import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';

/// Snippet de código de la evidencia (Figma 10:89): fondo #0B1220, radio 18,
/// 12 abajo y recorta. Barra #162030 (relleno 14/12, separación 6) con los
/// tres botones de ventana de 10 y el nombre del archivo; cada línea tiene
/// relleno 14/3 y separación 14 entre el número (ancho fijo) y el texto, en
/// JetBrains Mono 12/18 sin saltos: si no cabe, el bloque se desplaza en
/// horizontal.
///
/// - [reveladas]: líneas clave que se muestran en rojo (solo en 16b).
/// - [marcadas]: líneas que marcó el jugador (un resaltado amarillo con borde
///   por cada tramo de líneas seguidas).
/// - Con [alMarcar], cada línea es un botón: tocar marca esa línea y arrastrar
///   en vertical marca varias. Con teclado, flechas arriba y abajo mueven el
///   foco y Enter o Espacio marcan.
///
/// Las líneas miden 24 como en Figma: el área tocable no se amplía a 44
/// porque se solaparía con las líneas vecinas.
class SnippetCodigo extends StatefulWidget {
  const SnippetCodigo({
    required this.archivo,
    required this.lineas,
    this.reveladas = const {},
    this.marcadas = const {},
    this.alMarcar,
    super.key,
  });

  static const double radio = 18;

  final String archivo;
  final List<String> lineas;
  final Set<int> reveladas;
  final Set<int> marcadas;

  /// Recibe las líneas marcadas (empiezan en 1). `null`: solo lectura.
  final ValueChanged<List<int>>? alMarcar;

  /// Tramos de líneas seguidas, por ejemplo {4, 5, 6, 9} → (4, 6) y (9, 9).
  static List<(int, int)> tramos(Set<int> lineas) {
    final orden = lineas.toList()..sort();
    final tramos = <(int, int)>[];
    for (final n in orden) {
      if (tramos.isNotEmpty && tramos.last.$2 == n - 1) {
        tramos.last = (tramos.last.$1, n);
      } else {
        tramos.add((n, n));
      }
    }
    return tramos;
  }

  @override
  State<SnippetCodigo> createState() => _SnippetCodigoState();
}

class _SnippetCodigoState extends State<SnippetCodigo> {
  late List<FocusNode> _nodos = _crearNodos();

  /// Líneas que se van marcando con un arrastre (aún sin confirmar).
  final Set<int> _arrastre = {};
  int? _inicioArrastre;

  List<FocusNode> _crearNodos() => [
    for (var i = 0; i < widget.lineas.length; i++) FocusNode(debugLabel: 'línea ${i + 1}'),
  ];

  @override
  void didUpdateWidget(SnippetCodigo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lineas.length != widget.lineas.length) {
      for (final n in _nodos) {
        n.dispose();
      }
      _nodos = _crearNodos();
    }
  }

  @override
  void dispose() {
    for (final n in _nodos) {
      n.dispose();
    }
    super.dispose();
  }

  double _altoLinea(BuildContext context) => 6 + MediaQuery.textScalerOf(context).scale(12) * 1.5;

  int _lineaEn(double y) =>
      (y / _altoLinea(context)).floor().clamp(0, widget.lineas.length - 1) + 1;

  void _empezarArrastre(DragStartDetails d) {
    final linea = _lineaEn(d.localPosition.dy);
    setState(() {
      _inicioArrastre = linea;
      _arrastre
        ..clear()
        ..add(linea);
    });
  }

  void _moverArrastre(DragUpdateDetails d) {
    final inicio = _inicioArrastre;
    if (inicio == null) return;
    final actual = _lineaEn(d.localPosition.dy);
    final (desde, hasta) = inicio <= actual ? (inicio, actual) : (actual, inicio);
    setState(() {
      _arrastre
        ..clear()
        ..addAll([for (var i = desde; i <= hasta; i++) i]);
    });
  }

  void _terminarArrastre([DragEndDetails? _]) {
    final lineas = _arrastre.toList()..sort();
    setState(() {
      _inicioArrastre = null;
      _arrastre.clear();
    });
    if (lineas.isNotEmpty) widget.alMarcar?.call(lineas);
  }

  KeyEventResult _alTeclear(int indice, KeyEvent evento) {
    if (evento is! KeyDownEvent && evento is! KeyRepeatEvent) return KeyEventResult.ignored;
    final destino = switch (evento.logicalKey) {
      LogicalKeyboardKey.arrowUp => indice - 1,
      LogicalKeyboardKey.arrowDown => indice + 1,
      _ => null,
    };
    if (destino == null) return KeyEventResult.ignored;
    if (destino >= 0 && destino < _nodos.length) _nodos[destino].requestFocus();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final alMarcar = widget.alMarcar;
    final total = widget.lineas.length;
    final estilo = context.estilos.codigo;
    // Ancho fijo de los números: el del número más largo.
    final anchoNumero = MediaQuery.textScalerOf(context).scale(7.3) * '$total'.length;

    final marcadas = {...widget.marcadas, ..._arrastre};
    final alto = _altoLinea(context);
    final duracion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : EfectosApp.duracionResaltado;

    final lineas = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, texto) in widget.lineas.indexed)
          _Linea(
            numero: i + 1,
            texto: texto,
            anchoNumero: anchoNumero,
            estilo: estilo,
            revelada: widget.reveladas.contains(i + 1),
            marcada: marcadas.contains(i + 1),
            nodoFoco: _nodos[i],
            alTeclear: (evento) => _alTeclear(i, evento),
            alMarcar: alMarcar == null ? null : () => alMarcar([i + 1]),
          ),
      ],
    );

    // Resaltado del jugador (Figma 38:4552-4553): un rectángulo por cada
    // tramo de líneas seguidas, a 12 de los lados, con borde 2 y radio 6.
    final filas = Stack(
      children: [
        lineas,
        for (final (inicio, fin) in SnippetCodigo.tramos(marcadas))
          Positioned(
            left: 12,
            right: 12,
            top: (inicio - 1) * alto,
            height: (fin - inicio + 1) * alto,
            child: IgnorePointer(
              child: TweenAnimationBuilder<double>(
                key: ValueKey('resaltado-$inicio-$fin'),
                tween: Tween(begin: 0, end: 1),
                duration: duracion,
                builder: (context, valor, hijo) => Opacity(opacity: valor, child: hijo),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: EfectosApp.resaltado.withValues(alpha: EfectosApp.opacidadResaltado),
                    border: Border.all(color: EfectosApp.resaltado, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    return Semantics(
      container: true,
      label: Textos.snippetSemantica(widget.archivo, total),
      child: Container(
        key: const ValueKey('snippet-codigo'),
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: EfectosApp.fondoSnippet,
          borderRadius: BorderRadius.circular(SnippetCodigo.radio),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(
              child: Container(
                key: const ValueKey('barra-snippet'),
                color: EfectosApp.barraSnippet,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    for (final color in const [
                      EfectosApp.ventanaRojo,
                      EfectosApp.ventanaAmbar,
                      EfectosApp.ventanaVerde,
                    ]) ...[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        '  ${widget.archivo}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: estilo.copyWith(color: EfectosApp.textoSecundarioSnippet),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, restricciones) => SingleChildScrollView(
                key: const ValueKey('snippet-desplazable'),
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: restricciones.maxWidth),
                  child: IntrinsicWidth(
                    child: alMarcar == null
                        ? filas
                        : GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            // La línea donde empieza el dedo cuenta, no la de
                            // después de la tolerancia.
                            dragStartBehavior: DragStartBehavior.down,
                            onVerticalDragStart: _empezarArrastre,
                            onVerticalDragUpdate: _moverArrastre,
                            onVerticalDragEnd: _terminarArrastre,
                            onVerticalDragCancel: _terminarArrastre,
                            child: filas,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Linea extends StatefulWidget {
  const _Linea({
    required this.numero,
    required this.texto,
    required this.anchoNumero,
    required this.estilo,
    required this.revelada,
    required this.marcada,
    required this.nodoFoco,
    required this.alTeclear,
    required this.alMarcar,
  });

  final int numero;
  final String texto;
  final double anchoNumero;
  final TextStyle estilo;
  final bool revelada;
  final bool marcada;
  final FocusNode nodoFoco;
  final KeyEventResult Function(KeyEvent) alTeclear;
  final VoidCallback? alMarcar;

  @override
  State<_Linea> createState() => _LineaState();
}

class _LineaState extends State<_Linea> {
  bool _foco = false;

  @override
  Widget build(BuildContext context) {
    final alMarcar = widget.alMarcar;
    final colorTexto = widget.revelada ? EfectosApp.textoLineaClave : EfectosApp.textoSnippet;

    Widget linea = Container(
      key: ValueKey('linea-${widget.numero}'),
      color: widget.revelada ? EfectosApp.fondoLineaClave : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: widget.anchoNumero,
            child: Text(
              '${widget.numero}',
              softWrap: false,
              style: widget.estilo.copyWith(color: EfectosApp.textoSecundarioSnippet),
            ),
          ),
          const SizedBox(width: 14),
          Text(widget.texto, softWrap: false, style: widget.estilo.copyWith(color: colorTexto)),
        ],
      ),
    );

    // Foco de teclado, encima de la línea.
    linea = Stack(
      children: [
        linea,
        if (_foco)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                key: ValueKey('foco-linea-${widget.numero}'),
                decoration: BoxDecoration(
                  border: Border.all(color: context.tokens.focoAnillo, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
      ],
    );

    final etiqueta = Textos.lineaSemantica(
      widget.numero,
      widget.texto,
      marcada: widget.marcada,
      clave: widget.revelada,
    );
    if (alMarcar == null) {
      return Semantics(label: etiqueta, excludeSemantics: true, child: linea);
    }
    return Semantics(
      button: true,
      label: etiqueta,
      onTap: alMarcar,
      excludeSemantics: true,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: (_, evento) => widget.alTeclear(evento),
        child: FocusableActionDetector(
          focusNode: widget.nodoFoco,
          mouseCursor: SystemMouseCursors.click,
          onShowFocusHighlight: (valor) => setState(() => _foco = valor),
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                alMarcar();
                return null;
              },
            ),
          },
          child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: alMarcar, child: linea),
        ),
      ),
    );
  }
}
