import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

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
  }) = _EstadoFiltro;

  /// `evaluar` aborta con 422 si faltan respuestas: el envio se bloquea antes.
  bool get completo => preguntas.isNotEmpty && respuestas.length == preguntas.length;

  int get respondidas => respuestas.length;
}

class FiltroClinicoController extends AsyncNotifier<EstadoFiltro> {
  @override
  Future<EstadoFiltro> build() async {
    final preguntas = await ref.read(precalificacionRepositoryProvider).preguntas();

    return EstadoFiltro(preguntas: preguntas, respuestas: const {});
  }

  void responder(int preguntaId, bool si) {
    final actual = state.value;

    if (actual == null) return;

    state = AsyncData(
      actual.copyWith(respuestas: {...actual.respuestas, preguntaId: si}),
    );
  }

  /// Devuelve `null` si falta responder algo o si el envio fallo. El veredicto
  /// lo calcula el servidor: aqui no hay ninguna regla clinica.
  Future<Veredicto?> enviar({String? leadEmail}) async {
    final actual = state.value;

    if (actual == null || !actual.completo) return null;

    try {
      return await ref
          .read(precalificacionRepositoryProvider)
          .evaluar(actual.respuestas, leadEmail: leadEmail);
    } catch (e, pila) {
      // `copyWithPrevious` (para conservar `actual` junto al error) es
      // `@internal` en riverpod 3.4.2: usarlo fuera del propio paquete
      // dispara `invalid_use_of_internal_member`. La pantalla de error no lee
      // el valor previo de todos modos (`estado.when` no pasa por
      // `_contenido` en la rama `error`), asi que el `AsyncError` publico
      // basta.
      state = AsyncError<EstadoFiltro>(e, pila);

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
