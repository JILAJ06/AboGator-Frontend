import '../../componentes/barra_comodines.dart';
import '../../datos/modelos/articulo_tienda.dart';
import '../../datos/modelos/tarjeta.dart';
import 'estado_juego.dart';

/// Reglas puras de los comodines (T-07b).
///
/// - Lupa (10b): gasta 1 y resalta las palabras trampa; una vez por tarjeta.
/// - Abogado (10c): gasta 1 la primera vez que se abre en una tarjeta;
///   reabrirlo en la misma es gratis.
/// - Amparo: armarlo y desarmarlo es gratis; se gasta al absorber un error.
///
/// Ninguno se puede usar con un panel abierto ni en el Examen final (RN03).
abstract final class LogicaComodines {
  /// Resta 1 sin bajar de 0.
  static int restar(int cantidad) => cantidad > 0 ? cantidad - 1 : 0;

  static bool puedeUsarLupa(EstadoJuego e, Tarjeta t) =>
      e.panel == null &&
      e.cantidad(Comodin.lupaAuditor) > 0 &&
      t.aplicaLupa &&
      !e.lupaUsada.contains(t.id);

  /// Si se puede gastar un Abogado nuevo en [t] (sin contar reabrirlo).
  static bool puedeUsarAbogado(EstadoJuego e, Tarjeta t) =>
      e.panel == null &&
      e.cantidad(Comodin.abogadoSenior) > 0 &&
      t.aplicaAbogado &&
      !e.abogadoUsado.contains(t.id);

  /// Estado de la píldora de la Lupa en la tarjeta [t].
  static EstadoComodin estadoLupa(
    EstadoJuego e,
    Tarjeta t, {
    required bool panelAbierto,
    bool habilitados = true,
  }) {
    if (!habilitados) return EstadoComodin.deshabilitado;
    if (e.lupaUsada.contains(t.id)) return EstadoComodin.activo;
    if (panelAbierto || !puedeUsarLupa(e, t)) return EstadoComodin.deshabilitado;
    return EstadoComodin.disponible;
  }

  /// Estado de la píldora del Abogado en la tarjeta [t].
  static EstadoComodin estadoAbogado(
    EstadoJuego e,
    Tarjeta t, {
    required bool panelAbierto,
    bool habilitados = true,
  }) {
    if (!habilitados) return EstadoComodin.deshabilitado;
    if (e.abogadoUsado.contains(t.id)) return EstadoComodin.activo;
    if (panelAbierto || !puedeUsarAbogado(e, t)) return EstadoComodin.deshabilitado;
    return EstadoComodin.disponible;
  }

  /// Estado de la píldora del Amparo.
  static EstadoComodin estadoAmparo(
    EstadoJuego e, {
    required bool panelAbierto,
    bool habilitados = true,
  }) {
    if (!habilitados) return EstadoComodin.deshabilitado;
    if (e.amparoActivo) return EstadoComodin.activo;
    if (panelAbierto || e.cantidad(Comodin.amparo) <= 0) return EstadoComodin.deshabilitado;
    return EstadoComodin.disponible;
  }

  /// Si la píldora responde al toque: disponible, o activa cuando tocarla
  /// hace algo (reabrir el Abogado o desarmar el Amparo). Con un panel
  /// abierto o en el Examen, nunca.
  static bool tocable(
    Comodin comodin,
    EstadoComodin estado, {
    required bool panelAbierto,
    bool habilitados = true,
  }) {
    if (!habilitados || panelAbierto) return false;
    return switch (estado) {
      EstadoComodin.disponible => true,
      EstadoComodin.activo => comodin != Comodin.lupaAuditor,
      EstadoComodin.deshabilitado => false,
    };
  }
}
