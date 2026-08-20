import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/network/error_interceptor.dart';
import 'package:glucy_app/features/estudios/estudio_api.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  group('EstudioMedico.fromJson', () {
    // Forma real de GET /estudios-medicos: Laravel serializa la relacion
    // eager-loaded como `tipo_estudio` (snake_case), aunque las columnas
    // propias vayan en camelCase (`tipoEstudioId`).
    final filaDelBackend = <String, dynamic>{
      'id': 6,
      'tipoEstudioId': 1,
      'pacienteId': 4,
      'archivoId': 2,
      'fecha': '2026-08-17T00:00:00.000000Z',
      'origen': 'carga',
      'estado': 'pendiente',
      'intento': 1,
      'tipo_estudio': {'id': 1, 'nombre': 'Glucemia en ayunas'},
      'archivo': {'id': 2, 'nombre': 'estudio.png'},
      'paciente': {'id': 4, 'usuario': {'name': 'Paciente', 'apellidoPaterno': null}},
    };

    test('lee la relacion tipo_estudio en snake_case', () {
      final estudio = EstudioMedico.fromJson(filaDelBackend);

      expect(estudio.tipoEstudio?.id, 1);
      expect(estudio.tipoEstudio?.nombre, 'Glucemia en ayunas');
      expect(estudio.estado, 'pendiente');
    });

    test('sigue aceptando tipoEstudio en camelCase', () {
      final json = Map<String, dynamic>.from(filaDelBackend)
        ..remove('tipo_estudio')
        ..['tipoEstudio'] = {'id': 3, 'nombre': 'Creatinina'};

      expect(EstudioMedico.fromJson(json).tipoEstudio?.id, 3);
    });

    test('sin relacion, se queda con el id de tipoEstudioId para poder cruzar la fila', () {
      final json = Map<String, dynamic>.from(filaDelBackend)..remove('tipo_estudio');

      final estudio = EstudioMedico.fromJson(json);

      expect(estudio.tipoEstudioId, 1);
      expect(estudio.tipoEstudio, isNull);
    });
  });

  group('subirArchivo y registrar', () {
    late Dio dio;
    late DioAdapter adaptador;
    late EstudioApi api;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api'));
      adaptador = DioAdapter(dio: dio);
      dio.interceptors.add(ErrorInterceptor());
      api = EstudioApi(dio);
    });

    test('subirArchivo devuelve el id y los estudios que la IA aprobo al momento', () async {
      final archivo = File('${Directory.systemTemp.path}/estudio-prueba.pdf')..writeAsBytesSync([1, 2, 3]);
      // En Windows el stream del multipart puede retener el handle un rato:
      // borrar es cortesia, no requisito del test.
      addTearDown(() {
        try {
          archivo.deleteSync();
        } on FileSystemException {
          // se queda en el temp del sistema
        }
      });

      adaptador.onPost(
        '/archivos/subir',
        (servidor) => servidor.reply(201, {
          'id': 9,
          'nombre': 'estudio-prueba.pdf',
          'estudiosAprobados': [
            {
              'id': 31,
              'estado': 'aprobado',
              'fecha': '2026-08-20T00:00:00.000000Z',
              'tipoEstudioId': 1,
              'archivoId': 9,
            },
          ],
        }),
        data: Matchers.any,
      );

      final subida = await api.subirArchivo(rutaArchivo: archivo.path, nombreArchivo: 'estudio-prueba.pdf');

      expect(subida.archivoId, 9);
      expect(subida.aprobados, hasLength(1));
      expect(subida.aprobados.first.estado, 'aprobado');
      expect(subida.aprobados.first.tipoEstudioId, 1);
    });

    test('subirArchivo tolera una respuesta sin estudiosAprobados (backend viejo)', () async {
      final archivo = File('${Directory.systemTemp.path}/estudio-viejo.pdf')..writeAsBytesSync([4, 5, 6]);
      addTearDown(() {
        try {
          archivo.deleteSync();
        } on FileSystemException {
          // se queda en el temp del sistema
        }
      });

      adaptador.onPost(
        '/archivos/subir',
        (servidor) => servidor.reply(201, {'id': 9, 'nombre': 'estudio-viejo.pdf'}),
        data: Matchers.any,
      );

      final subida = await api.subirArchivo(rutaArchivo: archivo.path, nombreArchivo: 'estudio-viejo.pdf');

      expect(subida.archivoId, 9);
      expect(subida.aprobados, isEmpty);
    });

    test('registrar crea el estudio de un tipo apuntando a un archivo ya subido', () async {
      final hoy = DateTime.now().toIso8601String().substring(0, 10);

      adaptador.onPost(
        '/estudios-medicos',
        (servidor) => servidor.reply(201, {
          'id': 20,
          'estado': 'pendiente',
          'fecha': '${hoy}T00:00:00.000000Z',
          'tipoEstudioId': 5,
          'archivoId': 9,
        }),
        data: {'tipoEstudioId': 5, 'archivoId': 9, 'fecha': hoy, 'origen': 'carga'},
      );

      final estudio = await api.registrar(tipoEstudioId: 5, archivoId: 9);

      expect(estudio.id, 20);
      expect(estudio.estado, 'pendiente');
    });
  });
}
