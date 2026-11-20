import 'articulo_tienda.dart';

/// Resultado de una compra en la Tienda (lo decide el servidor).
class ResultadoCompra {
  const ResultadoCompra({
    required this.articulo,
    required this.cantidadNueva,
    required this.monedasRestantes,
  });

  final ArticuloTienda articulo;

  /// Unidades del artículo después de comprar.
  final int cantidadNueva;

  /// Saldo después de comprar.
  final int monedasRestantes;
}
