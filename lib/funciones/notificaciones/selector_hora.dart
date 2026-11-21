// 34c · Hora del recordatorio (T-13b). Aislado en su propio archivo: la hora
// la elige el cliente, pero el envío lo hace el servidor (T-14); si el
// recordatorio se quita, basta con borrar este archivo y su fila.

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../componentes/accion_enfocable.dart';
import '../../componentes/anillo_foco.dart';
import '../../componentes/boton_app.dart';
import '../../core/adaptativo/clase_pantalla.dart';
import '../../core/tema/efectos.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/ajustes_notificaciones.dart';

/// Reglas puras de la hora del recordatorio (minutos desde la medianoche).
abstract final class LogicaHora {
  /// "7:00 p. m.", "12:05 a. m.".
  static String formatear(int minutos) {
    final h24 = (minutos ~/ 60) % 24;
    final m = minutos % 60;
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    final periodo = h24 < 12 ? Textos.am : Textos.pm;
    return '$h12:${m.toString().padLeft(2, '0')} $periodo';
  }

  /// Partes para las ruedas: hora 1–12, minuto (índice de 5 en 5) y si es p. m.
  static ({int hora, int indiceMinuto, bool pm}) partes(int minutos) {
    final h24 = (minutos ~/ 60) % 24;
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    return (
      hora: h12,
      indiceMinuto: (minutos % 60) ~/ AjustesNotificaciones.pasoMinutos,
      pm: h24 >= 12,
    );
  }

  /// Minutos desde la medianoche a partir de las ruedas.
  static int componer({required int hora, required int indiceMinuto, required bool pm}) {
    final h24 = (hora % 12) + (pm ? 12 : 0);
    return h24 * 60 + indiceMinuto * AjustesNotificaciones.pasoMinutos;
  }
}

/// Abre el selector: hoja inferior en móvil y diálogo centrado de 440 en
/// tablet. Devuelve los minutos elegidos o `null` si se canceló (también con
/// Esc o tocando fuera).
///
/// Con [soloBotones] ("Botones en lugar de deslizar") cada rueda lleva + y −.
Future<int?> mostrarSelectorHora(
  BuildContext context, {
  required int inicial,
  bool soloBotones = false,
}) {
  if (context.clasePantalla.esTablet) {
    return showDialog<int>(
      context: context,
      barrierColor: EfectosApp.colorVelo,
      builder: (contexto) => Dialog(
        backgroundColor: const Color(0x00000000),
        elevation: 0,
        insetPadding: const EdgeInsets.all(MedidasAdaptativas.margen),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: SelectorHora.anchoDialogo),
          child: SelectorHora(inicial: inicial, enDialogo: true, soloBotones: soloBotones),
        ),
      ),
    );
  }
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: const Color(0x00000000),
    elevation: 0,
    barrierColor: EfectosApp.colorVelo,
    isScrollControlled: true,
    builder: (contexto) => SelectorHora(inicial: inicial, soloBotones: soloBotones),
  );
}

/// Contenido del selector (Figma 34c): título (H3), leyenda, tres ruedas
/// (hora 1–12, minutos de 5 en 5 y a. m./p. m.) con la fila elegida de 48
/// sobre fondo/superficie-alt (radio 14), "Guardar" y "Cancelar".
///
/// Cada rueda es ajustable para el lector (aumentar/disminuir) y con las
/// flechas ↑ ↓ del teclado; con "Botones en lugar de deslizar" lleva botones
/// + y − (el arrastre nunca es la única vía).
class SelectorHora extends StatefulWidget {
  const SelectorHora({
    required this.inicial,
    this.enDialogo = false,
    this.soloBotones = false,
    super.key,
  });

  static const double anchoDialogo = 440;
  static const double altoFila = 48;

  final int inicial;
  final bool enDialogo;

  /// Botones + y − junto a cada rueda.
  final bool soloBotones;

  @override
  State<SelectorHora> createState() => _SelectorHoraState();
}

class _SelectorHoraState extends State<SelectorHora> {
  late final _p = LogicaHora.partes(widget.inicial);
  late int _hora = _p.hora;
  late int _minuto = _p.indiceMinuto;
  late bool _pm = _p.pm;

  static final _horas = [for (var h = 1; h <= 12; h++) '$h'];
  static final _minutos = [
    for (var m = 0; m < 60; m += AjustesNotificaciones.pasoMinutos) m.toString().padLeft(2, '0'),
  ];
  static const _periodos = [Textos.am, Textos.pm];

  int get _minutosElegidos => LogicaHora.componer(hora: _hora, indiceMinuto: _minuto, pm: _pm);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final conBotones = widget.soloBotones;
    final ruedas = Row(
      key: const ValueKey('ruedas-hora'),
      children: [
        Expanded(
          child: RuedaSelector(
            clave: 'hora',
            nombre: Textos.ruedaHora,
            valores: _horas,
            indice: _hora - 1,
            ciclica: true,
            alCambiar: (i) => setState(() => _hora = i + 1),
            conBotones: conBotones,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RuedaSelector(
            clave: 'minutos',
            nombre: Textos.ruedaMinutos,
            valores: _minutos,
            indice: _minuto,
            ciclica: true,
            alCambiar: (i) => setState(() => _minuto = i),
            conBotones: conBotones,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RuedaSelector(
            clave: 'periodo',
            nombre: Textos.ruedaPeriodo,
            valores: _periodos,
            indice: _pm ? 1 : 0,
            alCambiar: (i) => setState(() => _pm = i == 1),
            conBotones: conBotones,
          ),
        ),
      ],
    );

    final contenido = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.enDialogo) ...[
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: tokens.bordeDefault,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Semantics(
            header: true,
            child: Text(
              Textos.horaRecordatorio,
              style: estilos.h3.copyWith(color: tokens.textoPrimario),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            Textos.horaRecordatorioDetalle,
            style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
          ),
          const SizedBox(height: 16),
          ruedas,
          const SizedBox(height: 20),
          BotonApp(
            key: const ValueKey('boton-guardar-hora'),
            texto: Textos.guardar,
            alPresionar: () => Navigator.of(context).pop(_minutosElegidos),
          ),
          const SizedBox(height: 8),
          BotonApp(
            key: const ValueKey('boton-cancelar-hora'),
            texto: Textos.cancelar,
            tipo: TipoBoton.fantasma,
            altoMinimo: 48,
            alPresionar: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );

    final radio = widget.enDialogo
        ? BorderRadius.circular(28)
        : const BorderRadius.vertical(top: Radius.circular(28));
    return Container(
      key: const ValueKey('selector-hora'),
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        borderRadius: radio,
        boxShadow: EfectosApp.sombraGlobo,
      ),
      child: SafeArea(top: false, child: contenido),
    );
  }
}

/// Una rueda del selector: tres filas visibles de 48 (la del centro, la
/// elegida, sobre fondo/superficie-alt; las vecinas más tenues).
///
/// - Arrastre o toque en una fila vecina para cambiar.
/// - Lector: ajustable ("Hora, 7"; aumentar y disminuir).
/// - Teclado: ↑ aumenta y ↓ disminuye; anillo de foco al llegar con Tab.
/// - [conBotones]: botones + arriba y − abajo.
class RuedaSelector extends StatefulWidget {
  const RuedaSelector({
    required this.clave,
    required this.nombre,
    required this.valores,
    required this.indice,
    required this.alCambiar,
    this.ciclica = false,
    this.conBotones = false,
    super.key,
  });

  final String clave;
  final String nombre;
  final List<String> valores;
  final int indice;
  final ValueChanged<int> alCambiar;

  /// Al pasar del último valor vuelve al primero (hora y minutos).
  final bool ciclica;
  final bool conBotones;

  @override
  State<RuedaSelector> createState() => _RuedaSelectorState();
}

class _RuedaSelectorState extends State<RuedaSelector> {
  late final _controlador = FixedExtentScrollController(initialItem: widget.indice);
  final _foco = FocusNode();
  bool _anillo = false;

  @override
  void didUpdateWidget(RuedaSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controlador.hasClients && _controlador.selectedItem != widget.indice) {
      _mover(widget.indice);
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    _foco.dispose();
    super.dispose();
  }

  int _siguiente(int paso) {
    final n = widget.valores.length;
    final i = widget.indice + paso;
    return widget.ciclica ? i % n : i.clamp(0, n - 1);
  }

  void _mover(int i) {
    if (!_controlador.hasClients) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controlador.jumpToItem(i);
    } else {
      _controlador.animateToItem(
        i,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
  }

  void _paso(int paso) {
    final i = _siguiente(paso);
    if (i != widget.indice) widget.alCambiar(i);
  }

  KeyEventResult _alTeclear(FocusNode _, KeyEvent evento) {
    if (evento is! KeyDownEvent && evento is! KeyRepeatEvent) return KeyEventResult.ignored;
    if (evento.logicalKey == LogicalKeyboardKey.arrowUp) {
      _paso(1);
      return KeyEventResult.handled;
    }
    if (evento.logicalKey == LogicalKeyboardKey.arrowDown) {
      _paso(-1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    const alto = SelectorHora.altoFila;
    final valor = widget.valores[widget.indice];
    final rueda = SizedBox(
      height: alto * 3,
      child: Stack(
        children: [
          Center(
            child: Container(
              height: alto,
              decoration: BoxDecoration(
                color: tokens.fondoSuperficieAlt,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          ListWheelScrollView.useDelegate(
            key: ValueKey('rueda-${widget.clave}'),
            controller: _controlador,
            itemExtent: alto,
            physics: const FixedExtentScrollPhysics(),
            overAndUnderCenterOpacity: 0.45,
            onSelectedItemChanged: (i) {
              if (i != widget.indice) widget.alCambiar(i);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.valores.length,
              builder: (context, i) => Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.valores[i],
                    style: estilos.h3.copyWith(
                      color: i == widget.indice ? tokens.textoPrimario : tokens.textoSecundario,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final ajustable = Semantics(
      container: true,
      label: widget.nombre,
      value: valor,
      increasedValue: widget.valores[_siguiente(1)],
      decreasedValue: widget.valores[_siguiente(-1)],
      onIncrease: () => _paso(1),
      onDecrease: () => _paso(-1),
      excludeSemantics: true,
      child: Focus(
        focusNode: _foco,
        onKeyEvent: _alTeclear,
        onFocusChange: (enfocado) => setState(
          () => _anillo =
              enfocado && FocusManager.instance.highlightMode == FocusHighlightMode.traditional,
        ),
        child: AnilloFoco(visible: _anillo, radio: 14, child: rueda),
      ),
    );

    if (!widget.conBotones) return ajustable;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BotonPaso(
          clave: 'mas-${widget.clave}',
          simbolo: '+',
          etiqueta: Textos.aumentar(widget.nombre),
          alPresionar: () => _paso(1),
        ),
        ajustable,
        _BotonPaso(
          clave: 'menos-${widget.clave}',
          simbolo: '−',
          etiqueta: Textos.disminuir(widget.nombre),
          alPresionar: () => _paso(-1),
        ),
      ],
    );
  }
}

/// Botón + o − de 48 × 48 (borde 1 borde/default, radio 12).
class _BotonPaso extends StatelessWidget {
  const _BotonPaso({
    required this.clave,
    required this.simbolo,
    required this.etiqueta,
    required this.alPresionar,
  });

  final String clave;
  final String simbolo;
  final String etiqueta;
  final VoidCallback alPresionar;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AccionEnfocable(
      key: ValueKey(clave),
      alPresionar: alPresionar,
      radio: 12,
      semantica: (hijo) => Semantics(
        button: true,
        label: etiqueta,
        onTap: alPresionar,
        excludeSemantics: true,
        child: hijo,
      ),
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tokens.fondoSuperficie,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tokens.bordeDefault),
        ),
        child: Text(simbolo, style: context.estilos.h2.copyWith(color: tokens.textoPrimario)),
      ),
    );
  }
}
