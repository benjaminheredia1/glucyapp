import 'package:flutter/material.dart';
import 'package:glucy_app/doctor/doctor_data.dart';
import 'package:glucy_app/doctor/doctor_tabbar.dart';
import 'package:glucy_app/onboarding/splash_screen.dart';

class _Stat {
  final String value;
  final String label;
  final Color color;
  const _Stat(this.value, this.label, this.color);
}

class _Row {
  final IconData icon;
  final String title;
  final String sub;
  const _Row(this.icon, this.title, this.sub);
}

/// Cuenta profesional: disponibilidad para casos nuevos, atajos de
/// auditoría/honorarios y cierre de sesión.
class PerfilDocScreen extends StatefulWidget {
  const PerfilDocScreen({super.key});

  @override
  State<PerfilDocScreen> createState() => _PerfilDocScreenState();
}

class _PerfilDocScreenState extends State<PerfilDocScreen> {
  final Map<String, bool> _availability = {'L': true, 'M': true, 'X': true, 'J': true, 'V': true, 'S': false, 'D': false};
  bool _urgentOn = true;

  static const _stats = [
    _Stat('48', 'Pacientes a cargo', DoctorColors.deep),
    _Stat('214', 'Planes firmados', DoctorColors.primary),
    _Stat('4h20', 'Validación media', DoctorColors.primary),
  ];
  static const _rows = [
    _Row(Icons.shield_outlined, 'Firma digital', 'Certificado vigente hasta may 2027'),
    _Row(Icons.apartment_outlined, 'Clínicas vinculadas', 'San Rafael · Andes · Vitalia'),
    _Row(Icons.description_outlined, 'Auditoría de mis firmas', '214 registros · exportable'),
    _Row(Icons.credit_card_outlined, 'Honorarios y liquidación', 'Próximo corte: 31 de agosto'),
    _Row(Icons.help_outline, 'Soporte profesional', 'Línea directa para médicos'),
  ];

  void _cerrarSesion() {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const SplashScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Mi cuenta', style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(color: DoctorColors.tealBg, shape: BoxShape.circle),
                            child: const Text('CN', style: TextStyle(fontFamily: 'Sora', fontSize: 17, fontWeight: FontWeight.w700, color: DoctorColors.primary)),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Dra. Carla Núñez', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                                const Text('Endocrinología · Mat. 45281', style: TextStyle(fontSize: 12, color: Color(0x8C10262A))),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(color: DoctorColors.tealBg, borderRadius: BorderRadius.circular(999)),
                                  child: const Text('Colegiatura vigente', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: DoctorColors.primary)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        for (final s in _stats) ...[
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                children: [
                                  Text(s.value, style: TextStyle(fontFamily: 'Sora', fontSize: 18, fontWeight: FontWeight.w700, color: s.color)),
                                  Text(s.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, height: 1.3, color: Color(0x8C10262A))),
                                ],
                              ),
                            ),
                          ),
                          if (s != _stats.last) const SizedBox(width: 8),
                        ],
                      ],
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('DISPONIBILIDAD', style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0x6B10262A), letterSpacing: 0.7)),
                          const SizedBox(height: 8),
                          const Text('Los casos nuevos solo se te asignan en los días marcados.', style: TextStyle(fontSize: 11.5, height: 1.5, color: Color(0x9910262A))),
                          const SizedBox(height: 9),
                          Row(
                            children: [
                              for (final d in ['L', 'M', 'X', 'J', 'V', 'S', 'D']) ...[
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () => setState(() => _availability[d] = !_availability[d]!),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: _availability[d]! ? DoctorColors.primary : Colors.white,
                                        border: Border.all(color: _availability[d]! ? DoctorColors.primary : const Color(0x1F052E33)),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(d, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _availability[d]! ? Colors.white : DoctorColors.ink)),
                                    ),
                                  ),
                                ),
                                if (d != 'D') const SizedBox(width: 6),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Recibir casos urgentes', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: DoctorColors.ink)),
                                  Text('Incluye fines de semana', style: TextStyle(fontSize: 11, color: Color(0x8010262A))),
                                ],
                              ),
                              Switch(value: _urgentOn, activeTrackColor: DoctorColors.primary, onChanged: (v) => setState(() => _urgentOn = v)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (final r in _rows)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(border: Border(bottom: r == _rows.last ? BorderSide.none : const BorderSide(color: Color(0x0D052E33)))),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(color: DoctorColors.tealBg, borderRadius: BorderRadius.circular(9)),
                                    child: Icon(r.icon, size: 17, color: DoctorColors.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(r.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DoctorColors.ink)),
                                        Text(r.sub, style: const TextStyle(fontSize: 11.5, color: Color(0x8C10262A))),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, size: 18, color: Color(0x4D10262A)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    OutlinedButton(
                      onPressed: _cerrarSesion,
                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xB310262A), side: const BorderSide(color: Color(0x26052E33)), padding: const EdgeInsets.symmetric(vertical: 13)),
                      child: const Text('Cerrar sesión', style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
            const DoctorTabBar(current: DoctorTab.perfil),
          ],
        ),
      ),
    );
  }
}
