import 'package:abogator/core/tema/tipografia.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// (estilo, familia, peso, tamaño, interlineado) según `02-diseno-tokens.md`.
final tablaFigma = <(String, TextStyle, String, FontWeight, double, double)>[
  ('Display', TipografiaBase.display, 'Fredoka', FontWeight.w700, 34, 40),
  ('H1', TipografiaBase.h1, 'Fredoka', FontWeight.w700, 26, 32),
  ('H2', TipografiaBase.h2, 'Fredoka', FontWeight.w600, 20, 26),
  ('H3', TipografiaBase.h3, 'Fredoka', FontWeight.w600, 17, 22),
  ('Cuerpo/Grande', TipografiaBase.cuerpoGrande, 'Inter', FontWeight.w400, 16, 24),
  ('Cuerpo/Base', TipografiaBase.cuerpoBase, 'Inter', FontWeight.w400, 14, 20),
  ('Cuerpo/Énfasis', TipografiaBase.cuerpoEnfasis, 'Inter', FontWeight.w600, 14, 20),
  ('Etiqueta', TipografiaBase.etiqueta, 'Inter', FontWeight.w600, 12, 16),
  ('Leyenda', TipografiaBase.leyenda, 'Inter', FontWeight.w500, 11, 14),
  ('Botón', TipografiaBase.boton, 'Fredoka', FontWeight.w600, 16, 20),
  ('Código', TipografiaBase.codigo, 'JetBrains Mono', FontWeight.w400, 12, 18),
];

void main() {
  test('hay 11 estilos de texto', () {
    expect(tablaFigma, hasLength(11));
  });

  for (final (nombre, estilo, familia, peso, tamano, interlineado) in tablaFigma) {
    test('$nombre usa $familia $tamano/$interlineado', () {
      expect(estilo.fontFamily, familia);
      expect(estilo.fontWeight, peso);
      expect(estilo.fontSize, tamano);
      expect(estilo.fontSize! * estilo.height!, closeTo(interlineado, 0.001));
    });
  }

  test('EstilosTexto.crear aplica el color sin cambiar tamaños', () {
    const color = Color(0xFF123456);
    final estilos = EstilosTexto.crear(colorTexto: color, fuente: fuenteSinDescarga);
    expect(estilos.h1.color, color);
    expect(estilos.h1.fontSize, 26);
    expect(estilos.codigo.fontFamily, 'JetBrains Mono');
  });
}
