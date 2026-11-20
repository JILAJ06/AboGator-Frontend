import 'dart:async';

import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/dialogo_confirmacion.dart';
import 'package:abogator/componentes/navegacion_inferior_app.dart';
import 'package:abogator/componentes/piezas_tienda.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:abogator/datos/mocks/mock_tienda.dart';
import 'package:abogator/datos/modelos/articulo_tienda.dart';
import 'package:abogator/datos/modelos/excepcion_tienda.dart';
import 'package:abogator/datos/modelos/resultado_compra.dart';
import 'package:abogator/datos/sincronizacion/servicio_conexion.dart';
import 'package:abogator/funciones/acceso/pantalla_inicio_sesion.dart';
import 'package:abogator/funciones/inicio/estado_inicio.dart';
import 'package:abogator/funciones/juego/estado_juego.dart';
import 'package:abogator/funciones/tienda/logica_tienda.dart';
import 'package:abogator/funciones/tienda/pantalla_tienda.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../ayudantes/montar.dart';
import '../juego/ayudante_juego.dart';

ArticuloTienda articulo(String id) => MockTienda.articulos.firstWhere((a) => a.id == id);

Finder precioDe(String id) =>
    find.descendant(of: find.byKey(ValueKey('articulo-$id')), matching: find.byType(BotonPrecio));

BotonPrecio botonDe(WidgetTester tester, String id) => tester.widget<BotonPrecio>(precioDe(id));

Future<void> tocar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<MockTienda> abrirTienda(
  WidgetTester tester, {
  MockTienda? tienda,
  Size tamano = const Size(390, 844),
  ServicioConexion? conexion,
}) async {
  final t = tienda ?? MockTienda(espera: Duration.zero);
  await abrirJuego(tester, ruta: Rutas.tienda, tienda: t, tamano: tamano, conexion: conexion);
  return t;
}

/// Tienda que falla una compra con [motivo] (o con un error genérico) y
/// mientras tanto cambia el saldo como si viniera del servidor.
class TiendaQueRechaza extends MockTienda {
  TiendaQueRechaza({this.motivo}) : super(espera: Duration.zero);

  final MotivoExcepcionTienda? motivo;
  int saldoTrasRechazo = 10;
  bool rechazado = false;

  @override
  Future<int> obtenerMonedas() async => rechazado ? saldoTrasRechazo : super.obtenerMonedas();

  @override
  Future<ResultadoCompra> comprarArticulo(String articuloId) async {
    rechazado = true;
    final m = motivo;
    if (m == null) throw Exception('sin red');
    throw ExcepcionTienda(m);
  }
}

void main() {
  group('MockTienda', () {
    test('precios y textos de Figma 24', () {
      expect(
        [for (final a in MockTienda.articulos) a.id],
        ['lupa', 'abogado', 'amparo', 'congelar-racha'],
      );
      expect([for (final a in MockTienda.articulos) a.precio], [60, 90, 120, 100]);
      expect(articulo('amparo').nombre, 'Amparo / Fianza');
      expect(articulo('congelar-racha').comodin, isNull);
      expect(articulo('congelar-racha').descripcion, 'Protege tu racha si no juegas un día.');
    });

    test('comprar suma al inventario y resta monedas', () async {
      final t = MockTienda(espera: Duration.zero);
      final r = await t.comprarArticulo('lupa');
      expect(r.cantidadNueva, 3);
      expect(r.monedasRestantes, 180);
      expect(await t.obtenerMonedas(), 180);
      expect((await t.obtenerComodines())[Comodin.lupaAuditor], 3);
    });

    test('Congelar racha cuenta aparte (empieza en 0)', () async {
      final t = MockTienda(espera: Duration.zero);
      expect(await t.obtenerCongeladoresRacha(), 0);
      final r = await t.comprarArticulo('congelar-racha');
      expect(r.cantidadNueva, 1);
      expect(await t.obtenerCongeladoresRacha(), 1);
      expect(await t.obtenerComodines(), MockTienda.comodinesIniciales);
    });

    Future<void> rechaza(MockTienda t, String id, MotivoExcepcionTienda motivo) async {
      final monedas = await t.obtenerMonedas();
      final comodines = await t.obtenerComodines();
      await expectLater(
        t.comprarArticulo(id),
        throwsA(isA<ExcepcionTienda>().having((e) => e.motivo, 'motivo', motivo)),
      );
      expect(await t.obtenerMonedas(), monedas);
      expect(await t.obtenerComodines(), comodines);
    }

    test('sin saldo, en máximo o con id inexistente no cambia nada', () async {
      await rechaza(
        MockTienda(espera: Duration.zero, monedas: 50),
        'lupa',
        MotivoExcepcionTienda.monedasInsuficientes,
      );
      await rechaza(
        MockTienda(espera: Duration.zero, comodines: const {Comodin.amparo: 9}),
        'amparo',
        MotivoExcepcionTienda.maximoAlcanzado,
      );
      await rechaza(
        MockTienda(espera: Duration.zero, congeladores: 9),
        'congelar-racha',
        MotivoExcepcionTienda.maximoAlcanzado,
      );
      await rechaza(
        MockTienda(espera: Duration.zero),
        'no-existe',
        MotivoExcepcionTienda.articuloInexistente,
      );
    });
  });

  group('LogicaTienda', () {
    final lupa = articulo('lupa');
    test('bloqueo y lo que falta', () {
      expect(
        LogicaTienda.bloqueo(lupa, monedas: 60, cantidad: 2, enLinea: true),
        BloqueoCompra.ninguno,
      );
      expect(
        LogicaTienda.bloqueo(lupa, monedas: 40, cantidad: 2, enLinea: true),
        BloqueoCompra.sinMonedas,
      );
      expect(
        LogicaTienda.bloqueo(lupa, monedas: 999, cantidad: 9, enLinea: true),
        BloqueoCompra.maximo,
      );
      expect(
        LogicaTienda.bloqueo(lupa, monedas: 999, cantidad: 0, enLinea: false),
        BloqueoCompra.sinConexion,
      );
      expect(LogicaTienda.faltan(lupa, 40), 20);
      expect(LogicaTienda.faltan(lupa, 100), 0);
    });
  });

  group('24 · Tienda', () {
    for (final brillo in Brightness.values) {
      testWidgets('estructura y textos de Figma (${brillo.name})', (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = brillo;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        await abrirTienda(tester);
        expect(find.byType(PantallaTienda), findsOneWidget);
        expect(find.text('240'), findsOneWidget);
        expect(find.bySemanticsLabel('Tienes 240 monedas'), findsOneWidget);
        expect(find.text(Textos.tuInventario), findsOneWidget);
        expect(find.text('Lupa ×2'), findsOneWidget);
        expect(find.text('Abogado ×1'), findsOneWidget);
        expect(find.text('Amparo ×1'), findsOneWidget);
        expect(find.textContaining('Congelar racha ×'), findsNothing);
        expect(find.bySemanticsLabel('Lupa de Auditor, 2 en inventario'), findsOneWidget);
        expect(find.text(Textos.comodinesSeccion), findsOneWidget);
        expect(find.byType(TarjetaArticulo), findsNWidgets(4));
        for (final n in ['60', '90', '120', '100']) {
          expect(find.text(n), findsOneWidget);
        }
        expect(find.text(Textos.notaRn03), findsOneWidget);
        expect(
          tester.widget<NavegacionInferiorApp>(find.byType(NavegacionInferiorApp)).actual,
          PestanaApp.tienda,
        );
        // Tarjetas de 165 de ancho en 390 y de igual alto por fila.
        final lupa = tester.getRect(find.byKey(const ValueKey('articulo-lupa')));
        final abogado = tester.getRect(find.byKey(const ValueKey('articulo-abogado')));
        expect(lupa.width, 165);
        expect(lupa.height, abogado.height);
        expect(abogado.left - lupa.right, 12);
        esperarSoloColoresDelTema(tester, brillo);
      });
    }

    testWidgets('Congelar racha aparece en el inventario solo con N > 0', (tester) async {
      await abrirTienda(tester, tienda: MockTienda(espera: Duration.zero, congeladores: 2));
      expect(find.text('Congelar racha ×2'), findsOneWidget);
    });

    testWidgets('el inventario muestra los comodines aun con ×0', (tester) async {
      await abrirTienda(
        tester,
        tienda: MockTienda(espera: Duration.zero, comodines: const {}),
      );
      expect(find.text('Lupa ×0'), findsOneWidget);
      expect(find.text('Abogado ×0'), findsOneWidget);
      expect(find.text('Amparo ×0'), findsOneWidget);
    });

    testWidgets('sin saldo: deshabilitado con "Te faltan N"', (tester) async {
      await abrirTienda(tester, tienda: MockTienda(espera: Duration.zero, monedas: 70));
      expect(botonDe(tester, 'lupa').alPresionar, isNotNull);
      expect(botonDe(tester, 'abogado').alPresionar, isNull);
      expect(find.text('Te faltan 20'), findsOneWidget);
      expect(find.text('Te faltan 50'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Comprar Abogado Senior por 90 monedas, te faltan 20 monedas'),
        findsOneWidget,
      );
    });

    testWidgets('en máximo: "Máximo" y deshabilitado', (tester) async {
      await abrirTienda(
        tester,
        tienda: MockTienda(espera: Duration.zero, comodines: const {Comodin.lupaAuditor: 9}),
      );
      expect(botonDe(tester, 'lupa').alPresionar, isNull);
      expect(find.text(Textos.precioMaximo), findsOneWidget);
      expect(
        find.bySemanticsLabel('Comprar Lupa de Auditor por 60 monedas, máximo alcanzado'),
        findsOneWidget,
      );
    });

    testWidgets('sin conexión: botones deshabilitados y nota', (tester) async {
      await abrirTienda(tester, conexion: ConexionSimulada(inicial: EstadoConexion.sinConexion));
      expect(find.text(Textos.necesitasConexionComprar), findsOneWidget);
      for (final a in MockTienda.articulos) {
        expect(botonDe(tester, a.id).alPresionar, isNull, reason: a.id);
      }
    });

    testWidgets('el diálogo se cancela con Cancelar, Esc o tocando fuera', (tester) async {
      final t = await abrirTienda(tester);
      await tocar(tester, precioDe('lupa'));
      expect(find.text('¿Comprar Lupa de Auditor?'), findsOneWidget);
      expect(find.text('Cuesta 60 monedas. Te quedarían 180.'), findsOneWidget);
      await tocar(tester, find.byKey(const ValueKey('boton-cancelar')));
      expect(find.byType(DialogoConfirmacion), findsNothing);

      await tocar(tester, precioDe('lupa'));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(DialogoConfirmacion), findsNothing);

      await tocar(tester, precioDe('lupa'));
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byType(DialogoConfirmacion), findsNothing);
      expect(await t.obtenerMonedas(), 240);
    });

    testWidgets('comprar actualiza saldo e inventario y lo anuncia', (tester) async {
      final t = await abrirTienda(tester);
      await tocar(tester, precioDe('lupa'));
      await tocar(tester, find.byKey(const ValueKey('boton-confirmar')));
      expect(
        find.text('Compraste Lupa de Auditor. Ahora tienes 3. Te quedan 180 monedas.'),
        findsOneWidget,
      );
      expect(find.text('180'), findsOneWidget);
      expect(find.text('Lupa ×3'), findsOneWidget);
      expect(await t.obtenerMonedas(), 180);
      // El Inicio y el juego leen lo nuevo al cargar.
      final c = contenedorDe(tester);
      expect((await c.read(datosInicioProvider.future)).monedas, 180);
      final juego = await c.read(datosJuegoProvider(sprintMock).future);
      expect(juego.comodines[Comodin.lupaAuditor], 3);
    });

    testWidgets('mientras compra no acepta otro toque', (tester) async {
      final t = BloqueadaTienda();
      await abrirTienda(tester, tienda: t);
      await tocar(tester, precioDe('lupa'));
      await tester.tap(find.byKey(const ValueKey('boton-confirmar')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(botonDe(tester, 'lupa').cargando, isTrue);
      await tester.tap(precioDe('lupa'), warnIfMissed: false);
      await tester.pump();
      expect(find.byType(DialogoConfirmacion), findsNothing);
      t.liberar();
      await tester.pumpAndSettle();
      expect(t.compras, 1);
      expect(find.text('Lupa ×3'), findsOneWidget);
    });

    for (final (motivo, texto) in [
      (MotivoExcepcionTienda.monedasInsuficientes, Textos.compraSinMonedas),
      (MotivoExcepcionTienda.maximoAlcanzado, Textos.compraMaximo),
      (null, Textos.compraError),
    ]) {
      testWidgets('error: ${motivo?.name ?? 'genérico'}', (tester) async {
        final t = TiendaQueRechaza(motivo: motivo);
        await abrirTienda(tester, tienda: t);
        await tocar(tester, precioDe('lupa'));
        await tocar(tester, find.byKey(const ValueKey('boton-confirmar')));
        expect(find.text(texto), findsOneWidget);
        // Con saldo cambiado se refresca; el genérico no recarga nada.
        expect(find.text('10'), motivo == null ? findsNothing : findsOneWidget);
      });
    }

    testWidgets('mientras carga, esqueleto', (tester) async {
      await abrirJuego(
        tester,
        ruta: Rutas.tienda,
        tienda: MockTienda(espera: const Duration(milliseconds: 100)),
        esperar: false,
      );
      await tester.pump();
      expect(find.byKey(const ValueKey('esqueleto-tienda')), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.byType(TarjetaArticulo), findsNWidgets(4));
    });

    testWidgets('error al cargar y reintentar', (tester) async {
      final t = TiendaQueFallaAlCargar();
      await abrirTienda(tester, tienda: t);
      expect(find.text(Textos.tiendaErrorCarga), findsOneWidget);
      t.fallar = false;
      await tocar(tester, find.text(Textos.reintentar));
      expect(find.byType(TarjetaArticulo), findsNWidgets(4));
    });

    testWidgets('sin sesión redirige al inicio de sesión', (tester) async {
      await abrirJuego(tester, ruta: Rutas.tienda, conSesion: false);
      expect(find.byType(PantallaInicioSesion), findsOneWidget);
    });

    test('contrastes AA', () {
      for (final t in [TokensColor.claro, TokensColor.oscuro]) {
        expect(Contraste.razon(t.textoEnPrimario, t.accionPrimaria), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.textoSecundario, t.fondoSuperficieAlt), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.textoPrimario, t.fondoDestacado), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.textoPrimario, t.fondoSuperficieAlt), greaterThanOrEqualTo(4.5));
      }
    });

    group('sin desbordes', () {
      for (final (tamano, escala) in [
        (const Size(390, 844), 1.0),
        (const Size(390, 844), 2.0),
        (const Size(360, 640), 1.0),
        (const Size(360, 640), 2.0),
        (const Size(320, 640), 1.0),
        (const Size(320, 640), 2.0),
      ]) {
        testWidgets('${tamano.width.toInt()}×${tamano.height.toInt()} ${escala}x', (tester) async {
          tester.platformDispatcher.textScaleFactorTestValue = escala;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await abrirTienda(tester, tamano: tamano);
          expect(tester.takeException(), isNull);
          await tester.drag(
            find.byKey(const ValueKey('tienda-desplazable')),
            const Offset(0, -3000),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.text(Textos.notaRn03), findsOneWidget);
        });
      }
    });
  });
}

/// Tienda cuya compra espera a [liberar].
class BloqueadaTienda extends MockTienda {
  BloqueadaTienda() : super(espera: Duration.zero);

  final _bloqueo = Completer<void>();
  int compras = 0;

  void liberar() => _bloqueo.complete();

  @override
  Future<ResultadoCompra> comprarArticulo(String articuloId) async {
    compras++;
    await _bloqueo.future;
    return super.comprarArticulo(articuloId);
  }
}

/// Tienda que falla al cargar el catálogo mientras [fallar].
class TiendaQueFallaAlCargar extends MockTienda {
  TiendaQueFallaAlCargar() : super(espera: Duration.zero);

  bool fallar = true;

  @override
  Future<List<ArticuloTienda>> obtenerArticulos() async {
    if (fallar) throw Exception('sin red');
    return super.obtenerArticulos();
  }
}
