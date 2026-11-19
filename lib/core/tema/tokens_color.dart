import 'package:material_ui/material_ui.dart';

/// Representación `#RRGGBB` de un color (para mostrar o depurar tokens).
extension ColorComoHex on Color {
  String get comoHex {
    final rgb = toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}

/// Tokens de color del tema (valores de Figma).
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
    required this.bordeControl,
    required this.accionPrimaria,
    required this.accionSecundaria,
    required this.accionAcento,
    required this.estadoLegal,
    required this.estadoIlegal,
    required this.estadoCondicional,
    required this.estadoEscalar,
    required this.focoAnillo,
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

  /// borde/control: bordes de campos, interruptores inactivos, puntos del
  /// paginador y corazón vacío (contraste ≥ 3:1).
  final Color bordeControl;

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

  /// estado/condicional: "Legal con condiciones" y barra de Reputación.
  final Color estadoCondicional;

  /// estado/escalar: "Escalar al área jurídica".
  final Color estadoEscalar;

  /// foco/anillo: anillo de foco con teclado.
  final Color focoAnillo;

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
    bordeControl: Color(0xFF64748B),
    accionPrimaria: Color(0xFF1F4E35),
    accionSecundaria: Color(0xFF0F294A),
    accionAcento: Color(0xFF9A5A1C),
    estadoLegal: Color(0xFF186B40),
    estadoIlegal: Color(0xFFB52426),
    estadoCondicional: Color(0xFF2B5FA8),
    estadoEscalar: Color(0xFF6B4BA1),
    focoAnillo: Color(0xFF2B5FA8),
  );

  /// Los valores oscuros de borde/control, estado/condicional, estado/escalar y foco/anillo
  /// son propuestos (en Figma solo existen los claros); su contraste se
  /// verifica en `test/core/tema/contraste_tokens_test.dart`.
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
    bordeControl: Color(0xFF64748B),
    accionPrimaria: Color(0xFF68B678),
    accionSecundaria: Color(0xFFE2E8F0),
    accionAcento: Color(0xFFE0A060),
    estadoLegal: Color(0xFF5CC88A),
    estadoIlegal: Color(0xFFF07070),
    estadoCondicional: Color(0xFF6FA0E8),
    estadoEscalar: Color(0xFFB9A0E8),
    focoAnillo: Color(0xFF7CB0F0),
  );

  /// Todos los tokens con su nombre de Figma (para la galería y las pruebas).
  Map<String, Color> get porNombre => {
    'fondo/app': fondoApp,
    'fondo/superficie': fondoSuperficie,
    'fondo/superficie-alt': fondoSuperficieAlt,
    'fondo/destacado': fondoDestacado,
    'texto/primario': textoPrimario,
    'texto/secundario': textoSecundario,
    'texto/en-primario': textoEnPrimario,
    'texto/acento': textoAcento,
    'borde/default': bordeDefault,
    'borde/control': bordeControl,
    'accion/primaria': accionPrimaria,
    'accion/secundaria': accionSecundaria,
    'accion/acento': accionAcento,
    'estado/legal': estadoLegal,
    'estado/ilegal': estadoIlegal,
    'estado/condicional': estadoCondicional,
    'estado/escalar': estadoEscalar,
    'foco/anillo': focoAnillo,
  };

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
    Color? bordeControl,
    Color? accionPrimaria,
    Color? accionSecundaria,
    Color? accionAcento,
    Color? estadoLegal,
    Color? estadoIlegal,
    Color? estadoCondicional,
    Color? estadoEscalar,
    Color? focoAnillo,
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
      bordeControl: bordeControl ?? this.bordeControl,
      accionPrimaria: accionPrimaria ?? this.accionPrimaria,
      accionSecundaria: accionSecundaria ?? this.accionSecundaria,
      accionAcento: accionAcento ?? this.accionAcento,
      estadoLegal: estadoLegal ?? this.estadoLegal,
      estadoIlegal: estadoIlegal ?? this.estadoIlegal,
      estadoCondicional: estadoCondicional ?? this.estadoCondicional,
      estadoEscalar: estadoEscalar ?? this.estadoEscalar,
      focoAnillo: focoAnillo ?? this.focoAnillo,
    );
  }

  @override
  TokensColor lerp(TokensColor? other, double t) {
    if (other == null) {
      return this;
    }
    Color mezclar(Color a, Color b) => Color.lerp(a, b, t)!;
    return TokensColor(
      fondoApp: mezclar(fondoApp, other.fondoApp),
      fondoSuperficie: mezclar(fondoSuperficie, other.fondoSuperficie),
      fondoSuperficieAlt: mezclar(fondoSuperficieAlt, other.fondoSuperficieAlt),
      fondoDestacado: mezclar(fondoDestacado, other.fondoDestacado),
      textoPrimario: mezclar(textoPrimario, other.textoPrimario),
      textoSecundario: mezclar(textoSecundario, other.textoSecundario),
      textoEnPrimario: mezclar(textoEnPrimario, other.textoEnPrimario),
      textoAcento: mezclar(textoAcento, other.textoAcento),
      bordeDefault: mezclar(bordeDefault, other.bordeDefault),
      bordeControl: mezclar(bordeControl, other.bordeControl),
      accionPrimaria: mezclar(accionPrimaria, other.accionPrimaria),
      accionSecundaria: mezclar(accionSecundaria, other.accionSecundaria),
      accionAcento: mezclar(accionAcento, other.accionAcento),
      estadoLegal: mezclar(estadoLegal, other.estadoLegal),
      estadoIlegal: mezclar(estadoIlegal, other.estadoIlegal),
      estadoCondicional: mezclar(estadoCondicional, other.estadoCondicional),
      estadoEscalar: mezclar(estadoEscalar, other.estadoEscalar),
      focoAnillo: mezclar(focoAnillo, other.focoAnillo),
    );
  }
}
