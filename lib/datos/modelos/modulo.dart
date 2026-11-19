import 'dart:ui' show Color;

/// Estado de un sprint dentro del mapa del módulo (pantalla 08).
enum EstadoSprint { bloqueado, disponible, enCurso, completado }

/// Sprint: un bloque de tarjetas dentro de un módulo.
class Sprint {
  const Sprint({
    required this.id,
    required this.titulo,
    required this.objetivo,
    required this.tarjetasNormales,
    required this.tarjetasConEvidencia,
    required this.dilemas,
    required this.monedasMaximas,
    required this.minutosEstimados,
    required this.estado,
    this.estrellas = 0,
    this.esExamenFinal = false,
    this.tituloIntro,
  }) : assert(estrellas >= 0 && estrellas <= maximoEstrellas);

  /// Máximo de estrellas que da un sprint completado.
  static const int maximoEstrellas = 3;

  final String id;
  final String titulo;

  /// Título largo de la intro (09) si difiere del corto del mapa (08); por
  /// ejemplo "Aviso de privacidad en el MVP".
  final String? tituloIntro;

  /// Objetivo del sprint (la pantalla 09 le antepone "Objetivo: ").
  final String objetivo;
  final int tarjetasNormales;
  final int tarjetasConEvidencia;

  /// Tarjetas de justificación ("dilema clave").
  final int dilemas;
  final int monedasMaximas;
  final int minutosEstimados;
  final EstadoSprint estado;

  /// 0 a 3; solo tiene sentido si el sprint está completado.
  final int estrellas;

  /// El último nodo del mapa es el Examen Final (Nivel Jefe). No cuenta como
  /// sprint en los números de progreso.
  final bool esExamenFinal;

  /// Total de tarjetas del sprint.
  int get numeroTarjetas => tarjetasNormales + tarjetasConEvidencia + dilemas;
}

/// Módulo temático (1 a 5), con su color propio.
class Modulo {
  const Modulo({
    required this.id,
    required this.numero,
    required this.nombre,
    required this.color,
    required this.sprints,
  });

  final String id;

  /// Número del módulo (1 a 5).
  final int numero;
  final String nombre;

  /// Color decorativo del módulo (de `ColoresModulo`).
  final Color color;

  /// Sprints en orden; el último es el Examen final.
  final List<Sprint> sprints;
}
