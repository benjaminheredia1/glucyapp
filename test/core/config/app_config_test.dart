import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/config/app_config.dart';

void main() {
  Map<String, String> valido() => {
        'API_BASE_URL': 'http://10.0.2.2:8000/api',
        'API_TIMEOUT_MS': '15000',
        'LOG_HTTP': 'true',
        'AUTH0_DOMAIN': 'glucy.us.auth0.com',
        'AUTH0_CLIENT_ID': 'abc123',
        'AUTH0_AUDIENCE': 'https://api.glucy.local',
        'AUTH0_SCHEME': 'glucy',
      };

  group('AppConfig.desdeMapa', () {
    test('lee todos los valores de un mapa completo', () {
      final config = AppConfig.desdeMapa(valido());

      expect(config.apiBaseUrl, Uri.parse('http://10.0.2.2:8000/api'));
      expect(config.timeout, const Duration(milliseconds: 15000));
      expect(config.logHttp, isTrue);
      expect(config.auth0Domain, 'glucy.us.auth0.com');
      expect(config.auth0ClientId, 'abc123');
      expect(config.auth0Audience, 'https://api.glucy.local');
      expect(config.auth0Scheme, 'glucy');
    });

    test('sin ZONA_HORARIA asume America/La_Paz; con ella, la respeta', () {
      expect(AppConfig.desdeMapa(valido()).zonaHoraria, 'America/La_Paz');
      expect(AppConfig.desdeMapa({...valido(), 'ZONA_HORARIA': 'Europe/Madrid'}).zonaHoraria, 'Europe/Madrid');
    });

    test('falla si falta API_BASE_URL', () {
      final env = valido()..remove('API_BASE_URL');

      expect(
        () => AppConfig.desdeMapa(env),
        throwsA(isA<ConfigInvalida>().having((e) => e.mensaje, 'mensaje', contains('API_BASE_URL'))),
      );
    });

    test('falla si API_BASE_URL esta vacia', () {
      expect(
        () => AppConfig.desdeMapa(valido()..['API_BASE_URL'] = ''),
        throwsA(isA<ConfigInvalida>()),
      );
    });

    test('falla si API_BASE_URL no es absoluta', () {
      expect(
        () => AppConfig.desdeMapa(valido()..['API_BASE_URL'] = '/api'),
        throwsA(isA<ConfigInvalida>().having((e) => e.mensaje, 'mensaje', contains('absoluto'))),
      );
    });

    test('falla si falta cualquier clave de Auth0', () {
      for (final clave in ['AUTH0_DOMAIN', 'AUTH0_CLIENT_ID', 'AUTH0_AUDIENCE']) {
        expect(
          () => AppConfig.desdeMapa(valido()..remove(clave)),
          throwsA(isA<ConfigInvalida>().having((e) => e.mensaje, 'mensaje', contains(clave))),
          reason: 'deberia exigir $clave',
        );
      }
    });

    test('usa valores por defecto para el timeout, el log y el esquema', () {
      final env = valido()
        ..remove('API_TIMEOUT_MS')
        ..remove('LOG_HTTP')
        ..remove('AUTH0_SCHEME');

      final config = AppConfig.desdeMapa(env);

      expect(config.timeout, const Duration(milliseconds: 15000));
      expect(config.logHttp, isFalse);
      expect(config.auth0Scheme, 'glucy');
    });

    test('un API_TIMEOUT_MS no numerico cae al valor por defecto', () {
      final config = AppConfig.desdeMapa(valido()..['API_TIMEOUT_MS'] = 'pronto');

      expect(config.timeout, const Duration(milliseconds: 15000));
    });
  });
}
