/// Comodines disponibles en la Tienda. No funcionan en el Examen Final (RN03).
enum Comodin { lupaAuditor, abogadoSenior, amparo }

/// Artículo que se puede comprar en la Tienda.
class ArticuloTienda {
  const ArticuloTienda({
    required this.id,
    required this.comodin,
    required this.nombre,
    required this.descripcion,
    required this.precio,
  });

  final String id;
  final Comodin comodin;
  final String nombre;
  final String descripcion;

  /// Precio en monedas.
  final int precio;
}
