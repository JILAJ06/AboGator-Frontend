import 'dart:async';

import 'package:abogator/core/servicios/servicio_haptico.dart';
import 'package:abogator/core/utilidades/cronometro.dart';
import 'package:abogator/datos/modelos/apelacion.dart';
import 'package:abogator/datos/modelos/buzon_apelaciones.dart';
import 'package:abogator/datos/modelos/estado_startup.dart';
import 'package:abogator/datos/modelos/modulo.dart';
import 'package:abogator/datos/modelos/resultado_apelacion.dart';
import 'package:abogator/datos/modelos/usuario.dart';
import 'package:abogator/datos/repositorios/repositorio_apelaciones.dart';
import 'package:abogator/datos/repositorios/repositorio_progreso.dart';

/// Usuaria con sesión de las pruebas de la app.
const ana = Usuario(
  id: 'u-ana',
  nombre: 'Ana López',
  correo: 'ana@startup.mx',
  perfil: PerfilUsuario.desarrollador,
  nivel: 4,
  xp: 0,
  racha: 7,
);

/// Progreso con [modulos] fijos; puede fallar ([fallar]) o esperar a
/// [bloqueo], y cuenta las [llamadas].
class ProgresoFalso implements RepositorioProgreso {
  ProgresoFalso(this.modulos);

  List<Modulo> modulos;
  bool fallar = false;
  Completer<void>? bloqueo;
  int llamadas = 0;

  @override
  Future<List<Modulo>> obtenerModulos() async {
    llamadas++;
    await bloqueo?.future;
    if (fallar) throw Exception('sin red');
    return modulos;
  }

  @override
  Future<EstadoStartup> obtenerEstadoStartup() async =>
      const EstadoStartup(presupuesto: 0, reputacion: 0, velocidad: 0, riesgoLegal: 0);

  @override
  Future<void> registrarSprintCompletado({
    required String sprintId,
    required int estrellas,
    required EstadoStartup estadoFinal,
  }) async {}

  @override
  Future<void> registrarExamenAprobado({required String moduloId}) async {}
}

/// Buzón fijo: una apelación (`a0`, `a1`…) por cada día de [dias], contados
/// desde [ahora] (0 = hoy). Puede fallar ([fallar]) o esperar a [bloqueo].
class ApelacionesFalsas implements RepositorioApelaciones {
  /// [cantidad] apelaciones disponibles hoy (1 de enero de 2026).
  ApelacionesFalsas([int cantidad = 6]) : this.conDias(List.filled(cantidad, 0));

  ApelacionesFalsas.conDias(this.dias, {DateTime? ahora, this.fallar = false})
    : ahora = ahora ?? DateTime.utc(2026);

  final List<int> dias;
  final DateTime ahora;
  bool fallar;
  Completer<void>? bloqueo;

  @override
  Future<BuzonApelaciones> obtenerBuzon() async {
    await bloqueo?.future;
    if (fallar) throw StateError('sin red');
    return BuzonApelaciones(
      ahoraServidor: ahora,
      apelaciones: [
        for (final (i, d) in dias.indexed)
          Apelacion(
            id: 'a$i',
            tarjetaId: 't$i',
            moduloId: 'mod-1',
            titulo: 'Caso $i',
            tema: 'Tema',
            diaRepaso: 3,
            disponibleEl: ahora.add(Duration(days: d)),
          ),
      ],
    );
  }

  @override
  Future<void> registrarFallos(List<NuevaApelacion> fallos) async {}

  @override
  Future<ResultadoApelacion> resolverApelacion(String apelacionId, {required bool ganada}) =>
      throw UnimplementedError();
}

/// Vibraciones registradas, en orden, en [llamadas].
class HapticaFalsa implements ServicioHaptico {
  final llamadas = <String>[];

  @override
  Future<void> acierto() async => llamadas.add('acierto');
  @override
  Future<void> parcial() async => llamadas.add('parcial');
  @override
  Future<void> error() async => llamadas.add('error');
  @override
  Future<void> suave() async => llamadas.add('suave');
}

/// Reloj monótono controlado por la prueba (sin la hora del dispositivo).
class CronometroFalso implements Cronometro {
  @override
  Duration transcurrido = Duration.zero;

  @override
  void reiniciar() => transcurrido = Duration.zero;
}
