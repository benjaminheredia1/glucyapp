import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router/rutas.dart';
import '../app/theme/glucy_palette.dart';
import '../core/error/fallo_api.dart';
import '../features/auth/presentation/sesion_controller.dart';
import '../shared/widgets/mensaje_error.dart';

/// Portal profesional: la identidad la gestiona Auth0, igual que para el
/// paciente. Universal Login pide correo institucional y contrasena en el
/// navegador del sistema; la app nunca ve una contrasena.
class DoctorLoginScreen extends ConsumerWidget {
  const DoctorLoginScreen({super.key});

  void _volverAPaciente(BuildContext context) => context.go(Rutas.onboarding);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesion = ref.watch(sesionControllerProvider);
    final cargando = sesion.isLoading;
    final fallo = sesion.error;

    return Scaffold(
      backgroundColor: GlucyPalette.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(26, 46, 26, 30),
              color: GlucyPalette.deep,
              child: Column(
                children: [
                  const Icon(Icons.water_drop, size: 38, color: GlucyPalette.accent),
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
                  const SizedBox(height: 6),
                  const Text('Portal profesional · validación clínica', style: TextStyle(fontSize: 11.5, color: Color(0x8CF4FAF9))),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                decoration: const BoxDecoration(color: GlucyPalette.bg, borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: GlucyPalette.tealBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lock_outline, size: 16, color: GlucyPalette.primary),
                          SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              'El acceso profesional se valida con tu cuenta institucional. '
                              'Se abrira en el navegador seguro del sistema.',
                              style: TextStyle(fontSize: 11.5, height: 1.5, color: GlucyPalette.tealText),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (fallo is FalloApi) ...[
                      MensajeError(fallo),
                      const SizedBox(height: 14),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const Key('boton-acceder-medico'),
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
                                'Entrar al portal profesional',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () => _volverAPaciente(context),
                      child: const Text('Soy paciente, volver', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0x8C10262A))),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
