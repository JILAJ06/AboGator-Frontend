import 'package:abogator/componentes/navegacion_inferior_app.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

void main() {
  enAmbosModos('la pestaña activa usa fondo/destacado y accion/primaria', (tester, brillo) async {
    await montar(
      tester,
      NavegacionInferiorApp(actual: PestanaApp.buzon, alSeleccionar: (_) {}),
      brillo: brillo,
    );
    final t = tokensDe(brillo);
    for (final nombre in ['Mapa', 'Buzón', 'Tienda', 'Perfil']) {
      expect(find.text(nombre), findsOneWidget);
    }
    expect(tester.widget<Text>(find.text('Buzón')).style!.color, t.accionPrimaria);
    expect(tester.widget<Text>(find.text('Mapa')).style!.color, t.textoSecundario);
    final activo = find.ancestor(of: find.text('Buzón'), matching: find.byType(Container)).first;
    expect((tester.widget<Container>(activo).decoration! as BoxDecoration).color, t.fondoDestacado);
    esperarSoloColoresDelTema(tester, brillo);
  });

  testWidgets('cada pestaña tiene zona táctil ≥ 48 y avisa al tocarla', (tester) async {
    PestanaApp? elegida;
    await montar(
      tester,
      NavegacionInferiorApp(actual: PestanaApp.mapa, alSeleccionar: (p) => elegida = p),
    );
    for (final nombre in ['Mapa', 'Buzón', 'Tienda', 'Perfil']) {
      final zona = find.ancestor(of: find.text(nombre), matching: find.byType(Container)).first;
      final tamano = tester.getSize(zona);
      expect(tamano.width, greaterThanOrEqualTo(48));
      expect(tamano.height, greaterThanOrEqualTo(48));
    }
    await tester.tap(find.text('Tienda'));
    expect(elegida, PestanaApp.tienda);
  });

  testWidgets('el contenido mide al menos 58 y respeta la zona segura', (tester) async {
    await montar(tester, NavegacionInferiorApp(actual: PestanaApp.mapa, alSeleccionar: (_) {}));
    final sinZona = tester.getSize(find.byType(NavegacionInferiorApp)).height;
    expect(sinZona, greaterThanOrEqualTo(NavegacionInferiorApp.altoContenido));

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(padding: EdgeInsets.only(bottom: 26)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Theme(
            data: Theme.of(tester.element(find.byType(NavegacionInferiorApp))),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: NavegacionInferiorApp(actual: PestanaApp.mapa, alSeleccionar: (_) {}),
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(NavegacionInferiorApp)).height, sinZona + 26);
  });

  testWidgets('semántica: "Pestaña Mapa, 1 de 4" seleccionada', (tester) async {
    final semantica = tester.ensureSemantics();
    await montar(tester, NavegacionInferiorApp(actual: PestanaApp.mapa, alSeleccionar: (_) {}));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Pestaña Mapa, 1 de 4')),
      isSemantics(isSelected: true, isButton: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Pestaña Perfil, 4 de 4')),
      isSemantics(isSelected: false),
    );
    semantica.dispose();
  });

  testWidgets('con teclado se ve el anillo de foco', (tester) async {
    await montar(tester, NavegacionInferiorApp(actual: PestanaApp.mapa, alSeleccionar: (_) {}));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(find.byKey(const ValueKey('anillo-foco')), findsOneWidget);
  });
}
