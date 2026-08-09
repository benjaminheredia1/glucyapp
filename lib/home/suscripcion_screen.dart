import 'package:flutter/material.dart';
import 'package:glucy_app/home/recibo_screen.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const accent = Color(0xFF2EE6A8);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const alert = Color(0xFFE8574B);
}

class _Plan {
  final String name;
  final String price;
  final String per;
  final String desc;
  final String badge;
  const _Plan(this.name, this.price, this.per, this.desc, this.badge);
}

/// Estado de la suscripción (prueba gratuita) y planes disponibles.
class SuscripcionScreen extends StatelessWidget {
  const SuscripcionScreen({super.key});

  static const _plans = [
    _Plan('Mensual', '25 USD', '/ mes', 'Seguimiento con IA y validación médica cada 15 días · pago por QR', ''),
    _Plan('Anual', '250 USD', '/ año', 'Ahorras 2 meses · prioridad en la validación médica · pago por QR', 'más elegido'),
  ];

  void _cancelar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cancelación de suscripción — pendiente.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
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
                    child: Text('Mi suscripción',
                        textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(color: GlucyColors.deep, borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: GlucyColors.accent, borderRadius: BorderRadius.circular(999)),
                                child: const Text('Prueba gratuita', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GlucyColors.deep)),
                              ),
                              const Text('11 días restantes', style: TextStyle(fontSize: 11.5, color: Color(0xA6F4FAF9))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('Seguimiento médico', style: TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 4),
                          const Text('25 USD / mes · pago por QR · primer cobro el día 13', style: TextStyle(fontSize: 12.5, color: Color(0x9EF4FAF9))),
                          const SizedBox(height: 8),
                          const Divider(height: 1, color: Color(0x1FF4FAF9)),
                          const SizedBox(height: 8),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Validación médica', style: TextStyle(fontSize: 12.5, color: Color(0xCCF4FAF9))),
                              Text('cada 15 días', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: GlucyColors.accent)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('PLANES DISPONIBLES', style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0x6B10262A), letterSpacing: 0.8)),
                    const SizedBox(height: 8),
                    for (final p in _plans) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: p.badge.isEmpty ? Colors.white : const Color(0xFFDEF3EC),
                          border: Border.all(color: p.badge.isEmpty ? GlucyColors.cardBorder : GlucyColors.primary, width: 1.5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(p.name, style: const TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                                if (p.badge.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(color: GlucyColors.accent, borderRadius: BorderRadius.circular(999)),
                                    child: Text(p.badge, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: GlucyColors.deep)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(p.price, style: const TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w700, color: GlucyColors.primary)),
                                const SizedBox(width: 6),
                                Text(p.per, style: const TextStyle(fontSize: 11.5, color: Color(0x8010262A))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(p.desc, style: const TextStyle(fontSize: 12, height: 1.45, color: Color(0x9910262A))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReciboScreen())),
                      style: OutlinedButton.styleFrom(foregroundColor: GlucyColors.primary, side: const BorderSide(color: Color(0x4D0A7C86)), padding: const EdgeInsets.symmetric(vertical: 13)),
                      child: const Text('Ver último comprobante', style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => _cancelar(context),
                      style: OutlinedButton.styleFrom(foregroundColor: GlucyColors.alert, side: const BorderSide(color: Color(0x59E8574B)), padding: const EdgeInsets.symmetric(vertical: 13)),
                      child: const Text('Cancelar suscripción', style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700)),
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
}
