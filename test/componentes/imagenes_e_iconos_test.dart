import 'package:abogator/componentes/icono_app.dart';
import 'package:abogator/componentes/logo_app.dart';
import 'package:abogator/componentes/sarko_imagen.dart';
import 'package:abogator/core/tema/iconos_app.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

void main() {
  test('el catálogo tiene un ícono por cada nombre de Figma', () {
    expect(IconosApp.porNombre, hasLength(45));
    expect(IconosApp.porNombre.values.every((i) => i.fontFamily == 'Lucide'), isTrue);
  });

  test('todas las imágenes declaradas existen en el bundle', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final ruta in [
      for (final pose in PoseSarko.values) pose.ruta,
      'assets/imagenes/logo_isotipo.png',
      'assets/imagenes/logo_marca_nominativa.png',
      'assets/imagenes/icono_app.png',
    ]) {
      final datos = await rootBundle.load(ruta);
      expect(datos.lengthInBytes, greaterThan(0), reason: ruta);
    }
  });

  testWidgets('ícono sin etiqueta es decorativo; con etiqueta se anuncia', (tester) async {
    final semantica = tester.ensureSemantics();
    await montar(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconoApp(IconosApp.star),
          IconoApp(IconosApp.trophy, etiquetaSemantica: 'Trofeo'),
        ],
      ),
    );
    expect(find.bySemanticsLabel('Trofeo'), findsOneWidget);
    final decorativo = tester.getSemantics(find.byType(IconoApp).first);
    expect(decorativo.label, isNot(contains('star')));
    semantica.dispose();
  });

  enAmbosModos('Sarko: caja 4:5 y texto alternativo por pose', (tester, brillo) async {
    final semantica = tester.ensureSemantics();
    await montar(
      tester,
      Wrap(children: [for (final p in PoseSarko.values) SarkoImagen(pose: p, ancho: 88)]),
      brillo: brillo,
    );
    for (final pose in PoseSarko.values) {
      expect(find.bySemanticsLabel(pose.textoAlternativo), findsOneWidget);
    }
    expect(tester.getSize(find.byType(SarkoImagen).first), const Size(88, 110));
    semantica.dispose();
  });

  testWidgets('Sarko decorativo no se anuncia', (tester) async {
    final semantica = tester.ensureSemantics();
    await montar(tester, const SarkoImagen(pose: PoseSarko.alegre, decorativa: true));
    expect(find.bySemanticsLabel(PoseSarko.alegre.textoAlternativo), findsNothing);
    semantica.dispose();
  });

  enAmbosModos('logo: tres variantes con la etiqueta "AboGator"', (tester, brillo) async {
    final semantica = tester.ensureSemantics();
    await montar(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LogoApp(alto: 48),
          LogoApp(variante: VarianteLogo.horizontal, alto: 40),
          LogoApp(variante: VarianteLogo.isotipo, alto: 32),
        ],
      ),
      brillo: brillo,
    );
    expect(find.bySemanticsLabel('AboGator'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
    semantica.dispose();
  });
}
