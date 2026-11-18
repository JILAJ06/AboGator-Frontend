import 'dart:ui' show Color;

/// Estado de un sprint dentro del mapa del módulo (pantalla 08).
enum EstadoSprint { bloqueado, disponible, enCurso, completado }

/// Sprint: un bloque de tarjetas dentro de un módulo.
class Sprint {
  const Sprint({
    required this.id,
    required this.titulo,
    required this.numeroTarjetas,
    required this.estado,
    this.esExamenFinal = false,
  });

  final String id;
  final String titulo;
  final int numeroTarjetas;
  final EstadoSprint estado;

  /// El último nodo del mapa es el Examen Final (Nivel Jefe).
  final bool esExamenFinal;
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
  final List<Sprint> sprints;
}
