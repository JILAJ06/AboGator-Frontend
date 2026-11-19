import 'package:abogator/componentes/barra_juego.dart';
import 'package:abogator/componentes/indicadores_startup.dart';
import 'package:abogator/componentes/tarjeta_caso.dart';
import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:abogator/funciones/juego/pantalla_juego.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'ayudante_juego.dart';

void main() {
  testWidgets('muestra la barra, los indicadores, la tarjeta y las acciones', (tester) async {
    await abrirJuego(tester);
    expect(find.byType(PantallaJuego), findsOneWidget);
    expect(find.byType(BarraJuego), findsOneWidget);
    expect(find.text('Sprint 3 · Tarjeta 1 de 10'), findsOneWidget);
    expect(find.byType(IndicadoresStartup), findsOneWidget);
    expect(find.byType(TarjetaCaso), findsOneWidget);
    expect(textoActual(tester), MockTarjetas.tarjetasPorSprint[sprintMock]!.first.texto);
    expect(tester.takeException(), isNull);
  });
}
