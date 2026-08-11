import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/fallo_api.dart';
import '../../../core/storage/token_store.dart';
import '../../precalificacion/data/embudo_store.dart';
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
    required EmbudoStore embudo,
  })  : _gateway = gateway,
        _authApi = authApi,
        _usuarioApi = usuarioApi,
        _store = store,
        _embudo = embudo;

  final Auth0Gateway _gateway;
  final AuthApi _authApi;
  final UsuarioApi _usuarioApi;
  final TokenStore _store;
  final EmbudoStore _embudo;

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

    // Cada limpieza local es independiente: que una falle (un canal de
    // plataforma roto, por ejemplo) no puede impedir las demas, o un cierre
    // de sesion parcial dejaria credenciales o respuestas clinicas de una
    // persona expuestas a la siguiente en el mismo dispositivo.
    try {
      await _store.borrar();
    } catch (_) {}

    try {
      await _gateway.cerrarSesion();
    } catch (_) {}

    // Las respuestas del filtro clinico son de la persona que las respondio,
    // no del dispositivo: sin esto sobrevivirian a un cierre de sesion
    // explicito y se le mostrarian a quien abra el filtro despues en el
    // mismo telefono.
    try {
      await _embudo.limpiar();
    } catch (_) {}
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    gateway: ref.watch(auth0GatewayProvider),
    authApi: ref.watch(authApiProvider),
    usuarioApi: ref.watch(usuarioApiProvider),
    store: ref.watch(tokenStoreProvider),
    embudo: ref.watch(embudoStoreProvider),
  ),
);
