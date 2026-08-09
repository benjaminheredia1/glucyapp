import 'package:flutter/material.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const tealBg = Color(0xFFDEF3EC);
}

class _Row {
  final String label;
  final String value;
  final Color color;
  const _Row(this.label, this.value, this.color);
}

/// Comprobante del último cobro por QR.
class ReciboScreen extends StatelessWidget {
  const ReciboScreen({super.key});

  static const _rows = [
    _Row('Concepto', 'Plan mensual · seguimiento médico', GlucyColors.ink),
    _Row('Período', '6 ago – 5 sep 2026', GlucyColors.ink),
    _Row('Método', 'QR · BCP ···4821', GlucyColors.ink),
    _Row('N.º de operación', 'GLC-2026-08-0417', GlucyColors.ink),
    _Row('Clínica', 'Clínica San Rafael', GlucyColors.ink),
    _Row('Total pagado', '25.00 USD', GlucyColors.primary),
  ];

  void _pendiente(BuildContext context, String que) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$que — pendiente.')));
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
                    child: Text('Comprobante',
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
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(color: GlucyColors.tealBg, shape: BoxShape.circle),
                            child: const Icon(Icons.check, size: 26, color: GlucyColors.primary),
                          ),
                          const SizedBox(height: 10),
                          const Text('25.00 USD', style: TextStyle(fontFamily: 'Sora', fontSize: 26, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                            decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(999)),
                            child: const Text('Pago confirmado por QR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GlucyColors.primary)),
                          ),
                          const SizedBox(height: 8),
                          const Text('6 de agosto de 2026 · 09:14', style: TextStyle(fontSize: 11.5, color: Color(0x8010262A))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        children: [
                          for (final r in _rows) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(r.label, style: const TextStyle(fontSize: 12, color: Color(0x8C10262A))),
                                Text(r.value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: r.color)),
                              ],
                            ),
                            if (r != _rows.last) const Divider(height: 22, color: Color(0x0D052E33)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Qué cubre este cobro', style: TextStyle(fontFamily: 'Sora', fontSize: 12.5, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                          SizedBox(height: 6),
                          Text('Seguimiento con IA, validación médica cada 15 días y consultas incluidas del período 6 ago – 5 sep 2026.',
                              style: TextStyle(fontSize: 12, height: 1.5, color: Color(0x9E10262A))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pendiente(context, 'Descargar PDF'),
                            style: OutlinedButton.styleFrom(foregroundColor: GlucyColors.primary, side: const BorderSide(color: Color(0x4D0A7C86)), padding: const EdgeInsets.symmetric(vertical: 13)),
                            child: const Text('Descargar PDF', style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pendiente(context, 'Enviar por correo'),
                            style: OutlinedButton.styleFrom(foregroundColor: GlucyColors.primary, side: const BorderSide(color: Color(0x4D0A7C86)), padding: const EdgeInsets.symmetric(vertical: 13)),
                            child: const Text('Enviar por correo', style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
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
