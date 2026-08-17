import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/doctor/asignar_medicacion_screen.dart';
import 'package:glucy_app/features/medicacion/medicacion_api.dart';

class MedicacionApiFalsa implements MedicacionApi {
  Map<String, Object?>? ultimaAsignacion;

  @override
  Future<List<MedicamentoCatalogo>> medicamentos() async => const [
        MedicamentoCatalogo(id: 1, nombre: 'Metformina', concentracion: '1000 mg'),
        MedicamentoCatalogo(id: 2, nombre: 'Insulina glargina'),
      ];

  @override
  Future<List<PacienteResumen>> pacientes() async => const [
        PacienteResumen(id: 4, nombre: 'Maria Torres'),
        PacienteResumen(id: 5, nombre: 'Pedro Paz'),
      ];

  @override
  Future<void> asignar({
    required int pacienteId,
    required int medicamentoId,
    required String dosis,
    required String frecuencia,
    required List<String> horarios,
    required DateTime fechaInicio,
    String? indicaciones,
  }) async {
    ultimaAsignacion = {
      'pacienteId': pacienteId,
      'medicamentoId': medicamentoId,
      'dosis': dosis,
      'frecuencia': frecuencia,
      'horarios': horarios,
      'indicaciones': indicaciones,
    };
  }

  @override
  Future<List<TomaDelDia>> tomasDeHoy({required String dia, required String zona}) => throw UnimplementedError();

  @override
  Future<TomaDelDia> marcar(int tomaId, {required bool tomada}) => throw UnimplementedError();

  @override
  Future<List<EntradaActividad>> actividad({int porPagina = 50}) => throw UnimplementedError();
}

void main() {
  testWidgets('el doctor asigna un medicamento con dos horarios', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final api = MedicacionApiFalsa();
    // En test no se abre el TimePicker: se inyectan las horas a elegir.
    final horas = [const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 20, minute: 0)];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [medicacionApiProvider.overrideWithValue(api)],
        child: MaterialApp(
          home: AsignarMedicacionScreen(seleccionarHora: (_) async => horas.removeAt(0)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('campo-paciente')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pedro Paz').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('campo-medicamento')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Metformina 1000 mg').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('campo-dosis')), '1 comprimido');
    await tester.enterText(find.byKey(const Key('campo-frecuencia')), '2 veces al día');

    await tester.tap(find.byKey(const Key('horario-agregar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('horario-agregar')));
    await tester.pumpAndSettle();

    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('20:00'), findsOneWidget);

    await tester.tap(find.byKey(const Key('boton-asignar')));
    await tester.pumpAndSettle();

    expect(api.ultimaAsignacion?['pacienteId'], 5);
    expect(api.ultimaAsignacion?['medicamentoId'], 1);
    expect(api.ultimaAsignacion?['dosis'], '1 comprimido');
    expect(api.ultimaAsignacion?['frecuencia'], '2 veces al día');
    expect(api.ultimaAsignacion?['horarios'], ['08:00', '20:00']);
  });

  testWidgets('sin horarios el boton no envia', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final api = MedicacionApiFalsa();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [medicacionApiProvider.overrideWithValue(api)],
        child: MaterialApp(home: AsignarMedicacionScreen(seleccionarHora: (_) async => null)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('boton-asignar')));
    await tester.pumpAndSettle();

    expect(api.ultimaAsignacion, isNull);
  });
}
