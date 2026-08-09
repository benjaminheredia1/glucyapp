import 'package:flutter/material.dart';
import 'package:glucy_app/home/patient_tabbar.dart';

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

class _Med {
  final String name;
  final String when;
  final IconData icon;
  bool taken;
  _Med({required this.name, required this.when, required this.icon, required this.taken});
}

/// Plan de tratamiento vigente, con las tomas del día marcables una a una.
class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  String _tab = 'meds';

  final List<_Med> _meds = [
    _Med(name: 'Metformina 1.000 mg', when: 'Con el desayuno · 08:00', icon: Icons.medication_outlined, taken: true),
    _Med(name: 'Metformina 1.000 mg', when: 'Con el almuerzo · 13:00', icon: Icons.medication_outlined, taken: false),
    _Med(name: 'Insulina glargina · 22 U', when: 'Subcutánea · 22:00', icon: Icons.vaccines_outlined, taken: false),
  ];

  int get _taken => _meds.where((m) => m.taken).length;

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
              child: _tab == 'meds' ? _medsList() : _actividadPlaceholder(),
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

  Widget _medsList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tomas de hoy: $_taken de ${_meds.length}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xA610262A))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: GlucyColors.warnBg, borderRadius: BorderRadius.circular(999)),
                child: const Text('titulación activa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GlucyColors.warn)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final m in _meds) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: m.taken ? GlucyColors.tealBg : GlucyColors.warnBg, borderRadius: BorderRadius.circular(9)),
                    child: Icon(m.icon, size: 18, color: m.taken ? GlucyColors.primary : GlucyColors.warn),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
                        Text(m.when, style: const TextStyle(fontSize: 11.5, color: Color(0x8C10262A))),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => setState(() => m.taken = !m.taken),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: m.taken ? GlucyColors.tealBg : Colors.white,
                      foregroundColor: GlucyColors.primary,
                      side: BorderSide(color: m.taken ? GlucyColors.tealBg : const Color(0x4D0A7C86)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: Text(m.taken ? 'Tomada' : 'Marcar', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(12)),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 17, color: GlucyColors.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'La insulina se ajusta dentro del rango autorizado por tu médica (18–26 U). Fuera de ese rango, ella revisa antes.',
                    style: TextStyle(fontSize: 11.5, height: 1.5, color: Color(0xFF0A5A62)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actividadPlaceholder() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Text('Aún no hay actividad física indicada en tu plan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: Color(0x8C10262A))),
      ),
    );
  }
}
