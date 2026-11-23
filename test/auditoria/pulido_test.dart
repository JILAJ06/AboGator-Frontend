import 'package:abogator/componentes/barra_juego.dart';
import 'package:abogator/componentes/boton_veredicto.dart';
import 'package:abogator/componentes/confeti_sprint.dart';
import 'package:abogator/componentes/fila_apelacion.dart';
import 'package:abogator/componentes/piezas_jefe.dart';
import 'package:abogator/componentes/sello_veredicto.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:abogator/datos/modelos/ajustes.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/funciones/ajustes/estado_ajustes.dart';
import 'package:abogator/funciones/ajustes/pantalla_ajustes.dart';
import 'package:abogator/funciones/juego/mazo_swipe.dart';
import 'package:abogator/funciones/juego/saldo_juego.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';
import '../ayudantes/tamano_pantalla.dart';
import '../funciones/apelaciones/buzon_test.dart' show abrirBuzon;
import '../funciones/apelaciones/juicio_test.dart' show abrirJuicio;
import '../funciones/bienvenida/bienvenida_test.dart' show abrirOnboarding, montarApp;
import '../funciones/jefe/jefe_test.dart' show abrirCrisis, elegir, escenario, estado;
import '../funciones/juego/ayudante_juego.dart';
import '../funciones/tienda/tienda_test.dart' show abrirTienda, precioDe;
import 'ayudante_auditoria.dart';

/// Primera tarjeta del sprint de prueba (normal).
Tarjeta get primera => MockTarjetas.tarjetasPorSprint[sprintMock]!.first;

Finder botonVeredicto(Veredicto v) =>
    find.byWidgetPredicate((w) => w is BotonVeredicto && w.veredicto == v);

Future<void> responder(WidgetTester tester, Veredicto v) async {
  await tester.ensureVisible(botonVeredicto(v));
  await tester.tap(botonVeredicto(v));
  await tester.pumpAndSettle();
}

MazoSwipeState mazo(WidgetTester tester) => tester.state<MazoSwipeState>(find.byType(MazoSwipe));

double opacidadSello(WidgetTester tester, Veredicto v) => tester
    .widget<SelloVeredicto>(find.byWidgetPredicate((w) => w is SelloVeredicto && w.veredicto == v))
    .opacidad;

void main() {
  group('A1 · el foco vuelve a quien abrió el diálogo', () {
    testWidgets('Tienda: cancelar devuelve el foco a la tarjeta de compra', (tester) async {
      await abrirTienda(tester);
      await tocar(tester, precioDe('lupa'));
      expect(find.byKey(const ValueKey('dialogo-confirmacion')), findsOneWidget);
      await tocar(tester, find.byKey(const ValueKey('boton-cancelar')));
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'artículo lupa');
    });

    testWidgets('Tienda: confirmar también devuelve el foco a esa tarjeta', (tester) async {
      await abrirTienda(tester);
      await tocar(tester, precioDe('abogado'));
      await tocar(tester, find.byKey(const ValueKey('boton-confirmar')));
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'artículo abogado');
      // La tarjeta de retorno no es parada de Tab.
      expect(FocusManager.instance.primaryFocus?.skipTraversal, isTrue);
    });

    testWidgets('Ajustes: elegir un tamaño devuelve el foco a la fila', (tester) async {
      await abrirJuego(tester, ruta: '/perfil/ajustes');
      expect(find.byType(PantallaAjustes), findsOneWidget);
      await tocar(tester, find.byKey(const ValueKey('ajuste-tamano')));
      await tocar(tester, find.bySemanticsLabel(Textos.porcentajeSemantica(120)));
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'ajuste tamaño de texto');
    });

    testWidgets('Ajustes: cerrar con Esc también devuelve el foco', (tester) async {
      await abrirJuego(tester, ruta: '/perfil/ajustes', tamano: Tamano.tabletHorizontal.medida);
      await tocar(tester, find.byKey(const ValueKey('ajuste-tamano')));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'ajuste tamaño de texto');
    });
  });

  group('A2 · diálogo "Salir del examen"', () {
    for (final t in [Tamano.movil, Tamano.tabletHorizontal]) {
      testWidgets('dice que el tiempo sigue y el foco inicial es "Seguir" (${t.name})', (
        tester,
      ) async {
        await abrirCrisis(tester, tamano: t.medida);
        await tocar(tester, find.byKey(const ValueKey('boton-enfrentar')));
        await tocar(tester, find.bySemanticsLabel(Textos.salir).first);
        expect(find.text(Textos.salirExamenTexto), findsOneWidget);
        expect(Textos.salirExamenTexto, contains('El tiempo sigue corriendo.'));
        final cancelar = find.byKey(const ValueKey('boton-cancelar'));
        expect(find.descendant(of: cancelar, matching: find.text(Textos.seguirEnExamen)), findsOne);
        expect(enfocadoDentroDe(cancelar), isTrue);
        // "Seguir en el examen" no sale.
        await tocar(tester, cancelar);
        expect(find.byKey(const ValueKey('pantalla-decision')), findsOneWidget);
      });
    }

    testWidgets('los demás diálogos de confirmación conservan "Cancelar"', (tester) async {
      await abrirTienda(tester);
      await tocar(tester, precioDe('lupa'));
      expect(find.text(Textos.cancelar), findsOneWidget);
    });
  });

  group('A3 · barra de progreso del examen', () {
    for (final t in [Tamano.movil, Tamano.tabletHorizontal]) {
      testWidgets('relleno accion/secundaria (${t.name})', (tester) async {
        await abrirCrisis(tester, tamano: t.medida);
        await tocar(tester, find.byKey(const ValueKey('boton-enfrentar')));
        final relleno = tester.widget<AnimatedContainer>(
          find.byKey(const ValueKey('relleno-progreso')),
        );
        final color = (relleno.decoration! as BoxDecoration).color;
        expect(color, TokensColor.claro.accionSecundaria);
      });
    }

    testWidgets('el juego conserva accion/primaria', (tester) async {
      await abrirJuego(tester);
      final relleno = tester.widget<AnimatedContainer>(
        find.byKey(const ValueKey('relleno-progreso')),
      );
      expect((relleno.decoration! as BoxDecoration).color, TokensColor.claro.accionPrimaria);
    });

    test('accion/secundaria contra la pista: ≥ 3:1 en claro y oscuro', () {
      for (final t in [TokensColor.claro, TokensColor.oscuro]) {
        expect(
          Contraste.razon(t.accionSecundaria, t.fondoSuperficieAlt),
          greaterThanOrEqualTo(Contraste.minimoNoTexto),
        );
      }
    });
  });

  group('A4 · orden de foco del juego (26b)', () {
    const veredictos = [
      'sem:Veredicto: Ilegal',
      'sem:Veredicto: Escalar al área jurídica',
      'sem:Veredicto: Legal con condiciones',
      'sem:Veredicto: Legal',
    ];
    const comodines = ['sem:Lupa, 2 disponibles', 'sem:Abogado, 1 disponible'];

    testWidgets('juego en móvil: Salir → HUD → tarjeta → veredictos → comodines', (tester) async {
      await abrirJuego(tester);
      final orden = await recorrerConTab(tester, 9);
      expect(orden, [
        'sem:Salir',
        'sem:${Textos.indicadoresSemantica}',
        'gesto-tarjeta',
        ...veredictos,
        ...comodines,
      ]);
    });

    testWidgets('juego en tablet: Salir → Pausa → tarjeta → veredictos → comodines', (
      tester,
    ) async {
      await abrirJuego(tester, tamano: Tamano.tabletHorizontal.medida);
      final orden = await recorrerConTab(tester, 9);
      expect(orden, ['sem:Salir', 'sem:Pausa', 'gesto-tarjeta', ...veredictos, ...comodines]);
    });

    for (final t in [Tamano.movil, Tamano.tabletHorizontal]) {
      testWidgets('juicio (${t.name}): Salir → tarjeta → veredictos', (tester) async {
        await abrirJuicio(tester, tamano: t.medida);
        expect(await recorrerConTab(tester, 6), ['sem:Salir', 'gesto-tarjeta', ...veredictos]);
      });

      testWidgets('Examen (${t.name}): Salir → tarjeta → veredictos', (tester) async {
        await abrirCrisis(tester, tamano: t.medida);
        await tocar(tester, find.byKey(const ValueKey('boton-enfrentar')));
        expect(await recorrerConTab(tester, 6), ['sem:Salir', 'gesto-tarjeta', ...veredictos]);
      });
    }

    testWidgets('Examen en tablet con tiempo extendido: la pausa va tras Salir', (tester) async {
      await abrirCrisis(
        tester,
        tamano: Tamano.tabletHorizontal.medida,
        ajustes: const Ajustes(tiempoExtendido: true),
      );
      await tocar(tester, find.byKey(const ValueKey('boton-enfrentar')));
      expect((await recorrerConTab(tester, 3)), ['sem:Salir', 'sem:Pausa', 'gesto-tarjeta']);
    });

    testWidgets('la tarjeta muestra el anillo solo con teclado', (tester) async {
      await abrirJuego(tester);
      await recorrerConTab(tester, 3);
      expect(
        tester.widget<Widget>(find.byKey(const ValueKey('foco-tarjeta'))),
        isA<Widget>().having((w) => (w as dynamic).visible as bool, 'visible', isTrue),
      );
    });
  });

  group('A5 · onboarding en tablet se puede deslizar', () {
    Future<void> abrir(WidgetTester tester, {bool soloBotones = false}) async {
      await montarApp(tester, tamano: Tamano.tabletHorizontal.medida);
      if (soloBotones) {
        contenedorApp(tester)
            .read(ajustesProvider.notifier)
            .cargados(const Ajustes(soloBotones: true));
      }
      await abrirOnboarding(tester);
      expect(find.text(Textos.onboarding1Titulo), findsOneWidget);
    }

    testWidgets('a la izquierda avanza y a la derecha regresa', (tester) async {
      await abrir(tester);
      await tester.drag(find.byKey(const ValueKey('deslizar-onboarding')), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text(Textos.onboarding2Titulo), findsOneWidget);
      await tester.drag(find.byKey(const ValueKey('deslizar-onboarding')), const Offset(300, 0));
      await tester.pumpAndSettle();
      expect(find.text(Textos.onboarding1Titulo), findsOneWidget);
    });

    testWidgets('un arrastre corto y lento no cambia de página', (tester) async {
      await abrir(tester);
      await tester.timedDrag(
        find.byKey(const ValueKey('deslizar-onboarding')),
        const Offset(-20, 0),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();
      expect(find.text(Textos.onboarding1Titulo), findsOneWidget);
    });

    testWidgets('con "Solo botones" no se desliza (tablet)', (tester) async {
      await abrir(tester, soloBotones: true);
      expect(find.byKey(const ValueKey('deslizar-onboarding')), findsNothing);
      await tester.drag(find.text(Textos.onboarding1Titulo), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text(Textos.onboarding1Titulo), findsOneWidget);
    });

    testWidgets('con "Solo botones" el PageView del móvil tampoco se desliza', (tester) async {
      await montarApp(tester);
      contenedorApp(tester)
          .read(ajustesProvider.notifier)
          .cargados(const Ajustes(soloBotones: true));
      await abrirOnboarding(tester);
      final pagina = tester.widget<PageView>(find.byType(PageView));
      expect(pagina.physics, isA<NeverScrollableScrollPhysics>());
    });
  });

  group('A6 · la tarjeta se queda con su sello mientras la hoja está abierta', () {
    testWidgets('tablet: queda retenida con el sello y sale al cerrar la hoja', (tester) async {
      await abrirJuego(tester, tamano: Tamano.tabletHorizontal.medida);
      final v = primera.respuestaCorrecta;
      final textoAntes = textoActual(tester);
      await responder(tester, v);
      // Hoja abierta, tarjeta visible con su sello completo.
      expect(find.byKey(const ValueKey('hoja-lateral')), findsOneWidget);
      expect(mazo(tester).retenida, isTrue);
      expect(opacidadSello(tester, v), 1);
      expect(textoActual(tester), textoAntes);
      final zona = tester.getRect(find.byType(MazoSwipe));
      final tarjetaRect = tester.getRect(find.byKey(const ValueKey('gesto-tarjeta')));
      expect(zona.overlaps(tarjetaRect), isTrue);
      // El veredicto ya se calculó y se guardó al confirmar (como antes).
      expect(estadoJuego(tester).respuestas, isNotEmpty);
      // Cerrar la hoja: llega la siguiente y la anterior sale volando.
      await cerrarPanel(tester, settle: false);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byKey(const ValueKey('tarjeta-saliente')), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('tarjeta-saliente')), findsNothing);
      expect(mazo(tester).retenida, isFalse);
      expect(textoActual(tester), isNot(textoAntes));
    });

    testWidgets('tablet con teclado: flecha y Enter dejan la tarjeta retenida', (tester) async {
      await abrirJuego(tester, tamano: Tamano.tabletHorizontal.medida);
      await recorrerConTab(tester, 3);
      final v = primera.respuestaCorrecta;
      await tester.sendKeyEvent(teclaDe(v));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(mazo(tester).retenida, isTrue);
      expect(opacidadSello(tester, v), 1);
    });

    testWidgets('tablet con "Solo botones" y "Reducir animaciones": desaparece al cerrar', (
      tester,
    ) async {
      await abrirJuego(
        tester,
        tamano: Tamano.tabletHorizontal.medida,
        ajustes: const Ajustes(soloBotones: true, reducirAnimaciones: true),
      );
      await responder(tester, primera.respuestaCorrecta);
      expect(mazo(tester).retenida, isTrue);
      await cerrarPanel(tester, settle: false);
      await tester.pump();
      expect(find.byKey(const ValueKey('tarjeta-saliente')), findsNothing);
      expect(mazo(tester).retenida, isFalse);
    });

    for (final t in [Tamano.movil, Tamano.tabletMinima]) {
      testWidgets('${t.name}: la tarjeta sale volando como siempre', (tester) async {
        await abrirJuego(tester, tamano: t.medida);
        final v = primera.respuestaCorrecta;
        await responder(tester, v);
        expect(mazo(tester).retenida, isFalse);
        expect(opacidadSello(tester, v), 0);
      });
    }

    testWidgets('juicio en tablet: también queda retenida', (tester) async {
      await abrirJuicio(tester, tamano: Tamano.tabletHorizontal.medida);
      await responder(tester, Veredicto.legal);
      // Tras el veredicto el juicio muestra su resultado; mientras tanto la
      // tarjeta no salió volando.
      if (find.byType(MazoSwipe).evaluate().isNotEmpty) {
        expect(mazo(tester).retenida, isTrue);
      }
    });

    testWidgets('Examen en tablet: la tarjeta con su sello durante el contraargumento', (
      tester,
    ) async {
      await abrirCrisis(tester, tamano: Tamano.tabletHorizontal.medida);
      await tocar(tester, find.byKey(const ValueKey('boton-enfrentar')));
      await elegir(tester, escenario[0].respuestaCorrecta);
      expect(find.byKey(const ValueKey('panel-contraargumento')), findsOneWidget);
      // En 28b el Examen ya dibuja la tarjeta enviada con su sello (T-11).
      expect(find.byKey(const ValueKey('tarjeta-enviada')), findsOneWidget);
      expect(opacidadSello(tester, escenario[0].respuestaCorrecta), 1);
    });
  });

  group('A7 · chip del golpe en tablet', () {
    testWidgets('va dentro de la tarjeta "El Jefe", a 14 y 16 de su esquina', (tester) async {
      await abrirCrisis(tester, tamano: Tamano.tabletHorizontal.medida);
      await tocar(tester, find.byKey(const ValueKey('boton-enfrentar')));
      await elegir(tester, escenario[0].respuestaCorrecta);
      await tester.tap(find.byKey(ValueKey('fundamento-${escenario[0].fundamentoCorrecto}')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final chip = find.byType(ChipGolpe);
      expect(chip, findsOneWidget);
      expect(find.descendant(of: find.byType(TarjetaJefe), matching: chip), findsOneWidget);
      final tarjeta = tester.getRect(find.byKey(const ValueKey('tarjeta-jefe')));
      final r = tester.getRect(chip);
      expect(r.top - tarjeta.top, closeTo(14, 0.5));
      expect(tarjeta.right - r.right, closeTo(16, 0.5));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(estado(tester).hp, lessThan(100));
    });

    testWidgets('en móvil sigue sobre la barra del Jefe', (tester) async {
      await abrirCrisis(tester);
      await tocar(tester, find.byKey(const ValueKey('boton-enfrentar')));
      await elegir(tester, escenario[0].respuestaCorrecta);
      await tester.tap(find.byKey(ValueKey('fundamento-${escenario[0].fundamentoCorrecto}')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ChipGolpe), findsOneWidget);
      expect(find.byType(TarjetaJefe), findsNothing);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });
  });

  group('A8 · confeti proporcional al panel', () {
    for (final ancho in [597.0, 480.0, 360.0]) {
      testWidgets('ninguna pieza queda fuera de un panel de $ancho', (tester) async {
        await montar(
          tester,
          SizedBox(
            width: ancho,
            child: const ConfetiSprint(
              piezas: ConfetiSprint.piezasAuditoriaTablet,
              anchoLienzo: 597,
              proporcional: true,
            ),
          ),
        );
        final caja = tester.getRect(find.byType(ConfetiSprint));
        for (var i = 0; i < ConfetiSprint.piezasAuditoriaTablet.length; i++) {
          final pieza = tester.getRect(find.byKey(ValueKey('confeti-$i')));
          expect(pieza.left, greaterThanOrEqualTo(caja.left - 0.5));
          expect(pieza.left + ConfetiSprint.anchoPieza, lessThanOrEqualTo(caja.right + 0.5));
        }
        if (ancho == 597) {
          // Con el panel de Figma las posiciones no cambian.
          final x0 = tester.getRect(find.byKey(const ValueKey('confeti-0'))).left - caja.left;
          expect(x0, closeTo(ConfetiSprint.piezasAuditoriaTablet.first.x, 0.5));
        }
      });
    }
  });

  group('A9 · saldo del juego en un archivo compartido', () {
    testWidgets('el Examen lee el saldo desde saldo_juego.dart', (tester) async {
      await abrirCrisis(tester, tamano: Tamano.tabletHorizontal.medida);
      await tocar(tester, find.byKey(const ValueKey('boton-enfrentar')));
      final saldo = await contenedorDe(tester).read(saldoJuegoProvider.future);
      expect(find.byType(BarraJuegoTablet), findsOneWidget);
      expect(find.text('$saldo'), findsWidgets);
    });
  });

  group('A10 · anuncio de selección del Buzón', () {
    testWidgets('una vez por cambio real (no al repetir ni en el extremo)', (tester) async {
      final anuncios = capturarAnuncios(tester);
      await abrirBuzon(tester, tamano: Tamano.tabletHorizontal.medida);
      String titulo(String id) =>
          tester.widget<FilaApelacion>(find.byKey(ValueKey('fila-$id'))).titulo;
      bool esSeleccion(String a) => a.startsWith('Seleccionada: ');

      // Tocar la ya seleccionada: sin anuncio.
      await tocar(tester, find.byKey(const ValueKey('fila-ape-001')));
      expect(anuncios.where(esSeleccion), isEmpty);
      // Flecha arriba en la primera: sin anuncio.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(anuncios.where(esSeleccion), isEmpty);
      // Cambio real: un anuncio.
      await tocar(tester, find.byKey(const ValueKey('fila-ape-002')));
      expect(anuncios.where(esSeleccion), [Textos.juicioSeleccionado(titulo('ape-002'))]);
      // Repetir: sigue siendo uno.
      await tocar(tester, find.byKey(const ValueKey('fila-ape-002')));
      expect(anuncios.where(esSeleccion), hasLength(1));
    });

    testWidgets('el detalle ya no es región en vivo (no duplica el anuncio)', (tester) async {
      await abrirBuzon(tester, tamano: Tamano.tabletHorizontal.medida);
      final manejador = tester.ensureSemantics();
      final enVivo = find.descendant(
        of: find.byKey(const ValueKey('detalle-juicio')),
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && (w.properties.liveRegion ?? false),
        ),
      );
      expect(enVivo, findsNothing);
      manejador.dispose();
    });
  });
}

/// El contenedor de la app montada con `montarApp`.
ProviderContainer contenedorApp(WidgetTester tester) => contenedorDe(tester);

LogicalKeyboardKey teclaDe(Veredicto v) => switch (v) {
  Veredicto.legal => LogicalKeyboardKey.arrowRight,
  Veredicto.ilegal => LogicalKeyboardKey.arrowLeft,
  Veredicto.condicional => LogicalKeyboardKey.arrowUp,
  Veredicto.escalar => LogicalKeyboardKey.arrowDown,
};
