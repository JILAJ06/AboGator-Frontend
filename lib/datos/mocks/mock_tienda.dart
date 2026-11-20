import '../modelos/articulo_tienda.dart';
import '../modelos/excepcion_tienda.dart';
import '../modelos/resultado_compra.dart';
import '../repositorios/repositorio_tienda.dart';
import 'espera_simulada.dart';

/// Tienda simulada que hace de servidor: los tres comodines y "Congelar
/// racha" con los precios y textos de Figma 24. Monedas, comodines y
/// congeladores viven en memoria por instancia.
class MockTienda implements RepositorioTienda {
  MockTienda({
    this.espera = esperaSimuladaPorDefecto,
    this._monedas = monedasIniciales,
    Map<Comodin, int> comodines = comodinesIniciales,
    this._congeladores = 0,
  }) : _comodines = {...comodines};

  /// Monedas con las que empieza el mock (240, como en Figma 07 y 24).
  static const int monedasIniciales = 240;

  /// Comodines con los que empieza el mock (como en Figma 10 y 24).
  static const Map<Comodin, int> comodinesIniciales = {
    Comodin.lupaAuditor: 2,
    Comodin.abogadoSenior: 1,
    Comodin.amparo: 1,
  };

  final Duration espera;
  int _monedas;
  int _congeladores;
  final Map<Comodin, int> _comodines;

  static const List<ArticuloTienda> articulos = [
    ArticuloTienda(
      id: ArticuloTienda.idLupa,
      comodin: Comodin.lupaAuditor,
      nombre: 'Lupa de Auditor',
      descripcion: 'Resalta en amarillo las palabras trampa del caso.',
      precio: 60,
    ),
    ArticuloTienda(
      id: ArticuloTienda.idAbogado,
      comodin: Comodin.abogadoSenior,
      nombre: 'Abogado Senior',
      descripcion: 'Traduce el caso al artículo o licencia exacta.',
      precio: 90,
    ),
    ArticuloTienda(
      id: ArticuloTienda.idAmparo,
      comodin: Comodin.amparo,
      nombre: 'Amparo / Fianza',
      descripcion: 'Escudo: tu próximo error no te quita vida.',
      precio: 120,
    ),
    ArticuloTienda(
      id: ArticuloTienda.idCongelarRacha,
      comodin: null,
      nombre: 'Congelar racha',
      descripcion: 'Protege tu racha si no juegas un día.',
      precio: 100,
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

  @override
  Future<int> obtenerCongeladoresRacha() async {
    await esperar(espera);
    return _congeladores;
  }

  @override
  Future<ResultadoCompra> comprarArticulo(String articuloId) async {
    await esperar(espera);
    final articulo = articulos.where((a) => a.id == articuloId).firstOrNull;
    if (articulo == null) {
      throw const ExcepcionTienda(MotivoExcepcionTienda.articuloInexistente);
    }
    final comodin = articulo.comodin;
    final actual = comodin == null ? _congeladores : (_comodines[comodin] ?? 0);
    if (actual >= ArticuloTienda.maximo) {
      throw const ExcepcionTienda(MotivoExcepcionTienda.maximoAlcanzado);
    }
    if (_monedas < articulo.precio) {
      throw const ExcepcionTienda(MotivoExcepcionTienda.monedasInsuficientes);
    }
    _monedas -= articulo.precio;
    final nueva = actual + 1;
    if (comodin == null) {
      _congeladores = nueva;
    } else {
      _comodines[comodin] = nueva;
    }
    return ResultadoCompra(articulo: articulo, cantidadNueva: nueva, monedasRestantes: _monedas);
  }
}
