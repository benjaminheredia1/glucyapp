import 'package:flutter/material.dart';
import 'package:glucy_app/onboarding/questions_components/procesando_screen.dart';

/// Colores del diseño Glucy AI
class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const muted = Color(0x8010262A); // rgba(16,38,42,0.5)
  static const tealBg = Color(0xFFDEF3EC);
  static const tealText = Color(0xFF0A5A62);
}

/// Pantalla para agendar toma de muestra a domicilio, reutilizada desde
/// "Estudios requeridos" y desde "Subir estudio".
class LabDomicilioScreen extends StatefulWidget {
  const LabDomicilioScreen({super.key});

  @override
  State<LabDomicilioScreen> createState() => _LabDomicilioScreenState();
}

class _LabDomicilioScreenState extends State<LabDomicilioScreen> {
  String _slot = 'manana';

  static const _slots = [
    (key: 'manana', label: 'Mañana 8–11'),
    (key: 'tarde', label: 'Tarde 15–18'),
    (key: 'sabado', label: 'Sábado 9–12'),
  ];

  static const _items = ['Perfil lipídico', 'Examen de orina', 'Transaminasas'];

  void _agendar() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProcesandoScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: GlucyColors.cardBorder),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 13, color: GlucyColors.primary),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Laboratorio a domicilio',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Sora', fontSize: 18, fontWeight: FontWeight.w700, color: GlucyColors.deep),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.home_outlined, size: 20, color: GlucyColors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Un laboratorio aliado va a tu casa: te toman la muestra y suben el resultado directo a tu historia.',
                        style: TextStyle(fontSize: 12.5, height: 1.5, color: GlucyColors.tealText),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: GlucyColors.cardBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estudios a tomar', style: TextStyle(fontFamily: 'Sora', fontSize: 12.5, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                    const SizedBox(height: 10),
                    for (final item in _items) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item, style: const TextStyle(fontSize: 13, color: GlucyColors.ink)),
                          const Text('incluido', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    const Divider(height: 1, color: GlucyColors.cardBorder),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text('Total', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
                        Text('18 USD', style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Precio de convenio. Se paga al laboratorio, no a Glucy AI.',
                      style: TextStyle(fontSize: 11, color: GlucyColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: GlucyColors.cardBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Elige el horario', style: TextStyle(fontFamily: 'Sora', fontSize: 12.5, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        for (final s in _slots)
                          InkWell(
                            borderRadius: BorderRadius.circular(9),
                            onTap: () => setState(() => _slot = s.key),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                              decoration: BoxDecoration(
                                color: _slot == s.key ? GlucyColors.primary : GlucyColors.bg,
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(color: _slot == s.key ? GlucyColors.primary : GlucyColors.cardBorder),
                              ),
                              child: Text(
                                s.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _slot == s.key ? Colors.white : GlucyColors.ink,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _agendar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlucyColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Agendar visita', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
