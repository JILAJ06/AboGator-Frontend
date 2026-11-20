import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Base SQLite del dispositivo (`abogator.db`, versión 1): la cola de
/// respuestas y los ajustes locales (onboarding visto).
///
/// Se abre en la primera operación, no al arrancar la app. En pruebas se le
/// pasa la fábrica de `sqflite_common_ffi` y una ruta (o la base en memoria).
class BaseLocal {
  BaseLocal({this.fabrica, this.ruta});

  static const String nombre = 'abogator.db';
  static const int version = 1;

  static const String tablaRespuestas = 'respuestas_pendientes';
  static const String tablaAjustes = 'ajustes';

  /// Fábrica de bases (la de sqflite si es `null`).
  final DatabaseFactory? fabrica;

  /// Ruta de la base (`abogator.db` en la carpeta de bases si es `null`).
  final String? ruta;
  Future<Database>? _base;

  /// La base abierta (la abre la primera vez).
  Future<Database> get base => _base ??= _abrir();

  Future<Database> _abrir() async {
    final f = fabrica ?? databaseFactory;
    return f.openDatabase(
      ruta ?? p.join(await f.getDatabasesPath(), nombre),
      options: OpenDatabaseOptions(version: version, onCreate: _crear),
    );
  }

  static Future<void> _crear(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tablaRespuestas (
        id TEXT PRIMARY KEY,
        sprint_id TEXT NOT NULL,
        tarjeta_id TEXT NOT NULL,
        veredicto TEXT NOT NULL,
        justificacion INTEGER NULL,
        evidencia_correcta INTEGER NULL,
        respondida_en TEXT NOT NULL,
        intentos INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE $tablaAjustes (
        clave TEXT PRIMARY KEY,
        valor TEXT NOT NULL
      )
    ''');
  }

  /// Cierra la base; la siguiente operación la vuelve a abrir.
  Future<void> cerrar() async {
    final abierta = _base;
    _base = null;
    if (abierta != null) await (await abierta).close();
  }
}
