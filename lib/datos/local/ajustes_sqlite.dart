import 'package:sqflite/sqflite.dart';

import '../modelos/ajustes.dart';
import '../modelos/ajustes_notificaciones.dart';
import '../repositorios/repositorio_ajustes.dart';
import 'base_local.dart';

/// Ajustes de accesibilidad en la tabla `ajustes` de SQLite (clave/valor,
/// como "onboarding visto").
class AjustesSqlite implements RepositorioAjustes {
  AjustesSqlite(this._base);

  final BaseLocal _base;

  @override
  Future<Ajustes> cargar() async => CodecAjustes.deMapa(await _leer(CodecAjustes.claves));

  @override
  Future<void> guardar(Ajustes ajustes) => _escribir(CodecAjustes.aMapa(ajustes));

  @override
  Future<AjustesNotificaciones> cargarNotificaciones() async =>
      CodecNotificaciones.deMapa(await _leer(CodecNotificaciones.claves));

  @override
  Future<void> guardarNotificaciones(AjustesNotificaciones notificaciones) =>
      _escribir(CodecNotificaciones.aMapa(notificaciones));

  Future<Map<String, String?>> _leer(List<String> claves) async {
    final db = await _base.base;
    final filas = await db.query(
      BaseLocal.tablaAjustes,
      columns: ['clave', 'valor'],
      where: 'clave IN (${List.filled(claves.length, '?').join(', ')})',
      whereArgs: claves,
    );
    return {for (final f in filas) f['clave']! as String: f['valor'] as String?};
  }

  Future<void> _escribir(Map<String, String> valores) async {
    final db = await _base.base;
    final lote = db.batch();
    for (final MapEntry(:key, :value) in valores.entries) {
      lote.insert(BaseLocal.tablaAjustes, {
        'clave': key,
        'valor': value,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await lote.commit(noResult: true);
  }
}
