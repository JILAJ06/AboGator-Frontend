import 'package:abogator/componentes/bloque_lectura.dart';
import 'package:abogator/componentes/caja_superficie.dart';
import 'package:abogator/componentes/esqueleto_pantalla.dart';
import 'package:abogator/componentes/mensaje_pantalla.dart';
import 'package:abogator/componentes/titulo_enfocado.dart';
import 'package:abogator/componentes/vista_asincrona.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

BoxDecoration _decoracion(WidgetTester tester, Finder f) =>
    tester.widget<Container>(f).decoration! as BoxDecoration;

const _datos = Text('datos', key: ValueKey('vista-datos'));
const _esqueleto = SizedBox(key: ValueKey('vista-esqueleto'));

Widget _vista(AsyncValue<int> valor, {bool conservar = false, VoidCallback? reintentar}) =>
    SizedBox(
      width: 342,
      height: 400,
      child: VistaAsincrona<int>(
        valor: valor,
        conservarValor: conservar,
        datos: (_) => _datos,
        esqueleto: _esqueleto,
        textoError: 'Falló',
        alReintentar: reintentar ?? () {},
      ),
    );

var _falla = false;
final _proveedor = FutureProvider<int>(retry: (_, _) => null, (ref) async {
  if (_falla) throw Exception('falla');
  return 1;
});

/// Un error que conserva el valor anterior, como lo deja Riverpod al recargar.
Future<AsyncValue<int>> _errorConValorPrevio() async {
  _falla = false;
  final contenedor = ProviderContainer();
  addTearDown(contenedor.dispose);
  final sub = contenedor.listen(_proveedor, (_, _) {});
  addTearDown(sub.close);
  await contenedor.read(_proveedor.future);
  _falla = true;
  contenedor.invalidate(_proveedor);
  await expectLater(contenedor.read(_proveedor.future), throwsException);
  return contenedor.read(_proveedor);
}

void main() {
  for (final brillo in Brightness.values) {
    final tokens = brillo == Brightness.light ? TokensColor.claro : TokensColor.oscuro;

    group('Superficies (${brillo.name})', () {
      testWidgets('CajaSuperficie: tres fondos, radio y borde opcional en la caja con la clave', (
        tester,
      ) async {
        await montar(
          tester,
          const Column(
            children: [
              CajaSuperficie(clave: ValueKey('a'), ancho: 80, alto: 40, conBorde: true),
              CajaSuperficie(clave: ValueKey('b'), alto: 40, fondo: FondoCaja.superficieAlt),
              CajaSuperficie(
                clave: ValueKey('c'),
                alto: 40,
                fondo: FondoCaja.destacado,
                radio: 22,
                relleno: EdgeInsets.all(8),
              ),
            ],
          ),
          brillo: brillo,
        );
        final a = _decoracion(tester, find.byKey(const ValueKey('a')));
        expect(a.color, tokens.fondoSuperficie);
        expect(a.borderRadius, BorderRadius.circular(16));
        expect(a.border, Border.all(color: tokens.bordeDefault));
        expect(tester.getSize(find.byKey(const ValueKey('a'))), const Size(80, 40));
        final b = _decoracion(tester, find.byKey(const ValueKey('b')));
        expect(b.color, tokens.fondoSuperficieAlt);
        expect(b.border, isNull);
        final c = tester.widget<Container>(find.byKey(const ValueKey('c')));
        expect((c.decoration! as BoxDecoration).color, tokens.fondoDestacado);
        expect((c.decoration! as BoxDecoration).borderRadius, BorderRadius.circular(22));
        expect(c.padding, const EdgeInsets.all(8));
      });

      testWidgets('TarjetaLista: borde, recorte y un divisor de 1 entre filas', (tester) async {
        await montar(
          tester,
          const SizedBox(
            width: 342,
            child: TarjetaLista(
              clave: ValueKey('lista'),
              radio: 20,
              filas: [Text('uno'), Text('dos'), Text('tres')],
            ),
          ),
          brillo: brillo,
        );
        final caja = tester.widget<Container>(find.byKey(const ValueKey('lista')));
        expect(caja.clipBehavior, Clip.antiAlias);
        final d = caja.decoration! as BoxDecoration;
        expect(d.borderRadius, BorderRadius.circular(20));
        expect(d.border, Border.all(color: tokens.bordeDefault));
        final divisores = tester.widgetList<Divider>(find.byType(Divider)).toList();
        expect(divisores, hasLength(2));
        for (final dv in divisores) {
          expect((dv.height, dv.thickness, dv.color), (1.0, 1.0, tokens.bordeDefault));
        }
      });

      testWidgets('EsqueletoPantalla: región en vivo con su etiqueta, sin leer los bloques', (
        tester,
      ) async {
        final semantica = tester.ensureSemantics();
        await montar(
          tester,
          const SizedBox(
            width: 342,
            child: EsqueletoPantalla(
              etiqueta: 'Cargando',
              clave: ValueKey('esqueleto-prueba'),
              relleno: EdgeInsets.all(12),
              hijos: [BloqueEsqueleto(40, ancho: 120, radio: 8), BloqueEsqueleto(60)],
            ),
          ),
          brillo: brillo,
        );
        expect(find.byKey(const ValueKey('esqueleto-prueba')), findsOneWidget);
        expect(
          tester.getSemantics(find.byType(EsqueletoPantalla)),
          isSemantics(label: 'Cargando', isLiveRegion: true),
        );
        final bloques = find.byType(BloqueEsqueleto);
        expect(tester.getSize(bloques.first), const Size(120, 40));
        final d = _decoracion(
          tester,
          find.descendant(of: bloques.first, matching: find.byType(Container)),
        );
        expect(d.color, tokens.fondoSuperficieAlt);
        expect(d.borderRadius, BorderRadius.circular(8));
        semantica.dispose();
      });

      testWidgets('TituloEnfocado: encabezado H1 con foco inicial; estilo, color y alineación', (
        tester,
      ) async {
        final semantica = tester.ensureSemantics();
        await montar(
          tester,
          const Column(
            children: [
              TituloEnfocado('Título', clave: ValueKey('titulo')),
              TituloEnfocado(
                'Otro',
                autofocus: false,
                enVivo: true,
                color: Color(0xFF123456),
                alineacion: TextAlign.center,
              ),
            ],
          ),
          brillo: brillo,
        );
        await tester.pump();
        final bloque = tester.widget<BloqueLectura>(find.byKey(const ValueKey('titulo')));
        expect((bloque.encabezado, bloque.autofocus, bloque.radio), (true, true, 8.0));
        expect(
          tester
              .getSemantics(find.byKey(const ValueKey('titulo')))
              .getSemanticsData()
              .flagsCollection
              .isHeader,
          isTrue,
        );
        expect(Focus.of(tester.element(find.text('Título'))).hasFocus, isTrue);
        // El foco inicial queda dentro del título.
        final enfocado = FocusManager.instance.primaryFocus!.context!.widget;
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('titulo')),
            matching: find.byWidget(enfocado),
          ),
          findsOneWidget,
        );
        final texto = tester.widget<Text>(find.text('Título'));
        expect(texto.style!.color, tokens.textoPrimario);
        final otro = tester.widget<Text>(find.text('Otro'));
        expect(otro.style!.color, const Color(0xFF123456));
        expect(otro.textAlign, TextAlign.center);
        final segundo = tester.widget<BloqueLectura>(
          find.ancestor(of: find.text('Otro'), matching: find.byType(BloqueLectura)),
        );
        expect((segundo.autofocus, segundo.enVivo), (false, true));
        semantica.dispose();
      });
    });
  }

  group('VistaAsincrona', () {
    testWidgets('datos, error con «Reintentar» y carga', (tester) async {
      var reintentos = 0;
      await montar(tester, _vista(const AsyncData(1)));
      expect(find.byKey(const ValueKey('vista-datos')), findsOneWidget);

      await montar(
        tester,
        _vista(AsyncError(Exception(), StackTrace.empty), reintentar: () => reintentos++),
      );
      expect(find.byType(MensajePantalla), findsOneWidget);
      expect(find.text('Falló'), findsOneWidget);
      await tester.tap(find.text(Textos.reintentar));
      expect(reintentos, 1);

      await montar(tester, _vista(const AsyncLoading()));
      expect(find.byKey(const ValueKey('vista-esqueleto')), findsOneWidget);
    });

    testWidgets('por defecto, un error con valor previo muestra el error', (tester) async {
      final previo = (await tester.runAsync(_errorConValorPrevio))!;
      expect(previo.hasValue, isTrue);
      await montar(tester, _vista(previo));
      expect(find.byType(MensajePantalla), findsOneWidget);
    });

    testWidgets('con conservarValor, el valor previo gana al error y a la carga', (tester) async {
      final previo = (await tester.runAsync(_errorConValorPrevio))!;
      await montar(tester, _vista(previo, conservar: true));
      expect(find.byKey(const ValueKey('vista-datos')), findsOneWidget);

      await montar(tester, _vista(AsyncError(Exception(), StackTrace.empty), conservar: true));
      expect(find.byType(MensajePantalla), findsOneWidget);

      await montar(tester, _vista(const AsyncLoading(), conservar: true));
      expect(find.byKey(const ValueKey('vista-esqueleto')), findsOneWidget);
    });
  });
}
