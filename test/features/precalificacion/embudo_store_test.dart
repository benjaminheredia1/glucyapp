import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/features/precalificacion/data/embudo_store.dart';

/// Doble minimo del backend de flutter_secure_storage: implementa el mismo
/// contrato que un Keychain/EncryptedSharedPreferences real, en memoria, para
/// no depender de un canal de plataforma (que no existe en un test unitario
/// puro).
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

  test('la etapa del embudo se guarda y se relee', () async {
    await store.guardarEtapa(EmbudoStore.etapaEstudios);

    expect(await store.leerEtapa(), 'estudios');
  });

  test('sin etapa guardada, leerEtapa() devuelve null', () async {
    expect(await store.leerEtapa(), isNull);
  });

  // El cache de respuestas se quito; `limpiarRespuestas()` borra lo que
  // versiones anteriores dejaron bajo esa clave sin tocar la etapa.
  test('limpiarRespuestas() borra el progreso viejo pero conserva la etapa', () async {
    plataforma.valores['glucy.embudo.respuestas'] = '{"1": true, "2": false}';
    await store.guardarEtapa(EmbudoStore.etapaEstudios);

    await store.limpiarRespuestas();

    expect(plataforma.valores.containsKey('glucy.embudo.respuestas'), isFalse);
    expect(await store.leerEtapa(), 'estudios');
  });

  test('limpiar() borra respuestas y etapa (cierre de sesion)', () async {
    plataforma.valores['glucy.embudo.respuestas'] = '{"1": true}';
    await store.guardarEtapa(EmbudoStore.etapaEstudios);

    await store.limpiar();

    expect(plataforma.valores, isEmpty);
  });

  test('limpiar() sin nada guardado no revienta', () async {
    await store.limpiar();

    expect(plataforma.valores, isEmpty);
  });
}
