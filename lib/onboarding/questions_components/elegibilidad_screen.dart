import 'package:flutter/material.dart';
import 'package:glucy_app/onboarding/questions_components/prediag_screen.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const tealBg = Color(0xFFDEF3EC);
  static const tealText = Color(0xFF0A5A62);
}

class _Criterio {
  final String label;
  final String val;
  const _Criterio(this.label, this.val);
}

/// Confirma que el paciente es apto según los estudios y el filtro
/// clínico ("semáforo verde"), antes de mostrar el pre-diagnóstico.
class ElegibilidadScreen extends StatelessWidget {
  const ElegibilidadScreen({super.key});

  static const _criteria = [
    _Criterio('DM2 confirmada (HbA1c 7.4 %)', 'Sí'),
    _Criterio('Función renal (TFG 92)', '≥ 45'),
    _Criterio('Cetonas en orina', 'Negativas'),
    _Criterio('Transaminasas ALT/AST', 'Normales'),
    _Criterio('Péptido C (descarta LADA)', 'Normal'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: [
                  Text('Tu elegibilidad', style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                  SizedBox(height: 2),
                  Text('informe #48210', style: TextStyle(fontSize: 11, color: Color(0x7310262A))),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                            child: const Text('Semáforo verde', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: GlucyColors.primary)),
                          ),
                          const SizedBox(height: 9),
                          const Text('Eres apta para el programa',
                              style: TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                          const SizedBox(height: 6),
                          const Text(
                            'Diabetes tipo 2 confirmada, sin contraindicaciones para el manejo remoto.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12.5, height: 1.5, color: GlucyColors.tealText),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('CRITERIOS VERIFICADOS',
                          style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0x6B10262A), letterSpacing: 0.8)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          for (final c in _criteria) ...[
                            Row(
                              children: [
                                const Icon(Icons.check_circle_outline, size: 17, color: GlucyColors.primary),
                                const SizedBox(width: 10),
                                Expanded(child: Text(c.label, style: const TextStyle(fontSize: 12.5, color: GlucyColors.ink))),
                                Text(c.val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GlucyColors.primary)),
                              ],
                            ),
                            if (c != _criteria.last) const Divider(height: 22, color: Color(0x0D052E33)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: GlucyColors.cardBorder))),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrediagScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlucyColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Ver mi pre-diagnóstico', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
