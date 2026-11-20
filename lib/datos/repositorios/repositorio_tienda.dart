import '../modelos/articulo_tienda.dart';

/// Tienda de comodines (pantalla 24).
abstract interface class RepositorioTienda {
  Future<List<ArticuloTienda>> obtenerArticulos();

  Future<int> obtenerMonedas();

  /// Suma las monedas ganadas en un sprint y devuelve el nuevo total.
  Future<int> sumarMonedas(int cantidad);

  /// Comodines que tiene el usuario y cuántos de cada uno.
  Future<Map<Comodin, int>> obtenerComodines();

  /// Gasta un comodín (resta 1, nunca baja de 0). Se llama al usarlo.
  Future<void> consumirComodin(Comodin comodin);
}
