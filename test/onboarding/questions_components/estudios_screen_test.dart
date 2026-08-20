import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/features/estudios/estudio_api.dart';
import 'package:glucy_app/onboarding/questions_components/estudios_screen.dart';

class EstudioApiFalso implements EstudioApi {
  EstudioApiFalso({required this.tipos_, this.propios_ = const []});

  List<TipoEstudio> tipos_;
  List<EstudioMedico> propios_;
  int archivosSubidos = 0;
  final List<int> tiposRegistrados = [];

  /// Tipos que "la IA" aprueba al momento en la proxima subida.
  List<int> aprobadosPorIa = const [];

  @override
  Future<List<TipoEstudio>> tipos() async => tipos_;

  @override
  Future<List<EstudioMedico>> propios() async => propios_;

  @override
  Future<ResultadoSubida> subirArchivo({required String rutaArchivo, required String nombreArchivo}) async {
    archivosSubidos++;

    final aprobados = [
      for (final tipoId in aprobadosPorIa)
        EstudioMedico(
          id: 200 + tipoId,
          estado: 'aprobado',
          fecha: DateTime(2026, 8, 20),
          tipoEstudioId: tipoId,
          archivoId: 9,
        ),
    ];
    propios_ = [...aprobados, ...propios_];

    return (archivoId: 9, aprobados: aprobados);
  }

  @override
  Future<EstudioMedico> registrar({required int tipoEstudioId, required int archivoId, String? descripcion}) async {
    tiposRegistrados.add(tipoEstudioId);
    final estudio = EstudioMedico(
      id: 100 + tipoEstudioId,
      estado: 'pendiente',
      fecha: DateTime(2026, 8, 17),
      tipoEstudioId: tipoEstudioId,
      archivoId: archivoId,
    );
    propios_ = [estudio, ...propios_];
    return estudio;
  }

  @override
  Future<EstudioMedico> subir({
    required int tipoEstudioId,
    required String rutaArchivo,
    required String nombreArchivo,
    String? descripcion,
  }) async {
    final subida = await subirArchivo(rutaArchivo: rutaArchivo, nombreArchivo: nombreArchivo);
    for (final aprobado in subida.aprobados) {
      if (aprobado.tipoEstudioId == tipoEstudioId) return aprobado;
    }
    return registrar(tipoEstudioId: tipoEstudioId, archivoId: subida.archivoId);
  }

  @override
  Future<List<EstudioMedico>> porValidar() => throw UnimplementedError();

  @override
  Future<void> validar({required int id, required bool aprobar, String? motivo}) => throw UnimplementedError();

  @override
  Future<Uri> enlaceArchivo(int archivoId) => throw UnimplementedError();
}

const _tipos = [
  TipoEstudio(id: 1, nombre: 'Glucemia en ayunas'),
  TipoEstudio(id: 2, nombre: 'Creatinina'),
  TipoEstudio(id: 3, nombre: 'Perfil lipídico'),
];

Future<void> montar(WidgetTester tester, EstudioApiFalso api) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [estudioApiProvider.overrideWithValue(api)],
      child: MaterialApp(
        home: EstudiosScreen(
          elegirArchivo: () async => (nombre: 'laboratorio-central.pdf', ruta: 'C:/tmp/laboratorio-central.pdf'),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('la carga conjunta aprueba lo que la IA detecta y no registra nada pendiente', (tester) async {
    final api = EstudioApiFalso(
      tipos_: _tipos,
      propios_: [
        EstudioMedico(id: 50, estado: 'aprobado', fecha: DateTime(2026, 8, 10), tipoEstudioId: 1),
      ],
    )..aprobadosPorIa = [2];
    await montar(tester, api);

    expect(find.text('Pendiente de subir'), findsNWidgets(2));

    await tester.ensureVisible(find.byKey(const Key('boton-subir-todo')));
    await tester.tap(find.byKey(const Key('boton-subir-todo')));
    await tester.pumpAndSettle();

    // Un solo archivo subido; la IA aprobo el tipo 2 y el 3 NO queda
    // registrado en revision (ya no hay quien lo revise): se pide otro
    // archivo.
    expect(api.archivosSubidos, 1);
    expect(api.tiposRegistrados, isEmpty);
    expect(find.text('Aprobado'), findsNWidgets(2));
    expect(find.text('Pendiente de subir'), findsOneWidget);
    expect(find.textContaining('Sube otro archivo con el estudio restante'), findsOneWidget);
  });

  testWidgets('un estudio rechazado se cubre cuando la IA lo detecta en la carga conjunta', (tester) async {
    final api = EstudioApiFalso(
      tipos_: _tipos.sublist(0, 2),
      propios_: [
        EstudioMedico(id: 51, estado: 'rechazado', fecha: DateTime(2026, 8, 10), tipoEstudioId: 1, motivoRechazo: 'borroso'),
      ],
    )..aprobadosPorIa = [1, 2];
    await montar(tester, api);

    await tester.ensureVisible(find.byKey(const Key('boton-subir-todo')));
    await tester.tap(find.byKey(const Key('boton-subir-todo')));
    await tester.pumpAndSettle();

    expect(api.tiposRegistrados, isEmpty);
    expect(find.text('Aprobado'), findsNWidgets(2));
  });

  testWidgets('subir en el casillero equivocado no registra ese tipo: vale lo que la IA detecto', (tester) async {
    final api = EstudioApiFalso(tipos_: _tipos)
      // El paciente toca "Glucemia" (tipo 1) pero el archivo es de Creatinina
      // (tipo 2): la IA detecta y aprueba el 2.
      ..aprobadosPorIa = [2];
    await montar(tester, api);

    await tester.tap(find.text('Glucemia en ayunas'));
    await tester.pumpAndSettle();

    // Nada registrado a mano: Glucemia sigue pendiente de subir y Creatinina
    // quedo aprobada por la IA.
    expect(api.tiposRegistrados, isEmpty);
    expect(find.text('Aprobado'), findsOneWidget);
    expect(find.text('Pendiente de subir'), findsNWidgets(2));
    expect(find.textContaining('La IA detectó y aprobó: Creatinina'), findsOneWidget);
  });

  testWidgets('si la IA no detecta nada, no se registra ningun pendiente y se pide otro archivo', (tester) async {
    final api = EstudioApiFalso(tipos_: _tipos);
    await montar(tester, api);

    await tester.tap(find.text('Glucemia en ayunas'));
    await tester.pumpAndSettle();

    expect(api.tiposRegistrados, isEmpty);
    expect(find.text('Pendiente de subir'), findsNWidgets(3));
    expect(find.textContaining('No encontramos resultados'), findsOneWidget);
  });

  testWidgets('una fila pendiente de la version vieja se puede volver a subir', (tester) async {
    final api = EstudioApiFalso(
      tipos_: _tipos.sublist(0, 2),
      propios_: [
        // Resto de cuando existia la revision del doctor: nadie la resolvera.
        EstudioMedico(id: 51, estado: 'pendiente', fecha: DateTime(2026, 8, 10), tipoEstudioId: 1),
      ],
    )..aprobadosPorIa = [1];
    await montar(tester, api);

    expect(find.textContaining('vuelve a subirlo'), findsOneWidget);

    await tester.tap(find.text('Glucemia en ayunas'));
    await tester.pumpAndSettle();

    expect(find.text('Aprobado'), findsOneWidget);
    expect(find.textContaining('vuelve a subirlo'), findsNothing);
  });

  testWidgets('con todo aprobado no se ofrece la carga conjunta', (tester) async {
    final api = EstudioApiFalso(
      tipos_: _tipos.sublist(0, 2),
      propios_: [
        EstudioMedico(id: 50, estado: 'aprobado', fecha: DateTime(2026, 8, 10), tipoEstudioId: 1),
        EstudioMedico(id: 51, estado: 'aprobado', fecha: DateTime(2026, 8, 10), tipoEstudioId: 2),
      ],
    );
    await montar(tester, api);

    expect(find.byKey(const Key('boton-subir-todo')), findsNothing);
  });
}
