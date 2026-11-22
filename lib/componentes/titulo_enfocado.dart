import 'package:material_ui/material_ui.dart';

import '../core/utilidades/extensiones_contexto.dart';
import 'bloque_lectura.dart';

/// Título de pantalla, hoja o diálogo (T-15c): encabezado que recibe el foco
/// al abrir ([autofocus]), con anillo de radio 8. Por defecto H1 en
/// texto/primario; [estilo] y [color] lo cambian. Con [enVivo] además se
/// anuncia al aparecer.
///
/// [clave] va en el `BloqueLectura` (las pruebas lo buscan por clave).
class TituloEnfocado extends StatelessWidget {
  const TituloEnfocado(
    this.texto, {
    this.estilo,
    this.color,
    this.alineacion,
    this.autofocus = true,
    this.enVivo = false,
    this.clave,
    super.key,
  });

  final String texto;

  /// Estilo base; por defecto H1. El color se pone encima.
  final TextStyle? estilo;

  /// Color del texto; por defecto texto/primario.
  final Color? color;
  final TextAlign? alineacion;
  final bool autofocus;
  final bool enVivo;
  final Key? clave;

  @override
  Widget build(BuildContext context) => BloqueLectura(
    key: clave,
    encabezado: true,
    enVivo: enVivo,
    autofocus: autofocus,
    radio: 8,
    child: Text(
      texto,
      textAlign: alineacion,
      style: (estilo ?? context.estilos.h1).copyWith(color: color ?? context.tokens.textoPrimario),
    ),
  );
}
