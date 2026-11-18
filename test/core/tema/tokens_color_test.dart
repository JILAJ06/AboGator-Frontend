import 'package:abogator/core/tema/tokens_color.dart';
import 'package:flutter_test/flutter_test.dart';

/// Valores de `02-diseno-tokens.md` y `07-componentes.md` (claro, oscuro).
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
  'borde/control': (0xFF64748B, 0xFF64748B),
  'accion/primaria': (0xFF1F4E35, 0xFF68B678),
  'accion/secundaria': (0xFF0F294A, 0xFFE2E8F0),
  'accion/acento': (0xFF9A5A1C, 0xFFE0A060),
  'estado/legal': (0xFF186B40, 0xFF5CC88A),
  'estado/ilegal': (0xFFB52426, 0xFFF07070),
  'estado/condicional': (0xFF2B5FA8, 0xFF6FA0E8),
  'estado/escalar': (0xFF6B4BA1, 0xFFB9A0E8),
  'foco/anillo': (0xFF2B5FA8, 0xFF7CB0F0),
};

void main() {
  test('hay exactamente 18 tokens con los nombres de Figma', () {
    expect(TokensColor.claro.porNombre.keys, unorderedEquals(tablaFigma.keys));
    expect(TokensColor.oscuro.porNombre.keys, unorderedEquals(tablaFigma.keys));
  });

  test('los tokens del modo claro coinciden con la tabla', () {
    final claro = TokensColor.claro.porNombre;
    for (final MapEntry(key: nombre, value: (hex, _)) in tablaFigma.entries) {
      expect(claro[nombre]!.toARGB32(), hex, reason: nombre);
    }
  });

  test('los tokens del modo oscuro coinciden con la tabla', () {
    final oscuro = TokensColor.oscuro.porNombre;
    for (final MapEntry(key: nombre, value: (_, hex)) in tablaFigma.entries) {
      expect(oscuro[nombre]!.toARGB32(), hex, reason: nombre);
    }
  });

  test('lerp en los extremos devuelve cada modo', () {
    final inicio = TokensColor.claro.lerp(TokensColor.oscuro, 0);
    final fin = TokensColor.claro.lerp(TokensColor.oscuro, 1);
    expect(inicio.porNombre.values.map((c) => c.toARGB32()), [
      for (final c in TokensColor.claro.porNombre.values) c.toARGB32(),
    ]);
    expect(fin.focoAnillo.toARGB32(), 0xFF7CB0F0);
  });

  test('copyWith cambia solo el token indicado', () {
    final copia = TokensColor.claro.copyWith(focoAnillo: TokensColor.oscuro.focoAnillo);
    expect(copia.focoAnillo, TokensColor.oscuro.focoAnillo);
    expect(copia.bordeControl, TokensColor.claro.bordeControl);
  });
}
