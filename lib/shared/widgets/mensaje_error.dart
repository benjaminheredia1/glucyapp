import 'package:flutter/material.dart';

import '../../app/theme/glucy_palette.dart';
import '../../core/error/fallo_api.dart';

/// Muestra un `FalloApi` con el detalle que cada tipo permite. Un 422 lista los
/// errores por campo; el resto muestra su mensaje.
class MensajeError extends StatelessWidget {
  const MensajeError(this.fallo, {super.key});

  final FalloApi fallo;

  @override
  Widget build(BuildContext context) {
    final lineas = switch (fallo) {
      FalloValidacion(:final errores) when errores.isNotEmpty =>
        errores.values.expand((mensajes) => mensajes).toList(),
      _ => [fallo.mensaje],
    };

    return Container(
      key: const Key('mensaje-error'),
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: GlucyPalette.alertBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final linea in lineas)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, size: 16, color: GlucyPalette.alert),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      linea,
                      style: const TextStyle(fontSize: 12, height: 1.5, color: GlucyPalette.alert),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
