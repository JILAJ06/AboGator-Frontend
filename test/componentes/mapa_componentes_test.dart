import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/camino_sprints.dart';
import 'package:abogator/componentes/encabezado_modulo.dart';
import 'package:abogator/componentes/estrellas_sprint.dart';
import 'package:abogator/componentes/fila_detalle_sprint.dart';
import 'package:abogator/componentes/globo_sprint_actual.dart';
import 'package:abogator/componentes/nodo_sprint.dart';
import 'package:abogator/core/tema/colores_marca.dart';
import 'package:abogator/core/tema/efectos.dart';
import 'package:abogator/core/tema/iconos_app.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

BoxDecoration decoDe(WidgetTester tester, Finder finder) {
  final w = tester.widget(finder);
  return switch (w) {
    Container(:final decoration?) => decoration as BoxDecoration,
    Container(:final color) => BoxDecoration(color: color),
    DecoratedBox(:final decoration) => decoration as BoxDecoration,
    _ => throw StateError('sin decoración'),
  };
}

const anillo = ValueKey('anillo-foco');

EncabezadoModulo encabezado({
  Color color = ColoresModulo.proteccionDeDatos,
  VoidCallback? alAtras,
  String nombreCorto = 'Protección de datos',
  String titulo = 'Del Garage al MVP',
}) => EncabezadoModulo(
  numero: 1,
  nombreCorto: nombreCorto,
  titulo: titulo,
  color: color,
  vidas: 4,
  completados: 2,
  total: 5,
  alAtras: alAtras ?? () {},
);

void main() {
  group('EncabezadoModulo', () {
    enAmbosModos('color del módulo, textos blancos, chip de vidas y barra 2/5', (
      tester,
      brillo,
    ) async {
      final semantica = tester.ensureSemantics();
      // Textos cortos: con la fuente de pruebas (glifos cuadrados) los largos
      // ocupan dos líneas y el encabezado crece.
      await montar(
        tester,
        SizedBox(
          width: 390,
          child: encabezado(nombreCorto: 'Datos', titulo: 'El MVP'),
        ),
        brillo: brillo,
      );
      final caja = find.byKey(const ValueKey('encabezado-modulo'));
      expect(decoDe(tester, caja).color, ColoresModulo.proteccionDeDatos);
      // 150 como en Figma: 48 de barra de estado + 102 de contenido.
      expect(
        tester.getSize(caja).height,
        EncabezadoModulo.altoBarraEstado + EncabezadoModulo.altoContenido,
      );
      expect(find.text('MÓDULO 1 · DATOS'), findsOneWidget);
      final titulo = tester.widget<Text>(find.text('El MVP'));
      expect(titulo.style!.color, EfectosApp.textoEncabezado);
      expect(titulo.style!.fontSize, 20);
      expect(find.text('2/5'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      // Barra: 2 de 5.
      final pista = tester.getSize(find.byKey(const ValueKey('barra-encabezado')));
      final relleno = tester.getSize(find.byKey(const ValueKey('relleno-encabezado')));
      expect(pista.height, 8);
      expect(relleno.width, closeTo(pista.width * 2 / 5, 0.01));
      expect(
        decoDe(tester, find.byKey(const ValueKey('relleno-encabezado'))).color,
        EfectosApp.rellenoEncabezado,
      );
      expect(
        decoDe(tester, find.byKey(const ValueKey('atras-encabezado'))).color,
        EfectosApp.fondoAtrasEncabezado,
      );
      expect(tester.getSize(find.byKey(const ValueKey('atras-encabezado'))), const Size.square(48));
      // Semántica.
      expect(
        tester.getSemantics(find.bySemanticsLabel(RegExp('^MÓDULO 1'))),
        isSemantics(isHeader: true),
      );
      expect(find.bySemanticsLabel('Vidas: 4 de 5'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Avance del módulo: 2 de 5 sprints completados'),
        findsOneWidget,
      );
      semantica.dispose();
    });

    testWidgets('el botón atrás se anuncia, responde y tiene foco con teclado', (tester) async {
      final semantica = tester.ensureSemantics();
      var toques = 0;
      await montar(tester, SizedBox(width: 390, child: encabezado(alAtras: () => toques++)));
      expect(
        tester.getSemantics(find.bySemanticsLabel('Atrás')),
        isSemantics(isButton: true, hasTapAction: true),
      );
      await tester.tap(find.byKey(const ValueKey('atras-encabezado')));
      expect(toques, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(find.byKey(anillo), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(toques, 2);
      semantica.dispose();
    });

    test('texto blanco y etiqueta ≥ 4.5:1 sobre el fondo de los 5 módulos', () {
      for (final color in ColoresModulo.enOrden) {
        final fondo = EfectosApp.fondoEncabezado(color);
        expect(
          Contraste.razon(EfectosApp.textoEncabezado, fondo),
          greaterThanOrEqualTo(4.5),
          reason: color.toString(),
        );
        expect(
          Contraste.razon(EfectosApp.etiquetaEncabezado(fondo), fondo),
          greaterThanOrEqualTo(4.5),
          reason: color.toString(),
        );
      }
    });

    test('solo se oscurece el fondo de los módulos que no alcanzan el contraste', () {
      expect(
        EfectosApp.fondoEncabezado(ColoresModulo.proteccionDeDatos),
        ColoresModulo.proteccionDeDatos,
      );
      expect(
        EfectosApp.fondoEncabezado(ColoresModulo.delitosInformaticos),
        ColoresModulo.delitosInformaticos,
      );
      expect(
        EfectosApp.fondoEncabezado(ColoresModulo.contratosDigitales),
        ColoresModulo.contratosDigitales,
      );
      for (final color in [
        ColoresModulo.licenciasYPropiedadIntelectual,
        ColoresModulo.auditoriaYCumplimiento,
      ]) {
        final fondo = EfectosApp.fondoEncabezado(color);
        expect(fondo, isNot(color));
        expect(Contraste.luminancia(fondo), lessThan(Contraste.luminancia(color)));
      }
    });

    testWidgets('con texto al 200 % y 320 de ancho no se desborda', (tester) async {
      await montar(tester, SizedBox(width: 320, child: encabezado()), escalaTexto: 2);
      expect(tester.takeException(), isNull);
    });
  });

  group('NodoSprint', () {
    for (final (tipo, ancho, alto, cara) in [
      (TipoNodoSprint.completado, 96.0, 106.0, 72.0),
      (TipoNodoSprint.actual, 104.0, 114.0, 80.0),
      (TipoNodoSprint.bloqueado, 96.0, 106.0, 72.0),
      (TipoNodoSprint.jefe, 116.0, 126.0, 92.0),
    ]) {
      enAmbosModos('${tipo.name}: caja ${ancho.toInt()}×${alto.toInt()} y cara ${cara.toInt()}', (
        tester,
        brillo,
      ) async {
        await montar(
          tester,
          NodoSprint(tipo: tipo, estrellas: 3, etiquetaSemantica: 'n', alPresionar: () {}),
          brillo: brillo,
        );
        final t = tokensDe(brillo);
        expect(tester.getSize(find.byKey(ValueKey('nodo-${tipo.name}'))), Size(ancho, alto));
        final caraFinder = find.byKey(const ValueKey('cara-nodo'));
        expect(tester.getSize(caraFinder), Size.square(cara));
        expect(decoDe(tester, caraFinder).color, NodoSprint.colorCara(tipo, t));
        // La base va 8 más abajo que la cara, con el mismo tamaño.
        final base = find.byKey(const ValueKey('base-nodo'));
        expect(tester.getTopLeft(base) - tester.getTopLeft(caraFinder), const Offset(0, 8));
        expect(decoDe(tester, base).color, EfectosApp.baseNodo(NodoSprint.colorCara(tipo, t)));
        expect(
          find.byKey(const ValueKey('pulso-nodo')),
          tipo == TipoNodoSprint.actual ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(EstrellasNodo),
          tipo == TipoNodoSprint.completado ? findsOneWidget : findsNothing,
        );
        final icono = tester.widget<Icon>(find.byType(Icon));
        expect(icono.size, tipo.icono);
        expect(icono.icon, switch (tipo) {
          TipoNodoSprint.completado => IconosApp.check,
          TipoNodoSprint.actual => IconosApp.gavel,
          TipoNodoSprint.bloqueado => IconosApp.lock,
          TipoNodoSprint.jefe => IconosApp.trophy,
        });
        // El centro de la cara coincide con `centroCara`.
        final origen = tester.getTopLeft(find.byKey(ValueKey('nodo-${tipo.name}')));
        expect(tester.getCenter(caraFinder) - origen, tipo.centroCara);
        esperarSoloColoresDelTema(tester, brillo);
      });
    }

    test('las bases del modo claro son las de Figma', () {
      expect(EfectosApp.baseNodo(const Color(0xFF1F4E35)), const Color(0xFF123222));
      expect(EfectosApp.baseNodo(const Color(0xFF9A5A1C)), const Color(0xFF7A4615));
      expect(EfectosApp.baseNodo(const Color(0xFFF1F5F9)), const Color(0xFFCBD5E1));
      expect(EfectosApp.baseNodo(const Color(0xFF0F294A)), const Color(0xFF07172B));
    });

    enAmbosModos('estrellas ganadas en accion/acento y las demás en borde/default', (
      tester,
      brillo,
    ) async {
      await montar(tester, const EstrellasNodo(estrellas: 2), brillo: brillo);
      final t = tokensDe(brillo);
      Color colorDe(int i) =>
          (tester.widget<CustomPaint>(find.byKey(ValueKey('estrella-$i'))).painter!
                  as PintorEstrella)
              .color;
      expect(
        [colorDe(0), colorDe(1), colorDe(2)],
        [t.accionAcento, t.accionAcento, t.bordeDefault],
      );
      expect(tester.getSize(find.byType(EstrellasNodo)), const Size(52, 16));
    });

    testWidgets('con acción: botón con la etiqueta, foco con teclado y Enter', (tester) async {
      final semantica = tester.ensureSemantics();
      var toques = 0;
      await montar(
        tester,
        NodoSprint(
          tipo: TipoNodoSprint.completado,
          estrellas: 3,
          etiquetaSemantica: 'Sprint 1, Datos personales, completado, 3 de 3 estrellas',
          alPresionar: () => toques++,
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel(RegExp('^Sprint 1'))),
        isSemantics(isButton: true, hasTapAction: true, hasEnabledState: true, isEnabled: true),
      );
      await tester.tap(find.byType(NodoSprint));
      expect(toques, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(find.byKey(anillo), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(toques, 2);
      semantica.dispose();
    });

    testWidgets('bloqueado: no responde, no recibe foco y se anuncia deshabilitado', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await montar(
        tester,
        const NodoSprint(
          tipo: TipoNodoSprint.bloqueado,
          etiquetaSemantica: 'Sprint 4, Derechos ARCO, bloqueado',
          alPresionar: null,
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel(RegExp('^Sprint 4'))),
        isSemantics(isButton: true, hasEnabledState: true, isEnabled: false, hasTapAction: false),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(find.byKey(anillo), findsNothing);
      semantica.dispose();
    });
  });

  group('CaminoSprints', () {
    enAmbosModos('pinta en borde/default y no se lee', (tester, brillo) async {
      final semantica = tester.ensureSemantics();
      const puntos = [Offset(50, 0), Offset(10, 100), Offset(50, 200)];
      await montar(
        tester,
        const SizedBox(width: 100, height: 200, child: CaminoSprints(puntos: puntos)),
        brillo: brillo,
      );
      final pintor =
          tester
                  .widget<CustomPaint>(
                    find.descendant(
                      of: find.byType(CaminoSprints),
                      matching: find.byType(CustomPaint),
                    ),
                  )
                  .painter!
              as PintorCamino;
      expect(pintor.color, tokensDe(brillo).bordeDefault);
      expect(pintor.puntos, puntos);
      expect(tester.getSemantics(find.byType(CaminoSprints)).label, isEmpty);
      semantica.dispose();
    });

    test('vuelve a pintar solo si cambian los puntos o el color', () {
      const a = PintorCamino(puntos: [Offset.zero, Offset(1, 1)], color: Color(0xFFE2E8F0));
      expect(
        a.shouldRepaint(
          const PintorCamino(puntos: [Offset.zero, Offset(1, 1)], color: Color(0xFFE2E8F0)),
        ),
        isFalse,
      );
      expect(
        a.shouldRepaint(
          const PintorCamino(puntos: [Offset.zero, Offset(2, 1)], color: Color(0xFFE2E8F0)),
        ),
        isTrue,
      );
    });
  });

  group('GloboSprintActual', () {
    enAmbosModos('fondo/superficie, radio 16, título, detalle y "Comenzar" 170×48', (
      tester,
      brillo,
    ) async {
      final semantica = tester.ensureSemantics();
      var toques = 0;
      await montar(
        tester,
        GloboSprintActual(
          titulo: 'Sprint 3 · Aviso de privacidad',
          detalle: '10 tarjetas · ≈ 4 min',
          alComenzar: () => toques++,
        ),
        brillo: brillo,
      );
      final t = tokensDe(brillo);
      final deco = decoDe(tester, find.byKey(const ValueKey('globo-sprint')));
      expect(deco.color, t.fondoSuperficie);
      expect(deco.borderRadius, BorderRadius.circular(16));
      expect(deco.boxShadow, EfectosApp.sombraGlobo);
      expect(tester.widget<Text>(find.text('Sprint 3 · Aviso de privacidad')).style!.fontSize, 14);
      expect(
        tester.widget<Text>(find.text('10 tarjetas · ≈ 4 min')).style!.color,
        t.textoSecundario,
      );
      final boton = tester.getSize(find.byType(BotonApp));
      expect(boton.width, greaterThanOrEqualTo(170));
      expect(boton.height, 48);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Comenzar')),
        isSemantics(isButton: true, hasTapAction: true),
      );
      await tester.tap(find.text('Comenzar'));
      expect(toques, 1);
      esperarSoloColoresDelTema(tester, brillo);
      semantica.dispose();
    });
  });

  group('FilaDetalleSprint', () {
    enAmbosModos('ícono 22 en accion/primaria, título y texto; tarjeta radio 18', (
      tester,
      brillo,
    ) async {
      final semantica = tester.ensureSemantics();
      await montar(
        tester,
        const SizedBox(
          width: 342,
          child: TarjetaDetallesSprint(
            filas: [
              FilaDetalleSprint(
                icono: IconosApp.doc,
                titulo: '10 tarjetas',
                texto: '6 normales · 3 con evidencia · 1 dilema',
              ),
            ],
          ),
        ),
        brillo: brillo,
      );
      final t = tokensDe(brillo);
      final icono = tester.widget<Icon>(find.byType(Icon));
      expect(icono.size, 22);
      expect(icono.color, t.accionPrimaria);
      // Con la fuente de pruebas el desglose ocupa dos líneas de Leyenda (14 c/u).
      expect(tester.getSize(find.byType(FilaDetalleSprint)).height, 12 + 20 + 2 + 14 * 2 + 12);
      final deco = decoDe(tester, find.byKey(const ValueKey('tarjeta-detalles')));
      expect(deco.borderRadius, BorderRadius.circular(18));
      expect(deco.color, t.fondoSuperficie);
      // Se lee como un bloque.
      final nodo = tester.getSemantics(find.byType(FilaDetalleSprint));
      expect(nodo.label, contains('10 tarjetas'));
      expect(nodo.label, contains('1 dilema'));
      esperarSoloColoresDelTema(tester, brillo);
      semantica.dispose();
    });
  });
}
