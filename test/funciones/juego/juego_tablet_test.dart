import 'package:abogator/componentes/barra_juego.dart';
import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/boton_veredicto.dart';
import 'package:abogator/componentes/hoja_lateral.dart';
import 'package:abogator/componentes/opcion_justificacion.dart';
import 'package:abogator/componentes/panel_abogado.dart';
import 'package:abogator/componentes/panel_evidencia.dart';
import 'package:abogator/componentes/panel_justificacion.dart';
import 'package:abogator/componentes/panel_lateral_juego.dart';
import 'package:abogator/componentes/panel_veredicto.dart';
import 'package:abogator/componentes/riel_navegacion.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:abogator/datos/mocks/mock_progreso.dart';
import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/funciones/juego/pantalla_juego.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../ayudantes/montar.dart';
import '../../ayudantes/tamano_pantalla.dart';
import 'ayudante_juego.dart';

final normal = MockTarjetas.tarjetasPorSprint[sprintMock]![1];
final registro = MockTarjetas.tarjetasPorSprint[sprintMock]![5];
final dilema = MockTarjetas.tarjetasPorSprint[sprintMock]![9];

Finder get hoja => find.byKey(const ValueKey('hoja-lateral'));

Future<void> abrirTablet(
  WidgetTester tester, {
  Tamano tamano = Tamano.tabletHorizontal,
  List<Tarjeta>? tarjetas,
}) => abrirJuego(
  tester,
  tamano: tamano.medida,
  tarjetas: tarjetas == null ? null : {sprintMock: tarjetas},
);

Future<void> elegir(WidgetTester tester, Veredicto v) async {
  final boton = find.byWidgetPredicate((w) => w is BotonVeredicto && w.veredicto == v);
  await tester.ensureVisible(boton);
  await tester.tap(boton);
  await tester.pumpAndSettle();
}

/// Comprueba que [hoja] es la lateral de Figma: 376 de ancho, a 24 del borde
/// derecho y 22 del inferior.
void esperarHojaLateral(WidgetTester tester) {
  final r = tester.getRect(hoja);
  expect(r.width, 376);
  expect(r.right, 1194 - 24);
  expect(r.bottom, 834 - 22);
}

void main() {
  group('T10 · zona de juego en 1194×834', () {
    testWidgets('sin riel; barra de tablet con Salir, progreso, HUD y Pausa', (tester) async {
      await abrirTablet(tester);
      expect(find.byType(RielNavegacion), findsNothing);
      expect(find.byType(BarraJuego), findsNothing);
      final barra = tester.getRect(find.byType(BarraJuegoTablet));
      expect(barra.left, 24);
      expect(barra.top, 8);
      expect(barra.width, 1194 - 48);
      expect(barra.height, 64);
      expect(tester.getSize(find.byKey(const ValueKey('boton-salir-tablet'))), const Size(48, 48));
      expect(tester.getSize(find.byKey(const ValueKey('boton-pausa'))), const Size(48, 48));
      expect(find.bySemanticsLabel(Textos.pausa), findsOneWidget);
      expect(find.text(Textos.juegoPaso(3, 1, 10)), findsOneWidget);
    });

    testWidgets('tarjeta de 380 × 470 centrada en la zona izquierda, con su pila', (tester) async {
      await abrirTablet(tester);
      final zona = tester.getRect(find.byKey(const ValueKey('zona-tarjeta-tablet')));
      expect(zona.width, 380);
      expect(zona.height, 470 + 20);
      expect(zona.left, 207);
      expect(zona.top, 8 + 64 + 36);
      expect(find.byKey(const ValueKey('pila-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('pila-2')), findsOneWidget);
      // Botones de veredicto centrados bajo la tarjeta, en el orden de Figma.
      final botones = tester
          .widgetList<BotonVeredicto>(find.byType(BotonVeredicto))
          .map((b) => b.veredicto)
          .toList();
      expect(botones.take(4), [
        Veredicto.ilegal,
        Veredicto.escalar,
        Veredicto.condicional,
        Veredicto.legal,
      ]);
      final acciones = tester.getRect(find.byKey(const ValueKey('acciones-veredicto')));
      expect(acciones.center.dx, closeTo(zona.center.dx, 1));
      expect(find.byKey(const ValueKey('barra-comodines')), findsOneWidget);
    });

    testWidgets('panel lateral de 376: Tu Startup, contexto con el objetivo real y atajos', (
      tester,
    ) async {
      await abrirTablet(tester);
      final panel = tester.getRect(find.byKey(const ValueKey('panel-lateral-juego')));
      expect(panel.left, 1194 - 400);
      expect(panel.width, 376);
      expect(find.byType(TarjetaTuStartup), findsOneWidget);
      expect(find.text(Textos.notaIndicadores), findsOneWidget);
      final sprint = MockProgreso.modulos.first.sprints[2];
      expect(find.text(Textos.contextoSprint(1, 3)), findsOneWidget);
      expect(find.text(sprint.tituloIntro ?? sprint.titulo), findsOneWidget);
      expect(find.text(LogicaJuegoTablet.objetivo(sprint.objetivo)), findsOneWidget);
      for (final linea in Textos.atajosLineas) {
        expect(find.text(linea), findsOneWidget);
      }
    });

    test('el objetivo empieza con mayúscula', () {
      expect(LogicaJuegoTablet.objetivo('el MVP sale el viernes.'), 'El MVP sale el viernes.');
      expect(LogicaJuegoTablet.objetivo(''), '');
    });
  });

  group('hojas laterales', () {
    testWidgets('el veredicto abre la hoja de 376, no se descarta y al cerrarla sigue', (
      tester,
    ) async {
      await abrirTablet(tester, tarjetas: [normal, normal]);
      await elegir(tester, normal.respuestaCorrecta);
      expect(hoja, findsOneWidget);
      expect(find.byType(PanelVeredicto), findsOneWidget);
      esperarHojaLateral(tester);
      expect(find.bySemanticsLabel(Textos.hojaRetroalimentacion), findsOneWidget);
      // El panel lateral sigue debajo.
      expect(find.byType(TarjetaTuStartup), findsOneWidget);
      // Esc ni tocar fuera la cierran.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(60, 400));
      await tester.pumpAndSettle();
      expect(find.byType(PanelVeredicto), findsOneWidget);
      await cerrarPanel(tester);
      expect(hoja, findsNothing);
      expect(estadoJuego(tester).indice, 1);
    });

    testWidgets('la evidencia se abre en la hoja y se cierra con Esc', (tester) async {
      await abrirTablet(tester, tarjetas: [registro]);
      await tocar(tester, find.byKey(const ValueKey('boton-evidencia')));
      expect(find.byType(PanelEvidencia), findsOneWidget);
      esperarHojaLateral(tester);
      expect(find.bySemanticsLabel(Textos.hojaEvidencia), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(PanelEvidencia), findsNothing);
    });

    testWidgets('la evidencia se cierra tocando fuera', (tester) async {
      await abrirTablet(tester, tarjetas: [registro]);
      await tocar(tester, find.byKey(const ValueKey('boton-evidencia')));
      await tester.tapAt(const Offset(60, 400));
      await tester.pumpAndSettle();
      expect(find.byType(PanelEvidencia), findsNothing);
    });

    testWidgets('la justificación del dilema va en la hoja y no se descarta', (tester) async {
      await abrirTablet(tester, tarjetas: [dilema]);
      await elegir(tester, dilema.respuestaCorrecta);
      expect(find.byType(PanelJustificacion), findsOneWidget);
      esperarHojaLateral(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(PanelJustificacion), findsOneWidget);
      await tocar(tester, find.byType(OpcionJustificacion).first);
      await tocar(
        tester,
        find.descendant(of: find.byType(PanelJustificacion), matching: find.byType(BotonApp)),
      );
      expect(find.byType(PanelVeredicto), findsOneWidget);
      esperarHojaLateral(tester);
    });

    testWidgets('el Abogado Senior se abre en la hoja y se cierra con atrás', (tester) async {
      await abrirTablet(tester, tarjetas: [normal]);
      await tocar(tester, find.byKey(const ValueKey('comodin-abogado')));
      expect(find.byType(PanelAbogado), findsOneWidget);
      esperarHojaLateral(tester);
      expect(find.bySemanticsLabel(Textos.hojaAbogado), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(PanelAbogado), findsNothing);
    });

    testWidgets('con "Reducir animaciones" la hoja aparece sin movimiento', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
        disableAnimations: true,
      );
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await abrirTablet(tester, tarjetas: [normal, normal]);
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is BotonVeredicto && w.veredicto == normal.respuestaCorrecta,
        ),
      );
      await tester.pump();
      await tester.pump();
      esperarHojaLateral(tester);
    });

    testWidgets('con teclado: flecha y Enter responden y abren la hoja', (tester) async {
      await abrirTablet(tester, tarjetas: [normal, normal]);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(hoja, findsOneWidget);
      expect(estadoJuego(tester).respuestas, hasLength(1));
    });
  });

  group('Pausa', () {
    testWidgets('"Seguir jugando" cierra y "Salir del sprint" pide confirmación', (tester) async {
      await abrirTablet(tester);
      await tocar(tester, find.byKey(const ValueKey('boton-pausa')));
      expect(find.text(Textos.pausaTitulo), findsOneWidget);
      final dialogo = tester.getRect(
        find.descendant(
          of: find.byKey(const ValueKey('dialogo-pausa')),
          matching: find.byType(SingleChildScrollView),
        ),
      );
      expect(dialogo.width, lessThanOrEqualTo(440));
      await tocar(tester, find.byKey(const ValueKey('boton-seguir-jugando')));
      expect(find.text(Textos.pausaTitulo), findsNothing);

      await tocar(tester, find.byKey(const ValueKey('boton-pausa')));
      await tocar(tester, find.byKey(const ValueKey('boton-salir-sprint')));
      expect(find.text(Textos.salirTitulo), findsOneWidget);
      await tocar(tester, salirDelDialogo);
      expect(find.byType(PantallaJuego), findsNothing);
    });
  });

  testWidgets('un sprint completo en tablet con cada tipo de tarjeta', (tester) async {
    await abrirTablet(tester);
    for (
      var i = 0;
      i < 12 &&
          rutaActual(tester).startsWith('/juego/') &&
          !rutaActual(tester).endsWith('/completado') &&
          !rutaActual(tester).endsWith('/quiebra');
      i++
    ) {
      final t = tester.widget<PantallaJuego>(find.byType(PantallaJuego));
      expect(t, isNotNull);
      final actual = estadoJuego(tester).indice;
      final tarjetaActual = MockTarjetas.tarjetasPorSprint[sprintMock]![actual];
      await elegir(tester, tarjetaActual.respuestaCorrecta);
      if (find.byType(PanelJustificacion).evaluate().isNotEmpty) {
        await tocar(tester, find.byType(OpcionJustificacion).first);
        await tocar(
          tester,
          find.descendant(of: find.byType(PanelJustificacion), matching: find.byType(BotonApp)),
        );
      }
      expect(hoja, findsOneWidget);
      await cerrarPanel(tester);
      if (find.byType(PantallaJuego).evaluate().isEmpty) break;
    }
    expect(rutaActual(tester), endsWith('/completado'));
  });

  group('tablet vertical y móvil: el juego de siempre', () {
    for (final tamano in [Tamano.tabletVertical, Tamano.tabletMinima, Tamano.movil]) {
      testWidgets('${tamano.name}: sin panel lateral ni pausa; panel inferior', (tester) async {
        await abrirTablet(tester, tamano: tamano, tarjetas: [normal, normal]);
        expect(find.byType(BarraJuego), findsOneWidget);
        expect(find.byType(BarraJuegoTablet), findsNothing);
        expect(find.byKey(const ValueKey('panel-lateral-juego')), findsNothing);
        await elegir(tester, normal.respuestaCorrecta);
        expect(hoja, findsNothing);
        final panel = tester.getRect(find.byType(PanelVeredicto));
        expect(panel.bottom, tamano.medida.height);
        if (tamano != Tamano.movil) {
          expect(panel.width, lessThanOrEqualTo(anchoHojaTabletVertical));
          expect(panel.center.dx, closeTo(tamano.medida.width / 2, 1));
        }
      });
    }
  });

  probarSinDesbordesTablet((tester, tamano) async {
    await abrirTablet(tester, tamano: tamano, tarjetas: [normal, normal]);
    expect(tester.takeException(), isNull);
    await elegir(tester, normal.respuestaCorrecta);
    expect(tester.takeException(), isNull);
  });

  enAmbosModos('contrastes del panel lateral', (tester, brillo) async {
    final t = tokensDe(brillo);
    expect(Contraste.razon(t.textoSecundario, t.fondoSuperficieAlt), greaterThanOrEqualTo(4.5));
    expect(Contraste.razon(t.textoPrimario, t.fondoSuperficieAlt), greaterThanOrEqualTo(4.5));
    expect(Contraste.razon(t.textoAcento, t.fondoSuperficie), greaterThanOrEqualTo(4.5));
    for (final c in [t.estadoLegal, t.estadoIlegal, t.estadoCondicional, t.estadoEscalar]) {
      expect(Contraste.razon(c, t.fondoSuperficie), greaterThanOrEqualTo(4.5));
    }
  });

  testWidgets('HojaLateral.enHoja solo dentro de la hoja', (tester) async {
    late bool dentro;
    late bool fuera;
    await montar(
      tester,
      Builder(
        builder: (c) {
          fuera = HojaLateral.enHoja(c);
          return SizedBox(
            width: 800,
            height: 600,
            child: HojaLateral(
              etiqueta: 'x',
              child: Builder(
                builder: (c2) {
                  dentro = HojaLateral.enHoja(c2);
                  return const SizedBox(height: 10);
                },
              ),
            ),
          );
        },
      ),
    );
    expect(fuera, isFalse);
    expect(dentro, isTrue);
  });
}
