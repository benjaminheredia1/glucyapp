import 'package:flutter/material.dart';
import 'package:glucy_app/doctor/doctor_login_screen.dart';
import 'package:glucy_app/onboarding/questions_components/checkout_screen.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const accent = Color(0xFF2EE6A8);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const tealBg = Color(0xFFDEF3EC);
  static const tealText = Color(0xFF0A5A62);
}

/// Pantalla de creación de cuenta al final del embudo gratuito, antes del
/// checkout. Los botones de Google/Apple son simulados (sin backend de
/// autenticación todavía).
class CrearCuentaScreen extends StatelessWidget {
  const CrearCuentaScreen({super.key});

  void _continuar(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CheckoutScreen()));
  }

  void _portalMedico(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DoctorLoginScreen()));
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
              padding: const EdgeInsets.fromLTRB(26, 20, 26, 34),
              decoration: const BoxDecoration(color: GlucyColors.deep),
              child: Column(
                children: [
                  const Icon(Icons.water_drop, size: 40, color: GlucyColors.accent),
                  const SizedBox(height: 8),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontFamily: 'Sora', fontSize: 22),
                      children: [
                        TextSpan(text: 'Glucy ', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                        TextSpan(text: 'AI', style: TextStyle(fontWeight: FontWeight.w300, color: GlucyColors.accent)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -18),
                child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                decoration: const BoxDecoration(color: GlucyColors.bg, borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22))),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(999)),
                        child: const Text('Tu pre-diagnóstico está listo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GlucyColors.primary)),
                      ),
                      const SizedBox(height: 13),
                      const Text('Crea tu cuenta para continuar',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, height: 1.3, color: GlucyColors.deep)),
                      const SizedBox(height: 8),
                      const Text(
                        'Guardamos tu caso en una historia clínica a tu nombre para que el médico pueda validar y firmar tu tratamiento.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, height: 1.55, color: Color(0xA610262A)),
                      ),
                      const SizedBox(height: 18),
                      _authButton(context, 'Continuar con Google', Icons.g_mobiledata),
                      const SizedBox(height: 10),
                      _authButton(context, 'Continuar con Apple', Icons.apple),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(12)),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lock_outline, size: 16, color: GlucyColors.primary),
                            SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'Acceso gestionado con Auth0. Glucy AI no guarda contraseñas ni códigos.',
                                style: TextStyle(fontSize: 11.5, height: 1.5, color: GlucyColors.tealText),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Al continuar aceptas los Términos y el Aviso de privacidad de datos de salud.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, height: 1.5, color: Color(0x7310262A)),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => _portalMedico(context),
                        child: const Text.rich(
                          TextSpan(
                            style: TextStyle(fontSize: 12.5, color: Color(0x9910262A)),
                            children: [
                              TextSpan(text: '¿Eres médico? '),
                              TextSpan(text: 'Ingresa aquí', style: TextStyle(fontWeight: FontWeight.w700, color: GlucyColors.primary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _authButton(BuildContext context, String label, IconData icon) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _continuar(context),
        icon: Icon(icon, size: 20, color: GlucyColors.ink),
        label: Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: GlucyColors.ink)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0x1F052E33)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
