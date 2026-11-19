import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/barra_juego.dart';
import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/boton_veredicto.dart';
import 'package:abogator/componentes/indicadores_startup.dart';
import 'package:abogator/componentes/panel_veredicto.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/funciones/juego/estado_juego.dart';
import 'package:abogator/funciones/juego/logica_veredicto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'ayudante_juego.dart';

Tarjeta tarjeta(
  String id,
  Veredicto correcta, {
  MicroPregunta? micro,
  ImpactoTarjeta acierto = const ImpactoTarjeta(reputacion: 5, riesgoLegal: -10),
  ImpactoTarjeta fallo = const ImpactoTarjeta(velocidad: 10, riesgoLegal: 25),
  ImpactoTarjeta parcial = const ImpactoTarjeta(presupuesto: -5, velocidad: -10),
}) => Tarjeta(
  id: id,
  tipo: TipoTarjeta.normal,
  etiquetaCaso: 'CASO $id',
  personaje: 'Dev Junior',
  rol: 'Backend',
  texto: 'Caso $id',
  respuestaCorrecta: correcta,
  explicacion: 'Acierto $id',
  explicacionFallo: 'Fallo $id',
  explicacionParcial: 'Parcial $id',
  impactoAcierto: acierto,
  impactoFallo: fallo,
  impactoParcial: parcial,
  microPregunta: micro,
);

const pregunta = MicroPregunta(
  enunciado: '¿por qué es ilegal?',
  opciones: ['Correcta', 'Incorrecta'],
  indiceCorrecto: 0,
);

/// t1: Ilegal con micro-pregunta; t2: Legal sin micro-pregunta; t3: Escalar.
Map<String, List<Tarjeta>> mazo([List<Tarjeta>? tarjetas]) => {
  sprintMock:
      tarjetas ??
      [
        tarjeta('t1', Veredicto.ilegal, micro: pregunta),
        tarjeta('t2', Veredicto.legal),
        tarjeta('t3', Veredicto.escalar),
      ],
};

Future<void> elegir(WidgetTester tester, Veredicto v) async {
  await tester.tap(find.byWidgetPredicate((w) => w is BotonVeredicto && w.veredicto == v));
  await tester.pumpAndSettle();
}

PanelVeredicto panel(WidgetTester tester) =>
    tester.widget<PanelVeredicto>(find.byType(PanelVeredicto));

Future<void> pulsarBotonDelPanel(WidgetTester tester) async {
  final boton = find.descendant(of: find.byType(PanelVeredicto), matching: find.byType(BotonApp));
  await tester.ensureVisible(boton);
  await tester.tap(boton);
  await tester.pumpAndSettle();
}

int vidasEnBarra(WidgetTester tester) => tester.widget<BarraJuego>(find.byType(BarraJuego)).vidas;

IndicadoresStartup indicadores(WidgetTester tester) =>
    tester.widget<IndicadoresStartup>(find.byType(IndicadoresStartup));

void main() {
  group('variantes del panel', () {
    testWidgets(
      'acierto con micro-pregunta (12): +10 XP, +5 monedas, indicadores y "Saltar bonus"',
      (tester) async {
        await abrirJuego(tester, tarjetas: mazo());
        await elegir(tester, Veredicto.ilegal);
        expect(panel(tester).tipo, TipoPanelVeredicto.correcto);
        expect(panel(tester).microPregunta, pregunta);
        expect(find.text('+10 XP  ·  +5 monedas'), findsOneWidget);
        expect(find.text(Textos.saltarBonus), findsOneWidget);
        final e = estadoJuego(tester);
        expect((e.xp, e.monedas, e.vidas), (10, 5, 5));
        expect(e.estadoStartup.reputacion, 65);
        expect(e.estadoStartup.riesgoLegal, 15);
        // Los indicadores de atrás muestran el cambio mientras el panel está abierto.
        expect(indicadores(tester).cambios[IndicadorStartup.riesgoLegal], -10);
        expect(indicadores(tester).estado.riesgoLegal, 15);
        // La tarjeta no avanza hasta cerrar el panel.
        expect(e.indice, 0);
      },
    );

    testWidgets('micro-pregunta acertada → Bonus (12b): +15 XP y "Continuar"', (tester) async {
      await abrirJuego(tester, tarjetas: mazo());
      await elegir(tester, Veredicto.ilegal);
      await tester.tap(find.text('Correcta'));
      await tester.pumpAndSettle();
      expect(panel(tester).tipo, TipoPanelVeredicto.bonus);
      expect(find.text('+15 XP en total  ·  +5 monedas'), findsOneWidget);
      expect(find.text('Acierto t1'), findsOneWidget);
      expect(estadoJuego(tester).xp, 15);
      expect(estadoJuego(tester).resultados.single.bonus, isTrue);
      await pulsarBotonDelPanel(tester);
      expect(find.byType(PanelVeredicto), findsNothing);
      expect(estadoJuego(tester).indice, 1);
      expect(textoActual(tester), 'Caso t2');
      expect(indicadores(tester).cambios, isEmpty);
    });

    testWidgets('micro-pregunta fallada → Correcto con explicación, +10 XP', (tester) async {
      await abrirJuego(tester, tarjetas: mazo());
      await elegir(tester, Veredicto.ilegal);
      await tester.tap(find.text('Incorrecta'));
      await tester.pumpAndSettle();
      expect(panel(tester).tipo, TipoPanelVeredicto.correcto);
      expect(panel(tester).microPregunta, isNull);
      expect(find.text('+10 XP  ·  +5 monedas'), findsOneWidget);
      expect(find.text(Textos.porQue), findsOneWidget);
      expect(find.text(Textos.continuar), findsOneWidget);
      expect(estadoJuego(tester).xp, 10);
      expect(estadoJuego(tester).resultados.single.bonus, isFalse);
    });

    testWidgets('"Saltar bonus" → Correcto con explicación', (tester) async {
      await abrirJuego(tester, tarjetas: mazo());
      await elegir(tester, Veredicto.ilegal);
      await tester.tap(find.text(Textos.saltarBonus));
      await tester.pumpAndSettle();
      expect(panel(tester).microPregunta, isNull);
      expect(find.text('Acierto t1'), findsOneWidget);
      expect(estadoJuego(tester).xp, 10);
    });

    testWidgets('acierto sin micro-pregunta: explicación y "Continuar" de una vez', (tester) async {
      await abrirJuego(tester, tarjetas: mazo([tarjeta('t2', Veredicto.legal)]));
      await elegir(tester, Veredicto.legal);
      expect(panel(tester).tipo, TipoPanelVeredicto.correcto);
      expect(panel(tester).microPregunta, isNull);
      expect(find.text(Textos.continuar), findsOneWidget);
    });

    testWidgets('parcial (12c): Escalar sin hacer falta, +3 XP y sin perder vida', (tester) async {
      await abrirJuego(tester, tarjetas: mazo());
      await elegir(tester, Veredicto.escalar);
      expect(panel(tester).tipo, TipoPanelVeredicto.parcial);
      expect(find.text('+3 XP  ·  no pierdes vida'), findsOneWidget);
      expect(find.text('Parcial t1'), findsOneWidget);
      final e = estadoJuego(tester);
      expect((e.xp, e.monedas, e.vidas), (3, 0, 5));
      expect(e.falladas, isEmpty);
      expect(vidasEnBarra(tester), 5);
      expect(e.estadoStartup.presupuesto, 65);
    });

    testWidgets('incorrecto (14): −1 vida en la barra, Riesgo +25 y va a falladas', (tester) async {
      await abrirJuego(tester, tarjetas: mazo());
      await elegir(tester, Veredicto.legal);
      expect(panel(tester).tipo, TipoPanelVeredicto.incorrecto);
      expect(find.text(Textos.incorrectoSubtitulo), findsOneWidget);
      expect(find.text('Fallo t1'), findsOneWidget);
      expect(find.text(Textos.entendido), findsOneWidget);
      final e = estadoJuego(tester);
      expect((e.xp, e.monedas, e.vidas), (0, 0, 4));
      expect(vidasEnBarra(tester), 4);
      expect(e.falladas, ['t1']);
      expect(e.estadoStartup.riesgoLegal, 50);
      expect(indicadores(tester).cambios[IndicadorStartup.riesgoLegal], 25);
    });

    testWidgets('Amparo (14b): sin perder vida, Riesgo +20, se gasta y la tarjeta es fallada', (
      tester,
    ) async {
      await abrirJuego(tester, tarjetas: mazo());
      contenedorDe(tester).read(juegoProvider(sprintMock).notifier).establecerAmparo(activo: true);
      await elegir(tester, Veredicto.legal);
      expect(panel(tester).tipo, TipoPanelVeredicto.amparo);
      expect(find.text(Textos.amparoSubtitulo), findsOneWidget);
      final e = estadoJuego(tester);
      expect(e.vidas, 5);
      expect(vidasEnBarra(tester), 5);
      expect(e.estadoStartup.riesgoLegal, 45);
      expect(e.falladas, ['t1']);
      expect(e.amparoActivo, isFalse);
      expect(e.resultados.single.tipo, TipoVeredicto.amparo);
    });
  });

  group('panel modal', () {
    testWidgets('no se cierra con Esc, atrás ni tocando fuera', (tester) async {
      await abrirJuego(tester, tarjetas: mazo());
      await elegir(tester, Veredicto.legal);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(PanelVeredicto), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(PanelVeredicto), findsOneWidget);
      await tester.tapAt(const Offset(195, 60));
      await tester.pumpAndSettle();
      expect(find.byType(PanelVeredicto), findsOneWidget);
      expect(estadoJuego(tester).indice, 0);
      await pulsarBotonDelPanel(tester);
      expect(find.byType(PanelVeredicto), findsNothing);
      expect(estadoJuego(tester).indice, 1);
    });

    testWidgets('el título se anuncia con subtítulo e impacto y tiene el foco', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrirJuego(tester, tarjetas: mazo());
      await elegir(tester, Veredicto.legal);
      expect(
        find.bySemanticsLabel(
          'Veredicto incorrecto. −1 vida · Se guarda en tu Buzón de Apelaciones. '
          'Impacto: Velocidad +10, Riesgo legal +25',
        ),
        findsOneWidget,
      );
      final enFoco = FocusManager.instance.primaryFocus!.context!;
      expect(enFoco.findAncestorWidgetOfExactType<PanelVeredicto>(), isNotNull);
      semantica.dispose();
    });

    testWidgets('el velo es #0B1220 al 40 %', (tester) async {
      await abrirJuego(tester, tarjetas: mazo());
      await elegir(tester, Veredicto.legal);
      final barrera = tester
          .widgetList<ModalBarrier>(find.byType(ModalBarrier))
          .where((b) => b.color != null)
          .last;
      expect(barrera.color, const Color(0x660B1220));
      expect(barrera.dismissible, isFalse);
    });
  });

  group('destinos al cerrar el panel', () {
    testWidgets('última tarjeta → Sprint completado', (tester) async {
      await abrirJuego(tester, tarjetas: mazo([tarjeta('t2', Veredicto.legal)]));
      await elegir(tester, Veredicto.legal);
      await pulsarBotonDelPanel(tester);
      expect(rutaActual(tester), Rutas.sprintCompletadoDe(sprintMock));
      expect(find.text(Textos.pendienteSprintCompletado), findsOneWidget);
    });

    testWidgets('vidas en 0 → Sin vidas, aunque queden tarjetas', (tester) async {
      await abrirJuego(tester, tarjetas: mazo(), vidas: 1);
      await elegir(tester, Veredicto.legal);
      expect(vidasEnBarra(tester), 0);
      await pulsarBotonDelPanel(tester);
      expect(rutaActual(tester), Rutas.sinVidas);
      expect(find.text(Textos.sinVidasPendiente), findsOneWidget);
    });

    testWidgets('Riesgo legal en 100 → quiebra, con prioridad sobre 0 vidas', (tester) async {
      await abrirJuego(
        tester,
        vidas: 1,
        tarjetas: mazo([
          tarjeta('t1', Veredicto.ilegal, fallo: const ImpactoTarjeta(riesgoLegal: 80)),
          tarjeta('t2', Veredicto.legal),
        ]),
      );
      await elegir(tester, Veredicto.legal);
      expect(estadoJuego(tester).estadoStartup.riesgoLegal, 100);
      await pulsarBotonDelPanel(tester);
      expect(rutaActual(tester), Rutas.startupQuiebraDe(sprintMock));
      expect(find.text(Textos.pendienteQuiebra), findsOneWidget);
    });

    testWidgets('Presupuesto en 0 → quiebra', (tester) async {
      await abrirJuego(
        tester,
        tarjetas: mazo([
          tarjeta('t1', Veredicto.legal, parcial: const ImpactoTarjeta(presupuesto: -70)),
          tarjeta('t2', Veredicto.legal),
        ]),
      );
      await elegir(tester, Veredicto.escalar);
      await pulsarBotonDelPanel(tester);
      expect(rutaActual(tester), Rutas.startupQuiebraDe(sprintMock));
    });
  });

  testWidgets('vibraciones: ligera al acertar, de selección en parcial y media al fallar', (
    tester,
  ) async {
    final vibraciones = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (
      llamada,
    ) async {
      if (llamada.method == 'HapticFeedback.vibrate') vibraciones.add(llamada.arguments);
      return null;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await abrirJuego(tester, tarjetas: mazo());
    await elegir(tester, Veredicto.ilegal); // correcto
    await tester.tap(find.text(Textos.saltarBonus));
    await tester.pumpAndSettle();
    await pulsarBotonDelPanel(tester);
    await elegir(tester, Veredicto.escalar); // parcial
    await pulsarBotonDelPanel(tester);
    await elegir(tester, Veredicto.legal); // incorrecto
    expect(vibraciones, [
      'HapticFeedbackType.lightImpact',
      'HapticFeedbackType.selectionClick',
      'HapticFeedbackType.mediumImpact',
    ]);
  });

  group('sin desbordes con el panel abierto', () {
    for (final (tamano, escala) in [
      (const Size(390, 844), 2.0),
      (const Size(360, 640), 2.0),
      (const Size(320, 640), 1.0),
      (const Size(320, 640), 2.0),
    ]) {
      for (final brillo in Brightness.values) {
        testWidgets('${tamano.width.toInt()}×${tamano.height.toInt()} ${escala}x ${brillo.name}', (
          tester,
        ) async {
          tester.platformDispatcher.textScaleFactorTestValue = escala;
          tester.platformDispatcher.platformBrightnessTestValue = brillo;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
          await abrirJuego(tester, tamano: tamano, tarjetas: mazo());
          await tester.ensureVisible(find.byType(BotonVeredicto).first);
          await tester.pumpAndSettle();
          await elegir(tester, Veredicto.ilegal); // micro-pregunta, la variante más alta
          expect(tester.takeException(), isNull);
          // El panel cabe en la pantalla y su contenido se desplaza.
          expect(
            tester.getSize(find.byType(PanelVeredicto)).height,
            lessThanOrEqualTo(tamano.height),
          );
          await tester.drag(find.byKey(const ValueKey('panel-desplazable')), const Offset(0, -600));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.tap(find.text(Textos.saltarBonus));
          await tester.pumpAndSettle();
          await pulsarBotonDelPanel(tester);
          expect(tester.takeException(), isNull);
          expect(estadoJuego(tester).indice, 1);
        });
      }
    }
  });
}
