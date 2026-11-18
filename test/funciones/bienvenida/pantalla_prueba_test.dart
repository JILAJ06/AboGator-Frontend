import 'package:abogator/app/app.dart';
import 'package:abogator/core/tema/tipografia.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/funciones/bienvenida/pantalla_prueba.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const nombresTokens = [
  Textos.tokenFondoApp,
  Textos.tokenFondoSuperficie,
  Textos.tokenFondoSuperficieAlt,
  Textos.tokenFondoDestacado,
  Textos.tokenTextoPrimario,
  Textos.tokenTextoSecundario,
  Textos.tokenTextoEnPrimario,
  Textos.tokenTextoAcento,
  Textos.tokenBordeDefault,
  Textos.tokenAccionPrimaria,
  Textos.tokenAccionSecundaria,
  Textos.tokenAccionAcento,
  Textos.tokenEstadoLegal,
  Textos.tokenEstadoIlegal,
];

const nombresEstilos = [
  Textos.estiloDisplay,
  Textos.estiloH1,
  Textos.estiloH2,
  Textos.estiloH3,
  Textos.estiloCuerpoGrande,
  Textos.estiloCuerpoBase,
  Textos.estiloCuerpoEnfasis,
  Textos.estiloEtiqueta,
  Textos.estiloLeyenda,
  Textos.estiloBoton,
  Textos.estiloCodigo,
];

Future<void> montarApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [resolutorFuenteProvider.overrideWithValue(fuenteSinDescarga)],
      child: const AppAbogator(),
    ),
  );
  await tester.pumpAndSettle();
}

TokensColor tokensActuales(WidgetTester tester) {
  final context = tester.element(find.byType(PantallaPrueba));
  return Theme.of(context).extension<TokensColor>()!;
}

Brightness brilloActual(WidgetTester tester) {
  return Theme.of(tester.element(find.byType(PantallaPrueba))).brightness;
}

void main() {
  testWidgets('abre en la pantalla de prueba con los 14 tokens y los 11 estilos', (tester) async {
    await montarApp(tester);

    expect(find.text(Textos.pruebaTitulo), findsOneWidget);
    for (final nombre in nombresTokens) {
      expect(find.text(nombre), findsOneWidget, reason: nombre);
    }
    for (final nombre in nombresEstilos) {
      expect(find.textContaining('$nombre · '), findsOneWidget, reason: nombre);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('en modo claro usa los tokens claros', (tester) async {
    await montarApp(tester);

    expect(brilloActual(tester), Brightness.light);
    expect(tokensActuales(tester).fondoApp.toARGB32(), 0xFFF8FAFC);
    expect(find.text('#F8FAFC'), findsWidgets);
  });

  testWidgets('el interruptor cambia a modo oscuro y regresa a claro', (tester) async {
    await montarApp(tester);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(brilloActual(tester), Brightness.dark);
    expect(tokensActuales(tester).fondoApp.toARGB32(), 0xFF0B1220);
    expect(find.text('#0B1220'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(brilloActual(tester), Brightness.light);
  });

  testWidgets('sigue al sistema cuando el sistema está en modo oscuro', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await montarApp(tester);

    expect(brilloActual(tester), Brightness.dark);
    expect(tokensActuales(tester).textoPrimario.toARGB32(), 0xFFF8FAFC);
    expect(tester.takeException(), isNull);
  });

  testWidgets('respeta el texto dinámico del sistema', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await montarApp(tester);

    final escala = MediaQuery.textScalerOf(tester.element(find.byType(PantallaPrueba)));
    expect(escala.scale(10), 20);
    expect(tester.takeException(), isNull);
  });
}
