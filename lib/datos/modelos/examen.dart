import 'tarjeta.dart';

/// Fase de la crisis según la hora (línea de crisis de 27 y 28).
enum FaseCrisis {
  deteccion(0),
  contencion(6),
  aviso(24),
  autoridad(72);

  const FaseCrisis(this.hora);

  /// Hora en la que empieza la fase.
  final int hora;

  /// Fase de [hora]: H0 Detección (0–5), H6 Contención (6–23), H24 Aviso
  /// (24–71) y H72 Autoridad (72).
  static FaseCrisis de(int hora) => hora >= 72
      ? autoridad
      : hora >= 24
      ? aviso
      : hora >= 6
      ? contencion
      : deteccion;
}

/// Cómo va el intento según el servidor.
enum EstadoExamen { enCurso, aprobado, reprobado }

/// Una decisión de la crisis tal como la ve la app: sin la respuesta
/// correcta (la decide el servidor).
class DecisionCrisis {
  const DecisionCrisis({
    required this.id,
    required this.indice,
    required this.hora,
    required this.limite,
    required this.etiquetaCaso,
    required this.personaje,
    required this.rol,
    required this.texto,
    this.iniciales,
  });

  final String id;

  /// 1 a 10.
  final int indice;

  /// Hora de la crisis (0 a 72).
  final int hora;

  /// Tiempo para decidir (15 s, o 22 s con tiempo extendido).
  final Duration limite;
  final String etiquetaCaso;
  final String personaje;
  final String rol;
  final String texto;
  final String? iniciales;
}

/// Contraargumento de la Inspectora: la réplica y dos fundamentos.
class Replica {
  const Replica({required this.texto, required this.fundamentos});

  final String texto;
  final List<String> fundamentos;
}

/// Respuesta del servidor a una decisión.
class ResultadoDecision {
  const ResultadoDecision({
    required this.correcta,
    required this.tiempoAgotado,
    required this.vidas,
    required this.hpJefe,
    required this.estado,
    this.replica,
    this.limiteReplica,
    this.siguiente,
    this.respuestaCorrecta,
  });

  final bool correcta;
  final bool tiempoAgotado;
  final int vidas;
  final int hpJefe;
  final EstadoExamen estado;

  /// Solo si fue correcta: el contraargumento y su tiempo (8 s o 12 s).
  final Replica? replica;
  final Duration? limiteReplica;

  /// La siguiente decisión (si falló y el examen sigue).
  final DecisionCrisis? siguiente;

  /// Si falló: la respuesta correcta (para la apelación de la T-11b).
  final Veredicto? respuestaCorrecta;
}

/// Respuesta del servidor al fundamento elegido.
class ResultadoContraargumento {
  const ResultadoContraargumento({
    required this.correcto,
    required this.tiempoAgotado,
    required this.vidas,
    required this.hpJefe,
    required this.danio,
    required this.estado,
    this.siguiente,
  });

  final bool correcto;
  final bool tiempoAgotado;
  final int vidas;
  final int hpJefe;

  /// 20 si el fundamento fue correcto; si no, 0.
  final int danio;
  final EstadoExamen estado;
  final DecisionCrisis? siguiente;
}

/// Lo que muestra 27 antes de empezar.
class InfoExamen {
  const InfoExamen({
    required this.moduloId,
    required this.titulo,
    required this.descripcion,
    required this.totalDecisiones,
  });

  final String moduloId;
  final String titulo;
  final String descripcion;
  final int totalDecisiones;
}

/// Un intento recién empezado.
class IntentoExamen {
  const IntentoExamen({
    required this.id,
    required this.moduloId,
    required this.hpJefe,
    required this.vidas,
    required this.totalDecisiones,
    required this.decision,
  });

  final String id;
  final String moduloId;
  final int hpJefe;
  final int vidas;
  final int totalDecisiones;

  /// La primera decisión.
  final DecisionCrisis decision;
}

/// Resumen del intento (lo guarda la T-11b).
class ResumenExamen {
  const ResumenExamen({
    this.decisionesJugadas = 0,
    this.aciertos = 0,
    this.porTiempo = 0,
    this.golpes = 0,
    this.vidasRestantes = 0,
    this.aprobado = false,
  });

  final int decisionesJugadas;
  final int aciertos;
  final int porTiempo;
  final int golpes;
  final int vidasRestantes;
  final bool aprobado;

  ResumenExamen copyWith({
    int? decisionesJugadas,
    int? aciertos,
    int? porTiempo,
    int? golpes,
    int? vidasRestantes,
    bool? aprobado,
  }) => ResumenExamen(
    decisionesJugadas: decisionesJugadas ?? this.decisionesJugadas,
    aciertos: aciertos ?? this.aciertos,
    porTiempo: porTiempo ?? this.porTiempo,
    golpes: golpes ?? this.golpes,
    vidasRestantes: vidasRestantes ?? this.vidasRestantes,
    aprobado: aprobado ?? this.aprobado,
  );
}

/// Una decisión fallada (para registrar sus apelaciones en la T-11b).
class DecisionFallada {
  const DecisionFallada({
    required this.decision,
    this.veredicto,
    this.respuestaCorrecta,
    this.enContraargumento = false,
  });

  final DecisionCrisis decision;

  /// Lo que eligió (`null` si se le acabó el tiempo).
  final Veredicto? veredicto;
  final Veredicto? respuestaCorrecta;

  /// Acertó el veredicto pero falló el fundamento.
  final bool enContraargumento;
}
