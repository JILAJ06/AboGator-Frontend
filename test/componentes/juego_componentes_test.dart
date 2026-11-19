import 'package:abogator/componentes/acciones_veredicto.dart';
import 'package:abogator/componentes/barra_comodines.dart';
import 'package:abogator/componentes/barra_juego.dart';
import 'package:abogator/componentes/barra_progreso.dart';
import 'package:abogator/componentes/boton_cerrar.dart';
import 'package:abogator/componentes/boton_veredicto.dart';
import 'package:abogator/componentes/pila_tarjetas.dart';
import 'package:abogator/componentes/sello_veredicto.dart';
import 'package:abogator/componentes/tarjeta_caso.dart';
import 'package:abogator/componentes/tinte_veredicto.dart';
import 'package:abogator/core/tema/colores_marca.dart';
import 'package:abogator/core/tema/efectos.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

BoxDecoration decoDe(WidgetTester tester, Finder finder) {
  final w = tester.widget(finder);
  return switch (w) {
    Container(:final decoration?) => decoration as BoxDecoration,
    Container(:final color) => BoxDecoration(color: color),
    DecoratedBox(:final decoration) => decoration as BoxDecoration,
    _ => throw StateError('sin decoración'),
  };
}

Widget tarjetaDePrueba({Color color = ColoresModulo.licenciasYPropiedadIntelectual}) => SizedBox(
  width: TarjetaCaso.ancho,
  height: TarjetaCaso.alto,
  child: TarjetaCaso(
    etiquetaCaso: 'CASO 4 · OSS',
    colorModulo: color,
    iniciales: 'DJ',
    personaje: 'Dev Junior',
    rol: 'Backend',
    texto: '¿La copio?',
  ),
);

void main() {
  group('BarraJuego', () {
    enAmbosModos('Salir, "Sprint 3 · Tarjeta 5 de 10", barra al 50 % y vidas', (
      tester,
      brillo,
    ) async {
      final semantica = tester.ensureSemantics();
      var salidas = 0;
      await montar(
        tester,
        SizedBox(
          width: 390,
          child: BarraJuego(
            numeroSprint: 3,
            actual: 5,
            total: 10,
            vidas: 4,
            alSalir: () => salidas++,
          ),
        ),
        brillo: brillo,
      );
      expect(find.text('Sprint 3 · Tarjeta 5 de 10'), findsOneWidget);
      expect(tester.widget<BarraProgreso>(find.byType(BarraProgreso)).valor, 0.5);
      expect(find.text('4'), findsOneWidget);
      expect(tester.getSize(find.byType(BarraJuego)).height, greaterThanOrEqualTo(56));
      expect(
        tester.getSemantics(find.bySemanticsLabel(Textos.salir)),
        isSemantics(isButton: true, hasTapAction: true),
      );
      await tester.tap(find.byType(BotonCerrar));
      expect(salidas, 1);
      esperarSoloColoresDelTema(tester, brillo);
      semantica.dispose();
    });

    testWidgets('la barra de progreso se puede medir dentro de un IntrinsicHeight', (tester) async {
      await montar(
        tester,
        const SizedBox(
          width: 300,
          child: IntrinsicHeight(child: BarraProgreso(valor: 0.3, etiquetaSemantica: 'p')),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(BarraProgreso)).height, BarraProgreso.alto);
    });
  });

  group('TarjetaCaso', () {
    enAmbosModos('estilo de Figma: radio 28, sombra, chip, avatar 48, globo y pista', (
      tester,
      brillo,
    ) async {
      final semantica = tester.ensureSemantics();
      await montar(tester, tarjetaDePrueba(), brillo: brillo);
      final t = tokensDe(brillo);
      final tarjeta = decoDe(tester, find.byKey(const ValueKey('tarjeta-caso')));
      expect(tarjeta.color, t.fondoSuperficie);
      expect(tarjeta.borderRadius, BorderRadius.circular(28));
      expect(tarjeta.boxShadow, EfectosApp.sombraTarjetaCaso);
      final chip = decoDe(tester, find.byKey(const ValueKey('etiqueta-caso')));
      expect(chip.color, ColoresModulo.licenciasYPropiedadIntelectual.withValues(alpha: 0.14));
      expect(tester.widget<Text>(find.text('CASO 4 · OSS')).style!.color, t.textoAcento);
      expect(tester.getSize(find.byKey(const ValueKey('circulo-avatar'))), const Size.square(48));
      expect(find.text('DJ'), findsOneWidget);
      final globo = decoDe(tester, find.byKey(const ValueKey('globo-caso')));
      expect(globo.color, t.fondoSuperficieAlt);
      expect(
        globo.borderRadius,
        const BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      );
      final texto = tester.widget<Text>(find.text('¿La copio?')).style!;
      expect(texto.fontSize, 17);
      expect(texto.height! * 17, closeTo(25, 0.001));
      Color colorDe(String s) => tester.widget<Text>(find.text(s)).style!.color!;
      expect(colorDe(Textos.casoPistaIlegal), t.estadoIlegal);
      expect(colorDe(Textos.casoPistaLegal), t.estadoLegal);
      expect(colorDe(Textos.casoPistaCondicional), t.estadoCondicional);
      expect(colorDe(Textos.casoPistaEscalar), t.estadoEscalar);
      // Se lee como "personaje, rol: texto"; la pista no se lee.
      expect(find.bySemanticsLabel('Dev Junior, Backend: ¿La copio?'), findsOneWidget);
      expect(find.bySemanticsLabel(Textos.casoPistaLegal), findsNothing);
      esperarSoloColoresDelTema(tester, brillo);
      semantica.dispose();
    });

    testWidgets('con texto al 200 % y poco alto, el contenido se desplaza sin desbordes', (
      tester,
    ) async {
      await montar(
        tester,
        const SizedBox(
          width: 280,
          height: TarjetaCaso.altoMinimo,
          child: TarjetaCaso(
            etiquetaCaso: 'CASO 4 · FINALIDADES SECUNDARIAS',
            colorModulo: ColoresModulo.proteccionDeDatos,
            iniciales: 'PO',
            personaje: 'Product Owner',
            rol: 'Equipo de Producto',
            texto: 'Un texto largo de caso que no cabe en una tarjeta baja con texto grande.',
          ),
        ),
        escalaTexto: 2,
      );
      expect(tester.takeException(), isNull);
    });

    test('el alto mínimo crece con el texto dinámico', () {
      expect(TarjetaCaso.altoMinimoPara(TextScaler.noScaling), closeTo(TarjetaCaso.altoMinimo, 1));
      expect(
        TarjetaCaso.altoMinimoPara(const TextScaler.linear(2)),
        greaterThan(TarjetaCaso.altoMinimo),
      );
    });

    test('contraste ≥ 4.5:1: chip del caso sobre los 5 colores y pistas, en ambos modos', () {
      for (final t in [TokensColor.claro, TokensColor.oscuro]) {
        for (final color in ColoresModulo.enOrden) {
          final fondo = Color.alphaBlend(
            color.withValues(alpha: EfectosApp.opacidadEtiquetaCaso),
            t.fondoSuperficie,
          );
          expect(
            Contraste.razon(t.textoAcento, fondo),
            greaterThanOrEqualTo(4.5),
            reason: '$color',
          );
        }
        for (final pista in [t.estadoIlegal, t.estadoLegal, t.estadoCondicional, t.estadoEscalar]) {
          expect(Contraste.razon(pista, t.fondoSuperficie), greaterThanOrEqualTo(4.5));
        }
      }
    });
  });

  group('PilaTarjetas', () {
    for (final (restantes, capas) in [(0, 0), (1, 1), (2, 2), (8, 2)]) {
      testWidgets('con $restantes detrás dibuja $capas capas', (tester) async {
        await montar(
          tester,
          SizedBox(width: 342, height: 460, child: PilaTarjetas(restantes: restantes)),
        );
        expect(find.byKey(const ValueKey('pila-1')), capas >= 1 ? findsOneWidget : findsNothing);
        expect(find.byKey(const ValueKey('pila-2')), capas >= 2 ? findsOneWidget : findsNothing);
      });
    }

    enAmbosModos('Pila 1: 318 al 80 % y 10 abajo; Pila 2: 294 al 50 % y 20 abajo', (
      tester,
      brillo,
    ) async {
      await montar(
        tester,
        const SizedBox(width: 342, height: 460, child: PilaTarjetas(restantes: 2)),
        brillo: brillo,
      );
      final origen = tester.getTopLeft(find.byType(PilaTarjetas));
      final p1 = tester.getRect(find.byKey(const ValueKey('pila-1')));
      final p2 = tester.getRect(find.byKey(const ValueKey('pila-2')));
      expect(p1.width, 318);
      expect(p1.top - origen.dy, 10);
      expect(p1.height, 440);
      expect(p2.width, 294);
      expect(p2.top - origen.dy, 20);
      expect(p2.height, 440);
      final opacidades = tester
          .widgetList<Opacity>(
            find.descendant(of: find.byType(PilaTarjetas), matching: find.byType(Opacity)),
          )
          .map((o) => o.opacity);
      expect(opacidades.toSet(), {0.5, 0.8});
      esperarSoloColoresDelTema(tester, brillo);
    });
  });

  group('SelloVeredicto', () {
    for (final (v, texto, tamano, angulo) in [
      (Veredicto.legal, 'LEGAL', 34.0, 14.0),
      (Veredicto.ilegal, 'ILEGAL', 34.0, -14.0),
      (Veredicto.condicional, 'CON CONDICIONES', 26.0, 0.0),
      (Veredicto.escalar, 'A JURÍDICO', 26.0, 0.0),
    ]) {
      enAmbosModos('$texto: borde 4 en su color, Fredoka $tamano y ${angulo.toInt()}°', (
        tester,
        brillo,
      ) async {
        final semantica = tester.ensureSemantics();
        await montar(tester, SelloVeredicto(veredicto: v, opacidad: 0.4), brillo: brillo);
        final t = tokensDe(brillo);
        final deco = decoDe(tester, find.byKey(ValueKey('sello-${v.name}')));
        final borde = deco.border! as Border;
        expect(borde.top.width, 4);
        expect(borde.top.color, BotonVeredicto.color(v, t));
        expect(deco.color, t.fondoSuperficie);
        expect(deco.borderRadius, BorderRadius.circular(12));
        final estilo = tester.widget<Text>(find.text(texto)).style!;
        expect(estilo.fontSize, tamano);
        expect(estilo.letterSpacing, 3);
        expect(estilo.color, BotonVeredicto.color(v, t));
        expect(SelloVeredicto.angulo(v), angulo);
        expect(
          tester
              .widget<Opacity>(
                find.descendant(of: find.byType(SelloVeredicto), matching: find.byType(Opacity)),
              )
              .opacity,
          0.4,
        );
        expect(find.bySemanticsLabel(texto), findsNothing);
        esperarSoloColoresDelTema(tester, brillo);
        semantica.dispose();
      });
    }
  });

  group('TinteVeredicto', () {
    enAmbosModos('color del veredicto con la opacidad dada; nada en reposo', (
      tester,
      brillo,
    ) async {
      await montar(
        tester,
        const SizedBox(
          width: 100,
          height: 100,
          child: TinteVeredicto(veredicto: Veredicto.legal, opacidad: 0.1),
        ),
        brillo: brillo,
      );
      final caja = tester.widget<ColoredBox>(find.byKey(const ValueKey('tinte-legal')));
      expect(caja.color, tokensDe(brillo).estadoLegal.withValues(alpha: 0.1));
      await montar(
        tester,
        const SizedBox(
          width: 100,
          height: 100,
          child: TinteVeredicto(veredicto: null, opacidad: 0),
        ),
        brillo: brillo,
      );
      expect(
        find.descendant(of: find.byType(TinteVeredicto), matching: find.byType(ColoredBox)),
        findsNothing,
      );
    });
  });

  group('AccionesVeredicto', () {
    // Con la fuente de pruebas las etiquetas son más anchas que con Inter (en
    // la app la fila mide 333), así que aquí se da más ancho.
    testWidgets('orden Ilegal, Escalar, Condicional, Legal en una fila separados 14', (
      tester,
    ) async {
      final elegidos = <Veredicto>[];
      await montar(tester, SizedBox(width: 500, child: AccionesVeredicto(alElegir: elegidos.add)));
      final botones = tester.widgetList<BotonVeredicto>(find.byType(BotonVeredicto)).toList();
      expect(botones.map((b) => b.veredicto), AccionesVeredicto.orden);
      final rects = [for (var i = 0; i < 4; i++) tester.getRect(find.byType(BotonVeredicto).at(i))];
      expect(rects[1].left - rects[0].right, 14);
      expect(rects.map((r) => r.top).toSet(), hasLength(1));
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.byType(BotonVeredicto).at(i));
      }
      expect(elegidos, AccionesVeredicto.orden);
    });

    testWidgets('en 280 de ancho con texto al 200 % se acomodan sin desbordes', (tester) async {
      await montar(
        tester,
        SizedBox(width: 280, child: AccionesVeredicto(alElegir: (_) {})),
        escalaTexto: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('BarraComodines', () {
    enAmbosModos('tres píldoras de 48 con borde accion/acento; se leen como texto', (
      tester,
      brillo,
    ) async {
      final semantica = tester.ensureSemantics();
      await montar(
        tester,
        const SizedBox(width: 390, child: BarraComodines(lupa: 2, abogado: 1, amparo: 1)),
        brillo: brillo,
      );
      for (final texto in ['Lupa ×2', 'Abogado ×1', 'Amparo ×1']) {
        expect(find.text(texto), findsOneWidget);
      }
      final pildoras = find.descendant(
        of: find.byType(BarraComodines),
        matching: find.byWidgetPredicate(
          (w) => w is Container && w.constraints?.minHeight == BarraComodines.alto,
        ),
      );
      expect(pildoras, findsNWidgets(3));
      final deco = decoDe(tester, pildoras.first);
      final borde = deco.border! as Border;
      expect(borde.top.width, 1.5);
      expect(borde.top.color, tokensDe(brillo).accionAcento);
      final lupa = tester.getSemantics(find.bySemanticsLabel('Lupa, 2 disponibles'));
      expect(lupa, isSemantics(isButton: false, hasTapAction: false));
      expect(find.bySemanticsLabel('Abogado, 1 disponible'), findsOneWidget);
      esperarSoloColoresDelTema(tester, brillo);
      semantica.dispose();
    });
  });
}
