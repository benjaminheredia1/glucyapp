import 'package:flutter/material.dart';
import 'package:glucy_app/onboarding/questions_components/estudios_screen.dart';

/// Colores del diseño Glucy AI
class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const mutedLabel = Color(0x8A10262A); // rgba(16,38,42,0.55)
  static const resultBg = Color(0xFFDEF3EC);
  static const resultText = Color(0xFF0A5A62);
  static const stageDoneBg = Color(0xFFDEF3EC);
  static const stagePendingBg = Color(0xFFE1EDEA);
  static const stagePendingFg = Color(0x7310262A); // rgba(16,38,42,0.45)
}

class _StageStep {
  final String icon;
  final String title;
  final String sub;
  final Color bg;
  final Color fg;
  const _StageStep({required this.icon, required this.title, required this.sub, required this.bg, required this.fg});
}

/// Pantalla mostrada cuando el paciente pasa el filtro clínico sin
/// respuestas de alarma: confirma elegibilidad y ubica el siguiente paso
/// (subir los estudios de laboratorio).
class Filtro1Screen extends StatelessWidget {
  const Filtro1Screen({super.key});

  static const List<_StageStep> _stages = [
    _StageStep(
      icon: '✓',
      title: 'Filtro clínico',
      sub: 'Sin respuestas de alarma',
      bg: GlucyColors.stageDoneBg,
      fg: GlucyColors.primary,
    ),
    _StageStep(
      icon: '2',
      title: 'Estudios de laboratorio',
      sub: '4 estudios por subir o agendar',
      bg: GlucyColors.primary,
      fg: Colors.white,
    ),
    _StageStep(
      icon: '3',
      title: 'Análisis de la IA',
      sub: 'Revisa criterios de elegibilidad',
      bg: GlucyColors.stagePendingBg,
      fg: GlucyColors.stagePendingFg,
    ),
    _StageStep(
      icon: '4',
      title: 'Validación médica',
      sub: 'Un especialista firma tu plan',
      bg: GlucyColors.stagePendingBg,
      fg: GlucyColors.stagePendingFg,
    ),
  ];

  void _verEstudios(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EstudiosScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        // Scrollea en pantallas cortas sin perder el Spacer que pega el boton
        // al fondo cuando sobra alto: la caja minima mide lo que el viewport.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resultado del filtro 1',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: GlucyColors.deep,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: GlucyColors.resultBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.check, size: 22, color: GlucyColors.primary),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Eres candidata a Glucy AI',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: GlucyColors.deep,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Ninguna respuesta de alarma. Pasas al filtro 2: los estudios que confirman el '
                              'diagnóstico y descartan contraindicaciones.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, height: 1.5, color: GlucyColors.resultText),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'DÓNDE ESTÁS',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0x6B10262A),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final stage in _stages) ...[
                        _stageCard(stage),
                        const SizedBox(height: 10),
                      ],
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _verEstudios(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GlucyColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Ver estudios requeridos',
                            style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stageCard(_StageStep stage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: GlucyColors.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: stage.bg, shape: BoxShape.circle),
            child: Text(
              stage.icon,
              style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w700, color: stage.fg),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stage.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
                Text(stage.sub, style: const TextStyle(fontSize: 11.5, color: GlucyColors.mutedLabel)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
