import 'package:flutter/material.dart';
import 'package:glucy_app/onboarding/questions_components/envio_screen.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const tealBg = Color(0xFFDEF3EC);
  static const tealText = Color(0xFF0A5A62);
  static const warn = Color(0xFFB97417);
  static const warnBg = Color(0xFFFBEEDA);
}

class _Stat {
  final String value;
  final String label;
  final Color color;
  const _Stat(this.value, this.label, this.color);
}

/// Diagnóstico final validado y firmado por el médico especialista.
class DiagScreen extends StatelessWidget {
  const DiagScreen({super.key});

  static const _stats = [
    _Stat('158', 'Ayunas mg/dL', GlucyColors.warn),
    _Stat('7.4 %', 'HbA1c', GlucyColors.warn),
    _Stat('<6.5 %', 'Meta 90 días', GlucyColors.primary),
  ];

  static const _treatment = [
    'Metformina 1.000 mg, 2 veces al día con alimentos',
    'Insulina glargina (Lantus) 20 U a las 22:00 · rango autorizado 18–26 U',
    'Una medición de glucosa al día, registrando el momento',
    'Estudio de laboratorio cada 3 mediciones',
    'Revisión médica completa cada 15 días',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Tu diagnóstico', style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.check, size: 18, color: GlucyColors.primary),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Validado y firmado · hoy 14:05', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                                Text('Dra. Carla Núñez · Endocrinología · Mat. 45281', style: TextStyle(fontSize: 11.5, color: GlucyColors.tealText)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              _pill('Riesgo moderado', GlucyColors.warnBg, GlucyColors.warn),
                              _pill('CIE-10 E11.9', GlucyColors.bg, const Color(0x9910262A), bordered: true),
                            ],
                          ),
                          const SizedBox(height: 9),
                          const Text('Diabetes tipo 2', style: TextStyle(fontFamily: 'Sora', fontSize: 18, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                          const SizedBox(height: 8),
                          const Text(
                            'Con control glucémico subóptimo y sin complicaciones agudas evidentes. Riesgo cardiovascular a vigilar por LDL alto.',
                            style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xB310262A)),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              for (final s in _stats) ...[
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                    decoration: BoxDecoration(color: GlucyColors.bg, borderRadius: BorderRadius.circular(10)),
                                    child: Column(
                                      children: [
                                        Text(s.value, style: TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w700, color: s.color)),
                                        Text(s.label, style: const TextStyle(fontSize: 10.5, color: Color(0x8C10262A))),
                                      ],
                                    ),
                                  ),
                                ),
                                if (s != _stats.last) const SizedBox(width: 9),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Plan de tratamiento', style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                          const SizedBox(height: 9),
                          for (final t in _treatment) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 6, right: 9),
                                  child: SizedBox(width: 5, height: 5, child: DecoratedBox(decoration: BoxDecoration(color: GlucyColors.primary, shape: BoxShape.circle))),
                                ),
                                Expanded(child: Text(t, style: const TextStyle(fontSize: 12.5, height: 1.45, color: GlucyColors.ink))),
                              ],
                            ),
                            if (t != _treatment.last) const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EnvioScreen())),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: GlucyColors.primary,
                          side: const BorderSide(color: Color(0x4D0A7C86)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Ir a mi seguimiento', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color bg, Color fg, {bool bordered = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: bordered ? Border.all(color: GlucyColors.cardBorder) : null,
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}
