import '../modelos/ajustes.dart';
import '../repositorios/repositorio_ajustes.dart';

/// Ajustes en memoria (web y pruebas): guarda el mismo mapa clave/valor que
/// SQLite, así que valida igual.
class AjustesEnMemoria implements RepositorioAjustes {
  AjustesEnMemoria([Map<String, String>? iniciales]) : valores = {...?iniciales};

  /// Lo guardado, por clave.
  final Map<String, String> valores;

  @override
  Future<Ajustes> cargar() async => CodecAjustes.deMapa(valores);

  @override
  Future<void> guardar(Ajustes ajustes) async => valores.addAll(CodecAjustes.aMapa(ajustes));
}
