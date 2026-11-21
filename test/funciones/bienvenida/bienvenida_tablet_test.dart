import 'package:abogator/componentes/paginador_puntos.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/funciones/acceso/pantalla_inicio_sesion.dart';
import 'package:abogator/funciones/bienvenida/pantalla_onboarding.dart';
import 'package:abogator/funciones/bienvenida/pantalla_splash.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../ayudantes/tamano_pantalla.dart';
import 'bienvenida_test.dart' show abrirOnboarding, montarApp, pasarSplash, reducirAnimaciones;

Finder get columna => find.byKey(const ValueKey('columna-onboarding'));

void main() {
  group('01 Splash en tablet (T01)', () {
    testWidgets('logo de 469.4, lema más grande y puntos de 12', (tester) async {
      await montarApp(tester, tamano: Tamano.tabletHorizontal.medida);
      expect(find.byType(PantallaSplash), findsOneWidget);
      final logo = tester.getSize(find.byKey(const ValueKey('logo-splash')));
      expect(logo.width, closeTo(469.4, 0.1));
      final lema = tester.widget<Text>(find.text(Textos.splashLema));
      expect(lema.style!.fontSize, closeTo(20.3, 0.01));
      final puntos = find.descendant(
        of: find.byKey(const ValueKey('puntos-carga')),
        matching: find.byType(Container),
      );
      expect(tester.getSize(puntos.first), const Size(12, 12));
      await pasarSplash(tester);
      expect(find.byType(PantallaOnboarding), findsOneWidget);
    });

    testWidgets('en móvil se queda igual', (tester) async {
      await montarApp(tester);
      expect(tester.getSize(find.byKey(const ValueKey('logo-splash'))).width, closeTo(323.7, 0.01));
      await pasarSplash(tester);
    });
  });

  group('02 a 04 Onboarding en tablet horizontal (T02 a T04)', () {
    testWidgets('panel de la ilustración a la izquierda y columna de 470 a la derecha', (
      tester,
    ) async {
      await montarApp(tester, tamano: Tamano.tabletHorizontal.medida);
      await abrirOnboarding(tester);
      final panel = tester.getRect(find.byKey(const ValueKey('panel-ilustracion')));
      expect(panel.left, 0);
      expect(panel.width, 597);
      // El círculo de 300 del móvil se ve de 465 (× 1.55), como en Figma.
      final circulo = tester.getRect(find.byKey(const ValueKey('circulo-onboarding')));
      expect(circulo.width, closeTo(465, 1));
      expect(circulo.center.dx, closeTo(panel.center.dx - 2.3, 4));
      final c = tester.getRect(columna);
      expect(c.width, 470);
      expect(c.left, closeTo(597 + (597 - 470) / 2, 0.5));
      // Título a la izquierda (no centrado como en móvil).
      final titulo = tester.widget<Text>(find.text(Textos.onboarding1Titulo));
      expect(titulo.textAlign, isNot(TextAlign.center));
      expect(tester.getTopLeft(find.text(Textos.onboarding1Titulo)).dx, c.left);
      expect(tester.getTopLeft(find.byType(PaginadorPuntos)).dx, c.left);
      // "Omitir" arriba a la derecha, terminando 20 + 12 antes del borde.
      final omitir = tester.getRect(find.byKey(const ValueKey('boton-omitir')));
      expect(omitir.right, closeTo(1194 - 20, 0.5));
      expect(omitir.height, greaterThanOrEqualTo(48));
      expect(find.byType(PageView), findsNothing);
    });

    testWidgets('"Siguiente" recorre las 4 páginas y "Comenzar" lleva al acceso', (tester) async {
      await montarApp(tester, tamano: Tamano.tabletHorizontal.medida);
      await abrirOnboarding(tester);
      for (final titulo in [
        Textos.onboarding1Titulo,
        Textos.onboarding2Titulo,
        Textos.onboarding3Titulo,
      ]) {
        expect(find.text(titulo), findsOneWidget);
        await tester.tap(find.text(Textos.onboardingSiguiente));
        await tester.pumpAndSettle();
      }
      expect(find.text(Textos.onboarding4Titulo), findsOneWidget);
      expect(find.bySemanticsLabel(Textos.paginador(4, 4)), findsOneWidget);
      await tester.tap(find.text(Textos.onboardingComenzar));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaInicioSesion), findsOneWidget);
    });

    testWidgets('"Omitir" va al inicio de sesión', (tester) async {
      final repo = await montarApp(tester, tamano: Tamano.tabletHorizontal.medida);
      await abrirOnboarding(tester);
      await tester.tap(find.text(Textos.onboardingOmitir));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaInicioSesion), findsOneWidget);
      expect(await repo.fueVisto(), isTrue);
    });

    testWidgets('con "reducir animaciones" cambia de página sin transición', (tester) async {
      reducirAnimaciones(tester);
      await montarApp(tester, tamano: Tamano.tabletHorizontal.medida);
      await abrirOnboarding(tester);
      await tester.tap(find.text(Textos.onboardingSiguiente));
      await tester.pump();
      expect(find.text(Textos.onboarding2Titulo), findsOneWidget);
      expect(find.text(Textos.onboarding1Titulo), findsNothing);
    });
  });

  group('Onboarding en tablet vertical', () {
    testWidgets('la ilustración arriba y la columna de 470 debajo, centrada', (tester) async {
      await montarApp(tester, tamano: Tamano.tabletVertical.medida);
      await abrirOnboarding(tester);
      expect(find.byKey(const ValueKey('panel-ilustracion')), findsNothing);
      final circulo = tester.getRect(find.byKey(const ValueKey('circulo-onboarding')));
      final c = tester.getRect(columna);
      expect(c.width, 470);
      expect(c.center.dx, closeTo(834 / 2, 0.5));
      expect(c.top, greaterThan(circulo.bottom));
    });
  });

  group('sin desbordes', () {
    for (final tamano in [Tamano.tabletHorizontal, Tamano.tabletVertical, Tamano.tabletMinima]) {
      for (final escala in [1.0, 2.0]) {
        testWidgets('Splash y onboarding en ${tamano.name} al ${(escala * 100).round()} %', (
          tester,
        ) async {
          tester.platformDispatcher.textScaleFactorTestValue = escala;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await montarApp(tester, tamano: tamano.medida);
          expect(tester.takeException(), isNull);
          await pasarSplash(tester);
          for (var i = 0; i < 4; i++) {
            expect(tester.takeException(), isNull);
            final boton = find.text(
              i == 3 ? Textos.onboardingComenzar : Textos.onboardingSiguiente,
            );
            await tester.ensureVisible(boton);
            await tester.pumpAndSettle();
            if (i < 3) {
              await tester.tap(boton);
              await tester.pumpAndSettle();
            }
          }
          expect(find.text(Textos.onboarding4Titulo), findsOneWidget);
        });
      }
    }
  });
}
