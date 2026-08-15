import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucy_app/features/auth/domain/sesion.dart';
import 'package:glucy_app/features/auth/domain/usuario.dart';
import 'package:glucy_app/features/auth/presentation/sesion_controller.dart';
import 'package:glucy_app/home/notifs_screen.dart';
import 'package:glucy_app/home/patient_tabbar.dart';
import 'package:glucy_app/home/plan_screen.dart';
import 'package:glucy_app/home/progreso_screen.dart';
import 'package:glucy_app/home/registrar_screen.dart';
import 'package:glucy_app/onboarding/questions_components/estudios_screen.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const accent = Color(0xFF2EE6A8);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const warn = Color(0xFFB97417);
  static const warnBg = Color(0xFFFBEEDA);
}

class _HomeAction {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;
  const _HomeAction({required this.label, required this.icon, required this.onTap, this.primary = false});
}

/// Panel principal del paciente ya en seguimiento: última glucosa, acciones
/// rápidas y estado de los turnos de medición. Punto de llegada del embudo
/// de ingreso (splash → … → diagnóstico → aquí).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _readings = [166, 154, 149, 141, 138, 132, 124];
  static const _days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  static String _saludo(int hora) =>
      hora < 12 ? 'Buenos días,' : hora < 19 ? 'Buenas tardes,' : 'Buenas noches,';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // El router solo deja llegar aqui autenticado; el caso por defecto cubre
    // el frame de transicion durante un cierre de sesion.
    final nombre = switch (ref.watch(sesionControllerProvider).value) {
      SesionAutenticado(:final usuario) => usuario.nombreCompleto,
      _ => '',
    };
    final actions = [
      _HomeAction(
        label: 'Registrar',
        icon: Icons.upload_outlined,
        primary: true,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegistrarScreen())),
      ),
      _HomeAction(
        label: 'Medicinas',
        icon: Icons.medication_outlined,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlanScreen())),
      ),
      _HomeAction(
        label: 'Estudios',
        icon: Icons.science_outlined,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EstudiosScreen())),
      ),
      _HomeAction(
        label: 'Progreso',
        icon: Icons.show_chart,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProgresoScreen())),
      ),
    ];

    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
              child: Row(
                children: [
                  const SizedBox(width: 42),
                  Expanded(
                    child: Column(
                      children: [
                        Text(_saludo(DateTime.now().hour), style: const TextStyle(fontSize: 12.5, color: Color(0x8010262A))),
                        Text(
                          nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'Sora', fontSize: 21, fontWeight: FontWeight.w700, color: GlucyColors.deep),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(21),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotifsScreen())),
                    child: Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: GlucyColors.cardBorder)),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.notifications_none_rounded, size: 20, color: GlucyColors.primary),
                          Positioned(
                            top: -1,
                            right: -1,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: Color(0xFFE8574B), shape: BoxShape.circle),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                child: Column(
                  children: [
                    _glucoseCard(),
                    const SizedBox(height: 13),
                    _todayCard(),
                    const SizedBox(height: 13),
                    _actionsGrid(actions),
                    const SizedBox(height: 13),
                    _turnosCard(context),
                  ],
                ),
              ),
            ),
            const PatientTabBar(current: PatientTab.home),
          ],
        ),
      ),
    );
  }

  Widget _glucoseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: GlucyColors.deep, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontFamily: 'Sora', fontSize: 30, fontWeight: FontWeight.w700, color: GlucyColors.accent),
                        children: [
                          TextSpan(text: '${_readings.last} '),
                          const TextSpan(text: 'mg/dL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0x99F4FAF9))),
                        ],
                      ),
                    ),
                    const Text('Ayunas · hoy 08:10', style: TextStyle(fontSize: 11.5, color: Color(0x8CF4FAF9))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: GlucyColors.accent, borderRadius: BorderRadius.circular(999)),
                child: const Text('En rango', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GlucyColors.deep)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 90,
            child: CustomPaint(painter: _GlucoseChartPainter(_readings)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [for (final d in _days) Text(d, style: const TextStyle(fontSize: 10, color: Color(0x73F4FAF9)))],
            ),
          ),
        ],
      ),
    );
  }

  Widget _todayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Medición de hoy registrada', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
              Text('1 de 1', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GlucyColors.primary)),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: const LinearProgressIndicator(value: 1, minHeight: 7, backgroundColor: Color(0xFFE1EDEA), valueColor: AlwaysStoppedAnimation(GlucyColors.primary)),
          ),
          const SizedBox(height: 9),
          const Text(
            'Registras una medición al día y el ciclo de ajuste se cierra cada 3 días.',
            style: TextStyle(fontSize: 11.5, height: 1.5, color: Color(0x8C10262A)),
          ),
        ],
      ),
    );
  }

  Widget _actionsGrid(List<_HomeAction> actions) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.6,
      children: [
        for (final a in actions)
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: a.onTap,
            child: Container(
              decoration: BoxDecoration(
                color: a.primary ? GlucyColors.primary : Colors.white,
                border: Border.all(color: a.primary ? GlucyColors.primary : const Color(0x380A7C86)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(a.icon, size: 21, color: a.primary ? Colors.white : GlucyColors.primary),
                  const SizedBox(height: 6),
                  Text(a.label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: a.primary ? Colors.white : GlucyColors.primary)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _turnosCard(BuildContext context) {
    const turnDone = [true, true, false, false];
    const turnLabels = ['Día 3', 'Día 6', 'Día 9', 'Día 12'];
    const current = 3;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tus turnos', style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
              Text('turno $current de 4', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GlucyColors.primary)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < turnLabels.length; i++) ...[
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: turnDone[i] ? GlucyColors.primary : (i + 1 == current ? GlucyColors.warn : const Color(0xFFE1EDEA)),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(turnLabels[i],
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: turnDone[i] ? GlucyColors.primary : (i + 1 == current ? GlucyColors.warn : const Color(0x6610262A)))),
                    ],
                  ),
                ),
                if (i != turnLabels.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Registras tu glucosa cada 3 días (turnos 1 a 3). En el turno del día 12 subes un estudio de laboratorio y el día 13 un médico revisa y ajusta tu tratamiento.',
            style: TextStyle(fontSize: 11.5, height: 1.5, color: Color(0x8010262A)),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(color: GlucyColors.warnBg, borderRadius: BorderRadius.circular(10)),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.event_note_outlined, size: 15, color: GlucyColors.warn),
                SizedBox(width: 9),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 11, height: 1.5, color: Color(0xFF8A5510)),
                      children: [
                        TextSpan(text: 'El '),
                        TextSpan(text: 'día 13', style: TextStyle(fontWeight: FontWeight.w700)),
                        TextSpan(text: ' se activa el pago por QR: es cuando un médico revisa tu ciclo y firma el ajuste.'),
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

/// Dibuja la línea de glucosa de los últimos 7 días con la banda "en rango"
/// (110–140 mg/dL), replicando el gráfico SVG del diseño original.
class _GlucoseChartPainter extends CustomPainter {
  final List<int> readings;
  const _GlucoseChartPainter(this.readings);

  static const _vMin = 110.0;
  static const _vMax = 175.0;
  static const _top = 14.0;
  static const _bot = 94.0;
  static const _viewW = 320.0;
  static const _viewH = 110.0;

  double _y(double v) {
    final clamped = v.clamp(_vMin, _vMax);
    return _bot - (clamped - _vMin) / (_vMax - _vMin) * (_bot - _top);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / _viewW;
    final sy = size.height / _viewH;

    final bandTop = _y(140) * sy;
    final bandBottom = _y(110) * sy;
    final bandPaint = Paint()..color = const Color(0x282EE6A8);
    canvas.drawRect(Rect.fromLTRB(0, bandTop, size.width, bandBottom), bandPaint);

    final points = <Offset>[
      for (var i = 0; i < readings.length; i++) Offset((26 + i * 44) * sx, _y(readings[i].toDouble()) * sy),
    ];

    final linePaint = Paint()
      ..color = const Color(0xFF2EE6A8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, linePaint);

    for (var i = 0; i < points.length; i++) {
      final fill = readings[i] <= 140 ? const Color(0xFF2EE6A8) : const Color(0xFFE8A33D);
      canvas.drawCircle(points[i], 4 * ((sx + sy) / 2), Paint()..color = fill);
      canvas.drawCircle(points[i], 4 * ((sx + sy) / 2), Paint()
        ..color = const Color(0xFF052E33)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6);
    }
  }

  @override
  bool shouldRepaint(covariant _GlucoseChartPainter oldDelegate) => oldDelegate.readings != readings;
}
