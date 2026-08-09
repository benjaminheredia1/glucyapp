import 'package:flutter/material.dart';
import 'package:glucy_app/doctor/alertas_screen.dart';
import 'package:glucy_app/doctor/dash_screen.dart';
import 'package:glucy_app/doctor/doctor_data.dart';
import 'package:glucy_app/doctor/inbox_screen.dart';
import 'package:glucy_app/doctor/pacientes_screen.dart';
import 'package:glucy_app/doctor/perfil_doc_screen.dart';

enum DoctorTab { inbox, pacientes, alertas, dash, perfil }

class _TabDef {
  final DoctorTab tab;
  final String label;
  final IconData icon;
  const _TabDef(this.tab, this.label, this.icon);
}

/// Barra inferior compartida por las 5 pantallas principales del médico
/// (Bandeja, Pacientes, Alertas, Panel, Cuenta).
class DoctorTabBar extends StatelessWidget {
  final DoctorTab current;
  const DoctorTabBar({super.key, required this.current});

  static const _tabs = [
    _TabDef(DoctorTab.inbox, 'Bandeja', Icons.description_outlined),
    _TabDef(DoctorTab.pacientes, 'Pacientes', Icons.groups_outlined),
    _TabDef(DoctorTab.alertas, 'Alertas', Icons.error_outline),
    _TabDef(DoctorTab.dash, 'Panel', Icons.show_chart),
    _TabDef(DoctorTab.perfil, 'Cuenta', Icons.person_outline),
  ];

  void _go(BuildContext context, DoctorTab tab) {
    if (tab == current) return;
    late final Widget screen;
    switch (tab) {
      case DoctorTab.inbox:
        screen = const InboxScreen();
      case DoctorTab.pacientes:
        screen = const PacientesScreen();
      case DoctorTab.alertas:
        screen = const AlertasScreen();
      case DoctorTab.dash:
        screen = const DashScreen();
      case DoctorTab.perfil:
        screen = const PerfilDocScreen();
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 9, 6, 24),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: DoctorColors.cardBorder))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final t in _tabs)
            InkWell(
              onTap: () => _go(context, t.tab),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t.icon, size: 21, color: t.tab == current ? DoctorColors.primary : const Color(0x6610262A)),
                  const SizedBox(height: 4),
                  Text(t.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: t.tab == current ? DoctorColors.primary : const Color(0x6610262A))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
