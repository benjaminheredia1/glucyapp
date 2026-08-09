import 'package:flutter/material.dart';
import 'package:glucy_app/home/plan_screen.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const tealBg = Color(0xFFDEF3EC);
  static const tealText = Color(0xFF0A5A62);
}

class _Row {
  final String label;
  final String value;
  final Color color;
  const _Row(this.label, this.value, this.color);
}

/// Revalidación médica cada 15 días: qué cambió y el comentario de la
/// médica sobre el ciclo revisado.
class RevisionScreen extends StatelessWidget {
  const RevisionScreen({super.key});

  static const _rows = [
    _Row('Diagnóstico', 'Sin cambios · DM2', Color(0x8010262A)),
    _Row('Metformina 1.000 mg × 2', 'Igual', Color(0x8010262A)),
    _Row('Insulina basal', '20 U → 22 U', GlucyColors.primary),
  ];

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
                    child: Text('Revisión de 15 días',
                        textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 18, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(14)),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Revalidado por Dra. Carla Núñez', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.deep)),
                    Text('hoy 12:20 · ciclos 1 al 5 · 5 mediciones y 2 estudios revisados', style: TextStyle(fontSize: 11.5, color: GlucyColors.tealText)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('QUÉ SE REVISÓ', style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0x6B10262A), letterSpacing: 0.8)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    for (final r in _rows) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r.label, style: const TextStyle(fontSize: 12.5, color: GlucyColors.ink)),
                          Text(r.value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: r.color)),
                        ],
                      ),
                      if (r != _rows.last) const Divider(height: 22, color: Color(0x0D052E33)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Comentario de tu médica', style: TextStyle(fontFamily: 'Sora', fontSize: 12.5, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                    SizedBox(height: 6),
                    Text(
                      '«Buena respuesta al esquema. Subimos la basal 2 U por los valores de ayunas todavía sobre meta. Mantén el registro diario.»',
                      style: TextStyle(fontSize: 12.5, height: 1.55, color: Color(0xB310262A)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlanScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlucyColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Ver mi plan actualizado', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
