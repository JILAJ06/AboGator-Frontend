import 'package:abogator/app/app.dart';
import 'package:abogator/app/enrutador.dart';
import 'package:abogator/app/pantalla_pendiente.dart';
import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/sarko_imagen.dart';
import 'package:abogator/core/recursos/imagenes_app.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/mocks/onboarding_en_memoria.dart';
import 'package:abogator/datos/repositorios/proveedores_repositorios.dart';
import 'package:abogator/funciones/bienvenida/pantalla_onboarding.dart';
import 'package:abogator/funciones/bienvenida/pantalla_splash.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Monta la app con un estado de onboarding controlado. Devuelve el repositorio.
Future<OnboardingEnMemoria> montarApp(
  WidgetTester tester, {
  bool visto = false,
  Size tamano = const Size(390, 844),
}) async {
  await tester.binding.setSurfaceSize(tamano);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final repo = OnboardingEnMemoria(vistoAlInicio: visto);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [repositorioOnboardingProvider.overrideWithValue(repo)],
      child: const AppAbogator(),
    ),
  );
  await tester.pump();
  return repo;
}

void irA(WidgetTester tester, String ruta) {
  ProviderScope.containerOf(tester.element(find.byType(AppAbogator)))
      .read(enrutadorProvider)
      .go(ruta);
}

/// Pasa el Splash (2 s) y espera a que termine la navegación.
Future<void> pasarSplash(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

Future<void> abrirOnboarding(WidgetTester tester) async {
  irA(tester, Rutas.onboarding);
  await tester.pumpAndSettle();
}

void reducirAnimaciones(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
    disableAnimations: true,
  );
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

void main() {
  group('01 Splash', () {
    testWidgets('es la primera pantalla y muestra lema y "Powered by LawSwipe"', (tester) async {
      await montarApp(tester);
      expect(find.byType(PantallaSplash), findsOneWidget);
      expect(find.text(Textos.splashLema), findsOneWidget);
      expect(find.text(Textos.splashPoweredBy), findsOneWidget);
      final fondo = tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor;
      expect(fondo, TokensColor.claro.accionPrimaria);
      // Logo vertical "sobre verde" real, sin tarjeta marcador, a 323.7×187.9.
      final logo = find.byKey(const ValueKey('logo-splash'));
      expect(logo, findsOneWidget);
      final imagen = tester.widget<Image>(find.descendant(of: logo, matching: find.byType(Image)));
      expect(
        (imagen.image as AssetImage).assetName,
        ImagenesApp.logo(FormaLogo.vertical, TonoLogo.sobreVerde),
      );
      expect(tester.getSize(logo).width, closeTo(323.7, 0.01));
      expect(tester.getSize(logo).height, closeTo(187.8, 0.2));
      expect(find.byKey(const ValueKey('logo-splash-marcador')), findsNothing);
      await pasarSplash(tester);
    });

    testWidgets('en modo oscuro conserva el verde de marca y los colores claros', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await montarApp(tester);
      final fondo = tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor;
      expect(fondo, TokensColor.claro.accionPrimaria);
      expect(
        tester.widget<Text>(find.text(Textos.splashLema)).style!.color,
        TokensColor.claro.fondoDestacado,
      );
      expect(
        tester.widget<Text>(find.text(Textos.splashPoweredBy)).style!.color,
        TokensColor.claro.fondoDestacado,
      );
      final primerPunto = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byKey(const ValueKey('puntos-carga')),
              matching: find.byType(Container),
            ),
          )
          .first;
      expect((primerPunto.decoration! as BoxDecoration).color, TokensColor.claro.textoEnPrimario);
      await pasarSplash(tester);
    });

    testWidgets('tiene una sola etiqueta semántica', (tester) async {
      final semantica = tester.ensureSemantics();
      await montarApp(tester);
      expect(find.bySemanticsLabel(Textos.splashSemantica), findsOneWidget);
      expect(find.bySemanticsLabel(Textos.splashPoweredBy), findsNothing);
      await pasarSplash(tester);
      semantica.dispose();
    });

    testWidgets('sigue en el Splash antes de 2 s', (tester) async {
      await montarApp(tester);
      await tester.pump(const Duration(milliseconds: 1900));
      expect(find.byType(PantallaSplash), findsOneWidget);
      await pasarSplash(tester);
    });

    testWidgets('a los 2 s va al onboarding la primera vez', (tester) async {
      await montarApp(tester);
      await pasarSplash(tester);
      expect(find.byType(PantallaOnboarding), findsOneWidget);
    });

    testWidgets('a los 2 s va al inicio de sesión si el onboarding ya se vio', (tester) async {
      await montarApp(tester, visto: true);
      await pasarSplash(tester);
      expect(find.byType(PantallaOnboarding), findsNothing);
      expect(find.text(Textos.pendienteInicioSesion), findsOneWidget);
    });

    testWidgets('los puntos de carga avanzan y quedan fijos con "reducir animaciones"', (
      tester,
    ) async {
      List<Color?> colores() => tester
          .widgetList<Container>(
            find.descendant(
              of: find.byKey(const ValueKey('puntos-carga')),
              matching: find.byType(Container),
            ),
          )
          .map((c) => (c.decoration! as BoxDecoration).color)
          .toList();

      await montarApp(tester);
      final inicio = colores();
      await tester.pump(const Duration(milliseconds: 400));
      expect(colores(), isNot(inicio));
      await pasarSplash(tester);
    });

    testWidgets('con "reducir animaciones" el primer punto queda activo', (tester) async {
      reducirAnimaciones(tester);
      await montarApp(tester);
      Color? primero() =>
          (tester
                      .widgetList<Container>(
                        find.descendant(
                          of: find.byKey(const ValueKey('puntos-carga')),
                          matching: find.byType(Container),
                        ),
                      )
                      .first
                      .decoration!
                  as BoxDecoration)
              .color;
      final antes = primero();
      await tester.pump(const Duration(milliseconds: 1200));
      expect(primero(), antes);
      expect(antes, TokensColor.claro.textoEnPrimario);
      await pasarSplash(tester);
    });
  });

  group('02–04 Onboarding', () {
    testWidgets('las 4 páginas muestran su título, texto y botón', (tester) async {
      reducirAnimaciones(tester);
      await montarApp(tester);
      await abrirOnboarding(tester);
      for (final (i, pagina) in PaginaOnboarding.todas.indexed) {
        expect(find.text(pagina.titulo), findsOneWidget, reason: 'página ${i + 1}');
        expect(find.text(pagina.texto), findsOneWidget);
        expect(find.text(pagina.boton), findsOneWidget);
        if (i < 3) {
          await tester.tap(find.text(Textos.onboardingSiguiente));
          await tester.pumpAndSettle();
        }
      }
      expect(find.text(Textos.onboardingComenzar), findsOneWidget);
    });

    testWidgets('el paginador anuncia "Página N de 4" y se puede deslizar', (tester) async {
      final semantica = tester.ensureSemantics();
      await montarApp(tester);
      await abrirOnboarding(tester);
      expect(find.bySemanticsLabel('Página 1 de 4'), findsOneWidget);
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Página 2 de 4'), findsOneWidget);
      expect(find.text(Textos.onboarding2Titulo), findsOneWidget);
      semantica.dispose();
    });

    testWidgets('"¡Comenzar!" marca el onboarding como visto y va al inicio de sesión', (
      tester,
    ) async {
      reducirAnimaciones(tester);
      final repo = await montarApp(tester);
      await abrirOnboarding(tester);
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text(Textos.onboardingSiguiente));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text(Textos.onboardingComenzar));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaPendiente), findsOneWidget);
      expect(await repo.fueVisto(), isTrue);
    });

    testWidgets('"Omitir" marca visto y un segundo arranque salta al inicio de sesión', (
      tester,
    ) async {
      final repo = await montarApp(tester);
      await pasarSplash(tester);
      await tester.tap(find.text(Textos.onboardingOmitir));
      await tester.pumpAndSettle();
      expect(find.text(Textos.pendienteInicioSesion), findsOneWidget);
      expect(await repo.fueVisto(), isTrue);

      irA(tester, Rutas.splash);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(PantallaSplash), findsOneWidget);
      await pasarSplash(tester);
      expect(find.byType(PantallaOnboarding), findsNothing);
      expect(find.text(Textos.pendienteInicioSesion), findsOneWidget);
    });

    testWidgets('Omitir tiene zona táctil ≥ 48 y el foco va Omitir → botón', (tester) async {
      await montarApp(tester);
      await abrirOnboarding(tester);
      final omitir = tester.getSize(find.byKey(const ValueKey('boton-omitir')));
      expect(omitir.width, greaterThanOrEqualTo(48));
      expect(omitir.height, greaterThanOrEqualTo(48));
      // Arriba a la derecha: el texto termina a 24 del borde (x = 366 en 390).
      final texto = tester.getRect(find.text(Textos.onboardingOmitir));
      expect(texto.right, closeTo(366, 1));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final anillo = find.byKey(const ValueKey('anillo-foco'));
      expect(anillo, findsOneWidget);
      expect(
        find.ancestor(of: anillo, matching: find.byKey(const ValueKey('boton-omitir'))),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find
              .ancestor(
                of: find.byKey(const ValueKey('boton-omitir')),
                matching: find.byType(Stack),
              )
              .first,
          matching: anillo,
        ),
        findsOneWidget,
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        find.descendant(
          of: find.byType(BotonApp),
          matching: find.byKey(const ValueKey('anillo-foco')),
        ),
        findsOneWidget,
      );
    });

    testWidgets('las ilustraciones son decorativas', (tester) async {
      final semantica = tester.ensureSemantics();
      await montarApp(tester);
      await abrirOnboarding(tester);
      expect(find.byType(SarkoImagen), findsOneWidget);
      expect(find.bySemanticsLabel(PoseSarko.alegre.textoAlternativo), findsNothing);
      expect(find.bySemanticsLabel(Textos.onboarding1Titulo), findsOneWidget);
      semantica.dispose();
    });
  });

  group('Sin desbordes con texto al 200 %', () {
    for (final tamano in [const Size(390, 844), const Size(360, 640)]) {
      for (final brillo in Brightness.values) {
        final nombre = '${tamano.width.toInt()}×${tamano.height.toInt()} ${brillo.name}';
        testWidgets('Splash y las 4 páginas ($nombre)', (tester) async {
          tester.platformDispatcher.textScaleFactorTestValue = 2;
          tester.platformDispatcher.platformBrightnessTestValue = brillo;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
          reducirAnimaciones(tester);

          await montarApp(tester, tamano: tamano);
          expect(tester.takeException(), isNull, reason: 'Splash');
          await pasarSplash(tester);
          for (var i = 0; i < 4; i++) {
            expect(tester.takeException(), isNull, reason: 'página ${i + 1}');
            if (i < 3) {
              await tester.tap(find.text(Textos.onboardingSiguiente));
              await tester.pumpAndSettle();
            }
          }
        });
      }
    }
  });
}
