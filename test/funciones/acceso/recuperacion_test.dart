import 'package:abogator/app/enrutador.dart';
import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/ilustracion_insignia.dart';
import 'package:abogator/componentes/sarko_imagen.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/mocks/mock_autenticacion.dart';
import 'package:abogator/funciones/acceso/pantalla_inicio_sesion.dart';
import 'package:abogator/funciones/acceso/recuperacion/estado_recuperacion.dart';
import 'package:abogator/funciones/acceso/recuperacion/pantallas_recuperacion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../auditoria/ayudante_auditoria.dart';
import '../../ayudantes/tamano_pantalla.dart';
import '../juego/ayudante_juego.dart';

Finder get campoCorreo => find.descendant(
  of: find.byKey(const ValueKey('campo-correo-recuperacion')),
  matching: find.byType(EditableText),
);

Finder campo(String clave) =>
    find.descendant(of: find.byKey(ValueKey(clave)), matching: find.byType(EditableText));

Future<void> pulsar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<MockAutenticacion> abrirRecuperacion(
  WidgetTester tester, {
  String ruta = Rutas.recuperar,
  Size tamano = const Size(390, 844),
}) async {
  final auth = MockAutenticacion(espera: Duration.zero);
  await abrirJuego(tester, ruta: ruta, tamano: tamano, conSesion: false, autenticacion: auth);
  return auth;
}

BotonApp boton(WidgetTester tester, String clave) =>
    tester.widget<BotonApp>(find.byKey(ValueKey(clave)));

void main() {
  group('31 Recuperar contraseña', () {
    testWidgets('título, Sarko sorprendido, campo, nota, botones y pie', (tester) async {
      await abrirRecuperacion(tester);
      expect(find.text(Textos.recuperarTitulo), findsOneWidget);
      expect(tester.widget<SarkoImagen>(find.byType(SarkoImagen)).pose, PoseSarko.sorprendido);
      expect(find.text(Textos.recuperarDescripcion), findsOneWidget);
      expect(find.text(Textos.recuperarNota), findsOneWidget);
      expect(find.text(Textos.enviarEnlace), findsOneWidget);
      expect(find.text(Textos.volverAIniciarSesion), findsOneWidget);
      expect(find.text(Textos.enlaceCaducaEn), findsOneWidget);
      // El pie queda abajo (y ≈ 750 en Figma).
      expect(tester.getTopLeft(find.text(Textos.enlaceCaducaEn)).dy, greaterThan(700));
      // Atrás arriba a la izquierda (x 24).
      expect(tester.getTopLeft(find.bySemanticsLabel(Textos.atras)).dx, 24);
    });

    testWidgets('correo vacío o inválido: error anunciado y foco en el campo', (tester) async {
      final auth = await abrirRecuperacion(tester);
      await pulsar(tester, find.byKey(const ValueKey('boton-enviar-enlace')));
      expect(find.text(Textos.errorCorreo), findsOneWidget);
      expect(enfocadoDentroDe(find.byKey(const ValueKey('campo-correo-recuperacion'))), isTrue);
      await tester.enterText(campoCorreo, 'no-es-correo');
      await pulsar(tester, find.byKey(const ValueKey('boton-enviar-enlace')));
      expect(find.text(Textos.errorCorreo), findsOneWidget);
      expect(auth.solicitudesRecuperacion, isEmpty);
    });

    testWidgets('correo válido: pide el enlace y pasa a 31b con el correo', (tester) async {
      final auth = await abrirRecuperacion(tester);
      await tester.enterText(campoCorreo, '  ana@ejemplo.mx ');
      await pulsar(tester, find.byKey(const ValueKey('boton-enviar-enlace')));
      expect(auth.solicitudesRecuperacion, ['ana@ejemplo.mx']);
      expect(find.byType(PantallaCorreoEnviado), findsOneWidget);
      expect(find.text(Textos.enlaceEnviadoA('ana@ejemplo.mx')), findsOneWidget);
    });

    testWidgets('"Volver a iniciar sesión" y atrás regresan al inicio de sesión', (tester) async {
      await abrirRecuperacion(tester);
      await pulsar(tester, find.byKey(const ValueKey('boton-volver-inicio-sesion')));
      expect(find.byType(PantallaInicioSesion), findsOneWidget);
    });
  });

  group('31b Revisa tu correo', () {
    Future<void> llegar(WidgetTester tester, {Size tamano = const Size(390, 844)}) async {
      await abrirRecuperacion(tester, tamano: tamano);
      await tester.enterText(campoCorreo, 'ana@ejemplo.mx');
      await pulsar(tester, find.byKey(const ValueKey('boton-enviar-enlace')));
    }

    testWidgets('ilustración con Sarko alegre e insignia de correo', (tester) async {
      await llegar(tester);
      expect(find.byType(IlustracionInsignia), findsOneWidget);
      expect(tester.getSize(find.byType(IlustracionInsignia)), const Size(260, 260));
      expect(find.bySemanticsLabel(Textos.insigniaCorreo), findsOneWidget);
      expect(find.text(Textos.revisaSpam), findsOneWidget);
    });

    testWidgets('reenviar: cuenta de 45 s, se habilita, se anuncia una vez y reinicia', (
      tester,
    ) async {
      final anuncios = capturarAnuncios(tester);
      await llegar(tester);
      expect(find.text(Textos.reenviarEnlaceEn(45)), findsOneWidget);
      expect(boton(tester, 'boton-reenviar').alPresionar, isNull);
      await tester.pump(const Duration(seconds: 15));
      expect(find.text(Textos.reenviarEnlaceEn(30)), findsOneWidget);
      await tester.pump(const Duration(seconds: 30));
      expect(find.text(Textos.reenviarEnlace), findsOneWidget);
      expect(boton(tester, 'boton-reenviar').alPresionar, isNotNull);
      await tester.pump(const Duration(seconds: 5));
      expect(anuncios.where((a) => a == Textos.reenvioDisponible), hasLength(1));
      await pulsar(tester, find.byKey(const ValueKey('boton-reenviar')));
      expect(anuncios, contains(Textos.enlaceReenviado));
      expect(find.text(Textos.reenviarEnlaceEn(45)), findsOneWidget);
    });

    testWidgets('"Abrir correo" abre 31c con el token de demostración', (tester) async {
      await llegar(tester);
      await pulsar(tester, find.byKey(const ValueKey('boton-abrir-correo')));
      final pantalla = tester.widget<PantallaNuevaContrasena>(find.byType(PantallaNuevaContrasena));
      expect(pantalla.token, tokenDemoRecuperacion);
    });
  });

  group('31c Nueva contraseña', () {
    Future<void> abrir(WidgetTester tester, String token) =>
        abrirRecuperacion(tester, ruta: Rutas.recuperarNuevaCon(token));

    testWidgets('cerrar (X), ayuda de la regla y dos campos con ojo', (tester) async {
      await abrir(tester, 'demo');
      expect(find.bySemanticsLabel(Textos.cerrar), findsOneWidget);
      expect(find.text(Textos.ayudaNuevaContrasena), findsOneWidget);
      expect(find.bySemanticsLabel(Textos.mostrarContrasena), findsNWidgets(2));
    });

    testWidgets('regla incumplida: error y foco en la nueva', (tester) async {
      await abrir(tester, 'demo');
      await tester.enterText(campo('campo-nueva-contrasena'), 'corta');
      await tester.enterText(campo('campo-confirmar-contrasena'), 'corta');
      await pulsar(tester, find.byKey(const ValueKey('boton-guardar-contrasena')));
      expect(find.text(Textos.errorContrasenaRegistro), findsOneWidget);
      expect(enfocadoDentroDe(find.byKey(const ValueKey('campo-nueva-contrasena'))), isTrue);
    });

    testWidgets('no coinciden: error y foco en confirmar', (tester) async {
      await abrir(tester, 'demo');
      await tester.enterText(campo('campo-nueva-contrasena'), 'segura123');
      await tester.enterText(campo('campo-confirmar-contrasena'), 'segura124');
      await pulsar(tester, find.byKey(const ValueKey('boton-guardar-contrasena')));
      expect(find.text(Textos.errorContrasenasNoCoinciden), findsOneWidget);
      expect(enfocadoDentroDe(find.byKey(const ValueKey('campo-confirmar-contrasena'))), isTrue);
    });

    testWidgets('válida: 31d y "Iniciar sesión" vuelve al inicio de sesión', (tester) async {
      await abrir(tester, 'demo');
      await tester.enterText(campo('campo-nueva-contrasena'), 'segura123');
      await tester.enterText(campo('campo-confirmar-contrasena'), 'segura123');
      await pulsar(tester, find.byKey(const ValueKey('boton-guardar-contrasena')));
      expect(find.byKey(const ValueKey('recuperacion-listo')), findsOneWidget);
      expect(find.text(Textos.contrasenaActualizadaTitulo), findsOneWidget);
      expect(find.bySemanticsLabel(Textos.insigniaListo), findsOneWidget);
      await pulsar(tester, find.byKey(const ValueKey('boton-iniciar-sesion-recuperacion')));
      expect(find.byType(PantallaInicioSesion), findsOneWidget);
    });

    testWidgets('token caducado: 31e y "Pedir un enlace nuevo" vuelve a 31 con el correo', (
      tester,
    ) async {
      await abrirRecuperacion(tester);
      await tester.enterText(campoCorreo, 'ana@ejemplo.mx');
      await pulsar(tester, find.byKey(const ValueKey('boton-enviar-enlace')));
      expect(contenedorDe(tester).read(recuperacionProvider).correo, 'ana@ejemplo.mx');
      // Abre el enlace caducado (como el enlace profundo del correo).
      contenedorDe(tester)
          .read(enrutadorProvider)
          .go(Rutas.recuperarNuevaCon(MockAutenticacion.tokenCaducado));
      await tester.pumpAndSettle();
      await tester.enterText(campo('campo-nueva-contrasena'), 'segura123');
      await tester.enterText(campo('campo-confirmar-contrasena'), 'segura123');
      await pulsar(tester, find.byKey(const ValueKey('boton-guardar-contrasena')));
      expect(find.byKey(const ValueKey('recuperacion-caducado')), findsOneWidget);
      expect(find.text(Textos.enlaceCaducadoTitulo), findsOneWidget);
      expect(tester.widget<SarkoImagen>(find.byType(SarkoImagen)).pose, PoseSarko.triste);
      await pulsar(tester, find.byKey(const ValueKey('boton-pedir-enlace')));
      expect(find.byType(PantallaRecuperar), findsOneWidget);
      expect(tester.widget<EditableText>(campoCorreo).controller.text, 'ana@ejemplo.mx');
    });
  });

  group('tablet', () {
    testWidgets('31 en 1194×834: panel de marca con Sarko sorprendido y columna de 470', (
      tester,
    ) async {
      await abrirRecuperacion(tester, tamano: Tamano.tabletHorizontal.medida);
      expect(find.byKey(const ValueKey('panel-marca')), findsOneWidget);
      expect(
        tester.widget<SarkoImagen>(find.byKey(const ValueKey('sarko-panel-marca'))).pose,
        PoseSarko.sorprendido,
      );
      expect(tester.getSize(find.byKey(const ValueKey('formulario-recuperacion'))).width, 470);
    });

    testWidgets('31e en 834×1194: franja de marca con Sarko triste', (tester) async {
      await abrirRecuperacion(
        tester,
        ruta: Rutas.recuperarCaducado,
        tamano: Tamano.tabletVertical.medida,
      );
      expect(find.byKey(const ValueKey('franja-marca')), findsOneWidget);
      expect(tester.widget<SarkoImagen>(find.byType(SarkoImagen)).pose, PoseSarko.triste);
    });
  });
}
