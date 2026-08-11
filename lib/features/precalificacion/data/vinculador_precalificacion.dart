import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/fallo_api.dart';
import 'embudo_store.dart';
import 'precalificacion_repository.dart';

/// Ata la precalificacion que se respondio antes de tener cuenta al paciente
/// que acaba de entrar.
class VinculadorPrecalificacion {
  const VinculadorPrecalificacion({
    required PrecalificacionRepository repo,
    required EmbudoStore store,
  })  : _repo = repo,
        _store = store;

  final PrecalificacionRepository _repo;
  final EmbudoStore _store;

  /// No propaga nunca: que esto falle no puede impedir entrar en la app.
  ///
  /// El `catch` de fuera no es redundante con el `on FalloApi` de dentro: ese
  /// cubre el fallo de red esperado (el motivo de esta tarea), pero
  /// `leerPrecalificacion()`/`limpiar()` tambien pueden lanzar algo que no sea
  /// `FalloApi` (el almacen seguro corrupto, por ejemplo). La garantia del
  /// comentario de arriba es absoluta, no solo para fallos de red.
  Future<void> vincularPendiente() async {
    try {
      final id = await _store.leerPrecalificacion();

      if (id == null) return;

      try {
        await _repo.vincular(id);
        await _store.limpiar();
      } on FalloRed {
        // Puede que la sesion siga viva y el servidor no. Se conserva para
        // reintentarlo en el proximo acceso.
      } on FalloServidor {
        // 5xx: puede ser un despliegue a mitad de camino, no un rechazo. Se
        // conserva igual que un fallo de red.
      } on FalloLimite {
        // 429: el throttle de la ruta, justo despues de crear la sesion. No
        // es un rechazo del vinculo en si; se conserva para el proximo acceso.
      } on FalloApi {
        // 401/403, 404 o 409: la sesion no vale, esa precalificacion no es de
        // este usuario, no existe o ya estaba vinculada. Reintentarlo no la
        // va a arreglar.
        await _store.limpiar();
      }
    } catch (_) {
      // Fallo inesperado fuera de la llamada al servidor (almacen seguro,
      // por ejemplo): se ignora por la misma razon que los de arriba.
    }
  }
}

final vinculadorPrecalificacionProvider = Provider<VinculadorPrecalificacion>(
  (ref) => VinculadorPrecalificacion(
    repo: ref.watch(precalificacionRepositoryProvider),
    store: ref.watch(embudoStoreProvider),
  ),
);
