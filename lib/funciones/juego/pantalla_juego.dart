import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/rutas.dart';
import '../../componentes/acciones_veredicto.dart';
import '../../componentes/barra_comodines.dart';
import '../../componentes/barra_juego.dart';
import '../../componentes/bloque_lectura.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/etiqueta_lupa.dart';
import '../../componentes/indicadores_startup.dart';
import '../../componentes/mensaje_pantalla.dart';
import '../../componentes/panel_abogado.dart';
import '../../componentes/panel_evidencia.dart';
import '../../componentes/panel_justificacion.dart';
import '../../componentes/panel_veredicto.dart';
import '../../componentes/tarjeta_caso.dart';
import '../../componentes/tinte_veredicto.dart';
import '../../core/tema/efectos.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/articulo_tienda.dart';
import '../../datos/modelos/tarjeta.dart';
import '../inicio/logica_inicio.dart';
import 'estado_juego.dart';
import 'logica_comodines.dart';
import 'logica_swipe.dart';
import 'logica_veredicto.dart';
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
  final _focoEvidencia = FocusNode(debugLabel: 'botón de evidencia');

  final _focoAbogado = FocusNode(debugLabel: 'comodín Abogado');

  /// Hay un panel abierto (visor, justificación, Abogado o veredicto): la
  /// barra de comodines se deshabilita.
  final _panelAbierto = ValueNotifier(false);

  @override
  void dispose() {
    _arrastre.dispose();
    _focoEvidencia.dispose();
    _focoAbogado.dispose();
    _panelAbierto.dispose();
    super.dispose();
  }

  /// Anuncia [mensaje] al lector de pantalla.
  void _anunciar(String mensaje) {
    unawaited(SemanticsService.sendAnnouncement(View.of(context), mensaje, TextDirection.ltr));
  }

  /// 10b · Lupa: gasta 1 y resalta las palabras trampa de [tarjeta].
  void _usarLupa(Tarjeta tarjeta) {
    if (_panelAbierto.value || !_juego.usarLupa(tarjeta)) return;
    final quedan = ref.read(juegoProvider(widget.sprintId)).cantidad(Comodin.lupaAuditor);
    _anunciar('${Textos.lupaActiva}. ${Textos.comodinQuedan(Textos.comodinLupa, quedan)}');
  }

  /// 10c · Abogado: la primera vez en la tarjeta gasta 1; reabrirlo es gratis.
  /// Se cierra con "Volver a la tarjeta", atrás o Esc, y el foco vuelve a la
  /// píldora.
  Future<void> _usarAbogado(Tarjeta tarjeta) async {
    if (_panelAbierto.value) return;
    final antes = ref.read(juegoProvider(widget.sprintId)).cantidad(Comodin.abogadoSenior);
    if (!_juego.consultarAbogado(tarjeta)) return;
    final quedan = ref.read(juegoProvider(widget.sprintId)).cantidad(Comodin.abogadoSenior);
    if (quedan < antes) _anunciar(Textos.comodinQuedan(Textos.comodinAbogado, quedan));
    final alto = MediaQuery.sizeOf(context).height;
    await _mostrarPanel<void>(
      descartable: true,
      constructor: (contexto) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: alto * 0.92),
        child: PanelAbogado(
          traduccion: tarjeta.traduccionLegal ?? '',
          normas: tarjeta.normas,
          alVolver: () => Navigator.of(contexto).pop(),
        ),
      ),
    );
    // La píldora se vuelve a habilitar al reconstruirse la barra: el foco se
    // pide después de ese cuadro.
    await WidgetsBinding.instance.endOfFrame;
    if (mounted && _focoAbogado.context != null) _focoAbogado.requestFocus();
  }

  /// Amparo: arma o desarma (gratis); se gasta al absorber un error.
  void _usarAmparo() {
    if (_panelAbierto.value) return;
    _anunciar(_juego.alternarAmparo() ? Textos.amparoArmado : Textos.amparoDesarmado);
  }

  JuegoNotifier get _juego => ref.read(juegoProvider(widget.sprintId).notifier);

  /// Muestra un panel modal con el velo al 40 % y la subida de 280 ms (sin
  /// animación con "reducir animaciones"). Sin [descartable] no se cierra con
  /// atrás, Esc ni tocando fuera.
  Future<T?> _mostrarPanel<T>({
    required bool descartable,
    required Widget Function(BuildContext contexto) constructor,
  }) async {
    final sinAnimaciones = MediaQuery.disableAnimationsOf(context);
    _panelAbierto.value = true;
    try {
      return await showModalBottomSheet<T>(
        context: context,
        isDismissible: descartable,
        enableDrag: false,
        isScrollControlled: true,
        backgroundColor: const Color(0x00000000),
        elevation: 0,
        barrierColor: EfectosApp.colorVelo,
        sheetAnimationStyle: sinAnimaciones
            ? AnimationStyle.noAnimation
            : const AnimationStyle(
                duration: EfectosApp.duracionPanel,
                reverseDuration: EfectosApp.duracionPanel,
                curve: Curves.easeOut,
              ),
        builder: (contexto) => descartable
            ? constructor(contexto)
            : PopScope(canPop: false, child: constructor(contexto)),
      );
    } finally {
      _panelAbierto.value = false;
    }
  }

  /// Visor de evidencia (16 y 16b): se cierra con "Volver y decidir", atrás,
  /// Esc o tocando fuera (cerrar sin marcar equivale a no marcar nada). Al
  /// cerrarse, el foco vuelve al botón de evidencia.
  Future<void> _abrirEvidencia(Tarjeta tarjeta) async {
    final evidencia = tarjeta.evidencia;
    if (evidencia == null || _panelAbierto.value) return;
    final alto = MediaQuery.sizeOf(context).height;
    await _mostrarPanel<void>(
      descartable: true,
      constructor: (contexto) => Consumer(
        builder: (contexto, ref, _) {
          final marcadas = ref.watch(
            juegoProvider(widget.sprintId).select((e) => e.lineasMarcadas[tarjeta.id]),
          );
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: alto * 0.92),
            child: PanelEvidencia(
              archivo: evidencia.archivo,
              lineas: evidencia.lineas,
              lineasClave: evidencia.lineasClave,
              mensajeAcierto: evidencia.mensajeAcierto,
              mensajeFallo: evidencia.mensajeFallo,
              marcadas: marcadas,
              alMarcar: (lineas) => _juego.marcarEvidencia(tarjeta, lineas),
              alVolver: () => Navigator.of(contexto).pop(),
            ),
          );
        },
      ),
    );
    if (mounted && _focoEvidencia.context != null) _focoEvidencia.requestFocus();
  }

  /// Tras el vuelo de la tarjeta: en un dilema pide primero la justificación
  /// (18); luego califica, abre el panel de veredicto (modal sin descarte) y,
  /// al cerrarlo, resuelve qué sigue.
  Future<void> _alConfirmar(Tarjeta tarjeta, Veredicto veredicto) async {
    int? justificacion;
    final opciones = tarjeta.justificacion;
    if (tarjeta.tipo == TipoTarjeta.justificacion && opciones != null) {
      final alto = MediaQuery.sizeOf(context).height;
      justificacion = await _mostrarPanel<int>(
        descartable: false,
        constructor: (contexto) => ConstrainedBox(
          constraints: BoxConstraints(maxHeight: alto * 0.92),
          child: PanelJustificacion(
            veredicto: veredicto,
            justificacion: opciones,
            alConfirmar: (opcion) => Navigator.of(contexto).pop(opcion),
          ),
        ),
      );
      if (!mounted) return;
    }
    final resultado = _juego.responder(tarjeta, veredicto, justificacion: justificacion);
    _vibrar(resultado.tipo);
    await _mostrarPanel<void>(
      descartable: false,
      constructor: (contexto) =>
          _PanelDelJuego(sprintId: widget.sprintId, alCerrar: () => Navigator.of(contexto).pop()),
    );
    if (!mounted) return;
    final juego = _juego;
    final destino = juego.cerrarPanel(totalTarjetas: widget.datos.tarjetas.length);
    // Al terminar, guarda el resultado antes de salir (el mapa y el Inicio
    // lo leen de los repositorios).
    if (destino != DestinoVeredicto.siguiente) await juego.guardarResultado();
    if (!mounted) return;
    switch (destino) {
      case DestinoVeredicto.quiebra:
        context.go(Rutas.startupQuiebraDe(widget.sprintId));
      case DestinoVeredicto.sinVidas:
        context.go(Rutas.sinVidas);
      case DestinoVeredicto.sprintCompletado:
        context.go(Rutas.sprintCompletadoDe(widget.sprintId));
      case DestinoVeredicto.siguiente:
        break;
    }
  }

  /// Vibración según el resultado (no hay en web): correcto ligera, parcial
  /// de selección, error y Amparo media.
  static void _vibrar(TipoVeredicto tipo) {
    if (kIsWeb) return;
    switch (tipo) {
      case TipoVeredicto.correcto:
        HapticFeedback.lightImpact();
      case TipoVeredicto.parcial:
        HapticFeedback.selectionClick();
      case TipoVeredicto.incorrecto || TipoVeredicto.amparo:
        HapticFeedback.mediumImpact();
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
    final lupaUsada = progreso.lupaUsada.contains(tarjeta.id);
    final inspeccionar = tarjeta.tipo == TipoTarjeta.evidencia && tarjeta.evidencia != null
        ? () => _abrirEvidencia(tarjeta)
        : null;

    final contenido = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BarraJuego(
          numeroSprint: datos.numeroSprint,
          actual: indice + 1,
          total: total,
          vidas: progreso.vidas,
          alSalir: _salir,
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: BloqueLectura(
            etiqueta: Textos.indicadoresSemantica,
            child: IndicadoresStartup(
              estado: progreso.estadoStartup,
              cambios: progreso.panel == null
                  ? const {}
                  : cambiosDe(progreso.panel!.resultado.impacto),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    TarjetaCaso.altoMinimoPara(
                      MediaQuery.textScalerOf(context),
                      tipo: tarjeta.tipo,
                    ) +
                    MazoSwipe.altoPila,
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
                      etiquetaSemantica: Textos.tarjetaConTipoSemantica(
                        Textos.tarjetaSemantica(
                          indice + 1,
                          total,
                          tarjeta.personaje,
                          tarjeta.rol,
                          lupaUsada
                              ? '${tarjeta.texto} '
                                    '(${Textos.palabrasTrampaSemantica(tarjeta.palabrasTrampa)})'
                              : tarjeta.texto,
                        ),
                        switch (tarjeta.tipo) {
                          TipoTarjeta.normal => null,
                          TipoTarjeta.evidencia =>
                            progreso.evidenciaMarcada.containsKey(tarjeta.id)
                                ? Textos.evidenciaInspeccionadaSemantica
                                : Textos.conEvidenciaSemantica,
                          TipoTarjeta.justificacion => Textos.dilemaSemantica,
                        },
                      ),
                      alConfirmar: (v) => _alConfirmar(tarjeta, v),
                      alInspeccionar: inspeccionar,
                      tarjeta: TarjetaCaso(
                        etiquetaCaso: tarjeta.etiquetaCaso,
                        colorModulo: colorModulo,
                        iniciales: tarjeta.iniciales ?? LogicaInicio.iniciales(tarjeta.personaje),
                        personaje: tarjeta.personaje,
                        rol: tarjeta.rol,
                        texto: tarjeta.texto,
                        tipo: tarjeta.tipo,
                        alInspeccionar: inspeccionar,
                        nodoFocoEvidencia: _focoEvidencia,
                        palabrasTrampa: lupaUsada ? tarjeta.palabrasTrampa : const [],
                      ),
                    ),
                  ),
                  // Etiqueta de la Lupa (10b): sobre el borde de la tarjeta,
                  // solo mientras dura la tarjeta en la que se usó.
                  if (lupaUsada)
                    Positioned(
                      left: EtiquetaLupa.posicion.dx,
                      top: EtiquetaLupa.posicion.dy,
                      right: 0,
                      child: const Align(alignment: Alignment.topLeft, child: EtiquetaLupa()),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Semantics(
            container: true,
            label: Textos.comodinesTitulo,
            child: ValueListenableBuilder<bool>(
              valueListenable: _panelAbierto,
              builder: (context, panelAbierto, _) {
                final abierto = panelAbierto || progreso.panel != null;
                final lupa = LogicaComodines.estadoLupa(progreso, tarjeta, panelAbierto: abierto);
                final abogado = LogicaComodines.estadoAbogado(
                  progreso,
                  tarjeta,
                  panelAbierto: abierto,
                );
                final amparo = LogicaComodines.estadoAmparo(progreso, panelAbierto: abierto);
                bool tocable(Comodin c, EstadoComodin e) =>
                    LogicaComodines.tocable(c, e, panelAbierto: abierto);
                return BarraComodines(
                  lupa: progreso.cantidad(Comodin.lupaAuditor),
                  abogado: progreso.cantidad(Comodin.abogadoSenior),
                  amparo: progreso.cantidad(Comodin.amparo),
                  estadoLupa: lupa,
                  estadoAbogado: abogado,
                  estadoAmparo: amparo,
                  alUsarLupa: tocable(Comodin.lupaAuditor, lupa) ? () => _usarLupa(tarjeta) : null,
                  alUsarAbogado: tocable(Comodin.abogadoSenior, abogado)
                      ? () => _usarAbogado(tarjeta)
                      : null,
                  alUsarAmparo: tocable(Comodin.amparo, amparo) ? _usarAmparo : null,
                  nodoFocoAbogado: _focoAbogado,
                );
              },
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

/// Cambios de un impacto por indicador (para el panel y las barras).
Map<IndicadorStartup, int> cambiosDe(ImpactoTarjeta i) => {
  IndicadorStartup.presupuesto: i.presupuesto,
  IndicadorStartup.reputacion: i.reputacion,
  IndicadorStartup.velocidad: i.velocidad,
  IndicadorStartup.riesgoLegal: i.riesgoLegal,
};

/// Panel del veredicto en curso: sigue al estado del juego (micro-pregunta,
/// bonus o explicación).
class _PanelDelJuego extends ConsumerWidget {
  const _PanelDelJuego({required this.sprintId, required this.alCerrar});

  final String sprintId;
  final VoidCallback alCerrar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panel = ref.watch(juegoProvider(sprintId).select((e) => e.panel));
    if (panel == null) return const SizedBox.shrink();
    final juego = ref.read(juegoProvider(sprintId).notifier);
    final r = panel.resultado;
    final (tipo, subtitulo) = switch (r.tipo) {
      TipoVeredicto.correcto when panel.fase == FasePanel.bonus => (
        TipoPanelVeredicto.bonus,
        Textos.bonusSubtitulo(r.xp, r.monedas),
      ),
      TipoVeredicto.correcto => (
        TipoPanelVeredicto.correcto,
        Textos.correctoSubtitulo(r.xp, r.monedas),
      ),
      TipoVeredicto.parcial => (TipoPanelVeredicto.parcial, Textos.parcialSubtitulo(r.xp)),
      TipoVeredicto.incorrecto => (TipoPanelVeredicto.incorrecto, Textos.incorrectoSubtitulo),
      TipoVeredicto.amparo => (TipoPanelVeredicto.amparo, Textos.amparoSubtitulo),
    };
    final conPregunta = panel.fase == FasePanel.microPregunta;
    final alto = MediaQuery.sizeOf(context).height;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: alto * 0.92),
      child: PanelVeredicto(
        tipo: tipo,
        subtitulo: subtitulo,
        cambios: cambiosDe(r.impacto),
        explicacion: LogicaVeredicto.explicacion(panel.tarjeta, r.tipo),
        microPregunta: conPregunta ? panel.tarjeta.microPregunta : null,
        alElegirOpcion: juego.elegirOpcion,
        alContinuar: conPregunta ? juego.saltarBonus : alCerrar,
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
