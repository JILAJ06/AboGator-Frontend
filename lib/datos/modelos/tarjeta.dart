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

/// Cambio en los 4 indicadores de la Startup que provoca una respuesta.
class ImpactoTarjeta {
  const ImpactoTarjeta({
    this.presupuesto = 0,
    this.reputacion = 0,
    this.velocidad = 0,
    this.riesgoLegal = 0,
  });

  final int presupuesto;
  final int reputacion;
  final int velocidad;
  final int riesgoLegal;

  ImpactoTarjeta copiar({int? presupuesto, int? reputacion, int? velocidad, int? riesgoLegal}) =>
      ImpactoTarjeta(
        presupuesto: presupuesto ?? this.presupuesto,
        reputacion: reputacion ?? this.reputacion,
        velocidad: velocidad ?? this.velocidad,
        riesgoLegal: riesgoLegal ?? this.riesgoLegal,
      );

  @override
  bool operator ==(Object other) =>
      other is ImpactoTarjeta &&
      other.presupuesto == presupuesto &&
      other.reputacion == reputacion &&
      other.velocidad == velocidad &&
      other.riesgoLegal == riesgoLegal;

  @override
  int get hashCode => Object.hash(presupuesto, reputacion, velocidad, riesgoLegal);

  @override
  String toString() => 'ImpactoTarjeta($presupuesto, $reputacion, $velocidad, $riesgoLegal)';
}

/// Pregunta de bonus que aparece tras un acierto ("¿por qué es ilegal?").
class MicroPregunta {
  const MicroPregunta({
    required this.enunciado,
    required this.opciones,
    required this.indiceCorrecto,
  });

  /// Por ejemplo "¿por qué es ilegal?" (el panel antepone "Bonus +5 XP: ").
  final String enunciado;

  /// 2 o 3 opciones.
  final List<String> opciones;
  final int indiceCorrecto;
}

/// Caso práctico que el usuario lee y decide.
class Tarjeta {
  const Tarjeta({
    required this.id,
    required this.tipo,
    required this.etiquetaCaso,
    required this.personaje,
    required this.rol,
    required this.texto,
    required this.respuestaCorrecta,
    required this.explicacion,
    this.evidencia,
    this.impactoAcierto = const ImpactoTarjeta(),
    this.impactoFallo = const ImpactoTarjeta(),
    this.impactoParcial = const ImpactoTarjeta(),
    this.microPregunta,
    this.explicacionFallo,
    this.explicacionParcial,
  });

  final String id;
  final TipoTarjeta tipo;

  /// Etiqueta del caso, por ejemplo "CASO 4 · LICENCIAS OSS".
  final String etiquetaCaso;

  /// Quien plantea el caso, por ejemplo "Dev Junior".
  final String personaje;

  /// Rol o equipo del personaje, por ejemplo "Equipo de Backend".
  final String rol;

  /// Texto del caso (va en el globo de la tarjeta).
  final String texto;
  final Veredicto respuestaCorrecta;

  /// "¿Por qué?" tras un acierto (y en el bonus).
  final String explicacion;

  /// "¿Por qué?" tras un error; si falta, se usa [explicacion].
  final String? explicacionFallo;

  /// "¿Por qué?" tras escalar sin necesidad; si falta, se usa [explicacionFallo].
  final String? explicacionParcial;

  final ImpactoTarjeta impactoAcierto;
  final ImpactoTarjeta impactoFallo;
  final ImpactoTarjeta impactoParcial;

  /// Pregunta de bonus tras un acierto (opcional).
  final MicroPregunta? microPregunta;

  /// Fragmento de código o cláusula a inspeccionar (solo en tarjetas con evidencia).
  final String? evidencia;
}
