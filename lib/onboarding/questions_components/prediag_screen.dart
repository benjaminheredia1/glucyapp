import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:glucy_app/onboarding/questions_components/analisis_screen.dart';
import 'package:glucy_app/onboarding/questions_components/crear_cuenta_screen.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const warn = Color(0xFFB97417);
  static const warnBg = Color(0xFFFBEEDA);
}

class _Stat {
  final String value;
  final String label;
  final Color color;
  const _Stat(this.value, this.label, this.color);
}

class _PlanLine {
  final String text;
  final double blur;
  const _PlanLine(this.text, this.blur);
}

/// Pre-diagnóstico generado por IA: adelanta el diagnóstico y desenfoca
/// parte del plan para incentivar crear la cuenta y pagar.
class PrediagScreen extends StatelessWidget {
  const PrediagScreen({super.key});

  static const _stats = [
    _Stat('7.4 %', 'HbA1c', GlucyColors.warn),
    _Stat('158', 'Ayunas mg/dL', GlucyColors.warn),
    _Stat('<6.5 %', 'Meta 90 días', GlucyColors.primary),
  ];

  static const _plan = [
    _PlanLine('Metformina — ajuste de dosis según tu función renal', 0),
    _PlanLine('Insulina basal nocturna con rango de titulación', 3),
    _PlanLine('Meta de glucosa en ayunas personalizada', 3),
    _PlanLine('Estudio de control cada 3 mediciones', 3),
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
                child: Text('Tu pre-diagnóstico', style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(color: GlucyColors.warnBg, borderRadius: BorderRadius.circular(999)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 8, height: 8, child: DecoratedBox(decoration: BoxDecoration(color: GlucyColors.warn, shape: BoxShape.circle))),
                          SizedBox(width: 8),
                          Text('Análisis preliminar · sin validar aún', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: GlucyColors.warn)),
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
                          const Text('Diabetes tipo 2', style: TextStyle(fontFamily: 'Sora', fontSize: 18, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                          const SizedBox(height: 9),
                          const Text(
                            'De 2 años de evolución, con control glucémico subóptimo y sin complicaciones agudas. Riesgo cardiovascular a vigilar por LDL alto.',
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
                                        Text(s.value, style: TextStyle(fontFamily: 'Sora', fontSize: 17, fontWeight: FontWeight.w700, color: s.color)),
                                        Text(s.label, style: const TextStyle(fontSize: 10.5, color: Color(0x8C10262A))),
                                      ],
                                    ),
                                  ),
                                ),
                                if (s != _stats.last) const SizedBox(width: 9),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalisisScreen())),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: GlucyColors.ink,
                                side: const BorderSide(color: GlucyColors.cardBorder),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Ver el detalle de cada valor', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    const Text('LO QUE PROPONDRÍA TU PLAN',
                        style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0x6B10262A), letterSpacing: 0.8)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final p in _plan) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 6, right: 9),
                                  child: SizedBox(width: 5, height: 5, child: DecoratedBox(decoration: BoxDecoration(color: GlucyColors.primary, shape: BoxShape.circle))),
                                ),
                                Expanded(
                                  child: p.blur == 0
                                      ? Text(p.text, style: const TextStyle(fontSize: 12.5, height: 1.45, color: GlucyColors.ink))
                                      : ImageFiltered(
                                          imageFilter: ImageFilter.blur(sigmaX: p.blur, sigmaY: p.blur),
                                          child: Text(p.text, style: const TextStyle(fontSize: 12.5, height: 1.45, color: GlucyColors.ink)),
                                        ),
                                ),
                              ],
                            ),
                            if (p != _plan.last) const SizedBox(height: 9),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(color: GlucyColors.warnBg, borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 17, color: GlucyColors.warn),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Esto no es un diagnóstico. Un médico especialista debe revisarlo, editarlo y firmarlo antes de que puedas seguirlo.',
                              style: TextStyle(fontSize: 11.5, height: 1.5, color: Color(0xFF8A5510)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: GlucyColors.cardBorder))),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CrearCuentaScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlucyColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Iniciar mi tratamiento', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
