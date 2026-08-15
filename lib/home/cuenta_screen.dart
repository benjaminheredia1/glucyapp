import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucy_app/features/auth/domain/sesion.dart';
import 'package:glucy_app/features/auth/domain/usuario.dart';
import 'package:glucy_app/features/auth/presentation/sesion_controller.dart';
import 'package:glucy_app/home/editar_perfil_screen.dart';
import 'package:glucy_app/home/faq_screen.dart';
import 'package:glucy_app/home/patient_tabbar.dart';
import 'package:glucy_app/home/suscripcion_screen.dart';
import 'package:glucy_app/onboarding/questions_components/checkout_screen.dart';
import 'package:glucy_app/onboarding/questions_components/elegibilidad_screen.dart';
import 'package:glucy_app/onboarding/questions_components/estudios_screen.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const tealBg = Color(0xFFDEF3EC);
}

class _Row {
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback Function(BuildContext) onTap;
  const _Row(this.icon, this.title, this.sub, this.onTap);
}

/// Cuenta del paciente: accesos a perfil, suscripción, elegibilidad,
/// estudios y ayuda, más el cierre de sesión.
class CuentaScreen extends ConsumerWidget {
  const CuentaScreen({super.key});

  static final _rows = [
    _Row(Icons.person_outline, 'Editar perfil', 'Datos personales y preferencias',
        (ctx) => () => Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const EditarPerfilScreen()))),
    _Row(Icons.credit_card_outlined, 'Mi suscripción', 'Prueba gratis · primer cobro el 9 de agosto',
        (ctx) => () => Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const SuscripcionScreen()))),
    _Row(Icons.description_outlined, 'Mi elegibilidad', 'Semáforo verde · 25 de julio',
        (ctx) => () => Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const ElegibilidadScreen()))),
    _Row(Icons.apartment_outlined, 'Clínica vinculada', 'Clínica San Rafael', (ctx) => () {}),
    _Row(Icons.qr_code_2_outlined, 'Iniciar tratamiento', '12 días de prueba · pago por QR',
        (ctx) => () => Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const CheckoutScreen()))),
    _Row(Icons.science_outlined, 'Mis estudios', '4 de 6 al día',
        (ctx) => () => Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const EstudiosScreen()))),
    _Row(Icons.help_outline, 'Ayuda y soporte', 'Preguntas frecuentes y contacto',
        (ctx) => () => Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const FaqScreen()))),
  ];

  // No navega a mano: en cuanto `cerrarSesion()` deja el estado en
  // `noAutenticado`, el redirect de `glucyRouterProvider` saca de aqui solo,
  // igual que en `crear_cuenta_screen.dart`/`doctor_login_screen.dart` con
  // `iniciarSesion()`. Verificado con un doble de router: el redirect
  // reemplaza incluso una pantalla llegada por `Navigator.pushReplacement`
  // (como esta, vease `patient_tabbar.dart`), asi que no hace falta un
  // `Navigator.pushAndRemoveUntil` de respaldo.
  void _cerrarSesion(WidgetRef ref) {
    ref.read(sesionControllerProvider.notifier).cerrarSesion();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = switch (ref.watch(sesionControllerProvider).value) {
      SesionAutenticado(:final usuario) => usuario,
      _ => null,
    };

    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Mi cuenta', style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(color: GlucyColors.tealBg, shape: BoxShape.circle),
                            child: Text(usuario?.iniciales ?? '?',
                                style: const TextStyle(fontFamily: 'Sora', fontSize: 17, fontWeight: FontWeight.w700, color: GlucyColors.primary)),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(usuario?.nombreCompleto ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                                Text(usuario?.email ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: Color(0x8C10262A))),
                                const SizedBox(height: 5),
                                if (usuario?.emailVerificadoEn != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(999)),
                                    child: const Text('Verificado', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: GlucyColors.primary)),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (final r in _rows)
                            InkWell(
                              onTap: r.onTap(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(border: Border(bottom: r == _rows.last ? BorderSide.none : const BorderSide(color: Color(0x0D052E33)))),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(9)),
                                      child: Icon(r.icon, size: 17, color: GlucyColors.primary),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(r.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
                                          Text(r.sub, style: const TextStyle(fontSize: 11.5, color: Color(0x8C10262A))),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, size: 18, color: Color(0x4D10262A)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    OutlinedButton(
                      key: const Key('boton-cerrar-sesion'),
                      onPressed: () => _cerrarSesion(ref),
                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xB310262A), side: const BorderSide(color: Color(0x26052E33)), padding: const EdgeInsets.symmetric(vertical: 13)),
                      child: const Text('Cerrar sesión', style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
            const PatientTabBar(current: PatientTab.cuenta),
          ],
        ),
      ),
    );
  }
}
