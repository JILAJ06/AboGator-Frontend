/// Forma del logotipo, con las medidas en px de la exportación de Figma (≈ 1x).
enum FormaLogo {
  /// Solo el isotipo (200×200).
  isotipo('isotipo', 200, 200),

  /// Isotipo arriba y marca nominativa abajo (355×206).
  vertical('vertical', 355, 206),

  /// Isotipo a la izquierda y marca a la derecha (495×120).
  horizontal('horizontal', 495, 120),

  /// Horizontal con el lema "Educación en Legislación y Derecho Informático" (495×120).
  extendido('extendido', 495, 120);

  const FormaLogo(this.carpeta, this.anchoPx, this.altoPx);

  final String carpeta;
  final int anchoPx;
  final int altoPx;

  /// Relación ancho / alto del archivo.
  double get proporcion => anchoPx / altoPx;
}

/// Tono del logotipo según el fondo sobre el que va.
enum TonoLogo {
  /// A color, para fondos claros.
  color('color'),

  /// Una tinta oscura, para fondos claros o impresión.
  negro('negro'),

  /// Blanco/crema, para fondos oscuros (modo oscuro).
  negativo('negativo'),

  /// Para fondo azul marino (accion/secundaria claro).
  sobreAzul('sobre_azul'),

  /// Para fondo verde bosque (accion/primaria claro, Splash).
  sobreVerde('sobre_verde');

  const TonoLogo(this.sufijo);

  final String sufijo;
}

/// Rutas de las imágenes en `assets/imagenes/`.
///
/// Cada subcarpeta está declarada en `pubspec.yaml` (Flutter no entra en
/// subcarpetas con una sola entrada).
abstract final class ImagenesApp {
  static const String _base = 'assets/imagenes';

  /// Logo armado en Figma para una forma y un tono.
  static String logo(FormaLogo forma, TonoLogo tono) =>
      '$_base/logos/${forma.carpeta}/logo_${forma.carpeta}_${tono.sufijo}.png';

  /// Piezas base del logo (alta resolución, colores originales).
  static const String logoBaseIsotipo = '$_base/logos/base/logo_base_isotipo.png';
  static const String logoBaseMarcaNominativa = '$_base/logos/base/logo_base_marca_nominativa.png';

  // Poses de Sarko (fondo transparente, sin texto incrustado).
  static const String sarkoAlegre = '$_base/sarko/sarko_alegre.png';
  static const String sarkoEnojado = '$_base/sarko/sarko_enojado.png';
  static const String sarkoSorprendido = '$_base/sarko/sarko_sorprendido.png';
  static const String sarkoTriste = '$_base/sarko/sarko_triste.png';

  // Ícono de la app (para generar los íconos de Android/iOS más adelante).
  static const String iconoApp180 = '$_base/icono_app/icono_app_180.png';
  static const String iconoApp120 = '$_base/icono_app/icono_app_120.png';
  static const String iconoApp64 = '$_base/icono_app/icono_app_64.png';
  static const String iconoApp40 = '$_base/icono_app/icono_app_40.png';

  /// Todas las rutas (para las pruebas y la galería).
  static List<String> get todas => [
    for (final forma in FormaLogo.values)
      for (final tono in TonoLogo.values) logo(forma, tono),
    logoBaseIsotipo,
    logoBaseMarcaNominativa,
    sarkoAlegre,
    sarkoEnojado,
    sarkoSorprendido,
    sarkoTriste,
    iconoApp180,
    iconoApp120,
    iconoApp64,
    iconoApp40,
  ];
}
