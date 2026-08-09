import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:glucy_app/doctor/doctor_login_screen.dart';
import 'package:glucy_app/profile/profile.dart';

/// Colores extraídos del diseño (Glucy AI)
class GlucyColors {
  static const deep = Color(0xFF052E33); // fondo header oscuro
  static const primary = Color(0xFF0A7C86); // teal principal (botón, íconos)
  static const accent = Color(0xFF2EE6A8); // verde acento del logo
  static const bg = Color(0xFFF4FAF9); // fondo general
  static const cardBorder = Color(0xFFDDE8E7); // borde de tarjetas
  static const iconBg = Color(0xFFCFE9E4); // fondo circular de íconos
  static const ink = Color(0xFF10262A); // texto principal
  static const muted = Color(0xFF5E7377); // texto secundario
  static const subHeader = Color(0xFF8FB3B5); // subtítulo sobre header oscuro
  static const ratingBg = Color(0xFFEAF4F2); // fondo tarjeta de rating
}

/// Item de la lista de beneficios del onboarding
class OnboardingBenefit {
  final IconData icon;
  final String title;
  final String subtitle;

  const OnboardingBenefit({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const List<OnboardingBenefit> _benefits = [
    OnboardingBenefit(
      icon: Icons.access_time_rounded,
      title: '3 minutos para saber si aplicas',
      subtitle: 'Filtro clínico gratuito, sin estudios',
    ),
    OnboardingBenefit(
      icon: Icons.science_outlined,
      title: 'Pre-diagnóstico con tus laboratorios',
      subtitle: 'Antes de pagar nada',
    ),
    OnboardingBenefit(
      icon: Icons.shield_outlined,
      title: 'Un médico firma tu plan',
      subtitle: 'Nada llega a ti sin su aprobación',
    ),
  ];

  void _empezar(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const Profile()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: Column(
        children: [
          // ---------- Header oscuro con logo, título y subtítulo ----------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            decoration: const BoxDecoration(
              color: GlucyColors.deep,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
            ),
            child: Column(
              children: [
                const GlucyLogoMark(size: 44),
                const SizedBox(height: 14),
                const Text(
                  'Un plan de tratamiento,\nno un consejo genérico',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                    height: 1.25,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Verificamos si tu caso es apto, analizamos tus estudios '
                  'y un médico especialista valida el plan antes de que lo veas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: GlucyColors.subHeader,
                  ),
                ),
              ],
            ),
          ),

          // ---------- Lista de beneficios + rating ----------
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  for (final b in _benefits) ...[
                    _BenefitCard(benefit: b),
                    const SizedBox(height: 8),
                  ],
                  _RatingCard(),
                ],
              ),
            ),
          ),

          // ---------- Botón CTA + disclaimer ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _empezar(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GlucyColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: GlucyColors.primary),
                      ),
                    ),
                    child: const Text(
                      'Empezar es gratis',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ninguna recomendación llega a ti sin firma médica.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: GlucyColors.muted,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: Divider(color: GlucyColors.cardBorder)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'acceso profesional',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: GlucyColors.muted.withValues(alpha: 0.7), letterSpacing: 0.6),
                      ),
                    ),
                    Expanded(child: Divider(color: GlucyColors.cardBorder)),
                  ],
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DoctorLoginScreen())),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: GlucyColors.primary.withValues(alpha: 0.35), width: 1.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: GlucyColors.iconBg, borderRadius: BorderRadius.circular(11)),
                          child: const Icon(Icons.shield_outlined, size: 18, color: GlucyColors.primary),
                        ),
                        const SizedBox(width: 11),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Soy doctor, ingresar', style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                              Text('Portal de validación clínica', style: TextStyle(fontSize: 11, color: GlucyColors.muted)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 18, color: GlucyColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta blanca con ícono circular + título + subtítulo (uno por beneficio)
class _BenefitCard extends StatelessWidget {
  final OnboardingBenefit benefit;
  const _BenefitCard({required this.benefit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: GlucyColors.cardBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: GlucyColors.iconBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(benefit.icon, size: 18, color: GlucyColors.primary),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: GlucyColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  benefit.subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: GlucyColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta "4.8/5 de valoración · +1.200 pacientes"
class _RatingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 2, bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GlucyColors.ratingBg,
        border: Border.all(color: GlucyColors.iconBg),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '4.8/5 de valoración',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: GlucyColors.ink,
            ),
          ),
          const Text(
            '+1.200 pacientes',
            style: TextStyle(
              fontSize: 12.5,
              color: GlucyColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo de Glucy AI (gota + check), SVG original.
class GlucyLogoMark extends StatelessWidget {
  final double size;
  const GlucyLogoMark({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'lib/assets/glucy_drop_icon.svg',
      width: size,
      height: size,
    );
  }
}
