import 'dart:ui' show CheckedState;

import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/opcion_justificacion.dart';
import 'package:abogator/componentes/panel_evidencia.dart';
import 'package:abogator/componentes/panel_justificacion.dart';
import 'package:abogator/componentes/snippet_codigo.dart';
import 'package:abogator/componentes/tarjeta_caso.dart';
import 'package:abogator/core/tema/efectos.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

final registro = MockTarjetas.tarjetasPorSprint['spr-1-3']![5];
final evidencia = registro.evidencia!;
final dilema = MockTarjetas.tarjetasPorSprint['spr-1-3']![9];

BoxDecoration decoDe(WidgetTester tester, Finder finder) =>
    tester.widget<Container>(finder).decoration! as BoxDecoration;

/// Color que resulta de pintar [arriba] (con opacidad) sobre [abajo].
Color sobre(Color arriba, Color abajo) => Color.alphaBlend(arriba, abajo);

Widget snippet({
  double ancho = 342,
  Set<int> reveladas = const {},
  Set<int> marcadas = const {},
  ValueChanged<List<int>>? alMarcar,
}) => SizedBox(
  width: ancho,
  child: SnippetCodigo(
    archivo: evidencia.archivo,
    lineas: evidencia.lineas,
    reveladas: reveladas,
    marcadas: marcadas,
    alMarcar: alMarcar,
  ),
);

void main() {
  group('SnippetCodigo', () {
    enAmbosModos('barra, 7 líneas numeradas, fondo #0B1220 y radio 18', (tester, brillo) async {
      await montar(tester, snippet(), brillo: brillo);
      final caja = decoDe(tester, find.byKey(const ValueKey('snippet-codigo')));
      expect(caja.color, EfectosApp.fondoSnippet);
      expect(caja.borderRadius, BorderRadius.circular(18));
      expect(find.text('  registro_form.dart'), findsOneWidget);
      for (var i = 1; i <= 7; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
      expect(find.text('Checkbox(value: true, // pre-marcado'), findsOneWidget);
      // Cada línea mide 24 (relleno 3 + 18 de alto de línea + 3).
      expect(tester.getSize(find.byKey(const ValueKey('linea-1'))).height, 24);
      // Los números quedan alineados: el texto empieza en la misma x.
      final x1 = tester.getTopLeft(find.text('TextField(label: "Correo"),')).dx;
      final x7 = tester.getTopLeft(find.text('ElevatedButton("Registrarme")')).dx;
      expect(x1, x7);
      esperarSoloColoresDelTema(tester, brillo);
    });

    testWidgets('línea clave revelada: fondo rojo al 28 % y texto #FECACA', (tester) async {
      await montar(tester, snippet(reveladas: {4, 5, 6}));
      final linea4 = tester.widget<Container>(find.byKey(const ValueKey('linea-4')));
      expect(linea4.color, EfectosApp.fondoLineaClave);
      final texto = tester.widget<Text>(find.text('Checkbox(value: true, // pre-marcado'));
      expect(texto.style!.color, EfectosApp.textoLineaClave);
      final linea1 = tester.widget<Container>(find.byKey(const ValueKey('linea-1')));
      expect(linea1.color, isNull);
    });

    testWidgets('marcadas: un resaltado por tramo, con borde 2 y radio 6', (tester) async {
      await montar(tester, snippet(marcadas: {4, 5, 6}));
      final tramo = find.byKey(const ValueKey('resaltado-4-6'));
      expect(tramo, findsOneWidget);
      expect(find.byKey(const ValueKey('resaltado-4-4')), findsNothing);
      // Cubre las 3 líneas (24 cada una) a 12 de los lados, como en Figma.
      expect(tester.getSize(tramo).height, 72);
      expect(
        tester.getTopLeft(tramo).dy,
        tester.getTopLeft(find.byKey(const ValueKey('linea-4'))).dy,
      );
      expect(tester.getTopLeft(tramo).dx - tester.getTopLeft(find.byType(SnippetCodigo)).dx, 12);
      final deco =
          tester
                  .widget<DecoratedBox>(
                    find.descendant(of: tramo, matching: find.byType(DecoratedBox)),
                  )
                  .decoration
              as BoxDecoration;
      expect((deco.border! as Border).top.color, EfectosApp.resaltado);
      expect((deco.border! as Border).top.width, 2);
      expect(deco.borderRadius, BorderRadius.circular(6));
    });

    test('tramos de líneas seguidas', () {
      expect(SnippetCodigo.tramos({}), isEmpty);
      expect(SnippetCodigo.tramos({6, 4, 5, 9}), [(4, 6), (9, 9)]);
      expect(SnippetCodigo.tramos({1, 3}), [(1, 1), (3, 3)]);
    });

    testWidgets('sin animación del resaltado con "reducir animaciones"', (tester) async {
      await montar(tester, snippet(marcadas: {4}), reducirAnimaciones: true);
      expect(
        tester
            .widget<TweenAnimationBuilder<double>>(find.byKey(const ValueKey('resaltado-4-4')))
            .duration,
        Duration.zero,
      );
    });

    test('contraste AA del texto sobre el fondo oscuro', () {
      const fondo = EfectosApp.fondoSnippet;
      final clave = sobre(EfectosApp.fondoLineaClave, fondo);
      final resaltado = sobre(
        EfectosApp.resaltado.withValues(alpha: EfectosApp.opacidadResaltado),
        fondo,
      );
      final resaltadoClave = sobre(
        EfectosApp.resaltado.withValues(alpha: EfectosApp.opacidadResaltado),
        clave,
      );
      for (final (texto, base, nombre) in [
        (EfectosApp.textoSnippet, fondo, 'texto'),
        (EfectosApp.textoSecundarioSnippet, fondo, 'números'),
        (EfectosApp.textoSecundarioSnippet, EfectosApp.barraSnippet, 'archivo'),
        (EfectosApp.textoLineaClave, clave, 'línea clave'),
        (EfectosApp.textoSecundarioSnippet, clave, 'número de línea clave'),
        (EfectosApp.textoSnippet, resaltado, 'texto marcado'),
        (EfectosApp.textoLineaClave, resaltadoClave, 'línea clave marcada'),
      ]) {
        expect(Contraste.razon(texto, base), greaterThanOrEqualTo(4.5), reason: nombre);
      }
      // El borde del resaltado se distingue del fondo (≥ 3:1).
      expect(Contraste.razon(EfectosApp.resaltado, fondo), greaterThanOrEqualTo(3));
    });

    testWidgets('tocar una línea la marca; sin alMarcar es solo lectura', (tester) async {
      final marcadas = <List<int>>[];
      await montar(tester, snippet(alMarcar: marcadas.add));
      await tester.tap(find.byKey(const ValueKey('linea-5')));
      expect(marcadas, [
        [5],
      ]);
      await montar(tester, snippet());
      await tester.tap(find.byKey(const ValueKey('linea-5')));
      expect(marcadas, hasLength(1));
    });

    testWidgets('teclado: flechas y Espacio', (tester) async {
      final marcadas = <List<int>>[];
      await montar(tester, snippet(alMarcar: marcadas.add));
      Focus.of(tester.element(find.byKey(const ValueKey('linea-1')))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp); // no sale de la primera
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(find.byKey(const ValueKey('foco-linea-2')), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(marcadas, [
        [2],
      ]);
    });

    testWidgets('semántica: archivo y cada línea con su estado', (tester) async {
      final semantica = tester.ensureSemantics();
      await montar(tester, snippet(reveladas: {4}, marcadas: {4}, alMarcar: (_) {}));
      expect(find.bySemanticsLabel('Archivo registro_form.dart, 7 líneas'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Línea 1: TextField(label: "Correo"),; no marcada'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          'Línea 4: Checkbox(value: true, // pre-marcado; marcada; línea clave',
        ),
        findsOneWidget,
      );
      final nodo = tester.getSemantics(find.byKey(const ValueKey('linea-1')));
      expect(nodo.flagsCollection.isButton, isTrue);
      semantica.dispose();
    });

    testWidgets('si una línea no cabe, el bloque se desplaza en horizontal', (tester) async {
      await montar(tester, snippet(ancho: 200));
      expect(tester.takeException(), isNull);
      final desplazable = find.byKey(const ValueKey('snippet-desplazable'));
      final antes = tester.getTopLeft(find.text('7')).dx;
      await tester.drag(desplazable, const Offset(-150, 0));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('7')).dx, lessThan(antes));
    });
  });

  group('tarjeta por tipo', () {
    // Etiqueta corta: con la fuente de pruebas (más ancha) la de Figma no deja
    // lugar al chip en la misma línea.
    Widget tarjeta(Tarjeta t, {VoidCallback? alInspeccionar}) => SizedBox(
      width: 342,
      height: 440,
      child: TarjetaCaso(
        etiquetaCaso: 'CASO 6',
        colorModulo: const Color(0xFFB86B23),
        iniciales: 'QA',
        personaje: t.personaje,
        rol: t.rol,
        texto: t.texto,
        tipo: t.tipo,
        alInspeccionar: alInspeccionar,
      ),
    );

    enAmbosModos('evidencia (15): chip accion/secundaria y botón discontinuo de 48', (
      tester,
      brillo,
    ) async {
      var toques = 0;
      await montar(tester, tarjeta(registro, alInspeccionar: () => toques++), brillo: brillo);
      final t = tokensDe(brillo);
      final chip = decoDe(tester, find.byKey(const ValueKey('chip-tipo')));
      expect(chip.color, t.accionSecundaria);
      expect(chip.borderRadius, BorderRadius.circular(999));
      expect(find.text(Textos.tipoEvidencia), findsOneWidget);
      // El chip queda a la derecha del encabezado.
      expect(
        tester.getTopRight(find.byKey(const ValueKey('chip-tipo'))).dx,
        closeTo(tester.getTopRight(find.byKey(const ValueKey('globo-caso'))).dx, 0.5),
      );
      // 48 con una línea; la fuente de pruebas (más ancha) lo parte en dos.
      expect(
        tester.getSize(find.byKey(const ValueKey('boton-evidencia'))).height,
        greaterThanOrEqualTo(48),
      );
      // Entre el globo y el botón hay 18.
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('boton-evidencia'))).dy -
            tester.getBottomLeft(find.byKey(const ValueKey('globo-caso'))).dy,
        18,
      );
      // Con la fuente de pruebas el contenido se desplaza dentro de la tarjeta.
      await tester.ensureVisible(find.byKey(const ValueKey('boton-evidencia')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('boton-evidencia')));
      expect(toques, 1);
      // También con teclado.
      Focus.of(tester.element(find.byKey(const ValueKey('boton-evidencia')))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(toques, 2);
      esperarSoloColoresDelTema(tester, brillo);
    });

    enAmbosModos('dilema (17): chip accion/acento "Dilema ×2" y aviso fondo/destacado', (
      tester,
      brillo,
    ) async {
      await montar(tester, tarjeta(dilema), brillo: brillo);
      final t = tokensDe(brillo);
      expect(decoDe(tester, find.byKey(const ValueKey('chip-tipo'))).color, t.accionAcento);
      expect(find.text(Textos.tipoDilema), findsOneWidget);
      final aviso = decoDe(tester, find.byKey(const ValueKey('aviso-dilema')));
      expect(aviso.color, t.fondoDestacado);
      expect(aviso.borderRadius, BorderRadius.circular(14));
      expect(find.text(Textos.avisoDilema), findsOneWidget);
      expect(find.byKey(const ValueKey('boton-evidencia')), findsNothing);
      esperarSoloColoresDelTema(tester, brillo);
    });

    testWidgets('normal: sin chip, sin botón ni aviso', (tester) async {
      await montar(tester, tarjeta(MockTarjetas.tarjetasPorSprint['spr-1-3']![1]));
      expect(find.byKey(const ValueKey('chip-tipo')), findsNothing);
      expect(find.byKey(const ValueKey('boton-evidencia')), findsNothing);
      expect(find.byKey(const ValueKey('aviso-dilema')), findsNothing);
    });

    test('el alto mínimo cuenta el botón o el aviso', () {
      const escala = TextScaler.noScaling;
      final normal = TarjetaCaso.altoMinimoPara(escala);
      expect(TarjetaCaso.altoMinimoPara(escala, tipo: TipoTarjeta.evidencia), greaterThan(normal));
      expect(
        TarjetaCaso.altoMinimoPara(escala, tipo: TipoTarjeta.justificacion),
        greaterThan(normal),
      );
    });
  });

  group('OpcionJustificacion en modo selección', () {
    enAmbosModos('Seleccionada: borde 2.5 accion/secundaria y círculo relleno', (
      tester,
      brillo,
    ) async {
      final semantica = tester.ensureSemantics();
      var toques = 0;
      await montar(
        tester,
        SizedBox(
          width: 342,
          child: Column(
            children: [
              OpcionJustificacion(
                texto: 'Primera',
                posicion: 1,
                total: 2,
                seleccionada: true,
                alElegir: () => toques++,
              ),
              OpcionJustificacion(
                texto: 'Segunda',
                posicion: 2,
                total: 2,
                seleccionada: false,
                alElegir: () => toques++,
              ),
            ],
          ),
        ),
        brillo: brillo,
      );
      final t = tokensDe(brillo);
      final elegida = decoDe(tester, find.byKey(const ValueKey('opcion-1')));
      expect((elegida.border! as Border).top.color, t.accionSecundaria);
      expect((elegida.border! as Border).top.width, 2.5);
      final otra = decoDe(tester, find.byKey(const ValueKey('opcion-2')));
      expect((otra.border! as Border).top.color, t.bordeDefault);
      expect((otra.border! as Border).top.width, 1.5);
      expect(find.byKey(const ValueKey('punto-opcion')), findsOneWidget);
      expect(find.bySemanticsLabel('Opción 1 de 2: Primera; seleccionada'), findsOneWidget);
      expect(find.bySemanticsLabel('Opción 2 de 2: Segunda; no seleccionada'), findsOneWidget);
      expect(
        tester.getSemantics(find.byKey(const ValueKey('opcion-1'))).flagsCollection.isChecked,
        CheckedState.isTrue,
      );
      await tester.tap(find.text('Segunda'));
      expect(toques, 1);
      esperarSoloColoresDelTema(tester, brillo);
      semantica.dispose();
    });

    testWidgets('sin seleccionada (micro-pregunta) sigue leyéndose como antes', (tester) async {
      final semantica = tester.ensureSemantics();
      await montar(
        tester,
        OpcionJustificacion(texto: 'Única', posicion: 1, total: 1, alElegir: () {}),
      );
      expect(find.bySemanticsLabel('Opción 1 de 1: Única'), findsOneWidget);
      expect(find.byKey(const ValueKey('punto-opcion')), findsNothing);
      semantica.dispose();
    });
  });

  group('paneles', () {
    Widget visor({List<int>? marcadas}) => PanelEvidencia(
      archivo: evidencia.archivo,
      lineas: evidencia.lineas,
      lineasClave: evidencia.lineasClave,
      mensajeAcierto: evidencia.mensajeAcierto,
      mensajeFallo: evidencia.mensajeFallo,
      marcadas: marcadas,
      alMarcar: (_) {},
      alVolver: () {},
    );

    enAmbosModos('visor 16: título, instrucción y botón deshabilitado', (tester, brillo) async {
      await montar(tester, visor(), brillo: brillo);
      expect(find.text(Textos.inspeccionaTitulo), findsOneWidget);
      expect(find.text(Textos.inspeccionaInstruccion), findsOneWidget);
      final b = tester.widget<BotonApp>(find.byType(BotonApp));
      expect((b.texto, b.alPresionar), (Textos.marcaUnaLinea, null));
      expect(find.byType(ChipBonusEvidencia), findsNothing);
      esperarSoloColoresDelTema(tester, brillo);
    });

    enAmbosModos('visor 16b: "Línea marcada", chip fondo/destacado y "Volver y decidir"', (
      tester,
      brillo,
    ) async {
      await montar(tester, visor(marcadas: [4, 5, 6]), brillo: brillo);
      expect(find.text(Textos.lineaMarcadaTitulo), findsOneWidget);
      expect(find.text(evidencia.mensajeAcierto), findsOneWidget);
      final chip = decoDe(tester, find.byKey(const ValueKey('chip-bonus-evidencia')));
      expect(chip.color, tokensDe(brillo).fondoDestacado);
      final b = tester.widget<BotonApp>(find.byType(BotonApp));
      expect((b.texto, b.tipo), (Textos.volverYDecidir, TipoBoton.primario));
      expect(b.alPresionar, isNotNull);
      esperarSoloColoresDelTema(tester, brillo);
    });

    testWidgets('visor con línea equivocada: título y texto propios, sin chip', (tester) async {
      await montar(tester, visor(marcadas: [7]));
      expect(find.text(Textos.lineaEquivocadaTitulo), findsOneWidget);
      expect(find.text(evidencia.mensajeFallo), findsOneWidget);
      expect(find.byType(ChipBonusEvidencia), findsNothing);
    });

    enAmbosModos('justificación 18: chip del veredicto, título H1 centrado y 3 opciones', (
      tester,
      brillo,
    ) async {
      int? confirmada;
      await montar(
        tester,
        PanelJustificacion(
          veredicto: Veredicto.ilegal,
          justificacion: dilema.justificacion!,
          alConfirmar: (i) => confirmada = i,
        ),
        brillo: brillo,
      );
      final t = tokensDe(brillo);
      expect(decoDe(tester, find.byKey(const ValueKey('chip-veredicto'))).color, t.estadoIlegal);
      expect(find.text('Dictaste: ILEGAL'), findsOneWidget);
      final titulo = tester.widget<Text>(find.text(Textos.porQueIlegal));
      expect(titulo.textAlign, TextAlign.center);
      expect(titulo.style!.fontSize, 26);
      expect(find.byType(OpcionJustificacion), findsNWidgets(3));
      expect(tester.widget<BotonApp>(find.byType(BotonApp)).alPresionar, isNull);
      await tester.tap(find.byType(OpcionJustificacion).at(1));
      await tester.pump();
      expect(confirmada, isNull, reason: 'elegir no confirma');
      await tester.tap(find.byType(BotonApp));
      expect(confirmada, 1);
      esperarSoloColoresDelTema(tester, brillo);
    });

    for (final escala in [1.0, 2.0]) {
      for (final brillo in Brightness.values) {
        testWidgets('sin desbordes al ${(escala * 100).toInt()} % (${brillo.name})', (
          tester,
        ) async {
          await tester.binding.setSurfaceSize(const Size(320, 640));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          for (final panel in [
            visor(),
            visor(marcadas: [4]),
            visor(marcadas: [1]),
            PanelJustificacion(
              veredicto: Veredicto.condicional,
              justificacion: dilema.justificacion!,
              alConfirmar: (_) {},
            ),
          ]) {
            await montar(tester, panel, brillo: brillo, escalaTexto: escala);
            expect(tester.takeException(), isNull);
          }
        });
      }
    }
  });
}
