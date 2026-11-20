import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/boton_veredicto.dart';
import 'package:abogator/componentes/corazon_vida.dart';
import 'package:abogator/componentes/piezas_apelacion.dart';
import 'package:abogator/componentes/tarjeta_caso.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:abogator/datos/mocks/mock_apelaciones.dart';
import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:abogator/datos/mocks/mock_vidas.dart';
import 'package:abogator/datos/modelos/apelacion.dart';
import 'package:abogator/datos/modelos/buzon_apelaciones.dart';
import 'package:abogator/datos/modelos/resultado_apelacion.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/datos/repositorios/repositorio_apelaciones.dart';
import 'package:abogator/datos/sincronizacion/servicio_conexion.dart';
import 'package:abogator/funciones/apelaciones/logica_apelacion.dart';
import 'package:abogator/funciones/apelaciones/pantalla_buzon.dart';
import 'package:abogator/funciones/apelaciones/pantalla_juicio.dart';
import 'package:abogator/funciones/apelaciones/sesion_apelaciones.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../ayudantes/montar.dart';
import '../juego/ayudante_juego.dart';

final ahora = DateTime.utc(2026, 11, 20, 10);
final hoy = DateTime.utc(2026, 11, 20);

MockApelaciones servidor({bool conSemilla = true, DateTime Function()? reloj}) => MockApelaciones(
  espera: Duration.zero,
  ahoraServidor: reloj ?? () => ahora,
  conSemilla: conSemilla,
);

/// Buzón que falla al resolver (la primera vez, o siempre).
class BuzonQueFalla implements RepositorioApelaciones {
  BuzonQueFalla(this.real, {this.vecesQueFalla = 1});

  final MockApelaciones real;
  int vecesQueFalla;

  @override
  Future<BuzonApelaciones> obtenerBuzon() => real.obtenerBuzon();

  @override
  Future<void> registrarFallos(List<NuevaApelacion> fallos) => real.registrarFallos(fallos);

  @override
  Future<ResultadoApelacion> resolverApelacion(String apelacionId, {required bool ganada}) {
    if (vecesQueFalla > 0) {
      vecesQueFalla--;
      throw Exception('sin red');
    }
    return real.resolverApelacion(apelacionId, ganada: ganada);
  }
}

Finder boton(String texto) => find.widgetWithText(BotonApp, texto);

Future<void> tocar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> elegir(WidgetTester tester, Veredicto v) =>
    tocar(tester, find.byWidgetPredicate((w) => w is BotonVeredicto && w.veredicto == v));

/// Abre el juicio de [id] por el enlace profundo (sesión de una).
Future<void> abrirJuicio(
  WidgetTester tester, {
  String id = 'ape-001',
  RepositorioApelaciones? apelaciones,
  int vidas = 3,
  MockVidas? vidasRepo,
  Size tamano = const Size(390, 844),
  ServicioConexion? conexion,
}) => abrirJuego(
  tester,
  ruta: Rutas.juicioApelacionDe(id),
  apelaciones: apelaciones ?? servidor(),
  vidas: vidas,
  vidasRepo: vidasRepo,
  tamano: tamano,
  conexion: conexion,
);

void main() {
  group('MockApelaciones.resolverApelacion', () {
    test('ganar día 3 la pasa a día 7 en 4 días', () async {
      final repo = servidor();
      final r = await repo.resolverApelacion('ape-001', ganada: true);
      expect(r, const ResultadoApelacion(ganada: true, diaSiguiente: 7, diasParaVolver: 4));
      final a = (await repo.obtenerBuzon()).apelaciones.firstWhere((a) => a.id == 'ape-001');
      expect(a.diaRepaso, 7);
      expect(a.disponibleEl, hoy.add(const Duration(days: 4)));
    });

    test('ganar día 7 la pasa a día 14 en 7 días', () async {
      final repo = servidor();
      final r = await repo.resolverApelacion('ape-002', ganada: true);
      expect(r, const ResultadoApelacion(ganada: true, diaSiguiente: 14, diasParaVolver: 7));
      final a = (await repo.obtenerBuzon()).apelaciones.firstWhere((a) => a.id == 'ape-002');
      expect(a.diaRepaso, 14);
      expect(a.disponibleEl, hoy.add(const Duration(days: 7)));
    });

    test('ganar día 14 la saca del Buzón (dominada)', () async {
      var reloj = ahora;
      final repo = servidor(reloj: () => reloj);
      reloj = ahora.add(const Duration(days: 5));
      final r = await repo.resolverApelacion('ape-005', ganada: true);
      expect(r.dominada, isTrue);
      expect(r, const ResultadoApelacion(ganada: true));
      final b = await repo.obtenerBuzon();
      expect(b.apelaciones.any((a) => a.id == 'ape-005'), isFalse);
    });

    test('perder la deja en su día y la abre mañana', () async {
      final repo = servidor();
      final r = await repo.resolverApelacion('ape-002', ganada: false);
      expect(r, const ResultadoApelacion(ganada: false, diaSiguiente: 7, diasParaVolver: 1));
      final b = await repo.obtenerBuzon();
      final a = b.apelaciones.firstWhere((a) => a.id == 'ape-002');
      expect(a.diaRepaso, 7);
      expect(b.diasHasta(a), 1);
    });

    test('lanza si no existe o no se abre hoy', () async {
      final repo = servidor();
      expect(() => repo.resolverApelacion('ape-999', ganada: true), throwsStateError);
      expect(() => repo.resolverApelacion('ape-003', ganada: true), throwsStateError);
    });
  });

  group('MockVidas.recuperarVida', () {
    test('suma una sin pasar de 5', () async {
      final repo = MockVidas(espera: Duration.zero, cantidad: 0);
      expect((await repo.recuperarVida()).cantidad, 1);
      final lleno = MockVidas(espera: Duration.zero);
      final v = await lleno.recuperarVida();
      expect(v.cantidad, 5);
      expect(v.faltaParaProxima, isNull);
    });

    test('al llegar a 5 deja de regenerar', () async {
      final repo = MockVidas(espera: Duration.zero, cantidad: 4);
      expect((await repo.obtenerVidas()).faltaParaProxima, isNotNull);
      final v = await repo.recuperarVida();
      expect(v.cantidad, 5);
      expect(v.faltaParaProxima, isNull);
    });
  });

  group('LogicaApelacion', () {
    final gpl = MockTarjetas.tarjetasPorSprint.values
        .expand((l) => l)
        .firstWhere((t) => t.id == 'tar-gpl-01');

    test('solo la respuesta correcta gana', () {
      expect(LogicaApelacion.gana(gpl, Veredicto.ilegal), isTrue);
      for (final v in [Veredicto.legal, Veredicto.condicional, Veredicto.escalar]) {
        expect(LogicaApelacion.gana(gpl, v), isFalse);
      }
    });

    test('etiqueta en mayúsculas', () {
      expect(LogicaApelacion.etiqueta('Licencias OSS'), 'APELACIÓN · LICENCIAS OSS');
    });

    test('frases de regreso', () {
      expect(
        LogicaApelacion.fraseRegreso(
          const ResultadoApelacion(ganada: true, diaSiguiente: 7, diasParaVolver: 4),
        ),
        'La tarjeta vuelve en 4 días para asegurar que no se te olvide.',
      );
      expect(
        LogicaApelacion.fraseRegreso(const ResultadoApelacion(ganada: true)),
        Textos.tarjetaDominada,
      );
      expect(
        LogicaApelacion.fraseRegreso(
          const ResultadoApelacion(ganada: false, diaSiguiente: 3, diasParaVolver: 1),
        ),
        Textos.vuelveManana,
      );
    });

    test('días hechos al ganar y al perder', () {
      expect(LogicaApelacion.hechos(3, ganada: true), [true, false, false]);
      expect(LogicaApelacion.hechos(7, ganada: true), [true, true, false]);
      expect(LogicaApelacion.hechos(14, ganada: true), [true, true, true]);
      expect(LogicaApelacion.hechos(3, ganada: false), [false, false, false]);
      expect(LogicaApelacion.hechos(7, ganada: false), [true, false, false]);
      expect(LogicaApelacion.hechos(14, ganada: false), [true, true, false]);
    });

    test('texto de la perdida dice la respuesta correcta', () {
      final t = LogicaApelacion.texto(
        gpl,
        const ResultadoApelacion(ganada: false, diaSiguiente: 3, diasParaVolver: 1),
      );
      expect(t, startsWith(Textos.estaVezNo));
      expect(t, contains('La respuesta correcta era Ilegal.'));
      expect(t, endsWith(Textos.vuelveManana));
    });
  });

  group('22 · Juicio de apelación', () {
    for (final brillo in Brightness.values) {
      testWidgets('barra, tarjeta, aviso y nota (${brillo.name})', (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = brillo;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        await abrirJuicio(tester);
        expect(find.byType(PantallaJuicio), findsOneWidget);
        expect(find.text('Apelación 1 de 1'), findsOneWidget);
        expect(find.text(Textos.masUnaVida), findsOneWidget);
        expect(find.text('APELACIÓN · LICENCIAS OSS'), findsOneWidget);
        expect(find.text('La fallaste hace 3 días'), findsOneWidget);
        // El aviso va dentro de la tarjeta.
        expect(
          find.descendant(of: find.byType(TarjetaCaso), matching: find.byType(AvisoFallo)),
          findsOneWidget,
        );
        expect(find.byType(BotonVeredicto), findsNWidgets(4));
        expect(find.text(Textos.notaJuicio), findsOneWidget);
        expect(find.byKey(const ValueKey('barra-comodines')), findsNothing);
        esperarSoloColoresDelTema(tester, brillo);
      });
    }

    testWidgets('con 5 vidas la recompensa dice "Vidas al máximo"', (tester) async {
      await abrirJuicio(tester, vidas: 5);
      expect(find.text(Textos.vidasAlMaximo), findsOneWidget);
      expect(find.text(Textos.masUnaVida), findsNothing);
      expect(find.bySemanticsLabel(Textos.vidasAlMaximoSemantica), findsOneWidget);
    });

    testWidgets('la recompensa se lee como "Si ganas, recuperas 1 vida"', (tester) async {
      await abrirJuicio(tester);
      expect(find.bySemanticsLabel(Textos.recompensaApelacionSemantica), findsOneWidget);
    });

    testWidgets('arrastrar equivale al botón', (tester) async {
      final repo = servidor();
      await abrirJuicio(tester, apelaciones: repo);
      await tester.drag(find.byKey(const ValueKey('gesto-tarjeta')), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text(Textos.apelacionGanadaTitulo), findsOneWidget);
      final a = (await repo.obtenerBuzon()).apelaciones.firstWhere((a) => a.id == 'ape-001');
      expect(a.diaRepaso, 7);
    });

    testWidgets('Salir vuelve al Buzón sin resolver', (tester) async {
      final repo = servidor();
      await abrirJuicio(tester, apelaciones: repo);
      await tocar(tester, find.bySemanticsLabel(Textos.salir));
      expect(rutaActual(tester), Rutas.buzon);
      expect((await repo.obtenerBuzon()).deHoy, hasLength(2));
      expect(contenedorDe(tester).read(sesionApelacionesProvider), isNull);
    });

    testWidgets('atrás vuelve al Buzón sin resolver', (tester) async {
      final repo = servidor();
      await abrirJuicio(tester, apelaciones: repo);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(rutaActual(tester), Rutas.buzon);
      expect((await repo.obtenerBuzon()).deHoy, hasLength(2));
    });

    testWidgets('sin conexión pide conexión', (tester) async {
      await abrirJuicio(tester, conexion: ConexionSimulada(inicial: EstadoConexion.sinConexion));
      expect(find.text(Textos.necesitasConexionApelar), findsOneWidget);
      await tocar(tester, boton(Textos.volverAlBuzon));
      expect(rutaActual(tester), Rutas.buzon);
    });

    testWidgets('una apelación futura o inexistente no está disponible', (tester) async {
      await abrirJuicio(tester, id: 'ape-003');
      expect(find.text(Textos.apelacionNoDisponible), findsOneWidget);
      await tocar(tester, boton(Textos.volverAlBuzon));
      expect(rutaActual(tester), Rutas.buzon);
    });

    testWidgets('si no se guarda, avisa y la tarjeta vuelve', (tester) async {
      final repo = BuzonQueFalla(servidor());
      await abrirJuicio(tester, apelaciones: repo);
      await elegir(tester, Veredicto.ilegal);
      expect(find.text(Textos.errorGuardarApelacion), findsOneWidget);
      expect(find.byType(TarjetaCaso), findsOneWidget);
      expect(find.text(Textos.apelacionGanadaTitulo), findsNothing);
      await elegir(tester, Veredicto.ilegal);
      expect(find.text(Textos.apelacionGanadaTitulo), findsOneWidget);
    });
  });

  group('22b y la perdida', () {
    for (final (vidas, despues, insignia) in [
      (0, 1, Textos.vidaRecuperadaInsignia),
      (3, 4, Textos.vidaRecuperadaInsignia),
      (5, 5, Textos.vidasAlMaximo),
    ]) {
      testWidgets('ganada con $vidas vidas', (tester) async {
        await abrirJuicio(tester, vidas: vidas);
        await elegir(tester, Veredicto.ilegal);
        expect(find.text(Textos.apelacionGanadaTitulo), findsOneWidget);
        expect(tester.widget<FilaVidas>(find.byType(FilaVidas)).cantidad, despues);
        expect(find.text(insignia), findsOneWidget);
        expect(
          find.textContaining('La tarjeta vuelve en 4 días para asegurar que no se te olvide.'),
          findsOneWidget,
        );
        expect(find.textContaining(Textos.estaVezSi), findsOneWidget);
        final pildoras = tester.widgetList<PildoraRepaso>(find.byType(PildoraRepaso)).toList();
        expect([for (final p in pildoras) p.hecho], [true, false, false]);
        expect(find.bySemanticsLabel('Día 3, completado'), findsOneWidget);
        expect(find.bySemanticsLabel('Día 7, pendiente'), findsOneWidget);
        // Última de la sesión: solo "Volver al Buzón" como principal.
        expect(boton(Textos.siguienteApelacion), findsNothing);
        expect(tester.widget<BotonApp>(boton(Textos.volverAlBuzon)).tipo, TipoBoton.primario);
      });
    }

    testWidgets('perdida: no pierde vidas y da la respuesta correcta', (tester) async {
      await abrirJuicio(tester, id: 'ape-002', vidas: 2);
      await elegir(tester, Veredicto.legal);
      expect(find.text(Textos.apelacionPerdidaTitulo), findsOneWidget);
      expect(find.text(Textos.noPierdesVidas), findsOneWidget);
      expect(tester.widget<FilaVidas>(find.byType(FilaVidas)).cantidad, 2);
      expect(find.textContaining('La respuesta correcta era Ilegal.'), findsOneWidget);
      expect(find.textContaining(Textos.vuelveManana), findsOneWidget);
      final pildoras = tester.widgetList<PildoraRepaso>(find.byType(PildoraRepaso)).toList();
      expect([for (final p in pildoras) p.hecho], [true, false, false]);
    });

    testWidgets('el título recibe el foco y se anuncia', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrirJuicio(tester, vidas: 1);
      await elegir(tester, Veredicto.ilegal);
      expect(
        find.bySemanticsLabel('¡Apelación ganada! +1 vida recuperada. Vidas: 2 de 5.'),
        findsOneWidget,
      );
      expect(Focus.of(tester.element(find.text(Textos.apelacionGanadaTitulo))).hasFocus, isTrue);
      expect(
        tester
            .getSemantics(find.byKey(const ValueKey('titulo-resultado-apelacion')))
            .flagsCollection
            .isHeader,
        isTrue,
      );
      semantica.dispose();
    });

    test('contrastes AA', () {
      for (final t in [TokensColor.claro, TokensColor.oscuro]) {
        expect(Contraste.razon(t.textoEnPrimario, t.estadoIlegal), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.textoEnPrimario, t.estadoLegal), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.textoSecundario, t.fondoSuperficieAlt), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.textoAcento, t.fondoDestacado), greaterThanOrEqualTo(4.5));
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
          await abrirJuicio(tester, tamano: tamano);
          expect(tester.takeException(), isNull);
          await elegir(tester, Veredicto.ilegal);
          expect(tester.takeException(), isNull);
          expect(find.text(Textos.apelacionGanadaTitulo), findsOneWidget);
        });
      }
    });
  });

  group('flujos', () {
    testWidgets('Iniciar 2 → ganar → siguiente → perder → Buzón', (tester) async {
      final repo = servidor();
      await abrirJuego(tester, ruta: Rutas.buzon, apelaciones: repo, vidas: 3);
      await tocar(tester, boton(Textos.iniciarApelacionesHoy));
      expect(rutaActual(tester), Rutas.juicioApelacionDe('ape-001'));
      expect(find.text('Apelación 1 de 2'), findsOneWidget);

      await elegir(tester, Veredicto.ilegal);
      expect(find.text(Textos.apelacionGanadaTitulo), findsOneWidget);
      expect(tester.widget<FilaVidas>(find.byType(FilaVidas)).cantidad, 4);
      expect(boton(Textos.siguienteApelacion), findsOneWidget);
      expect(tester.widget<BotonApp>(boton(Textos.volverAlBuzon)).tipo, TipoBoton.fantasma);

      await tocar(tester, boton(Textos.siguienteApelacion));
      expect(rutaActual(tester), Rutas.juicioApelacionDe('ape-002'));
      expect(find.text('Apelación 2 de 2'), findsOneWidget);
      expect(find.text('La fallaste hace 7 días'), findsOneWidget);

      await elegir(tester, Veredicto.legal);
      expect(find.text(Textos.apelacionPerdidaTitulo), findsOneWidget);
      expect(boton(Textos.siguienteApelacion), findsNothing);

      await tocar(tester, boton(Textos.volverAlBuzon));
      expect(rutaActual(tester), Rutas.buzon);
      expect(find.byType(PantallaBuzon), findsOneWidget);
      final b = await repo.obtenerBuzon();
      expect(b.deHoy, isEmpty);
      expect(b.apelaciones.firstWhere((a) => a.id == 'ape-001').diaRepaso, 7);
      expect(contenedorDe(tester).read(sesionApelacionesProvider), isNull);
    });

    testWidgets('desde 0 vidas, ganar sube las vidas', (tester) async {
      final vidas = MockVidas(espera: Duration.zero, cantidad: 0);
      await abrirJuicio(tester, vidasRepo: vidas);
      await elegir(tester, Veredicto.ilegal);
      expect((await vidas.obtenerVidas()).cantidad, 1);
      expect(find.text(Textos.vidaRecuperadaInsignia), findsOneWidget);
    });

    testWidgets('fila del Buzón: sesión de una', (tester) async {
      await abrirJuego(tester, ruta: Rutas.buzon, apelaciones: servidor());
      await tocar(tester, find.byKey(const ValueKey('fila-ape-002')));
      expect(find.text('Apelación 1 de 1'), findsOneWidget);
    });

    testWidgets('enlace profundo sin sesión de la app va al inicio de sesión', (tester) async {
      await abrirJuego(
        tester,
        ruta: Rutas.juicioApelacionDe('ape-001'),
        conSesion: false,
        apelaciones: servidor(),
      );
      expect(find.byType(PantallaJuicio), findsNothing);
    });
  });

  group('piezas', () {
    for (final brillo in Brightness.values) {
      testWidgets('insignias, aviso y días (${brillo.name})', (tester) async {
        await montar(
          tester,
          const Column(
            children: [
              InsigniaVida(texto: Textos.masUnaVida, destacada: true),
              InsigniaVida(texto: Textos.noPierdesVidas, destacada: false),
              AvisoFallo(dias: 3),
              FilaRepaso(hechos: [true, true, false]),
            ],
          ),
          brillo: brillo,
        );
        expect(find.text('+1 vida'), findsOneWidget);
        expect(find.text('La fallaste hace 3 días'), findsOneWidget);
        expect(find.text('Día 14'), findsOneWidget);
        expect(find.bySemanticsLabel('Día 7, completado'), findsOneWidget);
        expect(find.bySemanticsLabel('Día 14, pendiente'), findsOneWidget);
        esperarSoloColoresDelTema(tester, brillo);
      });
    }
  });
}
