/// Tarjeta fallada que regresa al Buzón para apelarla (a los 3, 7 y 14 días).
class Apelacion {
  const Apelacion({
    required this.id,
    required this.tarjetaId,
    required this.resumen,
    required this.diaRepaso,
    required this.disponibleEl,
  });

  final String id;
  final String tarjetaId;
  final String resumen;

  /// Día de repaso: 3, 7 o 14.
  final int diaRepaso;

  /// Fecha (del servidor) desde la que se puede apelar.
  final DateTime disponibleEl;
}
