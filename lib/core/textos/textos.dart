/// Textos visibles de la interfaz, centralizados para poder corregirlos
/// o traducirlos en un solo lugar. Español de México.
abstract final class Textos {
  static const String nombreApp = 'AboGator';

  // ---------------------------------------------------------------------
  // Componentes
  // ---------------------------------------------------------------------

  // Campo de texto
  static const String mostrarContrasena = 'Mostrar contraseña';
  static const String ocultarContrasena = 'Ocultar contraseña';

  // Chip HUD
  static String chipVidas(int cantidad, int maximo) => 'Vidas: $cantidad de $maximo';
  static String chipMonedas(int cantidad) => cantidad == 1 ? '1 moneda' : '$cantidad monedas';
  static String chipRacha(int dias) => dias == 1 ? 'Racha de 1 día' : 'Racha de $dias días';
  static String chipComodines(int cantidad) => cantidad == 1 ? '1 comodín' : '$cantidad comodines';
  static String chipAmparo(int cantidad) => cantidad == 1 ? '1 amparo' : '$cantidad amparos';

  // Vidas
  static String filaVidas(int cantidad, int maximo) => 'Vidas: $cantidad de $maximo';

  // Indicadores de la Startup
  static const String indicadorPresupuesto = 'Presupuesto';
  static const String indicadorReputacion = 'Reputación';
  static const String indicadorVelocidad = 'Velocidad';
  static const String indicadorRiesgoLegal = 'Riesgo legal';
  static String indicadorValor(String nombre, int valor) => '$nombre $valor %';
  static const String impacto = 'Impacto:';
  static String impactoValor(int cambio) => cambio > 0 ? '+$cambio' : '−${cambio.abs()}';
  static String impactoSemantica(String nombre, int cambio) => '$nombre ${impactoValor(cambio)}';

  // Navegación inferior (en Figma la primera pestaña se llama "Mapa").
  static const String pestanaMapa = 'Mapa';
  static const String pestanaBuzon = 'Buzón';
  static const String pestanaTienda = 'Tienda';
  static const String pestanaPerfil = 'Perfil';
  static String pestanaSemantica(String nombre, int posicion, int total) =>
      'Pestaña $nombre, $posicion de $total';

  // Riel de navegación (tablet)
  static const String rielNavegacion = 'Navegación principal';
  static const String rielAjustes = 'Ajustes de accesibilidad';
  static String rielAvatar(String? nombre) =>
      nombre == null || nombre.isEmpty ? 'Tu perfil' : 'Perfil de $nombre';
  static String rielInsignia(int cantidad) => cantidad > 99 ? '99+' : '$cantidad';
  static String rielBuzonSemantica(int pendientes) => pendientes <= 0
      ? pestanaBuzon
      : pendientes == 1
      ? '$pestanaBuzon, 1 apelación pendiente'
      : '$pestanaBuzon, $pendientes apelaciones pendientes';

  // Paginador
  static String paginador(int actual, int total) => 'Página $actual de $total';

  // Sarko (texto alternativo de cada pose)
  static const String sarkoAlegre = 'Sarko, cocodrilo juez, celebra con el mazo en alto';
  static const String sarkoEnojado = 'Sarko, cocodrilo juez, enojado, levanta el mazo con el puño';
  static const String sarkoSorprendido =
      'Sarko, cocodrilo juez, sorprendido, con los ojos muy abiertos y el mazo en la mano';
  static const String sarkoTriste = 'Sarko, cocodrilo juez, triste, llora con el mazo abajo';
  static const String sarkoNoDisponible = 'Imagen de Sarko no disponible';

  // Logo
  static const String logo = 'AboGator';

  // Botón de regreso
  static const String atras = 'Atrás';

  // Botón de veredicto
  static const String veredictoLegal = 'LEGAL';
  static const String veredictoIlegal = 'ILEGAL';
  static const String veredictoCondicional = 'CONDICIONAL';
  static const String veredictoEscalar = 'ESCALAR';
  static const String veredictoSemanticaLegal = 'Veredicto: Legal';
  static const String veredictoSemanticaIlegal = 'Veredicto: Ilegal';
  static const String veredictoSemanticaCondicional = 'Veredicto: Legal con condiciones';
  static const String veredictoSemanticaEscalar = 'Veredicto: Escalar al área jurídica';

  // ---------------------------------------------------------------------
  // 01 Splash
  // ---------------------------------------------------------------------
  static const String splashLema = 'Educación en Legislación\ny Derecho Informático';
  static const String splashPoweredBy = 'Powered by LawSwipe';
  static const String splashSemantica =
      'AboGator. Educación en Legislación y Derecho Informático. Cargando.';

  // ---------------------------------------------------------------------
  // 02–04 Onboarding
  // ---------------------------------------------------------------------
  static const String onboardingOmitir = 'Omitir';
  static const String onboardingSiguiente = 'Siguiente';
  static const String onboardingComenzar = '¡Comenzar!';

  static const String onboarding1Titulo = '¡Hola! Soy Sarko';
  static const String onboarding1Texto =
      'Tu juez mentor. Te ayudaré a dominar las leyes de TI sin leer códigos de 300 páginas.';

  static const String onboarding2Titulo = 'Desliza en 4 direcciones';
  static const String onboarding2Texto =
      '→ Legal · ← Ilegal · ↑ Legal con condiciones · ↓ Escalar a jurídico. También puedes '
      'tocar los botones; todo funciona con lector de pantalla.';

  static const String onboarding3Titulo = 'Tu Startup depende de ti';
  static const String onboarding3Texto =
      'Cada decisión mueve el Presupuesto, la Reputación, la Velocidad y el Riesgo legal. Si el '
      'riesgo llega al 100% o te quedas sin dinero, la empresa quiebra.';

  static const String onboarding4Titulo = 'Cuida tus 5 vidas';
  static const String onboarding4Texto =
      'Cada error resta una vida (se regenera 1 cada 2 horas). Tus fallos vuelven como '
      'apelaciones a los 3 y 7 días: gánalas y recupera vidas.';
  static const String onboarding4Monedas = '+5';
  static const String onboarding4Racha = '7 días';

  // Miniatura de tarjeta de caso (pantalla 03, decorativa)
  static const String casoEtiqueta = 'CASO 4 · LICENCIAS OSS';
  static const String casoIniciales = 'DJ';
  static const String casoPersona = 'Dev Junior';
  static const String casoEquipo = 'Equipo de Backend';
  static const String casoPregunta =
      'Encontré una librería GPL-3.0 que resuelve el login. ¿La copio tal cual en nuestra app '
      'de código cerrado y la publicamos?';
  static const String casoPistaIlegal = '←  ILEGAL';
  static const String casoPistaLegal = 'LEGAL  →';
  static const String casoPistaBotones = 'Elige con los botones';
  static const String casoPistaCondicional = '↑ CONDICIONAL';
  static const String casoPistaEscalar = '↓ ESCALAR';

  // ---------------------------------------------------------------------
  // Validaciones de acceso (mensajes exactos del diseño)
  // ---------------------------------------------------------------------
  static const String errorNombre = 'Ingresa tu nombre';
  static const String errorCorreo = 'Ingresa un correo válido';
  static const String errorContrasenaVacia = 'Ingresa tu contraseña';
  static const String errorContrasenaRegistro = 'Mínimo 8 caracteres, incluye un número';
  static const String errorPerfil = 'Elige tu perfil';
  static const String errorAvisoPrivacidad = 'Debes aceptar el Aviso de Privacidad para continuar';
  static const String errorTerminos = 'Debes aceptar los Términos de uso para continuar';

  // ---------------------------------------------------------------------
  // 05 Inicio de sesión
  // ---------------------------------------------------------------------
  static const String inicioSesionTitulo = 'Bienvenido\nde vuelta';
  static const String inicioSesionSubtitulo = 'Continúa tu racha de 7 días';
  static const String campoCorreoInicio = 'Correo electrónico';
  static const String campoContrasenaInicio = 'Contraseña';
  static const String olvidasteContrasena = '¿Olvidaste tu contraseña?';
  static const String recuperacionPronto = 'La recuperación de contraseña estará disponible pronto';
  static const String botonIniciarSesion = 'Iniciar sesión';
  static const String iniciandoSesion = 'Iniciando sesión';
  static const String separadorO = 'o';
  static const String botonCrearUnaCuenta = 'Crear una cuenta';
  static const String notaSeguridad = 'Conexión cifrada (TLS 1.2+) · Autenticación JWT';

  // ---------------------------------------------------------------------
  // 06 Registro
  // ---------------------------------------------------------------------
  static const String registroTitulo = 'Crea tu cuenta';
  static const String registroSubtitulo = 'Elige tu perfil para ajustar el ritmo de los sprints.';

  // Panel de marca de tablet (T05 y T06)
  static const String lemaUnaLinea = 'Educación en Legislación y Derecho Informático';
  static const String registroPanelFrase = '«Más vale prevenir que litigar.»';
  static const String registroPanelTexto =
      'Crea tu perfil y Sarko ajustará la dificultad de cada sprint a tu experiencia.';
  static const String perfilEstudiante = 'Estudiante';
  static const String perfilDesarrollador = 'Desarrollador';
  static const String perfilLegal = 'Legal';
  static const String perfilEstudianteVisible = '🎓 Estudiante';
  static const String perfilDesarrolladorVisible = '💻 Desarrollador';
  static const String perfilLegalVisible = '⚖️ Legal';
  static String perfilSemantica(String perfil, int posicion, int total) =>
      'Perfil $perfil, $posicion de $total';
  static const String campoNombreRegistro = 'Nombre';
  static const String aceptoAvisoPrivacidad = 'He leído y acepto el Aviso de Privacidad.';
  static const String aceptoTerminos = 'He leído y acepto los Términos de uso.';
  static const String botonCrearCuenta = 'Crear cuenta';
  static const String creandoCuenta = 'Creando tu cuenta';
  static const String yaTienesCuenta = '¿Ya tienes cuenta? Inicia sesión';

  // ---------------------------------------------------------------------
  // 07 Inicio
  // ---------------------------------------------------------------------
  static String saludo(String primerNombre) => 'Hola, $primerNombre';
  static String perfilYNivel(String perfil, int nivel) => '$perfil · Nivel $nivel';
  static const String perfilCortoEstudiante = 'Estudiante';
  static const String perfilCortoDesarrollador = 'Dev';
  static const String perfilCortoLegal = 'Legal';

  static const String heroeEtiqueta = 'TU STARTUP ESTÁ EN';
  static String heroeSubtitulo(int sprint, int total, String modulo) =>
      'Sprint $sprint de $total · $modulo';
  static const String continuarSprint = 'Continuar sprint';

  static const String retoTitulo = 'Reto diario: 3 tarjetas sin fallar';
  static String retoSubtitulo(int racha, int monedas) =>
      'Mantén tu racha de $racha días · +$monedas monedas';
  static String retoProgreso(int actual, int total) => '$actual/$total';
  static String retoSemantica(int actual, int total) => 'Progreso: $actual de $total';

  static const String rutaStartup = 'Ruta de tu Startup';

  /// Nombre corto de cada módulo (etiqueta de la tarjeta, como en Figma).
  static const List<String> modulosCortos = [
    'Protección de datos',
    'Licencias open source',
    'Delitos informáticos',
    'Contratos digitales',
    'Auditoría y cumplimiento',
  ];

  /// Tramo de la Startup que representa cada módulo (título de la tarjeta).
  static const List<String> tramosStartup = [
    'Del Garage al MVP',
    'Ronda Semilla',
    'Escalando el equipo',
    'Serie A',
    'Salida a bolsa',
  ];

  static String moduloEtiqueta(int numero, String nombreCorto) =>
      'MÓDULO $numero · ${nombreCorto.toUpperCase()}';
  static String sprintsProgreso(int completados, int total) => '$completados/$total sprints';
  static String sprintsCompletado(int total) => '$total/$total sprints · Completado';
  static const String moduloBloqueadoAyuda = 'Completa el módulo anterior';
  static const String estadoModuloBloqueado = 'bloqueado';
  static const String estadoModuloDisponible = 'disponible';
  static const String estadoModuloEnCurso = 'en curso';
  static const String estadoModuloCompletado = 'completado';
  static String moduloSemantica(int numero, String nombre, String titulo, String estado) =>
      'Módulo $numero, $nombre, $titulo, $estado';
  static String sprintsSemantica(int completados, int total) =>
      '$completados de $total sprints completados';

  static const String buzonApelaciones = 'Buzón de apelaciones';
  static String buzonSemantica(int pendientes) => pendientes == 0
      ? buzonApelaciones
      : pendientes == 1
      ? '$buzonApelaciones, 1 pendiente'
      : '$buzonApelaciones, $pendientes pendientes';

  // 07 Inicio en tablet (T07 y T07b)
  static const String semanaTitulo = 'Tu semana';
  static const String semanaRacha = 'Racha';
  static const String semanaPrecision = 'Precisión';
  static const String semanaMonedas = 'Monedas';
  static const String semanaSinDato = '—';
  static const String semanaSinDatoSemantica = 'sin datos';
  static String semanaDias(int dias) => dias == 1 ? '1 día' : '$dias días';
  static String semanaPorcentaje(int porcentaje) => '$porcentaje%';
  static String semanaEstadistica(String etiqueta, String valor) => '$etiqueta: $valor';

  static String buzonInicioTexto(int pendientes) => pendientes == 1
      ? '1 tarjeta fallada espera juicio. Gánala para recuperar una vida.'
      : '$pendientes tarjetas falladas esperan juicio. Gánalas para recuperar vidas.';
  static const String buzonInicioVacio = 'No tienes apelaciones pendientes.';
  static String abrirBuzon(int pendientes) => 'Abrir Buzón ($pendientes)';

  static const String consejoEtiqueta = 'CONSEJO DE SARKO';
  static String consejoSprint(int sprint, String desbloqueo) =>
      'Termina el Sprint $sprint hoy y desbloquea $desbloqueo.';
  static const String consejoGeneral = '¡Tu Startup va por buen camino! Sigue practicando.';

  static const String consejoExamenFinal = 'el Examen final';

  static const String inicioErrorCarga = 'No pudimos cargar tu progreso.';
  static const String reintentar = 'Reintentar';
  static const String cargandoInicio = 'Cargando tu progreso';

  // ---------------------------------------------------------------------
  // 08 Mapa de sprints
  // ---------------------------------------------------------------------
  static String sprintNumero(int numero) => 'Sprint $numero';
  static const String examenFinal = 'Examen final';
  static String avanceModulo(int completados, int total) => '$completados/$total';
  static String avanceModuloSemantica(int completados, int total) =>
      'Avance del módulo: $completados de $total sprints completados';
  static const String estadoSprintCompletado = 'completado';
  static const String estadoSprintActual = 'en curso';
  static const String estadoSprintDisponible = 'disponible';
  static const String estadoSprintBloqueado = 'bloqueado';
  static String estrellasSemantica(int estrellas, int maximo) => '$estrellas de $maximo estrellas';
  static String seleccionSprint(String nombre, String titulo, String estado, {int? estrellas}) {
    final estadoMayuscula = estado.isEmpty ? estado : estado[0].toUpperCase() + estado.substring(1);
    final conEstrellas = estrellas == null
        ? ''
        : estrellas == 1
        ? ', 1 estrella'
        : ', $estrellas estrellas';
    return '$nombre, $titulo. $estadoMayuscula$conEstrellas.';
  }

  static String nodoSemantica(String nombre, String titulo, String estado) =>
      '$nombre, $titulo, $estado';
  static String globoTitulo(int numero, String titulo) => 'Sprint $numero · $titulo';
  static String globoDetalle(int tarjetas, int minutos) =>
      '${tarjetasCantidad(tarjetas)} · ≈ $minutos min';
  static const String comenzar = 'Comenzar';
  static const String cargandoMapa = 'Cargando el mapa del módulo';
  static const String mapaErrorCarga = 'No pudimos cargar el mapa del módulo.';
  static const String moduloNoEncontrado = 'No encontramos ese módulo.';
  static const String volverAlInicio = 'Volver al inicio';

  // ---------------------------------------------------------------------
  // 09 Intro del sprint
  // ---------------------------------------------------------------------
  static const String cerrar = 'Cerrar';
  static String introEtiqueta(int sprint, int modulo) => 'SPRINT $sprint · MÓDULO $modulo';
  static String introEtiquetaExamen(int modulo) => 'EXAMEN FINAL · MÓDULO $modulo';
  static String introObjetivo(String objetivo) => 'Objetivo: $objetivo';
  static String tarjetasCantidad(int n) => n == 1 ? '1 tarjeta' : '$n tarjetas';
  static String tarjetasDesglose(int normales, int conEvidencia, int dilemas) => [
    normales == 1 ? '1 normal' : '$normales normales',
    '$conEvidencia con evidencia',
    dilemas == 1 ? '1 dilema' : '$dilemas dilemas',
  ].join(' · ');
  static String monedasHasta(int monedas) =>
      monedas == 1 ? 'Hasta 1 moneda' : 'Hasta $monedas monedas';
  static const String monedasDilema = 'Dilema clave acertado = monedas ×2';
  static const String indicadoresTitulo = '4 indicadores de tu Startup';
  static const String indicadoresLista = 'Presupuesto, Reputación, Velocidad y Riesgo legal';
  static const String comenzarSprint = 'Comenzar sprint';
  static const String sprintBloqueado =
      'Este sprint está bloqueado. Completa los sprints anteriores para desbloquearlo.';
  static const String cargandoIntro = 'Cargando el sprint';
  static const String introErrorCarga = 'No pudimos cargar el sprint.';
  static const String volverAlMapa = 'Volver al mapa';

  // ---------------------------------------------------------------------
  // 10 Juego: tarjeta swipe (11, 11b, 11c y 13 son estados de arrastre)
  // ---------------------------------------------------------------------
  static const String salir = 'Salir';
  static String juegoPaso(int sprint, int actual, int total) =>
      'Sprint $sprint · Tarjeta $actual de $total';
  static String tarjetaSemantica(
    int actual,
    int total,
    String personaje,
    String rol,
    String texto,
  ) => 'Tarjeta $actual de $total. $personaje, $rol: $texto';

  /// Agrega el tipo especial de la tarjeta, si tiene, a [base].
  static String tarjetaConTipoSemantica(String base, String? tipo) =>
      tipo == null ? base : '$base ($tipo)';
  static String casoSemantica(String personaje, String rol, String texto) =>
      '$personaje, $rol: $texto';
  static const String selloLegal = 'LEGAL';
  static const String selloIlegal = 'ILEGAL';
  static const String selloCondicional = 'CON CONDICIONES';
  static const String selloEscalar = 'A JURÍDICO';
  static const String accionLegal = 'Legal';
  static const String accionIlegal = 'Ilegal';
  static const String accionCondicional = 'Legal con condiciones';
  static const String accionEscalar = 'Escalar a jurídico';
  static const String comodinLupa = 'Lupa';
  static const String comodinAbogado = 'Abogado';
  static const String comodinAmparo = 'Amparo';
  static String comodinCantidad(String nombre, int cantidad) => '$nombre ×$cantidad';
  static String comodinSemantica(String nombre, int cantidad) =>
      cantidad == 1 ? '$nombre, 1 disponible' : '$nombre, $cantidad disponibles';
  static const String comodinesTitulo = 'Comodines';

  // ---------------------------------------------------------------------
  // T-07b Comodines: barra, 10b Lupa de Auditor y 10c Abogado Senior
  // ---------------------------------------------------------------------
  static const String comodinActivo = 'activa';
  static const String comodinNoDisponible = 'no disponible';
  static const String amparoArmado = 'Amparo armado: tu próximo error no te quita vida';
  static const String amparoDesarmado = 'Amparo desarmado';
  static String comodinEstadoSemantica(String base, String? estado) =>
      estado == null ? base : '$base; $estado';
  static String comodinQuedan(String nombre, int cantidad) => '$nombre, quedan $cantidad';
  static const String lupaActiva = 'Lupa de Auditor: palabras trampa resaltadas';
  static String palabrasTrampaSemantica(List<String> palabras) =>
      palabras.map((p) => 'palabra trampa: $p').join('; ');
  static const String abogadoTitulo = 'Consulta al Abogado Senior';
  static const String abogadoSubtitulo = 'El caso, sin ruido y en términos legales';
  static const String abogadoPregunta = 'Lo que realmente se pregunta';
  static const String normaAplicable = 'NORMA APLICABLE';
  static const String volverALaTarjeta = 'Volver a la tarjeta';
  static const String indicadoresSemantica = 'Indicadores de la Startup';
  static const String salirTitulo = '¿Salir del sprint?';
  static const String salirTexto = 'Perderás el avance de este sprint.';
  static const String seguirJugando = 'Seguir jugando';
  static const String cargandoJuego = 'Cargando el sprint';
  static const String juegoErrorCarga = 'No pudimos cargar las tarjetas del sprint.';
  static const String sprintSinTarjetas = 'Este sprint todavía no tiene tarjetas.';

  // ---------------------------------------------------------------------
  // 20 Sin vidas
  // ---------------------------------------------------------------------
  static const String sinVidasTitulo = 'Te quedaste sin vidas';
  static const String proximaVidaEn = 'Próxima vida en';
  static const String vidaRecuperada = '¡Recuperaste una vida!';
  static const String notaVidasServidor = '1 vida cada 2 horas · tiempo controlado por el servidor';
  static const String mientrasTantoRepasa = 'Mientras tanto, repasa';
  static String apelacionesPendientesSugerencia(int n) => n == 1
      ? '1 apelación pendiente: si la ganas te devuelve 1 vida.'
      : '$n apelaciones pendientes: cada una que ganes te devuelve 1 vida.';

  /// "Próxima vida en 1 hora y 47 minutos" (se actualiza por minuto).
  static String proximaVidaSemantica(Duration falta) {
    final horas = falta.inHours;
    final minutos = falta.inMinutes % 60;
    if (horas == 0 && minutos == 0) return 'Próxima vida en menos de un minuto';
    String unidad(int n, String singular, String plural) => '$n ${n == 1 ? singular : plural}';
    final partes = [
      if (horas > 0) unidad(horas, 'hora', 'horas'),
      if (minutos > 0) unidad(minutos, 'minuto', 'minutos'),
    ];
    return 'Próxima vida en ${partes.join(' y ')}';
  }

  // ---------------------------------------------------------------------
  // 23 Sin conexión (estado de la pantalla de juego)
  // ---------------------------------------------------------------------
  static const String conexionInestable = 'Conexión inestable. Se guardará tu progreso localmente.';
  static const String conexionRestablecida =
      'Conexión restablecida. Se está sincronizando tu progreso.';
  static String respuestasGuardadas(int n) => n == 1
      ? '1 respuesta guardada en el dispositivo (SQLite)'
      : '$n respuestas guardadas en el dispositivo (SQLite)';
  static String respuestasGuardadasSemantica(int n) => n == 1
      ? '1 respuesta guardada en el dispositivo, pendiente de sincronizar'
      : '$n respuestas guardadas en el dispositivo, pendientes de sincronizar';
  static const String simularSinConexion = 'Simular sin conexión';
  static String veredictoAnuncio(String accion) => 'Veredicto: $accion';

  // ---------------------------------------------------------------------
  // 12, 12b, 12c, 14 y 14b Panel de veredicto
  // ---------------------------------------------------------------------
  static const String veredictoCorrectoTitulo = '¡Veredicto correcto!';
  static const String bonusGanadoTitulo = '¡Bonus ganado!';
  static const String respuestaParcialTitulo = 'Respuesta parcial';
  static const String veredictoIncorrectoTitulo = 'Veredicto incorrecto';
  static const String amparoTitulo = '¡El Amparo te protegió!';
  static String correctoSubtitulo(int xp, int monedas) =>
      '+$xp XP  ·  ${monedas == 1 ? '+1 moneda' : '+$monedas monedas'}';
  static String bonusSubtitulo(int xp, int monedas) =>
      '+$xp XP en total  ·  ${monedas == 1 ? '+1 moneda' : '+$monedas monedas'}';
  static String parcialSubtitulo(int xp) => '+$xp XP  ·  no pierdes vida';
  static const String incorrectoSubtitulo = '−1 vida  ·  Se guarda en tu Buzón de Apelaciones';
  static const String amparoSubtitulo = 'Veredicto incorrecto · conservas tu vida';
  static const String porQue = '¿Por qué?';
  static String bonusPregunta(int xp, String enunciado) => 'Bonus +$xp XP: $enunciado';
  static const String saltarBonus = 'Saltar bonus';
  static const String continuar = 'Continuar';
  static const String entendido = 'Entendido';
  static const String sinCambios = 'sin cambios';
  static String impactoAnuncio(List<String> cambios) =>
      'Impacto: ${cambios.isEmpty ? sinCambios : cambios.join(', ')}';
  static String panelAnuncio(String titulo, String subtitulo, String impacto) =>
      '$titulo. ${subtitulo.replaceAll('  ', ' ')}. $impacto';
  static String opcionSemantica(String opcion, int posicion, int total) =>
      'Opción $posicion de $total: $opcion';
  static const String seleccionada = 'seleccionada';
  static const String noSeleccionada = 'no seleccionada';
  static String opcionSeleccionSemantica(
    String opcion,
    int posicion,
    int total, {
    required bool seleccionada,
  }) =>
      '${opcionSemantica(opcion, posicion, total)}; '
      '${seleccionada ? Textos.seleccionada : noSeleccionada}';

  // ---------------------------------------------------------------------
  // 15, 16 y 16b Tarjeta con evidencia y visor
  // ---------------------------------------------------------------------
  static const String tipoEvidencia = 'Evidencia';
  static const String inspeccionarEvidencia = 'Toca la tarjeta para inspeccionar';
  static const String accionInspeccionar = 'Inspeccionar evidencia';
  static const String conEvidenciaSemantica = 'con evidencia por inspeccionar';
  static const String evidenciaInspeccionadaSemantica = 'evidencia ya inspeccionada';
  static const String inspeccionaTitulo = 'Inspecciona la evidencia';
  static const String inspeccionaInstruccion =
      'Subraya con el dedo la línea que viola la ley antes de deslizar. Busca casillas '
      'pre-marcadas, datos excesivos o avisos faltantes.';
  static const String marcaUnaLinea = 'Marca una línea para continuar';
  static const String lineaMarcadaTitulo = 'Línea marcada';
  static const String lineaEquivocadaTitulo = 'Esa no es la línea clave';
  static const String evidenciaCorrectaBonus = 'Evidencia correcta: +5 XP al acertar el veredicto';
  static const String volverYDecidir = 'Volver y decidir';
  static const String marcada = 'marcada';
  static const String noMarcada = 'no marcada';
  static const String lineaClave = 'línea clave';
  static String lineaSemantica(
    int numero,
    String texto, {
    required bool marcada,
    bool clave = false,
  }) =>
      'Línea $numero: ${texto.trim().isEmpty ? 'vacía' : texto.trim()}; '
      '${marcada ? Textos.marcada : noMarcada}${clave ? '; $lineaClave' : ''}';
  static String snippetSemantica(String archivo, int lineas) => 'Archivo $archivo, $lineas líneas';

  // ---------------------------------------------------------------------
  // 17 Tarjeta de dilema y 18 Justificar veredicto
  // ---------------------------------------------------------------------
  static const String tipoDilema = 'Dilema ×2';
  static const String dilemaSemantica = 'dilema: tendrás que justificar tu veredicto';
  static const String avisoDilema =
      'Después de deslizar tendrás que justificar tu veredicto. Acertar ambas partes = '
      'monedas dobles.';
  static String dictaste(String veredicto) => 'Dictaste: $veredicto';
  static const String porQueIlegal = '¿Por qué es ilegal?';
  static const String porQueLegal = '¿Por qué es legal?';
  static const String porQueCondicional = '¿Por qué es legal con condiciones?';
  static const String porQueEscalar = '¿Por qué escalar a jurídico?';
  static const String justificacionSubtitulo =
      'Elige la justificación correcta para ganar monedas dobles.';
  static const String confirmarJustificacion = 'Confirmar justificación';
  static String justificacionAnuncio(String veredicto, String pregunta) =>
      'Dictaste $veredicto. $pregunta';

  // ---------------------------------------------------------------------
  // 19 Sprint completado y 19b Startup en quiebra
  // ---------------------------------------------------------------------
  static const String sprintCompletadoTitulo = '¡Sprint completado!';
  static const String sprintCompletadoGenerico = 'Terminaste todas las tarjetas del sprint.';
  static const String estadisticaAciertos = 'Aciertos';
  static const String estadisticaXp = 'XP (con bonus)';
  static const String estadisticaMonedas = 'Monedas';
  static String valorAciertos(int aciertos, int total) => '$aciertos/$total';
  static String valorGanado(int cantidad) => '+$cantidad';
  static String estadisticasSemantica(int aciertos, int total, int xp, int monedas) =>
      '$aciertos de $total aciertos, $xp XP con bonus, '
      '${monedas == 1 ? '1 moneda' : '$monedas monedas'}';
  static const String estadoFinalStartup = 'Estado final de tu Startup';

  /// Aviso del buzón: 1 fallada → 3 días; 2 → 3 y 7 días; 3 o más → 3, 7 y 14.
  static String avisoBuzon(int falladas) => switch (falladas) {
    1 => '1 tarjeta fallada irá a apelación en 3 días. Resuélvela para recuperar una vida.',
    2 => '2 tarjetas falladas irán a apelación en 3 y 7 días. Resuélvelas para recuperar vidas.',
    _ =>
      '$falladas tarjetas falladas irán a apelación en 3, 7 y 14 días. Resuélvelas para '
          'recuperar vidas.',
  };
  static const String continuarAlMapa = 'Continuar al mapa';
  static const String repasarFallos = 'Repasar mis fallos';
  static const String quiebraTitulo = '¡Tu Startup quebró!';
  static const String etiquetaQuiebraRiesgo = 'RIESGO LEGAL 100%';
  static const String etiquetaQuiebraPresupuesto = 'PRESUPUESTO 0%';
  static const String etiquetaQuiebraRiesgoSemantica = 'Riesgo legal al 100 %';
  static const String etiquetaQuiebraPresupuestoSemantica = 'Presupuesto al 0 %';
  static const String quiebraGenericaRiesgo =
      'El Riesgo legal llegó al 100 %. Las demandas y las multas cerraron la Startup.';
  static const String quiebraGenericaPresupuesto =
      'El presupuesto se acabó y la Startup ya no pudo pagarle a su equipo.';
  static const String avisoReinicio =
      'El sprint se reinicia con los indicadores al inicio. Las tarjetas falladas ya están '
      'en tu Buzón de Apelaciones.';
  static const String reiniciarSprint = 'Reiniciar sprint';
  static const String irAlBuzon = 'Ir al Buzón de Apelaciones';
  static const String sinResultado = 'No hay un resultado que mostrar.';

  // ---------------------------------------------------------------------
  // Pantallas pendientes (marcadores temporales)
  // ---------------------------------------------------------------------

  // ---------------------------------------------------------------------
  // 22 Juicio de apelación, 22b Apelación ganada y apelación perdida
  // ---------------------------------------------------------------------
  static String apelacionPaso(int actual, int total) => 'Apelación $actual de $total';
  static const String masUnaVida = '+1 vida';
  static const String vidasAlMaximo = 'Vidas al máximo';
  static const String recompensaApelacionSemantica = 'Si ganas, recuperas 1 vida';
  static const String vidasAlMaximoSemantica = 'Tienes las vidas al máximo';
  static String etiquetaApelacion(String tema) => 'APELACIÓN · ${tema.toUpperCase()}';
  static String falladaHace(int dias) => 'La fallaste hace $dias días';
  static const String notaJuicio = 'Las apelaciones no dan avance en el mapa, pero sí vidas.';
  static String tarjetaApelacionSemantica(
    int actual,
    int total,
    String personaje,
    String rol,
    String texto,
  ) => 'Apelación $actual de $total. $personaje, $rol: $texto';
  static const String vidaRecuperadaInsignia = '+1 vida recuperada';
  static const String noPierdesVidas = 'No pierdes vidas';
  static const String apelacionGanadaTitulo = '¡Apelación ganada!';
  static const String apelacionPerdidaTitulo = 'Apelación perdida';
  static const String estaVezSi = 'Esta vez sí: ';
  static const String estaVezNo = 'Esta vez no: ';
  static String vuelveEnDias(int dias) =>
      'La tarjeta vuelve en $dias días para asegurar que no se te olvide.';
  static const String tarjetaDominada = 'Esta tarjeta ya quedó dominada: sale de tu Buzón.';
  static const String vuelveManana = 'La tarjeta vuelve mañana para que lo intentes de nuevo.';
  static String respuestaCorrectaEra(String veredicto) => 'La respuesta correcta era $veredicto.';
  static const String veredictoLegalNombre = 'Legal';
  static const String veredictoIlegalNombre = 'Ilegal';
  static const String veredictoCondicionalNombre = 'Condicional';
  static const String veredictoEscalarNombre = 'Escalar';
  static String diaRepaso(int dia) => 'Día $dia';
  static String diaRepasoSemantica(int dia, {required bool hecho}) =>
      'Día $dia, ${hecho ? 'completado' : 'pendiente'}';
  static const String siguienteApelacion = 'Siguiente apelación';
  static const String volverAlBuzon = 'Volver al Buzón';
  static String anuncioApelacion(String titulo, String insignia, int vidas) =>
      '$titulo $insignia. Vidas: $vidas de 5.';
  static const String necesitasConexionApelar = 'Necesitas conexión para apelar';
  static const String apelacionNoDisponible = 'Esta apelación ya no está disponible';
  static const String errorGuardarApelacion =
      'No se pudo guardar tu apelación. Inténtalo de nuevo.';
  static const String cargandoApelacion = 'Cargando la apelación';

  // ---------------------------------------------------------------------
  // 21 Buzón de Apelaciones
  // ---------------------------------------------------------------------
  static const String buzonTitulo = 'Buzón de Apelaciones';
  static const String buzonSubtitulo =
      'Tus fallos regresan a los 3 y 7 días para que no se te olviden.';
  static String juiciosHoy(int n) => switch (n) {
    0 => 'Hoy no tienes juicios de apelación',
    1 => '1 juicio de apelación hoy',
    _ => '$n juicios de apelación hoy',
  };
  static const String recompensaApelacion = 'Gana cada apelación y recupera 1 vida';
  static const String proximasApelaciones = 'Tus próximas apelaciones aparecen abajo';
  static String plazoApelacion(int dia, int dias) => switch (dias) {
    <= 0 => 'Día $dia · hoy · +1 vida',
    1 => 'Día $dia · mañana',
    _ => 'Día $dia · en $dias días',
  };
  static String avisoApelacionFutura(int dias) =>
      dias == 1 ? 'Esta apelación se abre mañana' : 'Esta apelación se abre en $dias días';
  static String filaApelacionSemantica(String titulo, String tema, int dia, int dias) =>
      '$titulo, $tema, día $dia, ${switch (dias) {
        <= 0 => 'disponible hoy, +1 vida si la ganas',
        1 => 'disponible mañana',
        _ => 'disponible en $dias días',
      }}';
  static String listaApelaciones(int n) => n == 1 ? 'Lista, 1 apelación' : 'Lista, $n apelaciones';
  static const String iniciarApelacionesHoy = 'Iniciar apelaciones de hoy';
  static const String notaApelaciones = 'No consume vidas · No avanza el mapa';
  static const String buzonVacioTitulo = 'Tu Buzón está vacío';
  static const String buzonVacioTexto = 'Cuando falles una tarjeta, volverá aquí a los 3 y 7 días.';
  static const String buzonErrorCarga = 'No pudimos cargar tu Buzón.';
  static const String cargandoBuzon = 'Cargando el Buzón';

  // ---------------------------------------------------------------------
  // 21b Notificación de apelación (la del sistema; aquí, su texto y maqueta)
  // ---------------------------------------------------------------------
  static const String notificacionApp = 'ABOGATOR';
  static const String notificacionAhora = 'ahora';
  static const String notificacionApelacionTitulo = '⚖️ Tienes un juicio de apelación pendiente';
  static String notificacionApelacionCuerpo(String titulo, int dias) =>
      'Hace $dias días fallaste “$titulo”. Gánala y recupera 1 vida.';
  static const String notificacionApelacionPie = 'Toca para abrir el juicio de apelación';

  // ---------------------------------------------------------------------
  // 26 Ajustes de accesibilidad
  // ---------------------------------------------------------------------
  static const String ajustesTitulo = 'Accesibilidad';
  static const String ajustesSubtitulo = 'WCAG 2.1 AA · Ajusta la app a tu forma de aprender.';
  static const String seccionVisual = 'VISUAL';
  static const String seccionMotora = 'MOTOR Y AUDITIVA';
  static const String seccionCognitiva = 'COGNITIVA (WCAG 2.2.1)';
  static const String modoOscuro = 'Modo oscuro';
  static const String modoOscuroDetalle = 'Contraste alto en fondos oscuros';
  static const String usarModoSistema = 'Usar el modo del sistema';
  static const String tamanoTexto = 'Tamaño de texto';
  static const String tamanoTextoDetalle = 'Texto dinámico sin deformar';
  static String tamanoValor(int porcentaje) => 'Aa $porcentaje %';
  static String porcentaje(int porcentaje) => '$porcentaje %';
  static String porcentajeSemantica(int porcentaje) => '$porcentaje por ciento';
  static const String muestraTamano = 'Aa';
  static const String etiquetasLector = 'Etiquetas para lector';
  static const String etiquetasLectorDetalle = 'TalkBack / VoiceOver';
  static const String lectorActivo = 'Activo';
  static const String lectorDisponible = 'Disponible';
  static String lectorSemantica(bool activo) =>
      'Etiquetas para lector: ${activo ? 'activo' : 'disponible'}';
  static const String soloBotones = 'Botones en lugar de deslizar';
  static const String soloBotonesDetalle = 'Toca uno de los 4 veredictos (48 dp)';
  static const String vibracion = 'Vibración háptica';
  static const String vibracionDetalle = 'Corta = acierto · doble = error';
  static const String tiempoExtendido = 'Tiempo extendido en exámenes';
  static const String tiempoExtendidoDetalle = '+50% por tarjeta y opción de pausa';
  static const String reducirAnimaciones = 'Reducir animaciones';
  static const String reducirAnimacionesDetalle = 'Menos movimiento en tarjetas';
  static String filaAjusteSemantica(String titulo, String detalle) =>
      '$titulo, ${detalle[0].toLowerCase()}${detalle.substring(1)}';
  static const String errorGuardarAjuste = 'No se pudo guardar el ajuste. Inténtalo de nuevo.';

  // ---------------------------------------------------------------------
  // 27, 28, 28b y 28c Examen Final (Nivel Jefe)
  // ---------------------------------------------------------------------
  static const String alertaJefe = 'NIVEL JEFE · CRISIS EN CURSO';
  static const String inspectoraVega = 'Inspectora Vega';
  static const String inspectoraVegaMayusculas = 'INSPECTORA VEGA';
  static const String auditoraDatos = 'Auditora de protección de datos';
  static String hpJefe(int hp) => 'HP $hp%';
  static String barraJefeSemantica(int hp) =>
      'Inspectora Vega, auditora de protección de datos. HP $hp por ciento';
  static const String faseDeteccion = 'Detección';
  static const String faseContencion = 'Contención';
  static const String faseAviso = 'Aviso';
  static const String faseAutoridad = 'Autoridad';
  static String horaCorta(int hora) => 'H$hora';
  static const String lineaCrisisSemantica =
      'Línea de crisis: detección, contención, aviso y autoridad';
  static String reglaDecisiones(int total, int segundos) =>
      '$total decisiones en secuencia rápida: $segundos s cada una';
  static const String reglaContraargumento =
      'La Inspectora te contraargumenta: defiende tu veredicto';
  static const String reglaComodines = 'Comodines desactivados (RN03)';
  static const String reglaVidas = 'Si pierdes todas tus vidas, la crisis se reinicia';
  static String tiempoExtendidoActivo(int segundos) =>
      'Tiempo extendido activo: $segundos s por decisión';
  static const String enfrentarAuditoria = 'Enfrentar la auditoría';
  static const String iniciandoExamen = 'Iniciando el examen';
  static const String ahoraNo = 'Ahora no';
  static const String necesitasConexionExamen = 'Necesitas conexión para iniciar el examen.';
  static const String examenNoDisponible = 'Este examen aún no está disponible';
  static const String examenErrorCarga = 'No se pudo cargar el examen.';
  static const String examenErrorIniciar = 'No se pudo iniciar el examen. Inténtalo de nuevo.';
  static const String cargandoExamen = 'Cargando el examen';
  static String pasoCrisis(int actual, int total) => 'Crisis · Decisión $actual de $total';
  static String horaCrisis(int hora) => 'Hora $hora de 72';
  static String decisionSemantica(
    int actual,
    int total,
    String personaje,
    String rol,
    String texto,
  ) => 'Decisión $actual de $total. $personaje, $rol: $texto';
  static const String comodinesDesactivados = 'Comodines desactivados en el examen';
  static const String pausar = 'Pausar el examen';
  static const String examenEnPausa = 'Examen en pausa';
  static const String tiempoDetenido = 'El tiempo está detenido.';
  static const String salirDelExamen = 'Salir del examen';
  static const String salirExamenTitulo = '¿Salir del examen?';
  static const String salirExamenTexto =
      'La crisis se reinicia desde la hora 0. No ganas premio ni pierdes vidas.';
  static const String salirExamen = 'Salir';
  static String quedanSegundos(int s) => s == 1 ? 'Queda 1 segundo' : 'Quedan $s segundos';
  static String limiteDecision(int s) => 'Tienes $s segundos para decidir';
  static const String tiempoAgotado = 'Tiempo agotado';
  static const String falloVeredicto = '−1 vida · Fallaste';
  static const String falloTiempo = '−1 vida · Se acabó el tiempo';
  static const String falloFundamento = '−1 vida · Ese fundamento no sirve';
  static String falloSemantica(String motivo, int vidas) =>
      '$motivo. Te ${vidas == 1 ? 'queda 1 vida' : 'quedan $vidas vidas'}.';
  static String golpe(int danio) => '−$danio HP · ¡Argumento sólido!';
  static String golpeSemantica(int danio, int hp) =>
      'Daño a la Inspectora: menos $danio HP. Le quedan $hp.';
  static const String defiendeVeredicto = 'Defiende tu veredicto · elige el fundamento';
  static String tienesParaResponder(int s) => 'Tienes $s s para responder';
  static String replicaCita(String texto) => '“$texto”';
  static String replicaAnuncio(String texto, int s) =>
      'La Inspectora contraargumenta: $texto Tienes $s segundos';
  // 29 Auditoría superada y 30 La Inspectora ganó
  static const String auditoriaSuperada = '¡Auditoría superada!';
  static String aprobadoDesbloqueo(int numero, String nombre) =>
      'Contuviste la crisis y la Inspectora Vega aprobó tu MVP. '
      'Desbloqueaste el Módulo $numero: $nombre.';
  static const String aprobadoUltimo =
      'Contuviste la crisis y la Inspectora Vega aprobó tu MVP. ¡Completaste todos los módulos!';
  static const String certificadoDeModulo = 'CERTIFICADO DE MÓDULO';
  static String detalleCertificado(String persona, int aciertos, int total, String fecha) =>
      '$persona · $aciertos/$total aciertos · $fecha';
  static String folio(String folio) => 'Folio $folio';
  static String certificadoSemantica(
    String modulo,
    String persona,
    int aciertos,
    int total,
    String fecha,
    String folio,
  ) =>
      'Certificado de módulo. $modulo. $persona, $aciertos de $total aciertos, $fecha. Folio $folio.';
  static String irAlModulo(int numero) => 'Ir al Módulo $numero';
  static const String compartirCertificadoBoton = 'Compartir certificado';
  static String compartirCertificado(String modulo, String folio, String fecha) =>
      'Obtuve el certificado «$modulo» en AboGator · Folio $folio · $fecha';
  static const String certificadoCopiado = 'Certificado copiado';
  static const String errorGuardarResultado = 'No pudimos guardar tu resultado';
  static const String errorGuardarApelaciones = 'No pudimos guardar tus apelaciones';
  static String anuncioAprobado(int? numero) => numero == null
      ? 'Auditoría superada. Certificado emitido. Completaste todos los módulos'
      : 'Auditoría superada. Certificado emitido. Módulo $numero desbloqueado';
  static String anuncioReprobado(int apelaciones) =>
      'La Inspectora ganó. ${apelaciones == 1 ? '1 apelación' : '$apelaciones apelaciones'} en el Buzón';
  static const String inspectoraGano = 'La Inspectora ganó';
  static const String reprobadoSinVidas =
      'Te quedaste sin vidas durante la crisis. La auditoría se reiniciará desde la hora 0.';
  static const String reprobadoSinDecisiones =
      'Se acabaron las decisiones y la Inspectora Vega sigue en pie. '
      'La auditoría se reiniciará desde la hora 0.';
  static String llegasteValor(int jugadas, int total) => '$jugadas/$total';
  static const String llegasteA = 'Llegaste a';
  static const String aciertos = 'Aciertos';
  static const String porTiempo = 'Por tiempo';
  static String resumenExamenSemantica(int jugadas, int total, int aciertos, int porTiempo) =>
      'Llegaste a la decisión $jugadas de $total. '
      '${aciertos == 1 ? '1 acierto' : '$aciertos aciertos'}. '
      '$porTiempo por tiempo agotado';
  static String proximaVidaExamen(String tiempo) =>
      'Próxima vida en $tiempo. Repasa los temas del módulo mientras tanto.';
  static String vidasRestantesExamen(int vidas) =>
      'Aún tienes ${vidas == 1 ? '1 vida' : '$vidas vidas'}. '
      'Repasa los temas del módulo antes de volver a intentarlo.';
  static const String repasarEnBuzon = 'Repasar en el Buzón';
  static const String errorRespuestaExamen = 'No se pudo enviar tu respuesta. Inténtalo de nuevo.';
  static const String pendienteNotificacionesRacha =
      'Notificaciones de racha · pantalla pendiente de diseño';
  static const String pendienteAvisoPrivacidad =
      'Aviso de privacidad · pantalla pendiente de diseño';

  // ---------------------------------------------------------------------
  // 24 Tienda
  // ---------------------------------------------------------------------
  static const String tiendaTitulo = 'Tienda';
  static String saldoSemantica(int monedas) =>
      monedas == 1 ? 'Tienes 1 moneda' : 'Tienes $monedas monedas';
  static const String tuInventario = 'Tu inventario';
  static const String comodinesSeccion = 'Comodines';
  static const String inventarioCongelar = 'Congelar racha';
  static String inventarioPildora(String nombre, int cantidad) => '$nombre ×$cantidad';
  static String inventarioSemantica(String nombre, int cantidad) =>
      '$nombre, $cantidad en inventario';
  static String inventarioLista(int articulos) =>
      articulos == 1 ? 'Inventario, 1 artículo' : 'Inventario, $articulos artículos';
  static const String precioMaximo = 'Máximo';
  static String teFaltan(int monedas) => 'Te faltan $monedas';
  static String comprarSemantica(String nombre, int precio) =>
      'Comprar $nombre por $precio monedas';
  static String comprarFaltanSemantica(String nombre, int precio, int faltan) =>
      'Comprar $nombre por $precio monedas, te faltan $faltan monedas';
  static String comprarMaximoSemantica(String nombre, int precio) =>
      'Comprar $nombre por $precio monedas, máximo alcanzado';
  static String comprarSinConexionSemantica(String nombre, int precio) =>
      'Comprar $nombre por $precio monedas, necesitas conexión';
  static const String notaRn03 =
      'Los comodines solo funcionan en lecciones normales. En el Examen Final están bloqueados (RN03).';
  static const String necesitasConexionComprar = 'Necesitas conexión para comprar.';
  static String confirmarCompraTitulo(String nombre) => '¿Comprar $nombre?';
  static String confirmarCompraTexto(int precio, int quedarian) =>
      'Cuesta $precio monedas. Te quedarían $quedarian.';
  static const String comprar = 'Comprar';
  static const String cancelar = 'Cancelar';
  static String compraHecha(String nombre, int cantidad, int monedas) =>
      'Compraste $nombre. Ahora tienes $cantidad. '
      'Te ${monedas == 1 ? 'queda 1 moneda' : 'quedan $monedas monedas'}.';
  static const String compraSinMonedas = 'Ya no te alcanzan las monedas.';
  static const String compraMaximo = 'Ya tienes el máximo.';
  static const String compraError = 'No se pudo completar la compra. Inténtalo de nuevo.';
  static const String comprando = 'Comprando';
  static const String tiendaErrorCarga = 'No se pudo cargar la Tienda.';
  static const String cargandoTienda = 'Cargando la Tienda';

  // ---------------------------------------------------------------------
  // 25 Perfil y progreso
  // ---------------------------------------------------------------------
  static const String perfilTitulo = 'Mi perfil';
  static const String accesibilidadYAjustes = 'Accesibilidad y ajustes';
  static String nivelYXp(String perfil, int nivel, String xp) => '$perfil · Nivel $nivel · $xp XP';
  static String tarjetaPerfilSemantica(String nombre, String detalle) => '$nombre, $detalle';
  static String rachaDias(int dias) => dias == 1 ? '1 día' : '$dias días';
  static const String rachaActual = 'Racha actual';
  static String precisionValor(int porcentaje) => '$porcentaje%';
  static const String precision = 'Precisión';
  static String certificadosValor(int obtenidos, int total) => '$obtenidos / $total';
  static String certificadosSemanticaValor(int obtenidos, int total) => '$obtenidos de $total';
  static const String certificados = 'Certificados';
  static const String sprintsPerfectos = 'Sprints perfectos';
  static String estadisticaSemantica(String etiqueta, String valor) => '$etiqueta: $valor';
  static const String insigniasTitulo = 'Insignias';
  static String insigniaSemantica(String nombre, {required bool obtenida}) =>
      '$nombre, ${obtenida ? 'obtenida' : 'bloqueada'}';
  static const String menuAccesibilidad = 'Accesibilidad';
  static const String menuNotificacionesRacha = 'Notificaciones de racha';
  static const String menuAvisoPrivacidad = 'Aviso de privacidad';
  static const String cerrarSesion = 'Cerrar sesión';
  static const String confirmarCerrarSesionTitulo = '¿Cerrar sesión?';
  static const String confirmarCerrarSesionTexto =
      'Tus datos de la cuenta quedan guardados en el servidor.';
  static String respuestasGuardadasAviso(int n) => n == 1
      ? 'Tienes 1 respuesta guardada en este dispositivo; se enviará cuando vuelvas a entrar.'
      : 'Tienes $n respuestas guardadas en este dispositivo; se enviarán cuando vuelvas a entrar.';
  static const String errorCerrarSesion = 'No se pudo cerrar la sesión. Inténtalo de nuevo.';
  static const String perfilErrorCarga = 'No se pudo cargar tu perfil.';
  static const String cargandoPerfil = 'Cargando tu perfil';

  // ---------------------------------------------------------------------
  // Galería de componentes (temporal, se elimina con las pantallas reales)
  // ---------------------------------------------------------------------
  static const String galeriaTitulo = 'Galería de componentes';
  static const String galeriaModoOscuro = 'Modo oscuro';
  static const String galeriaTokens = 'Tokens de color';
  static const String galeriaTipografia = 'Estilos de texto';
  static const String galeriaTextoEjemplo = 'Sarko dicta sentencia: ¿es legal?';
  static const String galeriaCodigoEjemplo = 'import gpl_lib; // ¿app cerrada?';
  static const String galeriaBotones = 'Botones';
  static const String galeriaVeredictos = 'Botones de veredicto (decorativos e interactivos)';
  static const String galeriaCampos = 'Campos de texto';
  static const String galeriaAcceso = 'Componentes de acceso';
  static const String galeriaInicio = 'Componentes del Inicio';
  static const String galeriaTablet = 'Componentes de tablet (riel e Inicio)';
  static const String galeriaMapa = 'Componentes del mapa y la intro del sprint';
  static const String galeriaJuego = 'Componentes del juego';
  static const String galeriaVeredicto = 'Paneles de veredicto';
  static const String galeriaEvidencia = 'Evidencia y dilema';
  static const String galeriaVidasConexion = 'Vidas y conexión';
  static const String galeriaApelaciones = 'Buzón de Apelaciones';
  static const String galeriaFinSprint = 'Componentes del fin de sprint';
  static const String galeriaExplicacion =
      'La licencia GPL-3.0 es copyleft: si la integras, todo el producto derivado debe '
      'liberarse bajo la misma licencia.';
  static const String galeriaMicroEnunciado = '¿por qué es ilegal?';
  static const String galeriaMicroOpcion1 = 'La GPL-3.0 obliga a liberar el código derivado';
  static const String galeriaMicroOpcion2 = 'Porque el código de GitHub siempre es privado';
  static const String galeriaChips = 'Chips HUD';
  static const String galeriaVidas = 'Vidas';
  static const String galeriaIndicadores = 'Indicadores de la Startup';
  static const String galeriaProgreso = 'Barra de progreso';
  static const String galeriaPaginador = 'Paginador';
  static const String galeriaFoco = 'Anillo de foco';
  static const String galeriaSarko = 'Sarko';
  static const String galeriaTienda = 'Piezas de la Tienda';
  static const String galeriaPerfil = 'Piezas del Perfil';
  static const String galeriaAjustes = 'Piezas de los Ajustes';
  static const String galeriaJefe = 'Piezas del Examen Final';
  static const String galeriaLogos = 'Logos (4 formas × 5 tonos)';
  static String galeriaLogo(String forma, String tono) => '$forma · $tono';
  static const String galeriaIconos = 'Íconos';
  static const String galeriaNavegacion = 'La navegación inferior está abajo de esta pantalla.';

  static const String botonPrimario = 'Comenzar sprint';
  static const String botonSecundario = 'Volver';
  static const String botonAcento = 'Comprar';
  static const String botonPeligro = 'Abandonar';
  static const String botonFantasma = 'Omitir';
  static const String botonDeshabilitado = 'Siguiente';

  static const String campoCorreo = 'Correo electrónico';
  static const String campoCorreoAyuda = 'tu@correo.com';
  static const String campoCorreoError = 'Ingresa un correo válido';
  static const String campoContrasena = 'Contraseña';
  static const String campoContrasenaAyuda = 'Mínimo 8 caracteres';
  static const String campoNombre = 'Nombre';
  static const String campoNombreAyuda = '¿Cómo te llamas?';
  static const String campoNombreValor = 'Valeria Ríos';

  static String progresoTarjeta(int actual, int total) => 'Tarjeta $actual de $total';

  // Nombres de los estilos de texto (tal como están en Figma).
  static const String estiloDisplay = 'Display';
  static const String estiloH1 = 'Título/H1';
  static const String estiloH2 = 'Título/H2';
  static const String estiloH3 = 'Título/H3';
  static const String estiloCuerpoGrande = 'Cuerpo/Grande';
  static const String estiloCuerpoBase = 'Cuerpo/Base';
  static const String estiloCuerpoEnfasis = 'Cuerpo/Énfasis';
  static const String estiloEtiqueta = 'Etiqueta';
  static const String estiloLeyenda = 'Leyenda';
  static const String estiloBoton = 'Botón';
  static const String estiloCodigo = 'Código';

  // ---------------------------------------------------------------------
  // Errores de la capa de datos simulada
  // ---------------------------------------------------------------------
  static const String errorCredenciales = 'El correo o la contraseña no son correctos.';
  static const String errorConsentimientos =
      'Debes aceptar el Aviso de Privacidad y los Términos de uso para crear tu cuenta.';
  static const String errorSprintNoEncontrado = 'No encontramos ese sprint.';
  static const String errorTarjetaNoEncontrada = 'No encontramos esa tarjeta.';
}
