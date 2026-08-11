import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/fallo_api.dart';
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
  Future<String?> renovar() async {
    final accessToken = await _gateway.accessTokenVigente();

    if (accessToken == null) return null;

    try {
      final respuesta = await _authApi.intercambiar(accessToken);
      await _store.guardar(respuesta.token);

      return respuesta.token;
    } on FalloApi {
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

/// Cierra el circulo: `dioProvider` lee `renovadorProvider`, que ahora apunta a
/// la renovacion de verdad.
final renovadorRealProvider = Provider<Renovador>(
  (ref) => ref.watch(renovadorSesionProvider).renovar,
);
