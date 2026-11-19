import 'package:material_ui/material_ui.dart';

import '../datos/modelos/tarjeta.dart';
import 'boton_veredicto.dart';

/// Fila de los 4 botones de veredicto (Figma 37:1789), separados 14, en este
/// orden: Ilegal, Escalar, Condicional y Legal (333 de ancho en total).
///
/// Si no caben en una fila (pantallas angostas o texto grande), se acomodan en
/// dos filas centradas en lugar de desbordarse.
class AccionesVeredicto extends StatelessWidget {
  const AccionesVeredicto({required this.alElegir, super.key});

  /// Orden de la fila (y del foco, como en Figma 26b).
  static const List<Veredicto> orden = [
    Veredicto.ilegal,
    Veredicto.escalar,
    Veredicto.condicional,
    Veredicto.legal,
  ];

  static const double separacion = 14;

  /// `null` deja los botones decorativos.
  final ValueChanged<Veredicto>? alElegir;

  @override
  Widget build(BuildContext context) {
    final elegir = alElegir;
    return Wrap(
      key: const ValueKey('acciones-veredicto'),
      alignment: WrapAlignment.center,
      spacing: separacion,
      runSpacing: 10,
      children: [
        for (final v in orden)
          BotonVeredicto(veredicto: v, alPresionar: elegir == null ? null : () => elegir(v)),
      ],
    );
  }
}
