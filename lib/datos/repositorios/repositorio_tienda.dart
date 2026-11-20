import '../modelos/articulo_tienda.dart';

/// Tienda de comodines (pantalla 24).
abstract interface class RepositorioTienda {
  Future<List<ArticuloTienda>> obtenerArticulos();

  Future<int> obtenerMonedas();
}
