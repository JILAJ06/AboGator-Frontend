import 'package:abogator/componentes/corazon_vida.dart';
import 'package:abogator/core/tema/colores_marca.dart';
import 'package:abogator/core/tema/efectos.dart';
import 'package:abogator/core/tema/tema_app.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const claveComponente = ValueKey('componente-en-prueba');

/// Monta [hijo] dentro de una app con el tema claro u oscuro.
Future<void> montar(
  WidgetTester tester,
  Widget hijo, {
  Brightness brillo = Brightness.light,
  bool reducirAnimaciones = false,
  double escalaTexto = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: crearTemaClaro(),
      darkTheme: crearTemaOscuro(),
      themeMode: brillo == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: reducirAnimaciones,
            textScaler: TextScaler.linear(escalaTexto),
          ),
          child: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: KeyedSubtree(key: claveComponente, child: hijo),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Tokens del modo que se está mostrando.
TokensColor tokensDe(Brightness brillo) =>
    brillo == Brightness.dark ? TokensColor.oscuro : TokensColor.claro;

int _rgb(Color c) => c.toARGB32() & 0xFFFFFF;

/// Colores (sin opacidad) que pinta el componente montado: textos, íconos,
/// fondos, bordes, sombras y el corazón dibujado.
Set<int> coloresUsados(WidgetTester tester) {
  final colores = <int>{};
  final raiz = find.byKey(claveComponente);
  Finder dentro(Type tipo) => find.descendant(of: raiz, matching: find.byType(tipo));

  for (final texto in tester.widgetList<RichText>(dentro(RichText))) {
    texto.text.visitChildren((span) {
      final color = span.style?.color;
      if (color != null) colores.add(_rgb(color));
      return true;
    });
  }
  for (final caja in tester.widgetList<DecoratedBox>(dentro(DecoratedBox))) {
    final d = caja.decoration;
    if (d is BoxDecoration) {
      if (d.color != null) colores.add(_rgb(d.color!));
      final borde = d.border;
      if (borde is Border) {
        for (final lado in [borde.top, borde.right, borde.bottom, borde.left]) {
          if (lado.style != BorderStyle.none && lado.width > 0) colores.add(_rgb(lado.color));
        }
      }
      for (final sombra in d.boxShadow ?? const <BoxShadow>[]) {
        colores.add(_rgb(sombra.color));
      }
    }
  }
  for (final pintura in tester.widgetList<CustomPaint>(dentro(CustomPaint))) {
    final pintor = pintura.painter;
    if (pintor is PintorCorazon) colores.add(_rgb(pintor.color));
  }
  return colores;
}

/// Colores permitidos: los tokens del modo, los colores de módulo, la sombra
/// sólida, el brillo y las bases de los nodos del mapa (derivadas de las caras).
Set<int> coloresPermitidos(Brightness brillo) {
  final t = tokensDe(brillo);
  return {
    for (final c in t.porNombre.values) _rgb(c),
    for (final c in ColoresModulo.enOrden) _rgb(c),
    _rgb(EfectosApp.colorSombraSolida),
    _rgb(EfectosApp.brilloBarra),
    for (final cara in [t.accionPrimaria, t.accionAcento, t.fondoSuperficieAlt, t.accionSecundaria])
      _rgb(EfectosApp.baseNodo(cara)),
  };
}

/// Verifica que el componente montado solo use colores del tema.
void esperarSoloColoresDelTema(WidgetTester tester, Brightness brillo) {
  final usados = coloresUsados(tester);
  final fuera = usados.difference(coloresPermitidos(brillo));
  expect(
    fuera,
    isEmpty,
    reason: 'Colores fuera del tema: ${fuera.map((c) => c.toRadixString(16)).toList()}',
  );
}

/// Ejecuta [cuerpo] en claro y en oscuro.
void enAmbosModos(String descripcion, Future<void> Function(WidgetTester, Brightness) cuerpo) {
  for (final brillo in Brightness.values) {
    testWidgets('$descripcion (${brillo == Brightness.dark ? 'oscuro' : 'claro'})', (tester) async {
      await cuerpo(tester, brillo);
    });
  }
}
