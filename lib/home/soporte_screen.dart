import 'package:flutter/material.dart';
import 'package:glucy_app/home/chat_screen.dart';
import 'package:glucy_app/home/suscripcion_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const tealBg = Color(0xFFDEF3EC);
  static const alertBg = Color(0xFFFBE4E1);
  static const alertText = Color(0xFFA8332A);
  static const alert = Color(0xFFE8574B);
}

class _Channel {
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback Function(BuildContext) onTap;
  const _Channel(this.icon, this.title, this.sub, this.onTap);
}

/// Centro de ayuda: deriva a chat de soporte, a suscripción, o a
/// emergencias según el motivo.
class SoporteScreen extends StatelessWidget {
  const SoporteScreen({super.key});

  static final _channels = [
    _Channel(Icons.chat_bubble_outline, 'Dudas sobre mi plan', 'Te acompaña la IA · el médico valida los cambios',
        (ctx) => () => Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const ChatScreen()))),
    _Channel(Icons.build_outlined, 'Problema con la app', 'Soporte técnico · responde en minutos',
        (ctx) => () => Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const ChatScreen()))),
    _Channel(Icons.credit_card_outlined, 'Pagos y facturación', 'Cambios de plan, cobros, comprobantes',
        (ctx) => () => Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const SuscripcionScreen()))),
  ];

  Future<void> _llamarEmergencias() async {
    final uri = Uri(scheme: 'tel', path: '911');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
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
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: GlucyColors.cardBorder)),
                      child: const Icon(Icons.arrow_back_ios_new, size: 13, color: GlucyColors.primary),
                    ),
                  ),
                  const Expanded(
                    child: Text('Necesito ayuda',
                        textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Elige el canal correcto para que te respondan más rápido.', style: TextStyle(fontSize: 12.5, height: 1.5, color: Color(0x9910262A))),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: GlucyColors.alertBg, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Urgencia médica 24/7', style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700, color: GlucyColors.alertText)),
                    const SizedBox(height: 6),
                    const Text('Vómitos, confusión, dolor en el pecho o glucosa mayor a 300 mg/dL.', style: TextStyle(fontSize: 12, height: 1.5, color: GlucyColors.alertText)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _llamarEmergencias,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlucyColors.alert,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Llamar a emergencias', style: TextStyle(fontFamily: 'Sora', fontSize: 13.5, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              for (final c in _channels) ...[
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: c.onTap(context),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(9)),
                          child: Icon(c.icon, size: 18, color: GlucyColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
                              Text(c.sub, style: const TextStyle(fontSize: 11.5, color: Color(0x8C10262A))),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 18, color: Color(0x4D10262A)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
