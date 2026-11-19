/// Rutas de la app según el inventario de `ai/conocimiento/03-pantallas.md`.
///
/// Desde T-02 la app arranca en [splash]. Las demás se declaran para que
/// cada tarea las implemente sin cambiar los nombres.
abstract final class Rutas {
  /// Raíz: redirige al Splash.
  static const String raiz = '/';

  /// Galería de componentes (solo en modo debug).
  static const String galeria = '/galeria';

  // Flujo 1 · Bienvenida y acceso
  /// 01 Splash
  static const String splash = '/splash';

  /// 02, 03, 03b y 04 Onboarding (un solo paginador).
  static const String onboarding = '/onboarding';

  /// 05 Inicio de sesión
  static const String inicioSesion = '/inicio-sesion';

  /// 06 Registro
  static const String registro = '/registro';

  // Flujo 2 · Navegación principal
  /// 07 / 07b Inicio (mapa de módulos)
  static const String inicio = '/inicio';

  /// 08 Mapa de sprints del módulo
  static const String mapaSprints = '/inicio/modulo/:moduloId';

  /// 09 Intro del sprint
  static const String introSprint = '/inicio/modulo/:moduloId/sprint/:sprintId';

  /// Ruta concreta del mapa de sprints de un módulo.
  static String mapaSprintsDe(String moduloId) => '/inicio/modulo/$moduloId';

  /// Ruta concreta de la intro de un sprint.
  static String introSprintDe(String moduloId, String sprintId) =>
      '/inicio/modulo/$moduloId/sprint/$sprintId';

  /// 21 Buzón de Apelaciones
  static const String buzon = '/buzon';

  /// 22 Juicio de apelación (21b la notificación abre esta ruta)
  static const String juicioApelacion = '/buzon/:apelacionId';

  /// 24 Tienda
  static const String tienda = '/tienda';

  /// 25 Perfil y progreso
  static const String perfil = '/perfil';

  /// 26 / 26b Ajustes de accesibilidad
  static const String ajustes = '/perfil/ajustes';

  // Flujo 3 · Juego
  /// 10–18, 10b, 10c: tarjetas, veredictos, evidencia y comodines.
  static const String juego = '/juego/:sprintId';

  /// 19 Sprint completado
  static const String sprintCompletado = '/juego/:sprintId/completado';

  /// 19b Startup en quiebra
  static const String startupQuiebra = '/juego/:sprintId/quiebra';

  // Flujo 4 · Vidas y conexión
  /// 20 Sin vidas
  static const String sinVidas = '/sin-vidas';

  /// 23 Sin conexión
  static const String sinConexion = '/sin-conexion';

  // Flujo 5 · Nivel Jefe
  /// 27 Crisis: ransomware (28, 28b y 28c ocurren dentro de esta ruta)
  static const String crisisJefe = '/jefe/:moduloId';

  /// 29 Auditoría superada (certificado)
  static const String auditoriaSuperada = '/jefe/:moduloId/superada';

  /// 30 La Inspectora ganó
  static const String inspectoraGano = '/jefe/:moduloId/derrota';
}
