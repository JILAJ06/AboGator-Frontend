import '../../componentes/nodo_sprint.dart';
import '../../core/textos/textos.dart';
import '../../datos/modelos/modulo.dart';
import '../inicio/logica_inicio.dart';

/// Reglas puras del mapa de sprints (08) y de la intro del sprint (09).
abstract final class LogicaMapa {
  /// Posición horizontal de cada nodo normal, como fracción del ancho: zigzag
  /// 50 %, 28 %, 50 %, 72 % (en Figma: 195, 110, 195 y 280 de 390), y se repite.
  static const List<double> zigzag = [0.5, 0.28, 0.5, 0.72];

  /// El Examen final va al centro.
  static const double xExamenFinal = 0.5;

  /// Fracción horizontal del nodo en la posición [indice] (0 = primero).
  static double fraccionX(int indice, {required bool esExamenFinal}) =>
      esExamenFinal ? xExamenFinal : zigzag[indice % zigzag.length];

  /// La etiqueta va a la izquierda del nodo si este está del lado derecho.
  static bool etiquetaALaIzquierda(double fraccion) => fraccion > 0.5;

  /// Sprint actual del módulo (el primero en curso o, si no hay, el primero
  /// disponible) con su número entre los sprints normales.
  static ({Sprint sprint, int numero})? sprintActual(Modulo modulo) {
    final normales = LogicaInicio.sprintsNormales(modulo);
    for (final buscado in [EstadoSprint.enCurso, EstadoSprint.disponible]) {
      final i = normales.indexWhere((s) => s.estado == buscado);
      if (i >= 0) return (sprint: normales[i], numero: i + 1);
    }
    return null;
  }

  /// Número del sprint entre los normales (1 a 5); `null` si es el Examen final
  /// o no pertenece al módulo.
  static int? numeroDe(Modulo modulo, Sprint sprint) {
    final i = LogicaInicio.sprintsNormales(modulo).indexWhere((s) => s.id == sprint.id);
    return i >= 0 ? i + 1 : null;
  }

  /// El Examen final se abre solo con todos los sprints normales completados.
  static bool examenDisponible(Modulo modulo) {
    final normales = LogicaInicio.sprintsNormales(modulo);
    return normales.isNotEmpty && normales.every((s) => s.estado == EstadoSprint.completado);
  }

  /// Si el sprint (o el Examen final) se puede abrir desde el mapa.
  static bool puedeAbrir(Modulo modulo, Sprint sprint) =>
      sprint.esExamenFinal ? examenDisponible(modulo) : sprint.estado != EstadoSprint.bloqueado;

  /// Aspecto del nodo: el Examen final siempre es "jefe"; en curso y
  /// disponible se ven como el sprint actual.
  static TipoNodoSprint tipoNodo(Sprint sprint) {
    if (sprint.esExamenFinal) return TipoNodoSprint.jefe;
    return switch (sprint.estado) {
      EstadoSprint.completado => TipoNodoSprint.completado,
      EstadoSprint.enCurso || EstadoSprint.disponible => TipoNodoSprint.actual,
      EstadoSprint.bloqueado => TipoNodoSprint.bloqueado,
    };
  }

  /// Nombre del nodo: "Sprint N" o "Examen final".
  static String nombreNodo(Modulo modulo, Sprint sprint) {
    final numero = numeroDe(modulo, sprint);
    return numero == null ? Textos.examenFinal : Textos.sprintNumero(numero);
  }

  /// Estado legible para el lector de pantalla.
  static String estadoLegible(Modulo modulo, Sprint sprint) {
    if (sprint.esExamenFinal) {
      return examenDisponible(modulo)
          ? Textos.estadoSprintDisponible
          : Textos.estadoSprintBloqueado;
    }
    return switch (sprint.estado) {
      EstadoSprint.completado => Textos.estadoSprintCompletado,
      EstadoSprint.enCurso => Textos.estadoSprintActual,
      EstadoSprint.disponible => Textos.estadoSprintDisponible,
      EstadoSprint.bloqueado => Textos.estadoSprintBloqueado,
    };
  }

  /// "Sprint N, título, estado" y, si está completado, sus estrellas.
  static String semanticaNodo(Modulo modulo, Sprint sprint) {
    final base = Textos.nodoSemantica(
      nombreNodo(modulo, sprint),
      sprint.titulo,
      estadoLegible(modulo, sprint),
    );
    if (!sprint.esExamenFinal && sprint.estado == EstadoSprint.completado) {
      return '$base, ${Textos.estrellasSemantica(sprint.estrellas, Sprint.maximoEstrellas)}';
    }
    return base;
  }

  /// Sprint seleccionado al abrir el mapa en tablet (T08): el de [sprintId]
  /// si existe y no es el Examen final; si no, el sprint actual (en curso o
  /// disponible), luego el último completado y, si no hay, el primero.
  static Sprint? seleccionInicial(Modulo modulo, {String? sprintId}) {
    if (sprintId != null) {
      final pedido = sprintPorId(modulo, sprintId);
      if (pedido != null && !pedido.esExamenFinal) return pedido;
    }
    final actual = sprintActual(modulo);
    if (actual != null) return actual.sprint;
    final normales = LogicaInicio.sprintsNormales(modulo);
    final completados = normales.where((s) => s.estado == EstadoSprint.completado);
    if (completados.isNotEmpty) return completados.last;
    return normales.isEmpty ? null : normales.first;
  }

  /// Lo que se anuncia al seleccionar un sprint en tablet: "Sprint 2,
  /// Consentimiento. Completado, 3 estrellas."
  static String anuncioSeleccion(Modulo modulo, Sprint sprint) {
    final completado = !sprint.esExamenFinal && sprint.estado == EstadoSprint.completado;
    return Textos.seleccionSprint(
      nombreNodo(modulo, sprint),
      sprint.titulo,
      estadoLegible(modulo, sprint),
      estrellas: completado ? sprint.estrellas : null,
    );
  }

  /// Busca un módulo por id.
  static Modulo? moduloPorId(List<Modulo> modulos, String id) {
    for (final modulo in modulos) {
      if (modulo.id == id) return modulo;
    }
    return null;
  }

  /// Busca un sprint (o el Examen final) del módulo por id.
  static Sprint? sprintPorId(Modulo modulo, String id) {
    for (final sprint in modulo.sprints) {
      if (sprint.id == id) return sprint;
    }
    return null;
  }

  /// Desglose de la intro: "6 normales · 3 con evidencia · 1 dilema".
  static String desglose(Sprint sprint) =>
      Textos.tarjetasDesglose(sprint.tarjetasNormales, sprint.tarjetasConEvidencia, sprint.dilemas);
}
