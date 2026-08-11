import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Interfaz para que los tests no dependan del Keychain ni de un canal de
/// plataforma.
abstract interface class TokenStore {
  Future<String?> leer();

  Future<void> guardar(String token);

  Future<void> borrar();
}

/// Keychain en iOS, EncryptedSharedPreferences en Android.
class TokenStoreSeguro implements TokenStore {
  // flutter_secure_storage 11.0.0 quito `encryptedSharedPreferences` de
  // AndroidOptions: el constructor por defecto ya cifra con AES-GCM y
  // envuelve la clave con RSA-OAEP, que es el comportamiento que antes
  // habia que pedir explicitamente con ese flag.
  TokenStoreSeguro([FlutterSecureStorage? almacen])
      : _almacen = almacen ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
            );

  static const _clave = 'glucy.token.sanctum';

  final FlutterSecureStorage _almacen;

  @override
  Future<String?> leer() => _almacen.read(key: _clave);

  @override
  Future<void> guardar(String token) => _almacen.write(key: _clave, value: token);

  @override
  Future<void> borrar() => _almacen.delete(key: _clave);
}

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStoreSeguro());
