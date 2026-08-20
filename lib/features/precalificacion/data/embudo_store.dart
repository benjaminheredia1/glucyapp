import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Progreso local del embudo.
///
/// Las respuestas del filtro clinico ya no se cachean (cada apertura empieza
/// en blanco; `limpiarRespuestas` borra lo que versiones viejas guardaron).
/// Lo que si se cachea es la ETAPA: al llegar a la subida de estudios se
/// guarda, para que cerrar la app no obligue a repetir perfil y filtro — al
/// reabrir, el router salta directo a los estudios (los datos en si viven en
/// el backend). `limpiar()` borra todo al cerrar sesion.
abstract interface class EmbudoStore {
  /// Etapa que marca que el paciente ya paso el filtro y esta subiendo
  /// estudios.
  static const etapaEstudios = 'estudios';

  Future<void> guardarEtapa(String etapa);

  Future<String?> leerEtapa();

  Future<void> limpiarRespuestas();

  Future<void> limpiar();
}

class EmbudoStoreSeguro implements EmbudoStore {
  // flutter_secure_storage 11.0.0 quito `encryptedSharedPreferences` de
  // AndroidOptions: el constructor por defecto ya cifra con AES-GCM y
  // envuelve la clave con RSA-OAEP (vease token_store.dart).
  EmbudoStoreSeguro([FlutterSecureStorage? almacen])
      : _almacen = almacen ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
            );

  // Clave que usaba el cache de respuestas; se conserva para poder borrarla.
  static const _claveProgreso = 'glucy.embudo.respuestas';

  static const _claveEtapa = 'glucy.embudo.etapa';

  final FlutterSecureStorage _almacen;

  @override
  Future<void> guardarEtapa(String etapa) => _almacen.write(key: _claveEtapa, value: etapa);

  @override
  Future<String?> leerEtapa() => _almacen.read(key: _claveEtapa);

  @override
  Future<void> limpiarRespuestas() => _almacen.delete(key: _claveProgreso);

  @override
  Future<void> limpiar() async {
    await _almacen.delete(key: _claveProgreso);
    await _almacen.delete(key: _claveEtapa);
  }
}

final embudoStoreProvider = Provider<EmbudoStore>((ref) => EmbudoStoreSeguro());
