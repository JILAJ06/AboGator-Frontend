import '../modelos/apelacion.dart';
import '../modelos/buzon_apelaciones.dart';
import '../repositorios/repositorio_apelaciones.dart';
import 'espera_simulada.dart';

/// Buzón simulado que hace de servidor: estado en memoria por instancia y
/// reloj inyectable ([ahoraServidor]).
///
/// Empieza con 6 apelaciones relativas a ese reloj; las dos primeras como en
/// Figma 21 (las dos de hoy), luego una mañana, una en 2 días y dos de día 14
/// más adelante.
class MockApelaciones implements RepositorioApelaciones {
  MockApelaciones({
    this.espera = esperaSimuladaPorDefecto,
    DateTime Function()? ahoraServidor,
    bool conSemilla = true,
  }) : _ahora = ahoraServidor ?? DateTime.now {
    if (conSemilla) _apelaciones.addAll(_semilla(_ahora().toUtc()));
  }

  final Duration espera;
  final DateTime Function() _ahora;
  final List<Apelacion> _apelaciones = [];
  int _siguiente = 7;

  /// Días que tarda en abrirse una apelación nueva.
  static const int diasPrimerRepaso = 3;

  static List<Apelacion> _semilla(DateTime ahora) {
    final hoy = DateTime.utc(ahora.year, ahora.month, ahora.day);
    DateTime en(int dias) => hoy.add(Duration(days: dias));
    return [
      Apelacion(
        id: 'ape-001',
        tarjetaId: 'tar-gpl-01',
        moduloId: 'mod-1',
        titulo: 'Librería GPL en app cerrada',
        tema: 'Licencias OSS',
        diaRepaso: 3,
        disponibleEl: en(0),
      ),
      Apelacion(
        id: 'ape-002',
        tarjetaId: 'tar-registro-01',
        moduloId: 'mod-1',
        titulo: 'Casilla de consentimiento pre-marcada',
        tema: 'Protección de datos',
        diaRepaso: 7,
        disponibleEl: en(0),
      ),
      Apelacion(
        id: 'ape-003',
        tarjetaId: 'tar-mit-02',
        moduloId: 'mod-2',
        titulo: 'Créditos de una librería MIT',
        tema: 'Licencias OSS',
        diaRepaso: 3,
        disponibleEl: en(1),
      ),
      Apelacion(
        id: 'ape-004',
        tarjetaId: 'tar-arco-02',
        moduloId: 'mod-1',
        titulo: 'Venta de la base de correos',
        tema: 'Transferencias',
        diaRepaso: 7,
        disponibleEl: en(2),
      ),
      Apelacion(
        id: 'ape-005',
        tarjetaId: 'tar-arco-01',
        moduloId: 'mod-1',
        titulo: 'Borrado con facturas fiscales',
        tema: 'Derechos ARCO',
        diaRepaso: 14,
        disponibleEl: en(5),
      ),
      Apelacion(
        id: 'ape-006',
        tarjetaId: 'tar-brecha-04',
        moduloId: 'mod-1',
        titulo: 'Contraseñas sin cifrar en la base',
        tema: 'Brechas de seguridad',
        diaRepaso: 14,
        disponibleEl: en(9),
      ),
    ];
  }

  @override
  Future<BuzonApelaciones> obtenerBuzon() async {
    await esperar(espera);
    return BuzonApelaciones(ahoraServidor: _ahora().toUtc(), apelaciones: _apelaciones);
  }

  @override
  Future<void> registrarFallos(List<NuevaApelacion> fallos) async {
    await esperar(espera);
    final ahora = _ahora().toUtc();
    for (final f in fallos) {
      if (_apelaciones.any((a) => a.tarjetaId == f.tarjetaId)) continue;
      _apelaciones.add(
        Apelacion(
          id: 'ape-${(_siguiente++).toString().padLeft(3, '0')}',
          tarjetaId: f.tarjetaId,
          moduloId: f.moduloId,
          titulo: f.titulo,
          tema: f.tema,
          diaRepaso: diasPrimerRepaso,
          disponibleEl: ahora.add(const Duration(days: diasPrimerRepaso)),
        ),
      );
    }
  }
}
