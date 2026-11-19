import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/rutas.dart';
import '../../componentes/acciones_veredicto.dart';
import '../../componentes/anillo_foco.dart';
import '../../componentes/barra_comodines.dart';
import '../../componentes/barra_juego.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/indicadores_startup.dart';
import '../../componentes/mensaje_pantalla.dart';
import '../../componentes/tarjeta_caso.dart';
import '../../componentes/tinte_veredicto.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/tarjeta.dart';
import '../inicio/logica_inicio.dart';
import 'estado_juego.dart';
import 'logica_swipe.dart';
import 'mazo_swipe.dart';

/// Pantalla 10 · Juego: tarjeta de caso que se arrastra en 4 direcciones.
///
/// 11 (←), 11b (↑), 11c (↓) y 13 (→) no son pantallas aparte: son esta misma
/// mientras se arrastra la tarjeta (sello, tinte e inclinación).
class PantallaJuego extends ConsumerWidget {
  const PantallaJuego({required this.sprintId, super.key});

  final String sprintId;

  /// Sale del juego: regresa a la intro o al mapa si hay pila; si no, al mapa
  /// del módulo (o al Inicio si no se conoce el módulo).
  static void volver(BuildContext context, String? moduloId) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(moduloId == null ? Rutas.inicio : Rutas.mapaSprintsDe(moduloId));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(datosJuegoProvider(sprintId));
    return Scaffold(
      body: switch (datos) {
        AsyncData(:final value) when value.sinVidas => MensajePantalla(
          texto: Textos.sinVidasPendiente,
          textoBoton: Textos.volverAlMapa,
          alPresionar: () => volver(context, value.modulo?.id),
        ),
        AsyncData(:final value) when value.tarjetas.isEmpty => MensajePantalla(
          texto: Textos.sprintSinTarjetas,
          textoBoton: value.modulo == null ? Textos.volverAlInicio : Textos.volverAlMapa,
          alPresionar: () => volver(context, value.modulo?.id),
        ),
        AsyncData(:final value) => _Juego(sprintId: sprintId, datos: value),
        AsyncError() => MensajePantalla(
          texto: Textos.juegoErrorCarga,
          textoBoton: Textos.reintentar,
          alPresionar: () => ref.invalidate(datosJuegoProvider(sprintId)),
        ),
        _ => const _EsqueletoJuego(),
      },
    );
  }
}

class _Juego extends ConsumerStatefulWidget {
  const _Juego({required this.sprintId, required this.datos});

  final String sprintId;
  final DatosJuego datos;

  @override
  ConsumerState<_Juego> createState() => _JuegoState();
}

class _JuegoState extends ConsumerState<_Juego> {
  final _mazo = GlobalKey<MazoSwipeState>();
  final _arrastre = ValueNotifier(const ArrastreVisible());

  @override
  void dispose() {
    _arrastre.dispose();
    super.dispose();
  }

  void _alConfirmar(Tarjeta tarjeta, Veredicto veredicto) {
    ref.read(juegoProvider(widget.sprintId).notifier).responder(tarjeta, veredicto);
    if (ref.read(juegoProvider(widget.sprintId)).indice >= widget.datos.tarjetas.length) {
      context.go(Rutas.sprintCompletadoDe(widget.sprintId));
    }
  }

  Future<void> _salir() async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (context) => const _DialogoSalir(),
    );
    if (salir == true && mounted) {
      PantallaJuego.volver(context, widget.datos.modulo?.id);
    }
  }

  /// Flechas: previsualizan. Enter: confirma la previsualización. Esc: la
  /// cancela. Sin previsualización, Enter y Esc siguen su camino (por
  /// ejemplo, Enter activa el botón de veredicto con foco).
  KeyEventResult _alTeclear(FocusNode _, KeyEvent evento) {
    if (evento is! KeyDownEvent && evento is! KeyRepeatEvent) return KeyEventResult.ignored;
    final mazo = _mazo.currentState;
    if (mazo == null) return KeyEventResult.ignored;
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

  @override
  Widget build(BuildContext context) {
    final datos = widget.datos;
    final progreso = ref.watch(juegoProvider(widget.sprintId));
    final total = datos.tarjetas.length;
    final indice = progreso.indice.clamp(0, total - 1);
    final tarjeta = datos.tarjetas[indice];
    final colorModulo = datos.modulo?.color ?? context.tokens.textoAcento;

    final contenido = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BarraJuego(
          numeroSprint: datos.numeroSprint,
          actual: indice + 1,
          total: total,
          vidas: datos.vidas.cantidad,
          alSalir: _salir,
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _BloqueEnfocable(
            etiqueta: Textos.indicadoresSemantica,
            child: IndicadoresStartup(estado: datos.estadoStartup!),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: TarjetaCaso.altoMinimo + MazoSwipe.altoPila,
              ),
              // Solo hijos posicionados: la zona no aporta alto intrínseco y
              // se estira o encoge con la pantalla.
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: MazoSwipe(
                      key: _mazo,
                      claveTarjeta: tarjeta.id,
                      restantes: total - indice - 1,
                      arrastre: _arrastre,
                      etiquetaSemantica: Textos.tarjetaSemantica(
                        indice + 1,
                        total,
                        tarjeta.personaje,
                        tarjeta.rol,
                        tarjeta.texto,
                      ),
                      alConfirmar: (v) => _alConfirmar(tarjeta, v),
                      tarjeta: TarjetaCaso(
                        etiquetaCaso: tarjeta.etiquetaCaso,
                        colorModulo: colorModulo,
                        iniciales: LogicaInicio.iniciales(tarjeta.personaje),
                        personaje: tarjeta.personaje,
                        rol: tarjeta.rol,
                        texto: tarjeta.texto,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AccionesVeredicto(alElegir: (v) => _mazo.currentState?.confirmar(v)),
        ),
        const SizedBox(height: 22),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _BloqueEnfocable(
            etiqueta: Textos.comodinesTitulo,
            child: BarraComodines(
              lupa: ComodinesJuego.lupa,
              abogado: ComodinesJuego.abogado,
              amparo: ComodinesJuego.amparo,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );

    return Focus(
      autofocus: true,
      skipTraversal: true,
      onKeyEvent: _alTeclear,
      child: Stack(
        children: [
          // Tinte de pantalla completa: detrás de la tarjeta y delante del fondo.
          Positioned.fill(
            child: ValueListenableBuilder<ArrastreVisible>(
              valueListenable: _arrastre,
              builder: (context, arrastre, _) => TinteVeredicto(
                veredicto: arrastre.veredicto,
                opacidad: arrastre.progreso * LogicaSwipe.opacidadTinte,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, restricciones) => SingleChildScrollView(
                key: const ValueKey('juego-desplazable'),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: restricciones.maxHeight),
                  child: IntrinsicHeight(child: contenido),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bloque que se lee completo y recibe foco con teclado (indicadores y
/// comodines, como en el orden de foco de Figma 26b). No hace nada al
/// activarlo.
class _BloqueEnfocable extends StatefulWidget {
  const _BloqueEnfocable({required this.etiqueta, required this.child});

  final String etiqueta;
  final Widget child;

  @override
  State<_BloqueEnfocable> createState() => _BloqueEnfocableState();
}

class _BloqueEnfocableState extends State<_BloqueEnfocable> {
  bool _foco = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: widget.etiqueta,
      child: MergeSemantics(
        child: FocusableActionDetector(
          onShowFocusHighlight: (valor) => setState(() => _foco = valor),
          child: AnilloFoco(visible: _foco, radio: 16, child: widget.child),
        ),
      ),
    );
  }
}

class _DialogoSalir extends StatelessWidget {
  const _DialogoSalir();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return AlertDialog(
      backgroundColor: tokens.fondoSuperficie,
      title: Text(Textos.salirTitulo, style: estilos.h2.copyWith(color: tokens.textoPrimario)),
      content: Text(
        Textos.salirTexto,
        style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowDirection: VerticalDirection.up,
      actions: [
        BotonApp(
          texto: Textos.salir,
          tipo: TipoBoton.secundario,
          expandido: false,
          alPresionar: () => Navigator.of(context).pop(true),
        ),
        BotonApp(
          texto: Textos.seguirJugando,
          expandido: false,
          alPresionar: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}

/// Esqueleto con las medidas de la barra, los indicadores, la tarjeta y las
/// acciones.
class _EsqueletoJuego extends StatelessWidget {
  const _EsqueletoJuego();

  @override
  Widget build(BuildContext context) {
    final color = context.tokens.fondoSuperficieAlt;
    Widget bloque(double alto, {double? ancho, double radio = 16}) => Container(
      width: ancho,
      height: alto,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radio)),
    );
    return Semantics(
      label: Textos.cargandoJuego,
      liveRegion: true,
      excludeSemantics: true,
      child: SafeArea(
        child: SingleChildScrollView(
          key: const ValueKey('esqueleto-juego'),
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 4),
              bloque(48, radio: 12),
              const SizedBox(height: 6),
              bloque(46),
              const SizedBox(height: 12),
              bloque(TarjetaCaso.alto, radio: TarjetaCaso.radio),
              const SizedBox(height: 18),
              bloque(90),
            ],
          ),
        ),
      ),
    );
  }
}
