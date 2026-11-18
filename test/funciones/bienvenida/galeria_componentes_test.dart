import 'package:abogator/app/app.dart';
import 'package:abogator/componentes/barra_progreso.dart';
import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/campo_texto_app.dart';
import 'package:abogator/componentes/chip_hud.dart';
import 'package:abogator/componentes/corazon_vida.dart';
import 'package:abogator/componentes/impacto_startup.dart';
import 'package:abogator/componentes/indicadores_startup.dart';
import 'package:abogator/componentes/logo_app.dart';
import 'package:abogator/componentes/navegacion_inferior_app.dart';
import 'package:abogator/componentes/paginador_puntos.dart';
import 'package:abogator/componentes/sarko_imagen.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/funciones/bienvenida/galeria_componentes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Pantalla alta para que la galería entera quede construida.
Future<void> montarGaleria(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 9000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(const ProviderScope(child: AppAbogator()));
  await tester.pumpAndSettle();
}

TokensColor tokensActuales(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(GaleriaComponentes))).extension<TokensColor>()!;

void main() {
  testWidgets('la app abre en la galería con todos los componentes', (tester) async {
    await montarGaleria(tester);
    expect(find.text(Textos.galeriaTitulo), findsOneWidget);
    expect(find.byType(BotonApp), findsNWidgets(7));
    expect(find.byType(CampoTextoApp), findsNWidgets(4));
    expect(find.byType(ChipHud), findsNWidgets(5));
    expect(find.byType(FilaVidas), findsNWidgets(3));
    expect(find.byType(IndicadoresStartup), findsOneWidget);
    expect(find.byType(ImpactoStartup), findsOneWidget);
    expect(find.byType(BarraProgreso), findsNWidgets(4));
    expect(find.byType(PaginadorPuntos), findsOneWidget);
    expect(find.byType(SarkoImagen), findsNWidgets(4));
    expect(find.byType(LogoApp), findsNWidgets(3));
    expect(find.byType(NavegacionInferiorApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el interruptor alterna entre claro y oscuro', (tester) async {
    await montarGaleria(tester);
    expect(tokensActuales(tester).fondoApp, TokensColor.claro.fondoApp);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(tokensActuales(tester).fondoApp, TokensColor.oscuro.fondoApp);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la navegación inferior cambia de pestaña', (tester) async {
    await montarGaleria(tester);
    await tester.tap(find.text('Perfil'));
    await tester.pump();
    expect(
      tester.widget<NavegacionInferiorApp>(find.byType(NavegacionInferiorApp)).actual,
      PestanaApp.perfil,
    );
  });

  for (final brillo in Brightness.values) {
    testWidgets('con texto al 200 % no hay desbordes (${brillo.name})', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      tester.platformDispatcher.platformBrightnessTestValue = brillo;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await tester.binding.setSurfaceSize(const Size(390, 16000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const ProviderScope(child: AppAbogator()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
