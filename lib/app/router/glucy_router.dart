import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../doctor/dash_screen.dart';
import '../../doctor/doctor_login_screen.dart';
import '../../features/auth/domain/rol.dart';
import '../../features/auth/domain/sesion.dart';
import '../../features/auth/domain/usuario.dart';
import '../../features/auth/presentation/sesion_controller.dart';
import '../../features/precalificacion/data/embudo_store.dart';
import '../../features/precalificacion/domain/veredicto.dart';
import '../../home/home_screen.dart';
import '../../onboarding/onboarding_screen.dart';
import '../../onboarding/questions_components/clinical_filter_widget.dart';
import '../../onboarding/questions_components/crear_cuenta_screen.dart';
import '../../onboarding/questions_components/estudios_screen.dart';
import '../../onboarding/questions_components/filtro1_screen.dart';
import '../../onboarding/questions_components/no_apto_screen.dart';
import '../../onboarding/splash_screen.dart';
import '../../profile/profile.dart';
import '../../warning/warning.dart';
import 'rutas.dart';

/// Etapa del embudo guardada en el dispositivo. Se relee en cada cambio de
/// sesion (el `watch` de abajo): cerrar sesion la borra del storage y aqui no
/// puede quedar un valor viejo que mande a un anonimo nuevo a los estudios.
final etapaEmbudoProvider = FutureProvider<String?>((ref) {
  ref.watch(sesionControllerProvider);

  return ref.watch(embudoStoreProvider).leerEtapa();
});

/// Reevalua las redirecciones cada vez que cambia la sesion o se conoce la
/// etapa guardada del embudo.
class _NotificadorSesion extends ChangeNotifier {
  _NotificadorSesion(Ref ref) {
    ref.listen(sesionControllerProvider, (_, __) => notifyListeners());
    ref.listen(etapaEmbudoProvider, (_, __) => notifyListeners());
  }
}

final glucyRouterProvider = Provider<GoRouter>((ref) {
  final notificador = _NotificadorSesion(ref);
  ref.onDispose(notificador.dispose);

  return GoRouter(
    initialLocation: Rutas.splash,
    refreshListenable: notificador,
    // Deja que la burbuja de Chucker abra su pantalla de inspeccion sobre el
    // navigator raiz. En release no hace nada (showOnRelease=false).
    navigatorKey: ChuckerFlutter.navigatorKey,
    routes: [
      GoRoute(path: Rutas.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: Rutas.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: Rutas.perfil, builder: (_, __) => const Profile()),
      GoRoute(path: Rutas.estudios, builder: (_, __) => const EstudiosScreen()),
      GoRoute(path: Rutas.crearCuenta, builder: (_, __) => const CrearCuentaScreen()),
      GoRoute(path: Rutas.login, builder: (_, __) => const CrearCuentaScreen()),
      GoRoute(path: Rutas.loginMedico, builder: (_, __) => const DoctorLoginScreen()),
      GoRoute(path: Rutas.inicioPaciente, builder: (_, __) => const HomeScreen()),
      GoRoute(path: Rutas.inicioMedico, builder: (_, __) => const DashScreen()),
      GoRoute(
        path: Rutas.filtroClinico,
        builder: (context, estado) => ClinicalFilterScreen(
          onVeredicto: (veredicto) => switch (veredicto.resultado) {
            // Apto sigue a "Filtro 1 OK" y de ahi al embudo de estudios
            // (Filtro1Screen -> EstudiosScreen -> ... -> PrediagScreen), que
            // ya encadena con Navigator.push y termina en CrearCuentaScreen.
            // La cuenta se crea despues del pre-diagnostico, no aqui.
            Resultado.apto => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const Filtro1Screen()),
              ),
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

      // Solo el arranque en frio (cargando y sin ningun valor previo) manda
      // al splash. `iniciarSesion()`/`cerrarSesion()` tambien ponen
      // `AsyncLoading` mientras dura el viaje a Universal Login, pero ahi
      // `hasValue` se mantiene en true (Riverpod conserva el dato anterior):
      // sacar de la pantalla de login en ese momento dejaria el spinner y el
      // `MensajeError` de la Task 13/14 inalcanzables, porque `ref.listen` es
      // sincrono y este redirect se reevalua en cada cambio de estado, antes
      // de que Auth0 llegue a abrirse.
      if (sesion.isLoading && !sesion.hasValue) {
        return estado.matchedLocation == Rutas.splash ? null : Rutas.splash;
      }

      final destino = estado.matchedLocation;
      // Riverpod 3 renombro `valueOrNull` a `value` (ya nullable en la clase
      // base `AsyncValue`); `valueOrNull` no existe en esta version.
      final actual = sesion.value ?? const Sesion.noAutenticado();

      // null mientras carga o si no hay nada guardado: en ambos casos el
      // embudo empieza del principio.
      final etapa = ref.read(etapaEmbudoProvider).value;

      return switch (actual) {
        SesionNoAutenticado() => Rutas.publicas.contains(destino)
            ? (destino == Rutas.splash ? Rutas.onboarding : null)
            : Rutas.login,
        SesionAutenticado(:final usuario) => _destinoAutenticado(usuario, destino, etapa),
      };
    },
  );
});

String? _destinoAutenticado(Usuario usuario, String destino, String? etapa) {
  // Identidad temporal (POST /auth/anonimo): vive en el embudo, que son las
  // rutas publicas. Inicio y portal medico son de cuenta real; si cae ahi,
  // vuelve al principio del embudo.
  if (usuario.esTemporal) {
    // Progreso cacheado: quien ya llego a la subida de estudios no repite
    // perfil ni filtro al reabrir la app; el arranque salta directo ahi.
    final arranque = destino == Rutas.splash || destino == Rutas.onboarding;

    if (arranque && etapa == EmbudoStore.etapaEstudios) {
      return Rutas.estudios;
    }

    if (Rutas.publicas.contains(destino)) {
      return destino == Rutas.splash ? Rutas.onboarding : null;
    }

    return Rutas.onboarding;
  }

  final rol = usuario.rol;
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
