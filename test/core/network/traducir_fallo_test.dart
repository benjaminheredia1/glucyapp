import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/core/network/traducir_fallo.dart';

void main() {
  final peticion = RequestOptions(path: '/user');

  DioException conRespuesta(int codigo, {dynamic cuerpo, Map<String, List<String>>? cabeceras}) {
    return DioException(
      requestOptions: peticion,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: peticion,
        statusCode: codigo,
        data: cuerpo,
        headers: Headers.fromMap(cabeceras ?? {}),
      ),
    );
  }

  group('traducirFallo', () {
    test('un timeout de conexion es FalloRed', () {
      final fallo = traducirFallo(
        DioException(requestOptions: peticion, type: DioExceptionType.connectionTimeout),
      );

      expect(fallo, isA<FalloRed>());
    });

    test('un error de conexion es FalloRed', () {
      final fallo = traducirFallo(
        DioException(requestOptions: peticion, type: DioExceptionType.connectionError),
      );

      expect(fallo, isA<FalloRed>());
    });

    test('401 es FalloAuth', () {
      expect(traducirFallo(conRespuesta(401)), isA<FalloAuth>());
    });

    test('403 es FalloAuth', () {
      expect(traducirFallo(conRespuesta(403)), isA<FalloAuth>());
    });

    test('404 es FalloNoEncontrado', () {
      expect(traducirFallo(conRespuesta(404)), isA<FalloNoEncontrado>());
    });

    test('422 conserva el mapa de errores de Laravel', () {
      final fallo = traducirFallo(conRespuesta(422, cuerpo: {
        'message': 'The given data was invalid.',
        'errors': {
          'email': ['El correo ya esta registrado.'],
          'password': ['Minimo 8 caracteres.', 'Falta un numero.'],
        },
      }));

      expect(fallo, isA<FalloValidacion>());
      final validacion = fallo as FalloValidacion;
      expect(validacion.mensaje, 'The given data was invalid.');
      expect(validacion.errores['email'], ['El correo ya esta registrado.']);
      expect(validacion.errores['password'], hasLength(2));
    });

    test('422 sin cuerpo de errores no revienta', () {
      final fallo = traducirFallo(conRespuesta(422, cuerpo: {'message': 'Datos invalidos.'}));

      expect(fallo, isA<FalloValidacion>());
      expect((fallo as FalloValidacion).errores, isEmpty);
    });

    test('429 lee Retry-After en segundos', () {
      final fallo = traducirFallo(conRespuesta(429, cabeceras: {
        'retry-after': ['60'],
      }));

      expect(fallo, isA<FalloLimite>());
      expect((fallo as FalloLimite).reintentarEn, const Duration(seconds: 60));
    });

    test('429 sin Retry-After usa un minuto', () {
      final fallo = traducirFallo(conRespuesta(429));

      expect((fallo as FalloLimite).reintentarEn, const Duration(seconds: 60));
    });

    test('500 es FalloServidor y conserva el mensaje', () {
      final fallo = traducirFallo(conRespuesta(500, cuerpo: {'message': 'Boom'}));

      expect(fallo, isA<FalloServidor>());
      expect(fallo.mensaje, 'Boom');
    });

    test('503 es FalloServidor', () {
      expect(traducirFallo(conRespuesta(503)), isA<FalloServidor>());
    });

    test('un cuerpo que no es JSON no rompe la traduccion', () {
      final fallo = traducirFallo(conRespuesta(500, cuerpo: '<html>error</html>'));

      expect(fallo, isA<FalloServidor>());
      expect(fallo.mensaje, isNotEmpty);
    });

    test('una cancelacion es FalloDesconocido', () {
      final fallo = traducirFallo(
        DioException(requestOptions: peticion, type: DioExceptionType.cancel),
      );

      expect(fallo, isA<FalloDesconocido>());
    });
  });
}
