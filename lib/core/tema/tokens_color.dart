import 'package:material_ui/material_ui.dart';

/// Tokens de color del tema (valores exactos de Figma).
///
/// Se leen desde cualquier widget con `context.tokens`
/// (ver `core/utilidades/extensiones_contexto.dart`).
@immutable
class TokensColor extends ThemeExtension<TokensColor> {
  const TokensColor({
    required this.fondoApp,
    required this.fondoSuperficie,
    required this.fondoSuperficieAlt,
    required this.fondoDestacado,
    required this.textoPrimario,
    required this.textoSecundario,
    required this.textoEnPrimario,
    required this.textoAcento,
    required this.bordeDefault,
    required this.accionPrimaria,
    required this.accionSecundaria,
    required this.accionAcento,
    required this.estadoLegal,
    required this.estadoIlegal,
  });

  /// fondo/app
  final Color fondoApp;

  /// fondo/superficie
  final Color fondoSuperficie;

  /// fondo/superficie-alt
  final Color fondoSuperficieAlt;

  /// fondo/destacado
  final Color fondoDestacado;

  /// texto/primario
  final Color textoPrimario;

  /// texto/secundario
  final Color textoSecundario;

  /// texto/en-primario
  final Color textoEnPrimario;

  /// texto/acento
  final Color textoAcento;

  /// borde/default
  final Color bordeDefault;

  /// accion/primaria
  final Color accionPrimaria;

  /// accion/secundaria
  final Color accionSecundaria;

  /// accion/acento
  final Color accionAcento;

  /// estado/legal
  final Color estadoLegal;

  /// estado/ilegal
  final Color estadoIlegal;

  static const TokensColor claro = TokensColor(
    fondoApp: Color(0xFFF8FAFC),
    fondoSuperficie: Color(0xFFFFFFFF),
    fondoSuperficieAlt: Color(0xFFF1F5F9),
    fondoDestacado: Color(0xFFE8D8A8),
    textoPrimario: Color(0xFF222A35),
    textoSecundario: Color(0xFF475569),
    textoEnPrimario: Color(0xFFFFFFFF),
    textoAcento: Color(0xFF8A4F17),
    bordeDefault: Color(0xFFE2E8F0),
    accionPrimaria: Color(0xFF1F4E35),
    accionSecundaria: Color(0xFF0F294A),
    accionAcento: Color(0xFF9A5A1C),
    estadoLegal: Color(0xFF186B40),
    estadoIlegal: Color(0xFFB52426),
  );

  static const TokensColor oscuro = TokensColor(
    fondoApp: Color(0xFF0B1220),
    fondoSuperficie: Color(0xFF162030),
    fondoSuperficieAlt: Color(0xFF1E2A3C),
    fondoDestacado: Color(0xFF3A3424),
    textoPrimario: Color(0xFFF8FAFC),
    textoSecundario: Color(0xFF94A3B8),
    textoEnPrimario: Color(0xFF0B1220),
    textoAcento: Color(0xFFE0A060),
    bordeDefault: Color(0xFF2A3850),
    accionPrimaria: Color(0xFF68B678),
    accionSecundaria: Color(0xFFE2E8F0),
    accionAcento: Color(0xFFE0A060),
    estadoLegal: Color(0xFF5CC88A),
    estadoIlegal: Color(0xFFF07070),
  );

  @override
  TokensColor copyWith({
    Color? fondoApp,
    Color? fondoSuperficie,
    Color? fondoSuperficieAlt,
    Color? fondoDestacado,
    Color? textoPrimario,
    Color? textoSecundario,
    Color? textoEnPrimario,
    Color? textoAcento,
    Color? bordeDefault,
    Color? accionPrimaria,
    Color? accionSecundaria,
    Color? accionAcento,
    Color? estadoLegal,
    Color? estadoIlegal,
  }) {
    return TokensColor(
      fondoApp: fondoApp ?? this.fondoApp,
      fondoSuperficie: fondoSuperficie ?? this.fondoSuperficie,
      fondoSuperficieAlt: fondoSuperficieAlt ?? this.fondoSuperficieAlt,
      fondoDestacado: fondoDestacado ?? this.fondoDestacado,
      textoPrimario: textoPrimario ?? this.textoPrimario,
      textoSecundario: textoSecundario ?? this.textoSecundario,
      textoEnPrimario: textoEnPrimario ?? this.textoEnPrimario,
      textoAcento: textoAcento ?? this.textoAcento,
      bordeDefault: bordeDefault ?? this.bordeDefault,
      accionPrimaria: accionPrimaria ?? this.accionPrimaria,
      accionSecundaria: accionSecundaria ?? this.accionSecundaria,
      accionAcento: accionAcento ?? this.accionAcento,
      estadoLegal: estadoLegal ?? this.estadoLegal,
      estadoIlegal: estadoIlegal ?? this.estadoIlegal,
    );
  }

  @override
  TokensColor lerp(TokensColor? other, double t) {
    if (other == null) {
      return this;
    }
    return TokensColor(
      fondoApp: Color.lerp(fondoApp, other.fondoApp, t)!,
      fondoSuperficie: Color.lerp(fondoSuperficie, other.fondoSuperficie, t)!,
      fondoSuperficieAlt: Color.lerp(fondoSuperficieAlt, other.fondoSuperficieAlt, t)!,
      fondoDestacado: Color.lerp(fondoDestacado, other.fondoDestacado, t)!,
      textoPrimario: Color.lerp(textoPrimario, other.textoPrimario, t)!,
      textoSecundario: Color.lerp(textoSecundario, other.textoSecundario, t)!,
      textoEnPrimario: Color.lerp(textoEnPrimario, other.textoEnPrimario, t)!,
      textoAcento: Color.lerp(textoAcento, other.textoAcento, t)!,
      bordeDefault: Color.lerp(bordeDefault, other.bordeDefault, t)!,
      accionPrimaria: Color.lerp(accionPrimaria, other.accionPrimaria, t)!,
      accionSecundaria: Color.lerp(accionSecundaria, other.accionSecundaria, t)!,
      accionAcento: Color.lerp(accionAcento, other.accionAcento, t)!,
      estadoLegal: Color.lerp(estadoLegal, other.estadoLegal, t)!,
      estadoIlegal: Color.lerp(estadoIlegal, other.estadoIlegal, t)!,
    );
  }
}
