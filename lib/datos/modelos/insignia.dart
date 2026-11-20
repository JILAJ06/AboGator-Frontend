/// Insignia del Perfil (pantalla 25).
class Insignia {
  const Insignia({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.desbloqueada,
    this.moduloId,
  });

  final String id;
  final String nombre;

  /// Nombre del ícono de Figma (`IconosApp.porNombre`), p. ej. `shield-check`.
  final String icono;

  /// Módulo del que sale el color de la medalla.
  final String? moduloId;
  final bool desbloqueada;
}
