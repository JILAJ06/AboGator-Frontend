import 'package:abogator/componentes/nodo_sprint.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/mocks/mock_progreso.dart';
import 'package:abogator/datos/modelos/modulo.dart';
import 'package:abogator/funciones/mapa/logica_mapa.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudantes/datos.dart';

const b = EstadoSprint.bloqueado;
const d = EstadoSprint.disponible;
const c = EstadoSprint.enCurso;
const h = EstadoSprint.completado;

void main() {
  final mock = MockProgreso.modulos.first;

  test('zigzag de Figma: 50 %, 28 %, 50 %, 72 %, 50 % y el final al centro', () {
    expect(
      [for (var i = 0; i < 5; i++) LogicaMapa.fraccionX(i, esExamenFinal: false)],
      [0.5, 0.28, 0.5, 0.72, 0.5],
    );
    expect(LogicaMapa.fraccionX(5, esExamenFinal: true), 0.5);
    // En 390: 195, 109.2, 195, 280.8 (Figma: 195, 110, 195, 280).
    expect(390 * LogicaMapa.fraccionX(3, esExamenFinal: false), closeTo(280, 1));
    expect(LogicaMapa.etiquetaALaIzquierda(0.72), isTrue);
    expect(LogicaMapa.etiquetaALaIzquierda(0.5), isFalse);
  });

  test('tipo de nodo por estado; el Examen final siempre es "jefe"', () {
    expect(LogicaMapa.tipoNodo(sprintDePrueba('a', h)), TipoNodoSprint.completado);
    expect(LogicaMapa.tipoNodo(sprintDePrueba('a', c)), TipoNodoSprint.actual);
    expect(LogicaMapa.tipoNodo(sprintDePrueba('a', d)), TipoNodoSprint.actual);
    expect(LogicaMapa.tipoNodo(sprintDePrueba('a', b)), TipoNodoSprint.bloqueado);
    expect(LogicaMapa.tipoNodo(sprintDePrueba('f', b, esExamenFinal: true)), TipoNodoSprint.jefe);
  });

  test('con el mock: sprint actual 3 y los 6 nodos en su estado', () {
    final actual = LogicaMapa.sprintActual(mock)!;
    expect(actual.numero, 3);
    expect(actual.sprint.titulo, 'Aviso de privacidad');
    expect(mock.sprints.map(LogicaMapa.tipoNodo), [
      TipoNodoSprint.completado,
      TipoNodoSprint.completado,
      TipoNodoSprint.actual,
      TipoNodoSprint.bloqueado,
      TipoNodoSprint.bloqueado,
      TipoNodoSprint.jefe,
    ]);
    expect(mock.sprints.map((s) => LogicaMapa.nombreNodo(mock, s)), [
      'Sprint 1',
      'Sprint 2',
      'Sprint 3',
      'Sprint 4',
      'Sprint 5',
      Textos.examenFinal,
    ]);
  });

  test('sin sprint en curso, el actual es el primero disponible; si no hay, ninguno', () {
    final disponible = moduloDePrueba(1, [h, d, b], conFinal: true);
    expect(LogicaMapa.sprintActual(disponible)!.numero, 2);
    final completo = moduloDePrueba(1, [h, h], conFinal: true, estadoFinal: d);
    expect(LogicaMapa.sprintActual(completo), isNull);
  });

  test('se abren el actual y los completados; los bloqueados no', () {
    expect(mock.sprints.map((s) => LogicaMapa.puedeAbrir(mock, s)), [
      true,
      true,
      true,
      false,
      false,
      false,
    ]);
  });

  test('el Examen final se abre solo con todos los sprints completados', () {
    expect(LogicaMapa.examenDisponible(mock), isFalse);
    final listo = moduloDePrueba(1, [h, h, h, h, h], conFinal: true);
    expect(LogicaMapa.examenDisponible(listo), isTrue);
    expect(LogicaMapa.puedeAbrir(listo, listo.sprints.last), isTrue);
    expect(LogicaMapa.examenDisponible(moduloDePrueba(1, [], conFinal: true)), isFalse);
  });

  test('semántica de cada nodo: nombre, título, estado y estrellas', () {
    expect(
      LogicaMapa.semanticaNodo(mock, mock.sprints[0]),
      'Sprint 1, Datos personales, completado, 3 de 3 estrellas',
    );
    expect(
      LogicaMapa.semanticaNodo(mock, mock.sprints[2]),
      'Sprint 3, Aviso de privacidad, en curso',
    );
    expect(LogicaMapa.semanticaNodo(mock, mock.sprints[3]), 'Sprint 4, Derechos ARCO, bloqueado');
    expect(
      LogicaMapa.semanticaNodo(mock, mock.sprints[5]),
      'Examen final, Auditoría de inversores, bloqueado',
    );
    final listo = moduloDePrueba(1, [h], conFinal: true);
    expect(LogicaMapa.semanticaNodo(listo, listo.sprints.last), endsWith('disponible'));
  });

  test('número del sprint sin contar el Examen final', () {
    expect(LogicaMapa.numeroDe(mock, mock.sprints[2]), 3);
    expect(LogicaMapa.numeroDe(mock, mock.sprints.last), isNull);
  });

  test('búsqueda de módulo y sprint por id', () {
    expect(LogicaMapa.moduloPorId(MockProgreso.modulos, 'mod-2')!.numero, 2);
    expect(LogicaMapa.moduloPorId(MockProgreso.modulos, 'no-existe'), isNull);
    expect(LogicaMapa.sprintPorId(mock, 'spr-1-3')!.titulo, 'Aviso de privacidad');
    expect(LogicaMapa.sprintPorId(mock, 'spr-1-final')!.esExamenFinal, isTrue);
    expect(LogicaMapa.sprintPorId(mock, 'no-existe'), isNull);
  });

  test('textos de la intro con singular y plural', () {
    expect(LogicaMapa.desglose(mock.sprints[2]), '6 normales · 3 con evidencia · 1 dilema');
    expect(Textos.tarjetasDesglose(1, 0, 2), '1 normal · 0 con evidencia · 2 dilemas');
    expect(Textos.tarjetasCantidad(10), '10 tarjetas');
    expect(Textos.tarjetasCantidad(1), '1 tarjeta');
    expect(Textos.monedasHasta(60), 'Hasta 60 monedas');
    expect(Textos.monedasHasta(1), 'Hasta 1 moneda');
    expect(Textos.globoDetalle(10, 4), '10 tarjetas · ≈ 4 min');
    expect(Textos.globoTitulo(3, 'Aviso de privacidad'), 'Sprint 3 · Aviso de privacidad');
    expect(Textos.introEtiqueta(3, 1), 'SPRINT 3 · MÓDULO 1');
    expect(Textos.introObjetivo('El MVP sale.'), 'Objetivo: El MVP sale.');
  });
}
