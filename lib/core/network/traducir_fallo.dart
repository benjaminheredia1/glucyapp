import 'package:dio/dio.dart';

import '../error/fallo_api.dart';

/// Funcion pura para poder probarla sin levantar un cliente HTTP.
FalloApi traducirFallo(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
    // No esta en el brief: dio 5.11.0 agrego este caso despues de que se
    // escribiera. Es un timeout mas, así que cae con los demas.
    case DioExceptionType.transformTimeout:
      return const FalloRed();
    case DioExceptionType.badCertificate:
      return const FalloRed('El certificado del servidor no es valido.');
    case DioExceptionType.cancel:
      return const FalloDesconocido('Peticion cancelada.');
    case DioExceptionType.unknown:
    case DioExceptionType.badResponse:
      break;
  }

  final respuesta = e.response;

  if (respuesta == null) {
    return const FalloRed();
  }

  final cuerpo = respuesta.data;
  final datos = cuerpo is Map<String, dynamic> ? cuerpo : const <String, dynamic>{};
  final mensaje = datos['message'] as String?;

  switch (respuesta.statusCode) {
    case 401:
    case 403:
      return FalloAuth(mensaje ?? 'Tu sesion no es valida.');
    case 404:
      return FalloNoEncontrado(mensaje ?? 'No encontramos ese recurso.');
    case 409:
      return FalloConflicto(mensaje ?? 'Ese dato ya existe.');
    case 422:
      return FalloValidacion(mensaje ?? 'Revisa los datos.', _errores(datos));
    case 429:
      return FalloLimite(_reintentarEn(respuesta));
    default:
      final codigo = respuesta.statusCode ?? 0;

      if (codigo >= 500) {
        return FalloServidor(mensaje ?? 'El servidor tuvo un problema.');
      }

      return FalloDesconocido(mensaje ?? 'Respuesta inesperada ($codigo).');
  }
}

Map<String, List<String>> _errores(Map<String, dynamic> datos) {
  final crudos = datos['errors'];

  if (crudos is! Map) return const {};

  return crudos.map(
    (clave, valor) => MapEntry(
      clave.toString(),
      valor is List ? valor.map((m) => m.toString()).toList() : <String>[valor.toString()],
    ),
  );
}

Duration _reintentarEn(Response<dynamic> respuesta) {
  final cabecera = respuesta.headers.value('retry-after');
  final segundos = int.tryParse(cabecera ?? '');

  return Duration(seconds: segundos ?? 60);
}
