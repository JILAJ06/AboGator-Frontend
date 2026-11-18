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
  static const String galeriaCampos = 'Campos de texto';
  static const String galeriaChips = 'Chips HUD';
  static const String galeriaVidas = 'Vidas';
  static const String galeriaIndicadores = 'Indicadores de la Startup';
  static const String galeriaProgreso = 'Barra de progreso';
  static const String galeriaPaginador = 'Paginador';
  static const String galeriaFoco = 'Anillo de foco';
  static const String galeriaSarko = 'Sarko';
  static const String galeriaLogos = 'Logos';
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
