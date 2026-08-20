import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/doctor/validar_estudios_screen.dart';
import 'package:glucy_app/features/estudios/estudio_api.dart';

class EstudioApiFalso implements EstudioApi {
  EstudioApiFalso(this.pendientes);

  List<EstudioMedico> pendientes;
  final List<({int id, bool aprobar, String? motivo})> firmas = [];

  @override
  Future<List<EstudioMedico>> porValidar() async => pendientes;

  @override
  Future<void> validar({required int id, required bool aprobar, String? motivo}) async {
    firmas.add((id: id, aprobar: aprobar, motivo: motivo));
    pendientes = [for (final e in pendientes) if (e.id != id) e];
  }

  @override
  Future<Uri> enlaceArchivo(int archivoId) async => Uri.parse('https://glucy.test/firmado/$archivoId');

  @override
  Future<List<EstudioMedico>> propios() => throw UnimplementedError();

  @override
  Future<List<TipoEstudio>> tipos() => throw UnimplementedError();

  @override
  Future<int> subirArchivo({required String rutaArchivo, required String nombreArchivo}) =>
      throw UnimplementedError();

  @override
  Future<EstudioMedico> registrar({required int tipoEstudioId, required int archivoId, String? descripcion}) =>
      throw UnimplementedError();

  @override
  Future<EstudioMedico> subir({
    required int tipoEstudioId,
    required String rutaArchivo,
    required String nombreArchivo,
    String? descripcion,
  }) =>
      throw UnimplementedError();
}

EstudioMedico _estudio(int id, String nombre) => EstudioMedico(
      id: id,
      estado: 'pendiente',
      fecha: DateTime(2026, 8, 14),
      tipoEstudio: TipoEstudio(id: id, nombre: nombre),
      archivoId: 10 + id,
      pacienteNombre: 'Benjamin Heredia',
    );

Widget _app(EstudioApiFalso api) => ProviderScope(
      overrides: [estudioApiProvider.overrideWithValue(api)],
      child: const MaterialApp(home: ValidarEstudiosScreen()),
    );

void main() {
  testWidgets('lista los estudios pendientes con paciente y tipo', (tester) async {
    final api = EstudioApiFalso([_estudio(1, 'Perfil lipídico'), _estudio(2, 'Creatinina')]);

    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    expect(find.text('Perfil lipídico'), findsOneWidget);
    expect(find.text('Creatinina'), findsOneWidget);
    expect(find.textContaining('Benjamin Heredia'), findsNWidgets(2));
  });

  testWidgets('aprobar firma el veredicto y saca el estudio de la bandeja', (tester) async {
    final api = EstudioApiFalso([_estudio(1, 'Perfil lipídico')]);

    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aprobar'));
    await tester.pumpAndSettle();

    expect(api.firmas, [(id: 1, aprobar: true, motivo: null)]);
    expect(find.text('Perfil lipídico'), findsNothing);
    expect(find.textContaining('Sin estudios pendientes'), findsOneWidget);
  });

  testWidgets('rechazar exige motivo y lo manda al backend', (tester) async {
    final api = EstudioApiFalso([_estudio(1, 'Perfil lipídico')]);

    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rechazar'));
    await tester.pumpAndSettle();

    // Sin motivo el dialogo no firma nada.
    await tester.tap(find.widgetWithText(FilledButton, 'Rechazar'));
    await tester.pumpAndSettle();
    expect(api.firmas, isEmpty);

    await tester.enterText(find.byType(TextField), 'no se ve la fecha');
    await tester.tap(find.widgetWithText(FilledButton, 'Rechazar'));
    await tester.pumpAndSettle();

    expect(api.firmas, [(id: 1, aprobar: false, motivo: 'no se ve la fecha')]);
  });

  testWidgets('bandeja vacia muestra el estado sin pendientes', (tester) async {
    final api = EstudioApiFalso([]);

    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    expect(find.textContaining('Sin estudios pendientes'), findsOneWidget);
  });
}
