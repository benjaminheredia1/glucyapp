import 'package:flutter/material.dart';
import 'package:glucy_app/onboarding/questions_components/diag_pend_screen.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const accent = Color(0xFF2EE6A8);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const tealBg = Color(0xFFDEF3EC);
}

class _Beneficio {
  final String texto;
  const _Beneficio(this.texto);
}

class _Paso {
  final String numero;
  final String titulo;
  final String sub;
  const _Paso(this.numero, this.titulo, this.sub);
}

/// Prueba de 12 días y pago por QR: resume lo que incluye el plan, la
/// linea de tiempo de los proximos 13 dias y el metodo de pago (pantalla
/// 15 del catalogo). El cobro solo se activa el dia 13, y nunca si el
/// medico no aprueba el ingreso.
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  static const _beneficios = [
    _Beneficio('Un médico revisa, edita y firma tu plan'),
    _Beneficio('Ajuste de dosis cada ciclo de 3 mediciones'),
    _Beneficio('Revisión médica completa cada 15 días'),
    _Beneficio('2 consultas con tu médico cada mes'),
  ];

  static const _pasos = [
    _Paso('1', 'Hoy', 'Un médico recibe tu caso y firma tu plan'),
    _Paso('2', 'Días 3, 6 y 9', 'Registras tu glucosa con tu glucómetro'),
    _Paso('3', 'Día 12', 'Subes el control de laboratorio del ciclo'),
    _Paso('4', 'Día 13', 'Se activa el QR y el médico firma tu primer ajuste'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 20, 6),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: GlucyColors.deep),
                  ),
                  const Expanded(
                    child: Text('Iniciar mi tratamiento',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                  ),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: GlucyColors.accent, borderRadius: BorderRadius.circular(999)),
                                child: const Text('12 días gratis', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GlucyColors.deep)),
                              ),
                              const Text('sin tarjeta', style: TextStyle(fontSize: 11, color: Color(0x99F4FAF9))),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                    text: 'USD 0',
                                    style: TextStyle(fontFamily: 'Sora', fontSize: 27, fontWeight: FontWeight.w700, color: Colors.white)),
                                TextSpan(
                                    text: '  hoy · luego USD 25 al mes',
                                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xB8F4FAF9))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          for (final b in _beneficios) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.check, size: 16, color: GlucyColors.accent),
                                  const SizedBox(width: 9),
                                  Expanded(child: Text(b.texto, style: const TextStyle(fontSize: 12.5, height: 1.4, color: Colors.white))),
                                ],
                              ),
                            ),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tus próximos 13 días',
                              style: TextStyle(fontFamily: 'Sora', fontSize: 14.5, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                          const SizedBox(height: 12),
                          for (final p in _pasos) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(color: GlucyColors.tealBg, shape: BoxShape.circle),
                                  child: Text(p.numero,
                                      style: const TextStyle(fontFamily: 'Sora', fontSize: 11.5, fontWeight: FontWeight.w700, color: GlucyColors.primary)),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
                                      Text(p.sub, style: const TextStyle(fontSize: 11.5, height: 1.3, color: Color(0x8C10262A))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (p != _pasos.last) const SizedBox(height: 12),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text('Pago por QR',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontFamily: 'Sora', fontSize: 13.5, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: GlucyColors.bg, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(999)),
                                child: const Text('Bancos y billeteras', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Escaneas el código desde tu banco. No pedimos tarjeta ni datos financieros.',
                            style: TextStyle(fontSize: 12, height: 1.5, color: Color(0x9910262A)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline, size: 17, color: GlucyColors.primary),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Hoy no se cobra nada. Si el médico no aprueba tu ingreso, no hay cobro nunca.',
                              style: TextStyle(fontSize: 12, height: 1.5, color: GlucyColors.deep),
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
                      child: const Text('Empezar mis 12 días gratis', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'El QR aparece el día 13 y puedes cancelar antes desde la app',
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
}
