import 'package:flutter/material.dart';
import 'package:glucy_app/doctor/doctor_data.dart';
import 'package:glucy_app/doctor/doctor_tabbar.dart';

class _Kpi {
  final String value;
  final String label;
  final Color color;
  const _Kpi(this.value, this.label, this.color);
}

class _LegendItem {
  final String label;
  final int count;
  final Color color;
  const _LegendItem(this.label, this.count, this.color);
}

/// Panel del médico: KPIs de su cartera, meta glucémica y validaciones
/// por semana.
class DashScreen extends StatelessWidget {
  const DashScreen({super.key});

  static const _kpis = [
    _Kpi('48', 'Pacientes activos', DoctorColors.deep),
    _Kpi('4h20', 'Validación media', DoctorColors.primary),
    _Kpi('96%', 'Casos en SLA', DoctorColors.primary),
  ];
  static const _legend = [
    _LegendItem('En meta', 31, DoctorColors.accent),
    _LegendItem('Cerca de meta', 12, Color(0xFFE8A33D)),
    _LegendItem('Fuera de meta', 5, DoctorColors.alert),
  ];
  static const _weekVals = [18, 24, 21, 26, 19, 23];

  @override
  Widget build(BuildContext context) {
    final maxW = _weekVals.reduce((a, b) => a > b ? a : b);
    return Scaffold(
      backgroundColor: DoctorColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mi panel', style: TextStyle(fontFamily: 'Sora', fontSize: 21, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                  Text('Julio 2026 · Clínica San Rafael', style: TextStyle(fontSize: 12, color: Color(0x8010262A))),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (final k in _kpis) ...[
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                children: [
                                  Text(k.value, style: TextStyle(fontFamily: 'Sora', fontSize: 18, fontWeight: FontWeight.w700, color: k.color)),
                                  Text(k.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, height: 1.3, color: Color(0x8C10262A))),
                                ],
                              ),
                            ),
                          ),
                          if (k != _kpis.last) const SizedBox(width: 9),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Pacientes en meta glucémica', style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                              Text('64%', style: TextStyle(fontFamily: 'Sora', fontSize: 17, fontWeight: FontWeight.w700, color: DoctorColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: SizedBox(
                              height: 14,
                              child: Row(
                                children: const [
                                  Expanded(flex: 64, child: ColoredBox(color: DoctorColors.accent)),
                                  Expanded(flex: 25, child: ColoredBox(color: Color(0xFFE8A33D))),
                                  Expanded(flex: 11, child: ColoredBox(color: DoctorColors.alert)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          for (final l in _legend) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(width: 9, height: 9, decoration: BoxDecoration(color: l.color, shape: BoxShape.circle)),
                                    const SizedBox(width: 7),
                                    Text(l.label, style: const TextStyle(fontSize: 11.5, color: Color(0xA610262A))),
                                  ],
                                ),
                                Text('${l.count}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: DoctorColors.ink)),
                              ],
                            ),
                            if (l != _legend.last) const SizedBox(height: 6),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Casos validados por semana', style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                              Text('promedio 22', style: TextStyle(fontSize: 11.5, color: Color(0x8010262A))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 110,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                for (var i = 0; i < _weekVals.length; i++) ...[
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text('${_weekVals[i]}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0x8010262A))),
                                        const SizedBox(height: 6),
                                        Container(
                                          height: (_weekVals[i] / maxW * 80).toDouble(),
                                          decoration: BoxDecoration(
                                            color: _weekVals[i] >= 22 ? DoctorColors.primary : DoctorColors.primary.withValues(alpha: 0.45),
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text('S${i + 1}', style: const TextStyle(fontSize: 9.5, color: Color(0x7310262A))),
                                      ],
                                    ),
                                  ),
                                  if (i != _weekVals.length - 1) const SizedBox(width: 9),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: DoctorColors.tealBg, borderRadius: BorderRadius.circular(14)),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.trending_up, size: 18, color: DoctorColors.primary),
                          SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tu impacto este mes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DoctorColors.deep)),
                                SizedBox(height: 3),
                                Text('HbA1c promedio de tu cartera: 7.9% → 7.1%. 31 pacientes alcanzaron su meta.',
                                    style: TextStyle(fontSize: 11.5, height: 1.5, color: DoctorColors.tealText)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const DoctorTabBar(current: DoctorTab.dash),
          ],
        ),
      ),
    );
  }
}
