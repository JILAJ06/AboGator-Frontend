import 'package:material_ui/material_ui.dart';

/// Píldora: caja de radio 999 con [fondo], [relleno] y, si se pide, [borde],
/// [sombra] y [altoMinimo] (T-15b). La usan chips, etiquetas y avisos breves.
///
/// [clave] va en la caja (las pruebas leen su decoración por clave).
class Pildora extends StatelessWidget {
  const Pildora({
    required this.fondo,
    required this.relleno,
    required this.child,
    this.borde,
    this.sombra,
    this.altoMinimo,
    this.clave,
    super.key,
  });

  static const double radio = 999;

  final Color fondo;
  final EdgeInsetsGeometry relleno;
  final BoxBorder? borde;
  final List<BoxShadow>? sombra;
  final double? altoMinimo;
  final Key? clave;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final altoMinimo = this.altoMinimo;
    return Container(
      key: clave,
      constraints: altoMinimo == null ? null : BoxConstraints(minHeight: altoMinimo),
      padding: relleno,
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(radio),
        border: borde,
        boxShadow: sombra,
      ),
      child: child,
    );
  }
}
