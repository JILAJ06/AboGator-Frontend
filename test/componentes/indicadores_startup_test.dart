import 'package:abogator/componentes/impacto_startup.dart';
import 'package:abogator/componentes/indicadores_startup.dart';
import 'package:abogator/datos/modelos/estado_startup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

const ejemplo = EstadoStartup(presupuesto: 70, reputacion: 60, velocidad: 50, riesgoLegal: 25);

void main() {
  enAmbosModos('los rellenos miden valor × 68 / 100 con el color de cada indicador', (
    tester,
    brillo,
  ) async {
    await montar(
      tester,
      const SizedBox(width: 342, child: IndicadoresStartup(estado: ejemplo)),
      brillo: brillo,
    );
    final t = tokensDe(brillo);
    final esperados = {
      t.accionAcento: 70 * 68 / 100,
      t.estadoCondicional: 60 * 68 / 100,
      t.estadoLegal: 50 * 68 / 100,
      t.estadoIlegal: 25 * 68 / 100,
    };
    for (final MapEntry(key: color, value: ancho) in esperados.entries) {
      final relleno = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).color == color,
      );
      expect(tester.getSize(relleno).width, closeTo(ancho, 0.01));
      expect(tester.getSize(relleno).height, IndicadoresStartup.altoBarra);
    }
    esperarSoloColoresDelTema(tester, brillo);
  });

  testWidgets('semántica por barra', (tester) async {
    final semantica = tester.ensureSemantics();
    await montar(tester, const SizedBox(width: 342, child: IndicadoresStartup(estado: ejemplo)));
    for (final etiqueta in [
      'Presupuesto 70 %',
      'Reputación 60 %',
      'Velocidad 50 %',
      'Riesgo legal 25 %',
    ]) {
      expect(find.bySemanticsLabel(etiqueta), findsOneWidget);
    }
    semantica.dispose();
  });

  testWidgets('con texto al 200 % no se desborda', (tester) async {
    await montar(
      tester,
      const SizedBox(width: 342, child: IndicadoresStartup(estado: ejemplo)),
      escalaTexto: 2,
    );
    expect(tester.takeException(), isNull);
  });

  enAmbosModos('impacto: solo los que cambian, con signo y color', (tester, brillo) async {
    final semantica = tester.ensureSemantics();
    await montar(
      tester,
      const ImpactoStartup(
        cambios: {
          IndicadorStartup.presupuesto: -5,
          IndicadorStartup.velocidad: 0,
          IndicadorStartup.riesgoLegal: 10,
        },
      ),
      brillo: brillo,
    );
    expect(find.text('Impacto:'), findsOneWidget);
    expect(find.text('−5'), findsOneWidget);
    expect(find.text('+10'), findsOneWidget);
    expect(find.text('+0'), findsNothing);
    expect(tester.widget<Text>(find.text('+10')).style!.color, tokensDe(brillo).estadoIlegal);
    expect(find.bySemanticsLabel('Riesgo legal +10'), findsOneWidget);
    semantica.dispose();
  });
}
