import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

/// Familias tipográficas del diseño.
abstract final class FamiliasFuente {
  static const String fredoka = 'Fredoka';
  static const String inter = 'Inter';
  static const String jetBrainsMono = 'JetBrains Mono';
}

/// Los 11 estilos de texto de Figma, con tamaño e interlineado exactos.
///
/// En Flutter el interlineado se expresa como `height = interlineado / tamaño`.
/// Estos estilos no llevan color; el color lo pone [EstilosTexto.crear].
abstract final class TipografiaBase {
  /// Display · Fredoka Bold 34/40
  static const TextStyle display = TextStyle(
    fontFamily: FamiliasFuente.fredoka,
    fontWeight: FontWeight.w700,
    fontSize: 34,
    height: 40 / 34,
  );

  /// Título/H1 · Fredoka Bold 26/32
  static const TextStyle h1 = TextStyle(
    fontFamily: FamiliasFuente.fredoka,
    fontWeight: FontWeight.w700,
    fontSize: 26,
    height: 32 / 26,
  );

  /// Título/H2 · Fredoka SemiBold 20/26
  static const TextStyle h2 = TextStyle(
    fontFamily: FamiliasFuente.fredoka,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 26 / 20,
  );

  /// Título/H3 · Fredoka SemiBold 17/22
  static const TextStyle h3 = TextStyle(
    fontFamily: FamiliasFuente.fredoka,
    fontWeight: FontWeight.w600,
    fontSize: 17,
    height: 22 / 17,
  );

  /// Cuerpo/Grande · Inter Regular 16/24
  static const TextStyle cuerpoGrande = TextStyle(
    fontFamily: FamiliasFuente.inter,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 24 / 16,
  );

  /// Cuerpo/Base · Inter Regular 14/20
  static const TextStyle cuerpoBase = TextStyle(
    fontFamily: FamiliasFuente.inter,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 20 / 14,
  );

  /// Cuerpo/Énfasis · Inter SemiBold 14/20
  static const TextStyle cuerpoEnfasis = TextStyle(
    fontFamily: FamiliasFuente.inter,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 20 / 14,
  );

  /// Etiqueta · Inter SemiBold 12/16
  static const TextStyle etiqueta = TextStyle(
    fontFamily: FamiliasFuente.inter,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 16 / 12,
  );

  /// Leyenda · Inter Medium 11/14
  static const TextStyle leyenda = TextStyle(
    fontFamily: FamiliasFuente.inter,
    fontWeight: FontWeight.w500,
    fontSize: 11,
    height: 14 / 11,
  );

  /// Botón · Fredoka SemiBold 16/20
  static const TextStyle boton = TextStyle(
    fontFamily: FamiliasFuente.fredoka,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 20 / 16,
  );

  /// Código · JetBrains Mono Regular 12/18
  static const TextStyle codigo = TextStyle(
    fontFamily: FamiliasFuente.jetBrainsMono,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 18 / 12,
  );
}

/// Convierte un estilo base en uno con la fuente real cargada.
typedef ResolutorFuente = TextStyle Function(TextStyle estilo);

/// Carga la fuente con `google_fonts` (descarga y guarda en caché).
TextStyle fuenteGoogle(TextStyle estilo) {
  return GoogleFonts.getFont(estilo.fontFamily!, textStyle: estilo);
}

/// Deja el estilo tal cual (sin descargar nada). Se usa en pruebas.
TextStyle fuenteSinDescarga(TextStyle estilo) => estilo;

/// Cómo se resuelven las fuentes. En pruebas se sustituye por
/// [fuenteSinDescarga] para no depender de internet.
final resolutorFuenteProvider = Provider<ResolutorFuente>((ref) => fuenteGoogle);

/// Los 11 estilos ya con fuente y color, disponibles en el tema.
///
/// Se leen desde cualquier widget con `context.estilos`.
@immutable
class EstilosTexto extends ThemeExtension<EstilosTexto> {
  const EstilosTexto({
    required this.display,
    required this.h1,
    required this.h2,
    required this.h3,
    required this.cuerpoGrande,
    required this.cuerpoBase,
    required this.cuerpoEnfasis,
    required this.etiqueta,
    required this.leyenda,
    required this.boton,
    required this.codigo,
  });

  factory EstilosTexto.crear({required Color colorTexto, required ResolutorFuente fuente}) {
    TextStyle aplicar(TextStyle base) => fuente(base.copyWith(color: colorTexto));
    return EstilosTexto(
      display: aplicar(TipografiaBase.display),
      h1: aplicar(TipografiaBase.h1),
      h2: aplicar(TipografiaBase.h2),
      h3: aplicar(TipografiaBase.h3),
      cuerpoGrande: aplicar(TipografiaBase.cuerpoGrande),
      cuerpoBase: aplicar(TipografiaBase.cuerpoBase),
      cuerpoEnfasis: aplicar(TipografiaBase.cuerpoEnfasis),
      etiqueta: aplicar(TipografiaBase.etiqueta),
      leyenda: aplicar(TipografiaBase.leyenda),
      boton: aplicar(TipografiaBase.boton),
      codigo: aplicar(TipografiaBase.codigo),
    );
  }

  final TextStyle display;
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle cuerpoGrande;
  final TextStyle cuerpoBase;
  final TextStyle cuerpoEnfasis;
  final TextStyle etiqueta;
  final TextStyle leyenda;
  final TextStyle boton;
  final TextStyle codigo;

  /// Equivalencia con el `TextTheme` de Material, para que los widgets
  /// estándar también usen la tipografía del diseño.
  TextTheme comoTextTheme() {
    return TextTheme(
      displayMedium: display,
      headlineMedium: h1,
      titleLarge: h2,
      titleMedium: h3,
      bodyLarge: cuerpoGrande,
      bodyMedium: cuerpoBase,
      bodySmall: leyenda,
      labelLarge: boton,
      labelMedium: etiqueta,
      labelSmall: leyenda,
    );
  }

  @override
  EstilosTexto copyWith({
    TextStyle? display,
    TextStyle? h1,
    TextStyle? h2,
    TextStyle? h3,
    TextStyle? cuerpoGrande,
    TextStyle? cuerpoBase,
    TextStyle? cuerpoEnfasis,
    TextStyle? etiqueta,
    TextStyle? leyenda,
    TextStyle? boton,
    TextStyle? codigo,
  }) {
    return EstilosTexto(
      display: display ?? this.display,
      h1: h1 ?? this.h1,
      h2: h2 ?? this.h2,
      h3: h3 ?? this.h3,
      cuerpoGrande: cuerpoGrande ?? this.cuerpoGrande,
      cuerpoBase: cuerpoBase ?? this.cuerpoBase,
      cuerpoEnfasis: cuerpoEnfasis ?? this.cuerpoEnfasis,
      etiqueta: etiqueta ?? this.etiqueta,
      leyenda: leyenda ?? this.leyenda,
      boton: boton ?? this.boton,
      codigo: codigo ?? this.codigo,
    );
  }

  @override
  EstilosTexto lerp(EstilosTexto? other, double t) {
    if (other == null) {
      return this;
    }
    return EstilosTexto(
      display: TextStyle.lerp(display, other.display, t)!,
      h1: TextStyle.lerp(h1, other.h1, t)!,
      h2: TextStyle.lerp(h2, other.h2, t)!,
      h3: TextStyle.lerp(h3, other.h3, t)!,
      cuerpoGrande: TextStyle.lerp(cuerpoGrande, other.cuerpoGrande, t)!,
      cuerpoBase: TextStyle.lerp(cuerpoBase, other.cuerpoBase, t)!,
      cuerpoEnfasis: TextStyle.lerp(cuerpoEnfasis, other.cuerpoEnfasis, t)!,
      etiqueta: TextStyle.lerp(etiqueta, other.etiqueta, t)!,
      leyenda: TextStyle.lerp(leyenda, other.leyenda, t)!,
      boton: TextStyle.lerp(boton, other.boton, t)!,
      codigo: TextStyle.lerp(codigo, other.codigo, t)!,
    );
  }
}
