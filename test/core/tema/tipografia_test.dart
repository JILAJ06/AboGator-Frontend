import 'package:abogator/core/tema/tipografia.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// (estilo, familia, peso, tamaño, interlineado, tracking) según Figma.
final tablaFigma = <(String, TextStyle, String, FontWeight, double, double, double?)>[
  ('Display', TipografiaBase.display, 'Fredoka', FontWeight.w700, 34, 40, null),
  ('H1', TipografiaBase.h1, 'Fredoka', FontWeight.w700, 26, 32, null),
  ('H2', TipografiaBase.h2, 'Fredoka', FontWeight.w600, 20, 26, null),
  ('H3', TipografiaBase.h3, 'Fredoka', FontWeight.w600, 17, 22, null),
  ('Cuerpo/Grande', TipografiaBase.cuerpoGrande, 'Inter', FontWeight.w400, 16, 24, null),
  ('Cuerpo/Base', TipografiaBase.cuerpoBase, 'Inter', FontWeight.w400, 14, 20, null),
  ('Cuerpo/Énfasis', TipografiaBase.cuerpoEnfasis, 'Inter', FontWeight.w600, 14, 20, null),
  ('Etiqueta', TipografiaBase.etiqueta, 'Inter', FontWeight.w600, 12, 16, 0.2),
  ('Leyenda', TipografiaBase.leyenda, 'Inter', FontWeight.w500, 11, 14, 0.2),
  ('Botón', TipografiaBase.boton, 'Fredoka', FontWeight.w600, 16, 20, 0.2),
  ('Código', TipografiaBase.codigo, 'JetBrains Mono', FontWeight.w400, 12, 18, null),
];

void main() {
  test('hay 11 estilos de texto', () {
    expect(tablaFigma, hasLength(11));
  });

  for (final (nombre, estilo, familia, peso, tamano, interlineado, tracking) in tablaFigma) {
    test('$nombre usa $familia $tamano/$interlineado', () {
      expect(estilo.fontFamily, familia);
      expect(estilo.fontWeight, peso);
      expect(estilo.fontSize, tamano);
      expect(estilo.fontSize! * estilo.height!, closeTo(interlineado, 0.001));
      expect(estilo.letterSpacing, tracking);
    });
  }

  test('EstilosTexto.crear aplica el color sin cambiar tamaños', () {
    const color = Color(0xFF123456);
    final estilos = EstilosTexto.crear(colorTexto: color);
    expect(estilos.h1.color, color);
    expect(estilos.h1.fontSize, 26);
    expect(estilos.boton.letterSpacing, 0.2);
    expect(estilos.codigo.fontFamily, 'JetBrains Mono');
  });
}
