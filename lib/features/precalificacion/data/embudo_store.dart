import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Las respuestas del filtro clinico ya no se cachean entre sesiones: cada
/// apertura del filtro empieza en blanco. El store queda solo para borrar lo
/// que versiones anteriores dejaron guardado (al abrir el filtro y al cerrar
/// sesion), porque son respuestas clinicas y no deben quedarse en el
/// dispositivo.
abstract interface class EmbudoStore {
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

  final FlutterSecureStorage _almacen;

  @override
  Future<void> limpiar() => _almacen.delete(key: _claveProgreso);
}

final embudoStoreProvider = Provider<EmbudoStore>((ref) => EmbudoStoreSeguro());
