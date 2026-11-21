import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/boton_buzon.dart';
import 'package:abogator/componentes/encabezado_modulo.dart';
import 'package:abogator/componentes/globo_sprint_actual.dart';
import 'package:abogator/componentes/nodo_sprint.dart';
import 'package:abogator/componentes/riel_navegacion.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/mocks/mock_progreso.dart';
import 'package:abogator/datos/modelos/modulo.dart';
import 'package:abogator/funciones/inicio/pantalla_inicio.dart';
import 'package:abogator/funciones/jefe/pantalla_jefe.dart';
import 'package:abogator/funciones/juego/pantalla_juego.dart';
import 'package:abogator/funciones/mapa/detalle_sprint.dart';
import 'package:abogator/funciones/mapa/logica_mapa.dart';
import 'package:abogator/funciones/mapa/pantalla_intro_sprint.dart';
import 'package:abogator/funciones/mapa/pantalla_mapa_sprints.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../ayudantes/datos.dart';
import '../../ayudantes/tamano_pantalla.dart';
import 'mapa_test.dart' show abrir, moduloCompleto, nodo, rutaActual;

const c = EstadoSprint.completado;
const e = EstadoSprint.enCurso;
const b = EstadoSprint.bloqueado;

Finder get detalle => find.byKey(const ValueKey('panel-detalle'));

String tituloDetalle(WidgetTester tester) {
  final d = tester.widget<DetalleSprint>(find.byType(DetalleSprint));
  return d.sprint.tituloIntro ?? d.sprint.titulo;
}

Future<void> tocarNodo(WidgetTester tester, int i) async {
  await tester.ensureVisible(nodo(i));
  await tester.pumpAndSettle();
  await tester.tap(nodo(i));
  await tester.pumpAndSettle();
}

void main() {
  group('Mapa + detalle en tablet horizontal (T08)', () {
    testWidgets('dos paneles: mapa de 596 y detalle de 494, con riel y sin Buzón flotante', (
      tester,
    ) async {
      await abrir(tester, tamano: Tamano.tabletHorizontal.medida);
      expect(find.byType(RielNavegacion), findsOneWidget);
      expect(find.byType(BotonBuzon), findsNothing);
      final mapa = tester.getRect(find.byKey(const ValueKey('panel-mapa')));
      final panel = tester.getRect(detalle);
      expect(mapa.left, 104);
      expect(mapa.width, closeTo(596, 0.5));
      expect(panel.left, closeTo(700, 0.5));
      expect(panel.width, closeTo(494, 0.5));
      expect(panel.height, 834);
      // Encabezado de 134 a todo el ancho del panel.
      final encabezado = tester.getRect(find.byType(EncabezadoModulo));
      expect(encabezado.width, closeTo(596, 0.5));
      expect(encabezado.height, closeTo(134, 0.5));
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('atras-encabezado'))),
        const Offset(104 + 16, 20),
      );
      // Mapa × 1.12 centrado en el panel (Figma: x 79.6, ancho 436.8).
      final escalado = tester.getRect(find.byKey(const ValueKey('mapa-escalado')));
      expect(escalado.width, closeTo(436.8, 0.1));
      expect(escalado.left - 104, closeTo(79.6, 0.1));
      final cara = tester.getRect(find.byKey(const ValueKey('cara-nodo')).first);
      expect(cara.width, closeTo(72 * 1.12, 0.01));
      // Sin globo visible ni tocable (su lugar se conserva) y fuera del lector.
      expect(find.byType(GloboSprintActual).hitTestable(), findsNothing);
      expect(find.bySemanticsLabel(Textos.comenzar), findsNothing);
    });

    testWidgets('el detalle trae las 6 piezas en una columna de 430', (tester) async {
      await abrir(tester, tamano: Tamano.tabletHorizontal.medida);
      final columna = tester.getRect(find.byType(DetalleSprint));
      expect(columna.width, closeTo(430, 0.5));
      expect(columna.left, closeTo(700 + 1 + (494 - 1 - 430) / 2, 1));
      expect(tester.getSize(find.byKey(const ValueKey('elipse-intro'))), const Size(207, 207));
      expect(find.text('SPRINT 3 · MÓDULO 1'), findsOneWidget);
      expect(find.text('Aviso de privacidad en el MVP'), findsOneWidget);
      expect(find.textContaining('Objetivo: '), findsOneWidget);
      expect(find.text('10 tarjetas'), findsOneWidget);
      final boton = tester.getRect(find.byKey(const ValueKey('comenzar-detalle')));
      expect(boton.width, closeTo(430, 0.5));
      expect(boton.height, 52);
      // Alineado a la izquierda (no centrado como la intro del móvil).
      final etiqueta = tester.widget<Text>(find.text('SPRINT 3 · MÓDULO 1'));
      expect(etiqueta.textAlign, TextAlign.left);
    });

    group('selección inicial', () {
      for (final (nombre, estados, esperado) in [
        ('el sprint en curso', [c, c, e, b, b], 'Sprint de prueba 3'),
        ('sin sprint en curso, el último completado', [c, c, c, c, c], 'Sprint de prueba 5'),
        ('sin completados, el primero', [b, b, b, b, b], 'Sprint de prueba 1'),
      ]) {
        testWidgets(nombre, (tester) async {
          await abrir(
            tester,
            tamano: Tamano.tabletHorizontal.medida,
            modulos: [moduloDePrueba(1, estados, id: 'mod-1', conFinal: true)],
          );
          expect(tituloDetalle(tester), esperado);
        });
      }
    });

    testWidgets('tocar un completado cambia el detalle sin navegar y lo anuncia', (tester) async {
      await abrir(tester, tamano: Tamano.tabletHorizontal.medida);
      final antes = rutaActual(tester);
      await tocarNodo(tester, 1);
      expect(rutaActual(tester), antes);
      expect(tituloDetalle(tester), MockProgreso.modulos.first.sprints[1].titulo);
      expect(find.text('SPRINT 2 · MÓDULO 1'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp(r'^Sprint 2, .*\. Completado, 3 estrellas\.$')),
        findsOneWidget,
      );
      // Seleccionado: borde de 3 y "seleccionado" en la semántica.
      expect(find.byKey(const ValueKey('marca-seleccion')), findsOneWidget);
      expect(tester.widget<NodoSprint>(nodo(1)).seleccionado, isTrue);
      expect(tester.widget<NodoSprint>(nodo(2)).seleccionado, isFalse);
      // Volver al actual: sin borde (ya tiene su aro de pulso).
      await tocarNodo(tester, 2);
      expect(find.byKey(const ValueKey('marca-seleccion')), findsNothing);
      expect(find.text('SPRINT 3 · MÓDULO 1'), findsOneWidget);
    });

    testWidgets('bloqueados y Examen bloqueado no hacen nada', (tester) async {
      await abrir(tester, tamano: Tamano.tabletHorizontal.medida);
      final total = MockProgreso.modulos.first.sprints.length;
      await tocarNodo(tester, 3);
      await tocarNodo(tester, total - 1);
      expect(find.text('SPRINT 3 · MÓDULO 1'), findsOneWidget);
      expect(find.byType(PantallaJefe), findsNothing);
    });

    testWidgets('el Examen final habilitado abre la crisis', (tester) async {
      await abrir(tester, tamano: Tamano.tabletHorizontal.medida, modulos: [moduloCompleto]);
      await tocarNodo(tester, moduloCompleto.sprints.length - 1);
      expect(find.byType(PantallaJefe), findsOneWidget);
    });

    testWidgets('"Comenzar sprint" abre el juego del sprint seleccionado', (tester) async {
      await abrir(tester, tamano: Tamano.tabletHorizontal.medida);
      await tocarNodo(tester, 1);
      await tester.tap(find.byKey(const ValueKey('comenzar-detalle')));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaJuego), findsOneWidget);
      expect(rutaActual(tester), Rutas.juegoDe(MockProgreso.modulos.first.sprints[1].id));
    });

    testWidgets('la ruta de la intro muestra la vista combinada con ese sprint', (tester) async {
      final modulo = MockProgreso.modulos.first;
      await abrir(
        tester,
        tamano: Tamano.tabletHorizontal.medida,
        ruta: Rutas.introSprintDe(modulo.id, modulo.sprints[0].id),
      );
      expect(find.byType(PantallaMapaSprints), findsOneWidget);
      expect(find.byKey(const ValueKey('intro-sprint')), findsNothing);
      expect(find.text('SPRINT 1 · MÓDULO 1'), findsOneWidget);
      // Atrás vuelve al Inicio.
      await tester.tap(find.byKey(const ValueKey('atras-encabezado')));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaInicio), findsOneWidget);
    });

    testWidgets('atrás sin pila vuelve al Inicio', (tester) async {
      await abrir(tester, tamano: Tamano.tabletHorizontal.medida);
      await tester.tap(find.byKey(const ValueKey('atras-encabezado')));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaInicio), findsOneWidget);
    });

    testWidgets('orden de foco: riel, atrás, nodos y el botón del detalle al final', (
      tester,
    ) async {
      await abrir(tester, tamano: Tamano.tabletHorizontal.medida);
      final enfocados = <String>[];
      for (var i = 0; i < 14; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final foco = FocusManager.instance.primaryFocus?.context;
        if (foco == null) {
          enfocados.add('?');
        } else if (foco.findAncestorWidgetOfExactType<RielNavegacion>() != null) {
          enfocados.add('riel');
        } else if (foco.findAncestorWidgetOfExactType<EncabezadoModulo>() != null) {
          enfocados.add('atras');
        } else if (foco.findAncestorWidgetOfExactType<NodoSprint>() != null) {
          enfocados.add('nodo');
        } else if (foco.findAncestorWidgetOfExactType<BotonApp>()?.key ==
            const ValueKey('comenzar-detalle')) {
          enfocados.add('comenzar');
        } else {
          enfocados.add('otro');
        }
      }
      // 4 destinos, Ajustes y avatar; luego atrás, los nodos abiertos y el botón.
      expect(enfocados.sublist(0, 6), List.filled(6, 'riel'));
      expect(enfocados[6], 'atras');
      final iComenzar = enfocados.indexOf('comenzar');
      expect(iComenzar, greaterThan(7));
      expect(enfocados.sublist(7, iComenzar), everyElement('nodo'));
    });

    testWidgets('carga y error a ancho de contenido', (tester) async {
      await abrir(tester, tamano: Tamano.tabletHorizontal.medida, antes: (p) => p.fallar = true);
      expect(find.text(Textos.mapaErrorCarga), findsOneWidget);
      expect(detalle, findsNothing);
      expect(find.byType(RielNavegacion), findsOneWidget);
    });

    testWidgets('módulo no encontrado', (tester) async {
      await abrir(
        tester,
        tamano: Tamano.tabletHorizontal.medida,
        ruta: Rutas.mapaSprintsDe('nada'),
      );
      expect(find.text(Textos.moduloNoEncontrado), findsOneWidget);
      expect(detalle, findsNothing);
    });

    for (final brillo in Brightness.values) {
      for (final escala in [1.0, 2.0]) {
        testWidgets('sin desbordes al ${(escala * 100).round()} % (${brillo.name})', (
          tester,
        ) async {
          tester.platformDispatcher.textScaleFactorTestValue = escala;
          tester.platformDispatcher.platformBrightnessTestValue = brillo;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
          await abrir(tester, tamano: Tamano.tabletHorizontal.medida);
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(find.byKey(const ValueKey('comenzar-detalle')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('Mapa en tablet vertical y móvil: como hoy', () {
    for (final tamano in [Tamano.tabletVertical, Tamano.tabletMinima]) {
      testWidgets('${tamano.name}: riel y tocar abre la intro a pantalla completa', (tester) async {
        await abrir(tester, tamano: tamano.medida);
        expect(find.byType(RielNavegacion), findsOneWidget);
        expect(detalle, findsNothing);
        expect(find.byType(BotonBuzon), findsNothing);
        await tocarNodo(tester, 1);
        expect(find.byType(PantallaIntroSprint), findsOneWidget);
        expect(find.byKey(const ValueKey('intro-sprint')), findsOneWidget);
      });
    }

    testWidgets('sin la reserva del Buzón con riel y con ella en móvil', (tester) async {
      double rellenoInferior() => tester
          .widget<SingleChildScrollView>(find.byKey(const ValueKey('mapa-sprints')))
          .padding!
          .resolve(TextDirection.ltr)
          .bottom;
      await abrir(tester, tamano: Tamano.tabletVertical.medida);
      expect(rellenoInferior(), MapaSprints.margenInferior);
      await abrir(tester);
      expect(rellenoInferior(), greaterThan(MapaSprints.margenInferior));
    });
  });

  test('anuncio de la selección', () {
    final modulo = MockProgreso.modulos.first;
    expect(
      LogicaMapa.anuncioSeleccion(modulo, modulo.sprints[1]),
      matches(RegExp(r'^Sprint 2, .+\. Completado, \d estrellas?\.$')),
    );
    expect(LogicaMapa.anuncioSeleccion(modulo, modulo.sprints[3]), endsWith('Bloqueado.'));
  });
}
