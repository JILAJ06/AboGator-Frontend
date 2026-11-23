import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/boton_atras.dart';
import 'package:abogator/componentes/disposicion_ilustracion_tablet.dart';
import 'package:abogator/componentes/icono_app.dart';
import 'package:abogator/componentes/ilustracion_insignia.dart';
import 'package:abogator/componentes/piezas_ajustes.dart';
import 'package:abogator/componentes/sarko_imagen.dart';
import 'package:abogator/core/tema/iconos_app.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/mocks/ajustes_en_memoria.dart';
import 'package:abogator/datos/modelos/ajustes.dart';
import 'package:abogator/datos/modelos/ajustes_notificaciones.dart';
import 'package:abogator/datos/repositorios/repositorio_ajustes.dart';
import 'package:abogator/funciones/ajustes/pantalla_ajustes.dart';
import 'package:abogator/funciones/notificaciones/pantalla_notificaciones.dart';
import 'package:abogator/funciones/notificaciones/selector_hora.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../auditoria/ayudante_auditoria.dart';
import '../../ayudantes/montar.dart';
import '../../ayudantes/tamano_pantalla.dart';
import '../juego/ayudante_juego.dart';

/// Abre Ajustes y desde ahí Notificaciones (así "cerrar" regresa a Ajustes).
Future<AjustesEnMemoria> abrirNotificaciones(
  WidgetTester tester, {
  Size tamano = const Size(390, 844),
  Ajustes ajustes = const Ajustes(),
  AjustesEnMemoria? repo,
}) async {
  final r = repo ?? AjustesEnMemoria();
  await abrirJuego(tester, ruta: Rutas.ajustes, tamano: tamano, ajustes: ajustes, repoAjustes: r);
  await tocar(tester, find.byKey(const ValueKey('ajuste-notificaciones')));
  expect(find.byType(PantallaNotificaciones), findsOneWidget);
  return r;
}

Future<AjustesNotificaciones> guardadas(AjustesEnMemoria repo) => repo.cargarNotificaciones();

void main() {
  group('LogicaHora', () {
    test('formato de 12 horas con a. m. y p. m.', () {
      expect(LogicaHora.formatear(19 * 60), '7:00 p. m.');
      expect(LogicaHora.formatear(0), '12:00 a. m.');
      expect(LogicaHora.formatear(12 * 60 + 5), '12:05 p. m.');
      expect(LogicaHora.formatear(9 * 60 + 30), '9:30 a. m.');
    });

    test('partes y componer son inversas', () {
      for (var m = 0; m < 24 * 60; m += 5) {
        final p = LogicaHora.partes(m);
        expect(LogicaHora.componer(hora: p.hora, indiceMinuto: p.indiceMinuto, pm: p.pm), m);
      }
    });
  });

  group('CodecNotificaciones', () {
    test('ida y vuelta, y valores inválidos toman el por defecto', () {
      const n = AjustesNotificaciones(
        rachaEnRiesgo: false,
        recordatorioDiario: true,
        minutosRecordatorio: 8 * 60 + 15,
        activadas: true,
        decidido: true,
      );
      expect(CodecNotificaciones.deMapa(CodecNotificaciones.aMapa(n)), n);
      expect(
        CodecNotificaciones.deMapa({CodecNotificaciones.minutosRecordatorio: '7'}),
        const AjustesNotificaciones(),
      );
      expect(CodecNotificaciones.deMapa({}), const AjustesNotificaciones());
    });
  });

  group('34 Protege tu racha', () {
    testWidgets('título, Sarko alegre, tres filas con sus valores y botones', (tester) async {
      await abrirNotificaciones(tester);
      expect(find.text(Textos.protegeTuRacha), findsOneWidget);
      expect(tester.widget<SarkoImagen>(find.byType(SarkoImagen)).pose, PoseSarko.alegre);
      expect(find.text(Textos.rachaEnRiesgo), findsOneWidget);
      expect(find.text(Textos.juiciosApelacion), findsOneWidget);
      expect(find.text(Textos.recordatorioDiarioDetalle('7:00 p. m.')), findsOneWidget);
      final interruptores = tester
          .widgetList<InterruptorApp>(find.byType(InterruptorApp))
          .map((i) => (i.valor, i.grande))
          .toList();
      expect(interruptores, [(true, true), (true, true), (false, true)]);
      expect(tester.getSize(find.byKey(const ValueKey('interruptor')).first), const Size(52, 32));
      expect(find.text(Textos.notificacionesNota), findsOneWidget);
      expect(find.text(Textos.activarNotificaciones), findsOneWidget);
      expect(find.text(Textos.ahoraNo), findsOneWidget);
    });

    testWidgets('los interruptores se guardan al instante', (tester) async {
      final repo = await abrirNotificaciones(tester);
      await tocar(tester, find.byKey(const ValueKey('notif-racha')));
      expect((await guardadas(repo)).rachaEnRiesgo, isFalse);
      await tocar(tester, find.byKey(const ValueKey('interruptor-recordatorio')));
      expect((await guardadas(repo)).recordatorioDiario, isTrue);
    });

    testWidgets('"Activar notificaciones" guarda, marca decidido y vuelve a Ajustes', (
      tester,
    ) async {
      final repo = await abrirNotificaciones(tester);
      await tocar(tester, find.byKey(const ValueKey('boton-activar-notificaciones')));
      final n = await guardadas(repo);
      expect(n.activadas, isTrue);
      expect(n.decidido, isTrue);
      expect(find.byType(PantallaAjustes), findsOneWidget);
    });

    testWidgets('"Ahora no" guarda apagadas y vuelve', (tester) async {
      final repo = await abrirNotificaciones(tester);
      await tocar(tester, find.byKey(const ValueKey('boton-ahora-no')));
      final n = await guardadas(repo);
      expect(n.activadas, isFalse);
      expect(n.decidido, isTrue);
      expect(find.byType(PantallaAjustes), findsOneWidget);
    });

    testWidgets('la fila y el interruptor del recordatorio son dos controles con nombre', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await abrirNotificaciones(tester);
      expect(find.bySemanticsLabel(Textos.cambiarHoraSemantica('7:00 p. m.')), findsOneWidget);
      expect(find.bySemanticsLabel(Textos.recordatorioDiario), findsOneWidget);
      semantica.dispose();
    });
  });

  group('34c Hora del recordatorio', () {
    testWidgets('móvil: hoja inferior con radio 28, agarre y tres ruedas', (tester) async {
      await abrirNotificaciones(tester);
      await tocar(tester, find.byKey(const ValueKey('fila-hora-recordatorio')));
      expect(find.byType(BottomSheet), findsOneWidget);
      final caja = tester.widget<Container>(find.byKey(const ValueKey('selector-hora')));
      expect(
        (caja.decoration! as BoxDecoration).borderRadius,
        const BorderRadius.vertical(top: Radius.circular(28)),
      );
      expect(find.byType(RuedaSelector), findsNWidgets(3));
      expect(find.text(Textos.horaRecordatorio), findsOneWidget);
      // Sin "Solo botones" no hay + y −.
      expect(find.byKey(const ValueKey('mas-hora')), findsNothing);
    });

    testWidgets('tablet: diálogo centrado de 440 como máximo', (tester) async {
      await abrirNotificaciones(tester, tamano: Tamano.tabletHorizontal.medida);
      await tocar(tester, find.byKey(const ValueKey('fila-hora-recordatorio')));
      expect(find.byType(Dialog), findsOneWidget);
      final r = tester.getRect(find.byKey(const ValueKey('selector-hora')));
      expect(r.width, lessThanOrEqualTo(SelectorHora.anchoDialogo));
      expect(r.center.dx, closeTo(1194 / 2, 1));
    });

    testWidgets('"Solo botones": + y − cambian la hora; Guardar enciende, anuncia y devuelve el '
        'foco', (tester) async {
      final anuncios = capturarAnuncios(tester);
      final repo = await abrirNotificaciones(
        tester,
        ajustes: const Ajustes(soloBotones: true, reducirAnimaciones: true),
      );
      await tocar(tester, find.byKey(const ValueKey('fila-hora-recordatorio')));
      await tocar(tester, find.byKey(const ValueKey('mas-hora')));
      await tocar(tester, find.byKey(const ValueKey('mas-minutos')));
      await tocar(tester, find.byKey(const ValueKey('mas-minutos')));
      await tocar(tester, find.byKey(const ValueKey('boton-guardar-hora')));
      final n = await guardadas(repo);
      expect(n.minutosRecordatorio, 20 * 60 + 10);
      expect(n.recordatorioDiario, isTrue);
      expect(anuncios, contains(Textos.recordatorioGuardado('8:10 p. m.')));
      expect(find.text(Textos.recordatorioDiarioDetalle('8:10 p. m.')), findsOneWidget);
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'fila recordatorio diario');
    });

    testWidgets('teclado: ↑ aumenta la rueda enfocada y Esc cancela sin guardar', (tester) async {
      final repo = await abrirNotificaciones(
        tester,
        ajustes: const Ajustes(reducirAnimaciones: true),
      );
      await tocar(tester, find.byKey(const ValueKey('fila-hora-recordatorio')));
      // Tab hasta la primera rueda (la de la hora).
      var enRueda = false;
      for (var i = 0; i < 4 && !enRueda; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        enRueda = enfocadoDentroDe(find.byKey(const ValueKey('ruedas-hora')));
      }
      expect(enRueda, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(
        tester.widget<RuedaSelector>(find.byType(RuedaSelector).first).indice,
        7, // de 7 a 8 (índice 7)
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('selector-hora')), findsNothing);
      expect((await guardadas(repo)).minutosRecordatorio, AjustesNotificaciones.horaPorDefecto);
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'fila recordatorio diario');
    });

    testWidgets('las ruedas son ajustables para el lector', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrirNotificaciones(tester);
      await tocar(tester, find.byKey(const ValueKey('fila-hora-recordatorio')));
      final datos = tester.getSemantics(find.bySemanticsLabel(Textos.ruedaHora)).getSemanticsData();
      expect(datos.value, '7');
      expect(datos.increasedValue, '8');
      expect(datos.decreasedValue, '6');
      semantica.dispose();
    });
  });

  group('filas sin íconos (Figma 34, ronda 2)', () {
    for (final t in [Tamano.movil, Tamano.tabletHorizontal]) {
      testWidgets('ninguna fila lleva ícono y el texto empieza en x16 o x20 (${t.name})', (
        tester,
      ) async {
        await abrirNotificaciones(tester, tamano: t.medida);
        final tarjeta = find.byKey(const ValueKey('tarjeta-notificaciones'));
        expect(find.descendant(of: tarjeta, matching: find.byType(IconoApp)), findsNothing);
        final borde = tester.getRect(tarjeta).left;
        final relleno = t == Tamano.movil ? 16.0 : 20.0;
        for (final texto in [
          Textos.rachaEnRiesgo,
          Textos.juiciosApelacion,
          Textos.recordatorioDiario,
        ]) {
          expect(
            tester.getTopLeft(find.descendant(of: tarjeta, matching: find.text(texto))).dx - borde,
            closeTo(relleno, 1.5),
          );
        }
      });
    }
  });

  group('tablet (T34, Figma 150:5709)', () {
    testWidgets('1194×834: panel de 597 con círculo de 340, Sarko de 230 e insignia de 84', (
      tester,
    ) async {
      await abrirNotificaciones(tester, tamano: Tamano.tabletHorizontal.medida);
      final panel = tester.getRect(find.byKey(const ValueKey('panel-ilustracion-tablet')));
      expect(panel.left, 0);
      expect(panel.width, DisposicionIlustracionTablet.anchoPanel);
      expect(panel.height, 834);
      final color = tester
          .widget<ColoredBox>(find.byKey(const ValueKey('panel-ilustracion-tablet')))
          .color;
      expect(color, TokensColor.claro.fondoDestacado);
      // La ilustración a escala 1, centrada en el panel.
      final ilustracion = tester.getRect(find.byKey(const ValueKey('ilustracion-racha')));
      expect(ilustracion.width, closeTo(IlustracionRacha.circulo + 1, 0.5));
      expect(ilustracion.center.dx, closeTo(panel.center.dx, 1));
      final sarko = find.descendant(
        of: find.byKey(const ValueKey('ilustracion-racha')),
        matching: find.byType(SarkoImagen),
      );
      expect(tester.getSize(sarko).width, closeTo(230, 0.5));
      expect(tester.widget<SarkoImagen>(sarko).pose, PoseSarko.alegre);
      final insignia = tester.widget<InsigniaCircular>(
        find.byKey(const ValueKey('insignia-racha')),
      );
      expect(insignia.diametro, 84);
      expect(insignia.icono, IconosApp.flame);
      expect(insignia.tamanoIcono, 40);
      // Atrás en el panel, con margen de 32.
      final atras = tester.getRect(find.byType(BotonAtras));
      expect(atras.topLeft, const Offset(32, 32));
      expect(atras.size, const Size(48, 48));
    });

    testWidgets('1194×834: columna de 470 a la derecha, sin Sarko ni atrás dentro', (tester) async {
      await abrirNotificaciones(tester, tamano: Tamano.tabletHorizontal.medida);
      final columna = find.byKey(const ValueKey('columna-notificaciones'));
      final r = tester.getRect(columna);
      expect(r.width, 470);
      expect(r.center.dx, closeTo(597 + (1194 - 597) / 2, 1));
      expect(find.descendant(of: columna, matching: find.byType(SarkoImagen)), findsNothing);
      expect(find.descendant(of: columna, matching: find.byType(BotonAtras)), findsNothing);
      expect(tester.getSize(find.byKey(const ValueKey('tarjeta-notificaciones'))).width, 470);
      // El atrás del panel cierra.
      await tocar(tester, find.byType(BotonAtras));
      expect(find.byType(PantallaAjustes), findsOneWidget);
    });

    for (final t in [Tamano.tabletVertical, Tamano.tabletMinima]) {
      testWidgets('${t.name}: franja arriba con la ilustración reducida y la columna debajo', (
        tester,
      ) async {
        await abrirNotificaciones(tester, tamano: t.medida);
        final franja = tester.getRect(find.byKey(const ValueKey('panel-ilustracion-tablet')));
        expect(franja.width, t.medida.width);
        expect(franja.height, DisposicionIlustracionTablet.altoFranja);
        final ilustracion = tester.getRect(find.byKey(const ValueKey('ilustracion-racha')));
        expect(ilustracion.height, lessThan(franja.height));
        final columna = tester.getRect(find.byKey(const ValueKey('columna-notificaciones')));
        expect(columna.top, greaterThanOrEqualTo(franja.bottom));
        expect(columna.width, 470);
      });
    }

    testWidgets('el selector de hora sigue siendo el diálogo de 440', (tester) async {
      await abrirNotificaciones(tester, tamano: Tamano.tabletHorizontal.medida);
      await tocar(tester, find.byKey(const ValueKey('fila-hora-recordatorio')));
      expect(find.byType(Dialog), findsOneWidget);
    });
  });
}
