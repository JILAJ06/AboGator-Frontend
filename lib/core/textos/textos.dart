/// Textos visibles de la interfaz, centralizados para poder corregirlos
/// o traducirlos en un solo lugar. Español de México.
abstract final class Textos {
  static const String nombreApp = 'AboGator';

  // Pantalla temporal "Tema de prueba" (se elimina en T-02).
  static const String pruebaTitulo = 'Tema de prueba';
  static const String pruebaSeccionColores = 'Tokens de color';
  static const String pruebaSeccionTipografia = 'Estilos de texto';
  static const String pruebaModoOscuro = 'Modo oscuro';
  static const String pruebaTextoEjemplo = 'Sarko dicta sentencia: ¿es legal?';
  static const String pruebaCodigoEjemplo = 'import gpl_lib; // ¿app cerrada?';

  // Nombres de los tokens de color (tal como están en Figma).
  static const String tokenFondoApp = 'fondo/app';
  static const String tokenFondoSuperficie = 'fondo/superficie';
  static const String tokenFondoSuperficieAlt = 'fondo/superficie-alt';
  static const String tokenFondoDestacado = 'fondo/destacado';
  static const String tokenTextoPrimario = 'texto/primario';
  static const String tokenTextoSecundario = 'texto/secundario';
  static const String tokenTextoEnPrimario = 'texto/en-primario';
  static const String tokenTextoAcento = 'texto/acento';
  static const String tokenBordeDefault = 'borde/default';
  static const String tokenAccionPrimaria = 'accion/primaria';
  static const String tokenAccionSecundaria = 'accion/secundaria';
  static const String tokenAccionAcento = 'accion/acento';
  static const String tokenEstadoLegal = 'estado/legal';
  static const String tokenEstadoIlegal = 'estado/ilegal';

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

  // Errores de la capa de datos simulada.
  static const String errorCredenciales = 'El correo o la contraseña no son correctos.';
  static const String errorConsentimientos =
      'Debes aceptar el Aviso de Privacidad y los Términos de uso para crear tu cuenta.';
  static const String errorSprintNoEncontrado = 'No encontramos ese sprint.';
}
