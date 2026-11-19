import 'dart:ui';

import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/funciones/juego/logica_swipe.dart';
import 'package:flutter_test/flutter_test.dart';

const ancho = 342.0;

void main() {
  test('el eje se decide al pasar 12 dp y gana el componente mayor', () {
    expect(LogicaSwipe.decidirEje(const Offset(8, 8)), isNull);
    expect(LogicaSwipe.decidirEje(const Offset(12, 3)), EjeSwipe.horizontal);
    expect(LogicaSwipe.decidirEje(const Offset(-3, -12)), EjeSwipe.vertical);
    expect(LogicaSwipe.decidirEje(const Offset(10, 10)), EjeSwipe.horizontal);
  });

  test('el desplazamiento se queda sobre el eje bloqueado', () {
    expect(LogicaSwipe.sobreEje(EjeSwipe.horizontal, const Offset(40, 25)), const Offset(40, 0));
    expect(LogicaSwipe.sobreEje(EjeSwipe.vertical, const Offset(40, -25)), const Offset(0, -25));
    expect(LogicaSwipe.sobreEje(null, const Offset(5, 5)), Offset.zero);
  });

  test('umbrales: 28 % del ancho en horizontal y 80 dp en vertical', () {
    expect(LogicaSwipe.umbral(EjeSwipe.horizontal, ancho), closeTo(95.76, 0.01));
    expect(LogicaSwipe.umbral(EjeSwipe.vertical, ancho), 80);
  });

  test('dirección → veredicto', () {
    expect(LogicaSwipe.veredictoDe(EjeSwipe.horizontal, const Offset(5, 0)), Veredicto.legal);
    expect(LogicaSwipe.veredictoDe(EjeSwipe.horizontal, const Offset(-5, 0)), Veredicto.ilegal);
    expect(LogicaSwipe.veredictoDe(EjeSwipe.vertical, const Offset(0, -5)), Veredicto.condicional);
    expect(LogicaSwipe.veredictoDe(EjeSwipe.vertical, const Offset(0, 5)), Veredicto.escalar);
    expect(LogicaSwipe.veredictoDe(EjeSwipe.vertical, Offset.zero), isNull);
    expect(LogicaSwipe.veredictoDe(null, const Offset(5, 0)), isNull);
    for (final v in Veredicto.values) {
      final previo = LogicaSwipe.desplazamientoPrevio(v, ancho);
      expect(LogicaSwipe.veredictoDe(LogicaSwipe.ejeDe(v), previo), v);
      expect(LogicaSwipe.progreso(LogicaSwipe.ejeDe(v), previo, ancho), 1);
    }
  });

  test('progreso de 0 a 1 con tope', () {
    expect(LogicaSwipe.progreso(null, const Offset(50, 0), ancho), 0);
    expect(LogicaSwipe.progreso(EjeSwipe.vertical, const Offset(0, -40), ancho), 0.5);
    expect(LogicaSwipe.progreso(EjeSwipe.vertical, const Offset(0, 200), ancho), 1);
    expect(
      LogicaSwipe.progreso(EjeSwipe.horizontal, const Offset(-95.76 / 4, 0), ancho),
      closeTo(0.25, 0.001),
    );
  });

  test('ángulo: solo en horizontal, con signo y tope de 12°', () {
    expect(LogicaSwipe.anguloGrados(EjeSwipe.vertical, const Offset(0, 50), ancho), 0);
    expect(LogicaSwipe.anguloGrados(EjeSwipe.horizontal, Offset.zero, ancho), 0);
    // El tope llega a la mitad del umbral.
    final mitad = LogicaSwipe.umbral(EjeSwipe.horizontal, ancho) / 2;
    expect(LogicaSwipe.anguloGrados(EjeSwipe.horizontal, Offset(mitad / 2, 0), ancho), 6);
    expect(LogicaSwipe.anguloGrados(EjeSwipe.horizontal, Offset(mitad, 0), ancho), 12);
    expect(LogicaSwipe.anguloGrados(EjeSwipe.horizontal, const Offset(300, 0), ancho), 12);
    expect(LogicaSwipe.anguloGrados(EjeSwipe.horizontal, const Offset(-300, 0), ancho), -12);
  });

  group('al soltar', () {
    Veredicto? soltar(EjeSwipe? eje, Offset d, [Offset v = Offset.zero]) =>
        LogicaSwipe.alSoltar(eje: eje, desplazamiento: d, velocidad: v, ancho: ancho);

    test('por debajo del umbral regresa', () {
      expect(soltar(EjeSwipe.horizontal, const Offset(90, 0)), isNull);
      expect(soltar(EjeSwipe.vertical, const Offset(0, -79)), isNull);
      expect(soltar(null, Offset.zero), isNull);
    });

    test('en o por encima del umbral confirma hacia ese lado', () {
      expect(soltar(EjeSwipe.horizontal, const Offset(96, 0)), Veredicto.legal);
      expect(soltar(EjeSwipe.horizontal, const Offset(-200, 0)), Veredicto.ilegal);
      expect(soltar(EjeSwipe.vertical, const Offset(0, -80)), Veredicto.condicional);
      expect(soltar(EjeSwipe.vertical, const Offset(0, 81)), Veredicto.escalar);
    });

    test('un lanzamiento de 800 dp/s confirma aunque no llegue al umbral', () {
      expect(
        soltar(EjeSwipe.horizontal, const Offset(20, 0), const Offset(800, 0)),
        Veredicto.legal,
      );
      expect(
        soltar(EjeSwipe.vertical, const Offset(0, -10), const Offset(0, -900)),
        Veredicto.condicional,
      );
      expect(soltar(EjeSwipe.horizontal, const Offset(20, 0), const Offset(799, 0)), isNull);
      // La velocidad del otro eje no cuenta.
      expect(soltar(EjeSwipe.horizontal, const Offset(20, 0), const Offset(0, 2000)), isNull);
    });
  });

  test('el vuelo sale de la zona en la dirección del veredicto', () {
    final legal = LogicaSwipe.destinoVuelo(Veredicto.legal, ancho, 440);
    expect(legal.dx, greaterThan(ancho));
    expect(legal.dy, 0);
    final escalar = LogicaSwipe.destinoVuelo(Veredicto.escalar, ancho, 440);
    expect(escalar.dy, greaterThan(440));
    expect(LogicaSwipe.destinoVuelo(Veredicto.ilegal, ancho, 440).dx, lessThan(-ancho));
    expect(LogicaSwipe.destinoVuelo(Veredicto.condicional, ancho, 440).dy, lessThan(-440));
  });
}
