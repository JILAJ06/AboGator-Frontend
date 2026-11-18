import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'anillo_foco.dart';
import 'icono_app.dart';

/// Tipo de dato del campo: define teclado, autocompletado y si se oculta.
enum TipoCampo { texto, nombre, correo, contrasena }

/// Campo de texto del diseño: etiqueta siempre visible, caja de 52 con
/// radio 14 y mensaje de error opcional (hueco 6 entre cada parte).
class CampoTextoApp extends StatefulWidget {
  const CampoTextoApp({
    required this.etiqueta,
    this.controlador,
    this.textoAyuda,
    this.error,
    this.tipo = TipoCampo.texto,
    this.iconoInicio,
    this.alCambiar,
    this.nodoFoco,
    this.accionTeclado,
    super.key,
  });

  static const double altoCaja = 52;
  static const double radio = 14;

  final String etiqueta;
  final TextEditingController? controlador;
  final String? textoAyuda;

  /// Mensaje de error. Si no es `null`, el campo se muestra en estado de error
  /// y el mensaje se anuncia al lector de pantalla.
  final String? error;
  final TipoCampo tipo;
  final IconData? iconoInicio;
  final ValueChanged<String>? alCambiar;
  final FocusNode? nodoFoco;
  final TextInputAction? accionTeclado;

  @override
  State<CampoTextoApp> createState() => _CampoTextoAppState();
}

class _CampoTextoAppState extends State<CampoTextoApp> {
  FocusNode? _nodoPropio;
  bool _ocultarTexto = true;
  bool _anilloVisible = false;

  FocusNode get _nodo => widget.nodoFoco ?? (_nodoPropio ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _nodo.addListener(_alCambiarFoco);
  }

  @override
  void didUpdateWidget(CampoTextoApp anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.nodoFoco != widget.nodoFoco) {
      (anterior.nodoFoco ?? _nodoPropio)?.removeListener(_alCambiarFoco);
      _nodo.addListener(_alCambiarFoco);
    }
  }

  @override
  void dispose() {
    _nodo.removeListener(_alCambiarFoco);
    _nodoPropio?.dispose();
    super.dispose();
  }

  void _alCambiarFoco() {
    final teclado = FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    setState(() => _anilloVisible = _nodo.hasFocus && teclado);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final hayError = widget.error != null;
    final enfocado = _nodo.hasFocus;

    final borde = hayError
        ? Border.all(color: tokens.estadoIlegal, width: 2)
        : enfocado
        ? Border.all(color: tokens.accionPrimaria, width: 2)
        : Border.all(color: tokens.bordeControl, width: 1.5);

    final esContrasena = widget.tipo == TipoCampo.contrasena;

    final campo = TextField(
      controller: widget.controlador,
      focusNode: _nodo,
      onChanged: widget.alCambiar,
      obscureText: esContrasena && _ocultarTexto,
      enableSuggestions: !esContrasena,
      autocorrect: widget.tipo == TipoCampo.texto,
      keyboardType: switch (widget.tipo) {
        TipoCampo.correo => TextInputType.emailAddress,
        TipoCampo.contrasena => TextInputType.visiblePassword,
        TipoCampo.nombre => TextInputType.name,
        TipoCampo.texto => TextInputType.text,
      },
      textCapitalization: widget.tipo == TipoCampo.nombre
          ? TextCapitalization.words
          : TextCapitalization.none,
      autofillHints: switch (widget.tipo) {
        TipoCampo.correo => const [AutofillHints.email],
        TipoCampo.contrasena => const [AutofillHints.password],
        TipoCampo.nombre => const [AutofillHints.name],
        TipoCampo.texto => null,
      },
      textInputAction: widget.accionTeclado,
      style: estilos.cuerpoGrande.copyWith(color: tokens.textoPrimario),
      cursorColor: tokens.accionPrimaria,
      decoration: InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        hintText: widget.textoAyuda,
        hintStyle: estilos.cuerpoGrande.copyWith(color: tokens.textoSecundario),
      ),
    );

    // El borde va en primer plano para que su grosor (1.5 o 2) no cambie
    // el alto de la caja entre estados.
    final caja = Container(
      key: const ValueKey('caja-campo'),
      constraints: const BoxConstraints(minHeight: CampoTextoApp.altoCaja),
      padding: EdgeInsets.only(left: 16, right: esContrasena ? 0 : 16),
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        borderRadius: BorderRadius.circular(CampoTextoApp.radio),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CampoTextoApp.radio),
        border: borde,
      ),
      child: Row(
        children: [
          if (widget.iconoInicio != null) ...[
            IconoApp(widget.iconoInicio!, tamano: 20, color: tokens.textoSecundario),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Semantics(label: widget.etiqueta, child: campo),
            ),
          ),
          if (esContrasena) _botonMostrar(context),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Text(
            widget.etiqueta,
            style: estilos.etiqueta.copyWith(color: tokens.textoPrimario),
          ),
        ),
        const SizedBox(height: 6),
        AnilloFoco(visible: _anilloVisible, radio: CampoTextoApp.radio, child: caja),
        if (hayError) ...[
          const SizedBox(height: 6),
          Semantics(
            liveRegion: true,
            child: Text(widget.error!, style: estilos.leyenda.copyWith(color: tokens.estadoIlegal)),
          ),
        ],
      ],
    );
  }

  Widget _botonMostrar(BuildContext context) {
    final etiqueta = _ocultarTexto ? Textos.mostrarContrasena : Textos.ocultarContrasena;
    return Semantics(
      button: true,
      label: etiqueta,
      excludeSemantics: true,
      onTap: _alternarOcultar,
      child: InkResponse(
        onTap: _alternarOcultar,
        radius: 24,
        child: SizedBox.square(
          dimension: 48,
          child: Center(
            child: IconoApp(
              _ocultarTexto ? IconosApp.eye : IconosApp.eyeOff,
              tamano: 20,
              color: context.tokens.textoSecundario,
            ),
          ),
        ),
      ),
    );
  }

  void _alternarOcultar() {
    setState(() => _ocultarTexto = !_ocultarTexto);
  }
}
