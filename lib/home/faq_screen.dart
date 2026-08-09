import 'package:flutter/material.dart';
import 'package:glucy_app/home/faq_articulo_screen.dart';
import 'package:glucy_app/home/patient_tabbar.dart';
import 'package:glucy_app/home/soporte_screen.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
}

/// Centro de ayuda con buscador y categorías; las preguntas más
/// consultadas llevan al artículo correspondiente.
class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  String _query = '';
  String _cat = 'Todo';

  static const _cats = ['Todo', 'Elegibilidad', 'Estudios', 'Dosis', 'Pagos'];
  static const _all = [
    '¿Por qué debo subir un estudio cada 3 mediciones?',
    '¿Cómo aplico y guardo la insulina Lantus?',
    '¿Qué pasa cuando terminan mis 12 días de prueba?',
    '¿Qué hago si mi estudio fue rechazado?',
    '¿Puedo cambiar de médico?',
  ];

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final items = _all.where((f) => q.isEmpty || f.toLowerCase().contains(q)).toList();

    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ayuda', style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                  const Text('Resuelve en segundos, sin esperar a nadie', style: TextStyle(fontSize: 12, color: Color(0x8010262A))),
                  const SizedBox(height: 11),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0x1A052E33)), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 18, color: Color(0x6610262A)),
                        const SizedBox(width: 9),
                        Expanded(
                          child: TextField(
                            onChanged: (v) => setState(() => _query = v),
                            decoration: const InputDecoration(hintText: 'Buscar en la ayuda…', border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final c in _cats)
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => setState(() => _cat = c),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(color: _cat == c ? GlucyColors.primary : Colors.white, borderRadius: BorderRadius.circular(999)),
                            child: Text(c, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _cat == c ? Colors.white : GlucyColors.ink)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                children: [
                  const Text('LAS MÁS CONSULTADAS', style: TextStyle(fontFamily: 'Sora', fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0x6B10262A), letterSpacing: 0.6)),
                  const SizedBox(height: 8),
                  for (final f in items) ...[
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FaqArticuloScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Expanded(child: Text(f, style: const TextStyle(fontSize: 12.5, height: 1.4, fontWeight: FontWeight.w500, color: GlucyColors.ink))),
                            const Icon(Icons.chevron_right, size: 18, color: Color(0x4D10262A)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SoporteScreen())),
                    style: OutlinedButton.styleFrom(foregroundColor: GlucyColors.primary, side: const BorderSide(color: Color(0x4D0A7C86)), padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('No encontré mi respuesta', style: TextStyle(fontFamily: 'Sora', fontSize: 13.5, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const PatientTabBar(current: PatientTab.faq),
          ],
        ),
      ),
    );
  }
}
