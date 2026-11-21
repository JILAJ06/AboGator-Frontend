import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/barra_comodines.dart';
import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/boton_veredicto.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/mocks/mock_apelaciones.dart';
import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:abogator/datos/mocks/mock_vidas.dart';
import 'package:abogator/datos/modelos/ajustes.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/datos/sincronizacion/servicio_conexion.dart';
import 'package:abogator/funciones/juego/mazo_swipe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../funciones/apelaciones/juicio_test.dart' show servidor;
import '../funciones/jefe/jefe_test.dart'
    as jefe
    show RelojFalso, elegir, escenario, incorrecto, pasarChip, servidor;
import '../funciones/jefe/resultado_test.dart' show empezar, ganar, perderPorVidas;
import '../funciones/juego/ayudante_juego.dart';
import '../funciones/juego/fin_sprint_test.dart' as fin show mazoLegal, responder, tarjeta;

/// Cómo llegar a una pantalla (y a su estado) con unos ajustes y un tamaño.
typedef Llegar = Future<void> Function(WidgetTester tester, Ajustes ajustes, Size tamano);

/// Una vista de la auditoría: su nombre (número de Figma y estado) y cómo se
/// llega a ella. [alFinal] deja correr lo pendiente (relojes del Splash).
class Escena {
  const Escena(this.nombre, this.llegar, {this.alFinal});

  final String nombre;
  final Llegar llegar;
  final Future<void> Function(WidgetTester tester)? alFinal;
}

List<Tarjeta> get _mazo => MockTarjetas.tarjetasPorSprint[sprintMock]!;

Tarjeta _primeraQue(bool Function(Tarjeta) prueba) => _mazo.firstWhere(prueba);

Tarjeta get _conMicro => _primeraQue((t) => t.microPregunta != null);
Tarjeta get _conEvidencia => _primeraQue((t) => t.tipo == TipoTarjeta.evidencia);
Tarjeta get _dilema => _primeraQue((t) => t.tipo == TipoTarjeta.justificacion);
Tarjeta get _normal => _primeraQue((t) => t.tipo == TipoTarjeta.normal && t.microPregunta == null);

Veredicto _otro(Veredicto v) => v == Veredicto.legal ? Veredicto.ilegal : Veredicto.legal;

Finder _veredicto(Veredicto v) =>
    find.byWidgetPredicate((w) => w is BotonVeredicto && w.veredicto == v);

Finder _comodin(String nombre) =>
    find.byWidgetPredicate((w) => w is PildoraComodin && w.nombre == nombre);

Future<void> pulsar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f.first);
  await tester.pumpAndSettle();
  await tester.tap(f.first);
  await tester.pumpAndSettle();
}

Future<void> _juego(WidgetTester tester, Ajustes a, Size t, List<Tarjeta> tarjetas) =>
    abrirJuego(tester, tamano: t, ajustes: a, tarjetas: {sprintMock: tarjetas});

Future<void> _ruta(
  WidgetTester tester,
  Ajustes a,
  Size t,
  String ruta, {
  bool conSesion = true,
  ServicioConexion? conexion,
  MockApelaciones? apelaciones,
  MockVidas? vidas,
}) => abrirJuego(
  tester,
  ruta: ruta,
  tamano: t,
  ajustes: a,
  conSesion: conSesion,
  conexion: conexion,
  apelaciones: apelaciones,
  vidasRepo: vidas,
);

Future<void> _crisis(WidgetTester tester, Ajustes a, Size t, {bool empezarExamen = true}) async {
  final reloj = jefe.RelojFalso();
  final vidas = MockVidas(espera: Duration.zero);
  await abrirJuego(
    tester,
    ruta: Rutas.crisisJefeDe('mod-1'),
    vidasRepo: vidas,
    examen: jefe.servidor(vidas, reloj),
    crearCronometro: reloj.crear,
    ajustes: a,
    tamano: t,
  );
  if (empezarExamen) await pulsar(tester, find.byKey(const ValueKey('boton-enfrentar')));
}

/// Acceso, bienvenida y onboarding (01 a 06).
final escenasAcceso = <Escena>[
  Escena(
    '01 Splash',
    (tester, a, t) async {
      await abrirJuego(
        tester,
        ruta: Rutas.splash,
        tamano: t,
        ajustes: a,
        conSesion: false,
        esperar: false,
      );
    },
    alFinal: (tester) async {
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    },
  ),
  for (var pagina = 0; pagina < 4; pagina++)
    Escena('0${pagina + 2} Onboarding ${pagina + 1}', (tester, a, t) async {
      await _ruta(tester, a, t, Rutas.onboarding, conSesion: false);
      for (var i = 0; i < pagina; i++) {
        await pulsar(tester, find.byType(BotonApp).last);
      }
    }),
  Escena('05 Inicio de sesión', (tester, a, t) async {
    await _ruta(tester, a, t, Rutas.inicioSesion, conSesion: false);
  }),
  Escena('05 Inicio de sesión con errores', (tester, a, t) async {
    await _ruta(tester, a, t, Rutas.inicioSesion, conSesion: false);
    await pulsar(tester, find.byType(BotonApp).first);
  }),
  Escena('06 Registro', (tester, a, t) async {
    await _ruta(tester, a, t, Rutas.registro, conSesion: false);
  }),
  Escena('06 Registro con errores', (tester, a, t) async {
    await _ruta(tester, a, t, Rutas.registro, conSesion: false);
    await pulsar(tester, find.byType(BotonApp).first);
  }),
];

/// Navegación principal y cuenta (07 a 09, 24 a 26).
final escenasNavegacion = <Escena>[
  Escena('07 Inicio', (tester, a, t) => _ruta(tester, a, t, Rutas.inicio)),
  Escena('08 Mapa de sprints', (tester, a, t) => _ruta(tester, a, t, Rutas.mapaSprintsDe('mod-1'))),
  Escena(
    '09 Intro del sprint',
    (tester, a, t) => _ruta(tester, a, t, Rutas.introSprintDe('mod-1', sprintMock)),
  ),
  Escena('24 Tienda', (tester, a, t) => _ruta(tester, a, t, Rutas.tienda)),
  Escena('24 Tienda · confirmar compra', (tester, a, t) async {
    await _ruta(tester, a, t, Rutas.tienda);
    await pulsar(tester, find.byKey(const ValueKey('articulo-lupa')));
    final precio = find.descendant(
      of: find.byKey(const ValueKey('articulo-lupa')),
      matching: find.bySemanticsLabel(RegExp('Comprar')),
    );
    if (find.byKey(const ValueKey('dialogo-confirmacion')).evaluate().isEmpty) {
      await pulsar(tester, precio);
    }
  }),
  Escena(
    '24 Tienda sin conexión',
    (tester, a, t) => _ruta(
      tester,
      a,
      t,
      Rutas.tienda,
      conexion: ConexionSimulada(inicial: EstadoConexion.sinConexion),
    ),
  ),
  Escena('25 Perfil', (tester, a, t) => _ruta(tester, a, t, Rutas.perfil)),
  Escena('25 Perfil · cerrar sesión', (tester, a, t) async {
    await _ruta(tester, a, t, Rutas.perfil);
    await pulsar(tester, find.byKey(const ValueKey('menu-cerrar-sesion')));
  }),
  Escena('26 Ajustes', (tester, a, t) => _ruta(tester, a, t, Rutas.ajustes)),
  Escena('26 Ajustes · tamaño de texto', (tester, a, t) async {
    await _ruta(tester, a, t, Rutas.ajustes);
    await pulsar(tester, find.byKey(const ValueKey('ajuste-tamano')));
  }),
];

/// El juego y sus estados (10 a 18, 10b, 10c, 14b, 19, 19b, 20 y 23).
final escenasJuego = <Escena>[
  Escena('10 Tarjeta normal', (tester, a, t) => _juego(tester, a, t, [_normal, _conMicro])),
  Escena('11 Previsualizar Ilegal', (tester, a, t) async {
    await _juego(tester, a, t, [_normal, _conMicro]);
    tester.state<MazoSwipeState>(find.byType(MazoSwipe)).previsualizar(Veredicto.ilegal);
    await tester.pumpAndSettle();
  }),
  Escena('12 Veredicto correcto con micro-pregunta', (tester, a, t) async {
    await _juego(tester, a, t, [_conMicro, _normal]);
    await pulsar(tester, _veredicto(_conMicro.respuestaCorrecta));
  }),
  Escena('14 Veredicto incorrecto', (tester, a, t) async {
    await _juego(tester, a, t, [_normal, _conMicro]);
    await pulsar(tester, _veredicto(_otro(_normal.respuestaCorrecta)));
  }),
  Escena('12c Respuesta parcial', (tester, a, t) async {
    await _juego(tester, a, t, [
      fin.tarjeta('p1', Veredicto.legal),
      fin.tarjeta('p2', Veredicto.legal),
    ]);
    await pulsar(tester, _veredicto(Veredicto.escalar));
  }),
  Escena('15 Tarjeta con evidencia', (tester, a, t) => _juego(tester, a, t, [_conEvidencia])),
  Escena('16 Visor de evidencia', (tester, a, t) async {
    await _juego(tester, a, t, [_conEvidencia]);
    await pulsar(tester, find.byKey(const ValueKey('boton-evidencia')));
  }),
  Escena('17 Tarjeta de justificación', (tester, a, t) => _juego(tester, a, t, [_dilema])),
  Escena('18 Justificar veredicto', (tester, a, t) async {
    await _juego(tester, a, t, [_dilema]);
    await pulsar(tester, _veredicto(_dilema.respuestaCorrecta));
  }),
  Escena('10b Lupa de Auditor', (tester, a, t) async {
    await _juego(tester, a, t, [_normal, _conMicro]);
    await pulsar(tester, _comodin(Textos.comodinLupa));
  }),
  Escena('10c Abogado Senior', (tester, a, t) async {
    await _juego(tester, a, t, [_normal, _conMicro]);
    await pulsar(tester, _comodin(Textos.comodinAbogado));
  }),
  Escena('14b Amparo', (tester, a, t) async {
    await _juego(tester, a, t, [_normal, _conMicro]);
    await pulsar(tester, _comodin(Textos.comodinAmparo));
    await pulsar(tester, _veredicto(_otro(_normal.respuestaCorrecta)));
  }),
  Escena('Juego · salir', (tester, a, t) async {
    await _juego(tester, a, t, [_normal]);
    await pulsar(tester, find.bySemanticsLabel(Textos.salir));
  }),
  Escena('19 Sprint completado', (tester, a, t) async {
    await abrirJuego(tester, tamano: t, ajustes: a, tarjetas: fin.mazoLegal(2));
    await fin.responder(tester, Veredicto.legal);
    await fin.responder(tester, Veredicto.ilegal);
  }),
  Escena('19b Startup en quiebra', (tester, a, t) async {
    await abrirJuego(
      tester,
      tamano: t,
      ajustes: a,
      tarjetas: {
        sprintMock: [
          fin.tarjeta(
            't1',
            Veredicto.legal,
            fallo: const ImpactoTarjeta(presupuesto: -10, riesgoLegal: 80),
          ),
          fin.tarjeta('t2', Veredicto.legal),
        ],
      },
    );
    await fin.responder(tester, Veredicto.ilegal);
  }),
  Escena(
    '20 Sin vidas',
    (tester, a, t) => _ruta(
      tester,
      a,
      t,
      Rutas.sinVidasDe('mod-1'),
      vidas: MockVidas(espera: Duration.zero, cantidad: 0),
    ),
  ),
  Escena('23 Sin conexión', (tester, a, t) async {
    await abrirJuego(
      tester,
      tamano: t,
      ajustes: a,
      conexion: ConexionSimulada(inicial: EstadoConexion.sinConexion),
    );
  }),
];

/// Buzón y juicio (21, 21 vacío, 22, 22b).
final escenasBuzon = <Escena>[
  Escena('21 Buzón', (tester, a, t) => _ruta(tester, a, t, Rutas.buzon, apelaciones: servidor())),
  Escena(
    '21 Buzón vacío',
    (tester, a, t) => _ruta(tester, a, t, Rutas.buzon, apelaciones: servidor(conSemilla: false)),
  ),
  Escena(
    '22 Juicio de apelación',
    (tester, a, t) =>
        _ruta(tester, a, t, Rutas.juicioApelacionDe('ape-001'), apelaciones: servidor()),
  ),
  Escena('22b Apelación ganada', (tester, a, t) async {
    await _ruta(tester, a, t, Rutas.juicioApelacionDe('ape-001'), apelaciones: servidor());
    // ape-001 del mock: la respuesta correcta es Ilegal.
    await pulsar(tester, _veredicto(Veredicto.ilegal));
  }),
  Escena('22b Apelación perdida', (tester, a, t) async {
    await _ruta(tester, a, t, Rutas.juicioApelacionDe('ape-001'), apelaciones: servidor());
    await pulsar(tester, _veredicto(Veredicto.legal));
  }),
];

/// Examen Final (27 a 30).
final escenasExamen = <Escena>[
  Escena('27 Crisis', (tester, a, t) => _crisis(tester, a, t, empezarExamen: false)),
  const Escena('28 Decisión de crisis', _crisis),
  Escena('28b Contraargumento', (tester, a, t) async {
    await _crisis(tester, a, t);
    await jefe.elegir(tester, jefe.escenario[0].respuestaCorrecta);
  }),
  Escena('28c Golpe al Jefe', (tester, a, t) async {
    await _crisis(tester, a, t);
    await jefe.elegir(tester, jefe.escenario[0].respuestaCorrecta);
    await tester.tap(find.byKey(ValueKey('fundamento-${jefe.escenario[0].fundamentoCorrecto}')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }, alFinal: jefe.pasarChip),
  Escena('28 Fallo', (tester, a, t) async {
    await _crisis(tester, a, t);
    await jefe.elegir(tester, jefe.incorrecto(jefe.escenario[0].respuestaCorrecta));
  }, alFinal: jefe.pasarChip),
  Escena('Examen · salir', (tester, a, t) async {
    await _crisis(tester, a, t);
    await pulsar(tester, find.bySemanticsLabel(Textos.salir));
  }),
  Escena('Examen · pausa (tiempo extendido)', (tester, a, t) async {
    await _crisis(tester, a.copyWith(tiempoExtendido: true), t);
    await pulsar(tester, find.byKey(const ValueKey('boton-pausa')));
  }),
  Escena('29 Auditoría superada', (tester, a, t) async {
    await empezar(tester, tamano: t, ajustes: a);
    await ganar(tester);
    await tester.pumpAndSettle();
  }),
  Escena('30 La Inspectora ganó', (tester, a, t) async {
    await empezar(tester, tamano: t, ajustes: a);
    await perderPorVidas(tester, 5);
    await tester.pumpAndSettle();
  }),
];
