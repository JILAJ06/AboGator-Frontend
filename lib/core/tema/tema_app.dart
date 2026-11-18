import 'package:material_ui/material_ui.dart';

import 'tipografia.dart';
import 'tokens_color.dart';

/// Construye el `ThemeData` de la app a partir de los tokens.
///
/// No fija la escala de texto: se respeta el texto dinámico del sistema.
ThemeData crearTema({
  required TokensColor tokens,
  required Brightness brillo,
  required ResolutorFuente fuente,
}) {
  final estilos = EstilosTexto.crear(colorTexto: tokens.textoPrimario, fuente: fuente);
  final esquema = ColorScheme(
    brightness: brillo,
    primary: tokens.accionPrimaria,
    onPrimary: tokens.textoEnPrimario,
    secondary: tokens.accionSecundaria,
    onSecondary: tokens.textoEnPrimario,
    tertiary: tokens.accionAcento,
    onTertiary: tokens.textoEnPrimario,
    error: tokens.estadoIlegal,
    onError: tokens.textoEnPrimario,
    surface: tokens.fondoSuperficie,
    onSurface: tokens.textoPrimario,
    onSurfaceVariant: tokens.textoSecundario,
    surfaceContainerHighest: tokens.fondoSuperficieAlt,
    outline: tokens.bordeDefault,
    outlineVariant: tokens.bordeDefault,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brillo,
    colorScheme: esquema,
    scaffoldBackgroundColor: tokens.fondoApp,
    dividerColor: tokens.bordeDefault,
    textTheme: estilos.comoTextTheme(),
    extensions: [tokens, estilos],
  );
}

ThemeData crearTemaClaro(ResolutorFuente fuente) {
  return crearTema(tokens: TokensColor.claro, brillo: Brightness.light, fuente: fuente);
}

ThemeData crearTemaOscuro(ResolutorFuente fuente) {
  return crearTema(tokens: TokensColor.oscuro, brillo: Brightness.dark, fuente: fuente);
}
