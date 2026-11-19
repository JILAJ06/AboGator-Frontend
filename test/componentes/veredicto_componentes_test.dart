import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/impacto_startup.dart';
import 'package:abogator/componentes/indicadores_startup.dart';
import 'package:abogator/componentes/opcion_justificacion.dart';
import 'package:abogator/componentes/panel_veredicto.dart';
import 'package:abogator/componentes/sarko_imagen.dart';
import 'package:abogator/core/tema/efectos.dart';
import 'package:abogator/core/tema/iconos_app.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:abogator/datos/modelos/estado_startup.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

const pregunta = MicroPregunta(
  enunciado: '¿por qué es ilegal?',
  opciones: ['La GPL-3.0 obliga a liberar el código derivado', 'Porque es privado'],
  indiceCorrecto: 0,
);

const explicacion = 'Usar código GPL-3.0 en software propietario infringe la licencia.';

/// Los datos de cada variante, como en Figma.
final variantes = <TipoPanelVeredicto, (String, Map<IndicadorStartup, int>)>{
  TipoPanelVeredicto.correcto: (
    Textos.correctoSubtitulo(10, 5),
    {IndicadorStartup.reputacion: 5, IndicadorStartup.riesgoLegal: -10},
  ),
  TipoPanelVeredicto.bonus: (
    Textos.bonusSubtitulo(15, 5),
    {IndicadorStartup.reputacion: 5, IndicadorStartup.riesgoLegal: -10},
  ),
  TipoPanelVeredicto.parcial: (
    Textos.parcialSubtitulo(3),
    {IndicadorStartup.presupuesto: -5, IndicadorStartup.velocidad: -10},
  ),
  TipoPanelVeredicto.incorrecto: (
    Textos.incorrectoSubtitulo,
    {IndicadorStartup.velocidad: 10, IndicadorStartup.riesgoLegal: 25},
  ),
  TipoPanelVeredicto.amparo: (
    Textos.amparoSubtitulo,
    {IndicadorStartup.velocidad: 10, IndicadorStartup.riesgoLegal: 20},
  ),
};

Widget panel(
  TipoPanelVeredicto tipo, {
  bool conPregunta = false,
  VoidCallback? alContinuar,
  ValueChanged<int>? alElegir,
}) {
  final (subtitulo, cambios) = variantes[tipo]!;
  return SizedBox(
    width: 390,
    child: PanelVeredicto(
      tipo: tipo,
      subtitulo: subtitulo,
      cambios: cambios,
      explicacion: explicacion,
      microPregunta: conPregunta ? pregunta : null,
      alElegirOpcion: alElegir ?? (_) {},
      alContinuar: alContinuar ?? () {},
    ),
  );
}

BoxDecoration decoDe(WidgetTester tester, Finder finder) {
  final w = tester.widget(finder);
  return switch (w) {
    Container(:final decoration?) => decoration as BoxDecoration,
    DecoratedBox(:final decoration) => decoration as BoxDecoration,
    _ => throw StateError('sin decoración'),
  };
}

void main() {
  group('PanelVeredicto', () {
    for (final (tipo, titulo, icono, pose, boton, tipoBoton) in [
      (
        TipoPanelVeredicto.correcto,
        '¡Veredicto correcto!',
        IconosApp.check,
        PoseSarko.alegre,
        'Continuar',
        TipoBoton.primario,
      ),
      (
        TipoPanelVeredicto.bonus,
        '¡Bonus ganado!',
        IconosApp.star,
        PoseSarko.alegre,
        'Continuar',
        TipoBoton.primario,
      ),
      (
        TipoPanelVeredicto.parcial,
        'Respuesta parcial',
        IconosApp.arrowDown,
        PoseSarko.sorprendido,
        'Continuar',
        TipoBoton.primario,
      ),
      (
        TipoPanelVeredicto.incorrecto,
        'Veredicto incorrecto',
        IconosApp.x,
        PoseSarko.triste,
        'Entendido',
        TipoBoton.peligro,
      ),
      (
        TipoPanelVeredicto.amparo,
        '¡El Amparo te protegió!',
        IconosApp.shieldCheck,
        PoseSarko.sorprendido,
        'Entendido',
        TipoBoton.secundario,
      ),
    ]) {
      enAmbosModos('${tipo.name}: insignia, título, subtítulo, Sarko, explicación y botón', (
        tester,
        brillo,
      ) async {
        var toques = 0;
        await montar(tester, panel(tipo, alContinuar: () => toques++), brillo: brillo);
        final t = tokensDe(brillo);
        final color = PanelVeredicto.color(tipo, t);
        // Contenedor: fondo/superficie, esquinas superiores de 28 y sombra elevada.
        final caja = decoDe(tester, find.byKey(const ValueKey('panel-veredicto')));
        expect(caja.color, t.fondoSuperficie);
        expect(caja.borderRadius, const BorderRadius.vertical(top: Radius.circular(28)));
        expect(caja.boxShadow, EfectosApp.sombraGlobo);
        expect(tester.getSize(find.byKey(const ValueKey('agarre'))), const Size(40, 5));
        // Insignia de 30 con ícono de 18 en texto/en-primario.
        expect(tester.getSize(find.byKey(const ValueKey('insignia'))), const Size.square(30));
        expect(decoDe(tester, find.byKey(const ValueKey('insignia'))).color, color);
        final iconoInsignia = tester.widget<Icon>(
          find.descendant(of: find.byKey(const ValueKey('insignia')), matching: find.byType(Icon)),
        );
        expect(iconoInsignia.icon, icono);
        expect(iconoInsignia.size, 18);
        expect(iconoInsignia.color, t.textoEnPrimario);
        final estiloTitulo = tester.widget<Text>(find.text(titulo)).style!;
        expect(estiloTitulo.color, color);
        expect(estiloTitulo.fontSize, 20);
        expect(tester.widget<Text>(find.text(variantes[tipo]!.$1)).style!.color, color);
        final sarko = tester.widget<SarkoImagen>(find.byType(SarkoImagen));
        expect(sarko.pose, pose);
        expect(tester.getSize(find.byType(SarkoImagen)).height, closeTo(96, 0.01));
        expect(find.byType(ImpactoStartup), findsOneWidget);
        expect(find.text(Textos.porQue), findsOneWidget);
        expect(find.text(explicacion), findsOneWidget);
        expect(
          decoDe(tester, find.byKey(const ValueKey('caja-explicacion'))).color,
          t.fondoSuperficieAlt,
        );
        final b = tester.widget<BotonApp>(find.byType(BotonApp));
        expect((b.texto, b.tipo), (boton, tipoBoton));
        await tester.tap(find.byType(BotonApp));
        expect(toques, 1);
        esperarSoloColoresDelTema(tester, brillo);
      });
    }

    enAmbosModos('correcto con micro-pregunta: caja destacada, opciones y "Saltar bonus"', (
      tester,
      brillo,
    ) async {
      final elegidas = <int>[];
      var saltos = 0;
      await montar(
        tester,
        panel(
          TipoPanelVeredicto.correcto,
          conPregunta: true,
          alElegir: elegidas.add,
          alContinuar: () => saltos++,
        ),
        brillo: brillo,
      );
      final t = tokensDe(brillo);
      expect(find.text(Textos.porQue), findsNothing);
      expect(
        decoDe(tester, find.byKey(const ValueKey('caja-micro-pregunta'))).color,
        t.fondoDestacado,
      );
      expect(find.text('Bonus +5 XP: ¿por qué es ilegal?'), findsOneWidget);
      expect(find.byType(OpcionJustificacion), findsNWidgets(2));
      final b = tester.widget<BotonApp>(find.byType(BotonApp));
      expect((b.texto, b.tipo), (Textos.saltarBonus, TipoBoton.fantasma));
      await tester.tap(find.byType(OpcionJustificacion).last);
      expect(elegidas, [1]);
      await tester.tap(find.byType(BotonApp));
      expect(saltos, 1);
      esperarSoloColoresDelTema(tester, brillo);
    });

    testWidgets('separación 14, y 16 en la variante Incorrecto', (tester) async {
      // Entre la fila de impacto y la caja de explicación.
      double hueco(WidgetTester tester) =>
          tester.getTopLeft(find.byKey(const ValueKey('caja-explicacion'))).dy -
          tester.getBottomLeft(find.byType(ImpactoStartup)).dy;
      await montar(tester, panel(TipoPanelVeredicto.parcial));
      expect(hueco(tester), 14);
      await montar(tester, panel(TipoPanelVeredicto.incorrecto));
      expect(hueco(tester), 16);
    });

    testWidgets('lector: el título se anuncia con subtítulo e impacto y recibe el foco', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await montar(tester, panel(TipoPanelVeredicto.incorrecto));
      final anuncio = tester.getSemantics(
        find.bySemanticsLabel(RegExp(r'^Veredicto incorrecto\.')),
      );
      expect(anuncio.label, contains('−1 vida · Se guarda en tu Buzón de Apelaciones'));
      expect(anuncio.label, contains('Impacto: Velocidad +10, Riesgo legal +25'));
      final datos = anuncio.getSemanticsData();
      expect(datos.flagsCollection.isHeader, isTrue);
      expect(datos.flagsCollection.isLiveRegion, isTrue);
      // El título tiene el foco al abrir.
      final enFoco = FocusManager.instance.primaryFocus!.context!;
      expect(enFoco.findAncestorWidgetOfExactType<PanelVeredicto>(), isNotNull);
      expect(
        tester
            .getRect(find.byKey(const ValueKey('titulo-panel')))
            .contains(tester.getCenter(find.byElementPredicate((e) => e == enFoco))),
        isTrue,
      );
      // Sarko y el agarre no se leen.
      expect(find.bySemanticsLabel(Textos.sarkoTriste), findsNothing);
      semantica.dispose();
    });

    testWidgets('orden de foco: título → impacto → explicación → botón', (tester) async {
      await montar(tester, panel(TipoPanelVeredicto.parcial));
      final orden = <String>[];
      for (var i = 0; i < 3; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final contexto = FocusManager.instance.primaryFocus!.context!;
        bool dentro(Key clave) => tester
            .getRect(find.byKey(clave))
            .contains(tester.getCenter(find.byElementPredicate((e) => e == contexto)));
        orden.add(
          dentro(const ValueKey('impacto-panel'))
              ? 'impacto'
              : dentro(const ValueKey('explicacion-panel'))
              ? 'explicacion'
              : contexto.findAncestorWidgetOfExactType<BotonApp>() != null
              ? 'boton'
              : 'otro',
        );
      }
      expect(orden, ['impacto', 'explicacion', 'boton']);
    });

    test('contraste ≥ 4.5:1 de títulos y chips de impacto en ambos modos', () {
      for (final t in [TokensColor.claro, TokensColor.oscuro]) {
        for (final tipo in TipoPanelVeredicto.values) {
          final color = PanelVeredicto.color(tipo, t);
          expect(Contraste.razon(color, t.fondoSuperficie), greaterThanOrEqualTo(4.5));
          expect(Contraste.razon(t.textoEnPrimario, color), greaterThanOrEqualTo(4.5));
        }
        for (final indicador in IndicadorStartup.values) {
          final texto = indicador.colorTexto(t);
          final fondo = Color.alphaBlend(
            texto.withValues(alpha: EfectosApp.opacidadChipImpacto),
            t.fondoSuperficie,
          );
          expect(
            Contraste.razon(texto, fondo),
            greaterThanOrEqualTo(4.5),
            reason: '${indicador.name} ${t == TokensColor.claro ? 'claro' : 'oscuro'}',
          );
        }
      }
    });

    for (final (ancho, escala) in [(390.0, 2.0), (360.0, 2.0), (320.0, 1.0), (320.0, 2.0)]) {
      testWidgets('sin desbordes a $ancho de ancho con texto ${escala}x', (tester) async {
        await tester.binding.setSurfaceSize(Size(ancho + 48, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        for (final tipo in TipoPanelVeredicto.values) {
          await montar(
            tester,
            SizedBox(
              height: 800,
              child: panel(tipo, conPregunta: tipo == TipoPanelVeredicto.correcto),
            ),
            escalaTexto: escala,
          );
          expect(tester.takeException(), isNull, reason: tipo.name);
        }
      });
    }
  });

  group('IndicadoresStartup con cambios', () {
    enAmbosModos('muestra el cambio con signo junto a las barras que se movieron', (
      tester,
      brillo,
    ) async {
      final semantica = tester.ensureSemantics();
      await montar(
        tester,
        const SizedBox(
          width: 342,
          child: IndicadoresStartup(
            estado: EstadoStartup(presupuesto: 70, reputacion: 60, velocidad: 60, riesgoLegal: 50),
            cambios: {IndicadorStartup.velocidad: 10, IndicadorStartup.riesgoLegal: 25},
          ),
        ),
        brillo: brillo,
      );
      final t = tokensDe(brillo);
      expect(find.text('+10'), findsOneWidget);
      expect(find.text('+25'), findsOneWidget);
      expect(find.byKey(const ValueKey('cambio-presupuesto')), findsNothing);
      expect(tester.widget<Text>(find.text('+25')).style!.color, t.estadoIlegal);
      expect(find.bySemanticsLabel('Riesgo legal 50 %, +25'), findsOneWidget);
      semantica.dispose();
    });

    testWidgets('la barra se anima al nuevo valor; con reducir animaciones salta', (tester) async {
      Widget barras(int riesgo) => SizedBox(
        width: 342,
        child: IndicadoresStartup(
          estado: EstadoStartup(
            presupuesto: 70,
            reputacion: 60,
            velocidad: 50,
            riesgoLegal: riesgo,
          ),
        ),
      );
      double ancho() => tester.getSize(find.byKey(const ValueKey('relleno-riesgoLegal'))).width;
      for (final reducir in [false, true]) {
        final riesgo = ValueNotifier(25);
        await montar(
          tester,
          ValueListenableBuilder<int>(
            valueListenable: riesgo,
            builder: (context, valor, _) => barras(valor),
          ),
          reducirAnimaciones: reducir,
        );
        expect(ancho(), closeTo(17, 0.01));
        riesgo.value = 50;
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        if (reducir) {
          expect(ancho(), closeTo(34, 0.01));
        } else {
          expect(ancho(), inExclusiveRange(17, 34));
        }
        await tester.pumpAndSettle();
        expect(ancho(), closeTo(34, 0.01));
        // Sale del árbol para que el siguiente montaje empiece de cero.
        await tester.pumpWidget(const SizedBox());
      }
    });
  });

  group('OpcionJustificacion', () {
    enAmbosModos('fondo/superficie, borde 1.5, radio 16 y círculo de 24 con borde 2', (
      tester,
      brillo,
    ) async {
      final semantica = tester.ensureSemantics();
      var toques = 0;
      await montar(
        tester,
        SizedBox(
          width: 310,
          child: OpcionJustificacion(
            texto: 'La GPL-3.0 obliga a liberar el código derivado',
            posicion: 1,
            total: 2,
            alElegir: () => toques++,
          ),
        ),
        brillo: brillo,
      );
      final t = tokensDe(brillo);
      final deco = decoDe(tester, find.byKey(const ValueKey('opcion-1')));
      expect(deco.color, t.fondoSuperficie);
      expect(deco.borderRadius, BorderRadius.circular(16));
      expect((deco.border! as Border).top.width, 1.5);
      expect((deco.border! as Border).top.color, t.bordeDefault);
      final circulo = decoDe(tester, find.byKey(const ValueKey('circulo-opcion')));
      expect((circulo.border! as Border).top.width, 2);
      expect((circulo.border! as Border).top.color, t.bordeControl);
      expect(tester.getSize(find.byKey(const ValueKey('circulo-opcion'))), const Size.square(24));
      final nodo = tester.getSemantics(
        find.bySemanticsLabel('Opción 1 de 2: La GPL-3.0 obliga a liberar el código derivado'),
      );
      expect(nodo.getSemanticsData().flagsCollection.isInMutuallyExclusiveGroup, isTrue);
      expect(nodo.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      await tester.tap(find.byType(OpcionJustificacion));
      expect(toques, 1);
      esperarSoloColoresDelTema(tester, brillo);
      semantica.dispose();
    });
  });
}
