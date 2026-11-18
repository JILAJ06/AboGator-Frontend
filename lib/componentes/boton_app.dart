import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/tema/tokens_color.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'anillo_foco.dart';
import 'icono_app.dart';

/// Tipos visuales del botón. El sexto, "Deshabilitado", se obtiene con
/// `alPresionar: null` en cualquier tipo.
enum TipoBoton { primario, secundario, acento, peligro, fantasma }

/// Botón del diseño: alto 52, radio 16, relleno horizontal 24,
/// texto con el estilo Botón.
///
/// Estado presionado (decisión, no está en Figma): baja 2 dp y la sombra
/// pasa de 4 a 2. Con "reducir animaciones" el cambio es inmediato.
class BotonApp extends StatefulWidget {
  const BotonApp({
    required this.texto,
    required this.alPresionar,
    this.tipo = TipoBoton.primario,
    this.iconoInicio,
    this.iconoFin,
    this.expandido = true,
    super.key,
  });

  static const double alto = 52;
  static const double radio = 16;
  static const double rellenoHorizontal = 24;
  static const double tamanoIcono = 16;

  final String texto;

  /// `null` deja el botón deshabilitado.
  final VoidCallback? alPresionar;
  final TipoBoton tipo;
  final IconData? iconoInicio;
  final IconData? iconoFin;

  /// `true`: ocupa el ancho del contenedor. `false`: ancho intrínseco.
  final bool expandido;

  @override
  State<BotonApp> createState() => _BotonAppState();
}

class _BotonAppState extends State<BotonApp> {
  bool _presionado = false;
  bool _foco = false;

  bool get _habilitado => widget.alPresionar != null;

  void _cambiarPresionado(bool valor) {
    if (_habilitado && _presionado != valor) {
      setState(() => _presionado = valor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final estilo = _EstiloBoton.de(widget.tipo, context.tokens, habilitado: _habilitado);
    final estiloTexto = context.estilos.boton.copyWith(color: estilo.texto);
    final bajada = _presionado ? 2.0 : 0.0;
    final sombra = estilo.conSombra ? EfectosApp.sombraSolida(_presionado ? 2 : 4) : null;
    final duracion = EfectosApp.duracion(context, milisegundos: 80);

    final contenido = Row(
      mainAxisSize: widget.expandido ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.iconoInicio != null) ...[
          IconoApp(widget.iconoInicio!, tamano: BotonApp.tamanoIcono, color: estilo.texto),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(widget.texto, style: estiloTexto, textAlign: TextAlign.center),
        ),
        if (widget.iconoFin != null) ...[
          const SizedBox(width: 8),
          IconoApp(widget.iconoFin!, tamano: BotonApp.tamanoIcono, color: estilo.texto),
        ],
      ],
    );

    final caja = AnimatedContainer(
      duration: duracion,
      transform: Matrix4.translationValues(0, bajada, 0),
      constraints: const BoxConstraints(minHeight: BotonApp.alto),
      padding: const EdgeInsets.symmetric(horizontal: BotonApp.rellenoHorizontal, vertical: 8),
      alignment: widget.expandido ? Alignment.center : null,
      decoration: BoxDecoration(
        color: estilo.fondo,
        borderRadius: BorderRadius.circular(BotonApp.radio),
        border: estilo.borde,
        boxShadow: sombra,
      ),
      child: contenido,
    );

    return Semantics(
      button: true,
      enabled: _habilitado,
      label: widget.texto,
      onTap: widget.alPresionar,
      excludeSemantics: true,
      child: FocusableActionDetector(
        enabled: _habilitado,
        mouseCursor: _habilitado ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onShowFocusHighlight: (valor) => setState(() => _foco = valor),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.alPresionar?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.alPresionar,
          onTapDown: (_) => _cambiarPresionado(true),
          onTapUp: (_) => _cambiarPresionado(false),
          onTapCancel: () => _cambiarPresionado(false),
          child: AnilloFoco(visible: _foco, radio: BotonApp.radio, child: caja),
        ),
      ),
    );
  }
}

class _EstiloBoton {
  const _EstiloBoton({
    required this.fondo,
    required this.texto,
    this.borde,
    this.conSombra = false,
  });

  factory _EstiloBoton.de(TipoBoton tipo, TokensColor t, {required bool habilitado}) {
    if (!habilitado) {
      return _EstiloBoton(fondo: t.fondoSuperficieAlt, texto: t.textoSecundario);
    }
    return switch (tipo) {
      TipoBoton.primario => _EstiloBoton(
        fondo: t.accionPrimaria,
        texto: t.textoEnPrimario,
        conSombra: true,
      ),
      TipoBoton.secundario => _EstiloBoton(
        fondo: t.fondoSuperficie,
        texto: t.accionSecundaria,
        borde: Border.all(color: t.accionSecundaria, width: 2),
      ),
      TipoBoton.acento => _EstiloBoton(
        fondo: t.accionAcento,
        texto: t.textoEnPrimario,
        conSombra: true,
      ),
      TipoBoton.peligro => _EstiloBoton(
        fondo: t.estadoIlegal,
        texto: t.textoEnPrimario,
        conSombra: true,
      ),
      TipoBoton.fantasma => _EstiloBoton(fondo: null, texto: t.textoAcento),
    };
  }

  final Color? fondo;
  final Color texto;
  final BoxBorder? borde;
  final bool conSombra;
}
