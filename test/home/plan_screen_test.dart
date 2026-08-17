import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/config/app_config.dart';
import 'package:glucy_app/features/medicacion/medicacion_api.dart';
import 'package:glucy_app/home/plan_screen.dart';

class MedicacionApiFalsa implements MedicacionApi {
  MedicacionApiFalsa({this.tomas = const [], this.entradas = const []});

  List<TomaDelDia> tomas;
  List<EntradaActividad> entradas;
  String? ultimoDia;
  String? ultimaZona;
  final List<int> marcadas = [];

  @override
  Future<List<TomaDelDia>> tomasDeHoy({required String dia, required String zona}) async {
    ultimoDia = dia;
    ultimaZona = zona;
    return tomas;
  }

  @override
  Future<TomaDelDia> marcar(int tomaId, {required bool tomada}) async {
    marcadas.add(tomaId);
    tomas = [
      for (final t in tomas)
        t.id == tomaId
            ? TomaDelDia(
                id: t.id,
                programadaEn: t.programadaEn,
                estado: 'tomada',
                medicamento: t.medicamento,
                dosis: t.dosis,
                tomadaEn: DateTime.now(),
              )
            : t,
    ];
    return tomas.firstWhere((t) => t.id == tomaId);
  }

  @override
  Future<List<EntradaActividad>> actividad({int porPagina = 50}) async => entradas;

  @override
  Future<List<MedicamentoCatalogo>> medicamentos() => throw UnimplementedError();

  @override
  Future<List<PacienteResumen>> pacientes() => throw UnimplementedError();

  @override
  Future<void> asignar({
    required int pacienteId,
    required int medicamentoId,
    required String dosis,
    required String frecuencia,
    required List<String> horarios,
    required DateTime fechaInicio,
    String? indicaciones,
  }) =>
      throw UnimplementedError();
}

final _config = AppConfig(
  apiBaseUrl: Uri.parse('http://localhost:8000/api'),
  timeout: const Duration(seconds: 5),
  logHttp: false,
  auth0Domain: 'x',
  auth0ClientId: 'x',
  auth0Audience: 'x',
  auth0Scheme: 'glucy',
  zonaHoraria: 'America/La_Paz',
);

Future<void> montar(WidgetTester tester, MedicacionApiFalsa api) async {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        medicacionApiProvider.overrideWithValue(api),
        appConfigProvider.overrideWithValue(_config),
      ],
      child: const MaterialApp(home: PlanScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

TomaDelDia _toma(int id, int hora, {String estado = 'pendiente'}) => TomaDelDia(
      id: id,
      programadaEn: DateTime(2026, 8, 17, hora, 0),
      estado: estado,
      medicamento: 'Metformina',
      dosis: '1 comprimido',
    );

void main() {
  testWidgets('lista las tomas de hoy con hora local y contador', (tester) async {
    final api = MedicacionApiFalsa(tomas: [_toma(9, 8, estado: 'tomada'), _toma(10, 20)]);

    await montar(tester, api);

    expect(api.ultimaZona, 'America/La_Paz');
    expect(api.ultimoDia, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    expect(find.text('Metformina · 1 comprimido'), findsNWidgets(2));
    expect(find.textContaining('08:00'), findsOneWidget);
    expect(find.textContaining('20:00'), findsOneWidget);
    expect(find.text('Tomas de hoy: 1 de 2'), findsOneWidget);
    expect(find.text('Tomada'), findsOneWidget);
    expect(find.text('Marcar'), findsOneWidget);
  });

  testWidgets('Marcar registra la toma en el servidor y refresca la lista', (tester) async {
    final api = MedicacionApiFalsa(tomas: [_toma(10, 20)]);
    await montar(tester, api);

    await tester.tap(find.text('Marcar'));
    await tester.pumpAndSettle();

    expect(api.marcadas, [10]);
    expect(find.text('Tomada'), findsOneWidget);
    expect(find.text('Tomas de hoy: 1 de 1'), findsOneWidget);
  });

  testWidgets('sin medicacion asignada lo dice', (tester) async {
    await montar(tester, MedicacionApiFalsa());

    expect(find.textContaining('aún no cargó tu plan de medicación'), findsOneWidget);
  });

  testWidgets('la pestaña Actividad agrupa por dia tomas y mediciones', (tester) async {
    final ahora = DateTime.now();
    final api = MedicacionApiFalsa(entradas: [
      ActividadToma(ahora.subtract(const Duration(minutes: 5)), medicamento: 'Metformina', dosis: '1 comprimido', estado: 'tomada'),
      ActividadMedicion(ahora.subtract(const Duration(hours: 1)), valor: 108, unidad: 'mg/dL', momento: 'ayunas'),
      ActividadToma(ahora.subtract(const Duration(days: 1)), medicamento: 'Metformina', dosis: '1 comprimido', estado: 'omitida'),
    ]);
    await montar(tester, api);

    await tester.tap(find.text('Actividad'));
    await tester.pumpAndSettle();

    expect(find.text('Hoy'), findsOneWidget);
    expect(find.text('Ayer'), findsOneWidget);
    expect(find.textContaining('Metformina'), findsNWidgets(2));
    expect(find.textContaining('108'), findsOneWidget);
    expect(find.textContaining('Omitida'), findsOneWidget);
    expect(find.textContaining('actividad física'), findsNothing);
  });
}
