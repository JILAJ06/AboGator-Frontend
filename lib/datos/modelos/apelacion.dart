/// Tarjeta fallada que regresa al Buzón para apelarla (a los 3, 7 y 14 días).
class Apelacion {
  const Apelacion({
    required this.id,
    required this.tarjetaId,
    required this.moduloId,
    required this.titulo,
    required this.tema,
    required this.diaRepaso,
    required this.disponibleEl,
  });

  final String id;
  final String tarjetaId;

  /// Módulo de la tarjeta (color de la franja en el Buzón).
  final String moduloId;

  /// Título corto del caso, por ejemplo "Librería GPL en app cerrada".
  final String titulo;

  /// Tema, por ejemplo "Licencias OSS".
  final String tema;

  /// Día de repaso: 3, 7 o 14.
  final int diaRepaso;

  /// Fecha (del servidor) desde la que se puede apelar.
  final DateTime disponibleEl;

  @override
  String toString() => 'Apelacion($id, $tarjetaId, día $diaRepaso, $disponibleEl)';
}

/// Tarjeta fallada que se manda al Buzón al terminar un sprint.
class NuevaApelacion {
  const NuevaApelacion({
    required this.tarjetaId,
    required this.moduloId,
    required this.titulo,
    required this.tema,
  });

  final String tarjetaId;
  final String moduloId;
  final String titulo;
  final String tema;

  @override
  bool operator ==(Object other) =>
      other is NuevaApelacion &&
      other.tarjetaId == tarjetaId &&
      other.moduloId == moduloId &&
      other.titulo == titulo &&
      other.tema == tema;

  @override
  int get hashCode => Object.hash(tarjetaId, moduloId, titulo, tema);
}
