import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Progreso del embudo, para que cerrar la app a mitad del filtro no borre lo
/// respondido.
///
/// Va en almacenamiento seguro no por secretismo, sino porque son respuestas
/// clinicas y `flutter_secure_storage` ya es dependencia del proyecto.
abstract interface class EmbudoStore {
  Future<void> guardarProgreso(Map<int, bool> respuestas);

  Future<Map<int, bool>> leerProgreso();

  Future<void> guardarPrecalificacion(int id);

  Future<int?> leerPrecalificacion();

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

  static const _claveProgreso = 'glucy.embudo.respuestas';
  static const _clavePrecalificacion = 'glucy.embudo.precalificacionId';

  final FlutterSecureStorage _almacen;

  @override
  Future<void> guardarProgreso(Map<int, bool> respuestas) {
    final serializable = respuestas.map((k, v) => MapEntry(k.toString(), v));

    return _almacen.write(key: _claveProgreso, value: jsonEncode(serializable));
  }

  @override
  Future<Map<int, bool>> leerProgreso() async {
    final crudo = await _almacen.read(key: _claveProgreso);

    if (crudo == null || crudo.isEmpty) return {};

    try {
      final mapa = jsonDecode(crudo) as Map<String, dynamic>;

      return mapa.map((k, v) => MapEntry(int.parse(k), v as bool));
    } on FormatException {
      // Formato viejo o corrupto: empezar limpio vale mas que reventar.
      await _almacen.delete(key: _claveProgreso);

      return {};
    }
  }

  @override
  Future<void> guardarPrecalificacion(int id) =>
      _almacen.write(key: _clavePrecalificacion, value: id.toString());

  @override
  Future<int?> leerPrecalificacion() async =>
      int.tryParse(await _almacen.read(key: _clavePrecalificacion) ?? '');

  @override
  Future<void> limpiar() async {
    await _almacen.delete(key: _claveProgreso);
    await _almacen.delete(key: _clavePrecalificacion);
  }
}

final embudoStoreProvider = Provider<EmbudoStore>((ref) => EmbudoStoreSeguro());
