import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('la razón de contraste coincide con WCAG en casos conocidos', () {
    expect(Contraste.razon(const Color(0xFF000000), const Color(0xFFFFFFFF)), closeTo(21, 0.01));
    expect(Contraste.razon(const Color(0xFF777777), const Color(0xFFFFFFFF)), closeTo(4.48, 0.01));
    expect(Contraste.razon(const Color(0xFF123456), const Color(0xFF123456)), 1);
  });

  for (final (modo, t) in [('claro', TokensColor.claro), ('oscuro', TokensColor.oscuro)]) {
    final fondos = {'fondo/app': t.fondoApp, 'fondo/superficie': t.fondoSuperficie};

    // Tokens nuevos de T-01 y T-02: texto/estado ≥ 4.5:1; bordes/anillos ≥ 3:1.
    final casos = <(String, Color, double)>[
      ('estado/condicional', t.estadoCondicional, Contraste.minimoTexto),
      ('estado/escalar', t.estadoEscalar, Contraste.minimoTexto),
      ('borde/control', t.bordeControl, Contraste.minimoNoTexto),
      ('foco/anillo', t.focoAnillo, Contraste.minimoNoTexto),
    ];

    for (final (nombre, color, minimo) in casos) {
      for (final MapEntry(key: nombreFondo, value: fondo) in fondos.entries) {
        test('$modo: $nombre sobre $nombreFondo ≥ $minimo:1', () {
          expect(Contraste.razon(color, fondo), greaterThanOrEqualTo(minimo));
        });
      }
    }
  }
}
