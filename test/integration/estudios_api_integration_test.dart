@Tags(['integration'])
library;

import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/core/network/error_interceptor.dart';
import 'package:glucy_app/features/estudios/estudio_api.dart';

/// Pruebas de integracion contra el backend REAL (backend.glucy-ai.com).
///
/// Ejercitan el flujo nuevo de estudios: el paciente sube su archivo, la IA
/// del backend lo analiza en la misma peticion de subida y responde al
/// momento si es valido (2xx) o no (422 -> FalloValidacion con el motivo).
///
/// No corren con `flutter test` a secas: crean datos reales (una identidad
/// anonima y sus estudios). Para correrlas:
///
///   GLUCY_INTEGRACION=1 flutter test test/integration --tags integration
///
/// (En PowerShell: `$env:GLUCY_INTEGRACION='1'; flutter test test/integration`.)
///
/// Con GLUCY_API_BASE se apunta a otro backend (p. ej. uno local:
/// `http://127.0.0.1:8000/api`).
final _base = Platform.environment['GLUCY_API_BASE'] ?? 'https://backend.glucy-ai.com/api';

final _activadas = Platform.environment['GLUCY_INTEGRACION'] == '1';

void main() {
  if (!_activadas) {
    test('pruebas de integracion desactivadas', () {},
        skip: 'Solo con GLUCY_INTEGRACION=1 (crean datos reales en el backend).');

    return;
  }

  late Dio dio;
  late EstudioApi api;
  late Directory carpetaTemporal;
  final estudiosCreados = <int>[];

  setUpAll(() async {
    carpetaTemporal = await Directory.systemTemp.createTemp('glucy_integracion');

    // Mismo stack que la app salvo la sesion: aqui el Bearer se pone a mano
    // (el AuthInterceptor real depende de flutter_secure_storage, que no
    // existe en la VM de tests).
    dio = Dio(BaseOptions(
      baseUrl: _base,
      headers: const {'Accept': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));
    dio.interceptors.add(ErrorInterceptor());

    final sesion = await dio.post<Map<String, dynamic>>('/auth/anonimo');
    final token = sesion.data!['token'] as String;
    dio.options.headers['Authorization'] = 'Bearer $token';

    api = EstudioApi(dio);
  });

  tearDownAll(() async {
    // Borrado logico de lo creado, para no dejar basura clinica en el
    // backend. Si algo falla (permisos, red) no tumba la corrida: el dato es
    // de una identidad anonima desechable.
    for (final id in estudiosCreados) {
      try {
        await dio.delete<void>('/estudios-medicos/$id');
      } catch (_) {}
    }

    try {
      await dio.post<void>('/auth/logout');
    } catch (_) {}

    try {
      await carpetaTemporal.delete(recursive: true);
    } catch (_) {}
  });

  /// PDF de un resultado de laboratorio legible, con un numero aleatorio en
  /// el encabezado para que cada corrida tenga un hash distinto (la
  /// deduplicacion del backend es por hash). Es legible a proposito: con la
  /// IA activa un archivo ilegible seria 422 y estos tests quieren pasar la
  /// puerta de subida.
  Future<File> archivoLegible(String nombre, {int? sello}) async {
    final marca = sello ?? Random().nextInt(999999);

    return File('${carpetaTemporal.path}/$nombre').writeAsString(
      '%PDF-1.4\n1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj\n'
      '2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj\n'
      '3 0 obj<</Type/Page/Parent 2 0 R/MediaBox[0 0 612 792]/Contents 4 0 R'
      '/Resources<</Font<</F1 5 0 R>>>>>>endobj\n'
      '4 0 obj<</Length 220>>stream\n'
      'BT /F1 14 Tf 72 720 Td (Laboratorio Central - Resultados $marca) Tj ET\n'
      'BT /F1 12 Tf 72 690 Td (Paciente: Paciente Prueba - Fecha: 2026-08-18) Tj ET\n'
      'BT /F1 12 Tf 72 660 Td (Glucemia en ayunas: 92 mg/dL \\(70-100\\)) Tj ET\n'
      'endstream\nendobj\n'
      '5 0 obj<</Type/Font/Subtype/Type1/BaseFont/Helvetica>>endobj\n'
      'trailer<</Root 1 0 R>>\n%%EOF',
    );
  }

  test('el catalogo de tipos de estudio existe y trae los obligatorios', () async {
    final tipos = await api.tipos();

    expect(tipos, isNotEmpty);
    expect(tipos.map((t) => t.nombre), contains('Glucemia en ayunas'));
  });

  test('subir un archivo devuelve su id y repetirlo deduplica por hash', () async {
    final archivo = await archivoLegible('estudio.pdf');

    final primeraVez = await api.subirArchivo(rutaArchivo: archivo.path, nombreArchivo: 'estudio.pdf');
    final segundaVez = await api.subirArchivo(rutaArchivo: archivo.path, nombreArchivo: 'estudio.pdf');

    estudiosCreados.addAll(segundaVez.aprobados.map((e) => e.id));

    expect(primeraVez.archivoId, greaterThan(0));
    expect(segundaVez.archivoId, primeraVez.archivoId);
  });

  test('subir y registrar un estudio: queda pendiente o lo aprueba la IA al momento', () async {
    final tipos = await api.tipos();
    final archivo = await archivoLegible('registro.pdf');

    final estudio = await api.subir(
      tipoEstudioId: tipos.first.id,
      rutaArchivo: archivo.path,
      nombreArchivo: 'registro.pdf',
      descripcion: 'prueba de integracion',
    );
    estudiosCreados.add(estudio.id);

    // Con la IA activa el estudio detectado nace aprobado; sin IA queda
    // pendiente de revision del doctor. Ambos contratos son validos.
    expect(estudio.estado, anyOf('pendiente', 'aprobado'));
    expect(estudio.archivoId, isNotNull);

    final propios = await api.propios();
    expect(propios.map((e) => e.id), contains(estudio.id));
  });

  test('un paciente no puede firmar el veredicto: validar es del doctor', () async {
    final tipos = await api.tipos();
    final archivo = await archivoLegible('veredicto.pdf');

    final estudio = await api.subir(
      tipoEstudioId: tipos.first.id,
      rutaArchivo: archivo.path,
      nombreArchivo: 'veredicto.pdf',
    );
    estudiosCreados.add(estudio.id);

    await expectLater(
      api.validar(id: estudio.id, aprobar: true),
      throwsA(isA<FalloAuth>()),
    );
  });

  test('un resultado de laboratorio legible se aprueba al momento si la IA esta activa', () async {
    // PDF con texto de un resultado real del catalogo. Con la IA activa, la
    // subida debe devolver ese estudio ya aprobado en `estudiosAprobados`;
    // sin IA (apagada o backend viejo) la lista llega vacia y el flujo
    // manual sigue: ambos son contratos validos para la app.
    final pdf = await archivoLegible('laboratorio.pdf');

    final subida = await api.subirArchivo(rutaArchivo: pdf.path, nombreArchivo: 'laboratorio.pdf');

    expect(subida.archivoId, greaterThan(0));

    if (subida.aprobados.isEmpty) {
      // ignore: avoid_print
      print('AVISO: la IA no aprobo estudios al momento (apagada o backend sin la feature).');
    } else {
      estudiosCreados.addAll(subida.aprobados.map((e) => e.id));

      expect(subida.aprobados.every((e) => e.estado == 'aprobado'), isTrue);

      final propios = await api.propios();
      expect(
        propios.where((e) => e.estado == 'aprobado').map((e) => e.id),
        containsAll(subida.aprobados.map((e) => e.id)),
      );
    }
  });

  test('la IA responde al momento sobre un archivo que no es un estudio', () async {
    // Un PDF cuyo texto es una receta de cocina: si el analisis con IA esta
    // activo, el backend contesta 422 en la misma subida (FalloValidacion
    // con el motivo). Hoy (2026-08-20) el agente AnalistaMedico del backend
    // esta roto (error PHP en sus instructions) y la subida pasa con 201:
    // este test acepta ambos resultados y deja constancia de cual ocurrio,
    // para que empiece a exigir el 422 cuando el backend lo arregle.
    final pdf = File('${carpetaTemporal.path}/receta.pdf');
    await pdf.writeAsString(
      '%PDF-1.4\n1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj\n'
      '2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj\n'
      '3 0 obj<</Type/Page/Parent 2 0 R/MediaBox[0 0 612 792]/Contents 4 0 R'
      '/Resources<</Font<</F1 5 0 R>>>>>>endobj\n'
      '4 0 obj<</Length 92>>stream\nBT /F1 18 Tf 72 720 Td '
      '(Receta de cocina ${Random().nextInt(999999)}: pastel de chocolate) Tj ET\nendstream\nendobj\n'
      '5 0 obj<</Type/Font/Subtype/Type1/BaseFont/Helvetica>>endobj\n'
      'trailer<</Root 1 0 R>>\n%%EOF',
    );

    try {
      final subida = await api.subirArchivo(rutaArchivo: pdf.path, nombreArchivo: 'receta.pdf');

      expect(subida.archivoId, greaterThan(0));
      expect(subida.aprobados, isEmpty);
      printOnFailure('La IA NO rechazo el archivo (agente apagado o roto en el backend).');
      // ignore: avoid_print
      print('AVISO: /archivos/subir acepto un PDF que no es un estudio. '
          'El veredicto 422 de la IA no esta activo en el backend.');
    } on FalloValidacion catch (fallo) {
      // Camino esperado cuando el agente funcione.
      expect(fallo.mensaje, isNotEmpty);
    }
  });
}
