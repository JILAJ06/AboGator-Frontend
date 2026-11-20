import 'insignia.dart';
import 'usuario.dart';

/// Lo que muestra el Perfil (pantalla 25); lo calcula el servidor.
class ResumenPerfil {
  const ResumenPerfil({
    required this.usuario,
    required this.precision,
    required this.certificados,
    required this.certificadosTotales,
    required this.sprintsPerfectos,
    required this.insignias,
  });

  final Usuario usuario;

  /// Porcentaje de aciertos, de 0 a 100.
  final int precision;
  final int certificados;
  final int certificadosTotales;
  final int sprintsPerfectos;
  final List<Insignia> insignias;
}
