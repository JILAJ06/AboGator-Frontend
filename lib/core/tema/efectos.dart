import 'package:material_ui/material_ui.dart';

import '../utilidades/contraste.dart';

/// Efectos visuales del diseño que no son tokens de color de Figma.
abstract final class EfectosApp {
  /// Color de la sombra sólida de los botones: #0F294A al 18 % (0x2E).
  static const Color colorSombraSolida = Color(0x2E0F294A);

  /// Brillo de la barra de progreso: blanco al 35 % (0x59).
  static const Color brilloBarra = Color(0x59FFFFFF);

  /// Opacidad del fondo de los chips de impacto (13 %).
  static const double opacidadChipImpacto = 0.13;

  /// Sombra del botón de veredicto: (0, 8), desenfoque 24, #0F294A al 14 % (0x24).
  static const List<BoxShadow> sombraVeredicto = [
    BoxShadow(color: Color(0x240F294A), offset: Offset(0, 8), blurRadius: 24),
  ];

  /// Sombra de la tarjeta de caso: (0, 10), desenfoque 12, #0F294A al 22 % (0x38).
  static const List<BoxShadow> sombraTarjeta = [
    BoxShadow(color: Color(0x380F294A), offset: Offset(0, 10), blurRadius: 12),
  ];

  /// Sombra de la tarjeta héroe: (0, 8), desenfoque 24, #0F294A al 14 %.
  static const List<BoxShadow> sombraHeroe = sombraVeredicto;

  /// Sombra de la tarjeta de módulo: (0, 8), desenfoque 12, #0F294A al 14 %.
  static const List<BoxShadow> sombraModulo = [
    BoxShadow(color: Color(0x240F294A), offset: Offset(0, 8), blurRadius: 12),
  ];

  /// Sombra del botón Buzón: (0, 16), desenfoque 40, #0F294A al 22 % (0x38).
  static const List<BoxShadow> sombraBuzon = [
    BoxShadow(color: Color(0x380F294A), offset: Offset(0, 16), blurRadius: 40),
  ];

  /// Elipse decorativa de la tarjeta héroe: blanco al 8 % (más clara que el verde
  /// en ambos modos, como en Figma 07 y 07b).
  static const Color elipseHeroe = Color(0x14FFFFFF);

  /// Círculo decorativo del panel de marca de tablet (T05 y T06, Figma 94:469):
  /// blanco al 6 % (0x0F) sobre el verde bosque fijo.
  static const Color circuloPanelMarca = Color(0x0FFFFFFF);

  /// Ícono sobre el color de un módulo: blanco fijo (los colores de módulo son
  /// de marca y no cambian con el modo).
  static const Color iconoSobreModulo = Color(0xFFFFFFFF);

  /// Opacidad de la etiqueta de la tarjeta de caso (14 %).
  static const double opacidadEtiquetaCaso = 0.14;

  /// Opacidad de los puntos de carga inactivos del Splash (40 %).
  static const double opacidadPuntoInactivo = 0.4;

  // ---------------------------------------------------------------------
  // 08 Mapa de sprints y 09 Intro del sprint (Figma 13:562 y 13:776)
  // ---------------------------------------------------------------------

  /// Sombra del globo del sprint actual ("Sombra/Elevada" de Figma).
  static const List<BoxShadow> sombraGlobo = sombraBuzon;

  /// Texto e íconos sobre el encabezado del módulo: blanco fijo.
  static const Color textoEncabezado = Color(0xFFFFFFFF);

  /// Fondo del botón atrás del encabezado: blanco al 18 % (0x2E).
  static const Color fondoAtrasEncabezado = Color(0x2EFFFFFF);

  /// Pista de la barra de avance del encabezado: blanco al 25 % (0x40).
  static const Color pistaEncabezado = Color(0x40FFFFFF);

  /// Relleno de la barra de avance del encabezado (ámbar claro de Figma).
  static const Color rellenoEncabezado = Color(0xFFE0A060);

  /// La etiqueta "MÓDULO N · NOMBRE" es el color del módulo mezclado con
  /// blanco al 85 % (en Figma, #DCE7F7 sobre el azul del módulo 1).
  static const double mezclaEtiquetaEncabezado = 0.85;

  /// Color de la etiqueta del encabezado sobre [fondo].
  static Color etiquetaEncabezado(Color fondo) =>
      Color.lerp(fondo, textoEncabezado, mezclaEtiquetaEncabezado)!;

  /// Fondo del encabezado del módulo: el color del módulo tal cual si el texto
  /// blanco y la etiqueta alcanzan 4.5:1; si no (módulos 2 y 5), se oscurece lo
  /// mínimo necesario en pasos de 2 % hacia negro.
  static Color fondoEncabezado(Color modulo) {
    var fondo = modulo;
    for (var paso = 1; paso <= 50; paso++) {
      final suficiente =
          Contraste.razon(textoEncabezado, fondo) >= Contraste.minimoTexto &&
          Contraste.razon(etiquetaEncabezado(fondo), fondo) >= Contraste.minimoTexto;
      if (suficiente) return fondo;
      fondo = Color.lerp(modulo, const Color(0xFF000000), paso * 0.02)!;
    }
    return fondo;
  }

  /// Camino del mapa: trazo de 8 con puntas redondas; guiones de 2 y huecos de
  /// 15 (se ven como puntos). El color es el token borde/default.
  static const double anchoCamino = 8;
  static const double guionCamino = 2;
  static const double huecoCamino = 15;

  /// Opacidad del aro de pulso del sprint actual (accion/acento al 40 %).
  static const double opacidadPulso = 0.4;

  /// Bases (sombra sólida inferior) de los nodos del mapa en modo claro, tal
  /// como están en Figma, por color de cara: completado, actual, bloqueado y
  /// Examen final.
  static const Map<int, Color> _basesClaro = {
    0xFF1F4E35: Color(0xFF123222),
    0xFF9A5A1C: Color(0xFF7A4615),
    0xFFF1F5F9: Color(0xFFCBD5E1),
    0xFF0F294A: Color(0xFF07172B),
  };

  /// Base de un nodo del mapa bajo su [cara]. En modo oscuro (sin valores en
  /// Figma) es la cara oscurecida un 35 %.
  static Color baseNodo(Color cara) =>
      _basesClaro[cara.toARGB32()] ?? Color.lerp(cara, const Color(0xFF000000), 0.35)!;

  // ---------------------------------------------------------------------
  // 10 Juego (Figma 37:1676)
  // ---------------------------------------------------------------------

  /// Sombra de la tarjeta de caso del juego (nodo 10:5): (0, 16), desenfoque
  /// 20, #0F294A al 22 % (0x38).
  static const List<BoxShadow> sombraTarjetaCaso = [
    BoxShadow(color: Color(0x380F294A), offset: Offset(0, 16), blurRadius: 20),
  ];

  /// Opacidad de las tarjetas de la pila: Pila 1 al 80 % y Pila 2 al 50 %.
  static const double opacidadPila1 = 0.8;
  static const double opacidadPila2 = 0.5;

  /// Inclinación de los sellos Legal (+14°) e Ilegal (−14°), calculada de
  /// sus cajas en Figma (37:2134 y 37:2132).
  static const double anguloSello = 14;

  /// Espaciado de las letras de los sellos.
  static const double espaciadoSello = 3;

  // ---------------------------------------------------------------------
  // 12, 12b, 12c, 14 y 14b Panel de veredicto
  // ---------------------------------------------------------------------

  /// Velo detrás del panel: #0B1220 al 40 % (0x66), como en Figma 14.
  static const Color colorVelo = Color(0x660B1220);

  /// El panel sube en 280 ms (ease-out).
  static const Duration duracionPanel = Duration(milliseconds: 280);

  // ---------------------------------------------------------------------
  // 16 y 16b Snippet de código (Figma 10:89)
  // ---------------------------------------------------------------------

  /// Fondo del snippet (igual en claro y oscuro: es un editor de código).
  static const Color fondoSnippet = Color(0xFF0B1220);

  /// Barra superior del snippet.
  static const Color barraSnippet = Color(0xFF162030);

  /// Botones de ventana de la barra (Figma 10:91, 10:92 y 10:93).
  static const Color ventanaRojo = Color(0xFFFF5F57);
  static const Color ventanaAmbar = Color(0xFFFEBC2E);
  static const Color ventanaVerde = Color(0xFF28C840);

  /// Nombre del archivo y números de línea.
  static const Color textoSecundarioSnippet = Color(0xFF94A3B8);

  /// Texto de las líneas.
  static const Color textoSnippet = Color(0xFFE2E8F0);

  /// Línea clave revelada (16b): rojo veredicto al 28 % y texto rosado.
  static const Color fondoLineaClave = Color(0x47B52426);
  static const Color textoLineaClave = Color(0xFFFECACA);

  /// Subrayado del jugador (estado/resaltado #FFE27A). En Figma es una capa
  /// con mezcla "multiply" al 55 %; sobre el fondo oscuro multiply casi no se
  /// ve (el relleno apenas tiñe y destaca el borde), así que se usa un relleno
  /// al 12 % más el borde de 2.
  static const Color resaltado = Color(0xFFFFE27A);
  static const double opacidadResaltado = 0.12;

  /// El resaltado aparece en 150 ms (sin animación con "reducir animaciones").
  static const Duration duracionResaltado = Duration(milliseconds: 150);

  // ---------------------------------------------------------------------
  // 10b Lupa de Auditor (Figma 38:4914)
  // ---------------------------------------------------------------------

  /// Subrayado grueso de las palabras trampa: #FFD84D al 65 % (como en
  /// Figma). En oscuro baja al 35 % para que el texto claro siga en AA.
  static const Color trampaClaro = Color(0xA6FFD84D);
  static const Color trampaOscuro = Color(0x59FFD84D);

  /// Grosor del subrayado (11 en Figma, con el texto de 17).
  static const double grosorTrampa = 11;

  /// Color del subrayado de las trampas según el modo.
  static Color trampa(Brightness brillo) => brillo == Brightness.dark ? trampaOscuro : trampaClaro;

  // ---------------------------------------------------------------------
  // 21b Notificación de apelación (imita la del sistema: no son tokens)
  // ---------------------------------------------------------------------

  /// Fondo: blanco al 88 % con desenfoque de 10.
  static const Color fondoNotificacion = Color(0xE0FFFFFF);
  static const double desenfoqueNotificacion = 10;

  /// Sombra (0, 8), desenfoque 12, negro al 18 % (0x2E).
  static const List<BoxShadow> sombraNotificacion = [
    BoxShadow(color: Color(0x2E000000), offset: Offset(0, 8), blurRadius: 12),
  ];

  /// Texto del sistema: nombre de la app y hora (#475569) y título y cuerpo
  /// (#111827).
  static const Color textoSecundarioNotificacion = Color(0xFF475569);
  static const Color textoNotificacion = Color(0xFF111827);

  /// Ícono de la app: verde de marca #1F4E35 (radio 8.4).
  static const Color iconoAppNotificacion = Color(0xFF1F4E35);

  // ---------------------------------------------------------------------
  // 19 Sprint completado (Figma 38:5557)
  // ---------------------------------------------------------------------

  /// Colores del confeti (decorativos, no son tokens): ámbar mazo, verde
  /// circuito, azul del módulo 1, rojo veredicto y ámbar claro.
  static const Color confetiAmbar = Color(0xFFB86B23);
  static const Color confetiVerde = Color(0xFF68B678);
  static const Color confetiAzul = Color(0xFF2B5FA8);
  static const Color confetiRojo = Color(0xFFB52426);
  static const Color confetiAmbarClaro = Color(0xFFE0A060);

  /// El confeti cae una vez al abrir la pantalla.
  static const Duration duracionConfeti = Duration(milliseconds: 1200);

  // ---------------------------------------------------------------------
  // 27, 28, 28b y 28c Examen Final (Figma 42:5885, 42:6027, 42:6140, 42:6284)
  // Colores fijos del Nivel Jefe: iguales en claro y oscuro.
  // ---------------------------------------------------------------------

  /// Fondo de la crisis (27).
  static const Color fondoCrisis = Color(0xFF0F294A);

  /// Barra del Jefe y globo de la réplica.
  static const Color barraJefe = Color(0xFF162030);

  /// Avatar de la Inspectora Vega.
  static const Color avatarJefe = Color(0xFF6B4BA1);

  /// Vida del Jefe y su "HP".
  static const Color vidaJefe = Color(0xFFF07070);

  /// Pista de la vida del Jefe: blanco al 15 %.
  static const Color pistaVidaJefe = Color(0x26FFFFFF);

  /// Textos sobre el fondo de la crisis.
  static const Color textoCrisis = Color(0xFFCBD5E1);
  static const Color textoCrisisSecundario = Color(0xFF94A3B8);

  /// Punto inactivo y conectores de la línea de crisis.
  static const Color inactivoCrisis = Color(0xFF2A3850);

  /// Línea "Tiempo extendido activo".
  static const Color verdeCrisis = Color(0xFF68B678);

  /// "INSPECTORA VEGA" en el globo de la réplica.
  static const Color textoReplica = Color(0xFFB7A0E6);

  /// Rojo de alerta, hora de crisis y daño (igual que estado/ilegal claro).
  static const Color alertaCrisis = Color(0xFFB52426);

  /// Íconos de las reglas de 27 (ámbar, leído de los SVG de Figma).
  static const Color iconoReglaCrisis = Color(0xFFE0A060);

  /// Fondo de las reglas: blanco al 8 %.
  static const Color fondoReglasCrisis = Color(0x14FFFFFF);

  /// Texto blanco de la crisis (alerta, título, reglas, chip de daño).
  static const Color blancoCrisis = Color(0xFFFFFFFF);

  /// Chip de la etiqueta "CRISIS · BRECHA DE DATOS": ámbar del mazo.
  static const Color etiquetaCrisis = Color(0xFFB86B23);

  /// Tinte de urgencia de 28, 28b y 28c (estado/ilegal al 6 %).
  static const double opacidadUrgencia = 0.06;

  /// Sombra del chip de daño: (0, 16), desenfoque 40, #0F294A al 22 %.
  static const List<BoxShadow> sombraChipDanio = sombraBuzon;

  /// Cuánto se ve el chip de daño o de fallo.
  static const Duration duracionChipJefe = Duration(milliseconds: 1500);

  /// La barra de vida del Jefe baja en 300 ms.
  static const Duration duracionVidaJefe = Duration(milliseconds: 300);

  /// Sombra sólida inferior, sin desenfoque.
  static List<BoxShadow> sombraSolida(double desplazamiento) => [
    BoxShadow(color: colorSombraSolida, offset: Offset(0, desplazamiento)),
  ];

  /// Duración de las transiciones cortas. Con "reducir animaciones" es cero.
  static Duration duracion(BuildContext context, {int milisegundos = 120}) {
    return MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : Duration(milliseconds: milisegundos);
  }
}
