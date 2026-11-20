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

/// Fragmento de código o registro que se inspecciona en una tarjeta con
/// evidencia (visor 16 y 16b).
class EvidenciaTarjeta {
  const EvidenciaTarjeta({
    required this.archivo,
    required this.lineas,
    required this.lineasClave,
    required this.mensajeAcierto,
    required this.mensajeFallo,
  });

  /// Nombre que se ve en la barra del snippet, por ejemplo "registro_form.dart".
  final String archivo;

  /// Texto de cada línea, sin saltos de línea.
  final List<String> lineas;

  /// Números de las líneas que violan la ley (empiezan en 1).
  final List<int> lineasClave;

  /// Texto de 16b cuando marca una línea clave.
  final String mensajeAcierto;

  /// Texto cuando marca una línea que no es la clave.
  final String mensajeFallo;
}

/// Justificación que se elige tras dictar el veredicto en una tarjeta de
/// dilema (panel 18). Las opciones están escritas para el veredicto correcto.
class Justificacion {
  const Justificacion({required this.opciones, required this.indiceCorrecto});

  /// 3 opciones.
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
    this.justificacion,
    this.palabrasTrampa = const [],
    this.traduccionLegal,
    this.normas = const [],
    this.iniciales,
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

  /// Pregunta de bonus tras un acierto (opcional; no la llevan las tarjetas
  /// con evidencia ni las de dilema, que tienen su propio bonus).
  final MicroPregunta? microPregunta;

  /// Fragmento a inspeccionar (solo en tarjetas con evidencia).
  final EvidenciaTarjeta? evidencia;

  /// Justificación del veredicto (solo en tarjetas de dilema).
  final Justificacion? justificacion;

  /// Fragmentos exactos de [texto] que resalta la Lupa de Auditor (10b).
  final List<String> palabrasTrampa;

  /// La pregunta real en términos legales (Abogado Senior, 10c).
  final String? traduccionLegal;

  /// Normas aplicables, por nombre (Abogado Senior, 10c).
  final List<String> normas;

  /// Iniciales del avatar; si faltan, se calculan del [personaje].
  final String? iniciales;

  /// La Lupa solo sirve si hay palabras trampa.
  bool get aplicaLupa => palabrasTrampa.isNotEmpty;

  /// El Abogado solo sirve con traducción y al menos una norma.
  bool get aplicaAbogado => (traduccionLegal?.isNotEmpty ?? false) && normas.isNotEmpty;
}
