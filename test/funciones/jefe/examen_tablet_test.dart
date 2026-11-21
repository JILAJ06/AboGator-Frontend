import 'package:abogator/componentes/barra_juego.dart';
import 'package:abogator/componentes/composicion_juego_tablet.dart';
import 'package:abogator/componentes/disposicion_resultado_tablet.dart';
import 'package:abogator/componentes/hoja_lateral.dart';
import 'package:abogator/componentes/piezas_jefe.dart';
import 'package:abogator/componentes/piezas_resultado.dart';
import 'package:abogator/core/tema/efectos.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/modelos/ajustes.dart';
import 'package:abogator/funciones/jefe/pantalla_resultado.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../ayudantes/tamano_pantalla.dart';
import 'jefe_test.dart' show abrirCrisis, elegir, escenario, tocar;
import 'resultado_test.dart' show empezar, ganar, perderPorVidas;

void main() {
  group('T27 crisis en 1194×834', () {
    testWidgets('panel izquierdo #162030 con halo e ilustración × 1.4; reglas a la derecha', (
      tester,
    ) async {
      await abrirCrisis(tester, tamano: Tamano.tabletHorizontal.medida);
      expect(find.byKey(const ValueKey('crisis-tablet')), findsOneWidget);
      final panel = tester.widget<ColoredBox>(
        find.byKey(const ValueKey('panel-ilustracion-resultado')),
      );
      expect(panel.color, EfectosApp.barraJefe);
      expect(tester.getSize(find.byKey(const ValueKey('halo-crisis'))), const Size(560, 560));
      final ilustracion = tester.getRect(find.byKey(const ValueKey('ilustracion-ampliada')));
      expect(ilustracion.width, closeTo(342 * 1.4, 0.5));
      expect(find.byKey(const ValueKey('reglas-crisis')), findsOneWidget);
      expect(find.byKey(const ValueKey('boton-enfrentar')), findsOneWidget);
      expect(find.byKey(const ValueKey('alerta-jefe')), findsOneWidget);
    });

    testWidgets('"Enfrentar la auditoría" empieza el examen con la composición de juego', (
      tester,
    ) async {
      await abrirCrisis(tester, tamano: Tamano.tabletHorizontal.medida);
      await tocar(tester, find.byKey(const ValueKey('boton-enfrentar')));
      expect(find.byType(ComposicionJuegoTablet), findsOneWidget);
      expect(find.byType(BarraJuegoTablet), findsOneWidget);
      expect(find.text(Textos.pasoCrisis(1, 10)), findsOneWidget);
      expect(find.byType(TarjetaJefe), findsOneWidget);
      expect(find.text(Textos.atajosLineasExamen.last), findsOneWidget);
      expect(find.byType(PildoraComodinesBloqueados), findsOneWidget);
      // Sin tiempo extendido no se puede pausar.
      expect(find.byKey(const ValueKey('boton-pausa')), findsNothing);
    });

    testWidgets('con tiempo extendido aparece la pausa en la barra', (tester) async {
      await abrirCrisis(
        tester,
        tamano: Tamano.tabletHorizontal.medida,
        ajustes: const Ajustes(tiempoExtendido: true),
      );
      await tocar(tester, find.byKey(const ValueKey('boton-enfrentar')));
      expect(
        find.descendant(
          of: find.byType(BarraJuegoTablet),
          matching: find.byKey(const ValueKey('boton-pausa')),
        ),
        findsOneWidget,
      );
    });
  });

  group('T28b contraargumento', () {
    testWidgets('acertar el veredicto abre el contraargumento en la hoja lateral', (tester) async {
      await abrirCrisis(tester, tamano: Tamano.tabletHorizontal.medida);
      await tocar(tester, find.byKey(const ValueKey('boton-enfrentar')));
      await elegir(tester, escenario[0].respuestaCorrecta);
      expect(find.byType(HojaLateral), findsOneWidget);
      expect(find.byKey(const ValueKey('panel-contraargumento')), findsOneWidget);
      final hoja = tester.getRect(find.byKey(const ValueKey('hoja-lateral')));
      expect(hoja.width, 376);
      expect(hoja.right, 1194 - 24);
      expect(hoja.bottom, 834 - 22);
      expect(find.bySemanticsLabel(Textos.hojaContraargumento), findsOneWidget);
      await tocar(tester, find.byKey(ValueKey('fundamento-${escenario[0].fundamentoCorrecto}')));
    });
  });

  group('T29 y T30', () {
    testWidgets('ganar: trofeo y Sarko a la izquierda, certificado a la derecha', (tester) async {
      await empezar(tester, tamano: Tamano.tabletHorizontal.medida);
      await ganar(tester);
      await tester.pumpAndSettle();
      expect(find.byType(PantallaAuditoriaSuperada), findsOneWidget);
      expect(find.byType(DisposicionResultadoTablet), findsOneWidget);
      expect(find.byType(TrofeoCertificado), findsOneWidget);
      expect(find.byType(TarjetaCertificado), findsOneWidget);
      expect(find.byKey(const ValueKey('boton-ir-modulo')), findsOneWidget);
    });

    testWidgets('perder: Sarko triste a la izquierda y el resumen a la derecha', (tester) async {
      await empezar(tester, tamano: Tamano.tabletHorizontal.medida);
      await perderPorVidas(tester, 5);
      await tester.pumpAndSettle();
      expect(find.byType(PantallaInspectoraGano), findsOneWidget);
      expect(find.byType(DisposicionResultadoTablet), findsOneWidget);
      expect(find.byType(FilaResumenExamen), findsOneWidget);
      expect(find.byKey(const ValueKey('boton-volver-mapa')), findsOneWidget);
    });

    testWidgets('en móvil los resultados no cambian', (tester) async {
      await empezar(tester);
      await perderPorVidas(tester, 5);
      await tester.pumpAndSettle();
      expect(find.byType(DisposicionResultadoTablet), findsNothing);
      expect(find.byKey(const ValueKey('resultado-desplazable')), findsOneWidget);
    });
  });

  group('sin desbordes', () {
    for (final tamano in [Tamano.tabletHorizontal, Tamano.tabletVertical, Tamano.tabletMinima]) {
      for (final escala in [1.0, 2.0]) {
        for (final brillo in Brightness.values) {
          final nombre = '${tamano.name} al ${(escala * 100).round()} % (${brillo.name})';
          testWidgets('crisis y decisión en $nombre', (tester) async {
            tester.platformDispatcher.textScaleFactorTestValue = escala;
            tester.platformDispatcher.platformBrightnessTestValue = brillo;
            addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
            addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
            await abrirCrisis(tester, tamano: tamano.medida);
            expect(tester.takeException(), isNull);
            await tocar(tester, find.byKey(const ValueKey('boton-enfrentar')));
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  });
}
