import 'dart:async';

import 'package:abogator/app/enrutador.dart';
import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/boton_buzon.dart';
import 'package:abogator/componentes/boton_veredicto.dart';
import 'package:abogator/componentes/fila_apelacion.dart';
import 'package:abogator/componentes/mensaje_pantalla.dart';
import 'package:abogator/componentes/navegacion_inferior_app.dart';
import 'package:abogator/componentes/notificacion_apelacion.dart';
import 'package:abogator/core/tema/colores_marca.dart';
import 'package:abogator/core/tema/efectos.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:abogator/datos/mocks/mock_apelaciones.dart';
import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/datos/repositorios/repositorio_apelaciones.dart';
import 'package:abogator/funciones/acceso/pantalla_inicio_sesion.dart';
import 'package:abogator/funciones/apelaciones/pantalla_buzon.dart';
import 'package:abogator/funciones/apelaciones/pantalla_juicio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../ayudantes/falsos.dart';
import '../../ayudantes/montar.dart';
import '../../ayudantes/sin_desbordes.dart';
import '../juego/ayudante_juego.dart';

final ahoraServidor = DateTime.utc(2026, 11, 20, 10);

MockApelaciones servidor({bool conSemilla = true}) => MockApelaciones(
  espera: Duration.zero,
  ahoraServidor: () => ahoraServidor,
  conSemilla: conSemilla,
);

Finder fila(String id) => find.byKey(ValueKey('fila-$id'));

Finder get botonIniciar => find.widgetWithText(BotonApp, Textos.iniciarApelacionesHoy);

Future<void> abrirBuzon(
  WidgetTester tester, {
  RepositorioApelaciones? apelaciones,
  Size tamano = const Size(390, 844),
  bool esperar = true,
}) async {
  await abrirJuego(
    tester,
    ruta: Rutas.buzon,
    apelaciones: apelaciones ?? servidor(),
    tamano: tamano,
    esperar: esperar,
  );
}

Future<void> elegir(WidgetTester tester, Veredicto v) =>
    tocar(tester, find.byWidgetPredicate((w) => w is BotonVeredicto && w.veredicto == v));

void main() {
  group('pantalla 21', () {
    for (final brillo in Brightness.values) {
      testWidgets('estructura, textos y colores de Figma (${brillo.name})', (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = brillo;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        await abrirBuzon(tester);
        final t = brillo == Brightness.dark ? TokensColor.oscuro : TokensColor.claro;
        expect(find.text(Textos.buzonTitulo), findsOneWidget);
        expect(find.text(Textos.buzonSubtitulo), findsOneWidget);
        expect(find.text('2 juicios de apelación hoy'), findsOneWidget);
        expect(find.text(Textos.recompensaApelacion), findsOneWidget);
        expect(find.byType(FilaApelacion), findsNWidgets(6));
        expect(find.text('Librería GPL en app cerrada'), findsOneWidget);
        expect(find.text('Día 3 · hoy · +1 vida'), findsOneWidget);
        expect(find.text('Día 7 · hoy · +1 vida'), findsOneWidget);
        expect(find.text('Día 3 · mañana'), findsOneWidget);
        expect(find.text('Día 7 · en 2 días'), findsOneWidget);
        expect(find.text('Día 14 · en 5 días'), findsOneWidget);
        // Pestaña Buzón activa y sin botón Buzón flotante.
        expect(
          tester.widget<NavegacionInferiorApp>(find.byType(NavegacionInferiorApp)).actual,
          PestanaApp.buzon,
        );
        expect(find.byType(BotonBuzon), findsNothing);
        // Lista: superficie, borde 1, radio 20.
        final lista =
            tester.widget<Container>(find.byKey(const ValueKey('lista-apelaciones'))).decoration!
                as BoxDecoration;
        expect((lista.color, lista.borderRadius), (t.fondoSuperficie, BorderRadius.circular(20)));
        // Recompensa y píldoras.
        final recompensa =
            tester.widget<Container>(find.byKey(const ValueKey('recompensa-buzon'))).decoration!
                as BoxDecoration;
        expect(
          (recompensa.color, recompensa.borderRadius),
          (t.fondoDestacado, BorderRadius.circular(18)),
        );
        final pildoras = tester
            .widgetList<Container>(find.byKey(const ValueKey('pildora-plazo')))
            .map((c) => (c.decoration! as BoxDecoration).color)
            .toList();
        expect(pildoras.take(2), everyElement(t.estadoIlegal));
        expect(pildoras.skip(2), everyElement(t.fondoSuperficieAlt));
        // Franja en el color del módulo.
        final franja =
            tester
                    .widget<Container>(
                      find.descendant(
                        of: fila('ape-001'),
                        matching: find.byKey(const ValueKey('franja-modulo')),
                      ),
                    )
                    .decoration!
                as BoxDecoration;
        expect(franja.color, ColoresModulo.enOrden[0]);
        expect(
          tester.getSize(find.byKey(const ValueKey('franja-modulo')).first),
          const Size(6, 40),
        );
      });
    }

    testWidgets('fila de hoy abre el juicio', (tester) async {
      await abrirBuzon(tester);
      await tocar(tester, fila('ape-001'));
      expect(rutaActual(tester), Rutas.juicioApelacionDe('ape-001'));
      expect(find.byType(PantallaJuicio), findsOneWidget);
    });

    testWidgets('fila futura no navega: avisa cuándo se abre', (tester) async {
      await abrirBuzon(tester);
      await tocar(tester, fila('ape-003'));
      expect(rutaActual(tester), Rutas.buzon);
      expect(find.text('Esta apelación se abre mañana'), findsOneWidget);
      await tocar(tester, fila('ape-004'));
      expect(find.text('Esta apelación se abre en 2 días'), findsOneWidget);
    });

    testWidgets('el botón queda fijo encima de la barra y abre la primera de hoy', (tester) async {
      await abrirBuzon(tester);
      final antes = tester.getTopLeft(botonIniciar);
      expect(
        tester.getBottomLeft(find.text(Textos.notaApelaciones)).dy,
        lessThanOrEqualTo(tester.getTopLeft(find.byType(NavegacionInferiorApp)).dy),
      );
      await tester.drag(find.byKey(const ValueKey('buzon-desplazable')), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(botonIniciar), antes);
      await tester.tap(botonIniciar);
      await tester.pumpAndSettle();
      expect(rutaActual(tester), Rutas.juicioApelacionDe('ape-001'));
    });

    testWidgets('singular y sin apelaciones de hoy (botón deshabilitado)', (tester) async {
      await abrirBuzon(
        tester,
        apelaciones: ApelacionesFalsas.conDias([0, 3], ahora: ahoraServidor),
      );
      expect(find.text('1 juicio de apelación hoy'), findsOneWidget);
      await abrirBuzon(
        tester,
        apelaciones: ApelacionesFalsas.conDias([1, 3], ahora: ahoraServidor),
      );
      expect(find.text(Textos.juiciosHoy(0)), findsOneWidget);
      expect(find.text(Textos.proximasApelaciones), findsOneWidget);
      expect(tester.widget<BotonApp>(botonIniciar).alPresionar, isNull);
      expect(find.text(Textos.iniciarApelacionesHoy), findsOneWidget);
    });

    testWidgets('vacío: Sarko, título y texto, sin botón', (tester) async {
      await abrirBuzon(tester, apelaciones: servidor(conSemilla: false));
      expect(find.text(Textos.buzonVacioTitulo), findsOneWidget);
      expect(find.text(Textos.buzonVacioTexto), findsOneWidget);
      expect(find.byType(FilaApelacion), findsNothing);
      expect(botonIniciar, findsNothing);
    });

    testWidgets('cargando, error y reintento', (tester) async {
      final repo = ApelacionesFalsas.conDias([0], ahora: ahoraServidor)..bloqueo = Completer();
      await abrirBuzon(tester, apelaciones: repo, esperar: false);
      expect(find.byKey(const ValueKey('esqueleto-buzon')), findsOneWidget);
      repo
        ..fallar = true
        ..bloqueo!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(MensajePantalla), findsOneWidget);
      expect(find.text(Textos.buzonErrorCarga), findsOneWidget);
      repo
        ..fallar = false
        ..bloqueo = null;
      await tester.tap(find.text(Textos.reintentar));
      await tester.pumpAndSettle();
      expect(find.byType(FilaApelacion), findsOneWidget);
    });

    testWidgets('foco inicial en el título; semántica de la lista y de las filas', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrirBuzon(tester);
      final enFoco = FocusManager.instance.primaryFocus!.context!;
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('titulo-buzon')),
          matching: find.byElementPredicate((e) => e == enFoco),
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(Textos.listaApelaciones(6)), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          'Librería GPL en app cerrada, Licencias OSS, día 3, disponible hoy, +1 vida si la ganas',
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp(r', disponible mañana$')), findsOneWidget);
      final nodo = tester.getSemantics(fila('ape-003'));
      expect(nodo.flagsCollection.isButton, isTrue);
      semantica.dispose();
    });

    testWidgets('teclado: Tab llega a las filas y Enter da el aviso de una futura', (tester) async {
      await abrirBuzon(tester);
      for (var i = 0; i < 12; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final f = FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<FilaApelacion>();
        if (f != null && f.dias > 0) break;
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Esta apelación se abre mañana'), findsOneWidget);
    });

    test('contrastes de la píldora en claro y oscuro', () {
      for (final t in [TokensColor.claro, TokensColor.oscuro]) {
        expect(Contraste.razon(t.textoEnPrimario, t.estadoIlegal), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.textoSecundario, t.fondoSuperficieAlt), greaterThanOrEqualTo(4.5));
      }
    });

    probarSinDesbordes((tester, tamano, _) async {
      await abrirBuzon(tester, tamano: tamano);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byKey(const ValueKey('buzon-desplazable')), const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('"Ir al Buzón de Apelaciones" de la 20 lleva aquí', (tester) async {
      await abrirJuego(tester, ruta: Rutas.sinVidasDe('mod-1'), vidas: 0, apelaciones: servidor());
      await tocar(tester, find.widgetWithText(BotonApp, Textos.irAlBuzon));
      expect(find.byType(PantallaBuzon), findsOneWidget);
    });
  });

  group('registro de fallos', () {
    final tarjetas = MockTarjetas.tarjetasPorSprint['spr-1-3']!;

    testWidgets('al completar el sprint las falladas llegan como "Día 3 · en 3 días"', (
      tester,
    ) async {
      final repo = servidor();
      await abrirJuego(
        tester,
        tarjetas: {sprintMock: tarjetas.take(2).toList()},
        apelaciones: repo,
      );
      await elegir(tester, Veredicto.legal); // la 1 es Ilegal
      await cerrarPanel(tester);
      await elegir(tester, Veredicto.legal); // la 2 es Legal
      await cerrarPanel(tester);
      expect(rutaActual(tester), Rutas.sprintCompletadoDe(sprintMock));
      final buzon = await repo.obtenerBuzon();
      expect(buzon.total, 7);
      final nueva = buzon.apelaciones.singleWhere((a) => a.tarjetaId == tarjetas[0].id);
      expect(
        (nueva.titulo, nueva.tema, nueva.moduloId),
        (tarjetas[0].titulo, tarjetas[0].tema, 'mod-1'),
      );
      expect(buzon.diasHasta(nueva), 3);
      // En el Buzón se ve con su plazo, y el contador del Inicio sube.
      contenedorDe(tester).read(enrutadorProvider).go(Rutas.buzon);
      await tester.pumpAndSettle();
      expect(find.text('Día 3 · en 3 días'), findsOneWidget);
      contenedorDe(tester).read(enrutadorProvider).go(Rutas.inicio);
      await tester.pumpAndSettle();
      expect(tester.widget<BotonBuzon>(find.byType(BotonBuzon)).pendientes, 7);
    });

    testWidgets('sin vidas también se registran (una sola vez)', (tester) async {
      final repo = servidor();
      await abrirJuego(
        tester,
        tarjetas: {sprintMock: tarjetas.take(3).toList()},
        vidas: 1,
        apelaciones: repo,
      );
      await elegir(tester, Veredicto.legal);
      await cerrarPanel(tester);
      expect(rutaActual(tester), Rutas.sinVidas);
      final buzon = await repo.obtenerBuzon();
      expect(buzon.apelaciones.where((a) => a.tarjetaId == tarjetas[0].id), hasLength(1));
      expect(buzon.total, 7);
    });

    testWidgets('en quiebra también se registran', (tester) async {
      final repo = servidor();
      const quiebra = Tarjeta(
        id: 'tar-quiebra',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 1 · PRUEBA',
        personaje: 'CEO',
        rol: 'Dirección',
        texto: 'Caso que quiebra la Startup',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion: 'E',
        titulo: 'Caso de quiebra',
        tema: 'Prueba',
        impactoFallo: ImpactoTarjeta(riesgoLegal: 100),
      );
      await abrirJuego(
        tester,
        tarjetas: {
          sprintMock: [quiebra, tarjetas[1]],
        },
        apelaciones: repo,
      );
      await elegir(tester, Veredicto.legal);
      await cerrarPanel(tester);
      expect(rutaActual(tester), Rutas.startupQuiebraDe(sprintMock));
      final buzon = await repo.obtenerBuzon();
      expect(buzon.apelaciones.map((a) => a.titulo), contains('Caso de quiebra'));
    });

    testWidgets('salir a la mitad no registra nada', (tester) async {
      final repo = servidor();
      await abrirJuego(
        tester,
        tarjetas: {sprintMock: tarjetas.take(3).toList()},
        apelaciones: repo,
      );
      await elegir(tester, Veredicto.legal);
      await cerrarPanel(tester);
      await tester.tap(find.byKey(const ValueKey('caja-cerrar')));
      await tester.pumpAndSettle();
      await tester.tap(salirDelDialogo);
      await tester.pumpAndSettle();
      expect((await repo.obtenerBuzon()).total, 6);
    });

    testWidgets('la misma tarjeta fallada otra vez no se duplica', (tester) async {
      final repo = servidor();
      // La GPL ya está en el Buzón (semilla).
      final gpl = tarjetas.firstWhere((t) => t.id == 'tar-gpl-01');
      await abrirJuego(
        tester,
        tarjetas: {
          sprintMock: [gpl],
        },
        apelaciones: repo,
      );
      await elegir(tester, Veredicto.legal);
      await cerrarPanel(tester);
      final buzon = await repo.obtenerBuzon();
      expect(buzon.apelaciones.where((a) => a.tarjetaId == 'tar-gpl-01'), hasLength(1));
      expect(buzon.total, 6);
    });
  });

  group('21b · notificación', () {
    enAmbosModos('maqueta con día 3: textos y colores del sistema', (tester, brillo) async {
      await montar(
        tester,
        const NotificacionApelacion(tituloCaso: 'Librería GPL en app cerrada', dias: 3),
        brillo: brillo,
      );
      expect(find.text(Textos.notificacionApp), findsOneWidget);
      expect(find.text('ahora'), findsOneWidget);
      expect(find.text('⚖️ Tienes un juicio de apelación pendiente'), findsOneWidget);
      expect(
        find.text('Hace 3 días fallaste “Librería GPL en app cerrada”. Gánala y recupera 1 vida.'),
        findsOneWidget,
      );
      expect(tester.getSize(find.byType(NotificacionApelacion)).width, 358);
      final titulo = tester.widget<Text>(find.text(Textos.notificacionApelacionTitulo));
      expect(titulo.style!.color, EfectosApp.textoNotificacion);
    });

    testWidgets('con día 7 y otra hora', (tester) async {
      await montar(
        tester,
        const NotificacionApelacion(tituloCaso: 'Caso', dias: 7, hora: 'hace 2 h'),
      );
      expect(find.text('Hace 7 días fallaste “Caso”. Gánala y recupera 1 vida.'), findsOneWidget);
      expect(find.text('hace 2 h'), findsOneWidget);
    });

    testWidgets('el enlace profundo con sesión abre el juicio', (tester) async {
      await abrirJuego(tester, ruta: Rutas.juicioApelacionDe('ape-001'), apelaciones: servidor());
      expect(rutaActual(tester), '/buzon/ape-001');
      expect(find.byType(PantallaJuicio), findsOneWidget);
    });

    testWidgets('sin sesión va al inicio de sesión', (tester) async {
      await abrirJuego(
        tester,
        ruta: Rutas.juicioApelacionDe('ape-001'),
        conSesion: false,
        apelaciones: servidor(),
      );
      expect(find.byType(PantallaInicioSesion), findsOneWidget);
    });
  });
}
