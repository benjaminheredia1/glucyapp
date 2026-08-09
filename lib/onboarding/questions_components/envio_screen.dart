import 'package:flutter/material.dart';
import 'package:glucy_app/home/home_screen.dart';
import 'package:glucy_app/home/soporte_screen.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const accent = Color(0xFF2EE6A8);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const tealBg = Color(0xFFDEF3EC);
}

class _EnvioStep {
  final bool done;
  final String title;
  final String sub;
  const _EnvioStep({required this.done, required this.title, required this.sub});
}

/// Seguimiento del kit (glucómetro + tiras + lancetas) que se envía tras
/// firmarse el diagnóstico. Último paso del embudo de ingreso: de aquí en
/// más el paciente ya está en seguimiento (Home).
class EnvioScreen extends StatelessWidget {
  const EnvioScreen({super.key});

  static const _steps = [
    _EnvioStep(done: true, title: 'Pedido confirmado', sub: '24 jul · 09:40'),
    _EnvioStep(done: true, title: 'Kit preparado en almacén', sub: '24 jul · 18:10'),
    _EnvioStep(done: true, title: 'En reparto', sub: '25 jul · 07:55'),
    _EnvioStep(done: false, title: 'Entregado', sub: 'Estimado: 26 jul, 9:00 – 14:00'),
  ];

  void _irAlInicio(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _problemaConEnvio(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SoporteScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Tu glucómetro', style: TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(color: GlucyColors.deep, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: GlucyColors.accent, borderRadius: BorderRadius.circular(999)),
                            child: const Text('En camino', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GlucyColors.deep)),
                          ),
                          const SizedBox(height: 8),
                          const Text('Llega mañana, 26 de julio', style: TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 6),
                          const Text(
                            'Kit Glucy: glucómetro, 50 tiras reactivas y lancetas. Sin costo durante los 12 días de prueba.',
                            style: TextStyle(fontSize: 12.5, height: 1.5, color: Color(0xA6F4FAF9)),
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1, color: Color(0x1FF4FAF9)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Guía de seguimiento', style: TextStyle(fontSize: 10.5, color: Color(0x80F4FAF9))),
                                  Text('GLC-4821-PE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.accent)),
                                ],
                              ),
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Color(0x40F4FAF9)),
                                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                ),
                                child: const Text('Copiar', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Seguimiento', style: TextStyle(fontFamily: 'Sora', fontSize: 12.5, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                          const SizedBox(height: 12),
                          for (var i = 0; i < _steps.length; i++) _timelineStep(_steps[i], isLast: i == _steps.length - 1),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Dirección de entrega', style: TextStyle(fontFamily: 'Sora', fontSize: 12.5, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                          const SizedBox(height: 8),
                          const Text('Av. Arequipa 2450, dpto. 501\nLince, Lima · +51 987 654 321',
                              style: TextStyle(fontSize: 12.5, height: 1.5, color: Color(0xB310262A))),
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
                          Icon(Icons.info_outline, size: 17, color: GlucyColors.primary),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Cuando llegue, abre la app y te guiamos paso a paso en tu primera medición. No registres nada antes de calibrar el equipo.',
                              style: TextStyle(fontSize: 11.5, height: 1.5, color: Color(0xFF0A5A62)),
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
                      onPressed: () => _irAlInicio(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlucyColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Ir a mi inicio', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _problemaConEnvio(context),
                    child: const Text('Tengo un problema con el envío', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: GlucyColors.primary)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timelineStep(_EnvioStep step, {required bool isLast}) {
    final bg = step.done ? GlucyColors.primary : const Color(0xFFE1EDEA);
    final fg = step.done ? Colors.white : const Color(0x7310262A);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: step.done
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : Text('${_steps.indexOf(step) + 1}', style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: step.done ? GlucyColors.primary : const Color(0x14052E33))),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: step.done ? GlucyColors.ink : const Color(0x8010262A))),
                  Text(step.sub, style: const TextStyle(fontSize: 11, color: Color(0x8010262A))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
