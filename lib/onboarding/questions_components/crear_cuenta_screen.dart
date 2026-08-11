import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/rutas.dart';
import '../../app/theme/glucy_palette.dart';
import '../../core/error/fallo_api.dart';
import '../../features/auth/domain/sesion.dart';
import '../../features/auth/presentation/sesion_controller.dart';
import '../../shared/widgets/mensaje_error.dart';

/// Acceso del paciente. La identidad la gestiona Auth0: Universal Login
/// presenta correo y contrasena, Google y, cuando se active, el segundo factor.
/// La app nunca ve una contrasena.
class CrearCuentaScreen extends ConsumerWidget {
  const CrearCuentaScreen({super.key});

  void _portalMedico(BuildContext context) => context.go(Rutas.loginMedico);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Sesion> sesion = ref.watch(sesionControllerProvider);
    final cargando = sesion.isLoading;
    final fallo = sesion.error;

    return Scaffold(
      backgroundColor: GlucyPalette.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(26, 20, 26, 34),
              decoration: const BoxDecoration(color: GlucyPalette.deep),
              child: Column(
                children: [
                  const Icon(Icons.water_drop, size: 40, color: GlucyPalette.accent),
                  const SizedBox(height: 8),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontFamily: 'Sora', fontSize: 22),
                      children: [
                        TextSpan(text: 'Glucy ', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                        TextSpan(text: 'AI', style: TextStyle(fontWeight: FontWeight.w300, color: GlucyPalette.accent)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -18),
                child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                decoration: const BoxDecoration(color: GlucyPalette.bg, borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22))),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(color: GlucyPalette.tealBg, borderRadius: BorderRadius.circular(999)),
                        child: const Text('Tu pre-diagnóstico está listo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GlucyPalette.primary)),
                      ),
                      const SizedBox(height: 13),
                      const Text('Crea tu cuenta para continuar',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, height: 1.3, color: GlucyPalette.deep)),
                      const SizedBox(height: 8),
                      const Text(
                        'Guardamos tu caso en una historia clínica a tu nombre para que el médico pueda validar y firmar tu tratamiento.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, height: 1.55, color: Color(0xA610262A)),
                      ),
                      const SizedBox(height: 18),
                      if (fallo is FalloApi) ...[
                        MensajeError(fallo),
                        const SizedBox(height: 14),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          key: const Key('boton-acceder'),
                          onPressed: cargando
                              ? null
                              : () => ref.read(sesionControllerProvider.notifier).iniciarSesion(),
                          style: FilledButton.styleFrom(
                            backgroundColor: GlucyPalette.primary,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: cargando
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text(
                                  'Entrar o crear cuenta',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          key: const Key('boton-apple'),
                          // Apple Sign In se activa en el tenant de Auth0; no
                          // necesita cambios de codigo aqui.
                          onPressed: null,
                          icon: const Icon(Icons.apple, size: 20),
                          label: const Text('Continuar con Apple (proximamente)'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0x1F052E33)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(color: GlucyPalette.tealBg, borderRadius: BorderRadius.circular(12)),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lock_outline, size: 16, color: GlucyPalette.primary),
                            SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'Acceso gestionado con Auth0. Glucy AI no guarda contraseñas ni códigos.',
                                style: TextStyle(fontSize: 11.5, height: 1.5, color: GlucyPalette.tealText),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Al continuar aceptas los Términos y el Aviso de privacidad de datos de salud.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, height: 1.5, color: Color(0x7310262A)),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => _portalMedico(context),
                        child: const Text.rich(
                          TextSpan(
                            style: TextStyle(fontSize: 12.5, color: Color(0x9910262A)),
                            children: [
                              TextSpan(text: '¿Eres médico? '),
                              TextSpan(text: 'Ingresa aquí', style: TextStyle(fontWeight: FontWeight.w700, color: GlucyPalette.primary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
