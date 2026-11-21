import '../modelos/insignia.dart';
import '../modelos/resumen_perfil.dart';
import '../repositorios/repositorio_autenticacion.dart';
import '../repositorios/repositorio_examen.dart';
import '../repositorios/repositorio_perfil.dart';
import 'espera_simulada.dart';
import 'mock_autenticacion.dart';

/// Perfil simulado (Figma 25): estadísticas e insignias de Ana López y el
/// usuario de la sesión del servidor (Ana si no hay [autenticacion] o no
/// tiene a nadie).
class MockPerfil implements RepositorioPerfil {
  MockPerfil({this.espera = esperaSimuladaPorDefecto, this.autenticacion, this.examen});

  final Duration espera;
  final RepositorioAutenticacion? autenticacion;

  /// Para contar los certificados emitidos (0 sin él).
  final RepositorioExamen? examen;

  static const List<Insignia> insignias = [
    Insignia(
      id: 'ins-guardian',
      nombre: 'Guardián de datos',
      icono: 'shield-check',
      moduloId: 'mod-1',
      desbloqueada: true,
    ),
    Insignia(
      id: 'ins-racha-7',
      nombre: 'Racha de 7',
      icono: 'flame',
      moduloId: 'mod-2',
      desbloqueada: true,
    ),
    Insignia(
      id: 'ins-sprint-perfecto',
      nombre: 'Sprint perfecto',
      icono: 'star',
      moduloId: 'mod-4',
      desbloqueada: true,
    ),
    Insignia(
      id: 'ins-abogado-codigo',
      nombre: 'Abogado de código',
      icono: 'lock',
      desbloqueada: false,
    ),
  ];

  @override
  Future<ResumenPerfil> obtenerPerfil() async {
    await esperar(espera);
    final usuario = await autenticacion?.usuarioActual() ?? MockAutenticacion.usuarioDemo;
    return ResumenPerfil(
      usuario: usuario,
      precision: 82,
      certificados: (await examen?.obtenerCertificados())?.length ?? 0,
      certificadosTotales: 5,
      sprintsPerfectos: 12,
      insignias: insignias,
    );
  }
}
