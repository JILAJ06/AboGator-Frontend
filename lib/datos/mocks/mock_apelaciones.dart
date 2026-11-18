import '../modelos/apelacion.dart';
import '../repositorios/repositorio_apelaciones.dart';
import 'espera_simulada.dart';

/// Buzón simulado con dos apelaciones pendientes.
class MockApelaciones implements RepositorioApelaciones {
  MockApelaciones({this.espera = esperaSimuladaPorDefecto});

  final Duration espera;

  @override
  Future<List<Apelacion>> obtenerApelacionesPendientes() async {
    await esperar(espera);
    return [
      Apelacion(
        id: 'ape-001',
        tarjetaId: 'tar-gpl-01',
        resumen: 'Librería GPL en app cerrada',
        diaRepaso: 3,
        disponibleEl: DateTime.utc(2026, 11, 20, 9),
      ),
      Apelacion(
        id: 'ape-002',
        tarjetaId: 'tar-arco-02',
        resumen: 'Venta de la base de correos',
        diaRepaso: 7,
        disponibleEl: DateTime.utc(2026, 11, 24, 9),
      ),
    ];
  }
}
