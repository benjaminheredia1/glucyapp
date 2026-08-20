@Tags(['integration'])
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/network/error_interceptor.dart';
import 'package:glucy_app/features/perfil/perfil_api.dart';

/// Pruebas de integracion del perfil contra el backend real. Mismo guard que
/// estudios_api_integration_test.dart:
///
///   GLUCY_INTEGRACION=1 flutter test test/integration --tags integration
final _base = Platform.environment['GLUCY_API_BASE'] ?? 'https://backend.glucy-ai.com/api';

final _activadas = Platform.environment['GLUCY_INTEGRACION'] == '1';

void main() {
  if (!_activadas) {
    test('pruebas de integracion desactivadas', () {},
        skip: 'Solo con GLUCY_INTEGRACION=1 (crean datos reales en el backend).');

    return;
  }

  late Dio dio;
  late PerfilApi api;

  setUpAll(() async {
    dio = Dio(BaseOptions(
      baseUrl: _base,
      headers: const {'Accept': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));
    dio.interceptors.add(ErrorInterceptor());

    final sesion = await dio.post<Map<String, dynamic>>('/auth/anonimo');
    dio.options.headers['Authorization'] = 'Bearer ${sesion.data!['token'] as String}';

    api = PerfilApi(dio);
  });

  tearDownAll(() async {
    try {
      await dio.post<void>('/auth/logout');
    } catch (_) {}
  });

  test('la medicacion actual del perfil se guarda, se reemplaza y se vacia', () async {
    final conDos = await api.actualizar(medicacionActual: const [
      (nombre: 'Metformina', cantidad: '850 mg'),
      (nombre: 'Enalapril', cantidad: null),
    ]);

    expect(conDos.paciente, isNotNull);
    expect(conDos.paciente!.medicacionActual, hasLength(2));
    expect(conDos.paciente!.medicacionActual.first, (nombre: 'Metformina', cantidad: '850 mg'));
    expect(conDos.paciente!.medicacionActual.last.cantidad, isNull);

    // Reemplazo completo, no acumulacion.
    final conUno = await api.actualizar(medicacionActual: const [
      (nombre: 'Insulina glargina', cantidad: '10 UI'),
    ]);

    expect(conUno.paciente!.medicacionActual, hasLength(1));
    expect(conUno.paciente!.medicacionActual.single.nombre, 'Insulina glargina');

    // Omitir el campo no toca la lista; [] la vacia.
    final sinTocar = await api.actualizar(name: 'Paciente Integracion');
    expect(sinTocar.paciente!.medicacionActual, hasLength(1));

    final vacia = await api.actualizar(medicacionActual: const []);
    expect(vacia.paciente!.medicacionActual, isEmpty);
  });
}
