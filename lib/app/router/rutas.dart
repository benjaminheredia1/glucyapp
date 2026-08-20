/// Paths de la app en un solo sitio, para que nadie escriba '/login' a mano.
abstract final class Rutas {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const perfil = '/tu-perfil';
  static const filtroClinico = '/filtro-clinico';
  static const estudios = '/estudios';
  static const noApto = '/no-apto';
  static const urgencia = '/urgencia';
  static const crearCuenta = '/crear-cuenta';
  static const login = '/login';
  static const loginMedico = '/portal-medico/login';
  static const inicioPaciente = '/inicio';
  static const inicioMedico = '/portal-medico';

  /// Alcanzables sin sesion. El embudo de precalificacion corre antes de que
  /// exista la cuenta, asi que no puede exigirla.
  static const publicas = {
    splash,
    onboarding,
    perfil,
    filtroClinico,
    estudios,
    noApto,
    urgencia,
    crearCuenta,
    login,
    loginMedico,
  };
}
