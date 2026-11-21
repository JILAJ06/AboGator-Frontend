import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/rutas.dart';
import '../../componentes/acciones_veredicto.dart';
import '../../componentes/aviso_conexion.dart';
import '../../componentes/barra_comodines.dart';
import '../../componentes/barra_juego.dart';
import '../../componentes/bloque_lectura.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/etiqueta_lupa.dart';
import '../../componentes/hoja_lateral.dart';
import '../../componentes/indicador_pendientes.dart';
import '../../componentes/indicadores_startup.dart';
import '../../componentes/interruptor_conexion_debug.dart';
import '../../componentes/mensaje_pantalla.dart';
import '../../componentes/panel_abogado.dart';
import '../../componentes/panel_evidencia.dart';
import '../../componentes/panel_justificacion.dart';
import '../../componentes/panel_lateral_juego.dart';
import '../../componentes/panel_veredicto.dart';
import '../../componentes/tarjeta_caso.dart';
import '../../componentes/tinte_veredicto.dart';
import '../../core/adaptativo/clase_pantalla.dart';
import '../../core/tema/efectos.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/articulo_tienda.dart';
import '../../datos/modelos/tarjeta.dart';
import '../../datos/repositorios/proveedores_repositorios.dart';
import '../../datos/sincronizacion/estado_sincronizacion.dart';
import '../../datos/sincronizacion/servicio_conexion.dart';
import '../acceso/sesion.dart';
import '../ajustes/estado_ajustes.dart';
import '../inicio/logica_inicio.dart';
import '../vidas/pantalla_sin_vidas.dart';
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
        // Sin vidas al abrir el sprint: directo a "Sin vidas" (20).
        AsyncData(:final value) when value.sinVidas => PantallaSinVidas(moduloId: value.modulo?.id),
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

  /// Muestra "Conexión restablecida" unos segundos tras volver la conexión.
  bool _restablecida = false;
  Timer? _temporizadorRestablecida;

  /// Cuánto se ve "Conexión restablecida…".
  static const Duration duracionRestablecida = Duration(seconds: 3);

  void _alCambiarConexion(EstadoConexion? antes, EstadoConexion ahora) {
    _temporizadorRestablecida?.cancel();
    final volvio = antes == EstadoConexion.sinConexion && ahora == EstadoConexion.enLinea;
    setState(() => _restablecida = volvio);
    if (volvio) {
      _temporizadorRestablecida = Timer(duracionRestablecida, () {
        if (mounted) setState(() => _restablecida = false);
      });
    }
  }

  @override
  void dispose() {
    _temporizadorRestablecida?.cancel();
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
      etiqueta: Textos.hojaAbogado,
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
    required String etiqueta,
    required Widget Function(BuildContext contexto) constructor,
  }) async {
    final sinAnimaciones = MediaQuery.disableAnimationsOf(context);
    final clase = context.clasePantalla;
    _panelAbierto.value = true;
    try {
      // Tablet horizontal (T-12c): hoja lateral de 376 que entra desde la
      // derecha, con el mismo velo y la misma duración.
      if (clase.esAncho) {
        return await showGeneralDialog<T>(
          context: context,
          barrierDismissible: descartable,
          barrierLabel: Textos.cerrar,
          barrierColor: EfectosApp.colorVelo,
          transitionDuration: sinAnimaciones ? Duration.zero : EfectosApp.duracionPanel,
          pageBuilder: (contexto, _, _) => HojaLateral(
            etiqueta: etiqueta,
            child: descartable
                ? constructor(contexto)
                : PopScope(canPop: false, child: constructor(contexto)),
          ),
          transitionBuilder: (contexto, animacion, _, hijo) => SlideTransition(
            position: Tween(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animacion, curve: Curves.easeOut)),
            child: hijo,
          ),
        );
      }
      return await showModalBottomSheet<T>(
        context: context,
        isDismissible: descartable,
        enableDrag: false,
        isScrollControlled: true,
        backgroundColor: const Color(0x00000000),
        elevation: 0,
        barrierColor: EfectosApp.colorVelo,
        // Entre 600 y 959 la hoja inferior no pasa de 440 y va centrada.
        constraints: clase.esTablet
            ? const BoxConstraints(maxWidth: anchoHojaTabletVertical)
            : null,
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
      etiqueta: Textos.hojaEvidencia,
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
        etiqueta: Textos.hojaJustificacion,
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
      etiqueta: Textos.hojaRetroalimentacion,
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
        context.go(Rutas.sinVidasDe(widget.datos.modulo?.id));
      case DestinoVeredicto.sprintCompletado:
        context.go(Rutas.sprintCompletadoDe(widget.sprintId));
      case DestinoVeredicto.siguiente:
        break;
    }
  }

  /// Vibración según el resultado (servicio háptico: respeta el ajuste y no
  /// vibra en web): correcto corta, parcial de selección, error y Amparo doble.
  void _vibrar(TipoVeredicto tipo) {
    final haptica = ref.read(servicioHapticoProvider);
    unawaited(switch (tipo) {
      TipoVeredicto.correcto => haptica.acierto(),
      TipoVeredicto.parcial => haptica.parcial(),
      TipoVeredicto.incorrecto || TipoVeredicto.amparo => haptica.error(),
    });
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

  /// Pausa (tablet): el sprint no tiene reloj, así que no detiene nada; deja
  /// seguir o salir (con la misma confirmación de Salir).
  Future<void> _pausar() async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (context) => const _DialogoPausa(),
    );
    if (salir == true && mounted) await _salir();
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
    final soloBotones = ref.watch(ajustesProvider.select((a) => a.soloBotones));
    final lupaUsada = progreso.lupaUsada.contains(tarjeta.id);
    // 23 · Sin conexión: aviso sobre la tarjeta y, en lugar de los comodines
    // (su gasto lo controla el servidor), las respuestas guardadas.
    ref.listen(conexionProvider, _alCambiarConexion);
    final sinConexion = ref.watch(conexionProvider) == EstadoConexion.sinConexion;
    final pendientes = ref.watch(respuestasPendientesProvider);
    final verAviso = sinConexion || _restablecida;
    final sinAnimaciones = MediaQuery.disableAnimationsOf(context);
    final inspeccionar = tarjeta.tipo == TipoTarjeta.evidencia && tarjeta.evidencia != null
        ? () => _abrirEvidencia(tarjeta)
        : null;

    final clase = context.clasePantalla;
    final cambios = progreso.panel == null
        ? const <IndicadorStartup, int>{}
        : cambiosDe(progreso.panel!.resultado.impacto);

    final zonaTarjeta = Stack(
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
            arrastreActivo: !soloBotones,
            tarjeta: TarjetaCaso(
              soloBotones: soloBotones,
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
        // Etiqueta de la Lupa (10b): sobre el borde de la tarjeta, solo
        // mientras dura la tarjeta en la que se usó.
        if (lupaUsada)
          Positioned(
            left: EtiquetaLupa.posicion.dx,
            top: EtiquetaLupa.posicion.dy,
            right: 0,
            child: const Align(alignment: Alignment.topLeft, child: EtiquetaLupa()),
          ),
        // Aviso de conexión (23): encima del borde superior de la tarjeta, sin
        // empujarla ni bloquear el arrastre.
        Positioned(
          left: 0,
          right: 0,
          top: posicionAvisoConexion,
          child: AnimatedSwitcher(
            duration: sinAnimaciones ? Duration.zero : EfectosApp.duracionPanel,
            child: verAviso
                ? AvisoConexion(key: ValueKey(sinConexion), restablecida: !sinConexion)
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
    final altoMinimoZona =
        TarjetaCaso.altoMinimoPara(MediaQuery.textScalerOf(context), tipo: tarjeta.tipo) +
        MazoSwipe.altoPila;
    final acciones = AccionesVeredicto(alElegir: (v) => _mazo.currentState?.confirmar(v));
    final Widget comodines;
    if (sinConexion || pendientes > 0) {
      comodines = ConstrainedBox(
        constraints: const BoxConstraints(minHeight: BarraComodines.alto),
        child: Center(child: IndicadorPendientes(cantidad: pendientes)),
      );
    } else {
      comodines = Semantics(
        container: true,
        label: Textos.comodinesTitulo,
        child: ValueListenableBuilder<bool>(
          valueListenable: _panelAbierto,
          builder: (context, panelAbierto, _) {
            final abierto = panelAbierto || progreso.panel != null;
            final lupa = LogicaComodines.estadoLupa(progreso, tarjeta, panelAbierto: abierto);
            final abogado = LogicaComodines.estadoAbogado(progreso, tarjeta, panelAbierto: abierto);
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
      );
    }
    // Solo en depuración: la única forma de ver el estado 23 sin backend.
    final interruptorDebug = kDebugMode && ref.read(servicioConexionProvider) is ConexionSimulada
        ? InterruptorConexionDebug(
            sinConexion: sinConexion,
            alCambiar: (sin) => (ref.read(servicioConexionProvider) as ConexionSimulada).establecer(
              sin ? EstadoConexion.sinConexion : EstadoConexion.enLinea,
            ),
          )
        : null;

    if (clase.esAncho) {
      return _envolver(
        _JuegoTablet(
          barra: BarraJuegoTablet(
            numeroSprint: datos.numeroSprint,
            actual: indice + 1,
            total: total,
            vidas: progreso.vidas,
            racha: ref.watch(sesionProvider)?.racha ?? 0,
            // Saldo al empezar más lo ganado en el sprint.
            monedas: (ref.watch(saldoJuegoProvider).value ?? 0) + progreso.monedas,
            alSalir: _salir,
            alPausar: _pausar,
          ),
          zonaTarjeta: zonaTarjeta,
          altoMinimoZona: altoMinimoZona,
          acciones: acciones,
          comodines: comodines,
          interruptorDebug: interruptorDebug,
          panel: [
            TarjetaTuStartup(estado: progreso.estadoStartup, cambios: cambios),
            TarjetaContextoSprint(
              etiqueta: Textos.contextoSprint(datos.modulo?.numero ?? 1, datos.numeroSprint),
              titulo: datos.sprint?.tituloIntro ?? datos.sprint?.titulo ?? '',
              objetivo: LogicaJuegoTablet.objetivo(datos.sprint?.objetivo ?? ''),
            ),
            const TarjetaAtajos(),
          ],
        ),
      );
    }

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
            child: IndicadoresStartup(estado: progreso.estadoStartup, cambios: cambios),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: altoMinimoZona),
              // Solo hijos posicionados: la zona no aporta alto intrínseco y
              // se estira o encoge con la pantalla.
              child: zonaTarjeta,
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: acciones),
        const SizedBox(height: 22),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: comodines),
        if (interruptorDebug != null) ...[const SizedBox(height: 8), interruptorDebug],
        const SizedBox(height: 16),
      ],
    );

    return _envolver(
      SafeArea(
        child: LayoutBuilder(
          builder: (context, restricciones) => SingleChildScrollView(
            key: const ValueKey('juego-desplazable'),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: restricciones.maxHeight),
              // Entre 600 y 959 el juego del móvil va centrado con ancho máximo.
              child: IntrinsicHeight(
                child: clase.esTablet
                    ? Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: anchoJuegoTabletVertical),
                          child: contenido,
                        ),
                      )
                    : contenido,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Teclado y tinte de pantalla completa (detrás de la tarjeta y delante del
  /// fondo), en móvil y en tablet.
  Widget _envolver(Widget cuerpo) => Focus(
    autofocus: true,
    skipTraversal: true,
    onKeyEvent: _alTeclear,
    child: Stack(
      children: [
        Positioned.fill(
          child: ValueListenableBuilder<ArrastreVisible>(
            valueListenable: _arrastre,
            builder: (context, arrastre, _) => TinteVeredicto(
              veredicto: arrastre.veredicto,
              opacidad: arrastre.progreso * LogicaSwipe.opacidadTinte,
            ),
          ),
        ),
        cuerpo,
      ],
    ),
  );
}

/// Ancho máximo de la hoja inferior entre 600 y 959 (como los diálogos).
const double anchoHojaTabletVertical = 440;

/// Ancho máximo del juego del móvil entre 600 y 959.
const double anchoJuegoTabletVertical = 440;

/// Saldo de monedas al abrir el juego (HUD de tablet; T-12c).
final saldoJuegoProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(repositorioTiendaProvider).obtenerMonedas(),
);

/// Reglas de presentación del juego en tablet (sin estado).
abstract final class LogicaJuegoTablet {
  /// El objetivo del sprint con la primera letra en mayúscula (los objetivos
  /// se guardan en minúscula porque la intro antepone "Objetivo: ").
  static String objetivo(String texto) {
    final t = texto.trim();
    if (t.isEmpty) return t;
    return t[0].toUpperCase() + t.substring(1);
  }
}

/// Composición del juego en tablet horizontal (T10, Figma `97:772`), sin riel:
/// barra de 64 arriba (x 24, y 8); a la izquierda (de 24 a ventana − 424) la
/// tarjeta de 380 × 470 centrada con su pila, los botones de veredicto y los
/// comodines; a la derecha el panel lateral de 376 (margen 24) con "Tu
/// Startup", el contexto del sprint y los atajos. Con texto grande el panel
/// pasa debajo y todo se desplaza en una columna.
class _JuegoTablet extends StatelessWidget {
  const _JuegoTablet({
    required this.barra,
    required this.zonaTarjeta,
    required this.altoMinimoZona,
    required this.acciones,
    required this.comodines,
    required this.panel,
    this.interruptorDebug,
  });

  static const double anchoTarjeta = 380;

  /// Tarjeta de 470 más los 20 de la pila.
  static const double altoZona = 470 + MazoSwipe.altoPila;

  static const double margen = 24;
  static const double arribaBarra = 8;

  /// De la barra a la tarjeta (Figma: 108 − 72).
  static const double bajoBarra = 36;
  static const double bajoAcciones = 16;
  static const double separacionPanel = 16;
  static const double abajo = 24;

  final Widget barra;
  final Widget zonaTarjeta;
  final double altoMinimoZona;
  final Widget acciones;
  final Widget comodines;
  final List<Widget> panel;
  final Widget? interruptorDebug;

  @override
  Widget build(BuildContext context) {
    final textoGrande = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final columnaPanel = Column(
      key: const ValueKey('panel-lateral-juego'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, p) in panel.indexed) ...[
          if (i > 0) const SizedBox(height: separacionPanel),
          p,
        ],
      ],
    );
    final debug = interruptorDebug;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, restricciones) {
          Widget zona(double alto) => Center(
            child: SizedBox(
              key: const ValueKey('zona-tarjeta-tablet'),
              width: anchoTarjeta,
              height: alto,
              child: zonaTarjeta,
            ),
          );
          final cabeza = Padding(
            padding: const EdgeInsets.fromLTRB(margen, arribaBarra, margen, 0),
            child: barra,
          );
          final bajo = <Widget>[
            Center(child: acciones),
            const SizedBox(height: bajoAcciones),
            Center(child: comodines),
            if (debug != null) ...[const SizedBox(height: 8), Center(child: debug)],
          ];

          if (textoGrande) {
            // Una columna que se desplaza: la zona de juego y, debajo, el panel.
            return SingleChildScrollView(
              key: const ValueKey('juego-desplazable'),
              padding: const EdgeInsets.only(bottom: abajo),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  cabeza,
                  const SizedBox(height: bajoBarra),
                  zona(altoZona > altoMinimoZona ? altoZona : altoMinimoZona),
                  ...bajo,
                  const SizedBox(height: abajo),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: MedidasAdaptativas.contenidoUnaColumna,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: margen),
                        child: columnaPanel,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Alto de la zona: el de Figma si cabe; si no, se encoge hasta el
          // mínimo del móvil y la pantalla se desplaza si aun así no cabe.
          const fijo =
              arribaBarra +
              BarraJuegoTablet.alto +
              bajoBarra +
              90 +
              bajoAcciones +
              BarraComodines.alto +
              abajo;
          final disponible = restricciones.maxHeight - fijo;
          final altoTarjeta = disponible.clamp(altoMinimoZona, altoZona);
          final altoTotal = fijo + altoTarjeta > restricciones.maxHeight
              ? fijo + altoTarjeta
              : restricciones.maxHeight;

          return SingleChildScrollView(
            key: const ValueKey('juego-desplazable'),
            child: SizedBox(
              height: altoTotal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  cabeza,
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: margen),
                        Expanded(
                          child: Column(
                            key: const ValueKey('zona-juego-tablet'),
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: bajoBarra),
                              zona(altoTarjeta),
                              ...bajo,
                            ],
                          ),
                        ),
                        const SizedBox(width: margen),
                        SizedBox(
                          width: MedidasAdaptativas.hojaLateral,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(top: margen, bottom: abajo),
                            child: columnaPanel,
                          ),
                        ),
                        const SizedBox(width: margen),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// "Juego en pausa" (tablet): centrado, hasta 440 de ancho. "Seguir jugando"
/// cierra; "Salir del sprint" devuelve `true` y abre la confirmación de Salir.
class _DialogoPausa extends StatelessWidget {
  const _DialogoPausa();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return Dialog(
      key: const ValueKey('dialogo-pausa'),
      backgroundColor: tokens.fondoSuperficie,
      surfaceTintColor: const Color(0x00000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: anchoHojaTabletVertical),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BloqueLectura(
                encabezado: true,
                autofocus: true,
                radio: 8,
                child: Text(
                  Textos.pausaTitulo,
                  style: estilos.h2.copyWith(color: tokens.textoPrimario),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                Textos.pausaTexto,
                style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
              ),
              const SizedBox(height: 20),
              BotonApp(
                key: const ValueKey('boton-seguir-jugando'),
                texto: Textos.seguirJugando,
                altoMinimo: 48,
                alPresionar: () => Navigator.of(context).pop(false),
              ),
              const SizedBox(height: 8),
              BotonApp(
                key: const ValueKey('boton-salir-sprint'),
                texto: Textos.salirDelSprint,
                tipo: TipoBoton.fantasma,
                altoMinimo: 48,
                alPresionar: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Altura del aviso de conexión respecto a la tarjeta (Figma 23: 6 arriba).
const double posicionAvisoConexion = -6;

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
