import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:abogator/datos/modelos/estado_startup.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/funciones/juego/logica_veredicto.dart';
import 'package:flutter_test/flutter_test.dart';

/// La tarjeta de la GPL-3.0 con los valores de Figma.
final gpl = MockTarjetas.tarjetasPorSprint['spr-2-1']!.firstWhere((t) => t.id == 'tar-gpl-01');

const estadoBase = EstadoStartup(presupuesto: 70, reputacion: 60, velocidad: 50, riesgoLegal: 25);

void main() {
  group('calificar', () {
    test('correcto: +10 XP, +5 monedas e impacto de acierto (Figma 12)', () {
      final r = LogicaVeredicto.calificar(gpl, Veredicto.ilegal);
      expect(r.tipo, TipoVeredicto.correcto);
      expect((r.xp, r.monedas, r.pierdeVida, r.bonus), (10, 5, false, false));
      expect(r.impacto, const ImpactoTarjeta(reputacion: 5, riesgoLegal: -10));
      expect(r.esFallo, isFalse);
    });

    test('bonus: +5 XP más (15), mismas monedas e impacto', () {
      final r = LogicaVeredicto.calificar(gpl, Veredicto.ilegal).conBonus();
      expect((r.xp, r.monedas, r.bonus), (15, 5, true));
      expect(r.impacto, gpl.impactoAcierto);
      expect(LogicaVeredicto.aciertaMicroPregunta(gpl.microPregunta!, 0), isTrue);
      expect(LogicaVeredicto.aciertaMicroPregunta(gpl.microPregunta!, 1), isFalse);
    });

    test('parcial: Escalar cuando no era Escalar: +3 XP, sin vida (Figma 12c)', () {
      final r = LogicaVeredicto.calificar(gpl, Veredicto.escalar);
      expect(r.tipo, TipoVeredicto.parcial);
      expect((r.xp, r.monedas, r.pierdeVida), (3, 0, false));
      expect(r.impacto, const ImpactoTarjeta(presupuesto: -5, velocidad: -10));
      expect(r.esFallo, isFalse);
    });

    test('no hay parcial para Condicional ni para Legal: son incorrectos', () {
      for (final v in [Veredicto.condicional, Veredicto.legal]) {
        final r = LogicaVeredicto.calificar(gpl, v);
        expect(r.tipo, TipoVeredicto.incorrecto, reason: v.name);
      }
    });

    test('Escalar cuando sí era Escalar es correcto', () {
      final escalar = MockTarjetas.tarjetasPorSprint['spr-1-3']!.firstWhere(
        (t) => t.respuestaCorrecta == Veredicto.escalar,
      );
      expect(LogicaVeredicto.calificar(escalar, Veredicto.escalar).tipo, TipoVeredicto.correcto);
    });

    test('incorrecto: 0 XP, 0 monedas, −1 vida e impacto de fallo (Figma 14)', () {
      final r = LogicaVeredicto.calificar(gpl, Veredicto.legal);
      expect((r.xp, r.monedas, r.pierdeVida), (0, 0, true));
      expect(r.impacto, const ImpactoTarjeta(velocidad: 10, riesgoLegal: 25));
      expect(r.esFallo, isTrue);
    });

    test('Amparo: sin vida perdida y el Riesgo legal sube 5 menos (Figma 14b: +20)', () {
      final r = LogicaVeredicto.calificar(gpl, Veredicto.legal, amparoActivo: true);
      expect(r.tipo, TipoVeredicto.amparo);
      expect((r.xp, r.monedas, r.pierdeVida), (0, 0, false));
      expect(r.impacto, const ImpactoTarjeta(velocidad: 10, riesgoLegal: 20));
      expect(r.esFallo, isTrue);
    });

    test('Amparo no baja de 0 el aumento del Riesgo legal', () {
      const tarjeta = Tarjeta(
        id: 't',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO',
        personaje: 'P',
        rol: 'R',
        texto: 'T',
        respuestaCorrecta: Veredicto.legal,
        explicacion: 'E',
        impactoFallo: ImpactoTarjeta(riesgoLegal: 3),
      );
      final r = LogicaVeredicto.calificar(tarjeta, Veredicto.ilegal, amparoActivo: true);
      expect(r.impacto.riesgoLegal, 0);
    });

    test('con Amparo activo, un acierto o un parcial no cambian', () {
      expect(
        LogicaVeredicto.calificar(gpl, Veredicto.ilegal, amparoActivo: true).tipo,
        TipoVeredicto.correcto,
      );
      expect(
        LogicaVeredicto.calificar(gpl, Veredicto.escalar, amparoActivo: true).tipo,
        TipoVeredicto.parcial,
      );
    });
  });

  group('indicadores', () {
    test('aplicar suma el impacto', () {
      final e = LogicaVeredicto.aplicar(
        estadoBase,
        const ImpactoTarjeta(velocidad: 10, riesgoLegal: 25),
      );
      expect((e.presupuesto, e.reputacion, e.velocidad, e.riesgoLegal), (70, 60, 60, 50));
    });

    test('los indicadores se quedan entre 0 y 100', () {
      final e = LogicaVeredicto.aplicar(
        estadoBase,
        const ImpactoTarjeta(presupuesto: -200, reputacion: 90, riesgoLegal: 500),
      );
      expect((e.presupuesto, e.reputacion, e.riesgoLegal), (0, 100, 100));
    });

    test('quiebra con Riesgo legal en 100 o Presupuesto en 0', () {
      expect(LogicaVeredicto.haQuebrado(estadoBase), isFalse);
      expect(
        LogicaVeredicto.haQuebrado(
          const EstadoStartup(presupuesto: 50, reputacion: 50, velocidad: 50, riesgoLegal: 100),
        ),
        isTrue,
      );
      expect(
        LogicaVeredicto.haQuebrado(
          const EstadoStartup(presupuesto: 0, reputacion: 50, velocidad: 50, riesgoLegal: 10),
        ),
        isTrue,
      );
    });
  });

  test('destino con prioridad: quiebra → sin vidas → última → siguiente', () {
    const quebrada = EstadoStartup(presupuesto: 0, reputacion: 0, velocidad: 0, riesgoLegal: 0);
    expect(
      LogicaVeredicto.destino(estado: quebrada, vidas: 0, esUltima: true),
      DestinoVeredicto.quiebra,
    );
    expect(
      LogicaVeredicto.destino(estado: estadoBase, vidas: 0, esUltima: true),
      DestinoVeredicto.sinVidas,
    );
    expect(
      LogicaVeredicto.destino(estado: estadoBase, vidas: 2, esUltima: true),
      DestinoVeredicto.sprintCompletado,
    );
    expect(
      LogicaVeredicto.destino(estado: estadoBase, vidas: 2, esUltima: false),
      DestinoVeredicto.siguiente,
    );
  });

  test('explicación según el resultado (textos de Figma en la tarjeta GPL)', () {
    expect(
      LogicaVeredicto.explicacion(gpl, TipoVeredicto.correcto),
      startsWith('La licencia GPL-3.0 es copyleft'),
    );
    expect(
      LogicaVeredicto.explicacion(gpl, TipoVeredicto.parcial),
      startsWith('Escalar a jurídico no está mal'),
    );
    expect(
      LogicaVeredicto.explicacion(gpl, TipoVeredicto.incorrecto),
      startsWith('Usar código GPL-3.0'),
    );
    expect(
      LogicaVeredicto.explicacion(gpl, TipoVeredicto.amparo),
      LogicaVeredicto.explicacion(gpl, TipoVeredicto.incorrecto),
    );
  });

  test('mock: las 10 tarjetas del sprint en curso tienen impactos y 4 micro-preguntas', () {
    final tarjetas = MockTarjetas.tarjetasPorSprint['spr-1-3']!;
    expect(tarjetas, hasLength(10));
    for (final t in tarjetas) {
      expect(t.impactoAcierto, isNot(const ImpactoTarjeta()), reason: t.id);
      expect(t.impactoFallo, isNot(const ImpactoTarjeta()), reason: t.id);
    }
    final conPregunta = tarjetas.where((t) => t.microPregunta != null).toList();
    expect(conPregunta, hasLength(4));
    for (final t in conPregunta) {
      final p = t.microPregunta!;
      expect(p.opciones.length, inInclusiveRange(2, 3));
      expect(p.indiceCorrecto, inInclusiveRange(0, p.opciones.length - 1));
    }
    expect(gpl.microPregunta!.opciones.first, 'La GPL-3.0 obliga a liberar el código derivado');
  });
}
