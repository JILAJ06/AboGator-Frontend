import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/aviso_informativo.dart';
import 'package:abogator/componentes/confeti_sprint.dart';
import 'package:abogator/componentes/disposicion_resultado_tablet.dart';
import 'package:abogator/componentes/estrellas_sprint.dart';
import 'package:abogator/componentes/riel_navegacion.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/funciones/juego/pantalla_sprint_completado.dart';
import 'package:abogator/funciones/juego/pantalla_startup_quiebra.dart';
import 'package:abogator/funciones/vidas/pantalla_sin_vidas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../ayudantes/tamano_pantalla.dart';
import 'ayudante_juego.dart';
import 'fin_sprint_test.dart' show mazoLegal, quebrarPorRiesgo, responder;

/// Juega 5 Legal con un fallo en [tamano] y llega a 19.
Future<void> completar(WidgetTester tester, {Tamano tamano = Tamano.tabletHorizontal}) async {
  await abrirJuego(tester, tamano: tamano.medida, tarjetas: mazoLegal(5));
  for (var i = 0; i < 4; i++) {
    await responder(tester, Veredicto.legal);
  }
  await responder(tester, Veredicto.ilegal);
}

/// Comprueba la composición de resultado: panel izquierdo de 597 y la columna
/// de 470 en la mitad derecha, sin riel.
void esperarResultadoTablet(WidgetTester tester) {
  expect(find.byType(RielNavegacion), findsNothing);
  final panel = tester.getRect(find.byKey(const ValueKey('panel-ilustracion-resultado')));
  expect(panel.left, 0);
  expect(panel.width, 597);
  expect(panel.height, 834);
  final columna = tester.getRect(
    find
        .descendant(
          of: find.byKey(const ValueKey('columna-resultado')),
          matching: find.byType(ConstrainedBox),
        )
        .at(1),
  );
  expect(columna.width, MedidasColumna.ancho);
  expect(columna.center.dx, closeTo(597 + (1194 - 597) / 2, 1));
}

abstract final class MedidasColumna {
  static const double ancho = 470;
}

void main() {
  group('T19 Sprint completado en 1194×834', () {
    testWidgets('Sarko y estrellas a la izquierda; contenido en 470 a la derecha', (tester) async {
      await completar(tester);
      expect(find.byType(PantallaSprintCompletado), findsOneWidget);
      esperarResultadoTablet(tester);
      // La ilustración × 1.7: elipse de 340 y la estrella del medio de 78.2.
      final ilustracion = tester.getRect(find.byKey(const ValueKey('ilustracion-ampliada')));
      expect(ilustracion.width, closeTo(210 * 1.7, 0.5));
      expect(ilustracion.right, lessThanOrEqualTo(597));
      final estrellas = find.descendant(
        of: find.byType(EstrellasSprint),
        matching: find.byType(CustomPaint),
      );
      final tamanos = [
        for (final e in estrellas.evaluate()) tester.getRect(find.byWidget(e.widget)).width,
      ];
      expect(tamanos[1], closeTo(78.2, 0.2));
      expect(tamanos[0], closeTo(61.2, 0.2));
      // Confeti sobre el panel izquierdo.
      expect(
        tester.widget<ConfetiSprint>(find.byType(ConfetiSprint)).piezas,
        ConfetiSprint.piezasSprintTablet,
      );
      // Tres estadísticas iguales, indicadores en su caja, aviso y botones.
      final a = tester.getSize(find.byKey(const ValueKey('estadistica-aciertos')));
      final x = tester.getSize(find.byKey(const ValueKey('estadistica-xp')));
      expect(a.width, closeTo(x.width, 0.5));
      expect(find.byKey(const ValueKey('caja-indicadores-tablet')), findsOneWidget);
      expect(find.byKey(const ValueKey('aviso-buzon')), findsOneWidget);
      expect(find.text(Textos.continuarAlMapa), findsOneWidget);
      expect(find.text(Textos.repasarFallos), findsOneWidget);
    });

    testWidgets('sin fallos no hay aviso del buzón', (tester) async {
      await abrirJuego(tester, tamano: Tamano.tabletHorizontal.medida, tarjetas: mazoLegal(2));
      await responder(tester, Veredicto.legal);
      await responder(tester, Veredicto.legal);
      esperarResultadoTablet(tester);
      expect(find.byType(AvisoInformativo), findsNothing);
    });

    testWidgets('"Continuar al mapa" vuelve al mapa', (tester) async {
      await completar(tester);
      await tester.tap(find.text(Textos.continuarAlMapa));
      await tester.pumpAndSettle();
      expect(rutaActual(tester), Rutas.mapaSprintsDe('mod-1'));
    });

    for (final tamano in [Tamano.tabletVertical, Tamano.tabletMinima, Tamano.movil]) {
      testWidgets('${tamano.name}: la columna de siempre', (tester) async {
        await completar(tester, tamano: tamano);
        expect(find.byType(DisposicionResultadoTablet), findsNothing);
        expect(find.byKey(const ValueKey('columna-fin-sprint')), findsOneWidget);
      });
    }
  });

  group('T19b Startup en quiebra', () {
    testWidgets('Sarko triste y la causa a la izquierda; indicadores y aviso a la derecha', (
      tester,
    ) async {
      await quebrarPorRiesgo(tester, tamano: Tamano.tabletHorizontal.medida);
      expect(find.byType(PantallaStartupQuiebra), findsOneWidget);
      esperarResultadoTablet(tester);
      expect(find.byKey(const ValueKey('indicadores-quiebra')), findsOneWidget);
      expect(find.byKey(const ValueKey('aviso-reinicio')), findsOneWidget);
      expect(find.text(Textos.quiebraTitulo), findsOneWidget);
      await tester.tap(find.text(Textos.reiniciarSprint));
      await tester.pumpAndSettle();
      expect(rutaActual(tester), Rutas.juegoDe(sprintMock));
    });
  });

  group('T20 Sin vidas', () {
    testWidgets('corazones y Sarko a la izquierda, Cerrar arriba y la cuenta a la derecha', (
      tester,
    ) async {
      await abrirJuego(
        tester,
        ruta: Rutas.sinVidasDe('mod-1'),
        vidas: 0,
        tamano: Tamano.tabletHorizontal.medida,
      );
      expect(find.byType(PantallaSinVidas), findsOneWidget);
      esperarResultadoTablet(tester);
      expect(find.byKey(const ValueKey('vidas-sin-vidas')), findsOneWidget);
      expect(find.text(Textos.sinVidasTitulo), findsOneWidget);
      final cerrar = tester.getTopLeft(find.byKey(const ValueKey('caja-cerrar')));
      expect(cerrar, const Offset(24, 12));
      await tester.tap(find.byKey(const ValueKey('caja-cerrar')));
      await tester.pumpAndSettle();
      expect(rutaActual(tester), Rutas.mapaSprintsDe('mod-1'));
    });
  });

  group('sin desbordes', () {
    for (final tamano in [Tamano.tabletHorizontal, Tamano.tabletVertical, Tamano.tabletMinima]) {
      for (final escala in [1.0, 2.0]) {
        for (final brillo in Brightness.values) {
          final nombre = '${tamano.name} al ${(escala * 100).round()} % (${brillo.name})';
          testWidgets('19, 19b y 20 en $nombre', (tester) async {
            tester.platformDispatcher.textScaleFactorTestValue = escala;
            tester.platformDispatcher.platformBrightnessTestValue = brillo;
            addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
            addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
            await completar(tester, tamano: tamano);
            expect(tester.takeException(), isNull);
            await abrirJuego(
              tester,
              ruta: Rutas.sinVidasDe('mod-1'),
              vidas: 0,
              tamano: tamano.medida,
            );
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  });
}
