/// Resultado de resolver una apelación (lo decide el servidor).
class ResultadoApelacion {
  const ResultadoApelacion({required this.ganada, this.diaSiguiente, this.diasParaVolver});

  final bool ganada;

  /// Día de repaso con el que vuelve (7 o 14 al ganar, el mismo al perder);
  /// `null` si la tarjeta quedó dominada y salió del Buzón.
  final int? diaSiguiente;

  /// Días hasta que se vuelve a abrir (4 o 7 al ganar, 1 al perder); `null`
  /// si quedó dominada.
  final int? diasParaVolver;

  /// Ganó el día 14: la tarjeta salió del Buzón.
  bool get dominada => diaSiguiente == null;

  @override
  bool operator ==(Object other) =>
      other is ResultadoApelacion &&
      other.ganada == ganada &&
      other.diaSiguiente == diaSiguiente &&
      other.diasParaVolver == diasParaVolver;

  @override
  int get hashCode => Object.hash(ganada, diaSiguiente, diasParaVolver);

  @override
  String toString() =>
      'ResultadoApelacion(ganada: $ganada, día: $diaSiguiente, vuelve en: $diasParaVolver)';
}
