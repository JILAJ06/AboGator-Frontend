import 'package:abogator/componentes/indicadores_startup.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/mocks/mock_progreso.dart';
import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:abogator/datos/mocks/mock_tienda.dart';
import 'package:abogator/datos/mocks/mock_vidas.dart';
import 'package:abogator/datos/modelos/estado_startup.dart';
import 'package:abogator/datos/modelos/modulo.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/funciones/juego/estado_juego.dart';
import 'package:abogator/funciones/juego/logica_fin_sprint.dart';
import 'package:abogator/funciones/juego/logica_veredicto.dart';
import 'package:flutter_test/flutter_test.dart';

ResultadoTarjeta r(TipoVeredicto tipo, {bool bonus = false}) =>
    ResultadoTarjeta(tarjetaId: 't', tipo: tipo, bonus: bonus);

const inicio = EstadoStartup(presupuesto: 70, reputacion: 60, velocidad: 50, riesgoLegal: 25);

void main() {
  group('estrellas por porcentaje de aciertos', () {
    test('≥ 90 % da 3, ≥ 60 % da 2 y menos da 1', () {
      int e(int aciertos, int total) => LogicaFinSprint.estrellas(aciertos: aciertos, total: total);
      expect(e(10, 10), 3);
      expect(e(9, 10), 3);
      // Como en Figma 19: 8 de 10 aciertos dan 2 estrellas.
      expect(e(8, 10), 2);
      expect(e(7, 10), 2);
      expect(e(6, 10), 2);
      expect(e(5, 10), 1);
      expect(e(0, 10), 1);
    });

    test('límites exactos de 90 % y 60 %', () {
      int e(int aciertos, int total) => LogicaFinSprint.estrellas(aciertos: aciertos, total: total);
      expect(e(90, 100), 3);
      expect(e(89, 100), 2);
      expect(e(60, 100), 2);
      expect(e(59, 100), 1);
      // 8 tarjetas: 8/8 = 100 %, 7/8 = 87.5 %, 5/8 = 62.5 %, 4/8 = 50 %.
      expect([for (var a = 4; a <= 8; a++) e(a, 8)], [1, 2, 2, 2, 3]);
    });

    test('completar da al menos 1 estrella, aun sin tarjetas', () {
      expect(LogicaFinSprint.estrellas(aciertos: 0, total: 0), 1);
    });
  });

  test('aciertos y falladas: el parcial no cuenta en ninguno', () {
    final resultados = [
      r(TipoVeredicto.correcto),
      r(TipoVeredicto.correcto, bonus: true),
      r(TipoVeredicto.parcial),
      r(TipoVeredicto.incorrecto),
      r(TipoVeredicto.amparo),
    ];
    expect(LogicaFinSprint.aciertos(resultados), 2);
    expect(LogicaFinSprint.falladas(resultados), 2);
  });

  test('cambios respecto al inicio, sin los indicadores que no cambiaron', () {
    const fin = EstadoStartup(presupuesto: 70, reputacion: 75, velocidad: 50, riesgoLegal: 30);
    expect(LogicaFinSprint.cambios(inicio, fin), {
      IndicadorStartup.reputacion: 15,
      IndicadorStartup.riesgoLegal: 5,
    });
    expect(LogicaFinSprint.cambios(inicio, inicio), isEmpty);
  });

  test('aviso del buzón para 0, 1, 2 y 3 o más falladas', () {
    expect(LogicaFinSprint.avisoBuzon(0), isNull);
    expect(
      LogicaFinSprint.avisoBuzon(1),
      '1 tarjeta fallada irá a apelación en 3 días. Resuélvela para recuperar una vida.',
    );
    expect(
      LogicaFinSprint.avisoBuzon(2),
      '2 tarjetas falladas irán a apelación en 3 y 7 días. Resuélvelas para recuperar vidas.',
    );
    expect(
      LogicaFinSprint.avisoBuzon(3),
      contains('3 tarjetas falladas irán a apelación en 3, 7 y 14 días'),
    );
    expect(
      LogicaFinSprint.avisoBuzon(5),
      startsWith('5 tarjetas falladas irán a apelación en 3, 7 y 14 días'),
    );
  });

  test('causa de la quiebra: Riesgo legal en 100, Presupuesto en 0 o ninguna', () {
    EstadoStartup e(int presupuesto, int riesgo) =>
        EstadoStartup(presupuesto: presupuesto, reputacion: 50, velocidad: 50, riesgoLegal: riesgo);
    expect(LogicaFinSprint.causaQuiebra(e(40, 100)), CausaQuiebra.riesgoLegal);
    expect(LogicaFinSprint.causaQuiebra(e(0, 50)), CausaQuiebra.presupuesto);
    expect(LogicaFinSprint.causaQuiebra(e(0, 100)), CausaQuiebra.riesgoLegal);
    expect(LogicaFinSprint.causaQuiebra(e(1, 99)), isNull);
  });

  test('descripción de la quiebra: la del sprint o una genérica según la causa', () {
    final aviso = MockProgreso.modulos.first.sprints[2];
    expect(
      LogicaFinSprint.descripcionQuiebra(aviso, CausaQuiebra.riesgoLegal),
      startsWith('Una auditoría encontró la librería GPL-3.0'),
    );
    final sinMensaje = MockProgreso.modulos[1].sprints.first;
    expect(
      LogicaFinSprint.descripcionQuiebra(sinMensaje, CausaQuiebra.riesgoLegal),
      Textos.quiebraGenericaRiesgo,
    );
    expect(
      LogicaFinSprint.descripcionQuiebra(null, CausaQuiebra.presupuesto),
      Textos.quiebraGenericaPresupuesto,
    );
  });

  group('guardado en los mocks', () {
    Sprint sprint(List<Modulo> modulos, String id) =>
        modulos.expand((m) => m.sprints).firstWhere((s) => s.id == id);

    test('registrar spr-1-3: completado con estrellas, spr-1-4 en curso y estado final', () async {
      final mock = MockProgreso(espera: Duration.zero);
      const fin = EstadoStartup(presupuesto: 70, reputacion: 75, velocidad: 50, riesgoLegal: 30);
      await mock.registrarSprintCompletado(sprintId: 'spr-1-3', estrellas: 2, estadoFinal: fin);
      final modulos = await mock.obtenerModulos();
      expect(sprint(modulos, 'spr-1-3').estado, EstadoSprint.completado);
      expect(sprint(modulos, 'spr-1-3').estrellas, 2);
      expect(sprint(modulos, 'spr-1-4').estado, EstadoSprint.enCurso);
      expect(sprint(modulos, 'spr-1-5').estado, EstadoSprint.bloqueado);
      expect(await mock.obtenerEstadoStartup(), fin);
      // Los demás datos del sprint se conservan.
      expect(sprint(modulos, 'spr-1-3').mensajeCompletado, isNotNull);
      expect(sprint(modulos, 'spr-1-3').numeroTarjetas, 10);
    });

    test('si ya estaba completado conserva el máximo de estrellas', () async {
      final mock = MockProgreso(espera: Duration.zero);
      await mock.registrarSprintCompletado(sprintId: 'spr-1-1', estrellas: 1, estadoFinal: inicio);
      expect(sprint(await mock.obtenerModulos(), 'spr-1-1').estrellas, 3);
      await mock.registrarSprintCompletado(sprintId: 'spr-1-3', estrellas: 1, estadoFinal: inicio);
      await mock.registrarSprintCompletado(sprintId: 'spr-1-3', estrellas: 3, estadoFinal: inicio);
      await mock.registrarSprintCompletado(sprintId: 'spr-1-3', estrellas: 2, estadoFinal: inicio);
      expect(sprint(await mock.obtenerModulos(), 'spr-1-3').estrellas, 3);
    });

    test('el último sprint no cambia el Examen final', () async {
      final mock = MockProgreso(espera: Duration.zero);
      await mock.registrarSprintCompletado(sprintId: 'spr-1-5', estrellas: 3, estadoFinal: inicio);
      final modulos = await mock.obtenerModulos();
      expect(sprint(modulos, 'spr-1-5').estado, EstadoSprint.completado);
      expect(sprint(modulos, 'spr-1-final').estado, EstadoSprint.bloqueado);
    });

    test('cada instancia empieza desde los datos iniciales', () async {
      final mock = MockProgreso(espera: Duration.zero);
      await mock.registrarSprintCompletado(sprintId: 'spr-1-3', estrellas: 3, estadoFinal: inicio);
      final otro = MockProgreso(espera: Duration.zero);
      expect(sprint(await otro.obtenerModulos(), 'spr-1-3').estado, EstadoSprint.enCurso);
      expect(await otro.obtenerEstadoStartup(), MockProgreso.estadoInicial);
      expect(sprint(MockProgreso.modulos, 'spr-1-3').estado, EstadoSprint.enCurso);
    });

    test('vidas: se guardan entre 0 y 5', () async {
      final mock = MockVidas(espera: Duration.zero);
      expect((await mock.guardarVidas(3)).cantidad, 3);
      expect((await mock.obtenerVidas()).cantidad, 3);
      expect((await mock.obtenerVidas()).faltaParaProxima, isNotNull);
      expect((await mock.guardarVidas(-2)).cantidad, 0);
      expect((await mock.guardarVidas(9)).cantidad, 5);
      expect((await MockVidas(espera: Duration.zero).obtenerVidas()).cantidad, 5);
    });

    test('monedas: se suman a las 240 iniciales', () async {
      final mock = MockTienda(espera: Duration.zero);
      expect(await mock.sumarMonedas(45), 285);
      expect(await mock.obtenerMonedas(), 285);
      expect(await MockTienda(espera: Duration.zero).obtenerMonedas(), 240);
    });
  });

  group('tarjetas del módulo 1', () {
    final modulo = MockProgreso.modulos.first;
    final sprints = modulo.sprints.where((s) => !s.esExamenFinal).toList();

    test('cada sprint tiene tantas tarjetas como su numeroTarjetas y su composición', () {
      expect(sprints, hasLength(5));
      for (final s in sprints) {
        final tarjetas = MockTarjetas.tarjetasPorSprint[s.id];
        expect(tarjetas, isNotNull, reason: s.id);
        int de(TipoTarjeta tipo) => tarjetas!.where((t) => t.tipo == tipo).length;
        expect(tarjetas, hasLength(s.numeroTarjetas), reason: s.id);
        expect(de(TipoTarjeta.normal), s.tarjetasNormales, reason: s.id);
        expect(de(TipoTarjeta.evidencia), s.tarjetasConEvidencia, reason: s.id);
        expect(de(TipoTarjeta.justificacion), s.dilemas, reason: s.id);
      }
    });

    test('cada tarjeta tiene caso, impactos y, si es de evidencia, su evidencia', () {
      final ids = <String>{};
      for (final s in sprints) {
        for (final (i, t) in MockTarjetas.tarjetasPorSprint[s.id]!.indexed) {
          expect(ids.add(t.id), isTrue, reason: 'id repetido: ${t.id}');
          expect(t.etiquetaCaso, startsWith('CASO ${i + 1} · '), reason: t.id);
          expect([t.personaje, t.rol, t.texto, t.explicacion], everyElement(isNotEmpty));
          expect(t.impactoAcierto, isNot(const ImpactoTarjeta()), reason: t.id);
          expect(t.impactoFallo, isNot(const ImpactoTarjeta()), reason: t.id);
          if (t.respuestaCorrecta != Veredicto.escalar) {
            expect(t.impactoParcial, isNot(const ImpactoTarjeta()), reason: t.id);
          }
          // Evidencia solo en las de evidencia y justificación solo en los dilemas.
          expect(t.evidencia != null, t.tipo == TipoTarjeta.evidencia, reason: t.id);
          expect(t.justificacion != null, t.tipo == TipoTarjeta.justificacion, reason: t.id);
          if (t.evidencia case final e?) {
            expect(e.archivo, isNotEmpty, reason: t.id);
            expect(e.lineas, isNotEmpty, reason: t.id);
            expect(e.lineas.any((l) => l.contains('\n')), isFalse, reason: t.id);
            expect(e.lineasClave, isNotEmpty, reason: t.id);
            expect(e.lineasClave, everyElement(inInclusiveRange(1, e.lineas.length)), reason: t.id);
            expect([e.mensajeAcierto, e.mensajeFallo], everyElement(isNotEmpty), reason: t.id);
          }
          if (t.justificacion case final j?) {
            expect(j.opciones, hasLength(3), reason: t.id);
            expect(j.indiceCorrecto, inInclusiveRange(0, 2), reason: t.id);
          }
        }
      }
    });

    test('la tarjeta 6 de spr-1-3 es el registro_form.dart de Figma 15 y 16b', () {
      final t = MockTarjetas.tarjetasPorSprint['spr-1-3']![5];
      expect(t.tipo, TipoTarjeta.evidencia);
      expect(t.etiquetaCaso, 'CASO 6 · PROTECCIÓN DE DATOS');
      expect(t.respuestaCorrecta, Veredicto.ilegal);
      final e = t.evidencia!;
      expect(e.archivo, 'registro_form.dart');
      expect(e.lineas, hasLength(7));
      expect(e.lineas[3], 'Checkbox(value: true, // pre-marcado');
      expect(e.lineasClave, [4, 5, 6]);
      expect(
        e.mensajeAcierto,
        'Marcaste la casilla pre-marcada y el aviso de privacidad faltante. Ahora regresa a la '
        'tarjeta y dicta tu veredicto.',
      );
    });

    test('la tarjeta 10 de spr-1-3 es el dilema de contraseñas de Figma 17 y 18', () {
      final t = MockTarjetas.tarjetasPorSprint['spr-1-3']![9];
      expect(t.tipo, TipoTarjeta.justificacion);
      expect(t.etiquetaCaso, 'CASO 10 · DILEMA CLAVE');
      expect(t.respuestaCorrecta, Veredicto.ilegal);
      expect(t.justificacion!.indiceCorrecto, 0);
      expect(t.justificacion!.opciones, [
        'Las contraseñas son datos personales y deben guardarse con hash (bcrypt), nunca en '
            'texto plano.',
        'Porque el cliente no firmó un contrato de confidencialidad.',
        'Solo sería ilegal si ocurre una filtración de datos.',
      ]);
    });

    test('ninguna tarjeta menciona plazos ni montos legales con cifra', () {
      const numero =
          r'(\d+|un|una|dos|tres|cuatro|cinco|seis|siete|ocho|nueve|diez|quince|veinte|treinta)';
      final cifra = RegExp(
        r'\b' +
            numero +
            r'\s+(días?|semanas?|mes|meses|horas?|pesos)\b|\bhace\s+\w+\s+años?\b|\$\s*\d',
        caseSensitive: false,
      );
      // La expresión sí detecta los casos que se quitaron.
      for (final viejo in [
        'lleva más de dos meses sin respuesta',
        '¿Cobramos 500 pesos?',
        'facturas de hace dos años',
        'en 72 horas',
      ]) {
        expect(cifra.hasMatch(viejo), isTrue, reason: viejo);
      }
      // Una edad no es un plazo.
      expect(cifra.hasMatch('usuarios tienen 15 años'), isFalse);
      for (final t in MockTarjetas.tarjetasPorSprint.values.expand((l) => l)) {
        final textos = [
          t.texto,
          t.explicacion,
          ?t.explicacionFallo,
          ?t.explicacionParcial,
          ...?t.evidencia?.lineas,
          ?t.evidencia?.mensajeAcierto,
          ?t.evidencia?.mensajeFallo,
          ...?t.justificacion?.opciones,
          ...t.palabrasTrampa,
          ?t.traduccionLegal,
          ...t.normas,
          ?t.titulo,
          ?t.tema,
          ?t.microPregunta?.enunciado,
          ...?t.microPregunta?.opciones,
        ];
        for (final texto in textos) {
          expect(cifra.hasMatch(texto), isFalse, reason: '${t.id}: $texto');
        }
      }
    });

    test('2 micro-preguntas por sprint, solo en tarjetas normales y con 2 o 3 opciones', () {
      for (final s in sprints) {
        final conPregunta = MockTarjetas.tarjetasPorSprint[s.id]!
            .where((t) => t.microPregunta != null)
            .toList();
        expect(conPregunta.length, 2, reason: s.id);
        expect(conPregunta.map((t) => t.tipo), everyElement(TipoTarjeta.normal), reason: s.id);
        for (final t in conPregunta) {
          final p = t.microPregunta!;
          expect(p.opciones.length, inInclusiveRange(2, 3), reason: t.id);
          expect(p.indiceCorrecto, inInclusiveRange(0, p.opciones.length - 1), reason: t.id);
        }
      }
    });

    test('cada sprint tiene su mensaje de completado y de quiebra', () {
      for (final s in sprints) {
        expect(s.mensajeCompletado, isNotEmpty, reason: s.id);
        expect(s.mensajeQuiebra, isNotEmpty, reason: s.id);
      }
      expect(
        sprints[2].mensajeCompletado,
        'Tu MVP ya cumple con el aviso de privacidad y la Startup sigue en pie.',
      );
    });

    test('la GPL-3.0 es la tarjeta 5 de spr-1-3 y spr-2-1 se queda con su tarjeta MIT', () {
      expect(MockTarjetas.tarjetasPorSprint['spr-1-3']![4].id, 'tar-gpl-01');
      expect(MockTarjetas.tarjetasPorSprint['spr-2-1']!.map((t) => t.id), ['tar-mit-02']);
    });
  });
}
