import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/features/precalificacion/data/embudo_store.dart';
import 'package:glucy_app/features/precalificacion/data/precalificacion_repository.dart';
import 'package:glucy_app/features/precalificacion/data/vinculador_precalificacion.dart';
import 'package:glucy_app/features/precalificacion/domain/pregunta_filtro.dart';
import 'package:glucy_app/features/precalificacion/domain/veredicto.dart';

class EmbudoStoreFalso implements EmbudoStore {
  Map<int, bool> progreso = {};
  int? precalificacionId;
  int limpiezas = 0;

  @override
  Future<void> guardarProgreso(Map<int, bool> respuestas) async => progreso = respuestas;

  @override
  Future<Map<int, bool>> leerProgreso() async => progreso;

  @override
  Future<void> guardarPrecalificacion(int id) async => precalificacionId = id;

  @override
  Future<int?> leerPrecalificacion() async => precalificacionId;

  @override
  Future<void> limpiar() async {
    limpiezas++;
    progreso = {};
    precalificacionId = null;
  }
}

/// Para probar que la garantia de "nunca propaga" no depende de que el fallo
/// sea justo un `FalloApi`: un almacen seguro corrupto lanzaria otra cosa.
class EmbudoStoreQueFallaAlLeer implements EmbudoStore {
  @override
  Future<int?> leerPrecalificacion() async => throw Exception('almacen corrupto');

  @override
  Future<void> guardarProgreso(Map<int, bool> respuestas) async {}

  @override
  Future<Map<int, bool>> leerProgreso() async => {};

  @override
  Future<void> guardarPrecalificacion(int id) async {}

  @override
  Future<void> limpiar() async {}
}

class RepoFalso implements PrecalificacionRepository {
  Object? errorAlVincular;
  final vinculadas = <int>[];

  @override
  Future<List<PreguntaFiltro>> preguntas() async => const [];

  @override
  Future<Veredicto> evaluar(Map<int, bool> respuestas, {String? leadEmail}) async =>
      const Veredicto(id: 1, resultado: Resultado.apto);

  @override
  Future<void> vincular(int precalificacionId) async {
    vinculadas.add(precalificacionId);
    if (errorAlVincular != null) throw errorAlVincular!;
  }
}

void main() {
  late EmbudoStoreFalso store;
  late RepoFalso repo;
  late VinculadorPrecalificacion vinculador;

  setUp(() {
    store = EmbudoStoreFalso();
    repo = RepoFalso();
    vinculador = VinculadorPrecalificacion(repo: repo, store: store);
  });

  test('sin precalificacion pendiente no llama al servidor', () async {
    await vinculador.vincularPendiente();

    expect(repo.vinculadas, isEmpty);
  });

  test('vincula la pendiente y limpia el embudo', () async {
    await store.guardarPrecalificacion(42);

    await vinculador.vincularPendiente();

    expect(repo.vinculadas, [42]);
    expect(store.limpiezas, 1);
    expect(await store.leerPrecalificacion(), isNull);
  });

  test('un 403 limpia igualmente: esa precalificacion no es de este usuario', () async {
    await store.guardarPrecalificacion(99);
    repo.errorAlVincular = const FalloAuth();

    await vinculador.vincularPendiente();

    expect(store.limpiezas, 1);
  });

  test('un fallo de red no limpia: se reintenta en el proximo acceso', () async {
    await store.guardarPrecalificacion(42);
    repo.errorAlVincular = const FalloRed();

    await vinculador.vincularPendiente();

    expect(store.limpiezas, 0);
    expect(await store.leerPrecalificacion(), 42);
  });

  test('un fallo del servidor (5xx) tampoco limpia: puede ser un despliegue a mitad de camino', () async {
    await store.guardarPrecalificacion(42);
    repo.errorAlVincular = const FalloServidor();

    await vinculador.vincularPendiente();

    expect(store.limpiezas, 0);
    expect(await store.leerPrecalificacion(), 42);
  });

  test('un 429 (throttle) tampoco limpia: no es un rechazo del vinculo en si', () async {
    await store.guardarPrecalificacion(42);
    repo.errorAlVincular = const FalloLimite(Duration(seconds: 30));

    await vinculador.vincularPendiente();

    expect(store.limpiezas, 0);
    expect(await store.leerPrecalificacion(), 42);
  });

  test('nunca propaga: entrar no puede fallar por esto', () async {
    await store.guardarPrecalificacion(42);
    repo.errorAlVincular = const FalloServidor();

    await expectLater(vinculador.vincularPendiente(), completes);
  });

  test('tampoco propaga un fallo que no sea FalloApi, como un almacen corrupto', () async {
    final vinculadorConAlmacenRoto = VinculadorPrecalificacion(
      repo: repo,
      store: EmbudoStoreQueFallaAlLeer(),
    );

    await expectLater(vinculadorConAlmacenRoto.vincularPendiente(), completes);
    expect(repo.vinculadas, isEmpty);
  });
}
