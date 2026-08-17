import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  /// Identidad temporal (POST /auth/anonimo) para correr el embudo sin
  /// cuenta. Un fallo deja `AsyncError`: la pantalla lo pinta con
  /// `MensajeError` y deja reintentar.
  Future<void> entrarComoAnonimo() async {
    state = const AsyncLoading();

    try {
      final usuario = await ref.read(authRepositoryProvider).entrarComoAnonimo();
      state = AsyncData(Sesion.autenticado(usuario));
    } catch (e, pila) {
      state = AsyncError(e, pila);
    }
  }

  /// `reclamar` (por defecto): si hay una identidad temporal, el backend la
  /// convierte en la cuenta real. El portal medico llama con `false`.
  Future<void> iniciarSesion({String? conexion, bool reclamar = true}) async {
    // `AsyncLoading()` pierde el valor previo; se guarda para que cancelar
    // Auth0 no tire una sesion temporal que sigue viva.
    final anterior = state.value;
    state = const AsyncLoading();

    try {
      final usuario = await ref
          .read(authRepositoryProvider)
          .iniciarSesion(conexion: conexion, reclamar: reclamar);
      state = AsyncData(Sesion.autenticado(usuario));
    } on Auth0Cancelado {
      // Echarse atras en Universal Login no es un fallo que reportar.
      state = AsyncData(anterior ?? const Sesion.noAutenticado());
    } catch (e, pila) {
      state = AsyncError(e, pila);
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
