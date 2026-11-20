import 'package:sqflite/sqflite.dart';

import '../modelos/ajustes.dart';
import '../repositorios/repositorio_ajustes.dart';
import 'base_local.dart';

/// Ajustes de accesibilidad en la tabla `ajustes` de SQLite (clave/valor,
/// como "onboarding visto").
class AjustesSqlite implements RepositorioAjustes {
  AjustesSqlite(this._base);

  final BaseLocal _base;

  @override
  Future<Ajustes> cargar() async {
    final db = await _base.base;
    final filas = await db.query(
      BaseLocal.tablaAjustes,
      columns: ['clave', 'valor'],
      where: 'clave IN (${List.filled(CodecAjustes.claves.length, '?').join(', ')})',
      whereArgs: CodecAjustes.claves,
    );
    return CodecAjustes.deMapa({
      for (final f in filas) f['clave']! as String: f['valor'] as String?,
    });
  }

  @override
  Future<void> guardar(Ajustes ajustes) async {
    final db = await _base.base;
    final lote = db.batch();
    for (final MapEntry(:key, :value) in CodecAjustes.aMapa(ajustes).entries) {
      lote.insert(BaseLocal.tablaAjustes, {
        'clave': key,
        'valor': value,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await lote.commit(noResult: true);
  }
}
