import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:glucy_app/onboarding/questions_components/clinical_filter_widget.dart';
import 'package:glucy_app/onboarding/onboarding_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Color _bgColor = Color(0xFF052E33);
  static const Color _neonGreen = Color(0xFF2EE6A8);
  static const Color _subtitleColor = Color(0xFF6E9A9C);
  static const Color _trackColor = Color(0xFF0B4247);

  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 22200),
    )..forward();

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OnboardingScreen(
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'lib/assets/glucy_drop_icon.svg',
                width: 84,
                height: 84,
              ),
              const SizedBox(height: 24),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                  children: [
                    TextSpan(text: 'Glucy ', style: TextStyle(color: Colors.white)),
                    TextSpan(text: 'AI', style: TextStyle(color: _neonGreen)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tu tratamiento analizado por la IA y\nvalidado por médicos reales',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: _subtitleColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, _) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progressController.value,
                      minHeight: 4,
                      backgroundColor: _trackColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(_neonGreen),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
