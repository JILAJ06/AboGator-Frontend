import 'package:abogator/core/adaptativo/clase_pantalla.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../ayudantes/tamano_pantalla.dart';

void main() {
  group('ClasePantalla.deAncho', () {
    for (final (ancho, clase) in [
      (390.0, ClasePantalla.movil),
      (599.0, ClasePantalla.movil),
      (600.0, ClasePantalla.tablet),
      (834.0, ClasePantalla.tablet),
      (959.0, ClasePantalla.tablet),
      (960.0, ClasePantalla.ancho),
      (1194.0, ClasePantalla.ancho),
    ]) {
      test('$ancho → ${clase.name}', () => expect(ClasePantalla.deAncho(ancho), clase));
    }

    test('esTablet y esAncho', () {
      expect(ClasePantalla.movil.esTablet, isFalse);
      expect(ClasePantalla.tablet.esTablet, isTrue);
      expect(ClasePantalla.tablet.esAncho, isFalse);
      expect(ClasePantalla.ancho.esTablet, isTrue);
      expect(ClasePantalla.ancho.esAncho, isTrue);
    });
  });

  test('medidas de la rejilla de Figma', () {
    expect(MedidasAdaptativas.margen, 32);
    expect(MedidasAdaptativas.medianil, 24);
    expect(MedidasAdaptativas.riel, 104);
    expect(MedidasAdaptativas.columnaFormulario, 470);
    expect(MedidasAdaptativas.hojaLateral, 376);
  });

  testWidgets('Adaptativo usa el ancho disponible, no el de la ventana', (tester) async {
    await tamanoPantalla(tester, Tamano.tabletHorizontal);
    final vistas = <ClasePantalla>[];
    Widget anotar(double ancho) => SizedBox(
      width: ancho,
      height: 10,
      child: Adaptativo(
        constructor: (context, clase) {
          vistas.add(clase);
          return const SizedBox.shrink();
        },
      ),
    );
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(children: [anotar(390), anotar(700), anotar(1000)]),
      ),
    );
    expect(vistas, [ClasePantalla.movil, ClasePantalla.tablet, ClasePantalla.ancho]);
  });

  testWidgets('la extensión del contexto usa el ancho de la ventana', (tester) async {
    for (final (tamano, esperada) in [
      (Tamano.movil, ClasePantalla.movil),
      (Tamano.tabletMinima, ClasePantalla.tablet),
      (Tamano.tabletVertical, ClasePantalla.tablet),
      (Tamano.tabletHorizontal, ClasePantalla.ancho),
    ]) {
      await tamanoPantalla(tester, tamano);
      late ClasePantalla clase;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(size: tamano.medida),
          child: Builder(
            builder: (context) {
              clase = context.clasePantalla;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(clase, esperada, reason: tamano.name);
    }
  });
}
