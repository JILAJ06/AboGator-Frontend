import 'package:abogator/componentes/boton_veredicto.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

void main() {
  enAmbosModos('los 4 tipos: círculo de 68, borde 3 y etiqueta en el color del estado', (
    tester,
    brillo,
  ) async {
    final t = tokensDe(brillo);
    final esperados = {
      Veredicto.ilegal: ('ILEGAL', t.estadoIlegal),
      Veredicto.legal: ('LEGAL', t.estadoLegal),
      Veredicto.condicional: ('CONDICIONAL', t.estadoCondicional),
      Veredicto.escalar: ('ESCALAR', t.estadoEscalar),
    };
    for (final MapEntry(key: v, value: (etiqueta, color)) in esperados.entries) {
      await montar(tester, BotonVeredicto(veredicto: v), brillo: brillo);
      final circulo = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).shape == BoxShape.circle,
      );
      expect(tester.getSize(circulo), const Size.square(BotonVeredicto.diametro));
      final deco = tester.widget<Container>(circulo).decoration! as BoxDecoration;
      expect((deco.border! as Border).top.width, 3);
      expect((deco.border! as Border).top.color, color);
      expect(deco.color, t.fondoSuperficie);
      expect(tester.widget<Text>(find.text(etiqueta)).style!.color, color);
      expect(tester.widget<Icon>(find.byType(Icon)).size, BotonVeredicto.tamanoIcono);
      esperarSoloColoresDelTema(tester, brillo);
    }
  });

  testWidgets('la columna de Condicional mide al menos 87', (tester) async {
    await montar(tester, const BotonVeredicto(veredicto: Veredicto.condicional));
    expect(
      tester.getSize(find.byType(BotonVeredicto)).width,
      greaterThanOrEqualTo(BotonVeredicto.anchoCondicional),
    );
  });

  testWidgets('sin alPresionar es decorativo y no se anuncia', (tester) async {
    final semantica = tester.ensureSemantics();
    await montar(tester, const BotonVeredicto(veredicto: Veredicto.legal));
    expect(find.bySemanticsLabel('Veredicto: Legal'), findsNothing);
    expect(find.bySemanticsLabel('LEGAL'), findsNothing);
    semantica.dispose();
  });

  testWidgets('con alPresionar: botón con nombre accesible y zona táctil completa', (tester) async {
    final semantica = tester.ensureSemantics();
    var toques = 0;
    await montar(
      tester,
      BotonVeredicto(veredicto: Veredicto.condicional, alPresionar: () => toques++),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Veredicto: Legal con condiciones')),
      isSemantics(isButton: true, hasTapAction: true),
    );
    await tester.tap(find.text('CONDICIONAL'));
    expect(toques, 1);
    semantica.dispose();
  });

  testWidgets('con teclado muestra el anillo de foco y Enter lo activa', (tester) async {
    var toques = 0;
    await montar(tester, BotonVeredicto(veredicto: Veredicto.escalar, alPresionar: () => toques++));
    expect(find.byKey(const ValueKey('anillo-foco')), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(find.byKey(const ValueKey('anillo-foco')), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(toques, 1);
  });
}
