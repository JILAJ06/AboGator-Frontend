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

  /// Tramo del mapa dentro del Inicio (ruta anidada: el Inicio queda debajo
  /// en la pila y "atrás" vuelve a él).
  static const String segmentoMapa = 'modulo/:moduloId';

  /// Tramo de la intro dentro del mapa (ruta anidada).
  static const String segmentoIntro = 'sprint/:sprintId';

  /// 08 Mapa de sprints del módulo
  static const String mapaSprints = '$inicio/$segmentoMapa';

  /// 09 Intro del sprint
  static const String introSprint = '$mapaSprints/$segmentoIntro';

  /// Ruta concreta del mapa de sprints de un módulo.
  static String mapaSprintsDe(String moduloId) => '/inicio/modulo/$moduloId';

  /// Ruta concreta de la intro de un sprint.
  static String introSprintDe(String moduloId, String sprintId) =>
      '/inicio/modulo/$moduloId/sprint/$sprintId';

  /// 21 Buzón de Apelaciones
  static const String buzon = '/buzon';

  /// 22 Juicio de una apelación, `/buzon/:apelacionId` (enlace profundo de la
  /// notificación 21b).
  static String juicioApelacionDe(String apelacionId) =>
      '/buzon/${Uri.encodeComponent(apelacionId)}';

  /// 24 Tienda
  static const String tienda = '/tienda';

  /// 25 Perfil y progreso
  static const String perfil = '/perfil';

  /// Tramos hijos del Perfil (rutas anidadas: atrás vuelve al Perfil).
  static const String segmentoAjustes = 'ajustes';
  static const String segmentoNotificaciones = 'notificaciones';

  /// 26 / 26b Ajustes de accesibilidad (T-10b), sin navegación inferior.
  static const String ajustes = '$perfil/$segmentoAjustes';

  /// 34 Notificaciones de racha (T-13b): "Ajustes → Notificaciones" (con
  /// push), desde el Perfil y tras el registro. Es de primer nivel: abrirla
  /// directo solo construye esta página (sin Perfil ni Ajustes debajo).
  static const String notificacionesRacha = '/ajustes/$segmentoNotificaciones';

  /// Parámetro de [notificacionesRacha] cuando se abre tras el registro: al
  /// cerrar va al Inicio en lugar de regresar.
  static const String desdeRegistro = 'desde=registro';

  // T-13b · Recuperar contraseña (31 a 31e), sin sesión.
  static const String recuperar = '/recuperar';
  static const String segmentoEnviado = 'enviado';
  static const String segmentoNueva = 'nueva';
  static const String segmentoListo = 'listo';
  static const String segmentoCaducado = 'caducado';
  static const String recuperarEnviado = '$recuperar/$segmentoEnviado';
  static const String recuperarNueva = '$recuperar/$segmentoNueva';
  static const String recuperarListo = '$recuperar/$segmentoListo';
  static const String recuperarCaducado = '$recuperar/$segmentoCaducado';

  /// 31c con el token del enlace (`?token=…`).
  static String recuperarNuevaCon(String token) =>
      '$recuperarNueva?token=${Uri.encodeQueryComponent(token)}';

  // T-13b · Aviso de Privacidad (32) y Términos de uso (33), sin sesión.
  static const String legalAviso = '/legal/aviso';
  static const String legalTerminos = '/legal/terminos';

  // Flujo 3 · Juego
  /// 10–18, 10b, 10c: tarjetas, veredictos, evidencia y comodines.
  static const String juego = '/juego/:sprintId';

  /// Ruta concreta del juego de un sprint.
  static String juegoDe(String sprintId) => '/juego/$sprintId';

  /// 19 Sprint completado
  static const String sprintCompletado = '/juego/:sprintId/completado';

  /// Ruta concreta de "Sprint completado" de un sprint.
  static String sprintCompletadoDe(String sprintId) => '/juego/$sprintId/completado';

  /// 19b Startup en quiebra
  static const String startupQuiebra = '/juego/:sprintId/quiebra';

  /// Ruta concreta de "Startup en quiebra" de un sprint.
  static String startupQuiebraDe(String sprintId) => '/juego/$sprintId/quiebra';

  // Flujo 4 · Vidas y conexión
  /// 20 Sin vidas. El parámetro `modulo` dice a qué mapa volver. (23 Sin
  /// conexión no es una ruta: es un estado de la pantalla de juego.)
  static const String sinVidas = '/sin-vidas';

  /// "Sin vidas" que vuelve al mapa de [moduloId] (o al Inicio si es `null`).
  static String sinVidasDe(String? moduloId) =>
      moduloId == null ? sinVidas : '$sinVidas?modulo=${Uri.encodeQueryComponent(moduloId)}';

  // Flujo 5 · Nivel Jefe
  /// 27 Crisis: ransomware (28, 28b y 28c ocurren dentro de esta ruta)
  static const String crisisJefe = '/jefe/:moduloId';

  /// Ruta concreta del Examen final (Nivel Jefe) de un módulo.
  static String crisisJefeDe(String moduloId) => '/jefe/$moduloId';

  /// 29 Auditoría superada (certificado)
  static const String auditoriaSuperada = '/jefe/:moduloId/superada';

  /// 30 La Inspectora ganó
  static const String inspectoraGano = '/jefe/:moduloId/derrota';

  /// Tramos hijos del Examen Final (29 y 30).
  static const String segmentoAuditoriaSuperada = 'superada';
  static const String segmentoInspectoraGano = 'derrota';

  /// 29 de un módulo.
  static String auditoriaSuperadaDe(String moduloId) => '/jefe/$moduloId/superada';

  /// 30 de un módulo.
  static String inspectoraGanoDe(String moduloId) => '/jefe/$moduloId/derrota';
}
