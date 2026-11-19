import 'package:abogator/app/enrutador.dart';
import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/aviso_informativo.dart';
import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/boton_veredicto.dart';
import 'package:abogator/componentes/confeti_sprint.dart';
import 'package:abogator/componentes/estadisticas_sprint.dart';
import 'package:abogator/componentes/estrellas_sprint.dart';
import 'package:abogator/componentes/etiqueta_quiebra.dart';
import 'package:abogator/componentes/indicadores_startup.dart';
import 'package:abogator/componentes/tarjeta_caso.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/mocks/mock_progreso.dart';
import 'package:abogator/datos/modelos/estado_startup.dart';
import 'package:abogator/datos/modelos/modulo.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/datos/repositorios/proveedores_repositorios.dart';
import 'package:abogator/datos/repositorios/repositorio_progreso.dart';
import 'package:abogator/datos/repositorios/repositorio_tienda.dart';
import 'package:abogator/datos/repositorios/repositorio_vidas.dart';
import 'package:abogator/funciones/juego/logica_veredicto.dart';
import 'package:abogator/funciones/juego/pantalla_juego.dart';
import 'package:abogator/funciones/mapa/pantalla_mapa_sprints.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'ayudante_juego.dart';

/// Tarjeta de prueba con respuesta [correcta] y sus impactos.
Tarjeta tarjeta(
  String id,
  Veredicto correcta, {
  ImpactoTarjeta acierto = const ImpactoTarjeta(reputacion: 5),
  ImpactoTarjeta fallo = const ImpactoTarjeta(riesgoLegal: 5),
  ImpactoTarjeta parcial = const ImpactoTarjeta(velocidad: -5),
}) => Tarjeta(
  id: id,
  tipo: TipoTarjeta.normal,
  etiquetaCaso: 'CASO $id',
  personaje: 'Dev Junior',
  rol: 'Backend',
  texto: 'Caso $id',
  respuestaCorrecta: correcta,
  explicacion: 'Porque sí ($id)',
  impactoAcierto: acierto,
  impactoFallo: fallo,
  impactoParcial: parcial,
);

/// [n] tarjetas Legal en el sprint en curso del mock (spr-1-3).
Map<String, List<Tarjeta>> mazoLegal(int n) => {
  sprintMock: [for (var i = 1; i <= n; i++) tarjeta('t$i', Veredicto.legal)],
};

/// Responde la tarjeta que se ve con [v] y cierra el panel.
Future<void> responder(WidgetTester tester, Veredicto v) async {
  final boton = find.byWidgetPredicate((w) => w is BotonVeredicto && w.veredicto == v);
  await tester.ensureVisible(boton);
  await tester.tap(boton);
  await tester.pumpAndSettle();
  await cerrarPanel(tester);
}

Future<void> tocar(WidgetTester tester, String texto) async {
  final boton = find.widgetWithText(BotonApp, texto);
  await tester.ensureVisible(boton);
  await tester.pumpAndSettle();
  await tester.tap(boton);
  await tester.pumpAndSettle();
}

RepositorioProgreso progreso(WidgetTester tester) =>
    contenedorDe(tester).read(repositorioProgresoProvider);

RepositorioVidas vidasRepo(WidgetTester tester) =>
    contenedorDe(tester).read(repositorioVidasProvider);

RepositorioTienda tienda(WidgetTester tester) =>
    contenedorDe(tester).read(repositorioTiendaProvider);

Sprint sprintDe(List<Modulo> modulos, String id) =>
    modulos.expand((m) => m.sprints).firstWhere((s) => s.id == id);

/// Juega el mazo de 5 Legal: 4 aciertos y 1 error (80 %, 3 estrellas).
Future<void> completarConUnFallo(WidgetTester tester) async {
  await abrirJuego(tester, tarjetas: mazoLegal(5));
  for (var i = 0; i < 4; i++) {
    await responder(tester, Veredicto.legal);
  }
  await responder(tester, Veredicto.ilegal);
}

/// Llega a la quiebra por Riesgo legal con una sola respuesta incorrecta.
Future<void> quebrarPorRiesgo(WidgetTester tester, {Size tamano = const Size(390, 844)}) async {
  await abrirJuego(
    tester,
    tamano: tamano,
    tarjetas: {
      sprintMock: [
        tarjeta(
          't1',
          Veredicto.legal,
          fallo: const ImpactoTarjeta(presupuesto: -10, riesgoLegal: 80),
        ),
        tarjeta('t2', Veredicto.legal),
      ],
    },
  );
  await responder(tester, Veredicto.ilegal);
}

String? etiquetaEnfocada(WidgetTester tester, Map<String, Finder> zonas) {
  final contexto = FocusManager.instance.primaryFocus!.context!;
  final centro = tester.getCenter(find.byElementPredicate((e) => e == contexto));
  for (final MapEntry(:key, :value) in zonas.entries) {
    if (tester.getRect(value).contains(centro)) return key;
  }
  return null;
}

void main() {
  group('19 · Sprint completado', () {
    testWidgets('al terminar muestra estrellas, estadísticas, estado final y aviso', (
      tester,
    ) async {
      await completarConUnFallo(tester);
      expect(rutaActual(tester), Rutas.sprintCompletadoDe(sprintMock));
      expect(find.text(Textos.sprintCompletadoTitulo), findsOneWidget);
      expect(
        find.text('Tu MVP ya cumple con el aviso de privacidad y la Startup sigue en pie.'),
        findsOneWidget,
      );
      expect(tester.widget<EstrellasSprint>(find.byType(EstrellasSprint)).ganadas, 3);
      final e = tester.widget<EstadisticasSprint>(find.byType(EstadisticasSprint));
      expect((e.aciertos, e.total, e.xp, e.monedas), (4, 5, 40, 20));
      Finder enEstadisticas(String texto) =>
          find.descendant(of: find.byType(EstadisticasSprint), matching: find.text(texto));
      expect(enEstadisticas('4/5'), findsOneWidget);
      expect(enEstadisticas('+40'), findsOneWidget);
      expect(enEstadisticas('+20'), findsOneWidget);
      // Estado final con el cambio respecto al inicio del sprint (70/60/50/25).
      final indicadores = tester.widget<IndicadoresStartup>(find.byType(IndicadoresStartup));
      expect(indicadores.estado.reputacion, 80);
      expect(indicadores.cambios, {
        IndicadorStartup.reputacion: 20,
        IndicadorStartup.riesgoLegal: 5,
      });
      expect(find.text(Textos.avisoBuzon(1)), findsOneWidget);
      expect(find.text(Textos.repasarFallos), findsOneWidget);
      expect(find.byType(ConfetiSprint), findsOneWidget);
    });

    testWidgets('el estado del sprint sobrevive al cambio de pantalla', (tester) async {
      await completarConUnFallo(tester);
      expect(find.byType(PantallaJuego), findsNothing);
      final estado = estadoJuego(tester);
      expect(estado.fin, DestinoVeredicto.sprintCompletado);
      expect(estado.resultados, hasLength(5));
      expect((estado.xp, estado.monedas, estado.vidas), (40, 20, 4));
      expect(estado.guardado, isTrue);
    });

    testWidgets('guarda el resultado y el mapa y el Inicio lo reflejan', (tester) async {
      await completarConUnFallo(tester);
      final modulos = await progreso(tester).obtenerModulos();
      expect(sprintDe(modulos, 'spr-1-3').estado, EstadoSprint.completado);
      expect(sprintDe(modulos, 'spr-1-3').estrellas, 3);
      expect(sprintDe(modulos, 'spr-1-4').estado, EstadoSprint.enCurso);
      expect(
        await progreso(tester).obtenerEstadoStartup(),
        const EstadoStartup(presupuesto: 70, reputacion: 80, velocidad: 50, riesgoLegal: 30),
      );
      expect((await vidasRepo(tester).obtenerVidas()).cantidad, 4);
      expect(await tienda(tester).obtenerMonedas(), 260);

      await tocar(tester, Textos.continuarAlMapa);
      expect(rutaActual(tester), Rutas.mapaSprintsDe('mod-1'));
      expect(find.byType(PantallaMapaSprints), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Sprint 3.*completado')), findsWidgets);
      expect(find.bySemanticsLabel(RegExp('Sprint 4.*en curso')), findsWidgets);

      contenedorDe(tester).read(enrutadorProvider).go(Rutas.inicio);
      await tester.pumpAndSettle();
      expect(find.text('260'), findsWidgets);
    });

    testWidgets('sin falladas no hay aviso ni "Repasar mis fallos"', (tester) async {
      await abrirJuego(tester, tarjetas: mazoLegal(2));
      await responder(tester, Veredicto.legal);
      await responder(tester, Veredicto.legal);
      expect(find.text(Textos.sprintCompletadoTitulo), findsOneWidget);
      expect(find.byType(AvisoInformativo), findsNothing);
      expect(find.text(Textos.repasarFallos), findsNothing);
      expect(find.text(Textos.continuarAlMapa), findsOneWidget);
    });

    testWidgets('las parciales no cuentan como acierto ni van al buzón', (tester) async {
      await abrirJuego(tester, tarjetas: mazoLegal(2));
      await responder(tester, Veredicto.legal);
      await responder(tester, Veredicto.escalar);
      expect(find.text('1/2'), findsOneWidget);
      expect(tester.widget<EstrellasSprint>(find.byType(EstrellasSprint)).ganadas, 1);
      expect(find.byType(AvisoInformativo), findsNothing);
    });

    testWidgets('"Repasar mis fallos" lleva al Buzón', (tester) async {
      await completarConUnFallo(tester);
      await tocar(tester, Textos.repasarFallos);
      expect(rutaActual(tester), Rutas.buzon);
    });

    testWidgets('el título se anuncia y recibe el foco; orden de foco del resto', (tester) async {
      final semantica = tester.ensureSemantics();
      await completarConUnFallo(tester);
      final titulo = find.byKey(const ValueKey('titulo-fin-sprint'));
      expect(etiquetaEnfocada(tester, {'titulo': titulo}), 'titulo');
      final nodo = tester.getSemantics(titulo);
      expect(nodo.flagsCollection.isLiveRegion, isTrue);
      expect(nodo.flagsCollection.isHeader, isTrue);

      final zonas = {
        'estrellas': find.byType(EstrellasSprint),
        'estadisticas': find.byType(EstadisticasSprint),
        'estado': find.byKey(const ValueKey('estado-final')),
        'aviso': find.byKey(const ValueKey('aviso-buzon')),
        'continuar': find.widgetWithText(BotonApp, Textos.continuarAlMapa),
        'repasar': find.widgetWithText(BotonApp, Textos.repasarFallos),
      };
      final orden = <String?>[];
      for (var i = 0; i < zonas.length; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        orden.add(etiquetaEnfocada(tester, zonas));
      }
      expect(orden, zonas.keys.toList());

      // El lector de pantalla recorre lo mismo: título antes que estrellas.
      final recorrido = tester.semantics
          .simulatedAccessibilityTraversal()
          .map((n) => n.label)
          .where((l) => l.isNotEmpty)
          .toList();
      int posicion(String texto) => recorrido.indexWhere((l) => l.contains(texto));
      final pasos = [
        Textos.sprintCompletadoTitulo,
        Textos.estrellasSemantica(3, 3),
        '4 de 5 aciertos',
        Textos.estadoFinalStartup,
        Textos.avisoBuzon(1),
        Textos.continuarAlMapa,
      ].map(posicion).toList();
      expect(pasos, everyElement(greaterThanOrEqualTo(0)), reason: '$recorrido');
      expect(pasos, orderedEquals([...pasos]..sort()), reason: '$recorrido');
      semantica.dispose();
    });
  });

  group('19b · Startup en quiebra', () {
    testWidgets('por Riesgo legal: indicadores, causa, descripción y aviso', (tester) async {
      await quebrarPorRiesgo(tester);
      expect(rutaActual(tester), Rutas.startupQuiebraDe(sprintMock));
      expect(find.text(Textos.quiebraTitulo), findsOneWidget);
      expect(find.text('RIESGO LEGAL 100%'), findsOneWidget);
      expect(find.text(MockProgreso.modulos.first.sprints[2].mensajeQuiebra!), findsOneWidget);
      expect(find.text(Textos.avisoReinicio), findsOneWidget);
      final indicadores = tester.widget<IndicadoresStartup>(find.byType(IndicadoresStartup));
      expect(indicadores.estado.riesgoLegal, 100);
      expect(indicadores.cambios, {
        IndicadorStartup.presupuesto: -10,
        IndicadorStartup.riesgoLegal: 75,
      });
    });

    testWidgets('por Presupuesto: "PRESUPUESTO 0%"', (tester) async {
      await abrirJuego(
        tester,
        tarjetas: {
          sprintMock: [
            tarjeta('t1', Veredicto.legal, parcial: const ImpactoTarjeta(presupuesto: -70)),
            tarjeta('t2', Veredicto.legal),
          ],
        },
      );
      await responder(tester, Veredicto.escalar);
      expect(rutaActual(tester), Rutas.startupQuiebraDe(sprintMock));
      expect(
        tester.widget<EtiquetaQuiebra>(find.byType(EtiquetaQuiebra)).causa,
        CausaQuiebra.presupuesto,
      );
      expect(find.text('PRESUPUESTO 0%'), findsOneWidget);
      // Una parcial no quita vida.
      expect((await vidasRepo(tester).obtenerVidas()).cantidad, 5);
    });

    testWidgets('guarda las vidas perdidas y no cambia el progreso', (tester) async {
      await quebrarPorRiesgo(tester);
      expect((await vidasRepo(tester).obtenerVidas()).cantidad, 4);
      final modulos = await progreso(tester).obtenerModulos();
      expect(sprintDe(modulos, 'spr-1-3').estado, EstadoSprint.enCurso);
      expect(await progreso(tester).obtenerEstadoStartup(), MockProgreso.estadoInicial);
      expect(await tienda(tester).obtenerMonedas(), 240);
    });

    testWidgets('"Reiniciar sprint" empieza desde cero y conserva las vidas perdidas', (
      tester,
    ) async {
      await quebrarPorRiesgo(tester);
      await tocar(tester, Textos.reiniciarSprint);
      expect(rutaActual(tester), Rutas.juegoDe(sprintMock));
      expect(find.byType(PantallaJuego), findsOneWidget);
      expect(textoActual(tester), 'Caso t1');
      final e = estadoJuego(tester);
      expect((e.indice, e.xp, e.monedas, e.vidas, e.fin), (0, 0, 0, 4, null));
      expect(e.estadoStartup, MockProgreso.estadoInicial);
      expect(e.resultados, isEmpty);
    });

    testWidgets('"Ir al Buzón de Apelaciones" lleva al Buzón', (tester) async {
      await quebrarPorRiesgo(tester);
      await tocar(tester, Textos.irAlBuzon);
      expect(rutaActual(tester), Rutas.buzon);
    });

    testWidgets('el título se anuncia y recibe el foco, antes que la causa', (tester) async {
      final semantica = tester.ensureSemantics();
      await quebrarPorRiesgo(tester);
      final titulo = find.byKey(const ValueKey('titulo-fin-sprint'));
      expect(etiquetaEnfocada(tester, {'titulo': titulo}), 'titulo');
      expect(tester.getSemantics(titulo).flagsCollection.isLiveRegion, isTrue);
      final recorrido = tester.semantics
          .simulatedAccessibilityTraversal()
          .map((n) => n.label)
          .where((l) => l.isNotEmpty)
          .toList();
      int posicion(String texto) => recorrido.indexWhere((l) => l.contains(texto));
      final pasos = [
        Textos.quiebraTitulo,
        Textos.etiquetaQuiebraRiesgoSemantica,
        'Una auditoría',
        Textos.indicadoresSemantica,
        Textos.avisoReinicio,
        Textos.reiniciarSprint,
        Textos.irAlBuzon,
      ].map(posicion).toList();
      expect(pasos, everyElement(greaterThanOrEqualTo(0)), reason: '$recorrido');
      expect(pasos, orderedEquals([...pasos]..sort()), reason: '$recorrido');
      semantica.dispose();
    });
  });

  group('sin un sprint terminado', () {
    for (final (nombre, ruta) in [
      ('completado', Rutas.sprintCompletadoDe(sprintMock)),
      ('quiebra', Rutas.startupQuiebraDe(sprintMock)),
    ]) {
      testWidgets('$nombre: mensaje y botón de regreso al mapa', (tester) async {
        await abrirJuego(tester, ruta: ruta);
        expect(find.text(Textos.sinResultado), findsOneWidget);
        await tester.tap(find.text(Textos.volverAlMapa));
        await tester.pumpAndSettle();
        expect(rutaActual(tester), Rutas.mapaSprintsDe('mod-1'));
      });
    }

    testWidgets('una quiebra no se muestra en la ruta de completado', (tester) async {
      await quebrarPorRiesgo(tester);
      contenedorDe(tester).read(enrutadorProvider).go(Rutas.sprintCompletadoDe(sprintMock));
      await tester.pumpAndSettle();
      expect(find.text(Textos.sinResultado), findsOneWidget);
    });
  });

  testWidgets('"Comenzar sprint" desde la intro reinicia un sprint terminado', (tester) async {
    await completarConUnFallo(tester);
    contenedorDe(tester).read(enrutadorProvider).go(Rutas.introSprintDe('mod-1', sprintMock));
    await tester.pumpAndSettle();
    await tocar(tester, Textos.comenzarSprint);
    expect(find.byType(PantallaJuego), findsOneWidget);
    expect(find.byType(TarjetaCaso), findsOneWidget);
    expect(textoActual(tester), 'Caso t1');
    final e = estadoJuego(tester);
    expect((e.indice, e.fin, e.guardado, e.vidas), (0, null, false, 4));
    // Empieza desde el estado final guardado del sprint anterior.
    expect(e.estadoInicial.reputacion, 80);
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
        final nombre = '${tamano.width.toInt()}×${tamano.height.toInt()} texto ${escala}x';
        for (final quiebra in [false, true]) {
          testWidgets('${quiebra ? '19b' : '19'} $nombre ${brillo.name}', (tester) async {
            tester.platformDispatcher.textScaleFactorTestValue = escala;
            tester.platformDispatcher.platformBrightnessTestValue = brillo;
            addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
            addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
            if (quiebra) {
              await quebrarPorRiesgo(tester, tamano: tamano);
            } else {
              await abrirJuego(tester, tamano: tamano, tarjetas: mazoLegal(1));
              await responder(tester, Veredicto.ilegal);
            }
            expect(tester.takeException(), isNull);
            final columna = find.byKey(const ValueKey('columna-fin-sprint'));
            await tester.drag(columna, const Offset(0, -3000));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            // El último botón queda a la vista al final del contenido.
            final ultimo = find.widgetWithText(
              BotonApp,
              quiebra ? Textos.irAlBuzon : Textos.repasarFallos,
            );
            expect(ultimo.hitTestable(), findsOneWidget);
            expect(tester.getRect(ultimo).bottom, lessThanOrEqualTo(tamano.height));
          });
        }
      }
    }

    // La fuente de prueba es más ancha que Fredoka e Inter: se mide en una
    // pantalla alta para que el contenido quepa.
    testWidgets('si el contenido cabe, los botones quedan abajo, como en Figma', (tester) async {
      await abrirJuego(tester, tamano: const Size(390, 1100), tarjetas: mazoLegal(5));
      for (var i = 0; i < 4; i++) {
        await responder(tester, Veredicto.legal);
      }
      await responder(tester, Veredicto.ilegal);
      final continuar = tester.getRect(find.widgetWithText(BotonApp, Textos.continuarAlMapa));
      final repasar = tester.getRect(find.widgetWithText(BotonApp, Textos.repasarFallos));
      expect(repasar.bottom, 1100 - 36);
      expect(repasar.height, 48);
      expect(continuar.height, 52);
      expect(repasar.top - continuar.bottom, 8);
    });
  });
}
