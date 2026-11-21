import 'package:abogator/componentes/navegacion_inferior_app.dart';
import 'package:abogator/componentes/riel_navegacion.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';
import '../ayudantes/tamano_pantalla.dart';

class RegistroRiel {
  final destinos = <PestanaApp>[];
  int ajustes = 0;
  int perfil = 0;
}

Future<RegistroRiel> montarRiel(
  WidgetTester tester, {
  PestanaApp? actual = PestanaApp.mapa,
  int? pendientes = 6,
  Brightness brillo = Brightness.light,
  double escalaTexto = 1,
  double alto = 760,
}) async {
  await tamanoPantalla(tester, Tamano.tabletHorizontal);
  final registro = RegistroRiel();
  await montar(
    tester,
    SizedBox(
      height: alto,
      child: RielNavegacion(
        actual: actual,
        pendientes: pendientes,
        iniciales: 'AL',
        nombreUsuario: 'Ana López',
        alSeleccionar: registro.destinos.add,
        alAjustes: () => registro.ajustes++,
        alPerfil: () => registro.perfil++,
      ),
    ),
    brillo: brillo,
    escalaTexto: escalaTexto,
  );
  return registro;
}

Finder destino(PestanaApp p) => find.byKey(ValueKey('riel-${p.name}'));

void main() {
  testWidgets('medidas de Figma: riel de 104, destinos de 80×72, botones de 48', (tester) async {
    await montarRiel(tester);
    expect(tester.getSize(find.byType(RielNavegacion)).width, 104);
    for (final p in PestanaApp.values) {
      final caja = find.descendant(of: destino(p), matching: find.byType(ConstrainedBox)).first;
      expect(tester.getSize(caja), const Size(80, 72), reason: p.name);
      expect(tester.getSize(find.byKey(ValueKey('indicador-${p.name}'))), const Size(56, 32));
    }
    expect(tester.getSize(find.byKey(const ValueKey('isotipo-riel'))).width, 56);
    expect(tester.getSize(find.byKey(const ValueKey('riel-ajustes'))), const Size(48, 48));
    expect(tester.getSize(find.byKey(const ValueKey('riel-avatar'))), const Size(48, 48));
    expect(find.text('AL'), findsOneWidget);

    // Orden vertical: isotipo, destinos, espacio flexible, Ajustes y avatar abajo.
    final yMapa = tester.getTopLeft(destino(PestanaApp.mapa)).dy;
    final yBuzon = tester.getTopLeft(destino(PestanaApp.buzon)).dy;
    expect(yBuzon - yMapa, 72 + 8);
    final abajo = tester.getBottomLeft(find.byKey(const ValueKey('riel-avatar'))).dy;
    final rielAbajo = tester.getBottomLeft(find.byType(RielNavegacion)).dy;
    expect(rielAbajo - abajo, 24);
  });

  testWidgets('el destino activo tiene fondo, etiqueta en negrita y "seleccionado"', (
    tester,
  ) async {
    await montarRiel(tester, actual: PestanaApp.tienda);
    final manejador = tester.ensureSemantics();
    expect(
      tester.getSemantics(destino(PestanaApp.tienda)),
      matchesSemantics(
        label: Textos.pestanaTienda,
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    final indicador = tester.widget<Container>(find.byKey(const ValueKey('indicador-tienda')));
    expect((indicador.decoration! as BoxDecoration).color, isNotNull);
    final inactivo = tester.widget<Container>(find.byKey(const ValueKey('indicador-mapa')));
    expect((inactivo.decoration! as BoxDecoration).color, isNull);

    final activo = tester.widget<Text>(find.text(Textos.pestanaTienda));
    final otro = tester.widget<Text>(find.text(Textos.pestanaMapa));
    expect(activo.style!.fontWeight, FontWeight.w600);
    expect(activo.style!.fontSize, 12);
    expect(otro.style!.fontWeight, FontWeight.w500);
    expect(otro.style!.fontSize, 11);
    manejador.dispose();
  });

  group('insignia del Buzón', () {
    for (final (cantidad, texto) in [(6, '6'), (1, '1'), (100, '99+'), (99, '99')]) {
      testWidgets('$cantidad → "$texto"', (tester) async {
        await montarRiel(tester, pendientes: cantidad);
        final insignia = find.byKey(const ValueKey('insignia-riel'));
        expect(find.descendant(of: insignia, matching: find.text(texto)), findsOneWidget);
        expect(find.bySemanticsLabel(Textos.rielBuzonSemantica(cantidad)), findsOneWidget);
      });
    }

    testWidgets('se oculta con 0 o sin dato', (tester) async {
      await montarRiel(tester, pendientes: 0);
      expect(find.byKey(const ValueKey('insignia-riel')), findsNothing);
      await montarRiel(tester, pendientes: null);
      expect(find.byKey(const ValueKey('insignia-riel')), findsNothing);
      expect(find.bySemanticsLabel(Textos.pestanaBuzon), findsOneWidget);
    });

    testWidgets('queda a 50 del borde izquierdo y 8 arriba del destino', (tester) async {
      await montarRiel(tester);
      final origen = tester.getTopLeft(destino(PestanaApp.buzon));
      final insignia = tester.getTopLeft(find.byKey(const ValueKey('insignia-riel')));
      expect(insignia - origen, const Offset(50, 8));
      expect(tester.getSize(find.byKey(const ValueKey('insignia-riel'))), const Size(20, 20));
    });

    test('textos del lector', () {
      expect(Textos.rielBuzonSemantica(6), 'Buzón, 6 apelaciones pendientes');
      expect(Textos.rielBuzonSemantica(1), 'Buzón, 1 apelación pendiente');
      expect(Textos.rielBuzonSemantica(0), 'Buzón');
    });
  });

  testWidgets('cada destino, Ajustes y el avatar avisan al tocarlos', (tester) async {
    final registro = await montarRiel(tester);
    for (final p in PestanaApp.values) {
      await tester.tap(destino(p));
    }
    await tester.tap(find.byKey(const ValueKey('riel-ajustes')));
    await tester.tap(find.byKey(const ValueKey('riel-avatar')));
    expect(registro.destinos, PestanaApp.values);
    expect(registro.ajustes, 1);
    expect(registro.perfil, 1);
    expect(find.bySemanticsLabel(Textos.rielAjustes), findsOneWidget);
    expect(find.bySemanticsLabel(Textos.rielAvatar('Ana López')), findsOneWidget);
  });

  testWidgets('con teclado: Tab recorre destinos, Ajustes y avatar; Enter activa', (tester) async {
    final registro = await montarRiel(tester);
    for (var i = 0; i < PestanaApp.values.length + 2; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    }
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(registro.perfil, 1);
  });

  enAmbosModos('solo usa colores del tema', (tester, brillo) async {
    await montarRiel(tester, brillo: brillo);
    esperarSoloColoresDelTema(tester, brillo);
  });

  enAmbosModos('contraste AA de etiquetas e insignia', (tester, brillo) async {
    final t = tokensDe(brillo);
    expect(Contraste.razon(t.textoPrimario, t.fondoDestacado), greaterThanOrEqualTo(4.5));
    expect(Contraste.razon(t.textoSecundario, t.fondoSuperficie), greaterThanOrEqualTo(4.5));
    expect(Contraste.razon(t.textoPrimario, t.fondoSuperficie), greaterThanOrEqualTo(4.5));
    expect(Contraste.razon(t.textoEnPrimario, t.estadoIlegal), greaterThanOrEqualTo(4.5));
  });

  for (final alto in [760.0, 600.0]) {
    testWidgets('texto al 200 % sin desbordes (alto $alto)', (tester) async {
      await montarRiel(tester, escalaTexto: 2, alto: alto);
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(RielNavegacion)).width, 104);
    });
  }
}
