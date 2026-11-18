/// Perfil con el que se registra el usuario (pantalla 06).
enum PerfilUsuario { estudiante, desarrollador, legal }

/// Usuario de la app.
class Usuario {
  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.perfil,
    required this.nivel,
    required this.xp,
    required this.racha,
  });

  final String id;
  final String nombre;
  final String correo;
  final PerfilUsuario perfil;
  final int nivel;
  final int xp;

  /// Días seguidos jugando.
  final int racha;
}
