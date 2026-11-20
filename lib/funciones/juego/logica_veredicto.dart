import '../../datos/modelos/estado_startup.dart';
import '../../datos/modelos/tarjeta.dart';

/// Resultado de calificar una respuesta (pantallas 12, 12c, 14 y 14b).
enum TipoVeredicto { correcto, parcial, incorrecto, amparo }

/// Qué pasa al cerrar el panel de veredicto, en orden de prioridad.
enum DestinoVeredicto { quiebra, sinVidas, sprintCompletado, siguiente }

/// Calificación de una respuesta.
class ResultadoVeredicto {
  const ResultadoVeredicto({
    required this.tipo,
    required this.xp,
    required this.monedas,
    required this.pierdeVida,
    required this.impacto,
    this.bonus = false,
  });

  final TipoVeredicto tipo;
  final int xp;
  final int monedas;
  final bool pierdeVida;
  final ImpactoTarjeta impacto;

  /// Bonus ganado (+5 XP): micro-pregunta bien respondida, evidencia bien
  /// marcada o justificación correcta (esta además duplica las monedas).
  final bool bonus;

  /// Fallo (con o sin Amparo): la tarjeta va al Buzón de Apelaciones (T-09).
  bool get esFallo => tipo == TipoVeredicto.incorrecto || tipo == TipoVeredicto.amparo;

  /// Suma el bonus: +5 XP y, con [monedasDobles], el doble de monedas.
  ResultadoVeredicto conBonus({bool monedasDobles = false}) => ResultadoVeredicto(
    tipo: tipo,
    xp: xp + LogicaVeredicto.xpBonus,
    monedas: monedasDobles ? monedas * 2 : monedas,
    pierdeVida: pierdeVida,
    impacto: impacto,
    bonus: true,
  );

  @override
  bool operator ==(Object other) =>
      other is ResultadoVeredicto &&
      other.tipo == tipo &&
      other.xp == xp &&
      other.monedas == monedas &&
      other.pierdeVida == pierdeVida &&
      other.impacto == impacto &&
      other.bonus == bonus;

  @override
  int get hashCode => Object.hash(tipo, xp, monedas, pierdeVida, impacto, bonus);
}

/// Reglas puras de calificación del juego.
abstract final class LogicaVeredicto {
  static const int xpCorrecto = 10;
  static const int xpBonus = 5;
  static const int monedasCorrecto = 5;
  static const int xpParcial = 3;

  /// Con Amparo, el Riesgo legal sube estos puntos menos que en el fallo (Figma
  /// 14: +25; 14b: +20).
  static const int reduccionAmparo = 5;

  /// Califica [veredicto] para [tarjeta].
  ///
  /// - Correcto: +10 XP, +5 monedas e impacto de acierto.
  /// - Parcial: eligió Escalar y la correcta no era Escalar: +3 XP, sin vida
  ///   perdida e impacto parcial (no hay parcial para Condicional).
  /// - Incorrecto: −1 vida e impacto de fallo.
  /// - Amparo (error con [amparoActivo]): sin vida perdida y el Riesgo legal
  ///   sube 5 menos (mínimo 0).
  static ResultadoVeredicto calificar(
    Tarjeta tarjeta,
    Veredicto veredicto, {
    bool amparoActivo = false,
  }) {
    if (veredicto == tarjeta.respuestaCorrecta) {
      return ResultadoVeredicto(
        tipo: TipoVeredicto.correcto,
        xp: xpCorrecto,
        monedas: monedasCorrecto,
        pierdeVida: false,
        impacto: tarjeta.impactoAcierto,
      );
    }
    if (veredicto == Veredicto.escalar) {
      return ResultadoVeredicto(
        tipo: TipoVeredicto.parcial,
        xp: xpParcial,
        monedas: 0,
        pierdeVida: false,
        impacto: tarjeta.impactoParcial,
      );
    }
    if (amparoActivo) {
      final fallo = tarjeta.impactoFallo;
      return ResultadoVeredicto(
        tipo: TipoVeredicto.amparo,
        xp: 0,
        monedas: 0,
        pierdeVida: false,
        impacto: fallo.copiar(
          riesgoLegal: fallo.riesgoLegal > 0
              ? (fallo.riesgoLegal - reduccionAmparo).clamp(0, fallo.riesgoLegal)
              : fallo.riesgoLegal,
        ),
      );
    }
    return ResultadoVeredicto(
      tipo: TipoVeredicto.incorrecto,
      xp: 0,
      monedas: 0,
      pierdeVida: true,
      impacto: tarjeta.impactoFallo,
    );
  }

  /// Si las [lineas] marcadas en la evidencia incluyen alguna línea clave.
  static bool aciertaEvidencia(EvidenciaTarjeta evidencia, Iterable<int> lineas) =>
      lineas.any(evidencia.lineasClave.contains);

  /// Bonus de evidencia: la tarjeta es de evidencia, la línea clave se marcó
  /// ([evidenciaCorrecta] es `true`; `null` si no se marcó) y el veredicto es
  /// correcto. Solo da +5 XP: no cambia vidas, indicadores ni estrellas.
  static bool bonusEvidencia({
    required Tarjeta tarjeta,
    required bool? evidenciaCorrecta,
    required TipoVeredicto tipo,
  }) =>
      tarjeta.tipo == TipoTarjeta.evidencia &&
      evidenciaCorrecta == true &&
      tipo == TipoVeredicto.correcto;

  /// Bonus de justificación: la tarjeta es de dilema, el veredicto es correcto
  /// y la [opcion] elegida es la correcta. Da +5 XP y monedas dobles. Con el
  /// veredicto equivocado la justificación no cuenta.
  static bool bonusJustificacion({
    required Tarjeta tarjeta,
    required int? opcion,
    required TipoVeredicto tipo,
  }) {
    final justificacion = tarjeta.justificacion;
    return tarjeta.tipo == TipoTarjeta.justificacion &&
        justificacion != null &&
        opcion == justificacion.indiceCorrecto &&
        tipo == TipoVeredicto.correcto;
  }

  /// Si la respuesta a la micro-pregunta es la correcta.
  static bool aciertaMicroPregunta(MicroPregunta pregunta, int opcion) =>
      opcion == pregunta.indiceCorrecto;

  /// Aplica [impacto] al estado, dejando cada indicador entre 0 y 100.
  static EstadoStartup aplicar(EstadoStartup estado, ImpactoTarjeta impacto) {
    int acotar(int v) => v.clamp(0, 100);
    return EstadoStartup(
      presupuesto: acotar(estado.presupuesto + impacto.presupuesto),
      reputacion: acotar(estado.reputacion + impacto.reputacion),
      velocidad: acotar(estado.velocidad + impacto.velocidad),
      riesgoLegal: acotar(estado.riesgoLegal + impacto.riesgoLegal),
    );
  }

  /// Quiebra: Riesgo legal en 100 o Presupuesto en 0.
  static bool haQuebrado(EstadoStartup estado) =>
      estado.riesgoLegal >= 100 || estado.presupuesto <= 0;

  /// Destino al cerrar el panel: quiebra → sin vidas → última tarjeta →
  /// siguiente.
  static DestinoVeredicto destino({
    required EstadoStartup estado,
    required int vidas,
    required bool esUltima,
  }) {
    if (haQuebrado(estado)) return DestinoVeredicto.quiebra;
    if (vidas <= 0) return DestinoVeredicto.sinVidas;
    if (esUltima) return DestinoVeredicto.sprintCompletado;
    return DestinoVeredicto.siguiente;
  }

  /// Texto del "¿Por qué?" según el resultado.
  static String explicacion(Tarjeta tarjeta, TipoVeredicto tipo) => switch (tipo) {
    TipoVeredicto.correcto => tarjeta.explicacion,
    TipoVeredicto.parcial =>
      tarjeta.explicacionParcial ?? tarjeta.explicacionFallo ?? tarjeta.explicacion,
    TipoVeredicto.incorrecto ||
    TipoVeredicto.amparo => tarjeta.explicacionFallo ?? tarjeta.explicacion,
  };
}
