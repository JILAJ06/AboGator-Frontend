import '../../core/textos/textos.dart';
import '../../datos/mocks/escenario_ransomware.dart';
import '../../datos/modelos/apelacion.dart';
import '../../datos/modelos/examen.dart';
import '../../datos/modelos/resultado_examen.dart';

/// Reglas puras del resultado del Examen Final (29 y 30).
abstract final class LogicaResultado {
  /// Una apelación por decisión fallada (veredicto, tiempo o fundamento),
  /// sin repetir decisión. El título es "Hora 24 · CTO" (≤ 45).
  static List<NuevaApelacion> apelaciones(List<DecisionFallada> falladas, String moduloId) {
    final vistos = <String>{};
    return [
      for (final f in falladas)
        if (vistos.add(f.decision.id))
          NuevaApelacion(
            tarjetaId: f.decision.id,
            moduloId: moduloId,
            titulo: titulo(f.decision),
            tema: EscenarioRansomware.tema,
          ),
    ];
  }

  /// "Hora 24 · CTO", recortado con "…" a 45.
  static String titulo(DecisionCrisis d) =>
      EscenarioRansomware.tituloApelacion(d.hora, d.personaje);

  /// Texto de 29: con el módulo siguiente o, si era el último, el cierre.
  static String textoAprobado(ModuloDesbloqueado? siguiente) => siguiente == null
      ? Textos.aprobadoUltimo
      : Textos.aprobadoDesbloqueo(siguiente.numero, siguiente.nombre);

  /// "Ana López · 9/10 aciertos · 28 oct 2026".
  static String detalleCertificado(Certificado c) => Textos.detalleCertificado(
    c.nombrePersona,
    c.aciertos,
    c.totalDecisiones,
    Certificado.fechaCorta(c.fecha),
  );

  /// Lo que se copia al compartir.
  static String textoCompartir(Certificado c) =>
      Textos.compartirCertificado(c.nombreModulo, c.folio, Certificado.fechaCorta(c.fecha));

  /// Lectura de la tarjeta del certificado como un solo bloque.
  static String semanticaCertificado(Certificado c) => Textos.certificadoSemantica(
    c.nombreModulo,
    c.nombrePersona,
    c.aciertos,
    c.totalDecisiones,
    Certificado.fechaLarga(c.fecha),
    c.folio,
  );

  /// Perdió por quedarse sin vidas (si no, se acabaron las decisiones).
  static bool sinVidas(int vidas) => vidas <= 0;
}
