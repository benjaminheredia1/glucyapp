import 'package:flutter/material.dart';
import 'package:glucy_app/onboarding/questions_components/diag_pend_screen.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const accent = Color(0xFF2EE6A8);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
}

/// Patrón 9×9 decorativo con los tres "ojos" de posición de un QR real,
/// solo para ilustrar el pago por QR (no es un código escaneable).
const List<String> _qrRows = [
  '111011101',
  '101010101',
  '111010111',
  '000010000',
  '110111011',
  '000010000',
  '111010111',
  '101011101',
  '111010111',
];

/// Paso final del embudo gratuito: resume lo incluido en los 12 días de
/// prueba y muestra el QR de pago (no se cobra nada hasta el día 13).
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  static const _includes = [
    'Día 2: recibes tu glucómetro y aprendes a usarlo',
    'Días 3, 6 y 9: registras tu glucosa; la IA te acompaña',
    'Día 12: subes un estudio de laboratorio',
    'Día 13: pagas y un médico revisa y firma el ajuste · luego revalida cada 15 días',
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
              child: Column(
                children: [
                  Text('Iniciar mi tratamiento', style: TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                  SizedBox(height: 2),
                  Text('paso 4 de 4', style: TextStyle(fontSize: 11, color: Color(0x7310262A))),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: GlucyColors.deep, borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: GlucyColors.accent, borderRadius: BorderRadius.circular(999)),
                            child: const Text('12 días de prueba', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GlucyColors.deep)),
                          ),
                          const SizedBox(height: 8),
                          const Text('0 USD hoy', style: TextStyle(fontFamily: 'Sora', fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 6),
                          const Text(
                            'Hoy la IA analizó tus estudios y un médico está a la espera para validar tu tratamiento.',
                            style: TextStyle(fontSize: 12.5, height: 1.5, color: Color(0xB8F4FAF9)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          for (final text in _includes) ...[
                            Row(
                              children: [
                                const Icon(Icons.check, size: 16, color: GlucyColors.primary),
                                const SizedBox(width: 10),
                                Expanded(child: Text(text, style: const TextStyle(fontSize: 12.5, height: 1.4, color: GlucyColors.ink))),
                              ],
                            ),
                            if (text != _includes.last) const Divider(height: 22, color: Color(0x0D052E33)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Método de pago', style: TextStyle(fontFamily: 'Sora', fontSize: 12.5, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: GlucyColors.bg, border: Border.all(color: const Color(0x400A7C86)), borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              children: [
                                _qrGrid(),
                                const SizedBox(height: 10),
                                const Text('Pago por QR', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: GlucyColors.deep)),
                                const SizedBox(height: 4),
                                const Text(
                                  'Escaneas el código con tu banco o billetera. Hoy no se cobra nada: el QR se activa el día 13.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 11, height: 1.5, color: Color(0x9910262A)),
                                ),
                              ],
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
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DiagPendScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlucyColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Empezar mis 12 días de prueba', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No se cobra nada hoy. El pago por QR se solicita el día 13, cuando un médico revisa tu ciclo y ajusta tu tratamiento.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, height: 1.5, color: Color(0x8010262A)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qrGrid() {
    return SizedBox(
      width: 106,
      height: 106,
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: GridView.count(
            crossAxisCount: 9,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final row in _qrRows)
                for (final bit in row.split(''))
                  ColoredBox(color: bit == '1' ? GlucyColors.deep : Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
