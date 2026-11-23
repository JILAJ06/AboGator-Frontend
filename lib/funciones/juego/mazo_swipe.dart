import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../componentes/anillo_foco.dart';
import '../../componentes/pila_tarjetas.dart';
import '../../componentes/sello_veredicto.dart';
import '../../componentes/tinte_veredicto.dart';
import '../../core/textos/textos.dart';
import '../../datos/modelos/tarjeta.dart';
import 'logica_swipe.dart';

/// Lo que se ve del arrastre fuera del mazo (el tinte de pantalla completa).
@immutable
class ArrastreVisible {
  const ArrastreVisible({this.veredicto, this.progreso = 0});

  /// Veredicto hacia el que apunta la tarjeta; `null` en reposo.
  final Veredicto? veredicto;

  /// 0 en reposo y 1 al llegar al umbral.
  final double progreso;

  @override
  bool operator ==(Object other) =>
      other is ArrastreVisible && other.veredicto == veredicto && other.progreso == progreso;

  @override
  int get hashCode => Object.hash(veredicto, progreso);
}

/// Reconocedor de arrastre que gana la arena en cuanto se toca la tarjeta:
/// así el gesto es de la tarjeta aunque la pantalla sea desplazable (el
/// desplazamiento se hace desde fuera de ella).
class _ArrastreInmediato extends PanGestureRecognizer {
  _ArrastreInmediato() : super(supportedDevices: null);

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolvePointer(event.pointer, GestureDisposition.accepted);
  }
}

/// Zona de la tarjeta del juego: pila, tarjeta que se arrastra en 4
/// direcciones y los 4 sellos. Ocupa todo el espacio que le den; la tarjeta
/// mide ese alto − 20 (lo que asoma la pila).
///
/// - Arrastre: el eje se decide a los 12 dp y se bloquea; en horizontal la
///   tarjeta se inclina hasta 12°. Al soltar confirma si pasó el umbral o hubo
///   un lanzamiento; si no, regresa con un resorte corto.
/// - [previsualizar], [cancelarPrevia] y [confirmar] dan el mismo resultado
///   con teclado y botones.
/// - Con "reducir animaciones" no hay vuelo, resorte ni entrada animada.
/// - Con [retenerAlConfirmar] (tablet ancha, T-13) la tarjeta no sale volando
///   al confirmar: se coloca en el umbral con su sello y se queda mientras la
///   hoja lateral está abierta; sale volando cuando llega la siguiente (al
///   cerrar la hoja). [alConfirmar] se llama en el mismo momento que con el
///   vuelo.
class MazoSwipe extends StatefulWidget {
  const MazoSwipe({
    required this.claveTarjeta,
    required this.tarjeta,
    required this.etiquetaSemantica,
    required this.restantes,
    required this.alConfirmar,
    required this.arrastre,
    this.alInspeccionar,
    this.arrastreActivo = true,
    this.retenerAlConfirmar = false,
    super.key,
  });

  /// Cambia con cada tarjeta (dispara la entrada desde la pila).
  final Object claveTarjeta;

  /// La tarjeta de caso que se dibuja.
  final Widget tarjeta;

  /// "Tarjeta k de n. personaje, rol: texto".
  final String etiquetaSemantica;

  /// Tarjetas que quedan detrás de la actual (para la pila).
  final int restantes;

  /// Se llama al terminar el vuelo de la tarjeta.
  final ValueChanged<Veredicto> alConfirmar;

  /// Se actualiza con el arrastre (lo usa el tinte de la pantalla).
  final ValueNotifier<ArrastreVisible> arrastre;

  /// Solo en tarjetas con evidencia: un toque sobre la tarjeta (soltar sin
  /// haberla movido) abre el visor, y el lector tiene la acción "Inspeccionar
  /// evidencia".
  final VoidCallback? alInspeccionar;

  /// Con `false` (ajuste "Botones en lugar de deslizar") la tarjeta no se
  /// arrastra: no hay reconocedor de arrastre. Los botones, el teclado y las
  /// acciones del lector siguen calificando, y un toque abre el visor.
  final bool arrastreActivo;

  /// La tarjeta confirmada se queda con su sello hasta la siguiente (tablet
  /// con hoja lateral; ver la descripción de la clase).
  final bool retenerAlConfirmar;

  /// Movimiento máximo para que soltar cuente como toque.
  static const double toleranciaToque = 8;

  /// Duraciones.
  static const Duration duracionVuelo = Duration(milliseconds: 280);
  static const Duration duracionRegreso = Duration(milliseconds: 250);
  static const Duration duracionEntrada = Duration(milliseconds: 200);

  /// Lo que asoma la pila por debajo de la tarjeta.
  static const double altoPila = 20;

  @override
  State<MazoSwipe> createState() => MazoSwipeState();
}

class MazoSwipeState extends State<MazoSwipe> with TickerProviderStateMixin {
  late final AnimationController _movimiento = AnimationController(vsync: this);
  late final AnimationController _entrada = AnimationController(
    vsync: this,
    value: 1,
    duration: MazoSwipe.duracionEntrada,
  );

  /// Vuelo de la tarjeta retenida cuando llega la siguiente.
  late final AnimationController _salida = AnimationController(
    vsync: this,
    duration: MazoSwipe.duracionVuelo,
  );

  EjeSwipe? _eje;
  Offset _arrastreBruto = Offset.zero;
  Offset _desplazamiento = Offset.zero;
  double _angulo = 0;

  /// Veredicto de una previsualización con teclado.
  Veredicto? _previa;

  /// Vuelo en curso (no admite otra confirmación).
  bool _volando = false;

  /// La tarjeta ya salió de la zona: sin sello ni tinte hasta la siguiente
  /// (como en Figma 12 y 14, mientras está abierto el panel).
  bool _fuera = false;

  /// La tarjeta confirmada se quedó en el umbral con su sello
  /// ([MazoSwipe.retenerAlConfirmar]); [_veredictoRetenido] es su veredicto.
  bool _retenida = false;
  Veredicto? _veredictoRetenido;

  /// Copia de la tarjeta retenida que sale volando sobre la nueva.
  _TarjetaSaliente? _saliente;
  Size _zona = Size.zero;

  /// La tarjeta se quedó en el umbral tras confirmar (pruebas y pantallas).
  bool get retenida => _retenida;

  Animation<Offset>? _animDesplazamiento;
  Animation<double>? _animAngulo;

  bool get _sinAnimaciones => MediaQuery.disableAnimationsOf(context);

  /// Veredicto previsualizado con teclado, si hay.
  Veredicto? get previa => _previa;

  @override
  void initState() {
    super.initState();
    _movimiento.addListener(() {
      setState(() {
        _desplazamiento = _animDesplazamiento?.value ?? _desplazamiento;
        _angulo = _animAngulo?.value ?? _angulo;
      });
      _publicar();
    });
    _entrada.addListener(() => setState(() {}));
    _salida.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(MazoSwipe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.claveTarjeta != widget.claveTarjeta) {
      final veredicto = _veredictoRetenido;
      if (_retenida && veredicto != null && !_sinAnimaciones) {
        // La anterior sale volando desde donde se quedó (al cerrar la hoja).
        _saliente = _TarjetaSaliente(
          tarjeta: oldWidget.tarjeta,
          veredicto: veredicto,
          desde: _desplazamiento,
          angulo: _angulo,
        );
        _salida.forward(from: 0).then((_) {
          if (mounted) setState(() => _saliente = null);
        });
      }
      _reiniciar();
      if (_sinAnimaciones) {
        _entrada.value = 1;
      } else {
        _entrada.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _movimiento.dispose();
    _entrada.dispose();
    _salida.dispose();
    super.dispose();
  }

  void _reiniciar() {
    _movimiento.stop();
    _eje = null;
    _arrastreBruto = Offset.zero;
    _desplazamiento = Offset.zero;
    _angulo = 0;
    _previa = null;
    _volando = false;
    _fuera = false;
    _retenida = false;
    _veredictoRetenido = null;
    // Se llama mientras se reconstruye: el tinte se avisa al terminar el cuadro.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _publicar();
    });
  }

  double get _progreso => LogicaSwipe.progreso(_eje, _desplazamiento, _zona.width);

  Veredicto? get _veredictoActual => LogicaSwipe.veredictoDe(_eje, _desplazamiento);

  void _publicar() {
    widget.arrastre.value = ArrastreVisible(veredicto: _veredictoActual, progreso: _progreso);
  }

  void _colocar(EjeSwipe? eje, Offset desplazamiento) {
    setState(() {
      _eje = eje;
      _desplazamiento = desplazamiento;
      _angulo = LogicaSwipe.anguloGrados(eje, desplazamiento, _zona.width);
    });
    _publicar();
  }

  // --- Arrastre -------------------------------------------------------------

  void _alEmpezar(DragStartDetails _) {
    if (_volando) return;
    _movimiento.stop();
    _previa = null;
    _arrastreBruto = Offset.zero;
    _colocar(null, Offset.zero);
  }

  void _alMover(DragUpdateDetails detalles) {
    if (_volando) return;
    _arrastreBruto += detalles.delta;
    final eje = _eje ?? LogicaSwipe.decidirEje(_arrastreBruto);
    _colocar(eje, LogicaSwipe.sobreEje(eje, _arrastreBruto));
  }

  void _alSoltar(DragEndDetails detalles) {
    if (_volando) return;
    final veredicto = LogicaSwipe.alSoltar(
      eje: _eje,
      desplazamiento: _desplazamiento,
      velocidad: detalles.velocity.pixelsPerSecond,
      ancho: _zona.width,
    );
    if (veredicto == null) {
      // Un toque no es un arrastre: abre el visor si la tarjeta lo tiene.
      final toque = _arrastreBruto.distance <= MazoSwipe.toleranciaToque;
      _regresar();
      if (toque) widget.alInspeccionar?.call();
    } else {
      confirmar(veredicto);
    }
  }

  // --- Teclado y botones ----------------------------------------------------

  /// Coloca la tarjeta en el umbral de [veredicto], con su sello y tinte.
  void previsualizar(Veredicto veredicto) {
    if (_volando) return;
    _movimiento.stop();
    _previa = veredicto;
    _colocar(
      LogicaSwipe.ejeDe(veredicto),
      LogicaSwipe.desplazamientoPrevio(veredicto, _zona.width),
    );
  }

  /// Quita la previsualización y regresa la tarjeta.
  void cancelarPrevia() {
    if (_volando) return;
    _previa = null;
    _regresar();
  }

  /// Hace salir volando la tarjeta hacia [veredicto] y, al terminar, avisa.
  void confirmar(Veredicto veredicto) {
    if (_volando) return;
    _volando = true;
    _previa = null;
    final eje = LogicaSwipe.ejeDe(veredicto);
    // Si la tarjeta estaba quieta (botón), arranca desde el umbral para que
    // el sello y el tinte se vean durante el vuelo.
    if (_eje != eje || _veredictoActual != veredicto) {
      _colocar(eje, LogicaSwipe.desplazamientoPrevio(veredicto, _zona.width));
    }
    final retener = widget.retenerAlConfirmar;
    // Retenida: la tarjeta va al umbral (con su sello completo) y se queda.
    final destino = retener
        ? LogicaSwipe.desplazamientoPrevio(veredicto, _zona.width)
        : LogicaSwipe.destinoVuelo(veredicto, _zona.width, _zona.height);
    final anguloFinal = retener
        ? LogicaSwipe.anguloGrados(eje, destino, _zona.width)
        : eje == EjeSwipe.horizontal
        ? LogicaSwipe.anguloVuelo * LogicaSwipe.direccion(veredicto).dx
        : 0.0;
    void terminar() {
      if (!mounted) return;
      setState(() {
        if (retener) {
          _retenida = true;
          _veredictoRetenido = veredicto;
        } else {
          _fuera = true;
        }
      });
      widget.arrastre.value = const ArrastreVisible();
      widget.alConfirmar(veredicto);
    }

    if (_sinAnimaciones) {
      _colocar(eje, destino);
      terminar();
      return;
    }
    _animar(
      destino,
      anguloFinal,
      MazoSwipe.duracionVuelo,
      retener ? Curves.easeOut : Curves.easeIn,
    ).then((_) => terminar());
  }

  void _regresar() {
    if (_sinAnimaciones || _desplazamiento == Offset.zero) {
      _colocar(null, Offset.zero);
      return;
    }
    _animar(Offset.zero, 0, MazoSwipe.duracionRegreso, Curves.easeOutBack).then((_) {
      if (mounted && !_volando) _colocar(null, Offset.zero);
    });
  }

  TickerFuture _animar(Offset destino, double angulo, Duration duracion, Curve curva) {
    final curvada = CurvedAnimation(parent: _movimiento, curve: curva);
    _animDesplazamiento = Tween<Offset>(begin: _desplazamiento, end: destino).animate(curvada);
    _animAngulo = Tween<double>(begin: _angulo, end: angulo).animate(curvada);
    _movimiento.duration = duracion;
    return _movimiento.forward(from: 0);
  }

  // --- Dibujo ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        _zona = restricciones.biggest;
        final ancho = _zona.width;
        final altoTarjeta = math.max(0.0, _zona.height - MazoSwipe.altoPila);
        final progreso = _progreso;
        final actual = _veredictoActual;
        double opacidad(Veredicto v) => !_fuera && actual == v ? progreso : 0;

        // Entrada desde la pila: de la escala y posición de Pila 1 a la normal.
        final e = Curves.easeOut.transform(_entrada.value);
        final escalaEntrada = 1 - (1 - (ancho - 2 * PilaTarjetas.margen) / ancho) * (1 - e);
        final bajadaEntrada = PilaTarjetas.desplazamiento * (1 - e);

        final tarjeta = Semantics(
          container: true,
          liveRegion: true,
          label: widget.etiquetaSemantica,
          customSemanticsActions: {
            for (final v in [
              Veredicto.legal,
              Veredicto.ilegal,
              Veredicto.condicional,
              Veredicto.escalar,
            ])
              CustomSemanticsAction(label: _accion(v)): () => confirmar(v),
            const CustomSemanticsAction(label: Textos.accionInspeccionar): ?widget.alInspeccionar,
          },
          excludeSemantics: true,
          child: RawGestureDetector(
            key: const ValueKey('gesto-tarjeta'),
            behavior: HitTestBehavior.opaque,
            gestures: {
              if (widget.arrastreActivo)
                _ArrastreInmediato: GestureRecognizerFactoryWithHandlers<_ArrastreInmediato>(
                  _ArrastreInmediato.new,
                  (r) => r
                    ..dragStartBehavior = DragStartBehavior.down
                    ..onStart = _alEmpezar
                    ..onUpdate = _alMover
                    ..onEnd = _alSoltar,
                )
              else if (widget.alInspeccionar != null)
                TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                  TapGestureRecognizer.new,
                  (r) => r.onTap = () {
                    if (!_volando) widget.alInspeccionar?.call();
                  },
                ),
            },
            // Parada de Tab de la tarjeta (orden 26b; T-13): sin atajos propios,
            // así las flechas, Enter y Esc siguen llegando a la pantalla.
            child: _FocoTarjeta(child: widget.tarjeta),
          ),
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: PilaTarjetas(restantes: widget.restantes)),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: altoTarjeta,
              child: Transform.translate(
                key: const ValueKey('transformacion-tarjeta'),
                offset: _desplazamiento + Offset(0, bajadaEntrada),
                child: Transform.rotate(
                  angle: _angulo * math.pi / 180,
                  child: Transform.scale(
                    scale: escalaEntrada,
                    child: Opacity(opacity: 0.8 + 0.2 * e, child: tarjeta),
                  ),
                ),
              ),
            ),
            ..._sellos(ancho, altoTarjeta, opacidad),
            ?_dibujarSaliente(ancho, altoTarjeta),
          ],
        );
      },
    );
  }

  /// La tarjeta retenida que sale volando hacia su veredicto (sin sello, sin
  /// toques ni semántica) mientras entra la siguiente.
  Widget? _dibujarSaliente(double ancho, double alto) {
    final saliente = _saliente;
    if (saliente == null) return null;
    final t = Curves.easeIn.transform(_salida.value);
    final destino = LogicaSwipe.destinoVuelo(saliente.veredicto, ancho, alto + MazoSwipe.altoPila);
    final anguloFinal = LogicaSwipe.ejeDe(saliente.veredicto) == EjeSwipe.horizontal
        ? LogicaSwipe.anguloVuelo * LogicaSwipe.direccion(saliente.veredicto).dx
        : 0.0;
    return Positioned(
      key: const ValueKey('tarjeta-saliente'),
      left: 0,
      right: 0,
      top: 0,
      height: alto,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: Transform.translate(
            offset: Offset.lerp(saliente.desde, destino, t)!,
            child: Transform.rotate(
              angle: (saliente.angulo + (anguloFinal - saliente.angulo) * t) * math.pi / 180,
              child: saliente.tarjeta,
            ),
          ),
        ),
      ),
    );
  }

  /// Sellos en las posiciones de Figma, relativas a la tarjeta (342×440):
  /// Legal centrado en (83.7, 81.3) e Ilegal en (ancho − 74.2, 58.5);
  /// Condicional de (centro + 30, 26) a (centro, −40) y Escalar de
  /// (centro − 10, alto − 64) a (centro − 24, alto − 44).
  List<Widget> _sellos(double ancho, double alto, double Function(Veredicto) opacidad) {
    final centro = ancho / 2;
    final pCond = opacidad(Veredicto.condicional);
    final pEsc = opacidad(Veredicto.escalar);
    Widget centrado(Offset punto, Veredicto v, {double y = -0.5}) => Positioned(
      left: punto.dx,
      top: punto.dy,
      child: FractionalTranslation(
        translation: Offset(-0.5, y),
        child: SelloVeredicto(veredicto: v, opacidad: opacidad(v)),
      ),
    );
    return [
      centrado(const Offset(83.7, 81.3), Veredicto.legal),
      centrado(Offset(ancho - 74.2, 58.5), Veredicto.ilegal),
      centrado(Offset(centro + 30 * (1 - pCond), 26 - 66 * pCond), Veredicto.condicional, y: 0),
      centrado(Offset(centro - 10 - 14 * pEsc, alto - 64 + 20 * pEsc), Veredicto.escalar, y: 0),
    ];
  }

  static String _accion(Veredicto v) => switch (v) {
    Veredicto.legal => Textos.accionLegal,
    Veredicto.ilegal => Textos.accionIlegal,
    Veredicto.condicional => Textos.accionCondicional,
    Veredicto.escalar => Textos.accionEscalar,
  };
}

/// La tarjeta retenida que sale cuando llega la siguiente.
@immutable
class _TarjetaSaliente {
  const _TarjetaSaliente({
    required this.tarjeta,
    required this.veredicto,
    required this.desde,
    required this.angulo,
  });

  final Widget tarjeta;
  final Veredicto veredicto;
  final Offset desde;
  final double angulo;
}

/// Foco de teclado de la tarjeta: una parada de Tab con anillo (solo al
/// navegar con teclado), sin nodo semántico propio ni atajos.
class _FocoTarjeta extends StatefulWidget {
  const _FocoTarjeta({required this.child});

  final Widget child;

  @override
  State<_FocoTarjeta> createState() => _FocoTarjetaState();
}

class _FocoTarjetaState extends State<_FocoTarjeta> {
  final _nodo = FocusNode(debugLabel: 'tarjeta del juego');
  bool _enfocada = false;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_alCambiarModo);
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_alCambiarModo);
    _nodo.dispose();
    super.dispose();
  }

  void _alCambiarModo(FocusHighlightMode _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final teclado = FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    return Focus(
      focusNode: _nodo,
      includeSemantics: false,
      onFocusChange: (valor) => setState(() => _enfocada = valor),
      child: AnilloFoco(
        key: const ValueKey('foco-tarjeta'),
        visible: _enfocada && teclado,
        radio: 28,
        child: widget.child,
      ),
    );
  }
}

/// Teclado del mazo, igual en el juego, el Examen y el juicio. Flechas: ←
/// ilegal, → legal, ↑ condicional y ↓ escalar previsualizan. Con una
/// previsualización, Enter (o el del teclado numérico) la confirma y Esc la
/// cancela. Sin ella, Enter y Esc siguen su camino (por ejemplo, Enter activa
/// el botón de veredicto con foco). Solo cuenta pulsar o mantener una tecla.
///
/// Cada pantalla pone antes sus guardias y atajos propios (mazo sin montar,
/// juicio resolviéndose, fase del Examen, tecla P).
KeyEventResult teclearMazo(MazoSwipeState mazo, KeyEvent evento) {
  if (evento is! KeyDownEvent && evento is! KeyRepeatEvent) return KeyEventResult.ignored;
  final flecha = switch (evento.logicalKey) {
    LogicalKeyboardKey.arrowLeft => Veredicto.ilegal,
    LogicalKeyboardKey.arrowRight => Veredicto.legal,
    LogicalKeyboardKey.arrowUp => Veredicto.condicional,
    LogicalKeyboardKey.arrowDown => Veredicto.escalar,
    _ => null,
  };
  if (flecha != null) {
    mazo.previsualizar(flecha);
    return KeyEventResult.handled;
  }
  final previa = mazo.previa;
  if (previa == null) return KeyEventResult.ignored;
  if (evento.logicalKey == LogicalKeyboardKey.enter ||
      evento.logicalKey == LogicalKeyboardKey.numpadEnter) {
    mazo.confirmar(previa);
    return KeyEventResult.handled;
  }
  if (evento.logicalKey == LogicalKeyboardKey.escape) {
    mazo.cancelarPrevia();
    return KeyEventResult.handled;
  }
  return KeyEventResult.ignored;
}

/// Tinte de pantalla completa del arrastre (va en el `Stack` de la pantalla,
/// detrás de la tarjeta y delante del fondo): el color del veredicto al que
/// apunta la tarjeta, con opacidad de 0 a [LogicaSwipe.opacidadTinte] según
/// el progreso hacia el umbral.
class TinteArrastre extends StatelessWidget {
  const TinteArrastre({required this.arrastre, super.key});

  final ValueListenable<ArrastreVisible> arrastre;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ValueListenableBuilder<ArrastreVisible>(
      valueListenable: arrastre,
      builder: (context, visible, _) => TinteVeredicto(
        veredicto: visible.veredicto,
        opacidad: visible.progreso * LogicaSwipe.opacidadTinte,
      ),
    ),
  );
}
