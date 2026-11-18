import 'package:material_ui/material_ui.dart';

import 'tipografia.dart';
import 'tokens_color.dart';

/// Construye el `ThemeData` de la app a partir de los tokens.
///
/// No fija la escala de texto: se respeta el texto dinámico del sistema.
ThemeData crearTema({required TokensColor tokens, required Brightness brillo}) {
  final estilos = EstilosTexto.crear(colorTexto: tokens.textoPrimario);
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
    outline: tokens.bordeControl,
    outlineVariant: tokens.bordeDefault,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brillo,
    colorScheme: esquema,
    fontFamily: FamiliasFuente.inter,
    scaffoldBackgroundColor: tokens.fondoApp,
    dividerColor: tokens.bordeDefault,
    focusColor: tokens.focoAnillo,
    textTheme: estilos.comoTextTheme(),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: tokens.accionPrimaria,
      selectionHandleColor: tokens.accionPrimaria,
    ),
    extensions: [tokens, estilos],
  );
}

ThemeData crearTemaClaro() => crearTema(tokens: TokensColor.claro, brillo: Brightness.light);

ThemeData crearTemaOscuro() => crearTema(tokens: TokensColor.oscuro, brillo: Brightness.dark);
