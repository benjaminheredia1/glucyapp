import 'package:flutter/material.dart';
import 'package:glucy_app/doctor/doctor_data.dart';
import 'package:glucy_app/doctor/historial_doctor_screen.dart';

class _Msg {
  final bool doc;
  final String text;
  final String time;
  const _Msg(this.doc, this.text, this.time);
}

/// Mensajería asíncrona del médico con la paciente, con respuestas
/// rápidas predefinidas.
class ChatDoctorScreen extends StatefulWidget {
  final CaseItem item;
  const ChatDoctorScreen({super.key, required this.item});

  @override
  State<ChatDoctorScreen> createState() => _ChatDoctorScreenState();
}

class _ChatDoctorScreenState extends State<ChatDoctorScreen> {
  final _controller = TextEditingController();
  final List<_Msg> _messages = [
    const _Msg(false, 'Doctora, ayer marqué 168 en ayunas. ¿Debo cambiar algo?', '08:22'),
    const _Msg(true, 'Buenos días María. No cambie la dosis por su cuenta. Registre hoy y mañana y lo evaluamos en el ciclo.', '08:40'),
    const _Msg(false, 'Entendido. La metformina me cae mal en el desayuno.', '08:44'),
  ];

  static const _quickReplies = ['Tómela con alimentos', 'Registre y la reviso hoy', 'Suba el estudio pendiente'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final t = (text ?? _controller.text).trim();
    if (t.isEmpty) return;
    setState(() {
      _messages.add(_Msg(true, t, '09:05'));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: DoctorColors.cardBorder))),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(color: DoctorColors.bg, shape: BoxShape.circle, border: Border.all(color: DoctorColors.cardBorder)),
                      child: const Icon(Icons.arrow_back_ios_new, size: 12, color: DoctorColors.primary),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: DoctorColors.tealBg, shape: BoxShape.circle),
                    child: Text(widget.item.initials, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w700, color: DoctorColors.primary)),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DoctorColors.deep)),
                        const Text('DM2 · caso #48210', style: TextStyle(fontSize: 11, color: Color(0x8010262A))),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => HistorialDoctorScreen(item: widget.item))),
                    style: OutlinedButton.styleFrom(foregroundColor: DoctorColors.primary, side: const BorderSide(color: Color(0x400A7C86)), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7)),
                    child: const Text('Historial', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              color: DoctorColors.warnBg,
              child: const Text('Mensajería asíncrona · no sustituye una urgencia. Todo queda en la auditoría clínica.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF8A5510))),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(14),
                itemCount: _messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 9),
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  return Column(
                    crossAxisAlignment: m.doc ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                          decoration: BoxDecoration(color: m.doc ? DoctorColors.primary : Colors.white, borderRadius: BorderRadius.circular(15)),
                          child: Text(m.text, style: TextStyle(fontSize: 13, height: 1.45, color: m.doc ? Colors.white : DoctorColors.ink)),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(m.time, style: const TextStyle(fontSize: 10, color: Color(0x6610262A))),
                    ],
                  );
                },
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: _quickReplies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 7),
                itemBuilder: (context, i) => OutlinedButton(
                  onPressed: () => _send(_quickReplies[i]),
                  style: OutlinedButton.styleFrom(foregroundColor: DoctorColors.primary, side: const BorderSide(color: Color(0x4D0A7C86)), padding: const EdgeInsets.symmetric(horizontal: 12)),
                  child: Text(_quickReplies[i], style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 22),
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: DoctorColors.cardBorder))),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Escribe a tu paciente…',
                        filled: true,
                        fillColor: DoctorColors.bg,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: DoctorColors.cardBorder)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: DoctorColors.cardBorder)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _send(),
                    borderRadius: BorderRadius.circular(19),
                    child: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: DoctorColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.send, size: 15, color: Colors.white),
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
