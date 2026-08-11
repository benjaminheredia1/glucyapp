import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/fallo_api.dart';
import '../../../core/storage/token_store.dart';
import '../domain/usuario.dart';
import 'auth0_gateway.dart';
import 'auth_api.dart';
import 'usuario_api.dart';

/// Orquesta las tres operaciones de sesion. La presentacion no sabe que hay un
/// proveedor de identidad detras.
class AuthRepository {
  const AuthRepository({
    required Auth0Gateway gateway,
    required AuthApi authApi,
    required UsuarioApi usuarioApi,
    required TokenStore store,
  })  : _gateway = gateway,
        _authApi = authApi,
        _usuarioApi = usuarioApi,
        _store = store;

  final Auth0Gateway _gateway;
  final AuthApi _authApi;
  final UsuarioApi _usuarioApi;
  final TokenStore _store;

  Future<Usuario> iniciarSesion() async {
    final accessToken = await _gateway.iniciarSesion();
    final respuesta = await _authApi.intercambiar(accessToken);

    await _store.guardar(respuesta.token);

    return respuesta.usuario;
  }

  /// `null` si no hay sesion que restaurar. Un fallo de red se propaga: no es
  /// lo mismo "no tienes sesion" que "no puedo comprobarla ahora".
  Future<Usuario?> restaurarSesion() async {
    final token = await _store.leer();

    if (token == null || token.isEmpty) return null;

    try {
      return await _usuarioApi.actual();
    } on FalloAuth {
      await _store.borrar();

      return null;
    }
  }

  Future<void> cerrarSesion() async {
    try {
      await _usuarioApi.cerrarSesion();
    } on FalloApi {
      // Salir tiene que funcionar aunque el servidor no conteste.
    }

    await _store.borrar();
    await _gateway.cerrarSesion();
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    gateway: ref.watch(auth0GatewayProvider),
    authApi: ref.watch(authApiProvider),
    usuarioApi: ref.watch(usuarioApiProvider),
    store: ref.watch(tokenStoreProvider),
  ),
);
