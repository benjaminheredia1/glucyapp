import 'package:flutter/material.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const tealBg = Color(0xFFDEF3EC);
  static const tealText = Color(0xFF0A5A62);
}

class _Msg {
  final bool me;
  final String text;
  final String time;
  const _Msg(this.me, this.text, this.time);
}

/// Chat de soporte técnico, con contexto del caso precargado (como en el
/// diseño: "estudio rechazado").
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final List<_Msg> _messages = [
    const _Msg(false, 'Hola María. Veo que tu estudio de transaminasas fue rechazado por falta de fecha. ¿Quieres que te ayude a subirlo de nuevo?', '09:41'),
    const _Msg(true, 'Sí, ya tengo la hoja completa.', '09:42'),
    const _Msg(false, 'Perfecto. Abre el estudio marcado en rojo y toca «Volver a subir». Yo lo reviso en el momento.', '09:42'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(true, text, '09:44'));
      _controller.clear();
    });
  }

  void _attach() {
    setState(() => _messages.add(const _Msg(true, '📎 Foto del estudio adjuntada', '09:44')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: GlucyColors.cardBorder))),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(color: GlucyColors.bg, shape: BoxShape.circle, border: Border.all(color: GlucyColors.cardBorder)),
                      child: const Icon(Icons.arrow_back_ios_new, size: 12, color: GlucyColors.primary),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: GlucyColors.tealBg, shape: BoxShape.circle),
                    child: const Text('LM', style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w700, color: GlucyColors.primary)),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lucía · soporte técnico', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: GlucyColors.deep)),
                        Text('En línea', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GlucyColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              color: GlucyColors.tealBg,
              child: const Text('Contexto recibido: estudio rechazado · caso #48210', style: TextStyle(fontSize: 11.5, color: GlucyColors.tealText)),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(14),
                itemCount: _messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 9),
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  return Column(
                    crossAxisAlignment: m.me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                          decoration: BoxDecoration(color: m.me ? GlucyColors.primary : Colors.white, borderRadius: BorderRadius.circular(15)),
                          child: Text(m.text, style: TextStyle(fontSize: 13, height: 1.45, color: m.me ? Colors.white : GlucyColors.ink)),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(m.time, style: const TextStyle(fontSize: 10, color: Color(0x6610262A))),
                    ],
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 22),
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: GlucyColors.cardBorder))),
              child: Row(
                children: [
                  InkWell(
                    onTap: _attach,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0x4D0A7C86))),
                      child: const Icon(Icons.attach_file, size: 16, color: GlucyColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Escribe tu mensaje…',
                        filled: true,
                        fillColor: GlucyColors.bg,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: GlucyColors.cardBorder)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: GlucyColors.cardBorder)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _send,
                    borderRadius: BorderRadius.circular(19),
                    child: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: GlucyColors.primary, shape: BoxShape.circle),
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
