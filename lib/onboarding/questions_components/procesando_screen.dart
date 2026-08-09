import 'package:flutter/material.dart';
import 'package:glucy_app/onboarding/questions_components/elegibilidad_screen.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const accent = Color(0xFF2EE6A8);
}

class _ProcStep {
  final String icon;
  final String title;
  final String sub;
  final Color bg;
  final Color fg;
  const _ProcStep({required this.icon, required this.title, required this.sub, required this.bg, required this.fg});
}

/// Pantalla de espera mientras la IA clasifica el caso (semáforo clínico)
/// a partir de los estudios subidos.
class ProcesandoScreen extends StatelessWidget {
  const ProcesandoScreen({super.key});

  static const _steps = [
    _ProcStep(icon: '✓', title: 'Extracción de valores', sub: '7 estudios leídos y normalizados', bg: GlucyColors.accent, fg: GlucyColors.deep),
    _ProcStep(icon: '✓', title: 'Criterios de exclusión', sub: 'TFG, cetonas, transaminasas', bg: GlucyColors.accent, fg: GlucyColors.deep),
    _ProcStep(icon: '3', title: 'Clasificación del semáforo', sub: 'En curso…', bg: Color(0x2EF4FAF9), fg: Color(0xFFF4FAF9)),
    _ProcStep(icon: '4', title: 'Asignación de especialista', sub: 'Pendiente', bg: Color(0x1AF4FAF9), fg: Color(0x80F4FAF9)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.deep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ANÁLISIS CLÍNICO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0x8CF4FAF9), letterSpacing: 1.2)),
              const SizedBox(height: 10),
              const Text('Clasificando tu caso',
                  style: TextStyle(fontFamily: 'Sora', fontSize: 24, fontWeight: FontWeight.w700, height: 1.25, color: Color(0xFFF4FAF9))),
              const SizedBox(height: 8),
              const Text(
                'Leemos tus 7 estudios, los cruzamos con tu cuestionario y determinamos si tu perfil es apto para el programa.',
                style: TextStyle(fontSize: 13, height: 1.55, color: Color(0xAEF4FAF9)),
              ),
              const SizedBox(height: 18),
              for (final s in _steps) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(color: const Color(0x0FF4FAF9), borderRadius: BorderRadius.circular(12)),
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
                            const SizedBox(height: 0),
                            Text(s.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFF4FAF9))),
                            Text(s.sub, style: const TextStyle(fontSize: 11.5, color: Color(0x80F4FAF9))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: const LinearProgressIndicator(
                  value: 0.76,
                  minHeight: 6,
                  backgroundColor: Color(0x1FF4FAF9),
                  valueColor: AlwaysStoppedAnimation(GlucyColors.accent),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ElegibilidadScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlucyColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ver mi elegibilidad', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
