import 'package:flutter/material.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const tealBg = Color(0xFFDEF3EC);
  static const warn = Color(0xFFB97417);
  static const warnBg = Color(0xFFFBEEDA);
  static const alert = Color(0xFFE8574B);
}

class _Sistema {
  final IconData icon;
  final String titulo;
  final String detalle;
  final String estado;
  final Color estadoBg;
  final Color estadoFg;
  const _Sistema(this.icon, this.titulo, this.detalle, this.estado, this.estadoBg, this.estadoFg);
}

class _Valor {
  final String nombre;
  final String valor;
  final Color valorColor;
  final String referencia;
  final String explicacion;
  const _Valor(this.nombre, this.valor, this.valorColor, this.referencia, this.explicacion);
}

/// Transparencia de la IA: valor por valor de los 7 estudios, con
/// referencia clínica y confianza del análisis (pantalla 12 del catálogo).
class AnalisisScreen extends StatelessWidget {
  const AnalisisScreen({super.key});

  static const _sistemas = [
    _Sistema(Icons.bloodtype_outlined, 'Glucémico', 'HbA1c 7.4 % · ayunas 158', 'Sobre meta', GlucyColors.warnBg, GlucyColors.warn),
    _Sistema(Icons.filter_alt_outlined, 'Renal', 'TFG 92 · sin proteínas en orina', 'Normal', GlucyColors.tealBg, GlucyColors.primary),
    _Sistema(Icons.local_hospital_outlined, 'Hepático', 'ALT 28 / AST 24', 'Normal', GlucyColors.tealBg, GlucyColors.primary),
    _Sistema(Icons.favorite_border, 'Lipídico', 'LDL 142 · triglicéridos 180', 'Atención', GlucyColors.warnBg, GlucyColors.warn),
    _Sistema(Icons.verified_outlined, 'Tipo de diabetes', 'Péptido C normal: descarta tipo 1', 'Confirmado', GlucyColors.tealBg, GlucyColors.primary),
  ];

  static const _valores = [
    _Valor('Glucemia en ayunas', '158 mg/dL', GlucyColors.alert, 'Referencia: 70 – 100',
        'Confirma diabetes. Es el valor que usaremos para titular la insulina basal.'),
    _Valor('HbA1c', '7.4 %', GlucyColors.warn, 'Referencia: < 5.7 %',
        'Promedio de tus últimos 3 meses. Equivale a una glucosa media de 166 mg/dL.'),
    _Valor('LDL', '142 mg/dL', GlucyColors.warn, 'Referencia: < 100',
        'El colesterol LDL alto suma riesgo cardiovascular: entra en el plan.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 20, 6),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: GlucyColors.deep),
                  ),
                  const Expanded(
                    child: Text('Detalle del análisis',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LOS 5 SISTEMAS EVALUADOS',
                        style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0x6B10262A), letterSpacing: 0.8)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          for (final s in _sistemas) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              child: Row(
                                children: [
                                  Icon(s.icon, size: 18, color: GlucyColors.primary),
                                  const SizedBox(width: 11),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(s.titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
                                        Text(s.detalle, style: const TextStyle(fontSize: 11.5, color: Color(0x8C10262A))),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(color: s.estadoBg, borderRadius: BorderRadius.circular(999)),
                                    child: Text(s.estado, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: s.estadoFg)),
                                  ),
                                ],
                              ),
                            ),
                            if (s != _sistemas.last) const Divider(height: 1, color: Color(0x0D052E33)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('VALOR POR VALOR · 7 ESTUDIOS, 34 VALORES',
                        style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0x6B10262A), letterSpacing: 0.8)),
                    const SizedBox(height: 8),
                    for (final v in _valores) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(v.nombre,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
                                ),
                                const SizedBox(width: 8),
                                Text(v.valor, style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700, color: v.valorColor)),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(v.referencia,
                                      overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: Color(0x8C10262A))),
                                ),
                                const SizedBox(width: 8),
                                Text('alto', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: v.valorColor)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(v.explicacion, style: const TextStyle(fontSize: 12, height: 1.45, color: Color(0xB310262A))),
                          ],
                        ),
                      ),
                      if (v != _valores.last) const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 16),
                    const Text('CÓMO SE HIZO ESTE ANÁLISIS',
                        style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0x6B10262A), letterSpacing: 0.8)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          _filaMeta('Estudios y respuestas', '7 estudios · 9 de 9 preguntas'),
                          const Divider(height: 1, color: Color(0x0D052E33)),
                          _filaMeta('Guías y modelo', 'ADA 2026 · ALAD · v2.4'),
                          const Divider(height: 1, color: Color(0x0D052E33)),
                          _filaMeta('Confianza del análisis', '92 %'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'La confianza baja cuando faltan valores o la foto se lee mal. Con menos de 80 %, un médico revisa antes de mostrarte nada.',
                      style: TextStyle(fontSize: 11.5, height: 1.5, color: Color(0x8010262A)),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: GlucyColors.cardBorder))),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GlucyColors.ink,
                    side: const BorderSide(color: Color(0x26052E33)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Volver a mi pre-diagnóstico', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filaMeta(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Flexible(
            flex: 4,
            child: Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, color: Color(0x9910262A))),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 5,
            child: Text(valor,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
          ),
        ],
      ),
    );
  }
}
