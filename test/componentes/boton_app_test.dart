import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/core/tema/iconos_app.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

BoxDecoration decoracionBoton(WidgetTester tester) {
  final cajas = tester.widgetList<DecoratedBox>(
    find.descendant(of: find.byType(BotonApp), matching: find.byType(DecoratedBox)),
  );
  return cajas.first.decoration as BoxDecoration;
}

void main() {
  enAmbosModos('los 6 tipos usan los tokens indicados', (tester, brillo) async {
    final t = tokensDe(brillo);
    final esperados = <(TipoBoton, bool), (Color?, Color)>{
      (TipoBoton.primario, true): (t.accionPrimaria, t.textoEnPrimario),
      (TipoBoton.secundario, true): (t.fondoSuperficie, t.accionSecundaria),
      (TipoBoton.acento, true): (t.accionAcento, t.textoEnPrimario),
      (TipoBoton.peligro, true): (t.estadoIlegal, t.textoEnPrimario),
      (TipoBoton.fantasma, true): (null, t.textoAcento),
      (TipoBoton.primario, false): (t.fondoSuperficieAlt, t.textoSecundario),
    };
    for (final MapEntry(key: (tipo, habilitado), value: (fondo, texto)) in esperados.entries) {
      await montar(
        tester,
        BotonApp(texto: 'Aceptar', tipo: tipo, alPresionar: habilitado ? () {} : null),
        brillo: brillo,
      );
      final deco = decoracionBoton(tester);
      expect(deco.color, fondo, reason: '$tipo $habilitado');
      expect(tester.widget<Text>(find.text('Aceptar')).style!.color, texto);
      expect(tester.getSize(find.byType(BotonApp)).height, BotonApp.alto);
      esperarSoloColoresDelTema(tester, brillo);
    }
  });

  testWidgets('primario, acento y peligro llevan sombra sólida; secundario lleva borde 2', (
    tester,
  ) async {
    await montar(tester, BotonApp(texto: 'A', alPresionar: () {}));
    final sombra = decoracionBoton(tester).boxShadow!.single;
    expect(sombra.offset, const Offset(0, 4));
    expect(sombra.blurRadius, 0);
    expect(sombra.color.toARGB32(), 0x2E0F294A);

    await montar(tester, BotonApp(texto: 'A', tipo: TipoBoton.secundario, alPresionar: () {}));
    final deco = decoracionBoton(tester);
    expect(deco.boxShadow, isNull);
    expect((deco.border! as Border).top.width, 2);
  });

  testWidgets('al presionar baja 2 dp y la sombra pasa a 2', (tester) async {
    await montar(tester, BotonApp(texto: 'A', alPresionar: () {}), reducirAnimaciones: true);
    final gesto = await tester.startGesture(tester.getCenter(find.byType(BotonApp)));
    await tester.pump();
    expect(decoracionBoton(tester).boxShadow!.single.offset, const Offset(0, 2));
    await gesto.up();
    await tester.pump();
    expect(decoracionBoton(tester).boxShadow!.single.offset, const Offset(0, 4));
  });

  testWidgets('llama a alPresionar al tocar y no lo hace deshabilitado', (tester) async {
    var toques = 0;
    await montar(tester, BotonApp(texto: 'A', alPresionar: () => toques++));
    await tester.tap(find.byType(BotonApp));
    expect(toques, 1);

    await montar(tester, const BotonApp(texto: 'A', alPresionar: null));
    await tester.tap(find.byType(BotonApp));
    expect(toques, 1);
  });

  testWidgets('semántica: botón con el texto visible y estado deshabilitado', (tester) async {
    final semantica = tester.ensureSemantics();
    await montar(tester, BotonApp(texto: 'Comenzar sprint', alPresionar: () {}));
    expect(
      tester.getSemantics(find.byType(BotonApp)),
      isSemantics(label: 'Comenzar sprint', isButton: true, isEnabled: true, hasTapAction: true),
    );
    await montar(tester, const BotonApp(texto: 'Siguiente', alPresionar: null));
    expect(
      tester.getSemantics(find.byType(BotonApp)),
      isSemantics(label: 'Siguiente', isButton: true, isEnabled: false),
    );
    semantica.dispose();
  });

  testWidgets('con teclado muestra el anillo de foco y Enter lo activa', (tester) async {
    var toques = 0;
    await montar(
      tester,
      BotonApp(texto: 'A', iconoInicio: IconosApp.back, alPresionar: () => toques++),
    );
    expect(find.byKey(const ValueKey('anillo-foco')), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(find.byKey(const ValueKey('anillo-foco')), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(toques, 1);
  });

  testWidgets('con texto al 200 % no se desborda', (tester) async {
    await montar(
      tester,
      BotonApp(texto: 'Comenzar sprint ahora mismo', alPresionar: () {}),
      escalaTexto: 2,
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(BotonApp)).height, greaterThanOrEqualTo(BotonApp.alto));
  });
}
