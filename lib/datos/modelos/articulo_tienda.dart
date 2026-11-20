/// Comodines disponibles en la Tienda. No funcionan en el Examen Final (RN03).
enum Comodin { lupaAuditor, abogadoSenior, amparo }

/// Artículo que se puede comprar en la Tienda (pantalla 24).
class ArticuloTienda {
  const ArticuloTienda({
    required this.id,
    required this.comodin,
    required this.nombre,
    required this.descripcion,
    required this.precio,
  });

  /// Ids estables de los artículos.
  static const String idLupa = 'lupa';
  static const String idAbogado = 'abogado';
  static const String idAmparo = 'amparo';
  static const String idCongelarRacha = 'congelar-racha';

  /// Unidades máximas de cada artículo en el inventario.
  static const int maximo = 9;

  final String id;

  /// Comodín que da; `null` en "Congelar racha", que no se usa en el juego.
  final Comodin? comodin;
  final String nombre;
  final String descripcion;

  /// Precio en monedas.
  final int precio;
}
