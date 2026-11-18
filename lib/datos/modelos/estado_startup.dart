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
}
