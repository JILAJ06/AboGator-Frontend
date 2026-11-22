import 'package:material_ui/material_ui.dart';

import '../core/utilidades/extensiones_contexto.dart';

/// Fondo de una [CajaSuperficie].
enum FondoCaja { superficie, superficieAlt, destacado }

/// Caja de superficie (T-15c): fondo del tema ([fondo]), radio [radio] y, con
/// [conBorde], borde 1 borde/default. Sin sombra ni degradado: esas cajas se
/// quedan como están.
///
/// [clave] va en la caja (las pruebas leen su decoración por clave).
class CajaSuperficie extends StatelessWidget {
  const CajaSuperficie({
    this.fondo = FondoCaja.superficie,
    this.radio = 16,
    this.conBorde = false,
    this.relleno,
    this.ancho,
    this.alto,
    this.alineacion,
    this.recorte = Clip.none,
    this.clave,
    this.child,
    super.key,
  });

  final FondoCaja fondo;
  final double radio;
  final bool conBorde;
  final EdgeInsetsGeometry? relleno;
  final double? ancho;
  final double? alto;
  final AlignmentGeometry? alineacion;
  final Clip recorte;
  final Key? clave;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      key: clave,
      width: ancho,
      height: alto,
      alignment: alineacion,
      padding: relleno,
      clipBehavior: recorte,
      decoration: BoxDecoration(
        color: switch (fondo) {
          FondoCaja.superficie => tokens.fondoSuperficie,
          FondoCaja.superficieAlt => tokens.fondoSuperficieAlt,
          FondoCaja.destacado => tokens.fondoDestacado,
        },
        borderRadius: BorderRadius.circular(radio),
        border: conBorde ? Border.all(color: tokens.bordeDefault) : null,
      ),
      child: child,
    );
  }
}

/// Tarjeta de lista (T-15c): caja de superficie con borde, recorte
/// antialias y las [filas] separadas por divisores de 1 en borde/default.
class TarjetaLista extends StatelessWidget {
  const TarjetaLista({
    required this.filas,
    this.radio = 16,
    this.alineacion = CrossAxisAlignment.stretch,
    this.clave,
    super.key,
  });

  final List<Widget> filas;
  final double radio;
  final CrossAxisAlignment alineacion;
  final Key? clave;

  @override
  Widget build(BuildContext context) {
    final borde = context.tokens.bordeDefault;
    return CajaSuperficie(
      clave: clave,
      radio: radio,
      conBorde: true,
      recorte: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: alineacion,
        children: [
          for (final (i, fila) in filas.indexed) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: borde),
            fila,
          ],
        ],
      ),
    );
  }
}
