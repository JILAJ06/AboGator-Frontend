import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/tema/iconos_app.dart';
import '../core/tema/tokens_color.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import '../datos/modelos/tarjeta.dart';
import 'anillo_foco.dart';
import 'icono_app.dart';

/// Botón de veredicto: círculo de 68 con borde 3 en el color del estado,
/// ícono de 32 y etiqueta en mayúsculas debajo (hueco 6).
///
/// Sin [alPresionar] es decorativo y se excluye de la semántica. Con él tiene
/// zona táctil completa, anillo de foco y nombre accesible
/// ("Veredicto: Legal con condiciones", etc.).
class BotonVeredicto extends StatefulWidget {
  const BotonVeredicto({required this.veredicto, this.alPresionar, super.key});

  static const double diametro = 68;
  static const double tamanoIcono = 32;

  /// Ancho de la columna de Condicional (su etiqueta es la más larga).
  static const double anchoCondicional = 87;

  final Veredicto veredicto;
  final VoidCallback? alPresionar;

  static IconData icono(Veredicto v) => switch (v) {
    Veredicto.ilegal => IconosApp.x,
    Veredicto.legal => IconosApp.check,
    Veredicto.condicional => IconosApp.arrowUp,
    Veredicto.escalar => IconosApp.arrowDown,
  };

  static String etiqueta(Veredicto v) => switch (v) {
    Veredicto.ilegal => Textos.veredictoIlegal,
    Veredicto.legal => Textos.veredictoLegal,
    Veredicto.condicional => Textos.veredictoCondicional,
    Veredicto.escalar => Textos.veredictoEscalar,
  };

  static String etiquetaSemantica(Veredicto v) => switch (v) {
    Veredicto.ilegal => Textos.veredictoSemanticaIlegal,
    Veredicto.legal => Textos.veredictoSemanticaLegal,
    Veredicto.condicional => Textos.veredictoSemanticaCondicional,
    Veredicto.escalar => Textos.veredictoSemanticaEscalar,
  };

  static Color color(Veredicto v, TokensColor t) => switch (v) {
    Veredicto.ilegal => t.estadoIlegal,
    Veredicto.legal => t.estadoLegal,
    Veredicto.condicional => t.estadoCondicional,
    Veredicto.escalar => t.estadoEscalar,
  };

  @override
  State<BotonVeredicto> createState() => _BotonVeredictoState();
}

class _BotonVeredictoState extends State<BotonVeredicto> {
  bool _foco = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final v = widget.veredicto;
    final color = BotonVeredicto.color(v, tokens);

    final circulo = Container(
      width: BotonVeredicto.diametro,
      height: BotonVeredicto.diametro,
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 3),
        boxShadow: EfectosApp.sombraVeredicto,
      ),
      child: Center(
        child: IconoApp(BotonVeredicto.icono(v), tamano: BotonVeredicto.tamanoIcono, color: color),
      ),
    );

    Widget contenido = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnilloFoco(visible: _foco, radio: BotonVeredicto.diametro / 2, child: circulo),
        const SizedBox(height: 6),
        Text(
          BotonVeredicto.etiqueta(v),
          style: context.estilos.etiqueta.copyWith(color: color),
          textAlign: TextAlign.center,
        ),
      ],
    );
    if (v == Veredicto.condicional) {
      contenido = ConstrainedBox(
        constraints: const BoxConstraints(minWidth: BotonVeredicto.anchoCondicional),
        child: contenido,
      );
    }

    final alPresionar = widget.alPresionar;
    if (alPresionar == null) {
      return ExcludeSemantics(child: contenido);
    }

    return Semantics(
      button: true,
      label: BotonVeredicto.etiquetaSemantica(v),
      onTap: alPresionar,
      excludeSemantics: true,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (valor) => setState(() => _foco = valor),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              alPresionar();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: alPresionar,
          child: contenido,
        ),
      ),
    );
  }
}
