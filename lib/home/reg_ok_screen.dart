import 'package:flutter/material.dart';
import 'package:glucy_app/home/ciclo_screen.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const tealBg = Color(0xFFDEF3EC);
  static const tealText = Color(0xFF0A5A62);
}

/// Confirmación tras registrar una medición de glucosa: cierra el ciclo
/// de 3 mediciones y adelanta la tendencia.
class RegOkScreen extends StatelessWidget {
  final String glucoseEntry;
  final String momento;
  final DateTime medidoEn;
  const RegOkScreen({super.key, required this.glucoseEntry, required this.momento, required this.medidoEn});

  String get _hora {
    final local = medidoEn.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
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
              Column(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: GlucyColors.tealBg, shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 28, color: GlucyColors.primary),
                  ),
                  const SizedBox(height: 10),
                  const Text('Medición guardada', style: TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                  const SizedBox(height: 4),
                  Text('$glucoseEntry mg/dL · ${momento.toLowerCase()} · hoy $_hora', style: const TextStyle(fontSize: 12.5, color: Color(0x8C10262A))),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ciclo de 3 mediciones', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
                        Text('3 de 3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GlucyColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: List.generate(
                        3,
                        (i) => Expanded(
                          child: Container(
                            height: 8,
                            margin: EdgeInsets.only(right: i == 2 ? 0 : 6),
                            decoration: BoxDecoration(color: GlucyColors.primary, borderRadius: BorderRadius.circular(99)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'Ciclo completo: ahora toca confirmar con un estudio de laboratorio para que el ajuste de dosis sea seguro.',
                      style: TextStyle(fontSize: 11.5, height: 1.5, color: Color(0x8C10262A)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(14)),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.trending_down, size: 19, color: GlucyColors.primary),
                    SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tu promedio bajó 11 mg/dL en el ciclo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.deep)),
                          SizedBox(height: 2),
                          Text('Tu médica verá esta tendencia junto con el estudio al validar el próximo ajuste.',
                              style: TextStyle(fontSize: 11.5, height: 1.5, color: GlucyColors.tealText)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CicloScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlucyColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Ver el ciclo completo', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                style: OutlinedButton.styleFrom(
                  foregroundColor: GlucyColors.ink,
                  side: const BorderSide(color: Color(0x26052E33)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Volver al inicio', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
