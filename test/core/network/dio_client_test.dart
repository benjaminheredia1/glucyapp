import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/network/dio_client.dart';

void main() {
  group('redactarParaLog', () {
    test('redacta la cabecera Bearer', () {
      final resultado = redactarParaLog('Authorization: Bearer abc123.def456');

      expect(resultado, 'Authorization: Bearer <redactado>');
    });

    test('redacta "password" en el cuerpo', () {
      final resultado = redactarParaLog('{"password":"secreta"}');

      expect(resultado, '{"password":"<redactado>"}');
    });

    test('redacta "accessToken" (camelCase, el formato propio de la app)', () {
      final resultado = redactarParaLog('{"accessToken":"xyz"}');

      expect(resultado, '{"accessToken":"<redactado>"}');
    });

    // El intercambio con Auth0 (dioPublicoProvider) responde en snake_case:
    // sin esto, un LOG_HTTP=true en debug imprimiria el token en claro.
    test('redacta "access_token" (snake_case, el formato que devuelve Auth0)', () {
      final resultado = redactarParaLog('{"access_token":"xyz.abc.123"}');

      expect(resultado, '{"access_token":"<redactado>"}');
    });

    test('redacta "refresh_token"', () {
      final resultado = redactarParaLog('{"refresh_token":"xyz.abc.123"}');

      expect(resultado, '{"refresh_token":"<redactado>"}');
    });

    test('redacta "id_token"', () {
      final resultado = redactarParaLog('{"id_token":"xyz.abc.123"}');

      expect(resultado, '{"id_token":"<redactado>"}');
    });

    test('no toca el resto de la linea', () {
      final resultado = redactarParaLog('{"id":1,"nombre":"Ana"}');

      expect(resultado, '{"id":1,"nombre":"Ana"}');
    });

    // Fix 4 del review final: `AuthApi.intercambiar` manda un `Map` de Dart
    // como cuerpo de peticion, no JSON. El logger de dio imprime ese Map con
    // `.toString()`, sin comillas alrededor de claves ni valores -- una forma
    // que este regex, hecho para el JSON citado de una RESPUESTA, no
    // reconoce. Esto no es un caso que la redaccion deba resolver: por eso
    // el fix real es apagar `requestBody` (vease el siguiente group), y este
    // test solo documenta por que la redaccion sola no basta.
    test('NO redacta el "accessToken" en la forma sin comillas que imprime un Map (por diseño)', () {
      final resultado = redactarParaLog('{accessToken: eyJhbGciOi.abc.def, dispositivo: api}');

      expect(resultado, contains('eyJhbGciOi.abc.def'));
    });
  });

  group('crearInterceptorLog', () {
    // El cuerpo de la peticion de AuthApi.intercambiar (un Map de Dart, no
    // JSON) es exactamente la forma que redactarParaLog no cubre (vease el
    // test de arriba): la unica manera de que el access token de Auth0 no
    // se imprima en claro es no imprimir el cuerpo de la peticion nunca.
    test('nunca imprime el cuerpo de la peticion', () {
      final interceptor = crearInterceptorLog();

      expect(interceptor.requestBody, isFalse);
    });

    // El cuerpo de la RESPUESTA si llega citado (JSON de verdad), asi que la
    // redaccion de arriba si lo cubre: no hace falta apagarlo tambien.
    test('si imprime el cuerpo de la respuesta (la redaccion lo cubre)', () {
      final interceptor = crearInterceptorLog();

      expect(interceptor.responseBody, isTrue);
    });
  });
}
