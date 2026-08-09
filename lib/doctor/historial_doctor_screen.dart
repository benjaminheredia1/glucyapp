import 'package:flutter/material.dart';
import 'package:glucy_app/doctor/doctor_data.dart';

class _Stat {
  final String value;
  final String label;
  final Color color;
  const _Stat(this.value, this.label, this.color);
}

class _TimelineItem {
  final IconData icon;
  final Color tint;
  final Color fg;
  final String title;
  final String date;
  final String sub;
  final String by;
  const _TimelineItem(this.icon, this.tint, this.fg, this.title, this.date, this.sub, {this.by = ''});
}

/// Historial clínico completo del caso: tendencia de glucosa y línea de
/// tiempo de eventos (alertas, estudios, ajustes, firmas).
class HistorialDoctorScreen extends StatelessWidget {
  final CaseItem item;
  const HistorialDoctorScreen({super.key, required this.item});

  static const _stats = [
    _Stat('6', 'Ciclos completados', DoctorColors.deep),
    _Stat('4', 'Ajustes firmados', DoctorColors.primary),
    _Stat('92 %', 'Adherencia', DoctorColors.primary),
  ];

  static final _timeline = [
    _TimelineItem(Icons.error_outline, DoctorColors.alertBg, DoctorColors.alert, 'Alerta de glucosa 268 mg/dL', 'hoy', 'Reporta sed intensa. Sin vómitos ni confusión.'),
    _TimelineItem(Icons.science_outlined, DoctorColors.tealBg, DoctorColors.primary, 'Estudio de laboratorio subido', '24 jul', 'Perfil lipídico · LDL 142 mg/dL · fuera de meta.'),
    _TimelineItem(Icons.medication_outlined, DoctorColors.tealBg, DoctorColors.primary, 'Ajuste de insulina 20 U → 22 U', '20 jul', 'Ayunas persistente sobre 130 en el ciclo previo.', by: 'Firmado por Dra. Carla Núñez'),
    _TimelineItem(Icons.show_chart, DoctorColors.tealBg, DoctorColors.primary, 'Ciclo de 3 mediciones cerrado', '18 jul', 'Promedio 141 mg/dL · −11 respecto al ciclo anterior.'),
    _TimelineItem(Icons.description_outlined, DoctorColors.tealBg, DoctorColors.primary, 'Plan inicial firmado', '02 jul', 'Metformina 1.000 mg × 2 · insulina glargina 20 U.', by: 'Firmado por Dra. Carla Núñez'),
    _TimelineItem(Icons.shield_outlined, DoctorColors.tealBg, DoctorColors.primary, 'Elegibilidad aprobada', '25 jun', 'Semáforo verde · sin criterios de exclusión.'),
  ];

  static const _progressLine =
      '14,50.4 41.4,44.9 68.7,60.5 96.1,66.9 123.4,63.3 150.8,71.6 178.1,68.6 205.5,74 232.9,69.3 260.2,71.6 287.6,65.6 315,63.7';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: DoctorColors.cardBorder)),
                      child: const Icon(Icons.arrow_back_ios_new, size: 13, color: DoctorColors.primary),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Historial clínico', style: TextStyle(fontFamily: 'Sora', fontSize: 18, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                        Text('${item.name} · caso #48210', style: const TextStyle(fontSize: 11.5, color: Color(0x8010262A))),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: DoctorColors.cardBorder)),
                    child: const Icon(Icons.print_outlined, size: 15, color: DoctorColors.primary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        for (final s in _stats) ...[
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.value, style: TextStyle(fontFamily: 'Sora', fontSize: 18, fontWeight: FontWeight.w700, color: s.color)),
                                  Text(s.label, style: const TextStyle(fontSize: 10, height: 1.3, color: Color(0x8C10262A))),
                                ],
                              ),
                            ),
                          ),
                          if (s != _stats.last) const SizedBox(width: 8),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
                      decoration: BoxDecoration(color: DoctorColors.deep, borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Glucosa en ayunas · 90 días', style: TextStyle(fontFamily: 'Sora', fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(color: DoctorColors.accent, borderRadius: BorderRadius.circular(999)),
                                child: const Text('−27 mg/dL', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: DoctorColors.deep)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          SizedBox(width: double.infinity, height: 90, child: CustomPaint(painter: _LinePainter())),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('LÍNEA DE TIEMPO', style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0x6B10262A), letterSpacing: 0.7)),
                    const SizedBox(height: 9),
                    for (var i = 0; i < _timeline.length; i++) _timelineRow(_timeline[i], isLast: i == _timeline.length - 1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timelineRow(_TimelineItem t, {required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: t.tint, borderRadius: BorderRadius.circular(9)),
                child: Icon(t.icon, size: 14, color: t.fg),
              ),
              if (!isLast) const Expanded(child: VerticalDivider(width: 2, thickness: 2, color: Color(0x14052E33))),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(t.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DoctorColors.ink))),
                      Text(t.date, style: const TextStyle(fontSize: 10.5, color: Color(0x6610262A))),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(t.sub, style: const TextStyle(fontSize: 11.5, height: 1.45, color: Color(0x9910262A))),
                  if (t.by.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(t.by, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: DoctorColors.primary)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final raw = HistorialDoctorScreen._progressLine.split(' ').map((p) {
      final xy = p.split(',');
      return Offset(double.parse(xy[0]), double.parse(xy[1]));
    }).toList();
    final sx = size.width / 320;
    final sy = size.height / 100;
    final points = raw.map((o) => Offset(o.dx * sx, o.dy * sy)).toList();
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = DoctorColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) => false;
}
