/// Preferencias de notificaciones de racha (pantalla 34, T-13b). Se guardan
/// en el dispositivo con los ajustes; el envío real es del servidor (T-14).
class AjustesNotificaciones {
  const AjustesNotificaciones({
    this.rachaEnRiesgo = true,
    this.apelaciones = true,
    this.recordatorioDiario = false,
    this.minutosRecordatorio = horaPorDefecto,
    this.activadas = false,
    this.decidido = false,
  });

  /// 7:00 p. m., en minutos desde la medianoche.
  static const int horaPorDefecto = 19 * 60;

  /// Paso de los minutos en el selector de hora.
  static const int pasoMinutos = 5;

  final bool rachaEnRiesgo;
  final bool apelaciones;
  final bool recordatorioDiario;

  /// Hora del recordatorio diario, en minutos desde la medianoche (múltiplo
  /// de [pasoMinutos]).
  final int minutosRecordatorio;

  /// "Activar notificaciones" (`true`) o "Ahora no" (`false`).
  final bool activadas;

  /// Ya se eligió "Activar notificaciones" o "Ahora no" al menos una vez.
  final bool decidido;

  AjustesNotificaciones copyWith({
    bool? rachaEnRiesgo,
    bool? apelaciones,
    bool? recordatorioDiario,
    int? minutosRecordatorio,
    bool? activadas,
    bool? decidido,
  }) => AjustesNotificaciones(
    rachaEnRiesgo: rachaEnRiesgo ?? this.rachaEnRiesgo,
    apelaciones: apelaciones ?? this.apelaciones,
    recordatorioDiario: recordatorioDiario ?? this.recordatorioDiario,
    minutosRecordatorio: minutosRecordatorio ?? this.minutosRecordatorio,
    activadas: activadas ?? this.activadas,
    decidido: decidido ?? this.decidido,
  );

  @override
  bool operator ==(Object other) =>
      other is AjustesNotificaciones &&
      other.rachaEnRiesgo == rachaEnRiesgo &&
      other.apelaciones == apelaciones &&
      other.recordatorioDiario == recordatorioDiario &&
      other.minutosRecordatorio == minutosRecordatorio &&
      other.activadas == activadas &&
      other.decidido == decidido;

  @override
  int get hashCode => Object.hash(
    rachaEnRiesgo,
    apelaciones,
    recordatorioDiario,
    minutosRecordatorio,
    activadas,
    decidido,
  );

  @override
  String toString() =>
      'AjustesNotificaciones(racha: $rachaEnRiesgo, apelaciones: $apelaciones, '
      'recordatorio: $recordatorioDiario a $minutosRecordatorio min, activadas: $activadas, '
      'decidido: $decidido)';
}
