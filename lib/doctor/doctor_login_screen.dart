import 'package:flutter/material.dart';
import 'package:glucy_app/doctor/doctor_data.dart';
import 'package:glucy_app/doctor/doctor_otp_screen.dart';
import 'package:glucy_app/onboarding/splash_screen.dart';

/// Portal profesional: login con correo institucional, matrícula y
/// contraseña, antes de la verificación en dos pasos.
class DoctorLoginScreen extends StatelessWidget {
  const DoctorLoginScreen({super.key});

  static const _fields = [
    ('Correo institucional', 'medico@clinica.com', TextInputType.emailAddress, Icons.person_outline, false),
    ('Matrícula profesional', '45281', TextInputType.text, Icons.shield_outlined, false),
    ('Contraseña', '••••••••', TextInputType.text, Icons.shield_outlined, true),
  ];

  void _volverAPaciente(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const SplashScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(26, 46, 26, 30),
              color: DoctorColors.deep,
              child: Column(
                children: [
                  const Icon(Icons.water_drop, size: 38, color: DoctorColors.accent),
                  const SizedBox(height: 8),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontFamily: 'Sora', fontSize: 22),
                      children: [
                        TextSpan(text: 'Glucy ', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                        TextSpan(text: 'AI', style: TextStyle(fontWeight: FontWeight.w300, color: DoctorColors.accent)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Portal profesional · validación clínica', style: TextStyle(fontSize: 11.5, color: Color(0x8CF4FAF9))),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                decoration: const BoxDecoration(color: DoctorColors.bg, borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final f in _fields) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.$1, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xA610262A))),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0x380A7C86)), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                Icon(f.$4, size: 17, color: DoctorColors.primary),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: TextField(
                                    obscureText: f.$5,
                                    keyboardType: f.$3,
                                    decoration: InputDecoration(hintText: f.$2, border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 14)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DoctorOtpScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DoctorColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Ingresar', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () => _volverAPaciente(context),
                      child: const Text('Soy paciente, volver', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0x8C10262A))),
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(color: DoctorColors.tealBg, borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.shield_outlined, size: 16, color: DoctorColors.primary),
                          SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              'El acceso profesional exige verificación en dos pasos y queda registrado en la auditoría clínica.',
                              style: TextStyle(fontSize: 11.5, height: 1.5, color: DoctorColors.tealText),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
