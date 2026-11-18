import 'package:abogator/componentes/anillo_foco.dart';
import 'package:abogator/componentes/barra_progreso.dart';
import 'package:abogator/componentes/paginador_puntos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

void main() {
  enAmbosModos('barra: alto 12 y relleno proporcional', (tester, brillo) async {
    await montar(
      tester,
      const SizedBox(
        width: 240,
        child: BarraProgreso(valor: 0.5, etiquetaSemantica: 'Tarjeta 5 de 10'),
      ),
      brillo: brillo,
    );
    expect(tester.getSize(find.byType(BarraProgreso)).height, BarraProgreso.alto);
    expect(tester.getSize(find.byKey(const ValueKey('relleno-progreso'))).width, 120);
    esperarSoloColoresDelTema(tester, brillo);
  });

  testWidgets('barra: sin animación con "reducir animaciones"', (tester) async {
    Widget barra(double valor) => SizedBox(
      width: 240,
      child: BarraProgreso(valor: valor, etiquetaSemantica: 'x'),
    );
    await montar(tester, barra(0.1), reducirAnimaciones: true);
    await montar(tester, barra(0.8), reducirAnimaciones: true);
    expect(
      tester.widget<AnimatedContainer>(find.byKey(const ValueKey('relleno-progreso'))).duration,
      Duration.zero,
    );
  });

  testWidgets('barra: semántica de progreso', (tester) async {
    final semantica = tester.ensureSemantics();
    await montar(
      tester,
      const SizedBox(
        width: 240,
        child: BarraProgreso(valor: 0.5, etiquetaSemantica: 'Tarjeta 5 de 10'),
      ),
    );
    expect(
      tester.getSemantics(find.byType(BarraProgreso)),
      isSemantics(label: 'Tarjeta 5 de 10', value: '50 %'),
    );
    semantica.dispose();
  });

  enAmbosModos('paginador: activo 28×8 en accion/primaria e inactivos 8×8', (tester, brillo) async {
    await montar(tester, const PaginadorPuntos(total: 4, actual: 1), brillo: brillo);
    expect(tester.getSize(find.byType(PaginadorPuntos)), const Size(76, 8));
    final puntos = tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
        .map((c) => (c.decoration! as BoxDecoration).color)
        .toList();
    final t = tokensDe(brillo);
    expect(puntos, [t.bordeControl, t.accionPrimaria, t.bordeControl, t.bordeControl]);
    esperarSoloColoresDelTema(tester, brillo);
  });

  testWidgets('paginador: semántica "Página 2 de 4"', (tester) async {
    final semantica = tester.ensureSemantics();
    await montar(tester, const PaginadorPuntos(total: 4, actual: 1));
    expect(find.bySemanticsLabel('Página 2 de 4'), findsOneWidget);
    semantica.dispose();
  });

  enAmbosModos('anillo de foco: 3 en foco/anillo a 5 del control', (tester, brillo) async {
    await montar(
      tester,
      const AnilloFoco(visible: true, radio: 16, child: SizedBox(width: 100, height: 52)),
      brillo: brillo,
    );
    final anillo = find.byKey(const ValueKey('anillo-foco'));
    expect(tester.getSize(anillo), const Size(110, 62));
    final deco = tester.widget<DecoratedBox>(anillo).decoration as BoxDecoration;
    expect((deco.border! as Border).top.width, 3);
    expect((deco.border! as Border).top.color, tokensDe(brillo).focoAnillo);
    expect(deco.borderRadius, BorderRadius.circular(21));
    expect(tester.getSize(find.byType(AnilloFoco)), const Size(100, 52));
  });

  testWidgets('anillo de foco oculto no pinta nada', (tester) async {
    await montar(
      tester,
      const AnilloFoco(visible: false, radio: 16, child: SizedBox(width: 100, height: 52)),
    );
    expect(find.byKey(const ValueKey('anillo-foco')), findsNothing);
  });
}
