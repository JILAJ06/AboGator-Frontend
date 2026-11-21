import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/piezas_ajustes.dart';
import 'package:abogator/componentes/sarko_imagen.dart';
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
import '../../ayudantes/tamano_pantalla.dart';
import '../juego/ayudante_juego.dart';

Future<void> pulsar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Abre Ajustes y desde ahí Notificaciones (así "cerrar" regresa a Ajustes).
Future<AjustesEnMemoria> abrirNotificaciones(
  WidgetTester tester, {
  Size tamano = const Size(390, 844),
  Ajustes ajustes = const Ajustes(),
  AjustesEnMemoria? repo,
}) async {
  final r = repo ?? AjustesEnMemoria();
  await abrirJuego(tester, ruta: Rutas.ajustes, tamano: tamano, ajustes: ajustes, repoAjustes: r);
  await pulsar(tester, find.byKey(const ValueKey('ajuste-notificaciones')));
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
      await pulsar(tester, find.byKey(const ValueKey('notif-racha')));
      expect((await guardadas(repo)).rachaEnRiesgo, isFalse);
      await pulsar(tester, find.byKey(const ValueKey('interruptor-recordatorio')));
      expect((await guardadas(repo)).recordatorioDiario, isTrue);
    });

    testWidgets('"Activar notificaciones" guarda, marca decidido y vuelve a Ajustes', (
      tester,
    ) async {
      final repo = await abrirNotificaciones(tester);
      await pulsar(tester, find.byKey(const ValueKey('boton-activar-notificaciones')));
      final n = await guardadas(repo);
      expect(n.activadas, isTrue);
      expect(n.decidido, isTrue);
      expect(find.byType(PantallaAjustes), findsOneWidget);
    });

    testWidgets('"Ahora no" guarda apagadas y vuelve', (tester) async {
      final repo = await abrirNotificaciones(tester);
      await pulsar(tester, find.byKey(const ValueKey('boton-ahora-no')));
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
      await pulsar(tester, find.byKey(const ValueKey('fila-hora-recordatorio')));
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
      await pulsar(tester, find.byKey(const ValueKey('fila-hora-recordatorio')));
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
      await pulsar(tester, find.byKey(const ValueKey('fila-hora-recordatorio')));
      await pulsar(tester, find.byKey(const ValueKey('mas-hora')));
      await pulsar(tester, find.byKey(const ValueKey('mas-minutos')));
      await pulsar(tester, find.byKey(const ValueKey('mas-minutos')));
      await pulsar(tester, find.byKey(const ValueKey('boton-guardar-hora')));
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
      await pulsar(tester, find.byKey(const ValueKey('fila-hora-recordatorio')));
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
      await pulsar(tester, find.byKey(const ValueKey('fila-hora-recordatorio')));
      final datos = tester.getSemantics(find.bySemanticsLabel(Textos.ruedaHora)).getSemanticsData();
      expect(datos.value, '7');
      expect(datos.increasedValue, '8');
      expect(datos.decreasedValue, '6');
      semantica.dispose();
    });
  });

  group('tablet', () {
    testWidgets('34 en 1194×834: columna de 470 centrada', (tester) async {
      await abrirNotificaciones(tester, tamano: Tamano.tabletHorizontal.medida);
      final tarjeta = tester.getRect(find.byKey(const ValueKey('tarjeta-notificaciones')));
      expect(tarjeta.width, 470);
      expect(tarjeta.center.dx, closeTo(1194 / 2, 1));
    });
  });
}
