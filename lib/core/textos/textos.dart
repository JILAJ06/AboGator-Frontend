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

  static const String inicioErrorCarga = 'No pudimos cargar tu progreso.';
  static const String reintentar = 'Reintentar';
  static const String cargandoInicio = 'Cargando tu progreso';

  // ---------------------------------------------------------------------
  // Pantallas pendientes (marcadores temporales)
  // ---------------------------------------------------------------------
  static const String pendienteInicio = 'Inicio · llega en T-04';
  static const String pendienteMapaSprints = 'Mapa de sprints · llega en T-04b';
  static const String pendienteIntroSprint = 'Intro del sprint · llega en T-04b';
  static const String pendienteBuzon = 'Buzón · llega en T-09';
  static const String pendienteTienda = 'Tienda · llega en T-10';
  static const String pendientePerfil = 'Perfil · llega en T-10';

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
  static const String galeriaChips = 'Chips HUD';
  static const String galeriaVidas = 'Vidas';
  static const String galeriaIndicadores = 'Indicadores de la Startup';
  static const String galeriaProgreso = 'Barra de progreso';
  static const String galeriaPaginador = 'Paginador';
  static const String galeriaFoco = 'Anillo de foco';
  static const String galeriaSarko = 'Sarko';
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
}
