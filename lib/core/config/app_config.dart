import 'package:flutter_riverpod/flutter_riverpod.dart';

/// La configuracion no es utilizable. Se lanza al arrancar, no a mitad de uso:
/// vale mas fallar con el motivo exacto que dar un 404 opaco tres pantallas mas
/// adelante.
class ConfigInvalida implements Exception {
  const ConfigInvalida(this.mensaje);

  final String mensaje;

  @override
  String toString() => 'ConfigInvalida: $mensaje';
}

/// Configuracion de runtime, leida de `.env` una sola vez al arrancar.
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.timeout,
    required this.logHttp,
    required this.auth0Domain,
    required this.auth0ClientId,
    required this.auth0Audience,
    required this.auth0Scheme,
  });

  final Uri apiBaseUrl;
  final Duration timeout;
  final bool logHttp;
  final String auth0Domain;
  final String auth0ClientId;
  final String auth0Audience;
  final String auth0Scheme;

  static const _timeoutPorDefecto = Duration(milliseconds: 15000);

  factory AppConfig.desdeMapa(Map<String, String> env) {
    final base = _exigido(env, 'API_BASE_URL');
    final uri = Uri.tryParse(base);

    if (uri == null || !uri.isAbsolute) {
      throw ConfigInvalida('API_BASE_URL tiene que ser un URI absoluto, y vale "$base".');
    }

    final ms = int.tryParse(env['API_TIMEOUT_MS'] ?? '');

    return AppConfig(
      apiBaseUrl: uri,
      timeout: ms == null ? _timeoutPorDefecto : Duration(milliseconds: ms),
      logHttp: (env['LOG_HTTP'] ?? '').toLowerCase() == 'true',
      auth0Domain: _exigido(env, 'AUTH0_DOMAIN'),
      auth0ClientId: _exigido(env, 'AUTH0_CLIENT_ID'),
      auth0Audience: _exigido(env, 'AUTH0_AUDIENCE'),
      auth0Scheme: (env['AUTH0_SCHEME'] ?? '').isEmpty ? 'glucy' : env['AUTH0_SCHEME']!,
    );
  }

  static String _exigido(Map<String, String> env, String clave) {
    final valor = env[clave];

    if (valor == null || valor.isEmpty) {
      throw ConfigInvalida('Falta $clave en .env. Copia .env.example y rellenalo.');
    }

    return valor;
  }
}

/// Lo sobrescribe `main.dart` con la config real, y cada test con la suya.
final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError('appConfigProvider tiene que sobrescribirse al arrancar.'),
);
