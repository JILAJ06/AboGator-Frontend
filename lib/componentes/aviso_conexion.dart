import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'icono_app.dart';

/// Aviso de conexión (Figma 23 = 41:5976): fondo/superficie con borde 1.5
/// accion/acento (5 a la izquierda), radio 14, relleno 14×12, separación 10,
/// sombra elevada, `info` de 20 y el texto en Cuerpo/Base (varias líneas).
///
/// Va encima del borde superior de la tarjeta sin empujarla y no recibe
/// toques (el arrastre de la tarjeta pasa). Se anuncia al aparecer o cambiar
/// y no recibe foco.
class AvisoConexion extends StatelessWidget {
  const AvisoConexion({this.restablecida = false, super.key});

  static const double radio = 14;
  static const double bordeIzquierdo = 5;
  static const double borde = 1.5;

  /// `false`: "Conexión inestable…"; `true`: "Conexión restablecida…".
  final bool restablecida;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final texto = restablecida ? Textos.conexionRestablecida : Textos.conexionInestable;
    // El borde de grosor distinto a la izquierda se arma con el color del
    // borde detrás y la superficie encima.
    return Semantics(
      liveRegion: true,
      label: texto,
      excludeSemantics: true,
      child: IgnorePointer(
        child: Container(
          key: const ValueKey('aviso-conexion'),
          padding: const EdgeInsets.fromLTRB(bordeIzquierdo, borde, borde, borde),
          decoration: BoxDecoration(
            color: tokens.accionAcento,
            borderRadius: BorderRadius.circular(radio),
            boxShadow: EfectosApp.sombraGlobo,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: tokens.fondoSuperficie,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(radio - bordeIzquierdo),
                right: Radius.circular(radio - borde),
              ),
            ),
            child: Row(
              children: [
                IconoApp(IconosApp.info, tamano: 20, color: tokens.accionAcento),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    texto,
                    style: context.estilos.cuerpoBase.copyWith(color: tokens.textoPrimario),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
