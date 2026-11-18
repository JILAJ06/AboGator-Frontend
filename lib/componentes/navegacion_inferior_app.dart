import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'anillo_foco.dart';
import 'icono_app.dart';

/// Pestañas de la barra inferior, en orden.
enum PestanaApp {
  mapa(IconosApp.map, Textos.pestanaMapa),
  buzon(IconosApp.inbox, Textos.pestanaBuzon),
  tienda(IconosApp.store, Textos.pestanaTienda),
  perfil(IconosApp.user, Textos.pestanaPerfil);

  const PestanaApp(this.icono, this.nombre);

  final IconData icono;
  final String nombre;
}

/// Barra de navegación inferior: 58 de contenido más la zona segura inferior
/// del dispositivo (en Figma, 84 = 58 + 26 del indicador de inicio).
///
/// La zona segura se resuelve con `SafeArea(top: false)`: en un teléfono con
/// indicador de inicio el sistema da su propio relleno inferior (≈ 34 en
/// iPhone), y en uno sin indicador queda en 0. Así nunca se tapa el contenido.
class NavegacionInferiorApp extends StatelessWidget {
  const NavegacionInferiorApp({required this.actual, required this.alSeleccionar, super.key});

  static const double altoContenido = 58;

  final PestanaApp actual;
  final ValueChanged<PestanaApp> alSeleccionar;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        border: Border(top: BorderSide(color: tokens.bordeDefault)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: altoContenido),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final pestana in PestanaApp.values)
                  Flexible(
                    child: _Elemento(
                      pestana: pestana,
                      activo: pestana == actual,
                      alPresionar: () => alSeleccionar(pestana),
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

class _Elemento extends StatefulWidget {
  const _Elemento({required this.pestana, required this.activo, required this.alPresionar});

  final PestanaApp pestana;
  final bool activo;
  final VoidCallback alPresionar;

  @override
  State<_Elemento> createState() => _ElementoState();
}

class _ElementoState extends State<_Elemento> {
  bool _foco = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = widget.activo ? tokens.accionPrimaria : tokens.textoSecundario;
    const radio = 14.0;
    return Semantics(
      button: true,
      selected: widget.activo,
      label: Textos.pestanaSemantica(
        widget.pestana.nombre,
        widget.pestana.index + 1,
        PestanaApp.values.length,
      ),
      onTap: widget.alPresionar,
      excludeSemantics: true,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (valor) => setState(() => _foco = valor),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.alPresionar();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.alPresionar,
          child: AnilloFoco(
            visible: _foco,
            radio: radio,
            child: Container(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: widget.activo ? tokens.fondoDestacado : null,
                borderRadius: BorderRadius.circular(radio),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconoApp(widget.pestana.icono, color: color),
                  const SizedBox(height: 4),
                  Text(
                    widget.pestana.nombre,
                    style: context.estilos.leyenda.copyWith(color: color),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
