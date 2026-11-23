import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/barra_juego.dart';
import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/boton_veredicto.dart';
import 'package:abogator/componentes/opcion_justificacion.dart';
import 'package:abogator/componentes/piezas_jefe.dart';
import 'package:abogator/core/tema/efectos.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:abogator/core/utilidades/cronometro.dart';
import 'package:abogator/datos/mocks/escenario_ransomware.dart';
import 'package:abogator/datos/mocks/mock_examen.dart';
import 'package:abogator/datos/mocks/mock_vidas.dart';
import 'package:abogator/datos/modelos/ajustes.dart';
import 'package:abogator/datos/modelos/examen.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/datos/modelos/vidas.dart';
import 'package:abogator/datos/repositorios/repositorio_examen.dart';
import 'package:abogator/datos/repositorios/repositorio_vidas.dart';
import 'package:abogator/datos/sincronizacion/servicio_conexion.dart';
import 'package:abogator/funciones/acceso/pantalla_inicio_sesion.dart';
import 'package:abogator/funciones/jefe/estado_examen.dart';
import 'package:abogator/funciones/jefe/logica_jefe.dart';
import 'package:abogator/funciones/jefe/pantalla_jefe.dart';
import 'package:abogator/funciones/jefe/pantalla_resultado.dart';
import 'package:abogator/funciones/jefe/reloj_crisis.dart';
import 'package:abogator/funciones/mapa/pantalla_mapa_sprints.dart';
import 'package:abogator/funciones/vidas/pantalla_sin_vidas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../ayudantes/falsos.dart';
import '../../ayudantes/montar.dart';
import '../../ayudantes/sin_desbordes.dart';
import '../juego/ayudante_juego.dart';

/// Reloj compartido: los cronómetros y el servidor avanzan juntos.
class RelojFalso {
  Duration ahora = Duration.zero;
  final base = DateTime.utc(2026, 11, 20, 10);

  DateTime fecha() => base.add(ahora);

  Cronometro crear() => _CronometroFalso(this);
}

class _CronometroFalso implements Cronometro {
  _CronometroFalso(this._reloj) : _inicio = _reloj.ahora;

  final RelojFalso _reloj;
  Duration _inicio;

  @override
  Duration get transcurrido => _reloj.ahora - _inicio;

  @override
  void reiniciar() => _inicio = _reloj.ahora;
}

/// Vidas sin el tope de 5 (para probar que se acaban las decisiones).
class VidasDeSobra implements RepositorioVidas {
  VidasDeSobra(this.cantidad);

  int cantidad;

  @override
  Future<Vidas> obtenerVidas() async => Vidas(cantidad: cantidad);

  @override
  Future<Vidas> guardarVidas(int c) async => Vidas(cantidad: cantidad = c);

  @override
  Future<Vidas> recuperarVida() async => Vidas(cantidad: ++cantidad);
}

List<DecisionEscenario> get escenario => EscenarioRansomware.decisiones;

Veredicto incorrecto(Veredicto v) => v == Veredicto.legal ? Veredicto.ilegal : Veredicto.legal;

MockExamen servidor(RepositorioVidas vidas, RelojFalso reloj, {bool Function()? enLinea}) =>
    MockExamen(vidas: vidas, espera: Duration.zero, ahora: reloj.fecha, enLinea: enLinea);

// ---------------------------------------------------------------------------
// Ayudantes de widget
// ---------------------------------------------------------------------------

class Montaje {
  Montaje(this.reloj, this.vidas, this.haptica);

  final RelojFalso reloj;
  final MockVidas vidas;
  final HapticaFalsa haptica;
}

Future<Montaje> abrirCrisis(
  WidgetTester tester, {
  int vidas = 5,
  String modulo = 'mod-1',
  Ajustes ajustes = const Ajustes(),
  ServicioConexion? conexion,
  Size tamano = const Size(390, 844),
}) async {
  final reloj = RelojFalso();
  final repoVidas = MockVidas(espera: Duration.zero, cantidad: vidas);
  final haptica = HapticaFalsa();
  await abrirJuego(
    tester,
    ruta: Rutas.crisisJefeDe(modulo),
    vidasRepo: repoVidas,
    examen: servidor(repoVidas, reloj),
    crearCronometro: reloj.crear,
    ajustes: ajustes,
    haptica: haptica,
    conexion: conexion,
    tamano: tamano,
  );
  return Montaje(reloj, repoVidas, haptica);
}

Future<Montaje> empezarExamen(
  WidgetTester tester, {
  int vidas = 5,
  Ajustes ajustes = const Ajustes(),
}) async {
  final m = await abrirCrisis(tester, vidas: vidas, ajustes: ajustes);
  await tocar(tester, find.byKey(const ValueKey('boton-enfrentar')));
  return m;
}

Future<void> elegir(WidgetTester tester, Veredicto v) =>
    tocar(tester, find.byWidgetPredicate((w) => w is BotonVeredicto && w.veredicto == v));

/// Avanza el reloj falso y deja correr el temporizador de pantalla.
Future<void> avanzar(WidgetTester tester, RelojFalso reloj, Duration d) async {
  reloj.ahora += d;
  await tester.pump(RelojCrisis.tic);
  await tester.pump(RelojCrisis.tic);
}

/// Deja pasar el chip de golpe o de fallo.
Future<void> pasarChip(WidgetTester tester) async {
  await tester.pump(EfectosApp.duracionChipJefe);
  await tester.pumpAndSettle();
}

EstadoExamenJefe estado(WidgetTester tester) => contenedorDe(tester).read(examenProvider)!;

int segundosEnPantalla(WidgetTester tester) =>
    int.parse(tester.widget<Text>(find.byKey(const ValueKey('segundos-crisis'))).data!);

/// Acierta la decisión actual y su fundamento.
Future<void> golpear(WidgetTester tester) async {
  final i = estado(tester).decision!.indice - 1;
  await elegir(tester, escenario[i].respuestaCorrecta);
  await tocar(tester, find.byKey(ValueKey('fundamento-${escenario[i].fundamentoCorrecto}')));
  await pasarChip(tester);
}

void main() {
  group('MockExamen', () {
    late RelojFalso reloj;
    late MockVidas vidas;
    late MockExamen repo;

    setUp(() {
      reloj = RelojFalso();
      vidas = MockVidas(espera: Duration.zero);
      repo = servidor(vidas, reloj);
    });

    test('consultar: solo el módulo 1 tiene escenario', () async {
      final info = await repo.consultar('mod-1');
      expect(info.titulo, '¡Ransomware! Se filtró la base de usuarios');
      expect(info.totalDecisiones, 10);
      await expectLater(
        repo.consultar('mod-2'),
        throwsA(
          isA<ExcepcionExamen>().having(
            (e) => e.motivo,
            'motivo',
            MotivoExcepcionExamen.examenNoDisponible,
          ),
        ),
      );
    });

    test('escenario: 10 decisiones, horas de Figma, veredictos variados', () {
      expect(escenario, hasLength(10));
      expect([for (final d in escenario) d.hora], [0, 1, 3, 6, 9, 12, 18, 24, 48, 72]);
      expect({for (final d in escenario) d.respuestaCorrecta}, hasLength(4));
      expect({for (final d in escenario) d.fundamentoCorrecto}, {0, 1});
      for (final d in escenario) {
        expect(d.fundamentos, hasLength(2));
        expect(
          RegExp(r'art[íi]culo\s*\d', caseSensitive: false).hasMatch(d.fundamentos.join()),
          isFalse,
        );
      }
      expect(escenario[7].personaje, 'CTO');
      expect(escenario[7].respuestaCorrecta, Veredicto.ilegal);
      expect(escenario[8].rol, 'Despacho jurídico');
      expect(escenario[8].respuestaCorrecta, Veredicto.legal);
    });

    test('iniciar: HP 100, 15 s (22 s con tiempo extendido)', () async {
      final i = await repo.iniciar('mod-1');
      expect(i.hpJefe, 100);
      expect(i.vidas, 5);
      expect(i.totalDecisiones, 10);
      expect(i.decision.indice, 1);
      expect(i.decision.hora, 0);
      expect(i.decision.limite, const Duration(seconds: 15));
      final e = await repo.iniciar('mod-1', tiempoExtendido: true);
      expect(e.decision.limite, const Duration(seconds: 22));
    });

    test('sin vidas, sin red o sin escenario no inicia', () async {
      Matcher motivo(MotivoExcepcionExamen m) =>
          throwsA(isA<ExcepcionExamen>().having((e) => e.motivo, 'motivo', m));
      await expectLater(
        servidor(MockVidas(espera: Duration.zero, cantidad: 0), reloj).iniciar('mod-1'),
        motivo(MotivoExcepcionExamen.sinVidas),
      );
      await expectLater(
        servidor(vidas, reloj, enLinea: () => false).iniciar('mod-1'),
        motivo(MotivoExcepcionExamen.sinConexion),
      );
      await expectLater(repo.iniciar('mod-3'), motivo(MotivoExcepcionExamen.examenNoDisponible));
    });

    test('acierto → réplica; fundamento correcto −20 HP; incorrecto −1 vida', () async {
      final i = await repo.iniciar('mod-1');
      final r = await repo.responderDecision(i.id, veredicto: escenario[0].respuestaCorrecta);
      expect(r.correcta, isTrue);
      expect(r.replica!.fundamentos, hasLength(2));
      expect(r.limiteReplica, const Duration(seconds: 8));
      final c = await repo.responderContraargumento(
        i.id,
        fundamento: escenario[0].fundamentoCorrecto,
      );
      expect(c.correcto, isTrue);
      expect(c.danio, 20);
      expect(c.hpJefe, 80);
      expect(c.vidas, 5);
      expect(c.siguiente!.indice, 2);

      await repo.responderDecision(i.id, veredicto: escenario[1].respuestaCorrecta);
      final mal = await repo.responderContraargumento(
        i.id,
        fundamento: 1 - escenario[1].fundamentoCorrecto,
      );
      expect(mal.correcto, isFalse);
      expect(mal.danio, 0);
      expect(mal.hpJefe, 80);
      expect(mal.vidas, 4);
      expect((await vidas.obtenerVidas()).cantidad, 4);
    });

    test('veredicto incorrecto o tiempo agotado: −1 vida sin réplica', () async {
      final i = await repo.iniciar('mod-1');
      final r = await repo.responderDecision(
        i.id,
        veredicto: incorrecto(escenario[0].respuestaCorrecta),
      );
      expect(r.correcta, isFalse);
      expect(r.replica, isNull);
      expect(r.vidas, 4);
      expect(r.respuestaCorrecta, escenario[0].respuestaCorrecta);
      expect(r.siguiente!.indice, 2);
      final t = await repo.responderDecision(i.id);
      expect(t.tiempoAgotado, isTrue);
      expect(t.vidas, 3);
    });

    test('réplica sin tiempo: −1 vida; con tiempo extendido son 12 s', () async {
      final i = await repo.iniciar('mod-1', tiempoExtendido: true);
      final r = await repo.responderDecision(i.id, veredicto: escenario[0].respuestaCorrecta);
      expect(r.limiteReplica, const Duration(seconds: 12));
      final c = await repo.responderContraargumento(i.id);
      expect(c.tiempoAgotado, isTrue);
      expect(c.vidas, 4);
    });

    test('5 golpes → aprobado (antes de la decisión 10)', () async {
      final i = await repo.iniciar('mod-1');
      late ResultadoContraargumento c;
      for (var k = 0; k < 5; k++) {
        await repo.responderDecision(i.id, veredicto: escenario[k].respuestaCorrecta);
        c = await repo.responderContraargumento(i.id, fundamento: escenario[k].fundamentoCorrecto);
      }
      expect(c.hpJefe, 0);
      expect(c.estado, EstadoExamen.aprobado);
      expect(c.siguiente, isNull);
      await expectLater(
        repo.responderDecision(i.id, veredicto: Veredicto.legal),
        throwsA(isA<ExcepcionExamen>()),
      );
    });

    test('0 vidas → reprobado', () async {
      final r2 = servidor(MockVidas(espera: Duration.zero, cantidad: 2), reloj);
      final i = await r2.iniciar('mod-1');
      await r2.responderDecision(i.id);
      final r = await r2.responderDecision(i.id);
      expect(r.vidas, 0);
      expect(r.estado, EstadoExamen.reprobado);
      expect(r.siguiente, isNull);
    });

    test('se acaban las decisiones con HP > 0 → reprobado', () async {
      final r2 = servidor(VidasDeSobra(9), reloj);
      final i = await r2.iniciar('mod-1');
      for (var k = 0; k < 4; k++) {
        await r2.responderDecision(i.id, veredicto: escenario[k].respuestaCorrecta);
        await r2.responderContraargumento(i.id, fundamento: escenario[k].fundamentoCorrecto);
      }
      late ResultadoDecision r;
      for (var k = 4; k < 10; k++) {
        r = await r2.responderDecision(i.id);
      }
      expect(r.hpJefe, 20);
      expect(r.vidas, 3);
      expect(r.estado, EstadoExamen.reprobado);
    });

    test('respuesta repetida o fuera de turno → intentoCerrado', () async {
      final i = await repo.iniciar('mod-1');
      await expectLater(
        repo.responderContraargumento(i.id, fundamento: 0),
        throwsA(isA<ExcepcionExamen>()),
      );
      await repo.responderDecision(i.id, veredicto: escenario[0].respuestaCorrecta);
      await expectLater(
        repo.responderDecision(i.id, veredicto: escenario[0].respuestaCorrecta),
        throwsA(
          isA<ExcepcionExamen>().having(
            (e) => e.motivo,
            'motivo',
            MotivoExcepcionExamen.intentoCerrado,
          ),
        ),
      );
    });

    test('respuesta más de 2 s tarde = tiempo agotado (reloj del servidor)', () async {
      final i = await repo.iniciar('mod-1');
      reloj.ahora += const Duration(seconds: 16);
      final a = await repo.responderDecision(i.id, veredicto: escenario[0].respuestaCorrecta);
      expect(a.correcta, isTrue, reason: 'dentro de la tolerancia');
      await repo.responderContraargumento(i.id, fundamento: escenario[0].fundamentoCorrecto);
      reloj.ahora += const Duration(seconds: 18);
      final b = await repo.responderDecision(i.id, veredicto: escenario[1].respuestaCorrecta);
      expect(b.correcta, isFalse);
      expect(b.tiempoAgotado, isTrue);
    });

    test('la pausa detiene el tiempo y salir no cambia vidas', () async {
      final i = await repo.iniciar('mod-1', tiempoExtendido: true);
      await repo.pausar(i.id);
      await expectLater(repo.responderDecision(i.id), throwsA(isA<ExcepcionExamen>()));
      reloj.ahora += const Duration(minutes: 2);
      await repo.reanudar(i.id);
      final r = await repo.responderDecision(i.id, veredicto: escenario[0].respuestaCorrecta);
      expect(r.correcta, isTrue);
      await repo.abandonar(i.id);
      expect((await vidas.obtenerVidas()).cantidad, 5);
      await expectLater(
        repo.responderContraargumento(i.id, fundamento: 0),
        throwsA(isA<ExcepcionExamen>()),
      );
    });
  });

  group('lógica', () {
    test('fases por hora', () {
      expect(FaseCrisis.de(0), FaseCrisis.deteccion);
      expect(FaseCrisis.de(5), FaseCrisis.deteccion);
      expect(FaseCrisis.de(6), FaseCrisis.contencion);
      expect(FaseCrisis.de(23), FaseCrisis.contencion);
      expect(FaseCrisis.de(24), FaseCrisis.aviso);
      expect(FaseCrisis.de(71), FaseCrisis.aviso);
      expect(FaseCrisis.de(72), FaseCrisis.autoridad);
    });

    test('tiempos, HP, urgencia y textos', () {
      expect(LogicaJefe.segundosPorDecision(tiempoExtendido: false), 15);
      expect(LogicaJefe.segundosPorDecision(tiempoExtendido: true), 22);
      expect(LogicaJefe.segundosReplica(tiempoExtendido: false), 8);
      expect(LogicaJefe.segundosReplica(tiempoExtendido: true), 12);
      expect(LogicaJefe.fraccionHp(60), 0.6);
      expect(LogicaJefe.urgente(5), isTrue);
      expect(LogicaJefe.urgente(6), isFalse);
      expect(LogicaJefe.textoFeedback(TipoFeedback.golpe, 20), '−20 HP · ¡Argumento sólido!');
      expect(LogicaJefe.textoFeedback(TipoFeedback.falloTiempo, 0), '−1 vida · Se acabó el tiempo');
      expect(
        LogicaJefe.anuncioFeedback(TipoFeedback.golpe, danio: 20, hp: 40, vidas: 2),
        'Daño a la Inspectora: menos 20 HP. Le quedan 40.',
      );
    });
  });

  group('27 · Crisis', () {
    for (final brillo in Brightness.values) {
      testWidgets('estructura de Figma, siempre oscura (${brillo.name})', (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = brillo;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        await abrirCrisis(tester);
        expect(find.byType(PantallaCrisis), findsOneWidget);
        expect(find.text(Textos.alertaJefe), findsOneWidget);
        expect(find.text('¡Ransomware! Se filtró la base de usuarios'), findsOneWidget);
        expect(find.textContaining('Tienes 72 horas'), findsOneWidget);
        expect(find.byType(BarraDelJefe), findsOneWidget);
        expect(find.text('HP 100%'), findsOneWidget);
        expect(find.byType(LineaDeCrisis), findsOneWidget);
        for (final t in [
          'H0',
          'H6',
          'H24',
          'H72',
          'Detección',
          'Contención',
          'Aviso',
          'Autoridad',
        ]) {
          expect(find.text(t), findsOneWidget);
        }
        expect(find.text('10 decisiones en secuencia rápida: 15 s cada una'), findsOneWidget);
        expect(find.text(Textos.reglaComodines), findsOneWidget);
        expect(find.byKey(const ValueKey('tiempo-extendido-crisis')), findsNothing);
        expect(find.text(Textos.enfrentarAuditoria), findsOneWidget);
        expect(find.text(Textos.ahoraNo), findsOneWidget);
        expect(
          tester.widget<Scaffold>(find.byKey(const ValueKey('pantalla-crisis'))).backgroundColor,
          EfectosApp.fondoCrisis,
        );
        expect(
          find.bySemanticsLabel(
            'Inspectora Vega, auditora de protección de datos. HP 100 por ciento',
          ),
          findsOneWidget,
        );
        esperarSoloColoresDelTema(tester, Brightness.light);
      });
    }

    testWidgets('con tiempo extendido: 22 s y la línea verde', (tester) async {
      await abrirCrisis(tester, ajustes: const Ajustes(tiempoExtendido: true));
      expect(find.text('10 decisiones en secuencia rápida: 22 s cada una'), findsOneWidget);
      expect(find.text('Tiempo extendido activo: 22 s por decisión'), findsOneWidget);
    });

    testWidgets('sin conexión: botón deshabilitado y aviso', (tester) async {
      await abrirCrisis(tester, conexion: ConexionSimulada(inicial: EstadoConexion.sinConexion));
      expect(find.text(Textos.necesitasConexionExamen), findsOneWidget);
      expect(
        tester.widget<BotonApp>(find.byKey(const ValueKey('boton-enfrentar'))).alPresionar,
        isNull,
      );
    });

    testWidgets('sin vidas va a "Sin vidas" del módulo', (tester) async {
      await abrirCrisis(tester, vidas: 0);
      await tocar(tester, find.byKey(const ValueKey('boton-enfrentar')));
      expect(rutaActual(tester), Rutas.sinVidas);
      expect(find.byType(PantallaSinVidas), findsOneWidget);
    });

    testWidgets('módulo sin examen', (tester) async {
      await abrirCrisis(tester, modulo: 'mod-2');
      expect(find.text(Textos.examenNoDisponible), findsOneWidget);
      await tocar(tester, find.text(Textos.volverAlMapa));
      expect(rutaActual(tester), Rutas.mapaSprintsDe('mod-2'));
    });

    testWidgets('"Ahora no" vuelve al mapa', (tester) async {
      await abrirCrisis(tester);
      await tocar(tester, find.byKey(const ValueKey('boton-ahora-no')));
      expect(find.byType(PantallaMapaSprints), findsOneWidget);
    });

    testWidgets('sin sesión redirige', (tester) async {
      await abrirJuego(tester, ruta: Rutas.crisisJefeDe('mod-1'), conSesion: false);
      expect(find.byType(PantallaInicioSesion), findsOneWidget);
    });
  });

  group('28 · Decisión', () {
    for (final brillo in Brightness.values) {
      testWidgets('piezas de Figma (${brillo.name})', (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = brillo;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        await empezarExamen(tester);
        expect(find.text('Crisis · Decisión 1 de 10'), findsOneWidget);
        expect(find.text('HP 100%'), findsOneWidget);
        expect(find.text('Hora 0 de 72'), findsOneWidget);
        expect(find.byKey(const ValueKey('tinte-urgencia')), findsOneWidget);
        expect(segundosEnPantalla(tester), 15);
        expect(find.text(Textos.comodinesDesactivados), findsOneWidget);
        expect(find.byKey(const ValueKey('boton-pausa')), findsNothing);
        expect(find.text(EscenarioRansomware.etiqueta), findsOneWidget);
        expect(
          tester.getSize(find.byKey(const ValueKey('temporizador-crisis'))),
          const Size(80, 80),
        );
        expect(find.byType(BarraJuego), findsOneWidget);
        esperarSoloColoresDelTema(tester, brillo);
      });
    }

    testWidgets('el temporizador corre y se pone urgente a ≤ 5 s', (tester) async {
      final m = await empezarExamen(tester);
      final ctx = tester.element(find.byKey(const ValueKey('temporizador-crisis')));
      final tokens = Theme.of(ctx).extension<TokensColor>()!;
      Color color() =>
          tester.widget<Text>(find.byKey(const ValueKey('segundos-crisis'))).style!.color!;
      expect(color(), tokens.accionPrimaria);
      await avanzar(tester, m.reloj, const Duration(seconds: 10));
      expect(segundosEnPantalla(tester), 5);
      expect(color(), tokens.estadoIlegal);
    });

    testWidgets('tiempo agotado: responde una sola vez, chip y −1 vida', (tester) async {
      final m = await empezarExamen(tester);
      await avanzar(tester, m.reloj, const Duration(seconds: 15));
      await tester.pump();
      expect(find.text(Textos.falloTiempo), findsOneWidget);
      expect(estado(tester).vidas, 4);
      await avanzar(tester, m.reloj, const Duration(seconds: 1));
      expect(estado(tester).vidas, 4);
      expect(m.haptica.llamadas, ['error']);
      await pasarChip(tester);
      expect(find.text('Crisis · Decisión 2 de 10'), findsOneWidget);
      expect(find.text(Textos.falloTiempo), findsNothing);
    });

    testWidgets('veredicto incorrecto: chip de fallo y −1 vida, sin réplica', (tester) async {
      await empezarExamen(tester);
      await elegir(tester, incorrecto(escenario[0].respuestaCorrecta));
      expect(find.text(Textos.falloVeredicto), findsOneWidget);
      expect(find.byType(PanelContraargumento), findsNothing);
      expect(estado(tester).vidas, 4);
      expect(estado(tester).falladas.single.respuestaCorrecta, escenario[0].respuestaCorrecta);
    });

    testWidgets('arrastrar equivale al botón', (tester) async {
      await empezarExamen(tester);
      await tester.drag(find.byKey(const ValueKey('gesto-tarjeta')), const Offset(400, 0));
      await tester.pumpAndSettle();
      // Decisión 1: Legal (arrastrar a la derecha).
      expect(find.byType(PanelContraargumento), findsOneWidget);
    });

    testWidgets('solo botones: arrastrar no responde', (tester) async {
      await empezarExamen(tester, ajustes: const Ajustes(soloBotones: true));
      await tester.drag(find.byKey(const ValueKey('gesto-tarjeta')), const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(find.byType(PanelContraargumento), findsNothing);
      expect(find.text(Textos.casoPistaBotones), findsOneWidget);
    });

    testWidgets('pausa (tiempo extendido): detiene el tiempo y tapa la tarjeta', (tester) async {
      final m = await empezarExamen(tester, ajustes: const Ajustes(tiempoExtendido: true));
      expect(segundosEnPantalla(tester), 22);
      await tocar(tester, find.byKey(const ValueKey('boton-pausa')));
      expect(find.byKey(const ValueKey('capa-pausa')), findsOneWidget);
      expect(find.text(Textos.examenEnPausa), findsOneWidget);
      await avanzar(tester, m.reloj, const Duration(seconds: 60));
      expect(estado(tester).fase, FaseJefe.pausa);
      await tocar(tester, find.byKey(const ValueKey('boton-continuar-pausa')));
      expect(estado(tester).fase, FaseJefe.decision);
      expect(segundosEnPantalla(tester), 22);
      await elegir(tester, escenario[0].respuestaCorrecta);
      expect(find.byType(PanelContraargumento), findsOneWidget);
    });

    testWidgets('Salir: cancelar sigue; confirmar vuelve al mapa sin perder vidas', (tester) async {
      final m = await empezarExamen(tester);
      await tocar(tester, find.bySemanticsLabel(Textos.salir));
      expect(find.text(Textos.salirExamenTitulo), findsOneWidget);
      await tocar(tester, find.byKey(const ValueKey('boton-cancelar')));
      expect(find.byKey(const ValueKey('pantalla-decision')), findsOneWidget);
      await tocar(tester, find.bySemanticsLabel(Textos.salir));
      await tocar(tester, find.byKey(const ValueKey('boton-confirmar')));
      expect(rutaActual(tester), Rutas.mapaSprintsDe('mod-1'));
      expect((await m.vidas.obtenerVidas()).cantidad, 5);
      expect(contenedorDe(tester).read(examenProvider), isNull);
    });
  });

  group('28b · Contraargumento', () {
    testWidgets('panel, velo, cuenta regresiva y tocar responde', (tester) async {
      final m = await empezarExamen(tester);
      await elegir(tester, escenario[0].respuestaCorrecta);
      expect(find.byType(PanelContraargumento), findsOneWidget);
      expect(find.byKey(const ValueKey('velo-contraargumento')), findsOneWidget);
      expect(find.text(Textos.inspectoraVegaMayusculas), findsOneWidget);
      expect(find.text('“${escenario[0].replica}”'), findsOneWidget);
      expect(find.byType(OpcionJustificacion), findsNWidgets(2));
      expect(find.text('Tienes 8 s para responder'), findsOneWidget);
      expect(find.byKey(const ValueKey('tarjeta-enviada')), findsOneWidget);
      // El temporizador de la decisión queda detenido.
      final congelado = segundosEnPantalla(tester);
      await avanzar(tester, m.reloj, const Duration(seconds: 3));
      expect(find.text('Tienes 5 s para responder'), findsOneWidget);
      expect(segundosEnPantalla(tester), congelado);
      // Tocar el velo no cierra nada.
      await tester.tapAt(const Offset(200, 120));
      await tester.pumpAndSettle();
      expect(find.byType(PanelContraargumento), findsOneWidget);
      await tocar(tester, find.byKey(ValueKey('fundamento-${escenario[0].fundamentoCorrecto}')));
      expect(find.byKey(const ValueKey('chip-danio')), findsOneWidget);
      expect(find.text('−20 HP · ¡Argumento sólido!'), findsOneWidget);
    });

    testWidgets('tiempo agotado en la réplica = fallo', (tester) async {
      final m = await empezarExamen(tester);
      await elegir(tester, escenario[0].respuestaCorrecta);
      await avanzar(tester, m.reloj, const Duration(seconds: 8));
      await tester.pump();
      expect(find.text(Textos.falloTiempo), findsOneWidget);
      expect(estado(tester).vidas, 4);
    });

    testWidgets('fundamento incorrecto: −1 vida', (tester) async {
      await empezarExamen(tester);
      await elegir(tester, escenario[0].respuestaCorrecta);
      await tocar(
        tester,
        find.byKey(ValueKey('fundamento-${1 - escenario[0].fundamentoCorrecto}')),
      );
      expect(find.text(Textos.falloFundamento), findsOneWidget);
      expect(estado(tester).vidas, 4);
      expect(estado(tester).hp, 100);
    });

    testWidgets('con tiempo extendido son 12 s', (tester) async {
      await empezarExamen(tester, ajustes: const Ajustes(tiempoExtendido: true));
      await elegir(tester, escenario[0].respuestaCorrecta);
      expect(find.text('Tienes 12 s para responder'), findsOneWidget);
    });

    testWidgets('el foco va a la réplica', (tester) async {
      await empezarExamen(tester);
      await elegir(tester, escenario[0].respuestaCorrecta);
      await tester.pump();
      final foco = FocusManager.instance.primaryFocus;
      expect(foco?.debugLabel, 'réplica de la Inspectora');
    });
  });

  group('28c · Golpe', () {
    testWidgets('HP 100 → 80, la siguiente decisión espera al chip', (tester) async {
      final m = await empezarExamen(tester);
      await elegir(tester, escenario[0].respuestaCorrecta);
      await tocar(tester, find.byKey(ValueKey('fundamento-${escenario[0].fundamentoCorrecto}')));
      expect(find.text('HP 80%'), findsOneWidget);
      // Ya se ve la decisión 2 con el tiempo lleno y detenido.
      expect(find.text('Crisis · Decisión 2 de 10'), findsOneWidget);
      expect(find.text('Hora 1 de 72'), findsOneWidget);
      await avanzar(tester, m.reloj, const Duration(seconds: 1));
      expect(segundosEnPantalla(tester), 15);
      expect(m.haptica.llamadas, ['acierto', 'acierto']);
      await pasarChip(tester);
      expect(find.byKey(const ValueKey('chip-danio')), findsNothing);
      await avanzar(tester, m.reloj, const Duration(seconds: 2));
      expect(segundosEnPantalla(tester), 13);
    });
  });

  group('flujo completo', () {
    testWidgets('5 golpes: aprobado → 29', (tester) async {
      await empezarExamen(tester);
      for (var k = 0; k < 5; k++) {
        await golpear(tester);
      }
      expect(rutaActual(tester), Rutas.auditoriaSuperadaDe('mod-1'));
      expect(find.byType(PantallaAuditoriaSuperada), findsOneWidget);
      final e = contenedorDe(tester).read(examenProvider)!;
      expect(e.resultado, EstadoExamen.aprobado);
      expect(e.resumen.golpes, 5);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(rutaActual(tester), Rutas.mapaSprintsDe('mod-1'));
      expect(contenedorDe(tester).read(examenProvider), isNull);
    });

    testWidgets('perder todas las vidas: reprobado → 30', (tester) async {
      await empezarExamen(tester, vidas: 2);
      await elegir(tester, incorrecto(escenario[0].respuestaCorrecta));
      await pasarChip(tester);
      await elegir(tester, incorrecto(escenario[1].respuestaCorrecta));
      await pasarChip(tester);
      expect(rutaActual(tester), Rutas.inspectoraGanoDe('mod-1'));
      expect(find.byType(PantallaInspectoraGano), findsOneWidget);
      expect(contenedorDe(tester).read(examenProvider)!.falladas, hasLength(2));
    });
  });

  group('accesibilidad', () {
    test('contrastes AA', () {
      const blanco = EfectosApp.blancoCrisis;
      expect(Contraste.razon(blanco, EfectosApp.alertaCrisis), greaterThanOrEqualTo(4.5));
      for (final fondo in [EfectosApp.fondoCrisis, EfectosApp.barraJefe]) {
        expect(Contraste.razon(EfectosApp.textoCrisisSecundario, fondo), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(EfectosApp.textoCrisis, fondo), greaterThanOrEqualTo(4.5));
      }
      expect(Contraste.razon(EfectosApp.vidaJefe, EfectosApp.barraJefe), greaterThanOrEqualTo(4.5));
      expect(
        Contraste.razon(EfectosApp.verdeCrisis, EfectosApp.fondoCrisis),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        Contraste.razon(EfectosApp.textoReplica, EfectosApp.barraJefe),
        greaterThanOrEqualTo(4.5),
      );
      for (final t in [TokensColor.claro, TokensColor.oscuro]) {
        expect(Contraste.razon(t.estadoIlegal, t.fondoSuperficie), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.textoSecundario, t.fondoSuperficieAlt), greaterThanOrEqualTo(4.5));
      }
    });

    probarSinDesbordes(
      (tester, tamano, _) async {
        final m = await abrirCrisis(
          tester,
          tamano: tamano,
          ajustes: const Ajustes(tiempoExtendido: true),
        );
        expect(tester.takeException(), isNull);
        await tocar(tester, find.byKey(const ValueKey('boton-enfrentar')));
        expect(tester.takeException(), isNull);
        await elegir(tester, escenario[0].respuestaCorrecta);
        expect(tester.takeException(), isNull);
        await tocar(tester, find.byKey(ValueKey('fundamento-${escenario[0].fundamentoCorrecto}')));
        expect(tester.takeException(), isNull);
        await avanzar(tester, m.reloj, Duration.zero);
        await pasarChip(tester);
        expect(tester.takeException(), isNull);
      },
      grupo: null,
      prefijo: 'sin desbordes ',
    );
  });
}
