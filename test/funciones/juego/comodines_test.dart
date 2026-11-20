import 'package:abogator/componentes/barra_comodines.dart';
import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/boton_veredicto.dart';
import 'package:abogator/componentes/etiqueta_lupa.dart';
import 'package:abogator/componentes/panel_abogado.dart';
import 'package:abogator/componentes/panel_veredicto.dart';
import 'package:abogator/componentes/tarjeta_caso.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/mocks/mock_progreso.dart';
import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:abogator/datos/mocks/mock_tienda.dart';
import 'package:abogator/datos/modelos/articulo_tienda.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/funciones/inicio/logica_inicio.dart';
import 'package:abogator/funciones/juego/estado_juego.dart';
import 'package:abogator/funciones/juego/logica_comodines.dart';
import 'package:abogator/funciones/juego/logica_veredicto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'ayudante_juego.dart';

final tarjetas = MockTarjetas.tarjetasPorSprint['spr-1-3']!;

/// Tarjeta 1 (Ilegal, con micro-pregunta) y 2 (Legal) de spr-1-3.
final primera = tarjetas[0];
final segunda = tarjetas[1];

final modulo1 = [
  for (final s in MockProgreso.modulos.first.sprints.where((s) => !s.esExamenFinal))
    ...MockTarjetas.tarjetasPorSprint[s.id]!,
];

Map<String, List<Tarjeta>> mazo(List<Tarjeta> lista) => {sprintMock: lista};

PildoraComodin pildora(WidgetTester tester, String nombre) => tester.widget<PildoraComodin>(
  find.byWidgetPredicate((w) => w is PildoraComodin && w.nombre == nombre),
);

Finder pildoraDe(String nombre) =>
    find.byWidgetPredicate((w) => w is PildoraComodin && w.nombre == nombre);

Future<void> tocar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> elegir(WidgetTester tester, Veredicto v) =>
    tocar(tester, find.byWidgetPredicate((w) => w is BotonVeredicto && w.veredicto == v));

/// Cierra el panel de veredicto (saltando la micro-pregunta si la hay).
Future<void> cerrar(WidgetTester tester) => cerrarPanel(tester);

EstadoJuego estado(WidgetTester tester) => estadoJuego(tester);

void main() {
  group('tienda', () {
    test('empieza con lupa 2, abogado 1 y amparo 1, por instancia', () async {
      final a = MockTienda(espera: Duration.zero);
      expect(await a.obtenerComodines(), {
        Comodin.lupaAuditor: 2,
        Comodin.abogadoSenior: 1,
        Comodin.amparo: 1,
      });
      await a.consumirComodin(Comodin.lupaAuditor);
      expect((await a.obtenerComodines())[Comodin.lupaAuditor], 1);
      final b = MockTienda(espera: Duration.zero);
      expect((await b.obtenerComodines())[Comodin.lupaAuditor], 2);
    });

    test('consumir nunca baja de 0', () async {
      final t = MockTienda(espera: Duration.zero);
      for (var i = 0; i < 3; i++) {
        await t.consumirComodin(Comodin.amparo);
      }
      expect((await t.obtenerComodines())[Comodin.amparo], 0);
    });

    test('las descripciones dicen lo que hace cada comodín', () {
      String de(Comodin c) => MockTienda.articulos.firstWhere((a) => a.comodin == c).descripcion;
      expect(de(Comodin.lupaAuditor), 'Resalta las palabras trampa del caso.');
      expect(de(Comodin.abogadoSenior), 'Traduce el caso a términos legales y cita la norma.');
      expect(de(Comodin.amparo), 'Tu siguiente error no te quita vida.');
    });
  });

  group('contenido de las tarjetas del módulo 1', () {
    test('todas tienen trampas contenidas en su texto, traducción y normas', () {
      expect(modulo1, hasLength(42));
      for (final t in modulo1) {
        expect(t.palabrasTrampa.length, inInclusiveRange(2, 4), reason: t.id);
        for (final p in t.palabrasTrampa) {
          expect(t.texto, contains(p), reason: '${t.id}: "$p"');
        }
        expect(t.traduccionLegal, isNotNull, reason: t.id);
        expect(t.traduccionLegal!.trim(), isNotEmpty, reason: t.id);
        expect(t.normas.length, inInclusiveRange(1, 3), reason: t.id);
        expect(t.aplicaLupa && t.aplicaAbogado, isTrue, reason: t.id);
      }
    });

    test('sin números de artículo ni de sección fuera de las dos normas de Figma', () {
      const figma = {
        'Licencia GPL-3.0, sección 5: obras derivadas',
        'Ley Federal del Derecho de Autor, art. 102 (programas de cómputo)',
      };
      final numerada = RegExp(
        r'\b(art\.?|artículos?|secci[oó]n|fracci[oó]n|párrafo)\s*\d',
        caseSensitive: false,
      );
      for (final t in modulo1) {
        for (final texto in [?t.traduccionLegal, ...t.normas]) {
          if (figma.contains(texto)) continue;
          expect(numerada.hasMatch(texto), isFalse, reason: '${t.id}: $texto');
        }
      }
      // Las de Figma siguen en la GPL (10c).
      final gpl = tarjetas.firstWhere((t) => t.id == 'tar-gpl-01');
      expect(gpl.normas, figma.toList());
      expect(gpl.palabrasTrampa, ['GPL-3.0', 'tal cual', 'código cerrado']);
      expect(
        gpl.traduccionLegal,
        '¿Se puede incluir código bajo GPL-3.0 dentro de un software propietario que se '
        'distribuye sin publicar su código fuente?',
      );
    });

    test('iniciales de dos letras; "QA" y "CL" como en Figma', () {
      for (final t in modulo1) {
        final ini = t.iniciales ?? LogicaInicio.iniciales(t.personaje);
        expect(ini.length, 2, reason: '${t.id}: ${t.personaje} → $ini');
      }
      expect(tarjetas.firstWhere((t) => t.personaje == 'QA Tester').iniciales, 'QA');
      expect(tarjetas.firstWhere((t) => t.personaje == 'Cliente').iniciales, 'CL');
    });
  });

  group('lógica', () {
    const t = Tarjeta(
      id: 't',
      tipo: TipoTarjeta.normal,
      etiquetaCaso: 'CASO',
      personaje: 'P',
      rol: 'R',
      texto: 'Una trampa aquí',
      respuestaCorrecta: Veredicto.legal,
      explicacion: 'E',
      palabrasTrampa: ['trampa'],
      traduccionLegal: '¿Pregunta?',
      normas: ['Norma'],
    );
    const sinComodines = Tarjeta(
      id: 'n',
      tipo: TipoTarjeta.normal,
      etiquetaCaso: 'CASO',
      personaje: 'P',
      rol: 'R',
      texto: 'Texto',
      respuestaCorrecta: Veredicto.legal,
      explicacion: 'E',
    );
    const todos = {Comodin.lupaAuditor: 2, Comodin.abogadoSenior: 1, Comodin.amparo: 1};

    test('restar no baja de 0', () {
      expect(LogicaComodines.restar(2), 1);
      expect(LogicaComodines.restar(0), 0);
    });

    test('Lupa: disponible, activa tras usarla y deshabilitada sin cantidad o sin trampas', () {
      const e = EstadoJuego(comodines: todos);
      expect(LogicaComodines.estadoLupa(e, t, panelAbierto: false), EstadoComodin.disponible);
      expect(
        LogicaComodines.estadoLupa(e.copiar(lupaUsada: {'t'}), t, panelAbierto: false),
        EstadoComodin.activo,
      );
      expect(
        LogicaComodines.estadoLupa(
          e.copiar(comodines: {...todos, Comodin.lupaAuditor: 0}),
          t,
          panelAbierto: false,
        ),
        EstadoComodin.deshabilitado,
      );
      expect(
        LogicaComodines.estadoLupa(e, sinComodines, panelAbierto: false),
        EstadoComodin.deshabilitado,
      );
      expect(LogicaComodines.estadoLupa(e, t, panelAbierto: true), EstadoComodin.deshabilitado);
      expect(
        LogicaComodines.estadoLupa(e, t, panelAbierto: false, habilitados: false),
        EstadoComodin.deshabilitado,
      );
    });

    test('Abogado: sin traducción o normas no aplica; consultado queda activo', () {
      const e = EstadoJuego(comodines: todos);
      expect(LogicaComodines.estadoAbogado(e, t, panelAbierto: false), EstadoComodin.disponible);
      expect(
        LogicaComodines.estadoAbogado(e, sinComodines, panelAbierto: false),
        EstadoComodin.deshabilitado,
      );
      final usado = e.copiar(abogadoUsado: {'t'}, comodines: {...todos, Comodin.abogadoSenior: 0});
      expect(LogicaComodines.estadoAbogado(usado, t, panelAbierto: false), EstadoComodin.activo);
      // Reabrirlo es gratis: sigue tocable aunque ya no queden.
      expect(
        LogicaComodines.tocable(Comodin.abogadoSenior, EstadoComodin.activo, panelAbierto: false),
        isTrue,
      );
    });

    test('Amparo: armado = activo; sin cantidad no se puede armar', () {
      const e = EstadoJuego(comodines: todos);
      expect(LogicaComodines.estadoAmparo(e, panelAbierto: false), EstadoComodin.disponible);
      expect(
        LogicaComodines.estadoAmparo(e.copiar(amparoActivo: true), panelAbierto: false),
        EstadoComodin.activo,
      );
      expect(
        LogicaComodines.estadoAmparo(
          e.copiar(comodines: {...todos, Comodin.amparo: 0}),
          panelAbierto: false,
        ),
        EstadoComodin.deshabilitado,
      );
    });

    test('nada es tocable con un panel abierto o en el Examen; la Lupa activa tampoco', () {
      for (final c in Comodin.values) {
        for (final est in EstadoComodin.values) {
          expect(LogicaComodines.tocable(c, est, panelAbierto: true), isFalse);
          expect(LogicaComodines.tocable(c, est, panelAbierto: false, habilitados: false), isFalse);
        }
      }
      expect(
        LogicaComodines.tocable(Comodin.lupaAuditor, EstadoComodin.activo, panelAbierto: false),
        isFalse,
      );
      expect(
        LogicaComodines.tocable(Comodin.amparo, EstadoComodin.activo, panelAbierto: false),
        isTrue,
      );
    });

    test('las trampas se encuentran en el texto (todas sus apariciones)', () {
      expect(TextoConTrampas.rangos('la trampa y otra trampa', ['trampa']), [(3, 9), (17, 23)]);
      expect(TextoConTrampas.rangos('nada', ['otra']), isEmpty);
    });
  });

  group('pantalla 10', () {
    testWidgets('las cantidades vienen de la tienda', (tester) async {
      final tienda = MockTienda(
        espera: Duration.zero,
        comodines: const {Comodin.lupaAuditor: 0, Comodin.abogadoSenior: 3, Comodin.amparo: 1},
      );
      await abrirJuego(tester, tarjetas: mazo([primera, segunda]), tienda: tienda);
      expect(find.text('Lupa ×0'), findsOneWidget);
      expect(find.text('Abogado ×3'), findsOneWidget);
      expect(pildora(tester, Textos.comodinLupa).estado, EstadoComodin.deshabilitado);
      expect(pildora(tester, Textos.comodinLupa).alPresionar, isNull);
      expect(pildora(tester, Textos.comodinAbogado).estado, EstadoComodin.disponible);
    });

    testWidgets('Lupa (10b): resalta, gasta 1, una vez por tarjeta, y se va al cambiar', (
      tester,
    ) async {
      final tienda = MockTienda(espera: Duration.zero);
      await abrirJuego(tester, tarjetas: mazo([primera, segunda]), tienda: tienda);
      expect(find.byType(EtiquetaLupa), findsNothing);
      await tocar(tester, pildoraDe(Textos.comodinLupa));
      expect(find.text('Lupa ×1'), findsOneWidget);
      expect(find.byType(EtiquetaLupa), findsOneWidget);
      expect(find.text(Textos.lupaActiva), findsOneWidget);
      expect(
        tester.widget<TarjetaCaso>(find.byType(TarjetaCaso)).palabrasTrampa,
        primera.palabrasTrampa,
      );
      expect(find.byKey(const ValueKey('trampas-globo')), findsOneWidget);
      expect(pildora(tester, Textos.comodinLupa).estado, EstadoComodin.activo);
      expect(pildora(tester, Textos.comodinLupa).alPresionar, isNull);
      // Se guardó al usarla.
      expect((await tienda.obtenerComodines())[Comodin.lupaAuditor], 1);
      // Tocarla otra vez no gasta.
      await tocar(tester, pildoraDe(Textos.comodinLupa));
      expect(estado(tester).cantidad(Comodin.lupaAuditor), 1);
      // Las estrellas y la Startup no cambian por usarla.
      expect(estado(tester).estadoStartup, estado(tester).estadoInicial);
      // Siguiente tarjeta: sin resaltado ni etiqueta y la Lupa vuelve a estar
      // disponible (queda 1).
      await elegir(tester, Veredicto.ilegal);
      await cerrar(tester);
      expect(find.byType(EtiquetaLupa), findsNothing);
      expect(tester.widget<TarjetaCaso>(find.byType(TarjetaCaso)).palabrasTrampa, isEmpty);
      expect(pildora(tester, Textos.comodinLupa).estado, EstadoComodin.disponible);
    });

    testWidgets('el lector lee las palabras trampa en el texto de la tarjeta', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrirJuego(tester, tarjetas: mazo([primera, segunda]));
      await tocar(tester, pildoraDe(Textos.comodinLupa));
      expect(
        find.bySemanticsLabel(
          RegExp('palabra trampa: ${RegExp.escape(primera.palabrasTrampa[0])}'),
        ),
        findsWidgets,
      );
      semantica.dispose();
    });

    testWidgets('Abogado (10c): abre, gasta 1 la primera vez y reabrir es gratis', (tester) async {
      final tienda = MockTienda(espera: Duration.zero);
      await abrirJuego(tester, tarjetas: mazo([primera, segunda]), tienda: tienda);
      await tocar(tester, pildoraDe(Textos.comodinAbogado));
      expect(find.byType(PanelAbogado), findsOneWidget);
      expect(find.text(Textos.abogadoTitulo), findsOneWidget);
      expect(find.text(Textos.abogadoSubtitulo), findsOneWidget);
      expect(find.text(Textos.abogadoPregunta), findsOneWidget);
      expect(find.text(primera.traduccionLegal!), findsOneWidget);
      expect(find.text(Textos.normaAplicable), findsOneWidget);
      for (final n in primera.normas) {
        expect(find.text(n), findsOneWidget);
      }
      expect(estado(tester).cantidad(Comodin.abogadoSenior), 0);
      expect((await tienda.obtenerComodines())[Comodin.abogadoSenior], 0);
      // La barra está deshabilitada con el panel abierto.
      expect(pildora(tester, Textos.comodinLupa).alPresionar, isNull);
      expect(pildora(tester, Textos.comodinAmparo).alPresionar, isNull);
      await tocar(
        tester,
        find.descendant(of: find.byType(PanelAbogado), matching: find.byType(BotonApp)),
      );
      expect(find.byType(PanelAbogado), findsNothing);
      // El foco vuelve a la píldora.
      final enFoco = FocusManager.instance.primaryFocus!.context!;
      expect(enFoco.findAncestorWidgetOfExactType<PildoraComodin>()?.nombre, Textos.comodinAbogado);
      // Reabrir: gratis, aunque quede en 0.
      expect(pildora(tester, Textos.comodinAbogado).estado, EstadoComodin.activo);
      await tocar(tester, pildoraDe(Textos.comodinAbogado));
      expect(find.byType(PanelAbogado), findsOneWidget);
      expect(estado(tester).cantidad(Comodin.abogadoSenior), 0);
      // Se cierra con Esc y con atrás.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(PanelAbogado), findsNothing);
      await tocar(tester, pildoraDe(Textos.comodinAbogado));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(PanelAbogado), findsNothing);
      // En la siguiente tarjeta ya no quedan.
      await elegir(tester, Veredicto.ilegal);
      await cerrar(tester);
      expect(pildora(tester, Textos.comodinAbogado).estado, EstadoComodin.deshabilitado);
    });

    testWidgets('Abogado: el título tiene el foco y se anuncia', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrirJuego(tester, tarjetas: mazo([primera, segunda]));
      await tocar(tester, pildoraDe(Textos.comodinAbogado));
      expect(find.bySemanticsLabel(Textos.abogadoTitulo), findsOneWidget);
      final enFoco = FocusManager.instance.primaryFocus!.context!;
      expect(enFoco.findAncestorWidgetOfExactType<PanelAbogado>(), isNotNull);
      semantica.dispose();
    });

    testWidgets('Amparo: armar y desarmar no gasta', (tester) async {
      await abrirJuego(tester, tarjetas: mazo([primera, segunda]));
      await tocar(tester, pildoraDe(Textos.comodinAmparo));
      expect(estado(tester).amparoActivo, isTrue);
      expect(estado(tester).cantidad(Comodin.amparo), 1);
      expect(pildora(tester, Textos.comodinAmparo).estado, EstadoComodin.activo);
      await tocar(tester, pildoraDe(Textos.comodinAmparo));
      expect(estado(tester).amparoActivo, isFalse);
      expect(estado(tester).cantidad(Comodin.amparo), 1);
    });

    testWidgets('Amparo armado + error → 14b sin perder vida y se gasta', (tester) async {
      final tienda = MockTienda(espera: Duration.zero);
      await abrirJuego(tester, tarjetas: mazo([primera, segunda]), tienda: tienda);
      await tocar(tester, pildoraDe(Textos.comodinAmparo));
      await elegir(tester, Veredicto.legal); // la correcta es Ilegal
      expect(
        tester.widget<PanelVeredicto>(find.byType(PanelVeredicto)).tipo,
        TipoPanelVeredicto.amparo,
      );
      final e = estado(tester);
      expect(e.vidas, 5);
      expect(e.amparoActivo, isFalse);
      expect(e.cantidad(Comodin.amparo), 0);
      expect(e.resultados.single.tipo, TipoVeredicto.amparo);
      expect((await tienda.obtenerComodines())[Comodin.amparo], 0);
      await cerrar(tester);
      expect(pildora(tester, Textos.comodinAmparo).estado, EstadoComodin.deshabilitado);
    });

    testWidgets('Amparo armado + acierto: sigue armado para la siguiente tarjeta', (tester) async {
      await abrirJuego(tester, tarjetas: mazo([primera, segunda]));
      await tocar(tester, pildoraDe(Textos.comodinAmparo));
      await elegir(tester, Veredicto.ilegal);
      await cerrar(tester);
      expect(estado(tester).amparoActivo, isTrue);
      expect(estado(tester).cantidad(Comodin.amparo), 1);
      expect(pildora(tester, Textos.comodinAmparo).estado, EstadoComodin.activo);
    });

    testWidgets('con el panel de veredicto abierto la barra no responde', (tester) async {
      await abrirJuego(tester, tarjetas: mazo([primera, segunda]));
      await elegir(tester, Veredicto.ilegal);
      for (final nombre in [Textos.comodinLupa, Textos.comodinAbogado, Textos.comodinAmparo]) {
        expect(pildora(tester, nombre).alPresionar, isNull, reason: nombre);
        expect(pildora(tester, nombre).estado, EstadoComodin.deshabilitado, reason: nombre);
      }
    });

    testWidgets('lo gastado se queda gastado al salir y volver a entrar', (tester) async {
      final tienda = MockTienda(espera: Duration.zero);
      await abrirJuego(tester, tarjetas: mazo([primera, segunda]), tienda: tienda);
      await tocar(tester, pildoraDe(Textos.comodinLupa));
      // Lo mismo que hace reiniciarJuego al salir y volver a entrar.
      contenedorDe(tester)
        ..invalidate(juegoProvider(sprintMock))
        ..invalidate(datosJuegoProvider(sprintMock));
      await tester.pumpAndSettle();
      expect(estado(tester).cantidad(Comodin.lupaAuditor), 1);
      expect(find.text('Lupa ×1'), findsOneWidget);
    });

    group('sin desbordes', () {
      for (final (tamano, escala) in [
        (const Size(390, 844), 1.0),
        (const Size(390, 844), 2.0),
        (const Size(360, 640), 2.0),
        (const Size(320, 640), 1.0),
        (const Size(320, 640), 2.0),
      ]) {
        testWidgets('${tamano.width.toInt()}×${tamano.height.toInt()} ${escala}x', (tester) async {
          tester.platformDispatcher.textScaleFactorTestValue = escala;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await abrirJuego(tester, tamano: tamano, tarjetas: mazo([primera, segunda]));
          await tocar(tester, pildoraDe(Textos.comodinLupa));
          expect(tester.takeException(), isNull);
          await tocar(tester, pildoraDe(Textos.comodinAbogado));
          expect(tester.takeException(), isNull);
          expect(
            tester.getSize(find.byType(PanelAbogado)).height,
            lessThanOrEqualTo(tamano.height),
          );
          await tocar(
            tester,
            find.descendant(of: find.byType(PanelAbogado), matching: find.byType(BotonApp)),
          );
          expect(tester.takeException(), isNull);
        });
      }
    });
  });
}
