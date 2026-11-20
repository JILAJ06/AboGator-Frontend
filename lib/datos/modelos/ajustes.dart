import 'package:material_ui/material_ui.dart' show ThemeMode;

/// Ajustes de accesibilidad del dispositivo (pantalla 26). No son de la
/// cuenta: cerrar sesión no los borra.
class Ajustes {
  const Ajustes({
    this.modoTema = ThemeMode.system,
    this.escalaTexto = 100,
    this.soloBotones = false,
    this.haptica = true,
    this.tiempoExtendido = false,
    this.reducirAnimaciones = false,
  });

  /// Tamaños de texto que se pueden elegir, en porcentaje.
  static const List<int> escalas = [100, 120, 140, 160];

  /// Tope de la escala efectiva (sistema × ajuste): 200 % (WCAG 1.4.4).
  static const double escalaMaxima = 2;

  final ThemeMode modoTema;

  /// Tamaño de texto en porcentaje (uno de [escalas]).
  final int escalaTexto;

  /// Botones en lugar de deslizar: la tarjeta no se arrastra.
  final bool soloBotones;

  /// Vibración háptica.
  final bool haptica;

  /// Tiempo extendido en exámenes (lo usa el Examen Final, T-11).
  final bool tiempoExtendido;
  final bool reducirAnimaciones;

  Ajustes copyWith({
    ThemeMode? modoTema,
    int? escalaTexto,
    bool? soloBotones,
    bool? haptica,
    bool? tiempoExtendido,
    bool? reducirAnimaciones,
  }) => Ajustes(
    modoTema: modoTema ?? this.modoTema,
    escalaTexto: escalaTexto ?? this.escalaTexto,
    soloBotones: soloBotones ?? this.soloBotones,
    haptica: haptica ?? this.haptica,
    tiempoExtendido: tiempoExtendido ?? this.tiempoExtendido,
    reducirAnimaciones: reducirAnimaciones ?? this.reducirAnimaciones,
  );

  @override
  bool operator ==(Object other) =>
      other is Ajustes &&
      other.modoTema == modoTema &&
      other.escalaTexto == escalaTexto &&
      other.soloBotones == soloBotones &&
      other.haptica == haptica &&
      other.tiempoExtendido == tiempoExtendido &&
      other.reducirAnimaciones == reducirAnimaciones;

  @override
  int get hashCode =>
      Object.hash(modoTema, escalaTexto, soloBotones, haptica, tiempoExtendido, reducirAnimaciones);

  @override
  String toString() =>
      'Ajustes(modo: ${modoTema.name}, texto: $escalaTexto %, soloBotones: $soloBotones, '
      'háptica: $haptica, tiempo: $tiempoExtendido, animaciones: $reducirAnimaciones)';
}
