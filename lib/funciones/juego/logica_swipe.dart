import 'dart:math' as math;
import 'dart:ui' show Offset;

import '../../datos/modelos/tarjeta.dart';

/// Eje del arrastre: se decide al pasar [LogicaSwipe.umbralEje] y se bloquea
/// hasta soltar.
enum EjeSwipe { horizontal, vertical }

/// Reglas puras del gesto de la tarjeta (pantallas 10, 11, 11b, 11c y 13).
///
/// → Legal, ← Ilegal, ↑ Legal con condiciones, ↓ Escalar a jurídico.
abstract final class LogicaSwipe {
  /// Arrastre mínimo para decidir el eje.
  static const double umbralEje = 12;

  /// Para confirmar en horizontal: 28 % del ancho de la zona de la tarjeta.
  static const double fraccionUmbralHorizontal = 0.28;

  /// Para confirmar en vertical.
  static const double umbralVertical = 80;

  /// Lanzamiento (fling) que confirma aunque no se llegue al umbral.
  static const double velocidadLanzamiento = 800;

  /// Inclinación máxima mientras se arrastra en horizontal.
  static const double anguloMaximo = 12;

  /// Fracción del umbral en la que la inclinación llega a [anguloMaximo]
  /// (Figma ya muestra los 12° en un arrastre corto).
  static const double fraccionAnguloMaximo = 0.5;

  /// Inclinación al salir volando en horizontal.
  static const double anguloVuelo = 24;

  /// Opacidad máxima del tinte de pantalla completa.
  static const double opacidadTinte = 0.10;

  /// Dirección de cada veredicto como vector unitario.
  static Offset direccion(Veredicto v) => switch (v) {
    Veredicto.legal => const Offset(1, 0),
    Veredicto.ilegal => const Offset(-1, 0),
    Veredicto.condicional => const Offset(0, -1),
    Veredicto.escalar => const Offset(0, 1),
  };

  static EjeSwipe ejeDe(Veredicto v) =>
      v == Veredicto.legal || v == Veredicto.ilegal ? EjeSwipe.horizontal : EjeSwipe.vertical;

  /// Eje según el arrastre acumulado; `null` mientras no pase [umbralEje].
  static EjeSwipe? decidirEje(Offset arrastre) {
    if (arrastre.distance < umbralEje) return null;
    return arrastre.dx.abs() >= arrastre.dy.abs() ? EjeSwipe.horizontal : EjeSwipe.vertical;
  }

  /// Desplazamiento de la tarjeta: solo sobre el eje bloqueado.
  static Offset sobreEje(EjeSwipe? eje, Offset arrastre) => switch (eje) {
    EjeSwipe.horizontal => Offset(arrastre.dx, 0),
    EjeSwipe.vertical => Offset(0, arrastre.dy),
    null => Offset.zero,
  };

  /// Distancia para confirmar en el [eje] con una zona de [ancho].
  static double umbral(EjeSwipe eje, double ancho) =>
      eje == EjeSwipe.horizontal ? ancho * fraccionUmbralHorizontal : umbralVertical;

  /// Veredicto hacia el que apunta el desplazamiento (sin importar el umbral).
  static Veredicto? veredictoDe(EjeSwipe? eje, Offset desplazamiento) {
    switch (eje) {
      case EjeSwipe.horizontal when desplazamiento.dx != 0:
        return desplazamiento.dx > 0 ? Veredicto.legal : Veredicto.ilegal;
      case EjeSwipe.vertical when desplazamiento.dy != 0:
        return desplazamiento.dy < 0 ? Veredicto.condicional : Veredicto.escalar;
      default:
        return null;
    }
  }

  /// Avance hacia el umbral, de 0 a 1 (sellos y tintes).
  static double progreso(EjeSwipe? eje, Offset desplazamiento, double ancho) {
    if (eje == null) return 0;
    final distancia = eje == EjeSwipe.horizontal
        ? desplazamiento.dx.abs()
        : desplazamiento.dy.abs();
    return (distancia / umbral(eje, ancho)).clamp(0.0, 1.0);
  }

  /// Inclinación en grados: solo en horizontal, con tope de [anguloMaximo]
  /// (negativa a la izquierda, positiva a la derecha).
  static double anguloGrados(EjeSwipe? eje, Offset desplazamiento, double ancho) {
    if (eje != EjeSwipe.horizontal || desplazamiento.dx == 0) return 0;
    final tope = umbral(eje!, ancho) * fraccionAnguloMaximo;
    final fraccion = (desplazamiento.dx.abs() / tope).clamp(0.0, 1.0);
    return anguloMaximo * fraccion * desplazamiento.dx.sign;
  }

  /// Veredicto al soltar: si pasa el umbral o hay un lanzamiento de al menos
  /// [velocidadLanzamiento] en el eje; `null` si la tarjeta debe regresar.
  static Veredicto? alSoltar({
    required EjeSwipe? eje,
    required Offset desplazamiento,
    required Offset velocidad,
    required double ancho,
  }) {
    if (eje == null) return null;
    final rapidez = eje == EjeSwipe.horizontal ? velocidad.dx : velocidad.dy;
    if (rapidez.abs() >= velocidadLanzamiento) {
      return veredictoDe(eje, eje == EjeSwipe.horizontal ? Offset(rapidez, 0) : Offset(0, rapidez));
    }
    if (progreso(eje, desplazamiento, ancho) >= 1) return veredictoDe(eje, desplazamiento);
    return null;
  }

  /// Posición de la tarjeta al previsualizar un veredicto (teclado): justo en
  /// el umbral.
  static Offset desplazamientoPrevio(Veredicto v, double ancho) =>
      direccion(v) * umbral(ejeDe(v), ancho);

  /// Destino del vuelo: fuera de la zona de [tamano] en esa dirección.
  static Offset destinoVuelo(Veredicto v, double ancho, double alto) {
    final d = direccion(v);
    return Offset(d.dx * ancho * 1.5, d.dy * math.max(alto, ancho) * 1.5);
  }
}
