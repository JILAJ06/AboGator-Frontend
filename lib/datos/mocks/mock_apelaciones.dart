import '../modelos/apelacion.dart';
import '../repositorios/repositorio_apelaciones.dart';
import 'espera_simulada.dart';

/// Buzón simulado con seis apelaciones pendientes (como el contador de Figma).
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
      Apelacion(
        id: 'ape-003',
        tarjetaId: 'tar-mit-02',
        resumen: 'Créditos de una librería MIT',
        diaRepaso: 3,
        disponibleEl: DateTime.utc(2026, 11, 21, 9),
      ),
      Apelacion(
        id: 'ape-004',
        tarjetaId: 'tar-arco-01',
        resumen: 'Borrado con facturas fiscales',
        diaRepaso: 7,
        disponibleEl: DateTime.utc(2026, 11, 25, 9),
      ),
      Apelacion(
        id: 'ape-005',
        tarjetaId: 'tar-gpl-01',
        resumen: 'Librería GPL en app cerrada',
        diaRepaso: 14,
        disponibleEl: DateTime.utc(2026, 12, 1, 9),
      ),
      Apelacion(
        id: 'ape-006',
        tarjetaId: 'tar-arco-02',
        resumen: 'Venta de la base de correos',
        diaRepaso: 14,
        disponibleEl: DateTime.utc(2026, 12, 2, 9),
      ),
    ];
  }
}
