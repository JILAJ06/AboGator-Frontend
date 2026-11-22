import 'package:material_ui/material_ui.dart';

import '../core/utilidades/extensiones_contexto.dart';
import 'accion_enfocable.dart';
import 'icono_app.dart';

/// Botón cuadrado de 48 × 48 con radio 12 (T-15b): por defecto fondo/superficie,
/// borde 1 borde/default y el [icono] de 20 en texto/primario. Se enfoca con
/// anillo y se anuncia como botón con [etiqueta].
///
/// Lo usan [BotonAtras], [BotonCerrar], el atrás del encabezado del módulo y
/// los botones + y − del selector de hora ([hijo] en lugar del ícono).
/// [claveCaja] va en la caja (las pruebas la miden por clave).
class BotonIconoCaja extends StatelessWidget {
  const BotonIconoCaja({
    required this.etiqueta,
    required this.alPresionar,
    this.icono,
    this.hijo,
    this.claveCaja,
    this.fondo,
    this.conBorde = true,
    this.colorIcono,
    super.key,
  }) : assert(icono != null || hijo != null, 'Hace falta un ícono o un hijo');

  static const double lado = 48;
  static const double radio = 12;

  final String etiqueta;
  final VoidCallback? alPresionar;
  final IconData? icono;

  /// Contenido en lugar del ícono (por ejemplo, el símbolo + o −).
  final Widget? hijo;
  final Key? claveCaja;

  /// Fondo de la caja; por defecto fondo/superficie.
  final Color? fondo;
  final bool conBorde;

  /// Color del ícono; por defecto texto/primario.
  final Color? colorIcono;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AccionEnfocable(
      alPresionar: alPresionar,
      radio: radio,
      semantica: (contenido) => Semantics(
        button: true,
        label: etiqueta,
        onTap: alPresionar,
        excludeSemantics: true,
        child: contenido,
      ),
      child: Container(
        key: claveCaja,
        width: lado,
        height: lado,
        decoration: BoxDecoration(
          color: fondo ?? tokens.fondoSuperficie,
          borderRadius: BorderRadius.circular(radio),
          border: conBorde ? Border.all(color: tokens.bordeDefault) : null,
        ),
        child: Center(
          child: hijo ?? IconoApp(icono!, tamano: 20, color: colorIcono ?? tokens.textoPrimario),
        ),
      ),
    );
  }
}
