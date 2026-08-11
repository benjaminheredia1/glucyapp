import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/auth_interceptor.dart';
import '../../../core/storage/token_store.dart';
import 'auth0_gateway.dart';
import 'auth_api.dart';

/// Rehace el token de Sanctum a partir del refresh token de Auth0.
///
/// No depende de `UsuarioApi`, y por tanto tampoco del `dio` que lleva el
/// `AuthInterceptor` que la usa: asi no hay ciclo.
class RenovadorSesion {
  const RenovadorSesion({
    required Auth0Gateway gateway,
    required AuthApi authApi,
    required TokenStore store,
  })  : _gateway = gateway,
        _authApi = authApi,
        _store = store;

  final Auth0Gateway _gateway;
  final AuthApi _authApi;
  final TokenStore _store;

  /// `null` significa "no se pudo": el interceptor cierra sesion.
  ///
  /// El catch es total (no solo `FalloApi`) a proposito: `AuthInterceptor`
  /// llama a esto sin su propio try/catch, encolado en un `QueuedInterceptor`.
  /// Si algo escapara de aqui -- un `TypeError` al parsear una respuesta
  /// malformada, un `PlatformException` del keystore al guardar -- la
  /// peticion original se quedaria sin resolver para siempre y bloquearia
  /// la cola de errores para cualquier 401 posterior.
  Future<String?> renovar() async {
    final accessToken = await _gateway.accessTokenVigente();

    if (accessToken == null) return null;

    try {
      final respuesta = await _authApi.intercambiar(accessToken);
      await _store.guardar(respuesta.token);

      return respuesta.token;
    } catch (_) {
      return null;
    }
  }
}

final renovadorSesionProvider = Provider<RenovadorSesion>(
  (ref) => RenovadorSesion(
    gateway: ref.watch(auth0GatewayProvider),
    authApi: ref.watch(authApiProvider),
    store: ref.watch(tokenStoreProvider),
  ),
);

/// La pieza que Task 12 usa para sobrescribir `renovadorProvider` en
/// `main.dart` y asi cerrar el circulo: aqui todavia no hay override, solo
/// se construye la renovacion de verdad para que esa tarea la enchufe.
final renovadorRealProvider = Provider<Renovador>(
  (ref) => ref.watch(renovadorSesionProvider).renovar,
);
