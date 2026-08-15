import 'package:flutter/material.dart';
import 'package:glucy_app/onboarding/questions_components/lab_domicilio_screen.dart';

enum StudyStatus { done, pending, rejected }

/// Ficha estatica de un estudio para esta pantalla de carga guiada.
/// (EstudiosScreen ya trabaja contra la API; esto queda para el flujo del
/// ciclo, que aun es una maqueta.)
class StudyItem {
  final int n;
  final String name;
  final String subtitle; // qué mide
  final String banner; // por qué importa
  final StudyStatus status;
  final String detail;

  const StudyItem({
    required this.n,
    required this.name,
    required this.subtitle,
    required this.banner,
    required this.status,
    this.detail = '',
  });
}

/// Colores del diseño Glucy AI
class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const muted = Color(0x9910262A); // rgba(16,38,42,0.6)
  static const tealBg = Color(0xFFDEF3EC);
  static const tealText = Color(0xFF0A5A62);
}

/// Sube (o simula la lectura de) un estudio individual pendiente o
/// rechazado. Al confirmar, hace pop devolviendo el detalle leído para
/// que EstudiosScreen marque ese estudio como completado.
class SubirEstudioScreen extends StatelessWidget {
  final StudyItem study;

  const SubirEstudioScreen({super.key, required this.study});

  void _confirmarSubida(BuildContext context) {
    // TODO: reemplazar por lectura real del archivo (OCR/backend) cuando exista.
    Navigator.of(context).pop('Leído · pendiente de verificación');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: GlucyColors.cardBorder),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 13, color: GlucyColors.primary),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      study.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Sora', fontSize: 18, fontWeight: FontWeight.w700, color: GlucyColors.deep),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 12),
              Text(study.subtitle, style: const TextStyle(fontSize: 12.5, color: GlucyColors.muted)),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(12)),
                child: Text(study.banner, style: const TextStyle(fontSize: 12.5, height: 1.5, color: GlucyColors.tealText)),
              ),
              const SizedBox(height: 16),
              const Text(
                'SI TODAVÍA NO TIENES EL ESTUDIO',
                style: TextStyle(fontFamily: 'Sora', fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0x6B10262A), letterSpacing: 0.7),
              ),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LabDomicilioScreen())),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0x400A7C86)), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(9)),
                        child: const Icon(Icons.home_outlined, size: 18, color: GlucyColors.primary),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Que un laboratorio venga a ti', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
                            Text('Toma de muestra a domicilio · desde 12 USD', style: TextStyle(fontSize: 11.5, color: GlucyColors.muted)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18, color: Color(0x4D10262A)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'SI YA TIENES EL RESULTADO',
                style: TextStyle(fontFamily: 'Sora', fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0x6B10262A), letterSpacing: 0.7),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _uploadButton(context, Icons.camera_alt_outlined, 'Tomar foto')),
                  const SizedBox(width: 10),
                  Expanded(child: _uploadButton(context, Icons.description_outlined, 'Subir PDF')),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: GlucyColors.primary),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Que se lean los valores, la fecha y tu nombre. Si algo falta, te lo pedimos de nuevo sin afectar tu elegibilidad.',
                        style: TextStyle(fontSize: 11.5, height: 1.5, color: GlucyColors.muted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _uploadButton(BuildContext context, IconData icon, String label) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _confirmarSubida(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x660A7C86), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: GlucyColors.primary),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: GlucyColors.primary)),
          ],
        ),
      ),
    );
  }
}
