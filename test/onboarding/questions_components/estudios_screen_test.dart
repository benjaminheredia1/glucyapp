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

  @override
  Future<List<TipoEstudio>> tipos() async => tipos_;

  @override
  Future<List<EstudioMedico>> propios() async => propios_;

  @override
  Future<int> subirArchivo({required String rutaArchivo, required String nombreArchivo}) async {
    archivosSubidos++;
    return 9;
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
    final archivoId = await subirArchivo(rutaArchivo: rutaArchivo, nombreArchivo: nombreArchivo);
    return registrar(tipoEstudioId: tipoEstudioId, archivoId: archivoId);
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
  testWidgets('subir un archivo con todo registra cada estudio que faltaba y los marca subidos', (tester) async {
    final api = EstudioApiFalso(
      tipos_: _tipos,
      propios_: [
        // El tipo 1 ya esta aprobado: no se vuelve a registrar.
        EstudioMedico(id: 50, estado: 'aprobado', fecha: DateTime(2026, 8, 10), tipoEstudioId: 1),
      ],
    );
    await montar(tester, api);

    expect(find.text('Pendiente de subir'), findsNWidgets(2));

    await tester.ensureVisible(find.byKey(const Key('boton-subir-todo')));
    await tester.tap(find.byKey(const Key('boton-subir-todo')));
    await tester.pumpAndSettle();

    // Un solo archivo subido, un registro por cada tipo que faltaba.
    expect(api.archivosSubidos, 1);
    expect(api.tiposRegistrados, [2, 3]);
    expect(find.text('Pendiente de subir'), findsNothing);
    expect(find.textContaining('Subido · en revisión'), findsNWidgets(2));
  });

  testWidgets('un estudio rechazado tambien se cubre con la carga conjunta', (tester) async {
    final api = EstudioApiFalso(
      tipos_: _tipos.sublist(0, 2),
      propios_: [
        EstudioMedico(id: 51, estado: 'rechazado', fecha: DateTime(2026, 8, 10), tipoEstudioId: 1, motivoRechazo: 'borroso'),
      ],
    );
    await montar(tester, api);

    await tester.ensureVisible(find.byKey(const Key('boton-subir-todo')));
    await tester.tap(find.byKey(const Key('boton-subir-todo')));
    await tester.pumpAndSettle();

    expect(api.tiposRegistrados, [1, 2]);
  });

  testWidgets('con todo subido o aprobado no se ofrece la carga conjunta', (tester) async {
    final api = EstudioApiFalso(
      tipos_: _tipos.sublist(0, 2),
      propios_: [
        EstudioMedico(id: 50, estado: 'aprobado', fecha: DateTime(2026, 8, 10), tipoEstudioId: 1),
        EstudioMedico(id: 51, estado: 'pendiente', fecha: DateTime(2026, 8, 10), tipoEstudioId: 2),
      ],
    );
    await montar(tester, api);

    expect(find.byKey(const Key('boton-subir-todo')), findsNothing);
  });
}
