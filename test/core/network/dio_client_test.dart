import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/network/dio_client.dart';

void main() {
  group('redactarParaLog', () {
    test('redacta la cabecera Bearer', () {
      final resultado = redactarParaLog('Authorization: Bearer abc123.def456');

      expect(resultado, 'Authorization: Bearer <redactado>');
    });

    test('redacta "password" en el cuerpo', () {
      final resultado = redactarParaLog('{"password":"secreta"}');

      expect(resultado, '{"password":"<redactado>"}');
    });

    test('redacta "accessToken" (camelCase, el formato propio de la app)', () {
      final resultado = redactarParaLog('{"accessToken":"xyz"}');

      expect(resultado, '{"accessToken":"<redactado>"}');
    });

    // El intercambio con Auth0 (dioPublicoProvider) responde en snake_case:
    // sin esto, un LOG_HTTP=true en debug imprimiria el token en claro.
    test('redacta "access_token" (snake_case, el formato que devuelve Auth0)', () {
      final resultado = redactarParaLog('{"access_token":"xyz.abc.123"}');

      expect(resultado, '{"access_token":"<redactado>"}');
    });

    test('redacta "refresh_token"', () {
      final resultado = redactarParaLog('{"refresh_token":"xyz.abc.123"}');

      expect(resultado, '{"refresh_token":"<redactado>"}');
    });

    test('redacta "id_token"', () {
      final resultado = redactarParaLog('{"id_token":"xyz.abc.123"}');

      expect(resultado, '{"id_token":"<redactado>"}');
    });

    test('no toca el resto de la linea', () {
      final resultado = redactarParaLog('{"id":1,"nombre":"Ana"}');

      expect(resultado, '{"id":1,"nombre":"Ana"}');
    });
  });
}
