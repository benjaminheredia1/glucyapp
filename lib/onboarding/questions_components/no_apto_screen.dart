import 'package:flutter/material.dart';
import 'package:glucy_app/app/router/rutas.dart';
import 'package:go_router/go_router.dart';

/// Colores del diseño Glucy AI
class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const muted = Color(0x9910262A); // rgba(16,38,42,0.6)
  static const mutedLight = Color(0x8010262A); // rgba(16,38,42,0.5)
  static const alertBg = Color(0xFFFBE4E1);
  static const alert = Color(0xFFE8574B);
}

/// Fila del recap ("Lo que ya registraste")
class NoAptoRecapItem {
  final String label;
  final String value;
  const NoAptoRecapItem(this.label, this.value);
}

/// Pantalla mostrada cuando una respuesta del filtro clínico descalifica
/// al paciente (no es urgencia, pero el manejo remoto no es seguro).
class NoAptoScreen extends StatelessWidget {
  final String reason;
  final List<NoAptoRecapItem> recap;

  const NoAptoScreen({super.key, required this.reason, required this.recap});

  // Se llega aqui por context.go(Rutas.noApto) desde el filtro clinico
  // (unica entrada real, vease glucy_router.dart), asi que esta pantalla
  // queda sola en el stack. Un Navigator.push(SplashScreen()) a mano
  // funcionaba por accidente, pero saltaba por fuera de go_router: el
  // redirect del router no se enteraba de ese cambio de pantalla. Igual que
  // en la flecha de volver, se navega con el propio router.
  void _volverAlInicio(BuildContext context) => context.go(Rutas.onboarding);

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
                    // Se llega aqui por context.go(Rutas.noApto) (unica
                    // entrada real), asi que esta pantalla queda sola en el
                    // stack: un pop() a secas lanzaria GoError('There is
                    // nothing to pop'), igual que el bug ya arreglado en
                    // clinical_filter_widget.dart.
                    onTap: () => context.canPop() ? context.pop() : context.go(Rutas.onboarding),
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
                      'Resultado del filtro',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: GlucyColors.deep,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: GlucyColors.alertBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Semáforo rojo',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: GlucyColors.alert),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Tu caso necesita manejo presencial',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: GlucyColors.deep,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Marcaste: $reason. El manejo remoto de la medicación no es seguro en esta condición.',
                style: const TextStyle(fontSize: 13, height: 1.5, color: GlucyColors.muted),
              ),
              const SizedBox(height: 16),
              const Text(
                'LO QUE YA REGISTRASTE',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0x6B10262A),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: GlucyColors.cardBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    for (final item in recap) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.label, style: const TextStyle(fontSize: 12.5, color: GlucyColors.muted)),
                          const SizedBox(width: 14),
                          Flexible(
                            child: Text(
                              item.value,
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: GlucyColors.ink),
                            ),
                          ),
                        ],
                      ),
                      if (item != recap.last) const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Queda guardado en tu cuenta. Si tu situación cambia, puedes retomar el filtro desde aquí.',
                style: TextStyle(fontSize: 11.5, height: 1.5, color: GlucyColors.mutedLight),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _volverAlInicio(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GlucyColors.ink,
                    side: const BorderSide(color: Color(0x26052E33)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Volver al inicio',
                    style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
