import 'package:abogator/app/enrutador.dart';
import 'package:abogator/app/pantalla_pendiente.dart';
import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/dialogo_confirmacion.dart';
import 'package:abogator/componentes/navegacion_inferior_app.dart';
import 'package:abogator/componentes/piezas_perfil.dart';
import 'package:abogator/core/tema/colores_marca.dart';
import 'package:abogator/core/tema/efectos.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:abogator/datos/mocks/mock_perfil.dart';
import 'package:abogator/datos/modelos/insignia.dart';
import 'package:abogator/datos/modelos/respuesta_pendiente.dart';
import 'package:abogator/datos/modelos/resumen_perfil.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/datos/modelos/usuario.dart';
import 'package:abogator/datos/repositorios/repositorio_autenticacion.dart';
import 'package:abogator/datos/repositorios/repositorio_perfil.dart';
import 'package:abogator/datos/sincronizacion/estado_sincronizacion.dart';
import 'package:abogator/datos/sincronizacion/servicio_conexion.dart';
import 'package:abogator/funciones/acceso/pantalla_inicio_sesion.dart';
import 'package:abogator/funciones/acceso/sesion.dart';
import 'package:abogator/funciones/apelaciones/sesion_apelaciones.dart';
import 'package:abogator/funciones/perfil/logica_perfil.dart';
import 'package:abogator/funciones/perfil/pantalla_perfil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../ayudantes/montar.dart';
import '../juego/ayudante_juego.dart';

Future<void> tocar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Autenticación que cuenta los cierres y puede fallar.
class AutenticacionDePrueba implements RepositorioAutenticacion {
  AutenticacionDePrueba({this.fallar = false});

  bool fallar;
  int cierres = 0;

  @override
  Future<void> cerrarSesion() async {
    if (fallar) throw Exception('sin red');
    cierres++;
  }

  @override
  Future<Usuario> iniciarSesion({required String correo, required String contrasena}) async => ana;

  @override
  Future<Usuario> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
    required PerfilUsuario perfil,
    required bool aceptaAvisoPrivacidad,
    required bool aceptaTerminos,
  }) async => ana;

  @override
  Future<Usuario?> usuarioActual() async => ana;
}

/// Perfil con insignias de sobra (para el desplazamiento horizontal).
class PerfilConMuchasInsignias implements RepositorioPerfil {
  @override
  Future<ResumenPerfil> obtenerPerfil() async => ResumenPerfil(
    usuario: ana,
    precision: 82,
    certificados: 0,
    certificadosTotales: 5,
    sprintsPerfectos: 12,
    insignias: [
      for (var i = 0; i < 7; i++)
        Insignia(
          id: 'i$i',
          nombre: 'Insignia $i',
          icono: 'star',
          moduloId: 'mod-1',
          desbloqueada: true,
        ),
    ],
  );
}

Future<AutenticacionDePrueba> abrirPerfil(
  WidgetTester tester, {
  AutenticacionDePrueba? autenticacion,
  RepositorioPerfil? perfil,
  Size tamano = const Size(390, 844),
  ServicioConexion? conexion,
}) async {
  final a = autenticacion ?? AutenticacionDePrueba();
  await abrirJuego(
    tester,
    ruta: Rutas.perfil,
    autenticacion: a,
    perfil: perfil ?? MockPerfil(espera: Duration.zero, autenticacion: a),
    tamano: tamano,
    conexion: conexion,
  );
  return a;
}

void main() {
  group('LogicaPerfil y MockPerfil', () {
    test('iniciales', () {
      expect(LogicaPerfil.iniciales('Ana López'), 'AL');
      expect(LogicaPerfil.iniciales('ana'), 'A');
      expect(LogicaPerfil.iniciales('María José Pérez'), 'MJ');
      expect(LogicaPerfil.iniciales('  Ángel   Úrsula '), 'ÁÚ');
      expect(LogicaPerfil.iniciales(''), '');
    });

    test('XP con separador de miles y rol neutro', () {
      expect(LogicaPerfil.miles(0), '0');
      expect(LogicaPerfil.miles(999), '999');
      expect(LogicaPerfil.miles(1250), '1,250');
      expect(LogicaPerfil.miles(1234567), '1,234,567');
      expect(
        LogicaPerfil.detalle(
          const Usuario(
            id: 'x',
            nombre: 'Ana López',
            correo: 'a@b.mx',
            perfil: PerfilUsuario.desarrollador,
            nivel: 4,
            xp: 1250,
            racha: 7,
          ),
        ),
        'Desarrollador · Nivel 4 · 1,250 XP',
      );
      expect(LogicaPerfil.rol(PerfilUsuario.estudiante), Textos.perfilEstudiante);
      expect(LogicaPerfil.rol(PerfilUsuario.legal), Textos.perfilLegal);
    });

    test('resumen del mock (Ana López)', () async {
      final r = await MockPerfil(espera: Duration.zero).obtenerPerfil();
      expect(r.usuario.nombre, 'Ana López');
      expect(r.usuario.racha, 7);
      expect(r.usuario.nivel, 4);
      expect(r.usuario.xp, 1250);
      expect(r.precision, 82);
      expect((r.certificados, r.certificadosTotales), (0, 5));
      expect(r.sprintsPerfectos, 12);
      expect(
        [for (final i in r.insignias) (i.nombre, i.icono, i.moduloId, i.desbloqueada)],
        [
          ('Guardián de datos', 'shield-check', 'mod-1', true),
          ('Racha de 7', 'flame', 'mod-2', true),
          ('Sprint perfecto', 'star', 'mod-4', true),
          ('Abogado de código', 'lock', null, false),
        ],
      );
    });
  });

  group('25 · Perfil', () {
    for (final brillo in Brightness.values) {
      testWidgets('estructura y textos de Figma (${brillo.name})', (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = brillo;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        await abrirPerfil(tester);
        expect(find.byType(PantallaPerfil), findsOneWidget);
        expect(find.text(Textos.perfilTitulo), findsOneWidget);
        expect(find.bySemanticsLabel(Textos.accesibilidadYAjustes), findsOneWidget);
        expect(find.text('AL'), findsOneWidget);
        expect(find.text('Ana López'), findsOneWidget);
        // Ana del ayudante tiene 0 XP.
        expect(find.text('Desarrollador · Nivel 4 · 0 XP'), findsOneWidget);
        expect(find.text('7 días'), findsOneWidget);
        expect(find.text('82%'), findsOneWidget);
        expect(find.text('0 / 5'), findsOneWidget);
        expect(find.text('12'), findsOneWidget);
        expect(find.bySemanticsLabel('Racha actual: 7 días'), findsOneWidget);
        expect(find.bySemanticsLabel('Certificados: 0 de 5'), findsOneWidget);
        expect(find.text(Textos.insigniasTitulo), findsOneWidget);
        expect(find.byType(MedallaInsignia), findsNWidgets(4));
        expect(find.bySemanticsLabel('Guardián de datos, obtenida'), findsOneWidget);
        expect(find.bySemanticsLabel('Abogado de código, bloqueada'), findsOneWidget);
        for (final t in [
          Textos.menuAccesibilidad,
          Textos.menuNotificacionesRacha,
          Textos.menuAvisoPrivacidad,
          Textos.cerrarSesion,
        ]) {
          expect(find.text(t), findsOneWidget);
        }
        expect(
          tester.widget<NavegacionInferiorApp>(find.byType(NavegacionInferiorApp)).actual,
          PestanaApp.perfil,
        );
        expect(tester.getSize(find.byKey(const ValueKey('boton-ajustes'))), const Size(48, 48));
        // Tres divisores entre cuatro filas (sin divisor al final).
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('menu-perfil')),
            matching: find.byType(Divider),
          ),
          findsNWidgets(3),
        );
        for (final k in [
          'menu-accesibilidad',
          'menu-notificaciones',
          'menu-aviso',
          'menu-cerrar-sesion',
        ]) {
          expect(tester.getSize(find.byKey(ValueKey(k))).height, greaterThanOrEqualTo(48));
        }
        esperarSoloColoresDelTema(tester, brillo);
      });
    }

    testWidgets('las medallas usan el color del módulo', (tester) async {
      await abrirPerfil(tester);
      BoxDecoration fondo(String id) =>
          tester
                  .widget<Container>(
                    find
                        .descendant(
                          of: find.byKey(ValueKey('insignia-$id')),
                          matching: find.byType(Container),
                        )
                        .first,
                  )
                  .decoration!
              as BoxDecoration;
      expect(fondo('ins-guardian').color, ColoresModulo.proteccionDeDatos);
      expect(fondo('ins-racha-7').color, ColoresModulo.licenciasYPropiedadIntelectual);
      expect(fondo('ins-sprint-perfecto').color, ColoresModulo.contratosDigitales);
    });

    testWidgets('con muchas insignias la fila se desplaza sin encoger la medalla', (tester) async {
      await abrirPerfil(tester, perfil: PerfilConMuchasInsignias());
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(const ValueKey('insignia-i0'))).width,
        MedallaInsignia.ancho,
      );
      final fila = find.byKey(const ValueKey('insignias'));
      await tester.drag(fila, const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(const ValueKey('insignia-i0'))).left, lessThan(0));
    });

    for (final (clave, ruta, texto) in [
      ('menu-notificaciones', Rutas.notificacionesRacha, Textos.pendienteNotificacionesRacha),
      ('menu-aviso', Rutas.avisoPrivacidad, Textos.pendienteAvisoPrivacidad),
    ]) {
      testWidgets('$clave va a $ruta sin barra inferior y atrás vuelve', (tester) async {
        await abrirPerfil(tester);
        await tocar(tester, find.byKey(ValueKey(clave)));
        expect(rutaActual(tester), ruta);
        expect(find.text(texto), findsOneWidget);
        expect(find.byType(PantallaPendiente), findsOneWidget);
        expect(find.byType(NavegacionInferiorApp), findsNothing);
        await tocar(tester, find.bySemanticsLabel(Textos.atras));
        expect(rutaActual(tester), Rutas.perfil);
        expect(find.byType(PantallaPerfil), findsOneWidget);
      });
    }

    testWidgets('atrás del sistema desde ajustes vuelve al Perfil', (tester) async {
      await abrirPerfil(tester);
      await tocar(tester, find.byKey(const ValueKey('boton-ajustes')));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(rutaActual(tester), Rutas.perfil);
    });

    testWidgets('cerrar sesión: cancelar no hace nada', (tester) async {
      final a = await abrirPerfil(tester);
      await tocar(tester, find.byKey(const ValueKey('menu-cerrar-sesion')));
      expect(find.text(Textos.confirmarCerrarSesionTitulo), findsOneWidget);
      expect(find.text(Textos.confirmarCerrarSesionTexto), findsOneWidget);
      await tocar(tester, find.byKey(const ValueKey('boton-cancelar')));
      expect(find.byType(DialogoConfirmacion), findsNothing);
      expect(a.cierres, 0);
      expect(rutaActual(tester), Rutas.perfil);
    });

    testWidgets('cerrar sesión con respuestas guardadas lo avisa', (tester) async {
      await abrirPerfil(tester, conexion: ConexionSimulada(inicial: EstadoConexion.sinConexion));
      final c = contenedorDe(tester);
      for (final id in ['r1', 'r2']) {
        await c
            .read(respuestasPendientesProvider.notifier)
            .agregar(
              RespuestaPendiente(
                id: id,
                sprintId: sprintMock,
                tarjetaId: 't-$id',
                veredicto: Veredicto.legal,
                respondidaEn: DateTime.utc(2026, 11, 20),
              ),
            );
      }
      await tester.pumpAndSettle();
      await tocar(tester, find.byKey(const ValueKey('menu-cerrar-sesion')));
      expect(
        find.textContaining(
          'Tienes 2 respuestas guardadas en este dispositivo; se enviarán cuando vuelvas a entrar.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('cerrar sesión: limpia la sesión y va al inicio de sesión', (tester) async {
      final a = await abrirPerfil(tester);
      final c = contenedorDe(tester);
      c.read(sesionApelacionesProvider.notifier).iniciar(['ape-001']);
      await tocar(tester, find.byKey(const ValueKey('menu-cerrar-sesion')));
      await tocar(tester, find.byKey(const ValueKey('boton-confirmar')));
      expect(a.cierres, 1);
      expect(c.read(sesionProvider), isNull);
      expect(c.read(sesionApelacionesProvider), isNull);
      expect(find.byType(PantallaInicioSesion), findsOneWidget);
      // Sin sesión, el Perfil ya no se puede abrir.
      c.read(enrutadorProvider).go(Rutas.perfil);
      await tester.pumpAndSettle();
      expect(find.byType(PantallaInicioSesion), findsOneWidget);
    });

    testWidgets('si no se puede cerrar sesión, avisa y se queda', (tester) async {
      final a = await abrirPerfil(tester, autenticacion: AutenticacionDePrueba(fallar: true));
      await tocar(tester, find.byKey(const ValueKey('menu-cerrar-sesion')));
      await tocar(tester, find.byKey(const ValueKey('boton-confirmar')));
      expect(find.text(Textos.errorCerrarSesion), findsOneWidget);
      expect(contenedorDe(tester).read(sesionProvider), isNotNull);
      expect(rutaActual(tester), Rutas.perfil);
      a.fallar = false;
    });

    testWidgets('sin sesión redirige al inicio de sesión', (tester) async {
      await abrirJuego(tester, ruta: Rutas.perfil, conSesion: false);
      expect(find.byType(PantallaInicioSesion), findsOneWidget);
    });

    testWidgets('las pestañas Tienda y Perfil conservan la barra', (tester) async {
      await abrirPerfil(tester);
      await tocar(
        tester,
        find.descendant(of: find.byType(NavegacionInferiorApp), matching: find.text('Tienda')),
      );
      expect(rutaActual(tester), Rutas.tienda);
      expect(
        tester.widget<NavegacionInferiorApp>(find.byType(NavegacionInferiorApp)).actual,
        PestanaApp.tienda,
      );
      await tocar(
        tester,
        find.descendant(of: find.byType(NavegacionInferiorApp), matching: find.text('Perfil')),
      );
      expect(rutaActual(tester), Rutas.perfil);
    });

    test('contrastes AA', () {
      for (final t in [TokensColor.claro, TokensColor.oscuro]) {
        expect(Contraste.razon(t.textoEnPrimario, t.accionPrimaria), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.textoSecundario, t.fondoSuperficieAlt), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.estadoIlegal, t.fondoSuperficie), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.accionSecundaria, t.fondoDestacado), greaterThanOrEqualTo(4.5));
      }
      for (final c in ColoresModulo.enOrden) {
        expect(Contraste.razon(EfectosApp.iconoSobreModulo, c), greaterThanOrEqualTo(3));
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
          await abrirPerfil(tester, tamano: tamano);
          expect(tester.takeException(), isNull);
          await tester.drag(
            find.byKey(const ValueKey('perfil-desplazable')),
            const Offset(0, -3000),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.text(Textos.cerrarSesion), findsOneWidget);
        });
      }
    });
  });
}
