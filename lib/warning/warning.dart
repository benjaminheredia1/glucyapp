import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Colores del diseño Glucy AI
class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const alert = Color(0xFFE8574B);
  static const alertStepBg = Color(0xFFFBE4E1);
}

class UrgencyStep {
  final int n;
  final String text;
  const UrgencyStep({required this.n, required this.text});
}

class UrgencyScreen extends StatelessWidget {
  /// Número al que se llama al tocar "Llamar a emergencias".
  /// Cambialo por el número de emergencias de tu país/región.
  final String emergencyPhoneNumber;

  const UrgencyScreen({super.key, this.emergencyPhoneNumber = '911'});

  static const List<UrgencyStep> _steps = [
    UrgencyStep(n: 1, text: 'Acude al servicio de urgencias más cercano o llama a emergencias.'),
    UrgencyStep(n: 2, text: 'Lleva tu medicación actual y este resumen.'),
    UrgencyStep(n: 3, text: 'No tomes decisiones de dosis por tu cuenta.'),
  ];

  Future<void> _llamarEmergencias() async {
    final uri = Uri(scheme: 'tel', path: emergencyPhoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Qué hacer ahora',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: GlucyColors.deep,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final step in _steps) ...[
                      _stepCard(step),
                      const SizedBox(height: 10),
                    ],
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _llamarEmergencias,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GlucyColors.alert,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Llamar a emergencias',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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

  // ---------- Banner rojo superior ----------
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
      color: GlucyColors.alert,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ATENCIÓN INMEDIATA AHORA',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xD9FFFFFF), // rgba(255,255,255,0.85)
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Acude a emergencias',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Los síntomas que describes pueden indicar una descompensación '
            'grave (cetoacidosis). Esto no se resuelve por una app.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xE6FFFFFF), // rgba(255,255,255,0.9)
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Tarjeta de cada paso numerado ----------
  Widget _stepCard(UrgencyStep step) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: GlucyColors.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: GlucyColors.alertStepBg,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${step.n}',
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: GlucyColors.alert,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              step.text,
              style: const TextStyle(fontSize: 13, height: 1.45, color: GlucyColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}