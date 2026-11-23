import 'dart:async';

import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/acciones_veredicto.dart';
import 'package:abogator/componentes/barra_comodines.dart';
import 'package:abogator/componentes/barra_juego.dart';
import 'package:abogator/componentes/boton_veredicto.dart';
import 'package:abogator/componentes/indicadores_startup.dart';
import 'package:abogator/componentes/panel_veredicto.dart';
import 'package:abogator/componentes/pila_tarjetas.dart';
import 'package:abogator/componentes/sello_veredicto.dart';
import 'package:abogator/componentes/tarjeta_caso.dart';
import 'package:abogator/componentes/tinte_veredicto.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/funciones/acceso/pantalla_inicio_sesion.dart';
import 'package:abogator/funciones/juego/estado_juego.dart';
import 'package:abogator/funciones/juego/logica_swipe.dart';
import 'package:abogator/funciones/juego/mazo_swipe.dart';
import 'package:abogator/funciones/juego/pantalla_juego.dart';
import 'package:abogator/funciones/mapa/pantalla_intro_sprint.dart';
import 'package:abogator/funciones/mapa/pantalla_mapa_sprints.dart';
import 'package:abogator/funciones/vidas/pantalla_sin_vidas.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../ayudantes/sin_desbordes.dart';
import 'ayudante_juego.dart';

final tarjetasMock = MockTarjetas.tarjetasPorSprint[sprintMock]!;

/// Dos tarjetas para llegar rápido al final.
final cortas = {
  'spr-1-3': [tarjetasMock[0], tarjetasMock[1]],
};

double opacidadSello(WidgetTester tester, Veredicto v) => tester
    .widget<SelloVeredicto>(find.byWidgetPredicate((w) => w is SelloVeredicto && w.veredicto == v))
    .opacidad;

TinteVeredicto tinte(WidgetTester tester) =>
    tester.widget<TinteVeredicto>(find.byType(TinteVeredicto));

Offset desplazamientoTarjeta(WidgetTester tester) {
  final t = tester.widget<Transform>(find.byKey(const ValueKey('transformacion-tarjeta')));
  return Offset(t.transform.getTranslation().x, t.transform.getTranslation().y);
}

Future<void> arrastrar(WidgetTester tester, Offset hasta) async {
  final gesto = await tester.startGesture(tester.getCenter(tarjeta));
  // Movimientos lentos (sin lanzamiento).
  const pasos = 20;
  for (var i = 0; i < pasos; i++) {
    await gesto.moveBy(hasta / pasos.toDouble(), timeStamp: Duration(milliseconds: 50 * i));
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pump(const Duration(milliseconds: 400));
  await gesto.up(timeStamp: const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

void main() {
  group('Pantalla 10', () {
    testWidgets('barra, indicadores, tarjeta, pila, acciones y comodines como en Figma', (
      tester,
    ) async {
      await abrirJuego(tester);
      expect(find.byType(PantallaJuego), findsOneWidget);
      expect(find.text('Sprint 3 · Tarjeta 1 de 10'), findsOneWidget);
      expect(find.byType(IndicadoresStartup), findsOneWidget);
      expect(find.text(tarjetasMock.first.etiquetaCaso), findsOneWidget);
      expect(find.text('Product Owner'), findsOneWidget);
      expect(find.text('PO'), findsOneWidget);
      expect(textoActual(tester), tarjetasMock.first.texto);
      expect(find.byKey(const ValueKey('pila-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('pila-2')), findsOneWidget);
      expect(
        tester.widgetList<BotonVeredicto>(find.byType(BotonVeredicto)).map((b) => b.veredicto),
        [Veredicto.ilegal, Veredicto.escalar, Veredicto.condicional, Veredicto.legal],
      );
      expect(find.text('Lupa ×2'), findsOneWidget);
      expect(find.text('Abogado ×1'), findsOneWidget);
      expect(find.text('Amparo ×1'), findsOneWidget);
      // Medidas de Figma en 390×844: tarjeta 342 de ancho.
      expect(tester.getSize(find.byKey(const ValueKey('tarjeta-caso'))).width, 342);
      // Todo cabe: la pantalla no se desplaza.
      final desplazable = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byKey(const ValueKey('juego-desplazable')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(desplazable.position.maxScrollExtent, 0);
      // Sellos y tinte en reposo: invisibles.
      for (final v in Veredicto.values) {
        expect(opacidadSello(tester, v), 0);
      }
      expect(tinte(tester).veredicto, isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('el número de sprint y el color del chip salen del módulo', (tester) async {
      await abrirJuego(tester);
      final caso = tester.widget<TarjetaCaso>(find.byType(TarjetaCaso));
      expect(caso.colorModulo, const Color(0xFF2B5FA8)); // módulo 1
      expect(tester.widget<BarraJuego>(find.byType(BarraJuego)).numeroSprint, 3);
    });

    for (final (nombre, hasta, veredicto) in [
      ('izquierda', const Offset(-200, 0), Veredicto.ilegal),
      ('derecha', const Offset(200, 0), Veredicto.legal),
      ('arriba', const Offset(0, -140), Veredicto.condicional),
      ('abajo', const Offset(0, 140), Veredicto.escalar),
    ]) {
      testWidgets('arrastrar a la $nombre más allá del umbral confirma ${veredicto.name}', (
        tester,
      ) async {
        await abrirJuego(tester);
        await arrastrar(tester, hasta);
        // La tarjeta avanza al cerrar el panel de veredicto.
        expect(textoActual(tester), tarjetasMock[0].texto);
        await cerrarPanel(tester);
        expect(estadoJuego(tester).respuestas, [
          RespuestaJuego(tarjetaId: tarjetasMock[0].id, veredicto: veredicto),
        ]);
        expect(textoActual(tester), tarjetasMock[1].texto);
        expect(find.text('Sprint 3 · Tarjeta 2 de 10'), findsOneWidget);
        expect(desplazamientoTarjeta(tester), Offset.zero);
      });

      testWidgets('arrastrar a la $nombre sin llegar al umbral regresa', (tester) async {
        await abrirJuego(tester);
        await arrastrar(tester, hasta * 0.25);
        expect(estadoJuego(tester).respuestas, isEmpty);
        expect(textoActual(tester), tarjetasMock[0].texto);
        expect(desplazamientoTarjeta(tester), Offset.zero);
        expect(opacidadSello(tester, veredicto), 0);
      });
    }

    testWidgets('sello y tinte crecen con el arrastre; la tarjeta se inclina a la izquierda', (
      tester,
    ) async {
      await abrirJuego(tester);
      final umbral = LogicaSwipe.umbral(EjeSwipe.horizontal, 342);
      final gesto = await tester.startGesture(tester.getCenter(tarjeta));
      await gesto.moveBy(const Offset(-20, 0));
      await tester.pump();
      await gesto.moveBy(Offset(-(umbral / 2 - 20), 0));
      await tester.pump();
      expect(opacidadSello(tester, Veredicto.ilegal), closeTo(0.5, 0.01));
      expect(opacidadSello(tester, Veredicto.legal), 0);
      expect(tinte(tester).veredicto, Veredicto.ilegal);
      expect(tinte(tester).opacidad, closeTo(0.05, 0.001));
      expect(desplazamientoTarjeta(tester).dx, closeTo(-umbral / 2, 0.01));
      final rotacion = tester
          .widgetList<Transform>(
            find.descendant(
              of: find.byKey(const ValueKey('transformacion-tarjeta')),
              matching: find.byType(Transform),
            ),
          )
          .first;
      // −12° a la mitad del umbral: la matriz tiene seno negativo.
      expect(rotacion.transform.storage[1], closeTo(-0.2079, 0.001));
      await gesto.moveBy(Offset(-umbral, 0));
      await tester.pump();
      expect(opacidadSello(tester, Veredicto.ilegal), 1);
      expect(tinte(tester).opacidad, closeTo(LogicaSwipe.opacidadTinte, 0.0001));
      await gesto.up();
      await tester.pumpAndSettle();
    });

    testWidgets('en vertical la tarjeta no se inclina y solo se mueve en y', (tester) async {
      await abrirJuego(tester);
      final gesto = await tester.startGesture(tester.getCenter(tarjeta));
      await gesto.moveBy(const Offset(5, -30));
      await tester.pump();
      await gesto.moveBy(const Offset(30, -20));
      await tester.pump();
      expect(desplazamientoTarjeta(tester), const Offset(0, -50));
      expect(opacidadSello(tester, Veredicto.condicional), closeTo(50 / 80, 0.001));
      await gesto.up();
      await tester.pumpAndSettle();
    });

    testWidgets('un lanzamiento rápido confirma aunque el arrastre sea corto', (tester) async {
      await abrirJuego(tester);
      await tester.fling(tarjeta, const Offset(-60, 0), 1500);
      await tester.pumpAndSettle();
      expect(estadoJuego(tester).respuestas.single.veredicto, Veredicto.ilegal);
    });

    testWidgets('los 4 botones confirman su veredicto', (tester) async {
      await abrirJuego(tester);
      for (final (i, v) in AccionesVeredicto.orden.indexed) {
        await tester.tap(find.byWidgetPredicate((w) => w is BotonVeredicto && w.veredicto == v));
        await tester.pumpAndSettle();
        await cerrarPanel(tester);
        expect(estadoJuego(tester).respuestas[i].veredicto, v);
        expect(estadoJuego(tester).respuestas[i].tarjetaId, tarjetasMock[i].id);
      }
      expect(find.text('Sprint 3 · Tarjeta 5 de 10'), findsOneWidget);
    });

    testWidgets('teclado: flecha previsualiza, otra la cambia, Esc cancela y Enter confirma', (
      tester,
    ) async {
      await abrirJuego(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(opacidadSello(tester, Veredicto.condicional), 1);
      expect(desplazamientoTarjeta(tester), const Offset(0, -80));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(opacidadSello(tester, Veredicto.condicional), 0);
      expect(opacidadSello(tester, Veredicto.ilegal), 1);
      expect(tinte(tester).veredicto, Veredicto.ilegal);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(opacidadSello(tester, Veredicto.ilegal), 0);
      expect(desplazamientoTarjeta(tester), Offset.zero);
      expect(estadoJuego(tester).respuestas, isEmpty);
      // Enter sin previsualización no hace nada.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(estadoJuego(tester).respuestas, isEmpty);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(estadoJuego(tester).respuestas.single.veredicto, Veredicto.escalar);
    });

    testWidgets('con el foco en un botón, Enter y Espacio lo confirman', (tester) async {
      await abrirJuego(tester);
      // Salir → Indicadores → tarjeta → Ilegal (la tarjeta es parada de Tab
      // desde T-13).
      for (var i = 0; i < 4; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(estadoJuego(tester).respuestas.single.veredicto, Veredicto.ilegal);
      await cerrarPanel(tester);
      // Al cerrar el panel, el foco vuelve al botón Ilegal.
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(estadoJuego(tester).respuestas.last.veredicto, Veredicto.ilegal);
      expect(estadoJuego(tester).respuestas, hasLength(2));
    });

    testWidgets('orden de foco de Figma 26b', (tester) async {
      await abrirJuego(tester);
      final orden = <String>[];
      for (var i = 0; i < 10; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final contexto = FocusManager.instance.primaryFocus?.context;
        if (contexto?.findAncestorWidgetOfExactType<MazoSwipe>() != null &&
            contexto?.findAncestorWidgetOfExactType<BotonVeredicto>() == null) {
          orden.add('tarjeta');
          continue;
        }
        final boton = contexto?.findAncestorWidgetOfExactType<BotonVeredicto>();
        String? dentro<T extends Widget>(String nombre) =>
            contexto?.findAncestorWidgetOfExactType<T>() != null ? nombre : null;
        final pildora = contexto?.findAncestorWidgetOfExactType<PildoraComodin>();
        orden.add(
          boton?.veredicto.name ??
              pildora?.nombre ??
              dentro<BarraJuego>('salir') ??
              (contiene<IndicadoresStartup>(contexto) ? 'indicadores' : null) ??
              (contiene<BarraComodines>(contexto) ? 'comodines' : null) ??
              'otro',
        );
      }
      expect(orden, [
        'salir',
        'indicadores',
        'tarjeta',
        'ilegal',
        'escalar',
        'condicional',
        'legal',
        Textos.comodinLupa,
        Textos.comodinAbogado,
        Textos.comodinAmparo,
      ]);
    });

    testWidgets('lector: tarjeta anunciada, 4 acciones y región en vivo', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrirJuego(tester);
      final etiqueta = Textos.tarjetaSemantica(
        1,
        10,
        tarjetasMock[0].personaje,
        tarjetasMock[0].rol,
        tarjetasMock[0].texto,
      );
      final nodo = tester.getSemantics(find.bySemanticsLabel(etiqueta));
      expect(nodo.getSemanticsData().flagsCollection.isLiveRegion, isTrue);
      final acciones = nodo.getSemanticsData().customSemanticsActionIds!.map(
        (id) => CustomSemanticsAction.getAction(id)!.label,
      );
      expect(acciones.toSet(), {
        Textos.accionLegal,
        Textos.accionIlegal,
        Textos.accionCondicional,
        Textos.accionEscalar,
      });
      // Los sellos, la pila, el tinte y la pista no se leen.
      expect(find.bySemanticsLabel(Textos.selloIlegal), findsNothing);
      expect(find.bySemanticsLabel(Textos.casoPistaLegal), findsNothing);
      // Ejecutar "Legal con condiciones" desde el lector.
      final id = nodo.getSemanticsData().customSemanticsActionIds!.firstWhere(
        (i) => CustomSemanticsAction.getAction(i)!.label == Textos.accionCondicional,
      );
      tester.binding.performSemanticsAction(
        SemanticsActionEvent(
          type: SemanticsAction.customAction,
          viewId: tester.view.viewId,
          nodeId: nodo.id,
          arguments: id,
        ),
      );
      await tester.pumpAndSettle();
      expect(estadoJuego(tester).respuestas.single.veredicto, Veredicto.condicional);
      await cerrarPanel(tester);
      // La tarjeta nueva se anuncia.
      expect(
        find.bySemanticsLabel(RegExp('^Tarjeta 2 de 10. ${tarjetasMock[1].personaje}')),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Salir'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('^Indicadores de la Startup')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Lupa, 2 disponibles')), findsOneWidget);
      semantica.dispose();
    });

    testWidgets('la pila se vacía al llegar a la última tarjeta', (tester) async {
      await abrirJuego(tester, tarjetas: cortas);
      expect(find.byKey(const ValueKey('pila-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('pila-2')), findsNothing);
      await tester.tap(find.byType(BotonVeredicto).first);
      await tester.pumpAndSettle();
      await cerrarPanel(tester);
      expect(find.byType(PilaTarjetas), findsOneWidget);
      expect(find.byKey(const ValueKey('pila-1')), findsNothing);
    });

    testWidgets('al responder la última tarjeta va a "Sprint completado"', (tester) async {
      await abrirJuego(tester, tarjetas: cortas);
      await tester.tap(find.byType(BotonVeredicto).last);
      await tester.pumpAndSettle();
      await cerrarPanel(tester);
      await tester.tap(find.byType(BotonVeredicto).first);
      await tester.pumpAndSettle();
      await cerrarPanel(tester);
      expect(find.text(Textos.sprintCompletadoTitulo), findsOneWidget);
      expect(rutaActual(tester), Rutas.sprintCompletadoDe(sprintMock));
    });

    testWidgets('con "reducir animaciones" la tarjeta pasa sin vuelo', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
        disableAnimations: true,
      );
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await abrirJuego(tester);
      await tester.tap(find.byType(BotonVeredicto).first);
      await tester.pump();
      expect(estadoJuego(tester).respuestas, hasLength(1));
      await tester.pump();
      // El panel aparece sin animación.
      expect(find.byType(PanelVeredicto), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
      await cerrarPanel(tester, settle: false);
      expect(textoActual(tester), tarjetasMock[1].texto);
      expect(desplazamientoTarjeta(tester), Offset.zero);
      expect(tester.hasRunningAnimations, isFalse);
      // Un arrastre corto regresa de inmediato.
      final gesto = await tester.startGesture(tester.getCenter(tarjeta));
      await gesto.moveBy(const Offset(-40, 0));
      await tester.pump();
      await gesto.up();
      await tester.pump();
      expect(desplazamientoTarjeta(tester), Offset.zero);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('Salir', () {
    testWidgets('pide confirmación; "Seguir jugando" se queda y "Salir" vuelve a la intro', (
      tester,
    ) async {
      await abrirJuego(tester, desdeIntro: true);
      expect(find.byType(PantallaJuego), findsOneWidget);
      await tester.tap(find.bySemanticsLabel(Textos.salir));
      await tester.pumpAndSettle();
      expect(find.text(Textos.salirTitulo), findsOneWidget);
      await tester.tap(find.text(Textos.seguirJugando));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaJuego), findsOneWidget);
      await tester.tap(find.bySemanticsLabel(Textos.salir));
      await tester.pumpAndSettle();
      await tester.tap(salirDelDialogo);
      await tester.pumpAndSettle();
      expect(find.byType(PantallaJuego), findsNothing);
      expect(find.byType(PantallaIntroSprint), findsOneWidget);
    });

    testWidgets('sin pila, "Salir" va al mapa del módulo', (tester) async {
      await abrirJuego(tester);
      await tester.tap(find.byKey(const ValueKey('caja-cerrar')));
      await tester.pumpAndSettle();
      await tester.tap(salirDelDialogo);
      await tester.pumpAndSettle();
      expect(find.byType(PantallaMapaSprints), findsOneWidget);
    });
  });

  group('Estados', () {
    testWidgets('cargando muestra el esqueleto', (tester) async {
      final repo = await abrirJuego(tester, esperar: false, antes: (r) => r.bloqueo = Completer());
      expect(find.byKey(const ValueKey('esqueleto-juego')), findsOneWidget);
      repo.bloqueo!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(TarjetaCaso), findsOneWidget);
    });

    testWidgets('error con "Reintentar"', (tester) async {
      final repo = await abrirJuego(tester, antes: (r) => r.fallar = true);
      expect(find.text(Textos.juegoErrorCarga), findsOneWidget);
      final llamadas = repo.llamadas;
      repo.fallar = false;
      await tester.tap(find.text(Textos.reintentar));
      await tester.pumpAndSettle();
      expect(repo.llamadas, greaterThan(llamadas));
      expect(find.byType(TarjetaCaso), findsOneWidget);
    });

    testWidgets('sprint sin tarjetas: mensaje y volver al mapa', (tester) async {
      await abrirJuego(tester, sprintId: 'spr-1-1', tarjetas: {'spr-1-1': []});
      expect(find.text(Textos.sprintSinTarjetas), findsOneWidget);
      await tester.tap(find.text(Textos.volverAlMapa));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaMapaSprints), findsOneWidget);
    });

    testWidgets('sprint inexistente: mensaje y volver al Inicio', (tester) async {
      await abrirJuego(tester, sprintId: 'no-existe');
      expect(find.text(Textos.sprintSinTarjetas), findsOneWidget);
      expect(find.text(Textos.volverAlInicio), findsOneWidget);
    });

    testWidgets('con 0 vidas muestra "Sin vidas" (20) sin cargar tarjetas', (tester) async {
      final repo = await abrirJuego(tester, vidas: 0);
      expect(find.byType(PantallaSinVidas), findsOneWidget);
      expect(find.text(Textos.sinVidasTitulo), findsOneWidget);
      expect(find.byType(TarjetaCaso), findsNothing);
      expect(repo.llamadas, 0);
    });

    testWidgets('sin sesión no entra al juego', (tester) async {
      await abrirJuego(tester, conSesion: false);
      expect(find.byType(PantallaJuego), findsNothing);
      expect(find.byType(PantallaInicioSesion), findsOneWidget);
    });
  });

  probarSinDesbordes(
    (tester, tamano, _) async {
      await abrirJuego(tester, tamano: tamano);
      expect(tester.takeException(), isNull);
      final posicion = tester
          .state<ScrollableState>(
            find
                .descendant(
                  of: find.byKey(const ValueKey('juego-desplazable')),
                  matching: find.byType(Scrollable),
                )
                .first,
          )
          .position;
      // Recorrer toda la pantalla.
      posicion.jumpTo(posicion.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      posicion.jumpTo(0);
      await tester.pumpAndSettle();
      // Si se desplaza, se hace desde fuera de la tarjeta (la barra).
      if (posicion.maxScrollExtent > 0) {
        await tester.drag(find.byType(BarraJuego), const Offset(0, -60));
        await tester.pumpAndSettle();
        expect(posicion.pixels, greaterThan(0));
      }
      // El gesto es de la tarjeta aunque la pantalla se pueda desplazar.
      await tester.ensureVisible(tarjeta);
      await tester.pumpAndSettle();
      final antesDelGesto = posicion.pixels;
      await arrastrar(tester, const Offset(0, -150));
      expect(estadoJuego(tester).respuestas.single.veredicto, Veredicto.condicional);
      expect(posicion.pixels, antesDelGesto);
      expect(tester.takeException(), isNull);
    },
    ambosBrillos: true,
    texto: 'texto ',
  );
}
