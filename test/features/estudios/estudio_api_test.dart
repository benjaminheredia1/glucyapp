import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/features/estudios/estudio_api.dart';

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
}
