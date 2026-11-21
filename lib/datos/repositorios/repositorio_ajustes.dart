import 'package:material_ui/material_ui.dart' show ThemeMode;

import '../modelos/ajustes.dart';
import '../modelos/ajustes_notificaciones.dart';

/// Ajustes de accesibilidad guardados en el dispositivo (pantalla 26).
abstract interface class RepositorioAjustes {
  /// Los ajustes guardados; lo que falte o no sea válido toma su valor por
  /// defecto.
  Future<Ajustes> cargar();

  Future<void> guardar(Ajustes ajustes);

  /// Preferencias de notificaciones de racha (pantalla 34, T-13b); lo que
  /// falte toma su valor por defecto.
  Future<AjustesNotificaciones> cargarNotificaciones();

  Future<void> guardarNotificaciones(AjustesNotificaciones notificaciones);
}

/// Claves de las notificaciones en la misma tabla `ajustes` (T-13b).
abstract final class CodecNotificaciones {
  static const String rachaEnRiesgo = 'notif_racha_riesgo';
  static const String apelaciones = 'notif_apelaciones';
  static const String recordatorioDiario = 'notif_recordatorio';
  static const String minutosRecordatorio = 'notif_recordatorio_minutos';
  static const String activadas = 'notif_activadas';
  static const String decidido = 'notif_decidido';

  static const List<String> claves = [
    rachaEnRiesgo,
    apelaciones,
    recordatorioDiario,
    minutosRecordatorio,
    activadas,
    decidido,
  ];

  static Map<String, String> aMapa(AjustesNotificaciones n) => {
    rachaEnRiesgo: n.rachaEnRiesgo ? '1' : '0',
    apelaciones: n.apelaciones ? '1' : '0',
    recordatorioDiario: n.recordatorioDiario ? '1' : '0',
    minutosRecordatorio: '${n.minutosRecordatorio}',
    activadas: n.activadas ? '1' : '0',
    decidido: n.decidido ? '1' : '0',
  };

  static AjustesNotificaciones deMapa(Map<String, String?> m) {
    const defecto = AjustesNotificaciones();
    bool? booleano(String clave) => switch (m[clave]) {
      '1' => true,
      '0' => false,
      _ => null,
    };
    final minutos = int.tryParse(m[minutosRecordatorio] ?? '');
    final valido =
        minutos != null &&
        minutos >= 0 &&
        minutos < 24 * 60 &&
        minutos % AjustesNotificaciones.pasoMinutos == 0;
    return AjustesNotificaciones(
      rachaEnRiesgo: booleano(rachaEnRiesgo) ?? defecto.rachaEnRiesgo,
      apelaciones: booleano(apelaciones) ?? defecto.apelaciones,
      recordatorioDiario: booleano(recordatorioDiario) ?? defecto.recordatorioDiario,
      minutosRecordatorio: valido ? minutos : defecto.minutosRecordatorio,
      activadas: booleano(activadas) ?? defecto.activadas,
      decidido: booleano(decidido) ?? defecto.decidido,
    );
  }
}

/// Conversión clave/valor común a las implementaciones (tabla `ajustes`).
abstract final class CodecAjustes {
  static const String modoTema = 'modo_tema';
  static const String escalaTexto = 'escala_texto';
  static const String soloBotones = 'solo_botones';
  static const String haptica = 'haptica';
  static const String tiempoExtendido = 'tiempo_extendido';
  static const String reducirAnimaciones = 'reducir_animaciones';

  static const List<String> claves = [
    modoTema,
    escalaTexto,
    soloBotones,
    haptica,
    tiempoExtendido,
    reducirAnimaciones,
  ];

  static Map<String, String> aMapa(Ajustes a) => {
    modoTema: a.modoTema.name,
    escalaTexto: '${a.escalaTexto}',
    soloBotones: a.soloBotones ? '1' : '0',
    haptica: a.haptica ? '1' : '0',
    tiempoExtendido: a.tiempoExtendido ? '1' : '0',
    reducirAnimaciones: a.reducirAnimaciones ? '1' : '0',
  };

  static Ajustes deMapa(Map<String, String?> m) {
    const defecto = Ajustes();
    bool? booleano(String clave) => switch (m[clave]) {
      '1' => true,
      '0' => false,
      _ => null,
    };
    final escala = int.tryParse(m[escalaTexto] ?? '');
    return Ajustes(
      modoTema:
          ThemeMode.values.where((t) => t.name == m[modoTema]).firstOrNull ?? defecto.modoTema,
      escalaTexto: Ajustes.escalas.contains(escala) ? escala! : defecto.escalaTexto,
      soloBotones: booleano(soloBotones) ?? defecto.soloBotones,
      haptica: booleano(haptica) ?? defecto.haptica,
      tiempoExtendido: booleano(tiempoExtendido) ?? defecto.tiempoExtendido,
      reducirAnimaciones: booleano(reducirAnimaciones) ?? defecto.reducirAnimaciones,
    );
  }
}
