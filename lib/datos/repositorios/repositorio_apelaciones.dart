import '../modelos/apelacion.dart';

/// Buzón de Apelaciones (pantallas 21, 21b, 22 y 22b).
abstract interface class RepositorioApelaciones {
  Future<List<Apelacion>> obtenerApelacionesPendientes();
}
