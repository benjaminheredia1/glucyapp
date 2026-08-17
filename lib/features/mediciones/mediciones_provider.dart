import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'medicion_api.dart';

/// Ultimas mediciones del paciente, de la mas antigua a la mas reciente
/// (orden natural para pintar una grafica). Una sola fuente para Inicio y
/// Progreso; `RegistrarScreen` la invalida al guardar para que ambas se
/// refresquen.
///
/// `autoDispose` para que un cambio de sesion no deje datos de otro paciente
/// en memoria: sin pantallas escuchando, el provider se descarta.
final medicionesProvider = FutureProvider.autoDispose<List<Medicion>>((ref) async {
  // Suficiente para 90 dias de un paciente que mide 1 vez al dia; Progreso
  // filtra por rango sobre esta lista.
  final recientes = await ref.watch(medicionApiProvider).recientes(cantidad: 100);

  return recientes.reversed.toList(growable: false);
});

extension MedicionesResumen on List<Medicion> {
  /// El registro considera "en rango" hasta 130 mg/dL (ver RegistrarScreen).
  static const limiteEnRango = 130.0;

  double? get promedio => isEmpty ? null : map((m) => m.valor).reduce((a, b) => a + b) / length;

  /// Porcentaje entero (0-100) de mediciones en rango; null sin datos.
  int? get porcentajeEnRango =>
      isEmpty ? null : (where((m) => m.valor <= limiteEnRango).length * 100 / length).round();

  /// Solo las de los ultimos [dias] dias, contados desde ahora.
  List<Medicion> ultimosDias(int dias, {DateTime? ahora}) {
    final desde = (ahora ?? DateTime.now()).subtract(Duration(days: dias));

    return where((m) => !m.medidoEn.isBefore(desde)).toList(growable: false);
  }
}
