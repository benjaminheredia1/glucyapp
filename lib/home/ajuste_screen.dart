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

/// Ajuste de dosis propuesto por la IA y ya validado por la médica,
/// dentro del rango de titulación autorizado.
class AjusteScreen extends StatelessWidget {
  const AjusteScreen({super.key});

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
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: GlucyColors.cardBorder)),
                      child: const Icon(Icons.arrow_back_ios_new, size: 13, color: GlucyColors.primary),
                    ),
                  ),
                  const Expanded(
                    child: Text('Nuevo ajuste',
                        textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(12)),
                child: const Text(
                  'Validado por Dra. Carla Núñez · hoy 11:40. Basado en tus 9 mediciones de los últimos 3 días.',
                  style: TextStyle(fontSize: 12, height: 1.5, color: GlucyColors.tealText),
                ),
              ),
              const SizedBox(height: 12),
              const Text('QUÉ CAMBIA', style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0x6B10262A), letterSpacing: 0.8)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: GlucyColors.bg, borderRadius: BorderRadius.circular(10)),
                            child: const Column(
                              children: [
                                Text('Antes', style: TextStyle(fontSize: 10.5, color: Color(0x8010262A))),
                                Text('20 U', style: TextStyle(fontFamily: 'Sora', fontSize: 18, fontWeight: FontWeight.w700, color: Color(0x8C10262A))),
                              ],
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Icon(Icons.arrow_forward, size: 18, color: GlucyColors.primary)),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(10)),
                            child: const Column(
                              children: [
                                Text('Ahora', style: TextStyle(fontSize: 10.5, color: GlucyColors.tealText)),
                                Text('22 U', style: TextStyle(fontFamily: 'Sora', fontSize: 18, fontWeight: FontWeight.w700, color: GlucyColors.primary)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('Insulina glargina (Lantus) · nocturna', style: TextStyle(fontSize: 11.5, color: Color(0x8C10262A))),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0x14052E33)),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Metformina 1.000 mg × 2', style: TextStyle(fontSize: 12.5, color: GlucyColors.ink)),
                        Text('Sin cambios', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0x8010262A))),
                      ],
                    ),
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
                    Text('Por qué', style: TextStyle(fontFamily: 'Sora', fontSize: 12.5, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                    SizedBox(height: 6),
                    Text(
                      'Tus 3 mediciones en ayunas del ciclo siguen por encima del objetivo (≤ 130 mg/dL) y el estudio de laboratorio lo confirma. El aumento es de 2 U, dentro del rango autorizado.',
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
                child: const Text('Entendido, aplicar', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
