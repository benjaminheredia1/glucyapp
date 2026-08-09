import 'package:flutter/material.dart';
import 'package:glucy_app/home/cuenta_screen.dart';
import 'package:glucy_app/home/faq_screen.dart';
import 'package:glucy_app/home/home_screen.dart';
import 'package:glucy_app/home/plan_screen.dart';
import 'package:glucy_app/home/progreso_screen.dart';

class GlucyTabColors {
  static const primary = Color(0xFF0A7C86);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const inactive = Color(0x6610262A); // rgba(16,38,42,0.4)
}

enum PatientTab { home, plan, progreso, faq, cuenta }

class _TabDef {
  final PatientTab tab;
  final String label;
  final IconData icon;
  const _TabDef(this.tab, this.label, this.icon);
}

/// Barra inferior compartida por las 5 pantallas principales del paciente
/// (Inicio, Mi plan, Progreso, Ayuda, Cuenta). Cambia de pestaña con
/// pushReplacement para no acumular stack al saltar entre secciones.
class PatientTabBar extends StatelessWidget {
  final PatientTab current;
  const PatientTabBar({super.key, required this.current});

  static const _tabs = [
    _TabDef(PatientTab.home, 'Inicio', Icons.home_outlined),
    _TabDef(PatientTab.plan, 'Mi plan', Icons.medication_outlined),
    _TabDef(PatientTab.progreso, 'Progreso', Icons.show_chart),
    _TabDef(PatientTab.faq, 'Ayuda', Icons.help_outline),
    _TabDef(PatientTab.cuenta, 'Cuenta', Icons.person_outline),
  ];

  void _go(BuildContext context, PatientTab tab) {
    if (tab == current) return;
    late final Widget screen;
    switch (tab) {
      case PatientTab.home:
        screen = const HomeScreen();
      case PatientTab.plan:
        screen = const PlanScreen();
      case PatientTab.progreso:
        screen = const ProgresoScreen();
      case PatientTab.faq:
        screen = const FaqScreen();
      case PatientTab.cuenta:
        screen = const CuentaScreen();
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 9, 6, 24),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: GlucyTabColors.cardBorder))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final t in _tabs)
            InkWell(
              onTap: () => _go(context, t.tab),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t.icon, size: 21, color: t.tab == current ? GlucyTabColors.primary : GlucyTabColors.inactive),
                  const SizedBox(height: 4),
                  Text(t.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: t.tab == current ? GlucyTabColors.primary : GlucyTabColors.inactive)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
