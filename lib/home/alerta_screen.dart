import 'package:flutter/material.dart';
import 'package:glucy_app/home/registrar_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const alert = Color(0xFFE8574B);
  static const alertBg = Color(0xFFFBE4E1);
  static const tealBg = Color(0xFFDEF3EC);
  static const tealText = Color(0xFF0A5A62);
}

/// Pantalla de alerta cuando una medición de glucosa sale muy fuera de
/// rango (valor crítico), con pasos inmediatos y aviso a la médica.
class AlertaScreen extends StatelessWidget {
  const AlertaScreen({super.key});

  static const _steps = [
    'Bebe agua y no hagas ejercicio intenso.',
    'Vuelve a medir en 2 horas.',
    'Si aparecen vómitos, confusión o dificultad para respirar, acude a urgencias.',
  ];

  Future<void> _llamarEmergencias() async {
    final uri = Uri(scheme: 'tel', path: '911');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
              color: GlucyColors.alert,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('VALOR CRÍTICO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xD9FFFFFF), letterSpacing: 1.1)),
                      Text('hoy 21:14', style: TextStyle(fontSize: 11, color: Color(0xCCFFFFFF))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text.rich(
                    TextSpan(style: TextStyle(fontFamily: 'Sora', fontSize: 40, fontWeight: FontWeight.w700, color: Colors.white), children: [
                      TextSpan(text: '268 '),
                      TextSpan(text: 'mg/dL', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xCCFFFFFF))),
                    ]),
                  ),
                  const Text('Muy por encima de tu rango objetivo', style: TextStyle(fontSize: 13, color: Color(0xE6FFFFFF))),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Qué hacer ahora', style: TextStyle(fontFamily: 'Sora', fontSize: 13.5, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                    const SizedBox(height: 12),
                    for (var i = 0; i < _steps.length; i++) ...[
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(color: GlucyColors.alertBg, shape: BoxShape.circle),
                              child: Text('${i + 1}', style: const TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w700, color: GlucyColors.alert)),
                            ),
                            const SizedBox(width: 11),
                            Expanded(child: Text(_steps[i], style: const TextStyle(fontSize: 13, height: 1.45, color: GlucyColors.ink))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tu médica ya fue notificada', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: GlucyColors.deep)),
                              Text('Dra. Carla Núñez · 21:14', style: TextStyle(fontSize: 11, color: GlucyColors.tealText)),
                            ],
                          ),
                          Text('Enviado', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GlucyColors.tealText)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: _llamarEmergencias,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlucyColors.alert,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Llamar a emergencias', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegistrarScreen())),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: GlucyColors.ink,
                        side: const BorderSide(color: Color(0x26052E33)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Volver a medir en 2 horas', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w700)),
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
