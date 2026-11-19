import '../modelos/articulo_tienda.dart';
import '../repositorios/repositorio_tienda.dart';
import 'espera_simulada.dart';

/// Tienda simulada con los tres comodines.
class MockTienda implements RepositorioTienda {
  MockTienda({this.espera = esperaSimuladaPorDefecto});

  final Duration espera;

  static const List<ArticuloTienda> articulos = [
    ArticuloTienda(
      id: 'art-lupa',
      comodin: Comodin.lupaAuditor,
      nombre: 'Lupa de Auditor',
      descripcion: 'Resalta la línea clave de la evidencia.',
      precio: 50,
    ),
    ArticuloTienda(
      id: 'art-abogado',
      comodin: Comodin.abogadoSenior,
      nombre: 'Abogado Senior',
      descripcion: 'Descarta una de las respuestas incorrectas.',
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
    return 240;
  }
}
