/// Todo lo que puede salir mal al hablar con la API, en tipos que la UI puede
/// distinguir. Sin esto, un 422 con el detalle de cada campo y un 500 acaban
/// mostrando el mismo mensaje generico.
sealed class FalloApi implements Exception {
  const FalloApi(this.mensaje);

  final String mensaje;

  @override
  String toString() => '$runtimeType: $mensaje';
}

/// Sin conexion o el servidor no responde a tiempo.
class FalloRed extends FalloApi {
  const FalloRed([super.mensaje = 'No hay conexion con el servidor.']);
}

/// 401 o 403. La sesion no vale o no alcanza para este recurso.
class FalloAuth extends FalloApi {
  const FalloAuth([super.mensaje = 'Tu sesion no es valida.']);
}

/// 404. En esta API tambien significa "existe pero esta fuera de tu alcance":
/// `BaseCrudController` oculta la existencia de lo que no te corresponde.
class FalloNoEncontrado extends FalloApi {
  const FalloNoEncontrado([super.mensaje = 'No encontramos ese recurso.']);
}

/// 422. `errores` viene del validador de Laravel: campo -> lista de mensajes.
class FalloValidacion extends FalloApi {
  const FalloValidacion(super.mensaje, this.errores);

  final Map<String, List<String>> errores;

  /// Primer mensaje de un campo, para pintarlo bajo su TextField.
  /// `firstOrNull` vive en package:collection, y no merece la dependencia.
  String? primerError(String campo) {
    final mensajes = errores[campo];

    return (mensajes == null || mensajes.isEmpty) ? null : mensajes.first;
  }
}

/// 409. En esta API: el correo o la identidad de Auth0 ya pertenece a otra
/// cuenta al reclamar una identidad anonima. La cuenta anonima no se toca.
class FalloConflicto extends FalloApi {
  const FalloConflicto([super.mensaje = 'Ese dato ya existe.']);
}

/// 429. La API limita varias rutas con `throttle`.
class FalloLimite extends FalloApi {
  const FalloLimite(this.reintentarEn, [super.mensaje = 'Demasiados intentos. Prueba en un momento.']);

  final Duration reintentarEn;
}

/// 5xx.
class FalloServidor extends FalloApi {
  const FalloServidor([super.mensaje = 'El servidor tuvo un problema.']);
}

class FalloDesconocido extends FalloApi {
  const FalloDesconocido([super.mensaje = 'Algo salio mal.']);
}
