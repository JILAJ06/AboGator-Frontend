import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/textos/textos.dart';
import 'mensaje_pantalla.dart';

/// Carga, error y datos de una pantalla (T-15c): con [valor] en datos llama a
/// [datos]; con error muestra [MensajePantalla] con [textoError] y
/// «Reintentar» ([alReintentar]); mientras carga, el [esqueleto].
///
/// Dos políticas, iguales a las que ya tenían las pantallas:
/// - por defecto, la del `switch` de Dart sobre el `AsyncValue` (`AsyncData`,
///   `AsyncError`, lo demás es carga);
/// - con [conservarValor], si hay un valor (aunque esté recargando o haya
///   fallado después) se muestran los datos; si no, el error y luego el
///   esqueleto.
///
/// Sin entrada en la galería: no tiene vista propia.
class VistaAsincrona<T> extends StatelessWidget {
  const VistaAsincrona({
    required this.valor,
    required this.datos,
    required this.esqueleto,
    required this.textoError,
    required this.alReintentar,
    this.conservarValor = false,
    super.key,
  });

  final AsyncValue<T> valor;
  final Widget Function(T valor) datos;
  final Widget esqueleto;
  final String textoError;
  final VoidCallback alReintentar;
  final bool conservarValor;

  @override
  Widget build(BuildContext context) {
    final error = MensajePantalla(
      texto: textoError,
      textoBoton: Textos.reintentar,
      alPresionar: alReintentar,
    );
    if (conservarValor) {
      final actual = valor.value;
      if (actual != null) return datos(actual);
      return valor.hasError ? error : esqueleto;
    }
    return switch (valor) {
      AsyncData(:final value) => datos(value),
      AsyncError() => error,
      _ => esqueleto,
    };
  }
}
