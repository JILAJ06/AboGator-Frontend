/// Por qué quebró la Startup (19b): Riesgo legal en 100 o Presupuesto en 0.
enum CausaQuiebra { riesgoLegal, presupuesto }

/// Indicadores de la Startup, en porcentaje (0 a 100).
///
/// Si [riesgoLegal] llega a 100 o [presupuesto] a 0, la Startup quiebra.
class EstadoStartup {
  const EstadoStartup({
    required this.presupuesto,
    required this.reputacion,
    required this.velocidad,
    required this.riesgoLegal,
  });

  final int presupuesto;
  final int reputacion;
  final int velocidad;
  final int riesgoLegal;

  @override
  bool operator ==(Object other) =>
      other is EstadoStartup &&
      other.presupuesto == presupuesto &&
      other.reputacion == reputacion &&
      other.velocidad == velocidad &&
      other.riesgoLegal == riesgoLegal;

  @override
  int get hashCode => Object.hash(presupuesto, reputacion, velocidad, riesgoLegal);

  @override
  String toString() => 'EstadoStartup($presupuesto, $reputacion, $velocidad, $riesgoLegal)';
}
