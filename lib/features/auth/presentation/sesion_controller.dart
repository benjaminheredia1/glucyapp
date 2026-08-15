import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../precalificacion/data/vinculador_precalificacion.dart';
import '../data/auth0_gateway.dart';
import '../data/auth_repository.dart';
import '../domain/sesion.dart';
import '../domain/usuario.dart';

/// Unica fuente de verdad del estado de sesion. El router y las pantallas leen
/// de aqui, nunca del almacenamiento ni de la API directamente.
class SesionController extends AsyncNotifier<Sesion> {
  @override
  Future<Sesion> build() async {
    final usuario = await ref.read(authRepositoryProvider).restaurarSesion();

    return usuario == null ? const Sesion.noAutenticado() : Sesion.autenticado(usuario);
  }

  Future<void> iniciarSesion({String? conexion}) async {
    state = const AsyncLoading();

    try {
      final usuario = await ref.read(authRepositoryProvider).iniciarSesion(conexion: conexion);
      state = AsyncData(Sesion.autenticado(usuario));
    } on Auth0Cancelado {
      // Echarse atras en Universal Login no es un fallo que reportar.
      state = const AsyncData(Sesion.noAutenticado());

      return;
    } catch (e, pila) {
      state = AsyncError(e, pila);

      return;
    }

    // Recupera la precalificacion que se respondio antes de tener cuenta.
    // Fuera del try de arriba y con su propio catch: ni siquiera un fallo al
    // construir `vinculadorPrecalificacionProvider` (no solo un fallo dentro
    // de `vincularPendiente()`, que ya se protege a si mismo) puede pisar el
    // estado de sesion autenticada que se acaba de fijar.
    try {
      await ref.read(vinculadorPrecalificacionProvider).vincularPendiente();
    } catch (_) {
      // No propaga: entrar no puede fallar por esto.
    }
  }

  /// Refresca el usuario en memoria tras editar el perfil, sin otra llamada a
  /// la API: el PATCH ya devolvio la cuenta actualizada.
  void fijarUsuario(Usuario usuario) {
    state = AsyncData(Sesion.autenticado(usuario));
  }

  Future<void> cerrarSesion() async {
    state = const AsyncLoading();

    try {
      await ref.read(authRepositoryProvider).cerrarSesion();
    } catch (_) {
      // Cerrar sesion tiene que completarse en la UI aunque algo de la
      // limpieza local falle: quedarse en AsyncLoading dejaria el boton
      // inerte, que es justo lo que este metodo existe para evitar.
    }

    state = const AsyncData(Sesion.noAutenticado());
  }
}

// Riverpod 3 reintenta un `build()` que lanza con backoff exponencial (hasta
// 10 veces, ~38s) salvo que el error sea un `Error` de Dart. `FalloRed` y el
// resto de `FalloApi` son `Exception`, asi que sin `retry: null` un fallo de
// red al restaurar quedaria reintentando en silencio en vez de mostrarse.
final sesionControllerProvider = AsyncNotifierProvider<SesionController, Sesion>(
  SesionController.new,
  retry: (retryCount, error) => null,
);
