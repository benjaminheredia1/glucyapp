import 'package:flutter/material.dart';
import 'package:glucy_app/onboarding/questions_components/estudios_screen.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const alertBg = Color(0xFFFBE4E1);
  static const alert = Color(0xFFE8574B);
  static const tealBg = Color(0xFFDEF3EC);
}

/// Artículo de ayuda con pasos accionables. Contenido específico para
/// "estudio rechazado", el caso más consultado.
class FaqArticuloScreen extends StatelessWidget {
  const FaqArticuloScreen({super.key});

  static const _steps = [
    ('Abre el estudio marcado en rojo', 'Verás el motivo exacto del rechazo'),
    ('Vuelve a fotografiar la hoja completa', 'Que se vean valores, fecha y tu nombre'),
    ('Súbelo de nuevo', 'La revisión toma menos de 2 horas'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: GlucyColors.alertBg, borderRadius: BorderRadius.circular(999)),
                    child: const Text('Estudio rechazado', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GlucyColors.alert)),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 14),
              const Text('¿Qué hago si mi estudio fue rechazado?',
                  style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, height: 1.3, color: GlucyColors.deep)),
              const SizedBox(height: 10),
              const Text(
                'Un estudio se rechaza cuando no se leen los valores, falta la fecha o el nombre no coincide con tu cuenta. No afecta tu elegibilidad: solo hay que volver a subirlo.',
                style: TextStyle(fontSize: 13, height: 1.55, color: Color(0xA610262A)),
              ),
              const SizedBox(height: 14),
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
                        decoration: const BoxDecoration(color: GlucyColors.tealBg, shape: BoxShape.circle),
                        child: Text('${i + 1}', style: const TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w700, color: GlucyColors.primary)),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_steps[i].$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
                            Text(_steps[i].$2, style: const TextStyle(fontSize: 11.5, height: 1.45, color: Color(0x8C10262A))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EstudiosScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlucyColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Ir a mis estudios', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿Te sirvió? ', style: TextStyle(fontSize: 12, color: Color(0x8010262A))),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(foregroundColor: GlucyColors.primary, side: const BorderSide(color: Color(0x1F052E33)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                    child: const Text('Sí', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(foregroundColor: GlucyColors.ink, side: const BorderSide(color: Color(0x1F052E33)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                    child: const Text('No', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
