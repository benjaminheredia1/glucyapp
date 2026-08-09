import 'package:flutter/material.dart';
import 'package:glucy_app/onboarding/questions_components/diag_screen.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const tealBg = Color(0xFFDEF3EC);
  static const warn = Color(0xFFB97417);
  static const warnBg = Color(0xFFFBEEDA);
}

class _IngresoStep {
  final String icon;
  final String title;
  final String sub;
  final Color bg;
  final Color fg;
  const _IngresoStep({required this.icon, required this.title, required this.sub, required this.bg, required this.fg});
}

/// Estado del caso mientras el médico especialista valida y firma el
/// plan generado por la IA (habitualmente menos de 12 horas).
class DiagPendScreen extends StatelessWidget {
  const DiagPendScreen({super.key});

  static const _steps = [
    _IngresoStep(icon: '✓', title: 'Filtro 1 y filtro 2', sub: 'Aprobados · semáforo verde', bg: GlucyColors.tealBg, fg: GlucyColors.primary),
    _IngresoStep(icon: '✓', title: 'Pre-diagnóstico generado', sub: 'Listo para el especialista', bg: GlucyColors.tealBg, fg: GlucyColors.primary),
    _IngresoStep(icon: '3', title: 'Validación y firma médica', sub: 'En curso · menos de 12 h', bg: GlucyColors.warnBg, fg: GlucyColors.warn),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tu plan', style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
              const SizedBox(height: 13),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(color: GlucyColors.warnBg, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                      child: const Text('En revisión médica', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: GlucyColors.warn)),
                    ),
                    const SizedBox(height: 8),
                    const Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF8A5510)),
                        children: [
                          TextSpan(text: 'Tu caso está con el especialista. Tiempo habitual de respuesta: '),
                          TextSpan(text: 'menos de 12 horas', style: TextStyle(fontWeight: FontWeight.w700)),
                          TextSpan(text: '.'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(21)),
                      child: const Text('CN', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w700, color: GlucyColors.primary)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dra. Carla Núñez', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
                          Text('Endocrinología · Mat. 45281', style: TextStyle(fontSize: 11.5, color: Color(0x8C10262A))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(999)),
                      child: const Text('Asignada', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GlucyColors.primary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13),
              const Text('ESTADO DE TU INGRESO',
                  style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0x6B10262A), letterSpacing: 0.8)),
              const SizedBox(height: 8),
              for (final s in _steps) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: s.bg, shape: BoxShape.circle),
                        child: Text(s.icon, style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w700, color: s.fg)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
                            Text(s.sub, style: const TextStyle(fontSize: 11.5, color: Color(0x8C10262A))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DiagScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlucyColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ver diagnóstico validado', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
