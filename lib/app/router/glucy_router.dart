import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../doctor/dash_screen.dart';
import '../../doctor/doctor_login_screen.dart';
import '../../features/auth/domain/rol.dart';
import '../../features/auth/domain/sesion.dart';
import '../../features/auth/presentation/sesion_controller.dart';
import '../../features/precalificacion/domain/veredicto.dart';
import '../../home/home_screen.dart';
import '../../onboarding/onboarding_screen.dart';
import '../../onboarding/questions_components/clinical_filter_widget.dart';
import '../../onboarding/questions_components/crear_cuenta_screen.dart';
import '../../onboarding/questions_components/no_apto_screen.dart';
import '../../onboarding/splash_screen.dart';
import '../../warning/warning.dart';
import 'rutas.dart';

/// Reevalua las redirecciones cada vez que cambia la sesion.
class _NotificadorSesion extends ChangeNotifier {
  _NotificadorSesion(Ref ref) {
    ref.listen(sesionControllerProvider, (_, __) => notifyListeners());
  }
}

final glucyRouterProvider = Provider<GoRouter>((ref) {
  final notificador = _NotificadorSesion(ref);
  ref.onDispose(notificador.dispose);

  return GoRouter(
    initialLocation: Rutas.splash,
    refreshListenable: notificador,
    routes: [
      GoRoute(path: Rutas.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: Rutas.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: Rutas.crearCuenta, builder: (_, __) => const CrearCuentaScreen()),
      GoRoute(path: Rutas.login, builder: (_, __) => const CrearCuentaScreen()),
      GoRoute(path: Rutas.loginMedico, builder: (_, __) => const DoctorLoginScreen()),
      GoRoute(path: Rutas.inicioPaciente, builder: (_, __) => const HomeScreen()),
      GoRoute(path: Rutas.inicioMedico, builder: (_, __) => const DashScreen()),
      GoRoute(
        path: Rutas.filtroClinico,
        builder: (context, estado) => ClinicalFilterScreen(
          onVeredicto: (veredicto) => switch (veredicto.resultado) {
            Resultado.apto => context.go(Rutas.crearCuenta),
            Resultado.urgente => context.go(Rutas.urgencia),
            Resultado.noApto => context.go(
                Rutas.noApto,
                extra: veredicto.motivo ?? 'tu respuesta al filtro clinico',
              ),
          },
        ),
      ),
      GoRoute(path: Rutas.urgencia, builder: (_, _) => const UrgencyScreen()),
      GoRoute(
        path: Rutas.noApto,
        builder: (context, estado) => NoAptoScreen(
          // El motivo lo redacta el backend, en `preguntas_precalificacion.motivo`.
          reason: estado.extra as String? ?? 'tu respuesta al filtro clinico',
          recap: const [],
        ),
      ),
    ],
    redirect: (context, estado) {
      final sesion = ref.read(sesionControllerProvider);

      // Mientras se restaura la sesion, el splash se queda donde esta.
      if (sesion.isLoading) {
        return estado.matchedLocation == Rutas.splash ? null : Rutas.splash;
      }

      final destino = estado.matchedLocation;
      // Riverpod 3 renombro `valueOrNull` a `value` (ya nullable en la clase
      // base `AsyncValue`); `valueOrNull` no existe en esta version.
      final actual = sesion.value ?? const Sesion.noAutenticado();

      return switch (actual) {
        SesionNoAutenticado() => Rutas.publicas.contains(destino)
            ? (destino == Rutas.splash ? Rutas.onboarding : null)
            : Rutas.login,
        SesionAutenticado(:final usuario) => _destinoAutenticado(usuario.rol, destino),
      };
    },
  );
});

String? _destinoAutenticado(Rol rol, String destino) {
  final inicio = rol == Rol.paciente ? Rutas.inicioPaciente : Rutas.inicioMedico;

  // Ya dentro, las pantallas del embudo y de acceso no tienen sentido.
  if (Rutas.publicas.contains(destino)) {
    return inicio;
  }

  // Un rol no entra en el area del otro. La autorizacion real la hace el
  // backend; esto solo evita enseñar una pantalla que devolveria 403.
  final esAreaMedica = destino.startsWith('/portal-medico');

  if (esAreaMedica && rol == Rol.paciente) return Rutas.inicioPaciente;
  if (!esAreaMedica && rol != Rol.paciente) return Rutas.inicioMedico;

  return null;
}
