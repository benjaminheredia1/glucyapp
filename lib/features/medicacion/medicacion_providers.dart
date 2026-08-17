import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import 'medicacion_api.dart';

String _fechaLocal(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Tomas de hoy (fecha local del telefono, zona IANA de la config). Marcar
/// una toma lo invalida para que la lista se refresque.
final tomasDeHoyProvider = FutureProvider.autoDispose<List<TomaDelDia>>((ref) {
  final zona = ref.watch(appConfigProvider).zonaHoraria;

  return ref.watch(medicacionApiProvider).tomasDeHoy(dia: _fechaLocal(DateTime.now()), zona: zona);
});

/// Historial (tomas marcadas + mediciones), de la mas reciente a la mas
/// antigua. Lo invalidan marcar una toma y registrar glucosa.
final actividadProvider = FutureProvider.autoDispose<List<EntradaActividad>>(
  (ref) => ref.watch(medicacionApiProvider).actividad(),
);
