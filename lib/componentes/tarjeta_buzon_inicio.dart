import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'boton_app.dart';
import 'caja_superficie.dart';
import 'icono_app.dart';

/// Tarjeta "Buzón de Apelaciones" del Inicio en tablet (Figma 96:564):
/// fondo/destacado, radio 20, relleno 20 y separación 12. Ícono inbox de 24 y
/// título (H3), texto (Cuerpo/Base en texto/secundario) y el botón secundario
/// "Abrir Buzón (N)" a todo el ancho.
///
/// Con 0 [pendientes] dice "No tienes apelaciones pendientes." y no muestra el
/// botón (el riel sigue llevando al Buzón).
class TarjetaBuzonInicio extends StatelessWidget {
  const TarjetaBuzonInicio({required this.pendientes, required this.alAbrir, super.key});

  static const double radio = 20;

  final int pendientes;
  final VoidCallback? alAbrir;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return CajaSuperficie(
      clave: const ValueKey('tarjeta-buzon-inicio'),
      relleno: const EdgeInsets.all(20),
      fondo: FondoCaja.destacado,
      radio: radio,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            label: Textos.buzonTitulo,
            excludeSemantics: true,
            child: Row(
              children: [
                IconoApp(IconosApp.inbox, color: tokens.textoPrimario),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    Textos.buzonTitulo,
                    style: estilos.h3.copyWith(color: tokens.textoPrimario),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            pendientes > 0 ? Textos.buzonInicioTexto(pendientes) : Textos.buzonInicioVacio,
            style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
          ),
          if (pendientes > 0) ...[
            const SizedBox(height: 12),
            BotonApp(
              key: const ValueKey('boton-abrir-buzon'),
              texto: Textos.abrirBuzon(pendientes),
              tipo: TipoBoton.secundario,
              alPresionar: alAbrir,
            ),
          ],
        ],
      ),
    );
  }
}
