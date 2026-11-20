import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

/// Vibraciones de la app con un significado (ajuste "Vibración háptica",
/// pantalla 26: corta = acierto · doble = error). Es la única vía para
/// vibrar: nadie llama a `HapticFeedback` directo.
abstract interface class ServicioHaptico {
  /// Veredicto correcto: un pulso ligero.
  Future<void> acierto();

  /// Veredicto parcial: un clic de selección.
  Future<void> parcial();

  /// Error (y Amparo): dos pulsos medios separados por [ServicioHapticoSistema.pausaError].
  Future<void> error();

  /// Confirmación suave (compra, apelación ganada, muestra del ajuste).
  Future<void> suave();
}

/// Pulsos que puede dar el sistema.
enum PulsoHaptico { ligero, medio, seleccion }

/// Vibración real del sistema. No hace nada en web ni con [activo] en falso.
class ServicioHapticoSistema implements ServicioHaptico {
  ServicioHapticoSistema({
    required this.activo,
    this.web = kIsWeb,
    Future<void> Function(PulsoHaptico pulso)? pulsar,
    Future<void> Function(Duration espera)? esperar,
  }) : _pulsar = pulsar ?? _pulsoDelSistema,
       _esperar = esperar ?? Future<void>.delayed;

  /// Lee el ajuste en el momento de vibrar.
  final bool Function() activo;
  final bool web;
  final Future<void> Function(PulsoHaptico pulso) _pulsar;
  final Future<void> Function(Duration espera) _esperar;

  /// Pausa entre los dos pulsos del error.
  static const Duration pausaError = Duration(milliseconds: 90);

  static Future<void> _pulsoDelSistema(PulsoHaptico pulso) => switch (pulso) {
    PulsoHaptico.ligero => HapticFeedback.lightImpact(),
    PulsoHaptico.medio => HapticFeedback.mediumImpact(),
    PulsoHaptico.seleccion => HapticFeedback.selectionClick(),
  };

  bool get _puede => !web && activo();

  @override
  Future<void> acierto() async {
    if (_puede) await _pulsar(PulsoHaptico.ligero);
  }

  @override
  Future<void> parcial() async {
    if (_puede) await _pulsar(PulsoHaptico.seleccion);
  }

  @override
  Future<void> error() async {
    if (!_puede) return;
    await _pulsar(PulsoHaptico.medio);
    await _esperar(pausaError);
    await _pulsar(PulsoHaptico.medio);
  }

  @override
  Future<void> suave() async {
    if (_puede) await _pulsar(PulsoHaptico.ligero);
  }
}
