import '../../componentes/piezas_tienda.dart';
import '../../datos/modelos/articulo_tienda.dart';

/// Reglas puras de la Tienda (pantalla 24).
abstract final class LogicaTienda {
  /// Por qué no se puede comprar [articulo] con [monedas] y [cantidad] (o
  /// `ninguno`). Sin conexión manda sobre lo demás; luego el máximo y el saldo.
  static BloqueoCompra bloqueo(
    ArticuloTienda articulo, {
    required int monedas,
    required int cantidad,
    required bool enLinea,
  }) {
    if (!enLinea) return BloqueoCompra.sinConexion;
    if (cantidad >= ArticuloTienda.maximo) return BloqueoCompra.maximo;
    if (monedas < articulo.precio) return BloqueoCompra.sinMonedas;
    return BloqueoCompra.ninguno;
  }

  /// Monedas que faltan para comprar [articulo] (0 si alcanzan).
  static int faltan(ArticuloTienda articulo, int monedas) =>
      monedas >= articulo.precio ? 0 : articulo.precio - monedas;
}
