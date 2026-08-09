import 'package:flutter/material.dart';
import 'package:glucy_app/home/alerta_screen.dart';
import 'package:glucy_app/home/ciclo_screen.dart';
import 'package:glucy_app/home/plan_screen.dart';
import 'package:glucy_app/onboarding/questions_components/diag_screen.dart';
import 'package:glucy_app/onboarding/questions_components/envio_screen.dart';
import 'package:glucy_app/onboarding/questions_components/estudios_screen.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const ink = Color(0xFF10262A);
  static const alert = Color(0xFFE8574B);
  static const alertBg = Color(0xFFFBE4E1);
  static const warn = Color(0xFFB97417);
  static const warnBg = Color(0xFFFBEEDA);
  static const tealBg = Color(0xFFDEF3EC);
}

class _Notif {
  final String group;
  final IconData icon;
  final Color tint;
  final Color fg;
  final String title;
  final String sub;
  final String time;
  final bool unread;
  final Widget Function() target;
  const _Notif(this.group, this.icon, this.tint, this.fg, this.title, this.sub, this.time, this.unread, this.target);
}

/// Bandeja de notificaciones del paciente, agrupadas por fecha.
class NotifsScreen extends StatefulWidget {
  const NotifsScreen({super.key});

  @override
  State<NotifsScreen> createState() => _NotifsScreenState();
}

class _NotifsScreenState extends State<NotifsScreen> {
  bool _allRead = false;

  static final _notifs = [
    _Notif('Hoy', Icons.error_outline, GlucyColors.alertBg, GlucyColors.alert, 'Glucosa fuera de rango',
        '268 mg/dL registrado a las 14:20. Revisa qué hacer.', '12 min', true, () => const AlertaScreen()),
    _Notif('Hoy', Icons.medication_outlined, GlucyColors.warnBg, GlucyColors.warn, 'Metformina de las 13:00',
        'Aún no marcaste esta toma como realizada.', '2 h', true, () => const PlanScreen()),
    _Notif('Hoy', Icons.local_shipping_outlined, GlucyColors.tealBg, GlucyColors.primary, 'Tu glucómetro salió del almacén',
        'Llega mañana 26 de julio.', '5 h', true, () => const EnvioScreen()),
    _Notif('Esta semana', Icons.check_circle_outline, GlucyColors.tealBg, GlucyColors.primary, 'Tu médica firmó el ajuste',
        'Insulina glargina 20 U → 22 U. Revisa tu plan.', 'ayer', false, () => const DiagScreen()),
    _Notif('Esta semana', Icons.error_outline, GlucyColors.alertBg, GlucyColors.alert, 'Estudio rechazado',
        'Transaminasas: falta la fecha en la hoja.', '2 días', false, () => const EstudiosScreen()),
    _Notif('Esta semana', Icons.science_outlined, GlucyColors.tealBg, GlucyColors.primary, 'Ciclo de 3 mediciones cerrado',
        'Toca subir un estudio de laboratorio.', '3 días', false, () => const CicloScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    final groups = ['Hoy', 'Esta semana'];
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0x14052E33))),
                      child: const Icon(Icons.arrow_back_ios_new, size: 13, color: GlucyColors.primary),
                    ),
                  ),
                  const Expanded(
                    child: Text('Notificaciones',
                        textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _allRead = true),
                    child: const Text('Marcar leídas', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: GlucyColors.primary)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                children: [
                  for (final g in groups) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 4),
                      child: Text(g.toUpperCase(),
                          style: const TextStyle(fontFamily: 'Sora', fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0x6B10262A), letterSpacing: 0.6)),
                    ),
                    for (final n in _notifs.where((n) => n.group == g)) ...[
                      InkWell(
                        borderRadius: BorderRadius.circular(13),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => n.target())),
                        child: Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: (n.unread && !_allRead) ? Colors.white : const Color(0xFFFAFDFC),
                            border: Border.all(color: (n.unread && !_allRead) ? const Color(0x380A7C86) : const Color(0x12052E33)),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(color: n.tint, borderRadius: BorderRadius.circular(11)),
                                child: Icon(n.icon, size: 17, color: n.fg),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text(n.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.ink))),
                                        Text(n.time, style: const TextStyle(fontSize: 10.5, color: Color(0x6610262A))),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(n.sub, style: const TextStyle(fontSize: 11.5, height: 1.45, color: Color(0x9910262A))),
                                  ],
                                ),
                              ),
                              if (n.unread && !_allRead) ...[
                                const SizedBox(width: 6),
                                Container(margin: const EdgeInsets.only(top: 5), width: 8, height: 8, decoration: const BoxDecoration(color: GlucyColors.primary, shape: BoxShape.circle)),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
