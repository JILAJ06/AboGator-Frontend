import '../modelos/articulo_tienda.dart';

/// Tienda de comodines (pantalla 24).
abstract interface class RepositorioTienda {
  Future<List<ArticuloTienda>> obtenerArticulos();

  Future<int> obtenerMonedas();

  /// Suma las monedas ganadas en un sprint y devuelve el nuevo total.
  Future<int> sumarMonedas(int cantidad);
}
