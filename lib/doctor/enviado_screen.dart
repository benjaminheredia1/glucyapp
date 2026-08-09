import 'package:flutter/material.dart';
import 'package:glucy_app/doctor/caso_screen.dart';
import 'package:glucy_app/doctor/doctor_data.dart';

/// Confirmación de envío del plan firmado, con acceso directo al
/// siguiente caso de la bandeja.
class EnviadoScreen extends StatelessWidget {
  final CaseItem item;
  const EnviadoScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final remaining = doctorCases.length - 1;
    return Scaffold(
      backgroundColor: DoctorColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: DoctorColors.tealBg, shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 30, color: DoctorColors.primary),
                  ),
                  const SizedBox(height: 11),
                  const Text('Tratamiento enviado', style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                  const SizedBox(height: 6),
                  Text('${item.name} recibió una notificación con el plan aprobado por ti.',
                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0x9910262A))),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tiempo de validación', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: DoctorColors.ink)),
                        Text('Meta del convenio: 12 h', style: TextStyle(fontSize: 11, color: Color(0x8C10262A))),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('3 h 12 min', style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: DoctorColors.primary)),
                        Text('Dentro de meta', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: DoctorColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quedan $remaining casos en tu bandeja', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: DoctorColors.ink)),
                        const Text('1 urgente · 2 pendientes · 2 estables', style: TextStyle(fontSize: 11, color: Color(0x8C10262A))),
                      ],
                    ),
                    const Icon(Icons.chevron_right, size: 18, color: Color(0x4D10262A)),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => CasoScreen(item: caseById(2)))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DoctorColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Siguiente caso', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                style: OutlinedButton.styleFrom(foregroundColor: DoctorColors.ink, side: const BorderSide(color: Color(0x26052E33)), padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Volver a la bandeja', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
