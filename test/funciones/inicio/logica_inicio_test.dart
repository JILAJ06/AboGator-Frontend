import 'package:abogator/componentes/tarjeta_modulo.dart';
import 'package:abogator/core/tema/colores_marca.dart';
import 'package:abogator/core/tema/iconos_app.dart';
import 'package:abogator/datos/mocks/mock_progreso.dart';
import 'package:abogator/datos/modelos/modulo.dart';
import 'package:abogator/datos/modelos/usuario.dart';
import 'package:abogator/funciones/inicio/logica_inicio.dart';
import 'package:flutter_test/flutter_test.dart';

Modulo modulo(List<EstadoSprint> estados, {int numero = 1, String id = 'm'}) => Modulo(
  id: id,
  numero: numero,
  nombre: 'Módulo $numero',
  color: ColoresModulo.enOrden[numero - 1],
  sprints: [
    for (final (i, e) in estados.indexed)
      Sprint(id: '$id-$i', titulo: 'S$i', numeroTarjetas: 8, estado: e),
  ],
);

const b = EstadoSprint.bloqueado;
const d = EstadoSprint.disponible;
const c = EstadoSprint.enCurso;
const h = EstadoSprint.completado;

void main() {
  test('iniciales y primer nombre', () {
    expect(LogicaInicio.iniciales('Ana López'), 'AL');
    expect(LogicaInicio.iniciales('  valeria   ríos  pérez'), 'VR');
    expect(LogicaInicio.iniciales('Sarko'), 'S');
    expect(LogicaInicio.iniciales(''), '');
    expect(LogicaInicio.primerNombre('Ana López'), 'Ana');
  });

  test('perfil corto', () {
    expect(LogicaInicio.perfilCorto(PerfilUsuario.estudiante), 'Estudiante');
    expect(LogicaInicio.perfilCorto(PerfilUsuario.desarrollador), 'Dev');
    expect(LogicaInicio.perfilCorto(PerfilUsuario.legal), 'Legal');
  });

  test('estado del módulo', () {
    expect(LogicaInicio.estadoDe(modulo([b, b, b])), EstadoModulo.bloqueado);
    expect(LogicaInicio.estadoDe(modulo([])), EstadoModulo.bloqueado);
    expect(LogicaInicio.estadoDe(modulo([h, h, h])), EstadoModulo.completado);
    expect(LogicaInicio.estadoDe(modulo([h, c, b])), EstadoModulo.enCurso);
    expect(LogicaInicio.estadoDe(modulo([h, b, b])), EstadoModulo.enCurso);
    expect(LogicaInicio.estadoDe(modulo([d, b, b])), EstadoModulo.disponible);
  });

  test('solo cuenta los sprints completados', () {
    expect(LogicaInicio.completados(modulo([h, h, c, b, b])), 2);
  });

  test('módulo y sprint actuales', () {
    final primero = modulo([h, h, b], id: 'a');
    final segundo = modulo([h, c, b], numero: 2, id: 'b');
    final actual = LogicaInicio.actual([primero, segundo])!;
    expect(actual.modulo.id, 'b');
    expect(actual.numeroSprint, 2);

    final soloDisponible = LogicaInicio.actual([
      modulo([h, d], id: 'x'),
    ])!;
    expect(soloDisponible.sprint.id, 'x-1');
    expect(
      LogicaInicio.actual([
        modulo([b, b]),
      ]),
      isNull,
    );
  });

  test('con el mock: módulo 1 en curso con 2/5 y sprint 3 de 5; los demás bloqueados', () {
    final modulos = MockProgreso.modulos;
    expect(LogicaInicio.estadoDe(modulos.first), EstadoModulo.enCurso);
    expect(LogicaInicio.completados(modulos.first), 2);
    final actual = LogicaInicio.actual(modulos)!;
    expect(actual.numeroSprint, 3);
    expect(actual.modulo.sprints, hasLength(5));
    for (final m in modulos.skip(1)) {
      expect(LogicaInicio.estadoDe(m), EstadoModulo.bloqueado);
    }
  });

  test('nombres cortos, tramos e íconos por número', () {
    final modulos = MockProgreso.modulos;
    expect(modulos.map(LogicaInicio.nombreCorto), [
      'Protección de datos',
      'Licencias open source',
      'Delitos informáticos',
      'Contratos digitales',
      'Auditoría y cumplimiento',
    ]);
    expect(modulos.map(LogicaInicio.tramo), [
      'Del Garage al MVP',
      'Ronda Semilla',
      'Escalando el equipo',
      'Serie A',
      'Salida a bolsa',
    ]);
    expect(modulos.map(LogicaInicio.iconoDe), [
      IconosApp.shield,
      IconosApp.code,
      IconosApp.gavel,
      IconosApp.doc,
      IconosApp.shieldCheck,
    ]);
  });
}
