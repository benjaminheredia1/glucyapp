import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/features/mediciones/medicion_api.dart';
import 'package:glucy_app/features/mediciones/mediciones_provider.dart';
import 'package:glucy_app/home/patient_tabbar.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const accent = Color(0xFF2EE6A8);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const tealBg = Color(0xFFDEF3EC);
  static const tealText = Color(0xFF0A5A62);
}

/// Tendencia de glucosa y tiempo en rango de los últimos 7/30/90 días.
class ProgresoScreen extends ConsumerStatefulWidget {
  const ProgresoScreen({super.key});

  @override
  ConsumerState<ProgresoScreen> createState() => _ProgresoScreenState();
}

class _ProgresoScreenState extends ConsumerState<ProgresoScreen> {
  String _range = '30';
  bool _tirInfoOpen = false;

  static String _formatear(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    // Mediciones reales del rango elegido; antes eran una maqueta fija.
    final todas = ref.watch(medicionesProvider);
    final enRango = todas.value?.ultimosDias(int.parse(_range)) ?? const <Medicion>[];
    final promedio = enRango.promedio;
    final tir = enRango.porcentajeEnRango;

    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tu progreso', style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      for (final r in ['7', '30', '90']) ...[
                        _rangeChip(r, '$r días'),
                        const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      decoration: BoxDecoration(color: GlucyColors.deep, borderRadius: BorderRadius.circular(16)),
                      child: todas.when(
                        loading: () => const SizedBox(
                          height: 120,
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: GlucyColors.accent)),
                        ),
                        error: (e, _) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e is FalloApi ? e.mensaje : 'No se pudieron cargar tus mediciones.',
                              style: const TextStyle(fontSize: 12.5, color: Color(0xCCF4FAF9)),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              key: const Key('reintentar-mediciones'),
                              onPressed: () => ref.invalidate(medicionesProvider),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: GlucyColors.accent,
                                side: const BorderSide(color: GlucyColors.accent),
                              ),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                        data: (_) => Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Promedio', style: TextStyle(fontSize: 11.5, color: Color(0x99F4FAF9))),
                                    Text.rich(TextSpan(
                                      style: const TextStyle(fontFamily: 'Sora', fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white),
                                      children: [
                                        TextSpan(text: promedio == null ? '— ' : '${_formatear(promedio)} '),
                                        const TextSpan(text: 'mg/dL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0x8CF4FAF9))),
                                      ],
                                    )),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(color: GlucyColors.accent, borderRadius: BorderRadius.circular(999)),
                                  child: Text(
                                    enRango.length == 1 ? '1 medición' : '${enRango.length} mediciones',
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: GlucyColors.deep),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (enRango.isEmpty)
                              const SizedBox(
                                height: 80,
                                child: Center(
                                  child: Text('Sin mediciones en este rango todavía.',
                                      style: TextStyle(fontSize: 12.5, color: Color(0x99F4FAF9))),
                                ),
                              )
                            else
                              SizedBox(
                                width: double.infinity,
                                height: 80,
                                child: CustomPaint(painter: _ProgressLinePainter([for (final m in enRango) m.valor])),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tiempo en rango', style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                              InkWell(
                                borderRadius: BorderRadius.circular(11),
                                onTap: () => setState(() => _tirInfoOpen = !_tirInfoOpen),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0x4D0A7C86))),
                                  child: const Text('?', style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w700, color: GlucyColors.primary)),
                                ),
                              ),
                            ],
                          ),
                          if (_tirInfoOpen) ...[
                            const SizedBox(height: 9),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(11)),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('¿Qué es el tiempo en rango?', style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                                  SizedBox(height: 6),
                                  Text.rich(TextSpan(style: TextStyle(fontSize: 11.5, height: 1.5, color: GlucyColors.tealText), children: [
                                    TextSpan(text: 'Es el porcentaje de tus mediciones que quedaron en el objetivo de '),
                                    TextSpan(text: '≤ 130 mg/dL', style: TextStyle(fontWeight: FontWeight.w700)),
                                    TextSpan(text: ' en ayunas. Mientras más alto, más estable está tu glucosa: importa más que un solo valor aislado.'),
                                  ])),
                                  SizedBox(height: 6),
                                  Text.rich(TextSpan(style: TextStyle(fontSize: 11.5, height: 1.5, color: GlucyColors.tealText), children: [
                                    TextSpan(text: 'Meta recomendada: más del '),
                                    TextSpan(text: '70 %', style: TextStyle(fontWeight: FontWeight.w700)),
                                    TextSpan(text: ' del tiempo en rango.'),
                                  ])),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 9),
                          if (tir == null)
                            const Text('Registra mediciones para calcular tu tiempo en rango.',
                                style: TextStyle(fontSize: 12, color: Color(0x8C10262A)))
                          else ...[
                            Text.rich(TextSpan(
                              style: const TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w700, color: GlucyColors.deep),
                              children: [
                                TextSpan(text: '$tir %'),
                                const TextSpan(text: '  en rango', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0x8C10262A))),
                              ],
                            )),
                            const SizedBox(height: 9),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: SizedBox(
                                height: 14,
                                child: Row(
                                  children: [
                                    if (tir > 0) Expanded(flex: tir, child: const ColoredBox(color: GlucyColors.accent)),
                                    if (tir < 100) Expanded(flex: 100 - tir, child: const ColoredBox(color: Color(0xFFE8A33D))),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 9),
                            Row(
                              children: [
                                _Legend(color: GlucyColors.accent, label: 'En rango $tir%'),
                                const SizedBox(width: 16),
                                _Legend(color: const Color(0xFFE8A33D), label: 'Sobre meta ${100 - tir}%'),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: const [
                        Expanded(child: _Kpi(value: '7.4→6.8', label: 'HbA1c estimada')),
                        SizedBox(width: 10),
                        Expanded(child: _Kpi(value: '−2.6 kg', label: 'Peso')),
                      ],
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.trending_up, size: 17, color: GlucyColors.primary),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tu HbA1c estimada bajó de 7.4% a 6.8% en 30 días. Si mantienes el registro diario, llegas a la meta de <6.5% en el próximo control.',
                              style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF0A5A62)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const PatientTabBar(current: PatientTab.progreso),
          ],
        ),
      ),
    );
  }

  Widget _rangeChip(String key, String label) {
    final on = _range == key;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => setState(() => _range = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: on ? GlucyColors.primary : Colors.white, borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: on ? Colors.white : const Color(0xFF10262A))),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xA610262A))),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  final String value;
  final String label;
  const _Kpi({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w700, color: GlucyColors.primary)),
          const SizedBox(height: 3),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.5, color: Color(0x8C10262A))),
        ],
      ),
    );
  }
}

/// Línea de tendencia simple (sin banda ni puntos), usada en la tarjeta
/// oscura de progreso.
class _ProgressLinePainter extends CustomPainter {
  final List<double> values;
  const _ProgressLinePainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final span = (maxV - minV).clamp(1, double.infinity);
    // Con una sola medicion no hay linea que trazar: un punto al centro.
    final dx = values.length == 1 ? 0.0 : size.width / (values.length - 1);
    final x0 = values.length == 1 ? size.width / 2 : 0.0;
    final points = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(x0 + i * dx, size.height - (values[i] - minV) / span * size.height * 0.85 - size.height * 0.05),
    ];

    if (points.length == 1) {
      canvas.drawCircle(points.first, 4, Paint()..color = const Color(0xFF2EE6A8));
      return;
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF2EE6A8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressLinePainter oldDelegate) => oldDelegate.values != values;
}
