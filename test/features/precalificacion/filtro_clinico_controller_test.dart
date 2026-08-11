import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/features/precalificacion/data/embudo_store.dart';
import 'package:glucy_app/features/precalificacion/data/precalificacion_repository.dart';
import 'package:glucy_app/features/precalificacion/domain/pregunta_filtro.dart';
import 'package:glucy_app/features/precalificacion/domain/veredicto.dart';
import 'package:glucy_app/features/precalificacion/presentation/filtro_clinico_controller.dart';

const _preguntas = [
  PreguntaFiltro(id: 1, codigo: 'q1', texto: 'Una', orden: 1, version: 1),
  PreguntaFiltro(id: 2, codigo: 'q2', texto: 'Dos', orden: 2, version: 1),
];

/// Doble en memoria: el real usa flutter_secure_storage, que no tiene canal
/// de plataforma en un test unitario puro.
class EmbudoStoreFalso implements EmbudoStore {
  Map<int, bool> progreso = {};
  int? precalificacionId;

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
    progreso = {};
    precalificacionId = null;
  }
}

class RepoFalso implements PrecalificacionRepository {
  RepoFalso({this.veredicto = const Veredicto(id: 1, resultado: Resultado.apto)});

  Veredicto veredicto;
  Object? errorAlEvaluar;
  Map<int, bool>? enviadas;
  int vinculadas = 0;

  @override
  Future<List<PreguntaFiltro>> preguntas() async => _preguntas;

  @override
  Future<Veredicto> evaluar(Map<int, bool> respuestas, {String? leadEmail}) async {
    enviadas = respuestas;
    if (errorAlEvaluar != null) throw errorAlEvaluar!;

    return veredicto;
  }

  @override
  Future<void> vincular(int precalificacionId) async => vinculadas++;
}

/// Solo para la prueba de `retry: null`: falla ya en `preguntas()`, que es lo
/// unico que corre dentro de `build()`. `evaluar()`/`vincular()` no hace
/// falta que hagan nada util, esa prueba nunca llega a llamarlos.
class RepoFalsoQueFallaAlCargar implements PrecalificacionRepository {
  @override
  Future<List<PreguntaFiltro>> preguntas() async => throw const FalloRed();

  @override
  Future<Veredicto> evaluar(Map<int, bool> respuestas, {String? leadEmail}) async =>
      throw UnimplementedError();

  @override
  Future<void> vincular(int precalificacionId) async => throw UnimplementedError();
}

ProviderContainer contenedor(PrecalificacionRepository repo, {EmbudoStore? store}) {
  final c = ProviderContainer(
    overrides: [
      precalificacionRepositoryProvider.overrideWithValue(repo),
      embudoStoreProvider.overrideWithValue(store ?? EmbudoStoreFalso()),
    ],
  );
  addTearDown(c.dispose);

  return c;
}

void main() {
  test('carga las preguntas del servidor', () async {
    final c = contenedor(RepoFalso());

    final estado = await c.read(filtroClinicoControllerProvider.future);

    expect(estado.preguntas, hasLength(2));
    expect(estado.respuestas, isEmpty);
    expect(estado.completo, isFalse);
  });

  test('el estado no esta completo hasta responderlas todas', () async {
    final c = contenedor(RepoFalso());
    await c.read(filtroClinicoControllerProvider.future);
    final notifier = c.read(filtroClinicoControllerProvider.notifier);
    notifier.escribirCorreo('maria@ejemplo.com');

    notifier.responder(1, true);
    expect(c.read(filtroClinicoControllerProvider).value!.completo, isFalse);

    notifier.responder(2, false);
    expect(c.read(filtroClinicoControllerProvider).value!.completo, isTrue);
  });

  test('el estado no esta completo sin un correo valido, aunque este todo respondido', () {
    const estado = EstadoFiltro(preguntas: _preguntas, respuestas: {1: true, 2: false});

    expect(estado.todasRespondidas, isTrue);
    expect(estado.completo, isFalse);

    expect(estado.copyWith(leadEmail: 'no-es-un-correo').completo, isFalse);
    expect(estado.copyWith(leadEmail: 'maria@ejemplo.com').completo, isTrue);
  });

  test('build() restaura el progreso guardado por una sesion anterior', () async {
    final store = EmbudoStoreFalso()..progreso = {1: true};
    final c = contenedor(RepoFalso(), store: store);

    final estado = await c.read(filtroClinicoControllerProvider.future);

    expect(estado.respuestas, {1: true});
  });

  test('build() descarta progreso de preguntas que ya no existen en el cuestionario vigente', () async {
    final store = EmbudoStoreFalso()..progreso = {1: true, 99: false};
    final c = contenedor(RepoFalso(), store: store);

    final estado = await c.read(filtroClinicoControllerProvider.future);

    expect(estado.respuestas, {1: true});
  });

  test('responder() guarda el progreso en el EmbudoStore', () async {
    final store = EmbudoStoreFalso();
    final c = contenedor(RepoFalso(), store: store);
    await c.read(filtroClinicoControllerProvider.future);
    final notifier = c.read(filtroClinicoControllerProvider.notifier);

    notifier.responder(1, true);

    expect(store.progreso, {1: true});
  });

  test('enviar() con exito guarda el id del veredicto para vincularlo despues', () async {
    final store = EmbudoStoreFalso();
    final repo = RepoFalso(veredicto: const Veredicto(id: 42, resultado: Resultado.apto));
    final c = contenedor(repo, store: store);
    await c.read(filtroClinicoControllerProvider.future);
    final notifier = c.read(filtroClinicoControllerProvider.notifier);

    notifier.responder(1, true);
    notifier.responder(2, false);
    notifier.escribirCorreo('maria@ejemplo.com');
    await notifier.enviar();

    expect(store.precalificacionId, 42);
  });

  test('responder dos veces la misma pregunta sustituye la respuesta', () async {
    final c = contenedor(RepoFalso());
    await c.read(filtroClinicoControllerProvider.future);
    final notifier = c.read(filtroClinicoControllerProvider.notifier);

    notifier.responder(1, true);
    notifier.responder(1, false);

    expect(c.read(filtroClinicoControllerProvider).value!.respuestas[1], isFalse);
  });

  test('enviar() manda todas las respuestas y devuelve el veredicto', () async {
    final repo = RepoFalso(veredicto: const Veredicto(id: 9, resultado: Resultado.urgente, motivo: 'sintomas'));
    final c = contenedor(repo);
    await c.read(filtroClinicoControllerProvider.future);
    final notifier = c.read(filtroClinicoControllerProvider.notifier);

    notifier.responder(1, true);
    notifier.responder(2, false);
    notifier.escribirCorreo('maria@ejemplo.com');

    final veredicto = await notifier.enviar();

    expect(repo.enviadas, {1: true, 2: false});
    expect(veredicto!.resultado, Resultado.urgente);
    expect(veredicto.motivo, 'sintomas');
  });

  test('enviar() sin responderlas todas no llama al servidor', () async {
    final repo = RepoFalso();
    final c = contenedor(repo);
    await c.read(filtroClinicoControllerProvider.future);
    final notifier = c.read(filtroClinicoControllerProvider.notifier);

    notifier.responder(1, true);

    expect(await notifier.enviar(), isNull);
    expect(repo.enviadas, isNull);
  });

  test('un fallo al evaluar conserva las respuestas, no las borra', () async {
    // Fix del review de Task 15: la version original tiraba el estado a
    // AsyncError, y el unico boton de esa pantalla (`ref.invalidate`) volvia
    // a pedir las preguntas con `respuestas: {}` -- un blip de red a mitad
    // del envio costaba las nueve respuestas.
    final repo = RepoFalso()..errorAlEvaluar = const FalloRed();
    final c = contenedor(repo);
    await c.read(filtroClinicoControllerProvider.future);
    final notifier = c.read(filtroClinicoControllerProvider.notifier);

    notifier.responder(1, true);
    notifier.responder(2, true);
    notifier.escribirCorreo('maria@ejemplo.com');

    expect(await notifier.enviar(), isNull);

    final estado = c.read(filtroClinicoControllerProvider);
    expect(estado.hasError, isFalse);
    expect(estado.value!.respuestas, {1: true, 2: true});
    expect(estado.value!.errorEnvio, isA<FalloRed>());
  });

  test('reintentar enviar() tras un fallo vuelve a mandar las mismas respuestas', () async {
    final repo = RepoFalso()..errorAlEvaluar = const FalloRed();
    final c = contenedor(repo);
    await c.read(filtroClinicoControllerProvider.future);
    final notifier = c.read(filtroClinicoControllerProvider.notifier);

    notifier.responder(1, true);
    notifier.responder(2, true);
    notifier.escribirCorreo('maria@ejemplo.com');
    await notifier.enviar();

    repo.errorAlEvaluar = null;
    final veredicto = await notifier.enviar();

    expect(veredicto, isNotNull);
    expect(repo.enviadas, {1: true, 2: true});
  });

  // Riverpod 3 reintenta un `build()` que lanza con backoff exponencial
  // (hasta 10 veces, hasta ~38s) salvo que el provider declare `retry: null`.
  // `filtroClinicoControllerProvider` lo declara (vease su archivo). Esta
  // prueba es la que de verdad ejercita esa ruta: a diferencia de las de
  // arriba, que fallan dentro de `enviar()` (nunca pasa por el retry de
  // Riverpod), esta falla dentro de `preguntas()`, que es lo que corre en
  // `build()`. El timeout corto es la aserción: sin `retry: null` esto
  // tardaria decenas de segundos y el test fallaria por timeout, no por el
  // valor del error.
  test(
    'un fallo de red al cargar las preguntas no reintenta con backoff',
    () async {
      final c = contenedor(RepoFalsoQueFallaAlCargar());

      await expectLater(
        c.read(filtroClinicoControllerProvider.future),
        throwsA(isA<FalloRed>()),
      );
    },
    timeout: const Timeout(Duration(seconds: 5)),
  );
}
