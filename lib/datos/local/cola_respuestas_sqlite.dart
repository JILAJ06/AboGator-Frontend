import 'package:sqflite/sqflite.dart';

import '../modelos/respuesta_pendiente.dart';
import '../repositorios/cola_respuestas.dart';
import 'base_local.dart';

/// Cola de respuestas en SQLite (Android e iOS): sobrevive a cerrar la app.
class ColaRespuestasSqlite implements ColaRespuestas {
  ColaRespuestasSqlite(this._base);

  final BaseLocal _base;

  static const String _tabla = BaseLocal.tablaRespuestas;

  @override
  Future<void> agregar(RespuestaPendiente respuesta) async {
    final db = await _base.base;
    // Idempotente por id: si ya está, no se duplica.
    await db.insert(_tabla, respuesta.aFila(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  @override
  Future<List<RespuestaPendiente>> pendientes() async {
    final db = await _base.base;
    // rowid conserva el orden de llegada.
    final filas = await db.query(_tabla, orderBy: 'rowid ASC');
    return filas.map(RespuestaPendiente.deFila).toList();
  }

  @override
  Future<int> cantidadPendientes() async {
    final db = await _base.base;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $_tabla')) ?? 0;
  }

  @override
  Future<void> marcarEnviadas(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _base.base;
    await db.delete(_tabla, where: 'id IN (${_marcas(ids)})', whereArgs: ids);
  }

  @override
  Future<void> registrarIntentoFallido(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _base.base;
    await db.rawUpdate(
      'UPDATE $_tabla SET intentos = intentos + 1 WHERE id IN (${_marcas(ids)})',
      ids,
    );
  }

  static String _marcas(List<String> ids) => List.filled(ids.length, '?').join(', ');
}
