import 'dart:io';

import 'package:abogator/componentes/icono_app.dart';
import 'package:abogator/componentes/logo_app.dart';
import 'package:abogator/componentes/sarko_imagen.dart';
import 'package:abogator/core/recursos/imagenes_app.dart';
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

  test('ImagenesApp tiene 20 logos, 2 piezas base, 4 poses y 4 íconos de app', () {
    expect(ImagenesApp.todas, hasLength(30));
    expect(ImagenesApp.todas.toSet(), hasLength(30));
    expect(
      ImagenesApp.logo(FormaLogo.vertical, TonoLogo.sobreVerde),
      'assets/imagenes/logos/vertical/logo_vertical_sobre_verde.png',
    );
  });

  test('cada ruta existe en disco y su carpeta está declarada en pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsLinesSync().map((l) => l.trim()).toSet();
    for (final ruta in ImagenesApp.todas) {
      expect(File(ruta).existsSync(), isTrue, reason: ruta);
      final carpeta = ruta.substring(0, ruta.lastIndexOf('/') + 1);
      expect(pubspec, contains('- $carpeta'), reason: '$carpeta no está en pubspec.yaml');
    }
  });

  test('cada ruta carga desde el bundle de la app', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final ruta in ImagenesApp.todas) {
      final datos = await rootBundle.load(ruta);
      expect(datos.lengthInBytes, greaterThan(0), reason: ruta);
    }
  });

  test('las medidas de los logos coinciden con FormaLogo', () {
    for (final forma in FormaLogo.values) {
      for (final tono in TonoLogo.values) {
        final bytes = File(ImagenesApp.logo(forma, tono)).readAsBytesSync();
        final datos = ByteData.sublistView(bytes);
        expect(
          (datos.getUint32(16), datos.getUint32(20)),
          (forma.anchoPx, forma.altoPx),
          reason: '${forma.name} ${tono.name}',
        );
      }
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
    for (final imagen in tester.widgetList<Image>(find.byType(Image))) {
      expect(imagen.alignment, Alignment.bottomCenter);
      expect(imagen.fit, BoxFit.contain);
    }
    semantica.dispose();
  });

  testWidgets('Sarko decorativo no se anuncia', (tester) async {
    final semantica = tester.ensureSemantics();
    await montar(tester, const SarkoImagen(pose: PoseSarko.alegre, decorativa: true));
    expect(find.bySemanticsLabel(PoseSarko.alegre.textoAlternativo), findsNothing);
    semantica.dispose();
  });

  String archivoDe(WidgetTester tester, Finder logo) {
    final imagen = tester.widget<Image>(find.descendant(of: logo, matching: find.byType(Image)));
    return (imagen.image as AssetImage).assetName;
  }

  enAmbosModos('logo automático: color en claro y negativo en oscuro', (tester, brillo) async {
    await montar(tester, const LogoApp(), brillo: brillo);
    final esperado = brillo == Brightness.dark ? TonoLogo.negativo : TonoLogo.color;
    expect(archivoDe(tester, find.byType(LogoApp)), ImagenesApp.logo(FormaLogo.vertical, esperado));
  });

  testWidgets('logo con tono fijo usa ese archivo en cualquier modo', (tester) async {
    await montar(tester, const LogoApp(tono: TonoLogo.sobreVerde), brillo: Brightness.dark);
    expect(
      archivoDe(tester, find.byType(LogoApp)),
      ImagenesApp.logo(FormaLogo.vertical, TonoLogo.sobreVerde),
    );
  });

  testWidgets('logo: el alto sale de la proporción del archivo', (tester) async {
    for (final forma in FormaLogo.values) {
      await montar(tester, LogoApp(forma: forma, ancho: 240));
      final tamano = tester.getSize(find.byType(LogoApp));
      expect(tamano.width, 240);
      expect(tamano.height, closeTo(240 * forma.altoPx / forma.anchoPx, 0.01), reason: forma.name);
    }
  });

  testWidgets('logo: semántica "AboGator" o decorativo', (tester) async {
    final semantica = tester.ensureSemantics();
    await montar(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LogoApp(forma: FormaLogo.horizontal, ancho: 200),
          LogoApp(forma: FormaLogo.isotipo, ancho: 60, decorativo: true),
        ],
      ),
    );
    expect(find.bySemanticsLabel('AboGator'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantica.dispose();
  });
}
