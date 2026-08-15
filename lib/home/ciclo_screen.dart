import 'package:flutter/material.dart';
import 'package:glucy_app/home/ajuste_screen.dart';
import 'package:glucy_app/onboarding/questions_components/estudios_screen.dart' show EstudiosScreen;
import 'package:glucy_app/onboarding/questions_components/subir_estudio_screen.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const tealBg = Color(0xFFDEF3EC);
  static const tealText = Color(0xFF0A5A62);
  static const warnBg = Color(0xFFFBEEDA);
  static const warn = Color(0xFFB97417);
}

class _Reading {
  final String day;
  final String time;
  final String moment;
  final int value;
  final Color color;
  const _Reading(this.day, this.time, this.moment, this.value, this.color);
}

const _glucemiaEnAyunas = StudyItem(
  n: 1,
  name: 'Glucemia en ayunas',
  subtitle: 'Nivel de glucosa en sangre tras 8 horas sin comer',
  banner: 'Es la base para medir tu control glucémico actual.',
  status: StudyStatus.pending,
);

/// Resumen de las 3 mediciones del ciclo actual y el estudio de
/// laboratorio requerido para validar el próximo ajuste.
class CicloScreen extends StatelessWidget {
  const CicloScreen({super.key});

  static const _readings = [
    _Reading('Lunes', '08:10', 'en ayunas', 141, Color(0xFFE8A33D)),
    _Reading('Jueves', '08:05', 'en ayunas', 132, Color(0xFFE8A33D)),
    _Reading('Domingo', '08:10', 'en ayunas', 108, GlucyColors.primary),
  ];

  Future<void> _subirEstudio(BuildContext context) async {
    final detail = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const SubirEstudioScreen(study: _glucemiaEnAyunas)),
    );
    if (detail != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estudio subido.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: GlucyColors.cardBorder)),
                      child: const Icon(Icons.arrow_back_ios_new, size: 13, color: GlucyColors.primary),
                    ),
                  ),
                  const Expanded(
                    child: Text('Ciclo completo',
                        textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(14)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('3 de 3 mediciones registradas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.deep)),
                        Text('ciclo #4', style: TextStyle(fontSize: 11.5, color: GlucyColors.tealText)),
                      ],
                    ),
                    Text('✓', style: TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w700, color: GlucyColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Para ajustar la dosis con seguridad necesitamos un valor de laboratorio, no solo el del glucómetro.',
                style: TextStyle(fontSize: 12.5, height: 1.5, color: Color(0x9910262A)),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    for (final r in _readings) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.day, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: GlucyColors.ink)),
                                Text('${r.time} · ${r.moment}', style: const TextStyle(fontSize: 11, color: Color(0x8010262A))),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700, color: r.color),
                              children: [
                                TextSpan(text: '${r.value} '),
                                const TextSpan(text: 'mg/dL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: Color(0x7310262A))),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (r != _readings.last) const Divider(height: 22, color: Color(0x0D052E33)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('ESTUDIO REQUERIDO DEL CICLO',
                  style: TextStyle(fontFamily: 'Sora', fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0x6B10262A), letterSpacing: 0.7)),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _subirEstudio(context),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0x66E8A33D)), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: GlucyColors.warnBg, borderRadius: BorderRadius.circular(9)),
                        child: const Icon(Icons.science_outlined, size: 18, color: GlucyColors.warn),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Glucemia en ayunas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
                            Text('Pendiente de subir', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GlucyColors.warn)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18, color: Color(0x4D10262A)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EstudiosScreen())),
                child: const Align(alignment: Alignment.centerLeft, child: Text('Ver todos mis estudios', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: GlucyColors.primary))),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AjusteScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlucyColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Ver ajuste propuesto', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
