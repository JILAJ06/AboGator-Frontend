import 'package:abogator/app/enrutador.dart';
import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/confeti_sprint.dart';
import 'package:abogator/componentes/piezas_resultado.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:abogator/datos/mocks/escenario_ransomware.dart';
import 'package:abogator/datos/mocks/mock_apelaciones.dart';
import 'package:abogator/datos/mocks/mock_examen.dart';
import 'package:abogator/datos/mocks/mock_perfil.dart';
import 'package:abogator/datos/mocks/mock_progreso.dart';
import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:abogator/datos/mocks/mock_vidas.dart';
import 'package:abogator/datos/modelos/ajustes.dart';
import 'package:abogator/datos/modelos/examen.dart';
import 'package:abogator/datos/modelos/modulo.dart';
import 'package:abogator/datos/modelos/resultado_examen.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/datos/repositorios/repositorio_examen.dart';
import 'package:abogator/datos/repositorios/repositorio_vidas.dart';
import 'package:abogator/datos/sincronizacion/servicio_conexion.dart';
import 'package:abogator/funciones/acceso/pantalla_inicio_sesion.dart';
import 'package:abogator/funciones/apelaciones/pantalla_buzon.dart';
import 'package:abogator/funciones/apelaciones/pantalla_juicio.dart';
import 'package:abogator/funciones/jefe/estado_examen.dart';
import 'package:abogator/funciones/jefe/logica_resultado.dart';
import 'package:abogator/funciones/mapa/pantalla_mapa_sprints.dart';
import 'package:abogator/funciones/perfil/estado_perfil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../ayudantes/falsos.dart';
import '../../ayudantes/montar.dart';
import '../../ayudantes/sin_desbordes.dart';
import '../juego/ayudante_juego.dart';
import 'jefe_test.dart'
    show
        RelojFalso,
        VidasDeSobra,
        avanzar,
        elegir,
        escenario,
        estado,
        golpear,
        incorrecto,
        pasarChip;

class Escena {
  Escena({
    required this.reloj,
    required this.vidas,
    required this.progreso,
    required this.apelaciones,
    required this.examen,
    required this.haptica,
    required this.conexion,
  });

  final RelojFalso reloj;
  final RepositorioVidas vidas;
  final MockProgreso progreso;
  final MockApelaciones apelaciones;
  final MockExamen examen;
  final HapticaFalsa haptica;
  final ConexionSimulada conexion;
}

/// Monta la app en 27 con todos los repositorios en memoria y empieza el
/// examen.
Future<Escena> empezar(
  WidgetTester tester, {
  RepositorioVidas? vidas,
  Size tamano = const Size(390, 844),
  Ajustes ajustes = const Ajustes(),
}) async {
  final reloj = RelojFalso();
  final repoVidas = vidas ?? MockVidas(espera: Duration.zero, ahoraServidor: reloj.fecha);
  final progreso = MockProgreso(espera: Duration.zero);
  final apelaciones = MockApelaciones(
    espera: Duration.zero,
    ahoraServidor: reloj.fecha,
    conSemilla: false,
  );
  final conexion = ConexionSimulada();
  final examen = MockExamen(
    vidas: repoVidas,
    progreso: progreso,
    espera: Duration.zero,
    ahora: reloj.fecha,
    enLinea: () => conexion.estado == EstadoConexion.enLinea,
  );
  final haptica = HapticaFalsa();
  await abrirJuego(
    tester,
    ruta: Rutas.crisisJefeDe('mod-1'),
    vidasRepo: repoVidas,
    progreso: progreso,
    apelaciones: apelaciones,
    examen: examen,
    perfil: MockPerfil(espera: Duration.zero, examen: examen),
    crearCronometro: reloj.crear,
    haptica: haptica,
    conexion: conexion,
    ajustes: ajustes,
    tamano: tamano,
  );
  await tocar(tester, find.byKey(const ValueKey('boton-enfrentar')));
  return Escena(
    reloj: reloj,
    vidas: repoVidas,
    progreso: progreso,
    apelaciones: apelaciones,
    examen: examen,
    haptica: haptica,
    conexion: conexion,
  );
}

Future<void> ganar(WidgetTester tester, {int fallosAntes = 0}) async {
  for (var k = 0; k < fallosAntes; k++) {
    await elegir(tester, incorrecto(escenario[k].respuestaCorrecta));
    await pasarChip(tester);
  }
  for (var k = 0; k < 5; k++) {
    await golpear(tester);
  }
}

Future<void> perderPorVidas(WidgetTester tester, int vidas) async {
  for (var k = 0; k < vidas; k++) {
    final i = estado(tester).decision!.indice - 1;
    await elegir(tester, incorrecto(escenario[i].respuestaCorrecta));
    await pasarChip(tester);
  }
}

/// Simula al servidor: un intento terminado sin pasar por la pantalla.
Future<String> intentoTerminado(MockExamen repo, {required bool aprobado}) async {
  final i = await repo.iniciar('mod-1');
  if (aprobado) {
    for (var k = 0; k < 5; k++) {
      await repo.responderDecision(i.id, veredicto: escenario[k].respuestaCorrecta);
      await repo.responderContraargumento(i.id, fundamento: escenario[k].fundamentoCorrecto);
    }
  } else {
    for (var k = 0; k < 5; k++) {
      await repo.responderDecision(i.id);
    }
  }
  return i.id;
}

void main() {
  group('MockExamen.registrarResultado', () {
    late RelojFalso reloj;
    late MockProgreso progreso;
    late MockVidas vidas;
    late MockExamen repo;
    var enLinea = true;

    setUp(() {
      reloj = RelojFalso();
      progreso = MockProgreso(espera: Duration.zero);
      vidas = MockVidas(espera: Duration.zero, ahoraServidor: reloj.fecha);
      enLinea = true;
      repo = MockExamen(
        vidas: vidas,
        progreso: progreso,
        espera: Duration.zero,
        ahora: reloj.fecha,
        enLinea: () => enLinea,
      );
    });

    test('aprobado: certificado con folio, módulo, aciertos y fecha del servidor', () async {
      final id = await intentoTerminado(repo, aprobado: true);
      final r = await repo.registrarResultado(id);
      expect(r.aprobado, isTrue);
      final c = r.certificado!;
      expect(c.folio, 'AG-M1-0001');
      expect(c.moduloId, 'mod-1');
      expect(c.nombreModulo, 'Protección de Datos');
      expect(c.nombrePersona, 'Ana López');
      expect((c.aciertos, c.totalDecisiones), (5, 10));
      expect(c.fecha, reloj.fecha());
      expect(r.siguienteModulo!.id, 'mod-2');
      expect(r.siguienteModulo!.numero, 2);
      expect(Certificado.fechaCorta(DateTime.utc(2026, 10, 28)), '28 oct 2026');
      expect(Certificado.fechaLarga(DateTime.utc(2026, 10, 28)), '28 de octubre de 2026');
    });

    test('idempotente: mismo certificado, sin duplicar', () async {
      final id = await intentoTerminado(repo, aprobado: true);
      final a = await repo.registrarResultado(id);
      final b = await repo.registrarResultado(id);
      expect(identical(a.certificado, b.certificado), isTrue);
      expect(await repo.obtenerCertificados(), hasLength(1));
      // Otro intento aprobado del mismo módulo tampoco duplica.
      final otro = await intentoTerminado(repo, aprobado: true);
      final c = await repo.registrarResultado(otro);
      expect(c.certificado!.folio, 'AG-M1-0001');
      expect(await repo.obtenerCertificados(), hasLength(1));
    });

    test('reprobado: sin certificado; vidas y próxima vida del servidor', () async {
      final id = await intentoTerminado(repo, aprobado: false);
      final r = await repo.registrarResultado(id);
      expect(r.aprobado, isFalse);
      expect(r.certificado, isNull);
      expect(r.vidas, 0);
      expect(r.faltaParaProximaVida, isNotNull);
      expect(await repo.obtenerCertificados(), isEmpty);
    });

    test('intento sin terminar → intentoCerrado; sin red → sinConexion', () async {
      final i = await repo.iniciar('mod-1');
      await expectLater(
        repo.registrarResultado(i.id),
        throwsA(
          isA<ExcepcionExamen>().having(
            (e) => e.motivo,
            'motivo',
            MotivoExcepcionExamen.intentoCerrado,
          ),
        ),
      );
      final id = await intentoTerminado(repo, aprobado: true);
      enLinea = false;
      await expectLater(
        repo.registrarResultado(id),
        throwsA(
          isA<ExcepcionExamen>().having(
            (e) => e.motivo,
            'motivo',
            MotivoExcepcionExamen.sinConexion,
          ),
        ),
      );
    });
  });

  group('MockProgreso.registrarExamenAprobado', () {
    test('completa el examen y pone en curso el primer sprint del siguiente', () async {
      final p = MockProgreso(espera: Duration.zero);
      await p.registrarExamenAprobado(moduloId: 'mod-1');
      final m = await p.obtenerModulos();
      final examen = m[0].sprints.last;
      expect(examen.esExamenFinal, isTrue);
      expect(examen.estado, EstadoSprint.completado);
      expect(examen.estrellas, 3);
      expect(m[1].sprints.first.estado, EstadoSprint.enCurso);
      // Repetir no cambia nada más.
      await p.registrarExamenAprobado(moduloId: 'mod-1');
      final otra = await p.obtenerModulos();
      expect(otra[1].sprints.where((s) => s.estado == EstadoSprint.enCurso), hasLength(1));
    });

    test('el último módulo no desbloquea nada', () async {
      final p = MockProgreso(espera: Duration.zero);
      final antes = await p.obtenerModulos();
      await p.registrarExamenAprobado(moduloId: 'mod-5');
      final despues = await p.obtenerModulos();
      for (var i = 0; i < 4; i++) {
        expect(
          [for (final s in despues[i].sprints) s.estado],
          [for (final s in antes[i].sprints) s.estado],
        );
      }
    });
  });

  group('apelaciones del examen', () {
    DecisionCrisis decision(int i) => DecisionCrisis(
      id: EscenarioRansomware.idDe(i),
      indice: i,
      hora: escenario[i - 1].hora,
      limite: const Duration(seconds: 15),
      etiquetaCaso: EscenarioRansomware.etiqueta,
      personaje: escenario[i - 1].personaje,
      rol: escenario[i - 1].rol,
      texto: escenario[i - 1].texto,
    );

    test('una por decisión fallada, sin duplicar, título ≤ 45', () {
      final falladas = [
        DecisionFallada(decision: decision(8), veredicto: Veredicto.legal),
        DecisionFallada(decision: decision(2)),
        DecisionFallada(decision: decision(8), enContraargumento: true),
        DecisionFallada(decision: decision(3), enContraargumento: true),
      ];
      final a = LogicaResultado.apelaciones(falladas, 'mod-1');
      expect([for (final x in a) x.tarjetaId], ['ran-08', 'ran-02', 'ran-03']);
      expect(a.first.titulo, 'Hora 24 · CTO');
      expect(a.first.tema, 'Brechas de seguridad');
      expect(a.first.moduloId, 'mod-1');
      for (final x in a) {
        expect(x.titulo.length, lessThanOrEqualTo(45));
      }
      expect(EscenarioRansomware.tituloApelacion(48, 'x' * 60).length, 45);
    });

    test('MockTarjetas abre la decisión del examen como tarjeta', () async {
      final t = await MockTarjetas(espera: Duration.zero).obtenerTarjeta('ran-03');
      expect(t.personaje, escenario[2].personaje);
      expect(t.texto, escenario[2].texto);
      expect(t.respuestaCorrecta, escenario[2].respuestaCorrecta);
      expect(t.explicacion, escenario[2].fundamentos[escenario[2].fundamentoCorrecto]);
      expect(t.tema, 'Brechas de seguridad');
      expect(t.etiquetaCaso, EscenarioRansomware.etiqueta);
      expect(EscenarioRansomware.comoTarjeta('ran-11'), isNull);
      expect(EscenarioRansomware.comoTarjeta('tar-x'), isNull);
    });

    test('el Perfil cuenta los certificados', () async {
      final reloj = RelojFalso();
      final repo = MockExamen(
        vidas: MockVidas(espera: Duration.zero),
        progreso: MockProgreso(espera: Duration.zero),
        espera: Duration.zero,
        ahora: reloj.fecha,
      );
      final perfil = MockPerfil(espera: Duration.zero, examen: repo);
      expect((await perfil.obtenerPerfil()).certificados, 0);
      await repo.registrarResultado(await intentoTerminado(repo, aprobado: true));
      expect((await perfil.obtenerPerfil()).certificados, 1);
    });
  });

  group('29 · Auditoría superada', () {
    for (final brillo in Brightness.values) {
      testWidgets('estructura de Figma (${brillo.name})', (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = brillo;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        final e = await empezar(tester);
        await ganar(tester);
        expect(rutaActual(tester), Rutas.auditoriaSuperadaDe('mod-1'));
        expect(find.byType(TrofeoCertificado), findsOneWidget);
        expect(tester.getSize(find.byType(TrofeoCertificado)), const Size(96, 96));
        expect(find.byKey(const ValueKey('confeti-auditoria')), findsOneWidget);
        expect(
          tester.widget<ConfetiSprint>(find.byKey(const ValueKey('confeti-auditoria'))).piezas,
          hasLength(8),
        );
        expect(find.text(Textos.auditoriaSuperada), findsOneWidget);
        expect(
          find.text(
            'Contuviste la crisis y la Inspectora Vega aprobó tu MVP. '
            'Desbloqueaste el Módulo 2: Licencias y Propiedad Intelectual.',
          ),
          findsOneWidget,
        );
        expect(find.text(Textos.certificadoDeModulo), findsOneWidget);
        expect(find.text('Protección de Datos'), findsOneWidget);
        final fecha = Certificado.fechaCorta(e.reloj.fecha());
        expect(find.textContaining('5/10 aciertos'), findsOneWidget);
        expect(find.textContaining(fecha), findsOneWidget);
        expect(find.text('Folio AG-M1-0001'), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);
        expect(
          tester
              .widget<CustomPaint>(find.byKey(const ValueKey('tarjeta-certificado')))
              .foregroundPainter,
          isA<PintorBordePunteado>(),
        );
        expect(find.text('Ir al Módulo 2'), findsOneWidget);
        expect(find.text(Textos.compartirCertificadoBoton), findsOneWidget);
        expect(
          find.bySemanticsLabel(
            RegExp(r'^Certificado de módulo\. Protección de Datos\. Ana López, 5 de 10 aciertos'),
          ),
          findsOneWidget,
        );
        expect(e.haptica.llamadas.last, 'acierto');
        esperarSoloColoresDelTema(tester, brillo);
      });
    }

    testWidgets('"Ir al Módulo 2": mapa del siguiente, examen reiniciado, Perfil 1 de 5', (
      tester,
    ) async {
      final e = await empezar(tester);
      await ganar(tester);
      await tocar(tester, find.byKey(const ValueKey('boton-ir-modulo')));
      expect(rutaActual(tester), Rutas.mapaSprintsDe('mod-2'));
      expect(find.byType(PantallaMapaSprints), findsOneWidget);
      expect(contenedorDe(tester).read(examenProvider), isNull);
      final m = await e.progreso.obtenerModulos();
      expect(m[0].sprints.last.estado, EstadoSprint.completado);
      expect(m[1].sprints.first.estado, EstadoSprint.enCurso);
      final perfil = await contenedorDe(tester).read(datosPerfilProvider.future);
      expect(perfil.resumen.certificados, 1);
    });

    testWidgets('compartir copia el texto y avisa', (tester) async {
      String? copiado;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (
        llamada,
      ) async {
        if (llamada.method == 'Clipboard.setData') {
          copiado = (llamada.arguments as Map)['text'] as String;
        }
        return null;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      final e = await empezar(tester);
      await ganar(tester);
      await tocar(tester, find.byKey(const ValueKey('boton-compartir')));
      expect(
        copiado,
        'Obtuve el certificado «Protección de Datos» en AboGator · Folio AG-M1-0001 · '
        '${Certificado.fechaCorta(e.reloj.fecha())}',
      );
      expect(find.text(Textos.certificadoCopiado), findsOneWidget);
    });

    testWidgets('sin red al registrar: error, reintentar y certificado', (tester) async {
      final e = await empezar(tester);
      for (var k = 0; k < 4; k++) {
        await golpear(tester);
      }
      e.conexion.establecer(EstadoConexion.sinConexion);
      await golpear(tester);
      expect(find.text(Textos.errorGuardarResultado), findsOneWidget);
      expect(find.byType(TarjetaCertificado), findsNothing);
      expect(find.byKey(const ValueKey('boton-volver-mapa')), findsOneWidget);
      e.conexion.establecer(EstadoConexion.enLinea);
      await tocar(tester, find.byKey(const ValueKey('boton-reintentar-resultado')));
      expect(find.byType(TarjetaCertificado), findsOneWidget);
      expect(await e.examen.obtenerCertificados(), hasLength(1));
    });

    testWidgets('atrás va al mapa del módulo', (tester) async {
      await empezar(tester);
      await ganar(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(rutaActual(tester), Rutas.mapaSprintsDe('mod-1'));
    });

    for (final ruta in [Rutas.auditoriaSuperadaDe('mod-1'), Rutas.inspectoraGanoDe('mod-1')]) {
      testWidgets('sin examen terminado $ruta redirige al mapa', (tester) async {
        await abrirJuego(tester, ruta: ruta);
        expect(rutaActual(tester), Rutas.mapaSprintsDe('mod-1'));
      });
    }

    testWidgets('sin sesión va al inicio de sesión', (tester) async {
      await abrirJuego(tester, ruta: Rutas.auditoriaSuperadaDe('mod-1'), conSesion: false);
      expect(find.byType(PantallaInicioSesion), findsOneWidget);
    });

    testWidgets('con fallos aprobados, sus apelaciones van al Buzón', (tester) async {
      final e = await empezar(tester);
      await ganar(tester, fallosAntes: 2);
      final buzon = await e.apelaciones.obtenerBuzon();
      expect([for (final a in buzon.apelaciones) a.tarjetaId], ['ran-01', 'ran-02']);
    });

    test('contrastes', () {
      for (final t in [TokensColor.claro, TokensColor.oscuro]) {
        expect(Contraste.razon(t.textoAcento, t.fondoSuperficie), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.estadoIlegal, t.fondoApp), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.estadoLegal, t.fondoSuperficie), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.estadoIlegal, t.fondoSuperficie), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.textoPrimario, t.fondoDestacado), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.textoSecundario, t.fondoDestacado), greaterThanOrEqualTo(4.5));
      }
    });
  });

  group('30 · La Inspectora ganó', () {
    for (final brillo in Brightness.values) {
      testWidgets('sin vidas: estructura, resumen y próxima vida (${brillo.name})', (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = brillo;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        final e = await empezar(tester, vidas: MockVidas(espera: Duration.zero, cantidad: 2));
        await perderPorVidas(tester, 2);
        expect(rutaActual(tester), Rutas.inspectoraGanoDe('mod-1'));
        expect(find.text(Textos.inspectoraGano), findsOneWidget);
        expect(find.text(Textos.reprobadoSinVidas), findsOneWidget);
        expect(find.text('2/10'), findsOneWidget);
        expect(find.text(Textos.llegasteA), findsOneWidget);
        expect(
          find.bySemanticsLabel('Llegaste a la decisión 2 de 10. 0 aciertos. 0 por tiempo agotado'),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('proxima-vida')), findsOneWidget);
        expect(find.textContaining('Próxima vida en '), findsOneWidget);
        expect(find.text(Textos.repasarEnBuzon), findsOneWidget);
        expect(find.text(Textos.volverAlMapa), findsOneWidget);
        expect(e.haptica.llamadas.last, 'error');
        esperarSoloColoresDelTema(tester, brillo);
      });
    }

    testWidgets('la cuenta regresiva baja con el cronómetro y para en 0', (tester) async {
      final e = await empezar(tester, vidas: MockVidas(espera: Duration.zero, cantidad: 1));
      await perderPorVidas(tester, 1);
      String texto() => tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(const ValueKey('proxima-vida')),
              matching: find.byType(Text),
            ),
          )
          .data!;
      final antes = texto();
      await avanzar(tester, e.reloj, const Duration(seconds: 61));
      expect(texto(), isNot(antes));
      await avanzar(tester, e.reloj, const Duration(hours: 5));
      expect(texto(), contains('00:00:00'));
    });

    testWidgets('sin decisiones con HP > 0: su texto y las vidas restantes', (tester) async {
      await empezar(tester, vidas: VidasDeSobra(9));
      for (var k = 0; k < 4; k++) {
        await golpear(tester);
      }
      for (var k = 4; k < 10; k++) {
        await elegir(tester, incorrecto(escenario[k].respuestaCorrecta));
        await pasarChip(tester);
      }
      expect(rutaActual(tester), Rutas.inspectoraGanoDe('mod-1'));
      expect(find.text(Textos.reprobadoSinDecisiones), findsOneWidget);
      expect(find.text(Textos.vidasRestantesExamen(3)), findsOneWidget);
      expect(find.byKey(const ValueKey('proxima-vida')), findsNothing);
      expect(find.text('10/10'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('perder → apelaciones en el Buzón → se abre el juicio', (tester) async {
      final e = await empezar(tester, vidas: MockVidas(espera: Duration.zero, cantidad: 2));
      await perderPorVidas(tester, 2);
      final buzon = await e.apelaciones.obtenerBuzon();
      expect([for (final a in buzon.apelaciones) a.tarjetaId], ['ran-01', 'ran-02']);
      expect(buzon.apelaciones.first.titulo, 'Hora 0 · Analista de seguridad');
      await tocar(tester, find.byKey(const ValueKey('boton-repasar-buzon')));
      expect(rutaActual(tester), Rutas.buzon);
      expect(contenedorDe(tester).read(examenProvider), isNull);
      // Las apelaciones se abren a los 3 días (reloj del servidor).
      e.reloj.ahora += const Duration(days: 3);
      contenedorDe(tester).invalidate(datosBuzonProvider);
      await tester.pumpAndSettle();
      contenedorDe(tester)
          .read(enrutadorProvider)
          .go(Rutas.juicioApelacionDe(buzon.apelaciones.first.id));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaJuicio), findsOneWidget);
      expect(find.text('APELACIÓN · BRECHAS DE SEGURIDAD'), findsOneWidget);
      expect(find.text(escenario[0].texto), findsOneWidget);
    });

    testWidgets('error al guardar: aviso con reintentar, botones activos', (tester) async {
      final e = await empezar(tester, vidas: MockVidas(espera: Duration.zero, cantidad: 1));
      e.conexion.establecer(EstadoConexion.sinConexion);
      await perderPorVidas(tester, 1);
      expect(find.text(Textos.errorGuardarApelaciones), findsOneWidget);
      expect(
        tester.widget<BotonApp>(find.byKey(const ValueKey('boton-volver-mapa'))).alPresionar,
        isNotNull,
      );
      e.conexion.establecer(EstadoConexion.enLinea);
      await tocar(tester, find.byKey(const ValueKey('boton-reintentar-resultado')));
      expect(find.text(Textos.errorGuardarApelaciones), findsNothing);
      expect((await e.apelaciones.obtenerBuzon()).apelaciones, hasLength(1));
      // Reintentar otra vez no duplica.
      await contenedorDe(tester).read(examenProvider.notifier).registrarResultado();
      expect((await e.apelaciones.obtenerBuzon()).apelaciones, hasLength(1));
    });

    testWidgets('"Volver al mapa" y enlace cruzado', (tester) async {
      await empezar(tester, vidas: MockVidas(espera: Duration.zero, cantidad: 1));
      await perderPorVidas(tester, 1);
      contenedorDe(tester).read(enrutadorProvider).go(Rutas.auditoriaSuperadaDe('mod-1'));
      await tester.pumpAndSettle();
      expect(rutaActual(tester), Rutas.inspectoraGanoDe('mod-1'));
      await tocar(tester, find.byKey(const ValueKey('boton-volver-mapa')));
      expect(rutaActual(tester), Rutas.mapaSprintsDe('mod-1'));
    });
  });

  group('desbordes', () {
    probarSinDesbordes(
      (tester, tamano, _) async {
        await empezar(tester, tamano: tamano);
        await ganar(tester);
        expect(tester.takeException(), isNull);
        await tester.drag(
          find.byKey(const ValueKey('resultado-desplazable')),
          const Offset(0, -2000),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
      grupo: null,
      prefijo: '29 a ',
    );
    probarSinDesbordes(
      (tester, tamano, escala) async {
        await empezar(
          tester,
          tamano: tamano,
          vidas: MockVidas(espera: Duration.zero, cantidad: 1),
        );
        await perderPorVidas(tester, 1);
        expect(tester.takeException(), isNull);
        expect(
          find.byKey(const ValueKey('resumen-examen')).evaluate().single.widget,
          escala >= 1.5 ? isA<Column>() : isA<IntrinsicHeight>(),
        );
        await tester.drag(
          find.byKey(const ValueKey('resultado-desplazable')),
          const Offset(0, -2000),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
      grupo: null,
      prefijo: '30 a ',
    );

    testWidgets('reducir animaciones: el confeti queda quieto', (tester) async {
      await empezar(tester, ajustes: const Ajustes(reducirAnimaciones: true));
      await ganar(tester);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
