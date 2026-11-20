import 'package:abogator/componentes/aviso_informativo.dart';
import 'package:abogator/componentes/confeti_sprint.dart';
import 'package:abogator/componentes/estadisticas_sprint.dart';
import 'package:abogator/componentes/estrellas_sprint.dart';
import 'package:abogator/componentes/etiqueta_quiebra.dart';
import 'package:abogator/componentes/icono_app.dart';
import 'package:abogator/core/tema/efectos.dart';
import 'package:abogator/core/tema/iconos_app.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:abogator/datos/modelos/estado_startup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

const estadisticas = EstadisticasSprint(aciertos: 8, total: 10, xp: 95, monedas: 45);

PintorEstrella pintor(WidgetTester tester, int i) =>
    tester.widget<CustomPaint>(find.byKey(ValueKey('estrella-$i'))).painter! as PintorEstrella;

BoxDecoration decoracion(WidgetTester tester, Finder de) =>
    tester
            .widgetList<Container>(find.descendant(of: de, matching: find.byType(Container)))
            .first
            .decoration!
        as BoxDecoration;

/// Monta [hijo] con un ancho fijo (el de la columna de 342 por defecto).
Future<void> montarAncho(
  WidgetTester tester,
  Widget hijo, {
  double ancho = 342,
  Brightness brillo = Brightness.light,
  double escalaTexto = 1,
  bool reducirAnimaciones = false,
}) => montar(
  tester,
  SizedBox(width: ancho, child: hijo),
  brillo: brillo,
  escalaTexto: escalaTexto,
  reducirAnimaciones: reducirAnimaciones,
);

void main() {
  group('EstrellasSprint', () {
    enAmbosModos('36 · 46 · 36 alineadas abajo, separación 6; llenas y en contorno', (
      tester,
      brillo,
    ) async {
      await montar(tester, const EstrellasSprint(ganadas: 2), brillo: brillo);
      final t = tokensDe(brillo);
      final tamanos = [
        for (var i = 0; i < 3; i++) tester.getSize(find.byKey(ValueKey('estrella-$i'))),
      ];
      expect(tamanos, const [Size.square(36), Size.square(46), Size.square(36)]);
      final rects = [
        for (var i = 0; i < 3; i++) tester.getRect(find.byKey(ValueKey('estrella-$i'))),
      ];
      expect(rects[1].left - rects[0].right, 6);
      expect(rects[2].left - rects[1].right, 6);
      expect({for (final r in rects) r.bottom}, hasLength(1));
      expect([for (var i = 0; i < 3; i++) pintor(tester, i).llena], [true, true, false]);
      expect(
        [for (var i = 0; i < 3; i++) pintor(tester, i).color],
        [t.accionAcento, t.accionAcento, t.bordeControl],
      );
      esperarSoloColoresDelTema(tester, brillo);
    });

    testWidgets('se lee como "N de 3 estrellas"', (tester) async {
      final semantica = tester.ensureSemantics();
      for (final n in [1, 2, 3]) {
        await montar(tester, EstrellasSprint(ganadas: n));
        expect(find.bySemanticsLabel(Textos.estrellasSemantica(n, 3)), findsOneWidget);
      }
      semantica.dispose();
    });

    test('las ganadas y las no ganadas se distinguen con contraste ≥ 3:1 sobre el fondo', () {
      for (final t in [TokensColor.claro, TokensColor.oscuro]) {
        expect(Contraste.razon(t.accionAcento, t.fondoApp), greaterThanOrEqualTo(3));
        expect(Contraste.razon(t.bordeControl, t.fondoApp), greaterThanOrEqualTo(3));
      }
    });
  });

  group('EstadisticasSprint', () {
    enAmbosModos('tres tarjetas de 107, separación 10, radio 18, borde y colores', (
      tester,
      brillo,
    ) async {
      await montarAncho(tester, estadisticas, brillo: brillo);
      final t = tokensDe(brillo);
      final claves = [
        'aciertos',
        'xp',
        'monedas',
      ].map((c) => find.byKey(ValueKey('estadistica-$c')));
      final rects = [for (final c in claves) tester.getRect(c)];
      for (final r in rects) {
        expect(r.width, closeTo(107.3, 0.1));
      }
      expect(rects[1].left - rects[0].right, 10);
      final d = decoracion(tester, claves.first);
      expect(d.color, t.fondoSuperficie);
      expect(d.borderRadius, BorderRadius.circular(18));
      expect((d.border! as Border).top.color, t.bordeDefault);
      expect(find.text('8/10'), findsOneWidget);
      expect(find.text('+95'), findsOneWidget);
      expect(find.text('+45'), findsOneWidget);
      expect(find.text(Textos.estadisticaXp), findsOneWidget);
      final iconos = tester.widgetList<IconoApp>(find.byType(IconoApp)).toList();
      expect(iconos.map((i) => i.icono), [IconosApp.check, IconosApp.star, IconosApp.coin]);
      expect(iconos.map((i) => i.color), [t.estadoLegal, t.accionPrimaria, t.accionAcento]);
      expect(iconos.map((i) => i.tamano), everyElement(20));
      esperarSoloColoresDelTema(tester, brillo);
    });

    testWidgets('se lee como un bloque', (tester) async {
      final semantica = tester.ensureSemantics();
      await montarAncho(tester, estadisticas);
      expect(
        find.bySemanticsLabel('8 de 10 aciertos, 95 XP con bonus, 45 monedas'),
        findsOneWidget,
      );
      semantica.dispose();
    });

    test('contraste ≥ 4.5:1 del valor y la etiqueta sobre la tarjeta', () {
      for (final t in [TokensColor.claro, TokensColor.oscuro]) {
        expect(Contraste.razon(t.textoPrimario, t.fondoSuperficie), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.textoSecundario, t.fondoSuperficie), greaterThanOrEqualTo(4.5));
      }
    });
  });

  group('AvisoInformativo', () {
    enAmbosModos('fondo/destacado, radio 16, relleno 14×10 (12 en 19b) e ícono de 20', (
      tester,
      brillo,
    ) async {
      final t = tokensDe(brillo);
      for (final (vertical, icono) in [(10.0, IconosApp.inbox), (12.0, IconosApp.info)]) {
        await montarAncho(
          tester,
          AvisoInformativo(icono: icono, texto: Textos.avisoBuzon(2), rellenoVertical: vertical),
          brillo: brillo,
        );
        final contenedor = tester.widget<Container>(
          find
              .descendant(of: find.byType(AvisoInformativo), matching: find.byType(Container))
              .first,
        );
        expect(contenedor.padding, EdgeInsets.symmetric(horizontal: 14, vertical: vertical));
        final d = contenedor.decoration! as BoxDecoration;
        expect(d.color, t.fondoDestacado);
        expect(d.borderRadius, BorderRadius.circular(16));
        expect(tester.getSize(find.byType(AvisoInformativo)).width, 342);
        expect(tester.widget<IconoApp>(find.byType(IconoApp)).tamano, 20);
        expect(tester.widget<IconoApp>(find.byType(IconoApp)).color, t.accionSecundaria);
        esperarSoloColoresDelTema(tester, brillo);
      }
    });

    test('contraste del texto (≥ 4.5:1) y de los íconos (≥ 3:1) sobre fondo/destacado', () {
      for (final t in [TokensColor.claro, TokensColor.oscuro]) {
        expect(Contraste.razon(t.textoPrimario, t.fondoDestacado), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.accionSecundaria, t.fondoDestacado), greaterThanOrEqualTo(3));
        expect(Contraste.razon(t.textoAcento, t.fondoDestacado), greaterThanOrEqualTo(3));
      }
    });

    testWidgets('se lee el texto del aviso', (tester) async {
      final semantica = tester.ensureSemantics();
      await montarAncho(
        tester,
        const AvisoInformativo(icono: IconosApp.info, texto: Textos.avisoReinicio),
      );
      expect(find.bySemanticsLabel(Textos.avisoReinicio), findsOneWidget);
      semantica.dispose();
    });
  });

  group('EtiquetaQuiebra', () {
    enAmbosModos('píldora estado/ilegal con trending-down de 16 y texto en-primario', (
      tester,
      brillo,
    ) async {
      final t = tokensDe(brillo);
      for (final (causa, texto) in [
        (CausaQuiebra.riesgoLegal, 'RIESGO LEGAL 100%'),
        (CausaQuiebra.presupuesto, 'PRESUPUESTO 0%'),
      ]) {
        await montar(tester, EtiquetaQuiebra(causa: causa), brillo: brillo);
        expect(find.text(texto), findsOneWidget);
        final contenedor = tester.widget<Container>(
          find.descendant(of: find.byType(EtiquetaQuiebra), matching: find.byType(Container)),
        );
        expect(contenedor.padding, const EdgeInsets.symmetric(horizontal: 12, vertical: 6));
        expect((contenedor.decoration! as BoxDecoration).color, t.estadoIlegal);
        final icono = tester.widget<IconoApp>(find.byType(IconoApp));
        expect(
          (icono.icono, icono.tamano, icono.color),
          (IconosApp.trendingDown, 16, t.textoEnPrimario),
        );
        expect(tester.widget<Text>(find.text(texto)).style!.color, t.textoEnPrimario);
        esperarSoloColoresDelTema(tester, brillo);
      }
    });

    test('contraste ≥ 4.5:1 del texto sobre estado/ilegal', () {
      for (final t in [TokensColor.claro, TokensColor.oscuro]) {
        expect(Contraste.razon(t.textoEnPrimario, t.estadoIlegal), greaterThanOrEqualTo(4.5));
      }
    });

    testWidgets('se lee la causa', (tester) async {
      final semantica = tester.ensureSemantics();
      await montar(tester, const EtiquetaQuiebra(causa: CausaQuiebra.presupuesto));
      expect(find.bySemanticsLabel(Textos.etiquetaQuiebraPresupuestoSemantica), findsOneWidget);
      semantica.dispose();
    });
  });

  group('ConfetiSprint', () {
    Rect pieza(WidgetTester tester, int i) => tester.getRect(
      find.descendant(of: find.byKey(ValueKey('confeti-$i')), matching: find.byType(Container)),
    );

    testWidgets('7 piezas de 12×6 con los colores de Figma', (tester) async {
      await montarAncho(tester, const ConfetiSprint(), ancho: 390);
      expect(find.byType(ConfetiSprint), findsOneWidget);
      final piezas = tester
          .widgetList<Container>(
            find.descendant(of: find.byType(ConfetiSprint), matching: find.byType(Container)),
          )
          .toList();
      expect(piezas, hasLength(7));
      for (final p in piezas) {
        expect(p.constraints, BoxConstraints.tight(const Size(12, 6)));
        expect((p.decoration! as BoxDecoration).borderRadius, BorderRadius.circular(2));
      }
      expect(
        [for (final p in piezas) (p.decoration! as BoxDecoration).color],
        [for (final p in ConfetiSprint.piezas) p.color],
      );
      expect(ConfetiSprint.piezas.map((p) => p.color).toSet(), {
        EfectosApp.confetiAmbar,
        EfectosApp.confetiVerde,
        EfectosApp.confetiAzul,
        EfectosApp.confetiRojo,
        EfectosApp.confetiAmbarClaro,
      });
    });

    testWidgets('cae una vez en 1.2 s hasta su lugar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(child: SizedBox(width: 390, child: ConfetiSprint())),
        ),
      );
      final arriba = pieza(tester, 0).top;
      await tester.pump(const Duration(milliseconds: 600));
      final enMedio = pieza(tester, 0).top;
      await tester.pumpAndSettle();
      final final_ = pieza(tester, 0).top;
      expect(arriba, lessThan(enMedio));
      expect(enMedio, lessThanOrEqualTo(final_));
      final caja = tester.getRect(find.byType(ConfetiSprint));
      expect(pieza(tester, 4).top - caja.top, closeTo(14, 4));
    });

    testWidgets('con "reducir animaciones" aparece quieto en su lugar', (tester) async {
      await montarAncho(tester, const ConfetiSprint(), ancho: 390, reducirAnimaciones: true);
      final antes = [for (var i = 0; i < 7; i++) pieza(tester, i)];
      await tester.pump(const Duration(milliseconds: 600));
      expect([for (var i = 0; i < 7; i++) pieza(tester, i)], antes);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('no se lee ni recibe toques', (tester) async {
      final semantica = tester.ensureSemantics();
      await montarAncho(tester, const ConfetiSprint(), ancho: 390);
      final nodo = tester.getSemantics(find.byType(ConfetiSprint));
      expect(nodo.label, isEmpty);
      expect(
        find.descendant(of: find.byType(ConfetiSprint), matching: find.byType(IgnorePointer)),
        findsWidgets,
      );
      semantica.dispose();
    });

    testWidgets('en 320 de ancho no desborda', (tester) async {
      await montarAncho(tester, const ConfetiSprint(), ancho: 272);
      expect(tester.takeException(), isNull);
    });
  });

  group('sin desbordes con texto al 200 %', () {
    for (final ancho in [342.0, 312.0, 272.0]) {
      testWidgets('estadísticas, aviso y etiqueta a $ancho de ancho', (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await montarAncho(
          tester,
          Column(
            children: [
              estadisticas,
              AvisoInformativo(icono: IconosApp.inbox, texto: Textos.avisoBuzon(3)),
              const EtiquetaQuiebra(causa: CausaQuiebra.riesgoLegal),
              const EstrellasSprint(ganadas: 1),
            ],
          ),
          ancho: ancho,
          escalaTexto: 2,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}
