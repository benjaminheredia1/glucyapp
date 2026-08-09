import 'package:flutter/material.dart';
import 'package:glucy_app/doctor/doctor_data.dart';
import 'package:glucy_app/doctor/inbox_screen.dart';

/// Verificación en dos pasos exigida para el acceso profesional. Al
/// completarse, limpia el stack: la Bandeja pasa a ser la raíz de
/// navegación del portal médico.
class DoctorOtpScreen extends StatefulWidget {
  const DoctorOtpScreen({super.key});

  @override
  State<DoctorOtpScreen> createState() => _DoctorOtpScreenState();
}

class _DoctorOtpScreenState extends State<DoctorOtpScreen> {
  String _otp = '';

  void _tap(String key) {
    setState(() {
      if (key == '⌫') {
        _otp = _otp.isEmpty ? _otp : _otp.substring(0, _otp.length - 1);
      } else if (key.isNotEmpty && _otp.length < 6) {
        _otp += key;
      }
    });
  }

  void _submit() {
    if (_otp.length != 6) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const InboxScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final full = _otp.length == 6;
    return Scaffold(
      backgroundColor: DoctorColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
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
                    child: Text('Verificación en dos pasos',
                        textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 18, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 14),
              Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: DoctorColors.tealBg, shape: BoxShape.circle),
                    child: const Icon(Icons.shield_outlined, size: 26, color: DoctorColors.primary),
                  ),
                  const SizedBox(height: 10),
                  const Text.rich(
                    TextSpan(style: TextStyle(fontSize: 12.5, height: 1.5, color: Color(0x9E10262A)), children: [
                      TextSpan(text: 'Enviamos un código de 6 dígitos al '),
                      TextSpan(text: '+51 ··· 4821', style: TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: ', el número registrado en tu matrícula profesional.'),
                    ]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 6; i++) ...[
                    Container(
                      width: 44,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i < _otp.length ? Colors.white : DoctorColors.bg,
                        border: Border.all(color: i == _otp.length ? DoctorColors.primary : (i < _otp.length ? const Color(0x590A7C86) : const Color(0x1A052E33)), width: 1.5),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(i < _otp.length ? _otp[i] : '', style: const TextStyle(fontFamily: 'Sora', fontSize: 22, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                    ),
                    if (i != 5) const SizedBox(width: 8),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(full ? 'Código completo' : 'Ingresa los 6 dígitos',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: full ? DoctorColors.primary : const Color(0x7310262A))),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.7,
                children: [
                  for (final k in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'])
                    k.isEmpty
                        ? const SizedBox()
                        : InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _tap(k),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                              child: Text(k, style: const TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w600, color: DoctorColors.deep)),
                            ),
                          ),
                ],
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: full ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: full ? DoctorColors.primary : DoctorColors.primary.withValues(alpha: 0.35),
                  disabledBackgroundColor: DoctorColors.primary.withValues(alpha: 0.35),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Verificar e ingresar', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 10),
              const Text.rich(
                TextSpan(style: TextStyle(fontSize: 11.5, color: Color(0x8010262A)), children: [
                  TextSpan(text: '¿No te llegó? '),
                  TextSpan(text: 'Reenviar en 0:42', style: TextStyle(fontWeight: FontWeight.w700, color: DoctorColors.primary)),
                ]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
