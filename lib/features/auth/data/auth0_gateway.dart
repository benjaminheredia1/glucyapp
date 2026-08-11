import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';

/// El usuario cerro Universal Login sin terminar. No es un error que mostrar.
class Auth0Cancelado implements Exception {
  const Auth0Cancelado();
}

/// Unico punto de la app que conoce `auth0_flutter`. Aislarlo permite probar
/// todo lo de arriba sin canales de plataforma.
abstract interface class Auth0Gateway {
  /// Abre Universal Login y devuelve el access token.
  /// Lanza [Auth0Cancelado] si el usuario se echa atras.
  Future<String> iniciarSesion();

  /// Access token vigente, renovado en silencio con el refresh token.
  /// `null` si ya no hay credenciales utilizables.
  Future<String?> accessTokenVigente();

  Future<void> cerrarSesion();
}

class Auth0GatewayReal implements Auth0Gateway {
  Auth0GatewayReal(this._config) : _auth0 = Auth0(_config.auth0Domain, _config.auth0ClientId);

  final AppConfig _config;
  final Auth0 _auth0;

  /// `offline_access` es lo que hace que Auth0 emita refresh token; `email` es
  /// obligatorio porque el backend consulta /userinfo.
  static const _scopes = {'openid', 'profile', 'email', 'offline_access'};

  @override
  Future<String> iniciarSesion() async {
    try {
      final credenciales = await _auth0
          .webAuthentication(scheme: _config.auth0Scheme)
          .login(audience: _config.auth0Audience, scopes: _scopes);

      return credenciales.accessToken;
    } on WebAuthenticationException catch (e) {
      // auth0_flutter 2.6.0 expone `isUserCancelledException`, no
      // `isCancellation` (nombre distinto al de versiones previas del SDK).
      if (e.isUserCancelledException) throw const Auth0Cancelado();

      rethrow;
    }
  }

  @override
  Future<String?> accessTokenVigente() async {
    if (!await _auth0.credentialsManager.hasValidCredentials()) {
      return null;
    }

    try {
      final credenciales = await _auth0.credentialsManager.credentials();

      return credenciales.accessToken;
    } on CredentialsManagerException {
      return null;
    }
  }

  @override
  Future<void> cerrarSesion() async {
    try {
      await _auth0.webAuthentication(scheme: _config.auth0Scheme).logout();
    } on WebAuthenticationException {
      // Salir en local no puede depender de que el tenant conteste.
    }

    await _auth0.credentialsManager.clearCredentials();
  }
}

final auth0GatewayProvider = Provider<Auth0Gateway>(
  (ref) => Auth0GatewayReal(ref.watch(appConfigProvider)),
);
