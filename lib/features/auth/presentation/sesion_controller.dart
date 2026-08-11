import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth0_gateway.dart';
import '../data/auth_repository.dart';
import '../domain/sesion.dart';

/// Unica fuente de verdad del estado de sesion. El router y las pantallas leen
/// de aqui, nunca del almacenamiento ni de la API directamente.
class SesionController extends AsyncNotifier<Sesion> {
  @override
  Future<Sesion> build() async {
    final usuario = await ref.read(authRepositoryProvider).restaurarSesion();

    return usuario == null ? const Sesion.noAutenticado() : Sesion.autenticado(usuario);
  }

  Future<void> iniciarSesion() async {
    state = const AsyncLoading();

    try {
      final usuario = await ref.read(authRepositoryProvider).iniciarSesion();
      state = AsyncData(Sesion.autenticado(usuario));
    } on Auth0Cancelado {
      // Echarse atras en Universal Login no es un fallo que reportar.
      state = const AsyncData(Sesion.noAutenticado());
    } catch (e, pila) {
      state = AsyncError(e, pila);
    }
  }

  Future<void> cerrarSesion() async {
    state = const AsyncLoading();
    await ref.read(authRepositoryProvider).cerrarSesion();
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
