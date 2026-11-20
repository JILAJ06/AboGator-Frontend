import 'package:sqflite/sqflite.dart';

import '../repositorios/repositorio_onboarding.dart';
import 'base_local.dart';

/// "Onboarding visto" en la tabla `ajustes` de SQLite (`onboarding_visto = 1`).
class OnboardingSqlite implements RepositorioOnboarding {
  OnboardingSqlite(this._base);

  final BaseLocal _base;

  static const String clave = 'onboarding_visto';

  @override
  Future<bool> fueVisto() async {
    final db = await _base.base;
    final filas = await db.query(
      BaseLocal.tablaAjustes,
      columns: ['valor'],
      where: 'clave = ?',
      whereArgs: [clave],
    );
    return filas.isNotEmpty && filas.first['valor'] == '1';
  }

  @override
  Future<void> marcarVisto() async {
    final db = await _base.base;
    await db.insert(BaseLocal.tablaAjustes, {
      'clave': clave,
      'valor': '1',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
