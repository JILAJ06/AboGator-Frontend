import 'package:abogator/core/tema/tokens_color.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Valores de la tabla de `ai/conocimiento/02-diseno-tokens.md`.
const Map<String, (int, int)> tablaFigma = {
  'fondo/app': (0xFFF8FAFC, 0xFF0B1220),
  'fondo/superficie': (0xFFFFFFFF, 0xFF162030),
  'fondo/superficie-alt': (0xFFF1F5F9, 0xFF1E2A3C),
  'fondo/destacado': (0xFFE8D8A8, 0xFF3A3424),
  'texto/primario': (0xFF222A35, 0xFFF8FAFC),
  'texto/secundario': (0xFF475569, 0xFF94A3B8),
  'texto/en-primario': (0xFFFFFFFF, 0xFF0B1220),
  'texto/acento': (0xFF8A4F17, 0xFFE0A060),
  'borde/default': (0xFFE2E8F0, 0xFF2A3850),
  'accion/primaria': (0xFF1F4E35, 0xFF68B678),
  'accion/secundaria': (0xFF0F294A, 0xFFE2E8F0),
  'accion/acento': (0xFF9A5A1C, 0xFFE0A060),
  'estado/legal': (0xFF186B40, 0xFF5CC88A),
  'estado/ilegal': (0xFFB52426, 0xFFF07070),
};

Map<String, Color> porNombre(TokensColor t) => {
  'fondo/app': t.fondoApp,
  'fondo/superficie': t.fondoSuperficie,
  'fondo/superficie-alt': t.fondoSuperficieAlt,
  'fondo/destacado': t.fondoDestacado,
  'texto/primario': t.textoPrimario,
  'texto/secundario': t.textoSecundario,
  'texto/en-primario': t.textoEnPrimario,
  'texto/acento': t.textoAcento,
  'borde/default': t.bordeDefault,
  'accion/primaria': t.accionPrimaria,
  'accion/secundaria': t.accionSecundaria,
  'accion/acento': t.accionAcento,
  'estado/legal': t.estadoLegal,
  'estado/ilegal': t.estadoIlegal,
};

void main() {
  test('hay exactamente 14 tokens', () {
    expect(porNombre(TokensColor.claro), hasLength(14));
    expect(tablaFigma, hasLength(14));
  });

  test('los tokens del modo claro coinciden con Figma', () {
    final claro = porNombre(TokensColor.claro);
    for (final MapEntry(key: nombre, value: (hex, _)) in tablaFigma.entries) {
      expect(claro[nombre]!.toARGB32(), hex, reason: nombre);
    }
  });

  test('los tokens del modo oscuro coinciden con Figma', () {
    final oscuro = porNombre(TokensColor.oscuro);
    for (final MapEntry(key: nombre, value: (_, hex)) in tablaFigma.entries) {
      expect(oscuro[nombre]!.toARGB32(), hex, reason: nombre);
    }
  });

  test('lerp en los extremos devuelve cada modo', () {
    final inicio = TokensColor.claro.lerp(TokensColor.oscuro, 0);
    final fin = TokensColor.claro.lerp(TokensColor.oscuro, 1);
    expect(inicio.fondoApp.toARGB32(), 0xFFF8FAFC);
    expect(fin.fondoApp.toARGB32(), 0xFF0B1220);
  });
}
