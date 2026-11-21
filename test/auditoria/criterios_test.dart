import 'package:abogator/app/app.dart';
import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/anillo_foco.dart';
import 'package:abogator/componentes/boton_veredicto.dart';
import 'package:abogator/componentes/fila_apelacion.dart';
import 'package:abogator/componentes/impacto_startup.dart';
import 'package:abogator/componentes/indicadores_startup.dart';
import 'package:abogator/componentes/sello_veredicto.dart';
import 'package:abogator/core/adaptativo/clase_pantalla.dart';
import 'package:abogator/core/tema/iconos_app.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/modelos/ajustes.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/funciones/jefe/estado_examen.dart';
import 'package:abogator/funciones/juego/pantalla_sprint_completado.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';
import '../ayudantes/tamano_pantalla.dart';
import '../funciones/apelaciones/juicio_test.dart' show servidor;
import '../funciones/jefe/jefe_test.dart' as jefe show abrirCrisis, elegir, escenario, pasarChip;
import '../funciones/juego/ayudante_juego.dart';
import '../funciones/juego/fin_sprint_test.dart' as fin show mazoLegal;
import 'ayudante_auditoria.dart';
import 'catalogo.dart' show pulsar;

/// El anillo de foco visible, si lo hay.
Finder get anilloVisible =>
    find.byWidgetPredicate((w) => w is AnilloFoco && w.visible, skipOffstage: false);

/// Recorre la pantalla con Tab hasta volver al inicio (o [maximo] pasos) y
/// comprueba en cada parada que se ve el anillo de foco dentro de la pantalla.
Future<int> recorrerConAnillo(WidgetTester tester, {int maximo = 40}) async {
  final vistos = <FocusNode>{};
  final pantalla = tester.getRect(find.byType(AppAbogator));
  for (var i = 0; i < maximo; i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    final nodo = FocusManager.instance.primaryFocus;
    if (nodo == null || !vistos.add(nodo)) break;
    final descripcion = describirFoco(nodo);
    // Paradas sin anillo propio a propósito: el interruptor de conexión de
    // depuración (solo en debug) y los campos de texto nativos, que dibujan
    // su propio anillo desde `CampoTextoApp`.
    if (descripcion == 'interruptor-conexion') continue;
    expect(anilloVisible, findsWidgets, reason: 'sin anillo de foco en "$descripcion"');
    final anillo = tester.getRect(anilloVisible.last);
    expect(
      pantalla.inflate(AnilloFoco.margen + 1).contains(anillo.topLeft) &&
          pantalla.inflate(AnilloFoco.margen + 1).contains(anillo.bottomRight),
      isTrue,
      reason: 'anillo fuera de la pantalla en "$descripcion": $anillo',
    );
  }
  return vistos.length;
}

void main() {
  group('Orientación (WCAG 1.3.4)', () {
    test('el teléfono es vertical y la tablet gira libremente', () {
      expect(orientacionesPermitidas(const Size(390, 844)), [DeviceOrientation.portraitUp]);
      expect(orientacionesPermitidas(const Size(844, 390)), [DeviceOrientation.portraitUp]);
      expect(orientacionesPermitidas(const Size(834, 1194)), DeviceOrientation.values);
      expect(orientacionesPermitidas(const Size(1194, 834)), DeviceOrientation.values);
      expect(orientacionesPermitidas(const Size(600, 960)), DeviceOrientation.values);
    });

    Future<void> rotar(WidgetTester tester, Tamano a) async {
      await tester.binding.setSurfaceSize(a.medida);
      await tester.pumpAndSettle();
    }

    testWidgets('rotar en el juego conserva la tarjeta y las respuestas', (tester) async {
      await abrirJuego(tester, tamano: Tamano.tabletHorizontal.medida);
      await pulsar(
        tester,
        find.byWidgetPredicate((w) => w is BotonVeredicto && w.veredicto == Veredicto.legal),
      );
      await cerrarPanel(tester);
      final indice = estadoJuego(tester).indice;
      final texto = textoActual(tester);
      await rotar(tester, Tamano.tabletVertical);
      expect(estadoJuego(tester).indice, indice);
      expect(textoActual(tester), texto);
      await rotar(tester, Tamano.tabletHorizontal);
      expect(estadoJuego(tester).respuestas, hasLength(1));
      expect(textoActual(tester), texto);
    });

    testWidgets('rotar en el Buzón conserva la apelación seleccionada', (tester) async {
      await abrirJuego(
        tester,
        ruta: Rutas.buzon,
        apelaciones: servidor(),
        tamano: Tamano.tabletHorizontal.medida,
      );
      await pulsar(tester, find.byKey(const ValueKey('fila-ape-002')));
      await rotar(tester, Tamano.tabletVertical);
      expect(find.byKey(const ValueKey('fila-ape-002')), findsOneWidget);
      await rotar(tester, Tamano.tabletHorizontal);
      expect(
        tester.widget<FilaApelacion>(find.byKey(const ValueKey('fila-ape-002'))).seleccionada,
        isTrue,
      );
    });

    testWidgets('rotar en el Examen conserva la decisión, el HP y la fase', (tester) async {
      await jefe.abrirCrisis(tester, tamano: Tamano.tabletHorizontal.medida);
      await pulsar(tester, find.byKey(const ValueKey('boton-enfrentar')));
      await jefe.elegir(tester, jefe.escenario[0].respuestaCorrecta);
      final antes = contenedorDe(tester).read(examenProvider)!;
      await rotar(tester, Tamano.tabletVertical);
      final despues = contenedorDe(tester).read(examenProvider)!;
      expect(despues.fase, antes.fase);
      expect(despues.decision?.indice, antes.decision?.indice);
      expect(despues.hp, antes.hp);
      expect(find.byKey(const ValueKey('panel-contraargumento')), findsOneWidget);
      await rotar(tester, Tamano.tabletHorizontal);
      expect(find.byKey(const ValueKey('panel-contraargumento')), findsOneWidget);
    });
  });

  group('Foco visible (WCAG 2.4.7)', () {
    final pantallas = <String, String>{
      'Inicio': Rutas.inicio,
      'Mapa': Rutas.mapaSprintsDe('mod-1'),
      'Intro': Rutas.introSprintDe('mod-1', sprintMock),
      'Juego': Rutas.juegoDe(sprintMock),
      'Tienda': Rutas.tienda,
      'Perfil': Rutas.perfil,
      'Ajustes': Rutas.ajustes,
      'Buzón': Rutas.buzon,
    };
    for (final t in [Tamano.movil, Tamano.tabletHorizontal]) {
      for (final MapEntry(key: nombre, value: ruta) in pantallas.entries) {
        testWidgets('$nombre (${t.name}): cada parada de Tab muestra su anillo', (tester) async {
          await abrirJuego(tester, ruta: ruta, tamano: t.medida, apelaciones: servidor());
          expect(await recorrerConAnillo(tester), greaterThan(1));
        });
      }
      testWidgets('acceso (${t.name}): inicio de sesión y registro', (tester) async {
        await abrirJuego(tester, ruta: Rutas.inicioSesion, tamano: t.medida, conSesion: false);
        expect(await recorrerConAnillo(tester), greaterThan(2));
        contenedorDe(tester);
      });
    }
  });

  group('Teclado (WCAG 2.1.1 y 2.1.2)', () {
    testWidgets('Shift+Tab recorre el juego al revés', (tester) async {
      await abrirJuego(tester);
      final ida = await recorrerConTab(tester, 4);
      final vuelta = await recorrerConTab(tester, 3, atras: true);
      expect(vuelta, ida.reversed.skip(1).toList());
    });

    testWidgets('un diálogo encierra el foco y Esc lo cierra devolviéndolo', (tester) async {
      await abrirJuego(tester, ruta: Rutas.tienda);
      await pulsar(tester, find.byKey(const ValueKey('articulo-lupa')).first);
      final precio = find.descendant(
        of: find.byKey(const ValueKey('articulo-lupa')),
        matching: find.bySemanticsLabel(RegExp('Comprar')),
      );
      await pulsar(tester, precio);
      final dialogo = find.byKey(const ValueKey('dialogo-confirmacion'));
      expect(dialogo, findsOneWidget);
      for (var i = 0; i < 6; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(enfocadoDentroDe(dialogo), isTrue, reason: 'el foco salió del diálogo');
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(dialogo, findsNothing);
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'artículo lupa');
    });

    testWidgets('Enter y Espacio activan un botón', (tester) async {
      await abrirJuego(tester, tarjetas: fin.mazoLegal(3));
      // Salir → indicadores → tarjeta → Ilegal.
      await recorrerConTab(tester, 4);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(estadoJuego(tester).respuestas.single.veredicto, Veredicto.ilegal);
    });

    testWidgets('el panel de veredicto no se escapa con Esc (no es descartable)', (tester) async {
      await abrirJuego(tester, tarjetas: fin.mazoLegal(3));
      await pulsar(
        tester,
        find.byWidgetPredicate((w) => w is BotonVeredicto && w.veredicto == Veredicto.legal),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text(Textos.continuar), findsWidgets);
    });
  });

  group('Solo botones y reducir animaciones (WCAG 2.5.1 y 2.3.3)', () {
    testWidgets('un sprint completo se juega solo con botones y sin animaciones', (tester) async {
      await abrirJuego(
        tester,
        tarjetas: fin.mazoLegal(2),
        ajustes: const Ajustes(soloBotones: true, reducirAnimaciones: true),
      );
      expect(find.byKey(const ValueKey('pista-botones')), findsOneWidget);
      for (var i = 0; i < 2; i++) {
        await pulsar(
          tester,
          find.byWidgetPredicate((w) => w is BotonVeredicto && w.veredicto == Veredicto.legal),
        );
        await cerrarPanel(tester);
      }
      expect(find.byType(PantallaSprintCompletado), findsOneWidget);
    });

    for (final extendido in [true, false]) {
      testWidgets('Examen: la tecla P pausa solo con tiempo extendido ($extendido)', (
        tester,
      ) async {
        await jefe.abrirCrisis(tester, ajustes: Ajustes(tiempoExtendido: extendido));
        await pulsar(tester, find.byKey(const ValueKey('boton-enfrentar')));
        await recorrerConTab(tester, 2);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('capa-pausa')), extendido ? findsOneWidget : findsNothing);
      });
    }

    testWidgets('el Examen sin tiempo extendido no ofrece pausa; con él, sí', (tester) async {
      await jefe.abrirCrisis(tester);
      await pulsar(tester, find.byKey(const ValueKey('boton-enfrentar')));
      expect(find.byKey(const ValueKey('boton-pausa')), findsNothing);
      await jefe.elegir(tester, jefe.escenario[0].respuestaCorrecta);
      await tester.pumpAndSettle();
      await jefe.pasarChip(tester);
    });
  });

  group('No depender solo del color (WCAG 1.4.1)', () {
    for (final v in Veredicto.values) {
      testWidgets('el sello ${v.name} lleva texto', (tester) async {
        await montar(tester, SelloVeredicto(veredicto: v));
        expect(find.text(SelloVeredicto.texto(v)), findsOneWidget);
      });

      testWidgets('el botón ${v.name} lleva ícono y etiqueta', (tester) async {
        await montar(tester, BotonVeredicto(veredicto: v));
        expect(find.byType(Icon), findsWidgets);
        expect(
          find.byWidgetPredicate((w) => w is Text && (w.data ?? '').isNotEmpty),
          findsOneWidget,
        );
      });
    }

    testWidgets('el impacto se dice con signo además del color', (tester) async {
      await montar(
        tester,
        const ImpactoStartup(
          cambios: {IndicadorStartup.reputacion: 5, IndicadorStartup.riesgoLegal: -10},
        ),
      );
      expect(find.textContaining('+5'), findsOneWidget);
      expect(find.textContaining('−10'), findsOneWidget);
    });

    testWidgets('el plazo de hoy lleva ícono y texto, no solo rojo', (tester) async {
      await montar(
        tester,
        const SizedBox(
          width: 360,
          child: FilaApelacion(
            titulo: 'T',
            tema: 'Tema',
            dia: 3,
            dias: 0,
            colorModulo: Color(0xFF2B5FA8),
            alPresionar: null,
          ),
        ),
      );
      expect(find.byIcon(IconosApp.gavel), findsOneWidget);
      expect(find.textContaining('hoy'), findsOneWidget);
    });
  });

  group('ZonaTactilMinima (la guía de la auditoría)', () {
    testWidgets('detecta un control de 40 × 40', (tester) async {
      final semantica = tester.ensureSemantics();
      await montar(
        tester,
        Semantics(
          button: true,
          label: 'pequeño',
          onTap: () {},
          child: const SizedBox(width: 40, height: 40),
        ),
      );
      final evaluacion = await ZonaTactilMinima.android.evaluate(tester);
      expect(evaluacion.passed, isFalse);
      semantica.dispose();
    });

    testWidgets('omite un control cortado por el borde de su desplazable', (tester) async {
      final semantica = tester.ensureSemantics();
      final controlador = ScrollController(initialScrollOffset: 30);
      addTearDown(controlador.dispose);
      await montar(
        tester,
        Column(
          children: [
            const SizedBox(height: 100),
            SizedBox(
              height: 200,
              child: ListView(
                controller: controlador,
                children: [
                  for (var i = 0; i < 6; i++)
                    Semantics(
                      button: true,
                      label: 'fila $i',
                      onTap: () {},
                      child: const SizedBox(height: 60),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
      final evaluacion = await ZonaTactilMinima.android.evaluate(tester);
      expect(evaluacion.passed, isTrue, reason: evaluacion.reason);
      semantica.dispose();
    });
  });
}
