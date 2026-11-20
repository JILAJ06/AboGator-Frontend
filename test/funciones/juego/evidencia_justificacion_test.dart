import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/boton_veredicto.dart';
import 'package:abogator/componentes/opcion_justificacion.dart';
import 'package:abogator/componentes/panel_evidencia.dart';
import 'package:abogator/componentes/panel_justificacion.dart';
import 'package:abogator/componentes/panel_veredicto.dart';
import 'package:abogator/componentes/snippet_codigo.dart';
import 'package:abogator/componentes/tarjeta_caso.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/funciones/juego/logica_veredicto.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'ayudante_juego.dart';

/// Tarjeta 6 de spr-1-3 (Figma 15, 16 y 16b): registro_form.dart, clave 4-6.
final registro = MockTarjetas.tarjetasPorSprint['spr-1-3']![5];

/// Tarjeta 10 de spr-1-3 (Figma 17 y 18): contraseñas en texto plano, Ilegal.
final dilema = MockTarjetas.tarjetasPorSprint['spr-1-3']![9];

final normal = MockTarjetas.tarjetasPorSprint['spr-1-3']![1];

Map<String, List<Tarjeta>> mazo(List<Tarjeta> tarjetas) => {sprintMock: tarjetas};

Finder get botonEvidencia => find.byKey(const ValueKey('boton-evidencia'));

Finder linea(int n) => find.byKey(ValueKey('linea-$n'));

Finder botonDe<T extends Widget>() =>
    find.descendant(of: find.byType(T), matching: find.byType(BotonApp));

BotonApp boton<T extends Widget>(WidgetTester tester) => tester.widget<BotonApp>(botonDe<T>());

Future<void> elegir(WidgetTester tester, Veredicto v) async {
  await tester.tap(find.byWidgetPredicate((w) => w is BotonVeredicto && w.veredicto == v));
  await tester.pumpAndSettle();
}

Future<void> abrirVisor(WidgetTester tester) async {
  await tester.ensureVisible(botonEvidencia);
  await tester.pumpAndSettle();
  await tester.tap(botonEvidencia);
  await tester.pumpAndSettle();
}

Future<void> marcar(WidgetTester tester, int n) async {
  await tester.ensureVisible(linea(n));
  await tester.tap(linea(n));
  await tester.pumpAndSettle();
}

Future<void> pulsar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

PanelVeredicto panel(WidgetTester tester) =>
    tester.widget<PanelVeredicto>(find.byType(PanelVeredicto));

void main() {
  group('tarjeta con evidencia (15)', () {
    testWidgets('muestra el chip "Evidencia" y el botón de inspeccionar', (tester) async {
      await abrirJuego(tester, tarjetas: mazo([registro, normal]));
      expect(find.byType(ChipTipoTarjeta), findsOneWidget);
      expect(find.text(Textos.tipoEvidencia), findsOneWidget);
      expect(find.text(Textos.inspeccionarEvidencia), findsOneWidget);
      expect(tester.getSize(botonEvidencia).height, greaterThanOrEqualTo(48));
    });

    testWidgets('el botón abre el visor (16) con el botón deshabilitado', (tester) async {
      await abrirJuego(tester, tarjetas: mazo([registro, normal]));
      await abrirVisor(tester);
      expect(find.byType(PanelEvidencia), findsOneWidget);
      expect(find.text(Textos.inspeccionaTitulo), findsOneWidget);
      expect(find.text(Textos.inspeccionaInstruccion), findsOneWidget);
      expect(find.text('  registro_form.dart'), findsOneWidget);
      expect(find.text(Textos.marcaUnaLinea), findsOneWidget);
      expect(boton<PanelEvidencia>(tester).alPresionar, isNull);
      // Sin marcar, las líneas clave no se revelan.
      final snippet = tester.widget<SnippetCodigo>(find.byType(SnippetCodigo));
      expect(snippet.reveladas, isEmpty);
    });

    testWidgets('tocar la tarjeta (sin arrastrarla) también abre el visor', (tester) async {
      await abrirJuego(tester, tarjetas: mazo([registro, normal]));
      await tester.tapAt(tester.getTopLeft(tarjeta) + const Offset(60, 90));
      await tester.pumpAndSettle();
      expect(find.byType(PanelEvidencia), findsOneWidget);
      expect(estadoJuego(tester).respuestas, isEmpty);
    });

    testWidgets('en una tarjeta normal tocarla no abre nada', (tester) async {
      await abrirJuego(tester, tarjetas: mazo([normal, registro]));
      await tester.tapAt(tester.getTopLeft(tarjeta) + const Offset(60, 90));
      await tester.pumpAndSettle();
      expect(find.byType(PanelEvidencia), findsNothing);
      expect(find.byType(ChipTipoTarjeta), findsNothing);
    });

    testWidgets('el lector: tipo en la etiqueta y acción "Inspeccionar evidencia"', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrirJuego(tester, tarjetas: mazo([registro, normal]));
      final nodo = tester.getSemantics(tarjeta);
      expect(nodo.label, endsWith('(${Textos.conEvidenciaSemantica})'));
      final acciones = nodo
          .getSemanticsData()
          .customSemanticsActionIds!
          .map(CustomSemanticsAction.getAction)
          .map((a) => a!.label)
          .toList();
      expect(acciones, containsAll([Textos.accionInspeccionar, Textos.accionIlegal]));
      final id = nodo.getSemanticsData().customSemanticsActionIds!.firstWhere(
        (i) => CustomSemanticsAction.getAction(i)!.label == Textos.accionInspeccionar,
      );
      nodo.owner!.performAction(nodo.id, SemanticsAction.customAction, id);
      await tester.pumpAndSettle();
      expect(find.byType(PanelEvidencia), findsOneWidget);
      semantica.dispose();
    });
  });

  group('visor de evidencia (16 y 16b)', () {
    testWidgets('marcar la línea clave → 16b, chip de bonus y "Volver y decidir"', (tester) async {
      await abrirJuego(tester, tarjetas: mazo([registro, normal]));
      await abrirVisor(tester);
      await marcar(tester, 4);
      expect(find.text(Textos.lineaMarcadaTitulo), findsOneWidget);
      expect(find.text(registro.evidencia!.mensajeAcierto), findsOneWidget);
      expect(find.byType(ChipBonusEvidencia), findsOneWidget);
      expect(find.text(Textos.evidenciaCorrectaBonus), findsOneWidget);
      final snippet = tester.widget<SnippetCodigo>(find.byType(SnippetCodigo));
      expect(snippet.reveladas, {4, 5, 6});
      expect(snippet.marcadas, {4});
      expect(snippet.alMarcar, isNull, reason: 'se marca una sola vez');
      expect(estadoJuego(tester).evidenciaMarcada, {registro.id: true});
      await pulsar(tester, botonDe<PanelEvidencia>());
      expect(find.byType(PanelEvidencia), findsNothing);
      // El foco vuelve al botón de evidencia.
      final enFoco = FocusManager.instance.primaryFocus!.context!;
      expect(enFoco.findAncestorWidgetOfExactType<BotonEvidencia>(), isNotNull);
    });

    testWidgets('marcó bien y acierta → Bonus (12b) con +15 XP y 1 acierto', (tester) async {
      await abrirJuego(tester, tarjetas: mazo([registro, normal]));
      await abrirVisor(tester);
      await marcar(tester, 5);
      await pulsar(tester, botonDe<PanelEvidencia>());
      await elegir(tester, Veredicto.ilegal);
      expect(panel(tester).tipo, TipoPanelVeredicto.bonus);
      expect(find.text('+15 XP en total  ·  +5 monedas'), findsOneWidget);
      expect(find.text(registro.explicacion), findsOneWidget);
      final e = estadoJuego(tester);
      expect((e.xp, e.monedas, e.vidas), (15, 5, 5));
      expect(e.resultados.single.bonus, isTrue);
      // Acierto es acierto: el bonus no cambia el conteo de las estrellas.
      expect(e.aciertos, 1);
      expect(e.estadoStartup, isNot(e.estadoInicial));
    });

    testWidgets('marcó bien pero falla el veredicto → 14 sin bonus', (tester) async {
      await abrirJuego(tester, tarjetas: mazo([registro, normal]));
      await abrirVisor(tester);
      await marcar(tester, 4);
      await pulsar(tester, botonDe<PanelEvidencia>());
      await elegir(tester, Veredicto.legal);
      expect(panel(tester).tipo, TipoPanelVeredicto.incorrecto);
      final e = estadoJuego(tester);
      expect((e.xp, e.vidas), (0, 4));
      expect(e.resultados.single.bonus, isFalse);
    });

    testWidgets('línea equivocada → "Esa no es la línea clave", sin chip ni bonus', (tester) async {
      await abrirJuego(tester, tarjetas: mazo([registro, normal]));
      await abrirVisor(tester);
      await marcar(tester, 1);
      expect(find.text(Textos.lineaEquivocadaTitulo), findsOneWidget);
      expect(find.text(registro.evidencia!.mensajeFallo), findsOneWidget);
      expect(find.byType(ChipBonusEvidencia), findsNothing);
      expect(find.text(Textos.volverYDecidir), findsOneWidget);
      expect(estadoJuego(tester).evidenciaMarcada, {registro.id: false});
      await pulsar(tester, botonDe<PanelEvidencia>());
      await elegir(tester, Veredicto.ilegal);
      expect(panel(tester).tipo, TipoPanelVeredicto.correcto);
      expect(find.text('+10 XP  ·  +5 monedas'), findsOneWidget);
      expect(estadoJuego(tester).xp, 10);
    });

    testWidgets('sin inspeccionar se puede deslizar: acierto normal sin bonus', (tester) async {
      await abrirJuego(tester, tarjetas: mazo([registro, normal]));
      await tester.drag(tarjeta, const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(panel(tester).tipo, TipoPanelVeredicto.correcto);
      expect(estadoJuego(tester).xp, 10);
    });

    testWidgets('al reabrir se ve el resultado y no se puede cambiar', (tester) async {
      await abrirJuego(tester, tarjetas: mazo([registro, normal]));
      await abrirVisor(tester);
      await marcar(tester, 1);
      await pulsar(tester, botonDe<PanelEvidencia>());
      await abrirVisor(tester);
      expect(find.text(Textos.lineaEquivocadaTitulo), findsOneWidget);
      await marcar(tester, 4);
      expect(find.text(Textos.lineaEquivocadaTitulo), findsOneWidget);
      expect(estadoJuego(tester).evidenciaMarcada, {registro.id: false});
      expect(estadoJuego(tester).lineasMarcadas[registro.id], [1]);
    });

    testWidgets('se cierra sin marcar con Esc, atrás o tocando fuera, y se puede reabrir', (
      tester,
    ) async {
      await abrirJuego(tester, tarjetas: mazo([registro, normal]));
      await abrirVisor(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(PanelEvidencia), findsNothing);
      await abrirVisor(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(PanelEvidencia), findsNothing);
      await abrirVisor(tester);
      await tester.tapAt(const Offset(195, 20));
      await tester.pumpAndSettle();
      expect(find.byType(PanelEvidencia), findsNothing);
      expect(estadoJuego(tester).evidenciaMarcada, isEmpty);
      await abrirVisor(tester);
      expect(find.text(Textos.inspeccionaTitulo), findsOneWidget);
      // La barrera es el velo al 40 % y sí se puede tocar para cerrar.
      final barrera = tester
          .widgetList<ModalBarrier>(find.byType(ModalBarrier))
          .where((b) => b.color != null)
          .last;
      expect(barrera.color, const Color(0x660B1220));
      expect(barrera.dismissible, isTrue);
    });

    testWidgets('arrastrar en vertical marca varias líneas y resalta las marcadas', (tester) async {
      await abrirJuego(tester, tarjetas: mazo([registro, normal]));
      await abrirVisor(tester);
      await tester.ensureVisible(linea(2));
      final gesto = await tester.startGesture(tester.getCenter(linea(2)));
      await gesto.moveTo(tester.getCenter(linea(3)));
      await gesto.moveTo(tester.getCenter(linea(4)));
      await gesto.up();
      await tester.pumpAndSettle();
      expect(estadoJuego(tester).lineasMarcadas[registro.id], [2, 3, 4]);
      expect(estadoJuego(tester).evidenciaMarcada[registro.id], isTrue);
      expect(tester.widget<SnippetCodigo>(find.byType(SnippetCodigo)).marcadas, {2, 3, 4});
    });

    testWidgets('teclado: flechas mueven el foco entre líneas y Enter marca', (tester) async {
      await abrirJuego(tester, tarjetas: mazo([registro, normal]));
      await abrirVisor(tester);
      Focus.of(tester.element(linea(2))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(find.byKey(const ValueKey('foco-linea-4')), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(estadoJuego(tester).lineasMarcadas[registro.id], [3]);
      expect(find.text(Textos.lineaEquivocadaTitulo), findsOneWidget);
    });

    testWidgets('el título tiene el foco y las líneas se leen con su estado', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrirJuego(tester, tarjetas: mazo([registro, normal]));
      await abrirVisor(tester);
      final enFoco = FocusManager.instance.primaryFocus!.context!;
      expect(enFoco.widget, isNot(isA<SnippetCodigo>()));
      expect(
        enFoco.findAncestorWidgetOfExactType<PanelEvidencia>(),
        isNotNull,
        reason: 'el foco va al visor',
      );
      expect(find.bySemanticsLabel(Textos.inspeccionaTitulo), findsOneWidget);
      expect(
        find.bySemanticsLabel('Línea 4: Checkbox(value: true, // pre-marcado; no marcada'),
        findsOneWidget,
      );
      await marcar(tester, 4);
      expect(
        find.bySemanticsLabel(
          'Línea 4: Checkbox(value: true, // pre-marcado; marcada; línea clave',
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(Textos.lineaMarcadaTitulo), findsOneWidget);
      semantica.dispose();
    });
  });

  group('tarjeta de dilema (17) y justificación (18)', () {
    testWidgets('la tarjeta muestra el chip "Dilema ×2" y el aviso', (tester) async {
      await abrirJuego(tester, tarjetas: mazo([dilema, normal]));
      expect(find.text(Textos.tipoDilema), findsOneWidget);
      expect(find.byType(AvisoDilema), findsOneWidget);
      expect(find.text(Textos.avisoDilema), findsOneWidget);
    });

    testWidgets('tras el veredicto se abre la justificación, no el panel de veredicto', (
      tester,
    ) async {
      await abrirJuego(tester, tarjetas: mazo([dilema, normal]));
      await elegir(tester, Veredicto.ilegal);
      expect(find.byType(PanelJustificacion), findsOneWidget);
      expect(find.byType(PanelVeredicto), findsNothing);
      expect(find.text('Dictaste: ILEGAL'), findsOneWidget);
      expect(find.text(Textos.porQueIlegal), findsOneWidget);
      expect(find.text(Textos.justificacionSubtitulo), findsOneWidget);
      expect(find.byType(OpcionJustificacion), findsNWidgets(3));
      // Aún no se califica nada y "Confirmar" está deshabilitado.
      expect(estadoJuego(tester).respuestas, isEmpty);
      expect(boton<PanelJustificacion>(tester).alPresionar, isNull);
    });

    for (final (v, chip, pregunta) in [
      (Veredicto.legal, 'Dictaste: LEGAL', Textos.porQueLegal),
      (Veredicto.ilegal, 'Dictaste: ILEGAL', Textos.porQueIlegal),
      (Veredicto.condicional, 'Dictaste: CON CONDICIONES', Textos.porQueCondicional),
      (Veredicto.escalar, 'Dictaste: A JURÍDICO', Textos.porQueEscalar),
    ]) {
      testWidgets('${v.name} con botón: "$pregunta"', (tester) async {
        await abrirJuego(tester, tarjetas: mazo([dilema, normal]));
        await elegir(tester, v);
        expect(find.text(chip), findsOneWidget);
        expect(find.text(pregunta), findsOneWidget);
      });
    }

    for (final (v, arrastre) in [
      (Veredicto.ilegal, const Offset(-300, 0)),
      (Veredicto.legal, const Offset(300, 0)),
      (Veredicto.condicional, const Offset(0, -300)),
      (Veredicto.escalar, const Offset(0, 300)),
    ]) {
      testWidgets('${v.name} con swipe también pide la justificación', (tester) async {
        await abrirJuego(tester, tarjetas: mazo([dilema, normal]));
        await tester.drag(tarjeta, arrastre);
        await tester.pumpAndSettle();
        expect(tester.widget<PanelJustificacion>(find.byType(PanelJustificacion)).veredicto, v);
      });
    }

    testWidgets('elegir solo selecciona; confirmar con ambas correctas → 12b con +10 monedas', (
      tester,
    ) async {
      await abrirJuego(tester, tarjetas: mazo([dilema, normal]));
      await elegir(tester, Veredicto.ilegal);
      await pulsar(tester, find.byType(OpcionJustificacion).first);
      expect(find.byType(PanelJustificacion), findsOneWidget);
      expect(find.byType(PanelVeredicto), findsNothing);
      final opciones = tester.widgetList<OpcionJustificacion>(find.byType(OpcionJustificacion));
      expect(opciones.map((o) => o.seleccionada), [true, false, false]);
      expect(boton<PanelJustificacion>(tester).alPresionar, isNotNull);
      // Se puede cambiar de opción antes de confirmar.
      await pulsar(tester, find.byType(OpcionJustificacion).at(1));
      await pulsar(tester, find.byType(OpcionJustificacion).first);
      await pulsar(tester, botonDe<PanelJustificacion>());
      expect(find.byType(PanelJustificacion), findsNothing);
      expect(panel(tester).tipo, TipoPanelVeredicto.bonus);
      expect(find.text('+15 XP en total  ·  +10 monedas'), findsOneWidget);
      expect(find.text(dilema.explicacion), findsOneWidget);
      final e = estadoJuego(tester);
      expect((e.xp, e.monedas, e.vidas, e.aciertos), (15, 10, 5, 1));
      expect(e.resultados.single.bonus, isTrue);
    });

    testWidgets('veredicto correcto con justificación equivocada → Correcto con explicación', (
      tester,
    ) async {
      await abrirJuego(tester, tarjetas: mazo([dilema, normal]));
      await elegir(tester, Veredicto.ilegal);
      await pulsar(tester, find.byType(OpcionJustificacion).at(2));
      await pulsar(tester, botonDe<PanelJustificacion>());
      expect(panel(tester).tipo, TipoPanelVeredicto.correcto);
      expect(panel(tester).microPregunta, isNull);
      expect(find.text('+10 XP  ·  +5 monedas'), findsOneWidget);
      expect(find.text(Textos.porQue), findsOneWidget);
      final e = estadoJuego(tester);
      expect((e.xp, e.monedas), (10, 5));
      expect(e.resultados.single.bonus, isFalse);
    });

    testWidgets('veredicto equivocado → 14 aunque la justificación sea la correcta', (
      tester,
    ) async {
      await abrirJuego(tester, tarjetas: mazo([dilema, normal]));
      await elegir(tester, Veredicto.legal);
      await pulsar(tester, find.byType(OpcionJustificacion).first);
      await pulsar(tester, botonDe<PanelJustificacion>());
      expect(panel(tester).tipo, TipoPanelVeredicto.incorrecto);
      final e = estadoJuego(tester);
      expect((e.xp, e.monedas, e.vidas), (0, 0, 4));
      expect(e.falladas, [dilema.id]);
    });

    testWidgets('Escalar sin hacer falta → parcial (12c) aunque la justificación sea correcta', (
      tester,
    ) async {
      await abrirJuego(tester, tarjetas: mazo([dilema, normal]));
      await elegir(tester, Veredicto.escalar);
      await pulsar(tester, find.byType(OpcionJustificacion).first);
      await pulsar(tester, botonDe<PanelJustificacion>());
      expect(panel(tester).tipo, TipoPanelVeredicto.parcial);
      expect(estadoJuego(tester).xp, LogicaVeredicto.xpParcial);
    });

    testWidgets('no se cierra con Esc, atrás ni tocando fuera', (tester) async {
      await abrirJuego(tester, tarjetas: mazo([dilema, normal]));
      await elegir(tester, Veredicto.ilegal);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(195, 20));
      await tester.pumpAndSettle();
      expect(find.byType(PanelJustificacion), findsOneWidget);
      expect(estadoJuego(tester).respuestas, isEmpty);
    });

    testWidgets('el título tiene el foco y anuncia el veredicto y la pregunta', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrirJuego(tester, tarjetas: mazo([dilema, normal]));
      await elegir(tester, Veredicto.ilegal);
      expect(find.bySemanticsLabel('Dictaste ILEGAL. ¿Por qué es ilegal?'), findsOneWidget);
      final enFoco = FocusManager.instance.primaryFocus!.context!;
      expect(enFoco.findAncestorWidgetOfExactType<PanelJustificacion>(), isNotNull);
      await pulsar(tester, find.byType(OpcionJustificacion).first);
      expect(find.bySemanticsLabel(RegExp(r'^Opción 1 de 3: .*; seleccionada$')), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp(r'^Opción 2 de 3: .*; no seleccionada$')),
        findsOneWidget,
      );
      semantica.dispose();
    });
  });

  group('sin desbordes', () {
    for (final (tamano, escala) in [
      (const Size(390, 844), 1.0),
      (const Size(390, 844), 2.0),
      (const Size(360, 640), 2.0),
      (const Size(320, 640), 1.0),
      (const Size(320, 640), 2.0),
    ]) {
      for (final brillo in Brightness.values) {
        final nombre = '${tamano.width.toInt()}×${tamano.height.toInt()} ${escala}x ${brillo.name}';
        Future<void> preparar(WidgetTester tester, List<Tarjeta> tarjetas) async {
          tester.platformDispatcher.textScaleFactorTestValue = escala;
          tester.platformDispatcher.platformBrightnessTestValue = brillo;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
          await abrirJuego(tester, tamano: tamano, tarjetas: mazo(tarjetas));
          expect(tester.takeException(), isNull);
        }

        testWidgets('evidencia $nombre', (tester) async {
          await preparar(tester, [registro, normal]);
          // Con texto grande el botón queda dentro del desplazamiento de la
          // tarjeta: se abre tocando la tarjeta.
          await tester.ensureVisible(find.byKey(const ValueKey('etiqueta-caso')));
          await tester.pumpAndSettle();
          await tester.tapAt(tester.getTopLeft(tarjeta) + const Offset(40, 40));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(
            tester.getSize(find.byType(PanelEvidencia)).height,
            lessThanOrEqualTo(tamano.height),
          );
          await marcar(tester, 4);
          await tester.drag(
            find.byKey(const ValueKey('snippet-desplazable')),
            const Offset(-300, 0),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await pulsar(tester, botonDe<PanelEvidencia>());
          expect(tester.takeException(), isNull);
        });

        testWidgets('dilema $nombre', (tester) async {
          await preparar(tester, [dilema, normal]);
          await tester.ensureVisible(find.byType(BotonVeredicto).first);
          await tester.pumpAndSettle();
          await elegir(tester, Veredicto.ilegal);
          expect(tester.takeException(), isNull);
          expect(
            tester.getSize(find.byType(PanelJustificacion)).height,
            lessThanOrEqualTo(tamano.height),
          );
          await pulsar(tester, find.byType(OpcionJustificacion).first);
          await pulsar(tester, botonDe<PanelJustificacion>());
          expect(tester.takeException(), isNull);
          expect(find.byType(PanelVeredicto), findsOneWidget);
        });
      }
    }

    testWidgets('la tarjeta de evidencia y la de dilema caben sin desbordes', (tester) async {
      for (final t in [registro, dilema]) {
        await abrirJuego(tester, tarjetas: mazo([t]));
        expect(tester.takeException(), isNull, reason: t.id);
        expect(find.byType(TarjetaCaso), findsOneWidget);
      }
    });
  });
}
