import 'package:abogator/componentes/avatar_app.dart';
import 'package:abogator/componentes/boton_buzon.dart';
import 'package:abogator/componentes/sarko_imagen.dart';
import 'package:abogator/componentes/tarjeta_heroe_startup.dart';
import 'package:abogator/componentes/tarjeta_modulo.dart';
import 'package:abogator/componentes/tarjeta_reto_diario.dart';
import 'package:abogator/core/tema/colores_marca.dart';
import 'package:abogator/core/tema/iconos_app.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

BoxDecoration decoDe(WidgetTester tester, Key clave) {
  final w = tester.widget(find.byKey(clave));
  return switch (w) {
    Container(:final decoration) => decoration! as BoxDecoration,
    DecoratedBox(:final decoration) => decoration as BoxDecoration,
    _ => throw StateError('sin decoración'),
  };
}

const anillo = ValueKey('anillo-foco');

TarjetaModulo tarjeta(EstadoModulo estado, {VoidCallback? alPresionar}) => TarjetaModulo(
  numero: 1,
  nombreCorto: 'Protección de datos',
  titulo: 'Del Garage al MVP',
  estado: estado,
  completados: switch (estado) {
    EstadoModulo.completado => 5,
    EstadoModulo.enCurso => 2,
    _ => 0,
  },
  total: 5,
  color: ColoresModulo.proteccionDeDatos,
  icono: IconosApp.shield,
  alPresionar: alPresionar ?? () {},
);

void main() {
  group('AvatarApp', () {
    enAmbosModos('círculo de 44 en fondo/destacado y decorativo', (tester, brillo) async {
      final semantica = tester.ensureSemantics();
      await montar(tester, const AvatarApp(iniciales: 'AL'), brillo: brillo);
      final t = tokensDe(brillo);
      expect(tester.getSize(find.byKey(const ValueKey('circulo-avatar'))), const Size.square(44));
      expect(decoDe(tester, const ValueKey('circulo-avatar')).color, t.fondoDestacado);
      final texto = tester.widget<Text>(find.text('AL'));
      expect(texto.style!.color, t.accionSecundaria);
      expect(texto.style!.fontSize, 17);
      expect(find.bySemanticsLabel('AL'), findsNothing);
      esperarSoloColoresDelTema(tester, brillo);
      semantica.dispose();
    });
  });

  group('TarjetaHeroeStartup', () {
    enAmbosModos('342×168 en accion/primaria con botón y Sarko', (tester, brillo) async {
      var toques = 0;
      await montar(
        tester,
        SizedBox(
          width: 342,
          child: TarjetaHeroeStartup(
            titulo: 'Del Garage al MVP',
            subtitulo: 'Sprint 3 de 5 · Protección de datos',
            alContinuar: () => toques++,
          ),
        ),
        brillo: brillo,
      );
      final t = tokensDe(brillo);
      final tarjeta = find.byKey(const ValueKey('tarjeta-heroe'));
      expect(tester.getSize(tarjeta).width, 342);
      expect(tester.getSize(tarjeta).height, greaterThanOrEqualTo(TarjetaHeroeStartup.alto));
      expect(decoDe(tester, const ValueKey('tarjeta-heroe')).color, t.accionPrimaria);
      expect(decoDe(tester, const ValueKey('boton-continuar')).color, t.accionAcento);
      expect(tester.getSize(find.byKey(const ValueKey('boton-continuar'))).height, 48);
      expect(tester.widget<Text>(find.text('Del Garage al MVP')).style!.color, t.textoEnPrimario);
      await tester.tap(find.text('Continuar sprint'));
      expect(toques, 1);
      esperarSoloColoresDelTema(tester, brillo);
    });

    for (final (ancho, conSarko) in [
      (342.0, true),
      (320.0, true),
      (319.0, false),
      (272.0, false),
    ]) {
      testWidgets('a $ancho de ancho ${conSarko ? 'muestra' : 'oculta'} a Sarko (D4)', (
        tester,
      ) async {
        await montar(
          tester,
          SizedBox(
            width: ancho,
            child: TarjetaHeroeStartup(
              titulo: 'Del Garage al MVP',
              subtitulo: 'S',
              alContinuar: () {},
            ),
          ),
        );
        expect(find.byType(SarkoImagen), conSarko ? findsOneWidget : findsNothing);
        expect(tester.takeException(), isNull);
      });
    }

    test('contraste del texto sobre el héroe y el botón ≥ 4.5:1 en ambos modos', () {
      for (final t in [TokensColor.claro, TokensColor.oscuro]) {
        expect(Contraste.razon(t.textoEnPrimario, t.accionPrimaria), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.textoEnPrimario, t.accionAcento), greaterThanOrEqualTo(4.5));
      }
    });

    testWidgets('el botón se anuncia y tiene foco con teclado', (tester) async {
      final semantica = tester.ensureSemantics();
      var toques = 0;
      await montar(
        tester,
        SizedBox(
          width: 342,
          child: TarjetaHeroeStartup(titulo: 'T', subtitulo: 'S', alContinuar: () => toques++),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Continuar sprint')),
        isSemantics(isButton: true, hasTapAction: true),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(find.byKey(anillo), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(toques, 1);
      semantica.dispose();
    });
  });

  group('TarjetaRetoDiario', () {
    enAmbosModos('fondo/destacado, radio 18 y progreso en texto/acento', (tester, brillo) async {
      final semantica = tester.ensureSemantics();
      await montar(
        tester,
        const SizedBox(
          width: 342,
          child: TarjetaRetoDiario(
            titulo: 'Reto diario: 3 tarjetas sin fallar',
            subtitulo: 'Mantén tu racha de 7 días · +15 monedas',
            actual: 1,
            total: 3,
          ),
        ),
        brillo: brillo,
      );
      final t = tokensDe(brillo);
      final deco = decoDe(tester, const ValueKey('tarjeta-reto'));
      expect(deco.color, t.fondoDestacado);
      expect(deco.borderRadius, BorderRadius.circular(18));
      // 60 con las fuentes reales; en pruebas el texto mide distinto y puede crecer.
      expect(
        tester.getSize(find.byKey(const ValueKey('tarjeta-reto'))).height,
        greaterThanOrEqualTo(60),
      );
      expect(tester.widget<Text>(find.text('1/3')).style!.color, t.textoAcento);
      expect(find.bySemanticsLabel(RegExp('Reto diario.*Progreso: 1 de 3')), findsOneWidget);
      esperarSoloColoresDelTema(tester, brillo);
      semantica.dispose();
    });
  });

  group('TarjetaModulo', () {
    enAmbosModos('en curso: insignia del color del módulo y barra 2/5', (tester, brillo) async {
      await montar(
        tester,
        SizedBox(width: 342, child: tarjeta(EstadoModulo.enCurso)),
        brillo: brillo,
      );
      final t = tokensDe(brillo);
      expect(
        decoDe(tester, const ValueKey('insignia-modulo')).color,
        ColoresModulo.proteccionDeDatos,
      );
      expect(tester.getSize(find.byKey(const ValueKey('insignia-modulo'))), const Size.square(56));
      expect(decoDe(tester, const ValueKey('tarjeta-modulo')).color, t.fondoSuperficie);
      expect(
        tester.widget<Text>(find.text('MÓDULO 1 · PROTECCIÓN DE DATOS')).style!.color,
        t.textoAcento,
      );
      expect(find.text('2/5 sprints'), findsOneWidget);
      expect(tester.getSize(find.byKey(const ValueKey('barra-sprints'))), const Size(96, 8));
      expect(
        tester.getSize(find.byKey(const ValueKey('relleno-sprints'))).width,
        closeTo(96 * 2 / 5, 0.01),
      );
      esperarSoloColoresDelTema(tester, brillo);
    });

    enAmbosModos('bloqueado: fondo superficie-alt, candado y sin acción', (tester, brillo) async {
      final semantica = tester.ensureSemantics();
      var toques = 0;
      await montar(
        tester,
        SizedBox(width: 342, child: tarjeta(EstadoModulo.bloqueado, alPresionar: () => toques++)),
        brillo: brillo,
      );
      final t = tokensDe(brillo);
      expect(decoDe(tester, const ValueKey('tarjeta-modulo')).color, t.fondoSuperficieAlt);
      expect(decoDe(tester, const ValueKey('insignia-modulo')).color, t.fondoSuperficieAlt);
      expect(
        tester.widgetList<Icon>(find.byType(Icon)).map((i) => i.icon),
        contains(IconosApp.lock),
      );
      expect(find.text('Completa el módulo anterior'), findsOneWidget);
      expect(find.byKey(const ValueKey('barra-sprints')), findsNothing);
      await tester.tap(find.byType(TarjetaModulo));
      expect(toques, 0);
      expect(
        tester.getSemantics(find.byType(TarjetaModulo)),
        isSemantics(isButton: true, isEnabled: false),
      );
      expect(
        find.bySemanticsLabel(RegExp('Módulo 1, .*bloqueado, Completa el módulo anterior')),
        findsOneWidget,
      );
      esperarSoloColoresDelTema(tester, brillo);
      semantica.dispose();
    });

    enAmbosModos('completado: check y "5/5 sprints · Completado"', (tester, brillo) async {
      await montar(
        tester,
        SizedBox(width: 342, child: tarjeta(EstadoModulo.completado)),
        brillo: brillo,
      );
      expect(
        tester.widgetList<Icon>(find.byType(Icon)).map((i) => i.icon),
        contains(IconosApp.check),
      );
      expect(find.text('5/5 sprints · Completado'), findsOneWidget);
      esperarSoloColoresDelTema(tester, brillo);
    });

    testWidgets('disponible: 0/5, se anuncia y se abre con teclado', (tester) async {
      final semantica = tester.ensureSemantics();
      var toques = 0;
      await montar(
        tester,
        SizedBox(width: 342, child: tarjeta(EstadoModulo.disponible, alPresionar: () => toques++)),
      );
      expect(find.text('0/5 sprints'), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          'Módulo 1, Protección de datos, Del Garage al MVP, disponible, 0 de 5 sprints completados',
        ),
        findsOneWidget,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(find.byKey(anillo), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(toques, 1);
      semantica.dispose();
    });
  });

  group('BotonBuzon', () {
    enAmbosModos('60×60 en accion/secundaria con contador', (tester, brillo) async {
      final semantica = tester.ensureSemantics();
      var toques = 0;
      await montar(tester, BotonBuzon(pendientes: 6, alPresionar: () => toques++), brillo: brillo);
      final t = tokensDe(brillo);
      expect(tester.getSize(find.byKey(const ValueKey('caja-buzon'))), const Size.square(60));
      expect(decoDe(tester, const ValueKey('caja-buzon')).color, t.accionSecundaria);
      final contador = decoDe(tester, const ValueKey('contador-buzon'));
      expect(contador.color, t.estadoIlegal);
      expect((contador.border! as Border).top.color, t.fondoApp);
      expect(tester.getSize(find.byKey(const ValueKey('contador-buzon'))), const Size(24, 22));
      final origen = tester.getTopLeft(find.byKey(const ValueKey('caja-buzon')));
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('contador-buzon'))) - origen,
        const Offset(46, -8),
      );
      expect(find.text('6'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Buzón de apelaciones, 6 pendientes')),
        isSemantics(isButton: true, hasTapAction: true),
      );
      await tester.tap(find.byKey(const ValueKey('caja-buzon')));
      expect(toques, 1);
      esperarSoloColoresDelTema(tester, brillo);
      semantica.dispose();
    });

    testWidgets('sin pendientes no dibuja el contador', (tester) async {
      final semantica = tester.ensureSemantics();
      await montar(tester, BotonBuzon(pendientes: 0, alPresionar: () {}));
      expect(find.byKey(const ValueKey('contador-buzon')), findsNothing);
      expect(find.bySemanticsLabel('Buzón de apelaciones'), findsOneWidget);
      semantica.dispose();
    });
  });
}
