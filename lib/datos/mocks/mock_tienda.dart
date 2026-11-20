import '../modelos/articulo_tienda.dart';
import '../repositorios/repositorio_tienda.dart';
import 'espera_simulada.dart';

/// Tienda simulada con los tres comodines. Las monedas y los comodines se
/// guardan en memoria; cada instancia empieza con [monedasIniciales] y
/// [comodinesIniciales]. La compra llega en T-10.
class MockTienda implements RepositorioTienda {
  MockTienda({
    this.espera = esperaSimuladaPorDefecto,
    this._monedas = monedasIniciales,
    Map<Comodin, int> comodines = comodinesIniciales,
  }) : _comodines = {...comodines};

  /// Monedas con las que empieza el mock (240, como en Figma 07).
  static const int monedasIniciales = 240;

  /// Comodines con los que empieza el mock (como en Figma 10).
  static const Map<Comodin, int> comodinesIniciales = {
    Comodin.lupaAuditor: 2,
    Comodin.abogadoSenior: 1,
    Comodin.amparo: 1,
  };

  final Duration espera;
  int _monedas;
  final Map<Comodin, int> _comodines;

  static const List<ArticuloTienda> articulos = [
    ArticuloTienda(
      id: 'art-lupa',
      comodin: Comodin.lupaAuditor,
      nombre: 'Lupa de Auditor',
      descripcion: 'Resalta las palabras trampa del caso.',
      precio: 50,
    ),
    ArticuloTienda(
      id: 'art-abogado',
      comodin: Comodin.abogadoSenior,
      nombre: 'Abogado Senior',
      descripcion: 'Traduce el caso a términos legales y cita la norma.',
      precio: 80,
    ),
    ArticuloTienda(
      id: 'art-amparo',
      comodin: Comodin.amparo,
      nombre: 'Amparo',
      descripcion: 'Tu siguiente error no te quita vida.',
      precio: 120,
    ),
  ];

  @override
  Future<List<ArticuloTienda>> obtenerArticulos() async {
    await esperar(espera);
    return articulos;
  }

  @override
  Future<int> obtenerMonedas() async {
    await esperar(espera);
    return _monedas;
  }

  @override
  Future<int> sumarMonedas(int cantidad) async {
    await esperar(espera);
    _monedas += cantidad;
    return _monedas;
  }

  @override
  Future<Map<Comodin, int>> obtenerComodines() async {
    await esperar(espera);
    return {for (final c in Comodin.values) c: _comodines[c] ?? 0};
  }

  @override
  Future<void> consumirComodin(Comodin comodin) async {
    await esperar(espera);
    final actual = _comodines[comodin] ?? 0;
    _comodines[comodin] = actual > 0 ? actual - 1 : 0;
  }
}
