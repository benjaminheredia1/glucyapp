import 'package:flutter/material.dart';
import 'package:glucy_app/doctor/chat_doctor_screen.dart';
import 'package:glucy_app/doctor/doctor_data.dart';
import 'package:glucy_app/doctor/editar_plan_screen.dart';
import 'package:glucy_app/doctor/firma_screen.dart';
import 'package:glucy_app/doctor/historial_doctor_screen.dart';

class _Lab {
  final String value;
  final String label;
  final Color color;
  const _Lab(this.value, this.label, this.color);
}

/// Detalle del caso: elegibilidad automática, laboratorios y la
/// propuesta de tratamiento generada por la IA, aún sin validar.
class CasoScreen extends StatelessWidget {
  final CaseItem item;
  const CasoScreen({super.key, required this.item});

  static const _tags = ['IMC 28.2', 'HTA', 'Estudios completos'];
  static const _labs = [
    _Lab('158', 'Ayunas', DoctorColors.warn),
    _Lab('7.4%', 'HbA1c', DoctorColors.warn),
    _Lab('92', 'TFG', DoctorColors.primary),
    _Lab('142', 'LDL', DoctorColors.warn),
    _Lab('Neg', 'Cetonas', DoctorColors.primary),
    _Lab('Nl', 'ALT/AST', DoctorColors.primary),
  ];
  static const _aiDiagnosis =
      'Diabetes tipo 2 (E11.9) de 2 años de evolución, con control glucémico subóptimo y sin complicaciones agudas. Riesgo cardiovascular por LDL elevado.';
  static const _aiPlan = [
    'Metformina 500 mg × 2 con alimentos',
    'Insulina glargina 20 U nocturna · rango 18–26 U',
    'Una medición diaria en ayunas',
    'Estudio de control cada 3 mediciones',
  ];

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
                        Text('${item.name}, ${item.age}', style: const TextStyle(fontFamily: 'Sora', fontSize: 18, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                        const Text('Caso #48210 · DM2 · E11.9', style: TextStyle(fontSize: 11.5, color: Color(0x8010262A))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(color: DoctorColors.tealBg, borderRadius: BorderRadius.circular(999)),
                    child: const Text('Ingreso nuevo', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: DoctorColors.primary)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        for (final t in _tags)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(999)),
                            child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xA610262A))),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: DoctorColors.tealBg, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Elegibilidad automática', style: TextStyle(fontFamily: 'Sora', fontSize: 12.5, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                                child: const Text('Semáforo verde', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: DoctorColors.primary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          const Text('Filtro 1 sin banderas · TFG 92 · cetonas negativas · péptido C normal (descarta LADA) · ALT/AST normales.',
                              style: TextStyle(fontSize: 11.5, height: 1.5, color: DoctorColors.tealText)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Laboratorios', style: TextStyle(fontFamily: 'Sora', fontSize: 12.5, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                          const SizedBox(height: 9),
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1.5,
                            children: [
                              for (final l in _labs)
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: DoctorColors.bg, borderRadius: BorderRadius.circular(9)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(l.value, style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w700, color: l.color)),
                                      Text(l.label, style: const TextStyle(fontSize: 9.5, color: Color(0x8C10262A))),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => HistorialDoctorScreen(item: item))),
                            icon: const Icon(Icons.description_outlined, size: 17),
                            label: const Text('Historial', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(foregroundColor: DoctorColors.primary, side: const BorderSide(color: Color(0x400A7C86)), padding: const EdgeInsets.symmetric(vertical: 12)),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatDoctorScreen(item: item))),
                                icon: const Icon(Icons.chat_bubble_outline, size: 17),
                                label: const Text('Mensajes', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                                style: OutlinedButton.styleFrom(foregroundColor: DoctorColors.primary, side: const BorderSide(color: Color(0x400A7C86)), padding: const EdgeInsets.symmetric(vertical: 12)),
                              ),
                              Positioned(
                                top: 6,
                                right: 18,
                                child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: DoctorColors.alert, shape: BoxShape.circle)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0x59E8A33D)), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(color: DoctorColors.warnBg, borderRadius: BorderRadius.circular(999)),
                                child: const Text('Propuesta de la IA', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: DoctorColors.warn)),
                              ),
                              const SizedBox(width: 8),
                              const Text('sin validar', style: TextStyle(fontSize: 11, color: Color(0x7310262A))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(_aiDiagnosis, style: TextStyle(fontSize: 13, height: 1.5, color: DoctorColors.ink)),
                          const Divider(height: 20, color: Color(0x14052E33)),
                          for (final p in _aiPlan) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 6, right: 9),
                                  child: SizedBox(width: 5, height: 5, child: DecoratedBox(decoration: BoxDecoration(color: DoctorColors.warn, shape: BoxShape.circle))),
                                ),
                                Expanded(child: Text(p, style: const TextStyle(fontSize: 12.5, height: 1.45, color: DoctorColors.ink))),
                              ],
                            ),
                            if (p != _aiPlan.last) const SizedBox(height: 6),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: DoctorColors.cardBorder))),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditarPlanScreen(item: item))),
                      style: OutlinedButton.styleFrom(foregroundColor: DoctorColors.primary, side: const BorderSide(color: Color(0x4D0A7C86)), padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Editar plan', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => FirmaScreen(item: item, metfDose: 500, metfTimes: 2, insDose: 20)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DoctorColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Revisar y firmar', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
