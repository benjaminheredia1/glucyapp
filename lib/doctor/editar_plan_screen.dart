import 'package:flutter/material.dart';
import 'package:glucy_app/doctor/doctor_data.dart';
import 'package:glucy_app/doctor/firma_screen.dart';

/// Edición del plan sugerido por la IA antes de firmarlo: dosis de
/// metformina e insulina con steppers, más nota clínica libre.
class EditarPlanScreen extends StatefulWidget {
  final CaseItem item;
  const EditarPlanScreen({super.key, required this.item});

  @override
  State<EditarPlanScreen> createState() => _EditarPlanScreenState();
}

class _EditarPlanScreenState extends State<EditarPlanScreen> {
  int _metfDose = 500;
  int _metfTimes = 2;
  int _insDose = 20;
  final _noteController = TextEditingController(
    text: 'Toma la metformina justo después de las comidas para reducir el malestar estomacal. '
        'Si los valores en ayunas siguen sobre 130, los ajustamos en el próximo ciclo.',
  );

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _metfChanged => _metfDose != 500 || _metfTimes != 2;
  int get _insPct => ((_insDose.clamp(18, 26) - 18) / 8 * 100).round();

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
                  const Expanded(
                    child: Text('Editar plan',
                        textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Metformina', style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(color: _metfChanged ? DoctorColors.warnBg : DoctorColors.tealBg, borderRadius: BorderRadius.circular(999)),
                                child: Text(_metfChanged ? 'Modificado' : 'Como sugerido',
                                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: _metfChanged ? DoctorColors.warn : DoctorColors.primary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _stepperRow('Dosis por toma', '$_metfDose mg',
                              onMinus: () => setState(() => _metfDose = (_metfDose - 250).clamp(250, 1000)),
                              onPlus: () => setState(() => _metfDose = (_metfDose + 250).clamp(250, 1000))),
                          const SizedBox(height: 10),
                          _stepperRow('Tomas por día', '$_metfTimes',
                              onMinus: () => setState(() => _metfTimes = (_metfTimes - 1).clamp(1, 3)),
                              onPlus: () => setState(() => _metfTimes = (_metfTimes + 1).clamp(1, 3))),
                          const SizedBox(height: 10),
                          Text('Sugerido por IA: 500 mg × 2 · tu ajuste: $_metfDose mg × $_metfTimes',
                              style: const TextStyle(fontSize: 11, height: 1.45, color: Color(0x8010262A))),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Insulina glargina (Lantus)', style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(color: DoctorColors.tealBg, borderRadius: BorderRadius.circular(999)),
                                child: const Text('Basal', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: DoctorColors.primary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _stepperRow('Dosis nocturna', '$_insDose U',
                              onMinus: () => setState(() => _insDose = (_insDose - 2).clamp(10, 40)),
                              onPlus: () => setState(() => _insDose = (_insDose + 2).clamp(10, 40))),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: DoctorColors.bg, borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Rango de titulación autorizado', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xA610262A))),
                                    Text('18 U – 26 U', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: DoctorColors.primary)),
                                  ],
                                ),
                                const SizedBox(height: 7),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(99),
                                  child: LinearProgressIndicator(value: _insPct / 100, minHeight: 6, backgroundColor: const Color(0xFFE1EDEA), valueColor: const AlwaysStoppedAnimation(DoctorColors.primary)),
                                ),
                                const SizedBox(height: 7),
                                const Text('Dentro de este rango la IA puede ajustar 2 U por ciclo sin volver a consultarte.',
                                    style: TextStyle(fontSize: 11, height: 1.45, color: Color(0x8010262A))),
                              ],
                            ),
                          ),
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
                          const Text('Nota clínica para la paciente', style: TextStyle(fontFamily: 'Sora', fontSize: 12.5, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _noteController,
                            maxLines: 4,
                            style: const TextStyle(fontSize: 12.5, height: 1.5, color: DoctorColors.ink),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(11),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0x400A7C86))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0x400A7C86))),
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
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: DoctorColors.cardBorder))),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => FirmaScreen(item: widget.item, metfDose: _metfDose, metfTimes: _metfTimes, insDose: _insDose)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DoctorColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Guardar y continuar a la firma', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepperRow(String label, String value, {required VoidCallback onMinus, required VoidCallback onPlus}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xB310262A))),
        Row(
          children: [
            _stepBtn('−', onMinus),
            SizedBox(width: 64, child: Text(value, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w700, color: DoctorColors.deep))),
            _stepBtn('+', onPlus),
          ],
        ),
      ],
    );
  }

  Widget _stepBtn(String label, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: DoctorColors.bg, border: Border.all(color: const Color(0x1F052E33)), borderRadius: BorderRadius.circular(9)),
        child: Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w700, color: DoctorColors.primary)),
      ),
    );
  }
}
