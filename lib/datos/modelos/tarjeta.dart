/// Tipo de tarjeta: normal (≈60 %), con evidencia (≈30 %) o de justificación (≈10 %).
enum TipoTarjeta { normal, evidencia, justificacion }

/// Las 4 decisiones posibles (una por dirección de swipe).
enum Veredicto {
  /// → derecha
  legal,

  /// ← izquierda
  ilegal,

  /// ↑ arriba: legal con condiciones
  condicional,

  /// ↓ abajo: escalar al área jurídica
  escalar,
}

/// Caso práctico que el usuario lee y decide.
class Tarjeta {
  const Tarjeta({
    required this.id,
    required this.tipo,
    required this.texto,
    required this.respuestaCorrecta,
    required this.explicacion,
    this.evidencia,
  });

  final String id;
  final TipoTarjeta tipo;
  final String texto;
  final Veredicto respuestaCorrecta;
  final String explicacion;

  /// Fragmento de código o cláusula a inspeccionar (solo en tarjetas con evidencia).
  final String? evidencia;
}
