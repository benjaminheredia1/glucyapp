import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/features/precalificacion/data/embudo_store.dart';

/// Doble minimo del backend de flutter_secure_storage: implementa el mismo
/// contrato que un Keychain/EncryptedSharedPreferences real, en memoria, para
/// poder inyectar datos corruptos sin depender de un canal de plataforma
/// (que no existe en un test unitario puro).
class _PlataformaEnMemoria extends FlutterSecureStoragePlatform {
  final Map<String, String> valores = {};

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    valores[key] = value;
  }

  @override
  Future<String?> read({required String key, required Map<String, String> options}) async =>
      valores[key];

  @override
  Future<bool> containsKey({required String key, required Map<String, String> options}) async =>
      valores.containsKey(key);

  @override
  Future<void> delete({required String key, required Map<String, String> options}) async =>
      valores.remove(key);

  @override
  Future<Map<String, String>> readAll({required Map<String, String> options}) async =>
      Map.of(valores);

  @override
  Future<void> deleteAll({required Map<String, String> options}) async => valores.clear();
}

void main() {
  late _PlataformaEnMemoria plataforma;
  late EmbudoStoreSeguro store;

  setUp(() {
    plataforma = _PlataformaEnMemoria();
    FlutterSecureStoragePlatform.instance = plataforma;
    store = EmbudoStoreSeguro();
  });

  test('leerProgreso() con JSON bien formado funciona', () async {
    plataforma.valores['glucy.embudo.respuestas'] = '{"1": true, "2": false}';

    expect(await store.leerProgreso(), {1: true, 2: false});
  });

  test('leerProgreso() sin nada guardado devuelve vacio', () async {
    expect(await store.leerProgreso(), isEmpty);
  });

  // Review de Task 17: el catch original solo cubria FormatException. Un
  // JSON valido pero con otra forma no lanza eso -- lanza TypeError -- y se
  // escapaba sin capturar, dejando el filtro clinico entero atascado en
  // error (retry: null no reintenta solo).
  test('leerProgreso() con JSON valido pero que no es un mapa empieza limpio, no revienta', () async {
    plataforma.valores['glucy.embudo.respuestas'] = 'null';

    expect(await store.leerProgreso(), isEmpty);
  });

  test('leerProgreso() con una respuesta que no es booleana tambien empieza limpio', () async {
    plataforma.valores['glucy.embudo.respuestas'] = '{"1": "si"}';

    expect(await store.leerProgreso(), isEmpty);
  });

  test('leerProgreso() con formato viejo/corrupto (FormatException) sigue empezando limpio', () async {
    plataforma.valores['glucy.embudo.respuestas'] = 'no es json';

    expect(await store.leerProgreso(), isEmpty);
  });
}
