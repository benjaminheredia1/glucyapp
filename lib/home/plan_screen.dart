import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/features/medicacion/medicacion_api.dart';
import 'package:glucy_app/features/medicacion/medicacion_providers.dart';
import 'package:glucy_app/home/patient_tabbar.dart';
import 'package:glucy_app/shared/widgets/mensaje_error.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const tealBg = Color(0xFFDEF3EC);
  static const warnBg = Color(0xFFFBEEDA);
  static const warn = Color(0xFFB97417);
}

/// Plan de tratamiento vigente: las tomas de hoy (reales, `GET /tomas`),
/// marcables una a una, y el historial de actividad (`GET /actividad`).
class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  String _tab = 'meds';
  int? _marcando;

  static String _hora(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  static const _momentos = {'ayunas': 'en ayunas', 'preprandial': 'antes de comer', 'postprandial': '2 h después'};

  Future<void> _marcar(TomaDelDia toma) async {
    setState(() => _marcando = toma.id);

    try {
      await ref.read(medicacionApiProvider).marcar(toma.id, tomada: true);
      // La lista y el historial se leen de sus providers: invalidarlos basta.
      ref.invalidate(tomasDeHoyProvider);
      ref.invalidate(actividadProvider);
    } on FalloApi catch (fallo) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo marcar: ${fallo.mensaje}')));
    } finally {
      if (mounted) setState(() => _marcando = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(999)),
                    child: const Text('Validado por Dra. C. Núñez', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GlucyColors.primary)),
                  ),
                  const SizedBox(height: 8),
                  const Text('Mi plan', style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                  const Text('Vigente desde el 25 de julio', style: TextStyle(fontSize: 11.5, color: Color(0x8010262A))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _tabChip('meds', 'Medicamentos'),
                      const SizedBox(width: 6),
                      _tabChip('act', 'Actividad'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _tab == 'meds' ? _medsList() : _actividad(),
            ),
            const PatientTabBar(current: PatientTab.plan),
          ],
        ),
      ),
    );
  }

  Widget _tabChip(String key, String label) {
    final on = _tab == key;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => setState(() => _tab = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: on ? GlucyColors.primary : Colors.white, borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: on ? Colors.white : GlucyColors.ink)),
      ),
    );
  }

  Widget _cargando() => const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(strokeWidth: 2)));

  Widget _error(Object e, VoidCallback reintentar) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (e is FalloApi) MensajeError(e) else Text('$e'),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: reintentar, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  Widget _medsList() {
    return ref.watch(tomasDeHoyProvider).when(
          loading: _cargando,
          error: (e, _) => _error(e, () => ref.invalidate(tomasDeHoyProvider)),
          data: (tomas) => tomas.isEmpty ? _sinMedicacion() : _tomas(tomas),
        );
  }

  Widget _sinMedicacion() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Text(
          'Tu médico aún no cargó tu plan de medicación. Cuando lo haga, aquí verás las tomas de cada día.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, height: 1.5, color: Color(0x8C10262A)),
        ),
      ),
    );
  }

  Widget _tomas(List<TomaDelDia> tomas) {
    final tomadas = tomas.where((t) => t.tomada).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tomas de hoy: $tomadas de ${tomas.length}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xA610262A))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: GlucyColors.warnBg, borderRadius: BorderRadius.circular(999)),
                child: const Text('titulación activa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GlucyColors.warn)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final t in tomas) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: t.tomada ? GlucyColors.tealBg : GlucyColors.warnBg, borderRadius: BorderRadius.circular(9)),
                    child: Icon(Icons.medication_outlined, size: 18, color: t.tomada ? GlucyColors.primary : GlucyColors.warn),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${t.medicamento} · ${t.dosis}', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
                        Text(
                          t.tomada && t.tomadaEn != null
                              ? 'Programada ${_hora(t.programadaEn)} · tomada ${_hora(t.tomadaEn!)}'
                              : 'Programada ${_hora(t.programadaEn)}',
                          style: const TextStyle(fontSize: 11.5, color: Color(0x8C10262A)),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: t.pendiente && _marcando == null ? () => _marcar(t) : null,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: t.tomada ? GlucyColors.tealBg : Colors.white,
                      foregroundColor: GlucyColors.primary,
                      disabledForegroundColor: t.tomada ? GlucyColors.primary : null,
                      side: BorderSide(color: t.tomada ? GlucyColors.tealBg : const Color(0x4D0A7C86)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: _marcando == t.id
                        ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(
                            t.tomada ? 'Tomada' : (t.pendiente ? 'Marcar' : 'Omitida'),
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _actividad() {
    return ref.watch(actividadProvider).when(
          loading: _cargando,
          error: (e, _) => _error(e, () => ref.invalidate(actividadProvider)),
          data: (entradas) => entradas.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text('Aún no hay actividad: marca una toma o registra tu glucosa.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: Color(0x8C10262A))),
                  ),
                )
              : _historial(entradas),
        );
  }

  static String _tituloDia(DateTime d) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final dia = DateTime(d.year, d.month, d.day);
    final diff = hoy.difference(dia).inDays;

    return diff == 0 ? 'Hoy' : diff == 1 ? 'Ayer' : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  }

  Widget _historial(List<EntradaActividad> entradas) {
    // Agrupadas por dia local, conservando el orden (ya viene desc).
    final grupos = <String, List<EntradaActividad>>{};
    for (final e in entradas) {
      grupos.putIfAbsent(_tituloDia(e.en), () => []).add(e);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      children: [
        for (final grupo in grupos.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 8, 2, 6),
            child: Text(grupo.key, style: const TextStyle(fontFamily: 'Sora', fontSize: 12.5, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
          ),
          for (final e in grupo.value) _entrada(e),
        ],
      ],
    );
  }

  Widget _entrada(EntradaActividad e) {
    final (icono, tint, fg, titulo, detalle) = switch (e) {
      ActividadToma(:final medicamento, :final dosis, :final tomada) => (
          Icons.medication_outlined,
          tomada ? GlucyColors.tealBg : GlucyColors.warnBg,
          tomada ? GlucyColors.primary : GlucyColors.warn,
          '$medicamento · $dosis',
          tomada ? 'Tomada · ${_hora(e.en)}' : 'Omitida · ${_hora(e.en)}',
        ),
      ActividadMedicion(:final valor, :final unidad, :final momento) => (
          Icons.water_drop_outlined,
          GlucyColors.tealBg,
          GlucyColors.primary,
          '${valor == valor.roundToDouble() ? valor.toStringAsFixed(0) : valor.toStringAsFixed(1)} $unidad',
          'Glucosa ${_momentos[momento] ?? momento} · ${_hora(e.en)}',
        ),
    };

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(9)),
            child: Icon(icono, size: 17, color: fg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
                Text(detalle, style: const TextStyle(fontSize: 11.5, color: Color(0x8C10262A))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
