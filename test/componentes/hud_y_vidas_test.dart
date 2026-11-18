import 'package:abogator/componentes/chip_hud.dart';
import 'package:abogator/componentes/corazon_vida.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

void main() {
  enAmbosModos('los 5 chips muestran su valor y usan el tema', (tester, brillo) async {
    await montar(
      tester,
      Wrap(
        children: [
          ChipHud.vidas(4),
          ChipHud.monedas(240),
          ChipHud.racha(7),
          ChipHud.comodines(3),
          ChipHud.amparo(1),
        ],
      ),
      brillo: brillo,
    );
    for (final valor in ['4', '240', '7', '3', '1']) {
      expect(find.text(valor), findsOneWidget);
    }
    esperarSoloColoresDelTema(tester, brillo);
  });

  testWidgets('semántica de los chips', (tester) async {
    final semantica = tester.ensureSemantics();
    await montar(
      tester,
      Wrap(children: [ChipHud.vidas(4), ChipHud.monedas(240), ChipHud.racha(7)]),
    );
    expect(find.bySemanticsLabel('Vidas: 4 de 5'), findsOneWidget);
    expect(find.bySemanticsLabel('240 monedas'), findsOneWidget);
    expect(find.bySemanticsLabel('Racha de 7 días'), findsOneWidget);
    semantica.dispose();
  });

  enAmbosModos('el chip Amparo lleva borde 1.5 accion/secundaria', (tester, brillo) async {
    await montar(tester, ChipHud.amparo(1), brillo: brillo);
    final deco =
        tester
                .widgetList<DecoratedBox>(
                  find.descendant(of: find.byType(ChipHud), matching: find.byType(DecoratedBox)),
                )
                .first
                .decoration
            as BoxDecoration;
    final borde = (deco.border! as Border).top;
    expect(borde.width, 1.5);
    expect(borde.color, tokensDe(brillo).accionSecundaria);
  });

  enAmbosModos('fila de vidas: llenos en estado/ilegal y vacíos en borde/control', (
    tester,
    brillo,
  ) async {
    await montar(tester, const FilaVidas(cantidad: 3), brillo: brillo);
    final pintores = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((c) => c.painter)
        .whereType<PintorCorazon>()
        .toList();
    expect(pintores, hasLength(5));
    final t = tokensDe(brillo);
    expect(pintores.where((p) => p.relleno && p.color == t.estadoIlegal), hasLength(3));
    expect(pintores.where((p) => !p.relleno && p.color == t.bordeControl), hasLength(2));
    esperarSoloColoresDelTema(tester, brillo);
  });

  testWidgets('el tamaño del corazón es parámetro y la fila tiene semántica', (tester) async {
    final semantica = tester.ensureSemantics();
    await montar(tester, const FilaVidas(cantidad: 2, tamano: 33.6, hueco: 11.2));
    expect(tester.getSize(find.byType(CorazonVida).first), const Size.square(33.6));
    expect(find.bySemanticsLabel('Vidas: 2 de 5'), findsOneWidget);
    semantica.dispose();
  });
}
