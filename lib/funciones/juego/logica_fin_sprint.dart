import '../../componentes/indicadores_startup.dart';
import '../../core/textos/textos.dart';
import '../../datos/modelos/estado_startup.dart';
import '../../datos/modelos/modulo.dart';
import 'estado_juego.dart';
import 'logica_veredicto.dart';

/// Reglas puras del fin de sprint (pantallas 19 y 19b).
abstract final class LogicaFinSprint {
  /// Con este porcentaje de aciertos o más se ganan 3 estrellas.
  static const int porcentajeTresEstrellas = 90;

  /// Con este porcentaje de aciertos o más se ganan 2 estrellas.
  static const int porcentajeDosEstrellas = 60;

  /// Aciertos: tarjetas calificadas como correctas (con o sin bonus). Las
  /// parciales no cuentan.
  static int aciertos(List<ResultadoTarjeta> resultados) =>
      resultados.where((r) => r.tipo == TipoVeredicto.correcto).length;

  /// Falladas: incorrectas y Amparo. Las parciales no cuentan.
  static int falladas(List<ResultadoTarjeta> resultados) => resultados
      .where((r) => r.tipo == TipoVeredicto.incorrecto || r.tipo == TipoVeredicto.amparo)
      .length;

  /// Estrellas de un sprint completado: ≥ 90 % de aciertos da 3, ≥ 60 % da 2 y
  /// menos da 1 (completar da siempre al menos una). Como en Figma 19: 8 de 10
  /// aciertos dan 2 estrellas.
  static int estrellas({required int aciertos, required int total}) {
    if (total <= 0) return 1;
    // Sin decimales: aciertos / total ≥ p / 100.
    if (aciertos * 100 >= porcentajeTresEstrellas * total) return Sprint.maximoEstrellas;
    if (aciertos * 100 >= porcentajeDosEstrellas * total) return 2;
    return 1;
  }

  /// Cambio de cada indicador respecto al inicio del sprint (sin los que no
  /// cambiaron).
  static Map<IndicadorStartup, int> cambios(EstadoStartup inicio, EstadoStartup fin) => {
    for (final i in IndicadorStartup.values)
      if (i.valorEn(fin) != i.valorEn(inicio)) i: i.valorEn(fin) - i.valorEn(inicio),
  };

  /// Causa de la quiebra; `null` si la Startup no quebró. Si se dan las dos,
  /// manda el Riesgo legal.
  static CausaQuiebra? causaQuiebra(EstadoStartup estado) {
    if (estado.riesgoLegal >= 100) return CausaQuiebra.riesgoLegal;
    if (estado.presupuesto <= 0) return CausaQuiebra.presupuesto;
    return null;
  }

  /// Aviso del buzón para [falladas] tarjetas; `null` si no hay falladas.
  static String? avisoBuzon(int falladas) => falladas <= 0 ? null : Textos.avisoBuzon(falladas);

  /// Descripción de la quiebra: la del sprint o una genérica según la causa.
  static String descripcionQuiebra(Sprint? sprint, CausaQuiebra causa) =>
      sprint?.mensajeQuiebra ??
      switch (causa) {
        CausaQuiebra.riesgoLegal => Textos.quiebraGenericaRiesgo,
        CausaQuiebra.presupuesto => Textos.quiebraGenericaPresupuesto,
      };
}
