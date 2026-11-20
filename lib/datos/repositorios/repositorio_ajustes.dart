import 'package:material_ui/material_ui.dart' show ThemeMode;

import '../modelos/ajustes.dart';

/// Ajustes de accesibilidad guardados en el dispositivo (pantalla 26).
abstract interface class RepositorioAjustes {
  /// Los ajustes guardados; lo que falte o no sea válido toma su valor por
  /// defecto.
  Future<Ajustes> cargar();

  Future<void> guardar(Ajustes ajustes);
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
