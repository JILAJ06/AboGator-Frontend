import '../../core/textos/textos.dart';
import '../../datos/modelos/resultado_apelacion.dart';
import '../../datos/modelos/tarjeta.dart';

/// Reglas puras del juicio de apelación (22, 22b y la perdida).
abstract final class LogicaApelacion {
  /// Días de repaso, en orden.
  static const List<int> dias = [3, 7, 14];

  /// Se gana solo con la respuesta correcta; cualquier otra (incluido
  /// Escalar de más) se pierde. No hay parcial.
  static bool gana(Tarjeta tarjeta, Veredicto veredicto) => veredicto == tarjeta.respuestaCorrecta;

  /// "APELACIÓN · LICENCIAS OSS".
  static String etiqueta(String tema) => Textos.etiquetaApelacion(tema);

  /// Frase de regreso del resultado: en N días, dominada o mañana.
  static String fraseRegreso(ResultadoApelacion r) {
    if (!r.ganada) return Textos.vuelveManana;
    final dias = r.diasParaVolver;
    return r.dominada || dias == null ? Textos.tarjetaDominada : Textos.vuelveEnDias(dias);
  }

  /// Qué píldoras de repaso están hechas: al ganar, los días ≤ [diaActual];
  /// al perder, solo los anteriores.
  static List<bool> hechos(int diaActual, {required bool ganada}) => [
    for (final d in dias) ganada ? d <= diaActual : d < diaActual,
  ];

  /// "Legal", "Ilegal", "Condicional" o "Escalar".
  static String nombre(Veredicto v) => switch (v) {
    Veredicto.legal => Textos.veredictoLegalNombre,
    Veredicto.ilegal => Textos.veredictoIlegalNombre,
    Veredicto.condicional => Textos.veredictoCondicionalNombre,
    Veredicto.escalar => Textos.veredictoEscalarNombre,
  };

  /// Texto del resultado: "Esta vez sí: …" / "Esta vez no: … La respuesta
  /// correcta era …", seguido de la frase de regreso.
  static String texto(Tarjeta tarjeta, ResultadoApelacion r) => r.ganada
      ? '${Textos.estaVezSi}${tarjeta.explicacion}\n${fraseRegreso(r)}'
      : '${Textos.estaVezNo}${tarjeta.explicacionFallo ?? tarjeta.explicacion}\n'
            '${Textos.respuestaCorrectaEra(nombre(tarjeta.respuestaCorrecta))}\n${fraseRegreso(r)}';
}
