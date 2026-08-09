import 'package:flutter/material.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const tealBg = Color(0xFFDEF3EC);
  static const warnBg = Color(0xFFFBEEDA);
}

class _Pref {
  final String title;
  final String sub;
  bool on;
  _Pref(this.title, this.sub, this.on);
}

/// Datos personales y preferencias de notificación de la cuenta.
class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _nombre = TextEditingController(text: 'María Torres');
  final _telefono = TextEditingController(text: '+51 987 654 321');
  final _nacimiento = TextEditingController(text: '14/03/1968');
  final _sexo = TextEditingController(text: 'Femenino');
  final _talla = TextEditingController(text: '162');
  final _peso = TextEditingController(text: '74');

  final List<_Pref> _prefs = [
    _Pref('Recordatorios de medicación', 'Aviso 10 min antes de cada toma', true),
    _Pref('Avisos de validación médica', 'Cuando tu médica firma un ajuste', true),
    _Pref('Novedades de Glucy AI', 'Contenido educativo y mejoras', false),
  ];

  @override
  void dispose() {
    for (final c in [_nombre, _telefono, _nacimiento, _sexo, _talla, _peso]) {
      c.dispose();
    }
    super.dispose();
  }

  void _guardar() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
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
                    child: Text('Editar perfil',
                        textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(color: GlucyColors.tealBg, shape: BoxShape.circle),
                          child: const Text('MT', style: TextStyle(fontFamily: 'Sora', fontSize: 24, fontWeight: FontWeight.w700, color: GlucyColors.primary)),
                        ),
                        const SizedBox(height: 9),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(foregroundColor: GlucyColors.primary, side: const BorderSide(color: Color(0x4D0A7C86)), padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7)),
                          child: const Text('Cambiar foto', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        children: [
                          _field('Nombre completo', _nombre),
                          const SizedBox(height: 12),
                          _field('Teléfono móvil', _telefono),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _field('Nacimiento', _nacimiento)),
                              const SizedBox(width: 12),
                              Expanded(child: _field('Sexo', _sexo)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _field('Talla (cm)', _talla)),
                              const SizedBox(width: 12),
                              Expanded(child: _field('Peso (kg)', _peso)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PREFERENCIAS', style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0x6B10262A), letterSpacing: 0.7)),
                          const SizedBox(height: 10),
                          for (final p in _prefs) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
                                      Text(p.sub, style: const TextStyle(fontSize: 11, color: Color(0x8010262A))),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: p.on,
                                  activeTrackColor: GlucyColors.primary,
                                  onChanged: (v) => setState(() => p.on = v),
                                ),
                              ],
                            ),
                            if (p != _prefs.last) const SizedBox(height: 4),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(color: GlucyColors.warnBg, borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFB97417)),
                          SizedBox(width: 9),
                          Expanded(
                            child: Text('Peso y talla afectan tu plan. Al guardarlos, tu médica revisa el cambio en la próxima validación.',
                                style: TextStyle(fontSize: 11.5, height: 1.5, color: Color(0xFF8A5510))),
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
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: GlucyColors.cardBorder))),
              child: ElevatedButton(
                onPressed: _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlucyColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Guardar cambios', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0x8010262A))),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: GlucyColors.ink),
          decoration: InputDecoration(
            filled: true,
            fillColor: GlucyColors.bg,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0x17052E33))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0x17052E33))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: GlucyColors.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }
}
