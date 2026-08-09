import 'package:flutter/material.dart';
import 'package:glucy_app/doctor/caso_screen.dart';
import 'package:glucy_app/doctor/doctor_data.dart';
import 'package:glucy_app/doctor/doctor_tabbar.dart';

/// Alertas críticas y resueltas de la cartera, con acceso directo al
/// caso correspondiente.
class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  String _tab = 'criticas';

  @override
  Widget build(BuildContext context) {
    final list = doctorAlerts.where((a) => a.tab == _tab).toList();
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Alertas', style: TextStyle(fontFamily: 'Sora', fontSize: 21, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: DoctorColors.alertBg, borderRadius: BorderRadius.circular(999)),
                        child: const Text('3 sin atender', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DoctorColors.alert)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      _tabChip('criticas', 'Críticas'),
                      const SizedBox(width: 6),
                      _tabChip('resueltas', 'Resueltas'),
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
                  final a = list[i];
                  final border = a.tab == 'criticas' ? const Color(0x59E8574B) : const Color(0x400A7C86);
                  final tint = a.tab == 'criticas' ? DoctorColors.alertBg : DoctorColors.tealBg;
                  final fg = a.tab == 'criticas' ? DoctorColors.alert : DoctorColors.primary;
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: border), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(9)),
                              child: Icon(a.icon, size: 16, color: fg),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.title, style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w700, color: fg)),
                                  Text(a.who, style: const TextStyle(fontSize: 11.5, color: Color(0x8C10262A))),
                                ],
                              ),
                            ),
                            Text(a.time, style: const TextStyle(fontSize: 10.5, color: Color(0x7310262A))),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Text(a.detail, style: const TextStyle(fontSize: 12.5, height: 1.45, color: Color(0xB310262A))),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(foregroundColor: DoctorColors.ink, side: const BorderSide(color: Color(0x1F052E33)), padding: const EdgeInsets.symmetric(vertical: 10)),
                                child: const Text('Llamar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CasoScreen(item: caseById(a.id)))),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: DoctorColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                                ),
                                child: const Text('Ver caso', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const DoctorTabBar(current: DoctorTab.alertas),
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
        decoration: BoxDecoration(color: on ? DoctorColors.primary : Colors.white, borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: on ? Colors.white : DoctorColors.ink)),
      ),
    );
  }
}
