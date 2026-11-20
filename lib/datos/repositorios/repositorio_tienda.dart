import '../modelos/articulo_tienda.dart';
import '../modelos/resultado_compra.dart';

/// Tienda de comodines (pantalla 24). Las monedas y las compras las decide el
/// servidor: la app nunca calcula un saldo por su cuenta.
abstract interface class RepositorioTienda {
  Future<List<ArticuloTienda>> obtenerArticulos();

  Future<int> obtenerMonedas();

  /// Suma las monedas ganadas en un sprint y devuelve el nuevo total.
  Future<int> sumarMonedas(int cantidad);

  /// Comodines que tiene el usuario y cuántos de cada uno.
  Future<Map<Comodin, int>> obtenerComodines();

  /// Gasta un comodín (resta 1, nunca baja de 0). Se llama al usarlo.
  Future<void> consumirComodin(Comodin comodin);

  /// Cuántos "Congelar racha" tiene el usuario (no es un comodín: el
  /// servidor lo gasta solo si un día no se juega).
  Future<int> obtenerCongeladoresRacha();

  /// Compra una unidad de [articuloId]. Lanza `ExcepcionTienda` con
  /// `monedasInsuficientes`, `maximoAlcanzado` (9) o `articuloInexistente`;
  /// en ese caso no cambia nada.
  Future<ResultadoCompra> comprarArticulo(String articuloId);
}
