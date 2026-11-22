import 'package:abogator/componentes/agarre_hoja.dart';
import 'package:abogator/componentes/aviso_snack.dart';
import 'package:abogator/componentes/boton_icono_caja.dart';
import 'package:abogator/componentes/pildora.dart';
import 'package:abogator/core/tema/iconos_app.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

BoxDecoration _decoracion(WidgetTester tester, Finder f) =>
    tester.widget<Container>(f).decoration! as BoxDecoration;

void main() {
  for (final brillo in Brightness.values) {
    final tokens = brillo == Brightness.light ? TokensColor.claro : TokensColor.oscuro;

    group('Piezas pequeñas (${brillo.name})', () {
      testWidgets('AgarreHoja mide 40 × 5, radio 3, borde/default y no se anuncia', (tester) async {
        final semantica = tester.ensureSemantics();
        await montar(tester, const AgarreHoja(), brillo: brillo);
        final agarre = find.byKey(const ValueKey('agarre'));
        expect(tester.getSize(agarre), const Size(40, 5));
        final d = _decoracion(tester, agarre);
        expect(d.color, tokens.bordeDefault);
        expect(d.borderRadius, BorderRadius.circular(3));
        expect(
          find.descendant(of: find.byType(AgarreHoja), matching: find.byType(ExcludeSemantics)),
          findsOneWidget,
        );
        semantica.dispose();
      });

      testWidgets('BotonIconoCaja: 48 × 48, radio 12, superficie y borde; botón con etiqueta', (
        tester,
      ) async {
        final semantica = tester.ensureSemantics();
        var veces = 0;
        await montar(
          tester,
          BotonIconoCaja(
            claveCaja: const ValueKey('caja'),
            icono: IconosApp.back,
            etiqueta: 'Volver',
            alPresionar: () => veces++,
          ),
          brillo: brillo,
        );
        final caja = find.byKey(const ValueKey('caja'));
        expect(tester.getSize(caja), const Size(48, 48));
        final d = _decoracion(tester, caja);
        expect(d.color, tokens.fondoSuperficie);
        expect(d.borderRadius, BorderRadius.circular(12));
        expect(d.border, Border.all(color: tokens.bordeDefault));
        expect(
          tester.getSemantics(find.byType(BotonIconoCaja)),
          isSemantics(label: 'Volver', isButton: true, hasTapAction: true),
        );
        await tester.tap(caja);
        expect(veces, 1);
        // Con teclado: Tab lo enfoca y Enter lo activa.
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(veces, 2);
        semantica.dispose();
      });

      testWidgets('BotonIconoCaja acepta otro fondo, sin borde y un hijo en lugar del ícono', (
        tester,
      ) async {
        await montar(
          tester,
          BotonIconoCaja(
            claveCaja: const ValueKey('caja'),
            etiqueta: 'Más',
            alPresionar: () {},
            fondo: tokens.fondoDestacado,
            conBorde: false,
            hijo: const Text('+'),
          ),
          brillo: brillo,
        );
        final d = _decoracion(tester, find.byKey(const ValueKey('caja')));
        expect(d.color, tokens.fondoDestacado);
        expect(d.border, isNull);
        expect(find.text('+'), findsOneWidget);
      });

      testWidgets('Pildora: radio 999, fondo, relleno, borde, sombra y alto mínimo', (
        tester,
      ) async {
        await montar(
          tester,
          Pildora(
            clave: const ValueKey('pildora'),
            fondo: tokens.fondoDestacado,
            relleno: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            borde: Border.all(color: tokens.bordeDefault),
            sombra: const [BoxShadow(blurRadius: 4)],
            altoMinimo: 48,
            child: const Text('Píldora'),
          ),
          brillo: brillo,
        );
        final f = find.byKey(const ValueKey('pildora'));
        final c = tester.widget<Container>(f);
        expect(c.padding, const EdgeInsets.symmetric(horizontal: 12, vertical: 6));
        final d = c.decoration! as BoxDecoration;
        expect(d.color, tokens.fondoDestacado);
        expect(d.borderRadius, BorderRadius.circular(999));
        expect(d.border, Border.all(color: tokens.bordeDefault));
        expect(d.boxShadow, const [BoxShadow(blurRadius: 4)]);
        expect(tester.getSize(f).height, greaterThanOrEqualTo(48));
      });
    });
  }

  testWidgets('mostrarAviso muestra el SnackBar con su clave, en región en vivo, y reemplaza el '
      'anterior', (tester) async {
    final semantica = tester.ensureSemantics();
    await montar(
      tester,
      Builder(
        builder: (context) => Column(
          children: [
            TextButton(
              onPressed: () => mostrarAviso(context, 'Primero', clave: const ValueKey('a')),
              child: const Text('uno'),
            ),
            TextButton(
              onPressed: () => mostrarAvisoEn(
                ScaffoldMessenger.of(context),
                'Segundo',
                clave: const ValueKey('b'),
              ),
              child: const Text('dos'),
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('uno'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('a')), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Primero')),
      isSemantics(label: 'Primero', isLiveRegion: true),
    );
    await tester.tap(find.text('dos'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('a')), findsNothing);
    expect(find.byKey(const ValueKey('b')), findsOneWidget);
    semantica.dispose();
  });
}
