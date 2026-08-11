import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/pregunta_filtro.dart';
import '../domain/veredicto.dart';
import 'precalificacion_api.dart';

class PrecalificacionRepository {
  PrecalificacionRepository(this._api);

  final PrecalificacionApi _api;

  List<PreguntaFiltro>? _cache;

  /// El cuestionario no cambia a mitad de sesion: se pide una vez.
  Future<List<PreguntaFiltro>> preguntas() async {
    return _cache ??= await _api.preguntas();
  }

  Future<Veredicto> evaluar(Map<int, bool> respuestas, {String? leadEmail}) {
    return _api.evaluar({
      'leadEmail': ?leadEmail,
      'respuestas': [
        for (final entrada in respuestas.entries)
          {'preguntaId': entrada.key, 'respuesta': entrada.value ? 'si' : 'no'},
      ],
    });
  }

  Future<void> vincular(int precalificacionId) => _api.vincular(precalificacionId);
}

final precalificacionRepositoryProvider = Provider<PrecalificacionRepository>(
  (ref) => PrecalificacionRepository(ref.watch(precalificacionApiProvider)),
);
