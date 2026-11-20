import 'apelacion.dart';

/// Buzón de Apelaciones tal como lo manda el servidor: su hora
/// ([ahoraServidor]) y las apelaciones, primero las de hoy y luego las
/// futuras por fecha.
///
/// Los plazos se cuentan en días calendario UTC con la hora del servidor,
/// nunca con el reloj del dispositivo.
class BuzonApelaciones {
  BuzonApelaciones({required this.ahoraServidor, required List<Apelacion> apelaciones})
    : apelaciones = List.unmodifiable(
        <Apelacion>[...apelaciones]..sort((a, b) => a.disponibleEl.compareTo(b.disponibleEl)),
      );

  final DateTime ahoraServidor;
  final List<Apelacion> apelaciones;

  /// Total en el Buzón (el contador del botón Buzón).
  int get total => apelaciones.length;

  /// Las que se pueden apelar hoy (una vencida también cuenta como de hoy).
  List<Apelacion> get deHoy => [
    for (final a in apelaciones)
      if (diasHasta(a) <= 0) a,
  ];

  /// Días calendario (UTC) que faltan para [a]: 0 o menos es hoy, 1 mañana.
  int diasHasta(Apelacion a) => diasEntre(ahoraServidor, a.disponibleEl);

  /// Días calendario UTC de [desde] a [hasta].
  static int diasEntre(DateTime desde, DateTime hasta) {
    DateTime dia(DateTime d) {
      final u = d.toUtc();
      return DateTime.utc(u.year, u.month, u.day);
    }

    return dia(hasta).difference(dia(desde)).inDays;
  }
}
