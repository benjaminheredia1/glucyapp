import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/network/error_interceptor.dart';
import 'package:glucy_app/features/medicacion/medicacion_api.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adaptador;
  late MedicacionApi api;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api'));
    adaptador = DioAdapter(dio: dio);
    dio.interceptors.add(ErrorInterceptor());
    api = MedicacionApi(dio);
  });

  // Forma real de GET /tomas: relacion en snake_case, fechas en UTC.
  Map<String, dynamic> tomaJson({int id = 9, String estado = 'pendiente', String? tomadaEn}) => {
        'id': id,
        'pacienteMedicamentoId': 3,
        'programadaEn': '2026-08-17T12:00:00.000000Z',
        'tomadaEn': tomadaEn,
        'estado': estado,
        'paciente_medicamento': {
          'id': 3,
          'dosis': '1 comprimido',
          'frecuencia': '2 veces al dia',
          'horarios': ['08:00', '20:00'],
          'medicamento': {'id': 1, 'nombre': 'Metformina', 'concentracion': '1000 mg'},
        },
      };

  group('tomasDeHoy', () {
    test('pide el dia y la zona y parsea medicamento, dosis y hora local', () async {
      adaptador.onGet(
        '/tomas',
        (servidor) => servidor.reply(200, {'data': [tomaJson()], 'total': 1}),
        queryParameters: {
          'dia': '2026-08-17',
          'zona': 'America/La_Paz',
          'orden': 'programadaEn',
          'direccion': 'asc',
          'porPagina': 50,
        },
      );

      final tomas = await api.tomasDeHoy(dia: '2026-08-17', zona: 'America/La_Paz');

      expect(tomas, hasLength(1));
      expect(tomas.first.id, 9);
      expect(tomas.first.medicamento, 'Metformina');
      expect(tomas.first.dosis, '1 comprimido');
      expect(tomas.first.estado, 'pendiente');
      expect(tomas.first.tomada, isFalse);
      expect(tomas.first.programadaEn.isUtc, isFalse, reason: 'se convierte a hora local');
      expect(tomas.first.programadaEn.toUtc(), DateTime.utc(2026, 8, 17, 12));
    });
  });

  group('marcar', () {
    test('POST /tomas/{id}/marcar con estado tomada', () async {
      adaptador.onPost(
        '/tomas/9/marcar',
        (servidor) => servidor.reply(200, tomaJson(estado: 'tomada', tomadaEn: '2026-08-17T12:05:00.000000Z')),
        data: {'estado': 'tomada'},
      );

      final toma = await api.marcar(9, tomada: true);

      expect(toma.tomada, isTrue);
      expect(toma.tomadaEn, isNotNull);
    });
  });

  group('actividad', () {
    test('parsea tomas y mediciones en el mismo historial', () async {
      adaptador.onGet(
        '/actividad',
        (servidor) => servidor.reply(200, {
          'data': [
            {
              'tipo': 'toma', 'en': '2026-08-17T12:05:00.000000Z', 'tomaId': 9, 'estado': 'tomada',
              'medicamento': 'Metformina', 'dosis': '1 comprimido', 'programadaEn': '2026-08-17T12:00:00.000000Z',
            },
            {
              'tipo': 'medicion', 'en': '2026-08-17T11:10:00.000000Z', 'medicionId': 3,
              'valor': '108.00', 'unidad': 'mg/dL', 'momento': 'ayunas',
            },
          ],
          'pagina': 1, 'porPagina': 50, 'total': 2,
        }),
        queryParameters: {'porPagina': 50},
      );

      final entradas = await api.actividad();

      expect(entradas, hasLength(2));
      expect(entradas[0], isA<ActividadToma>());
      expect((entradas[0] as ActividadToma).medicamento, 'Metformina');
      expect((entradas[0] as ActividadToma).tomada, isTrue);
      expect(entradas[1], isA<ActividadMedicion>());
      expect((entradas[1] as ActividadMedicion).valor, 108.0);
      expect(entradas[1].en.isUtc, isFalse);
    });
  });

  group('catalogos y alta (doctor)', () {
    test('medicamentos() y pacientes() leen data[]', () async {
      adaptador.onGet(
        '/medicamentos',
        (servidor) => servidor.reply(200, {
          'data': [
            {'id': 1, 'nombre': 'Metformina', 'concentracion': '1000 mg'},
            {'id': 2, 'nombre': 'Insulina glargina', 'concentracion': null},
          ],
        }),
        queryParameters: {'porPagina': 100, 'activo': 1},
      );
      adaptador.onGet(
        '/pacientes',
        (servidor) => servidor.reply(200, {
          'data': [
            {'id': 4, 'usuario': {'name': 'Maria', 'apellidoPaterno': 'Torres'}},
            {'id': 5, 'usuario': {'name': 'Paciente', 'apellidoPaterno': null}},
          ],
        }),
        queryParameters: {'porPagina': 100},
      );

      final medicamentos = await api.medicamentos();
      final pacientes = await api.pacientes();

      expect(medicamentos.map((m) => m.etiqueta), ['Metformina 1000 mg', 'Insulina glargina']);
      expect(pacientes.map((p) => p.nombre), ['Maria Torres', 'Paciente']);
    });

    test('asignar() manda horarios y fecha de inicio', () async {
      adaptador.onPost(
        '/paciente-medicamentos',
        (servidor) => servidor.reply(201, {'id': 3}),
        data: {
          'pacienteId': 4,
          'medicamentoId': 1,
          'dosis': '1 comprimido',
          'frecuencia': '2 veces al dia',
          'horarios': ['08:00', '20:00'],
          'fechaInicio': '2026-08-17',
        },
      );

      await expectLater(
        api.asignar(
          pacienteId: 4,
          medicamentoId: 1,
          dosis: '1 comprimido',
          frecuencia: '2 veces al dia',
          horarios: const ['08:00', '20:00'],
          fechaInicio: DateTime(2026, 8, 17),
        ),
        completes,
      );
    });
  });
}
