import 'package:flutter/material.dart';
import 'package:glucy_app/doctor/caso_screen.dart';
import 'package:glucy_app/doctor/doctor_data.dart';
import 'package:glucy_app/doctor/doctor_tabbar.dart';

/// Bandeja de revisión: casos ordenables por urgencia o antigüedad, con
/// conteo rápido de urgentes/pendientes/estables.
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  String _sort = 'urgencia';

  int _count(Urgency u) => doctorCases.where((c) => c.urgency == u).length;

  @override
  Widget build(BuildContext context) {
    final list = [...doctorCases];
    if (_sort == 'urgencia') {
      const order = {Urgency.urgente: 0, Urgency.pendiente: 1, Urgency.estable: 2};
      list.sort((a, b) => order[a.urgency]!.compareTo(order[b.urgency]!));
    }
    final nuevos = doctorCases.where((c) => c.kind.contains('Ingreso')).length;

    return Scaffold(
      backgroundColor: DoctorColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dra. Carla Núñez · Endocrinología', style: TextStyle(fontSize: 12, color: Color(0x8010262A))),
                  const Text('Bandeja de revisión', style: TextStyle(fontFamily: 'Sora', fontSize: 21, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                  const SizedBox(height: 8),
                  Text('${doctorCases.length} casos esperan tu firma · $nuevos son ingresos nuevos', style: const TextStyle(fontSize: 12.5, color: Color(0x9910262A))),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      _statCard('Urgentes', _count(Urgency.urgente), Icons.error_outline, DoctorColors.alertBg, DoctorColors.alert),
                      const SizedBox(width: 9),
                      _statCard('Pendientes', _count(Urgency.pendiente), Icons.schedule, DoctorColors.warnBg, DoctorColors.warn),
                      const SizedBox(width: 9),
                      _statCard('Estables', _count(Urgency.estable), Icons.check_circle_outline, DoctorColors.tealBg, DoctorColors.primary),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      _sortChip('urgencia', 'Por urgencia'),
                      const SizedBox(width: 6),
                      _sortChip('antiguos', 'Más antiguos'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final c = list[i];
                  final meta = urgencyMeta(c.urgency);
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CasoScreen(item: c))),
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Container(width: 5, color: meta.fg),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(13),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(color: meta.tint, shape: BoxShape.circle),
                                    child: Text(c.initials, style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w700, color: meta.fg)),
                                  ),
                                  const SizedBox(width: 11),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(child: Text('${c.name}, ${c.age}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DoctorColors.ink))),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: meta.tint, borderRadius: BorderRadius.circular(999)),
                                              child: Text(meta.label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: meta.fg)),
                                            ),
                                          ],
                                        ),
                                        Text(c.kind, style: const TextStyle(fontSize: 11.5, color: Color(0x8010262A))),
                                        const SizedBox(height: 3),
                                        Text(c.task, style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xAD10262A))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const DoctorTabBar(current: DoctorTab.inbox),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, int count, IconData icon, Color tint, Color fg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 15, color: fg),
            ),
            const SizedBox(height: 5),
            Text('$count', style: const TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
            Text(label, style: const TextStyle(fontSize: 10.5, color: Color(0x8C10262A))),
          ],
        ),
      ),
    );
  }

  Widget _sortChip(String key, String label) {
    final on = _sort == key;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => setState(() => _sort = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(color: on ? DoctorColors.primary : Colors.white, borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: on ? Colors.white : DoctorColors.ink)),
      ),
    );
  }
}
