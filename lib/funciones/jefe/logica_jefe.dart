import '../../core/textos/textos.dart';
import 'estado_examen.dart';

/// Reglas puras de la pantalla del Examen Final.
abstract final class LogicaJefe {
  /// Segundos por decisión (con tiempo extendido, +50 %: 22).
  static int segundosPorDecision({required bool tiempoExtendido}) => tiempoExtendido ? 22 : 15;

  /// Segundos para el contraargumento (12 con tiempo extendido).
  static int segundosReplica({required bool tiempoExtendido}) => tiempoExtendido ? 12 : 8;

  /// Fracción de la vida del Jefe (0 a 1).
  static double fraccionHp(int hp) => (hp / 100).clamp(0, 1).toDouble();

  /// Urgente con 5 s o menos.
  static bool urgente(int segundos) => segundos <= 5;

  /// Segundos en los que se anuncia el tiempo (además del límite y el 0).
  static const Set<int> segundosAnunciados = {10, 5};

  /// Texto del chip de [tipo].
  static String textoFeedback(TipoFeedback tipo, int danio) => switch (tipo) {
    TipoFeedback.golpe => Textos.golpe(danio),
    TipoFeedback.falloVeredicto => Textos.falloVeredicto,
    TipoFeedback.falloTiempo => Textos.falloTiempo,
    TipoFeedback.falloFundamento => Textos.falloFundamento,
  };

  /// Lo que se anuncia con el chip.
  static String anuncioFeedback(
    TipoFeedback tipo, {
    required int danio,
    required int hp,
    required int vidas,
  }) => tipo == TipoFeedback.golpe
      ? Textos.golpeSemantica(danio, hp)
      : Textos.falloSemantica(textoFeedback(tipo, danio), vidas);
}
