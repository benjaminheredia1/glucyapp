import 'package:flutter/material.dart';
import 'package:glucy_app/doctor/doctor_data.dart';
import 'package:glucy_app/doctor/enviado_screen.dart';

/// Firma profesional del plan: resume lo que recibirá la paciente y
/// exige la casilla de responsabilidad clínica antes de enviar.
class FirmaScreen extends StatefulWidget {
  final CaseItem item;
  final int metfDose;
  final int metfTimes;
  final int insDose;

  const FirmaScreen({super.key, required this.item, required this.metfDose, required this.metfTimes, required this.insDose});

  @override
  State<FirmaScreen> createState() => _FirmaScreenState();
}

class _FirmaScreenState extends State<FirmaScreen> {
  bool _signed = false;

  @override
  Widget build(BuildContext context) {
    final summary = [
      'Diagnóstico: diabetes tipo 2 (E11.9)',
      'Metformina ${widget.metfDose} mg, ${widget.metfTimes} veces al día con alimentos',
      'Insulina glargina (Lantus) ${widget.insDose} U a las 22:00 · rango 18–26 U',
      'Una medición de glucosa al día con su momento',
      'Estudio de laboratorio cada 3 mediciones',
    ];

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
                    child: Text('Firmar y enviar',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RESUMEN QUE RECIBIRÁ LA PACIENTE',
                        style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0x6B10262A), letterSpacing: 0.6)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final s in summary) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 6, right: 9),
                                  child: SizedBox(width: 5, height: 5, child: DecoratedBox(decoration: BoxDecoration(color: DoctorColors.primary, shape: BoxShape.circle))),
                                ),
                                Expanded(child: Text(s, style: const TextStyle(fontSize: 12.5, height: 1.45, color: DoctorColors.ink))),
                              ],
                            ),
                            if (s != summary.last) const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Firma profesional', style: TextStyle(fontFamily: 'Sora', fontSize: 12.5, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                          const SizedBox(height: 11),
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: DoctorColors.tealBg, shape: BoxShape.circle),
                                child: const Text('CN', style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700, color: DoctorColors.primary)),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Dra. Carla Núñez', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DoctorColors.ink)),
                                    Text('Endocrinología · Mat. 45281', style: TextStyle(fontSize: 11, color: Color(0x8C10262A))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 11),
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => setState(() => _signed = !_signed),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _signed ? DoctorColors.tealBg : DoctorColors.bg,
                                border: Border.all(color: _signed ? const Color(0x660A7C86) : DoctorColors.cardBorder),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: _signed ? DoctorColors.primary : Colors.white,
                                      border: Border.all(color: _signed ? DoctorColors.primary : const Color(0x33052E33)),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: _signed ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                                  ),
                                  const SizedBox(width: 11),
                                  const Expanded(
                                    child: Text('Confirmo que revisé los estudios y asumo la responsabilidad clínica de este plan.',
                                        style: TextStyle(fontSize: 12, height: 1.45, color: DoctorColors.ink)),
                                  ),
                                ],
                              ),
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
                onPressed: _signed
                    ? () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => EnviadoScreen(item: widget.item)))
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _signed ? DoctorColors.primary : DoctorColors.primary.withValues(alpha: 0.35),
                  disabledBackgroundColor: DoctorColors.primary.withValues(alpha: 0.35),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Firmar y enviar a la paciente', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
