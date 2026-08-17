import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/embudo_store.dart';
import '../data/precalificacion_repository.dart';
import '../domain/pregunta_filtro.dart';
import '../domain/veredicto.dart';

// Solo freezed: EstadoFiltro se genera, el provider se declara a mano (este
// proyecto no usa el generador de Riverpod, vease sesion_controller.dart).
part 'filtro_clinico_controller.freezed.dart';

@freezed
abstract class EstadoFiltro with _$EstadoFiltro {
  const EstadoFiltro._();

  const factory EstadoFiltro({
    required List<PreguntaFiltro> preguntas,
    required Map<int, bool> respuestas,
    // Fallo de un `enviar()` anterior, para pintar un aviso sin tirar las
    // respuestas ya dadas. Es de la pantalla, no de dominio: no viaja a la
    // API ni se compara en tests salvo por su presencia.
    Object? errorEnvio,
  }) = _EstadoFiltro;

  /// `evaluar` aborta con 422 si faltan respuestas: el envio se bloquea antes.
  bool get todasRespondidas =>
      preguntas.isNotEmpty && respuestas.length == preguntas.length;

  /// Sin correo: la precalificacion viaja con el Bearer de la identidad
  /// anonima y el backend ya sabe de quien es.
  bool get completo => todasRespondidas;

  int get respondidas => respuestas.length;
}

class FiltroClinicoController extends AsyncNotifier<EstadoFiltro> {
  @override
  Future<EstadoFiltro> build() async {
    final preguntas = await ref.read(precalificacionRepositoryProvider).preguntas();
    final guardadas = await ref.read(embudoStoreProvider).leerProgreso();

    // Solo se recuperan respuestas de preguntas que siguen activas: el
    // cuestionario esta versionado y puede haber cambiado.
    final vigentes = preguntas.map((p) => p.id).toSet();

    return EstadoFiltro(
      preguntas: preguntas,
      respuestas: {
        for (final e in guardadas.entries)
          if (vigentes.contains(e.key)) e.key: e.value,
      },
    );
  }

  void responder(int preguntaId, bool si) {
    final actual = state.value;

    if (actual == null) return;

    final respuestas = {...actual.respuestas, preguntaId: si};
    state = AsyncData(actual.copyWith(respuestas: respuestas));

    // Sin await: guardar el progreso no debe frenar la interaccion.
    // `.ignore()`, no `unawaited(...)`: `unawaited` solo descarta el Future,
    // no le pone un manejador -- un fallo aqui seguiria escapando como error
    // asincrono sin dueño a nivel de zona. `.ignore()` es el idiom real de
    // Dart para "que corra y que de verdad no importe el resultado".
    ref.read(embudoStoreProvider).guardarProgreso(respuestas).ignore();
  }

  /// Devuelve `null` si falta responder algo o si el envio fallo. El veredicto lo calcula el servidor: aqui no hay ninguna regla
  /// clinica.
  ///
  /// Un fallo de `evaluar()` NO tira el estado a `AsyncError`: eso reemplazaria
  /// el cuestionario entero por la pantalla de error, y su unico boton
  /// (`ref.invalidate`) volveria a pedir las preguntas con `respuestas: {}` —
  /// un blip de red a mitad del envio costaria las nueve respuestas. En vez
  /// de eso, `actual` se conserva y el fallo se expone en `errorEnvio` para
  /// que la pantalla lo pinte como aviso, sin perder nada.
  Future<Veredicto?> enviar() async {
    final actual = state.value;

    if (actual == null || !actual.completo) return null;

    try {
      final veredicto = await ref
          .read(precalificacionRepositoryProvider)
          .evaluar(actual.respuestas);

      return veredicto;
    } catch (e) {
      state = AsyncData(actual.copyWith(errorEnvio: e));

      return null;
    }
  }
}

// Riverpod 3 reintenta un `build()` que lanza con backoff exponencial (hasta
// 10 veces, ~38s) salvo que el error sea un `Error` de Dart. `FalloRed` y el
// resto de `FalloApi` son `Exception`, asi que sin `retry: null` un fallo de
// red al pedir las preguntas quedaria reintentando en silencio en vez de
// mostrarse (mismo problema que resolvio sesion_controller.dart).
final filtroClinicoControllerProvider = AsyncNotifierProvider<FiltroClinicoController, EstadoFiltro>(
  FiltroClinicoController.new,
  retry: (retryCount, error) => null,
);
