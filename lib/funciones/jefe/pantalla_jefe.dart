import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/rutas.dart';
import '../../componentes/acciones_veredicto.dart';
import '../../componentes/aviso_conexion.dart';
import '../../componentes/barra_juego.dart';
import '../../componentes/bloque_lectura.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/composicion_juego_tablet.dart';
import '../../componentes/dialogo_confirmacion.dart';
import '../../componentes/disposicion_resultado_tablet.dart';
import '../../componentes/hoja_lateral.dart';
import '../../componentes/icono_app.dart';
import '../../componentes/mensaje_pantalla.dart';
import '../../componentes/panel_lateral_juego.dart';
import '../../componentes/piezas_jefe.dart';
import '../../componentes/piezas_perfil.dart';
import '../../componentes/sarko_imagen.dart';
import '../../componentes/sello_veredicto.dart';
import '../../componentes/tarjeta_caso.dart';
import '../../componentes/tinte_veredicto.dart';
import '../../core/adaptativo/clase_pantalla.dart';
import '../../core/tema/efectos.dart';
import '../../core/tema/iconos_app.dart';
import '../../core/tema/tema_app.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/examen.dart';
import '../../datos/modelos/tarjeta.dart';
import '../../datos/repositorios/repositorio_examen.dart';
import '../../datos/sincronizacion/estado_sincronizacion.dart';
import '../../datos/sincronizacion/servicio_conexion.dart';
import '../acceso/sesion.dart';
import '../ajustes/estado_ajustes.dart';
import '../inicio/logica_inicio.dart';
import '../juego/logica_swipe.dart';
import '../juego/mazo_swipe.dart';
import '../juego/saldo_juego.dart';
import 'estado_examen.dart';
import 'logica_jefe.dart';
import 'reloj_crisis.dart';

/// Examen Final de un módulo: 27 Crisis → 28 Decisión → 28b Contraargumento
/// → 28c Golpe, en la misma ruta (la fase vive en `examenProvider`). Al
/// terminar va a 29 o 30 (T-11b).
class PantallaJefe extends ConsumerStatefulWidget {
  const PantallaJefe({required this.moduloId, super.key});

  final String moduloId;

  @override
  ConsumerState<PantallaJefe> createState() => _PantallaJefeState();
}

class _PantallaJefeState extends ConsumerState<PantallaJefe> {
  @override
  void initState() {
    super.initState();
    // No se puede cambiar un proveedor mientras se construye el árbol.
    unawaited(
      Future.microtask(() {
        if (mounted) ref.read(examenProvider.notifier).preparar(widget.moduloId);
      }),
    );
  }

  void _alCambiar(EstadoExamenJefe? antes, EstadoExamenJefe? ahora) {
    if (ahora == null || ahora.moduloId != widget.moduloId) return;
    if (ahora.fase == FaseJefe.terminado && antes?.fase != FaseJefe.terminado) {
      context.go(
        ahora.resultado == EstadoExamen.aprobado
            ? Rutas.auditoriaSuperadaDe(widget.moduloId)
            : Rutas.inspectoraGanoDe(widget.moduloId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<EstadoExamenJefe?>(examenProvider, _alCambiar);
    final examen = ref.watch(examenProvider);
    final enExamen =
        examen != null &&
        examen.moduloId == widget.moduloId &&
        examen.fase != FaseJefe.intro &&
        examen.fase != FaseJefe.terminado;
    if (enExamen) return _Decision(moduloId: widget.moduloId);
    return PantallaCrisis(moduloId: widget.moduloId);
  }
}

/// Vuelve al mapa del módulo (o a lo anterior si hay pila).
void volverAlMapa(BuildContext context, String moduloId) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(Rutas.mapaSprintsDe(moduloId));
  }
}

// =========================================================================
// 27 · Crisis
// =========================================================================

/// Pantalla 27 · Crisis (Figma 42:5885): siempre oscura, con colores fijos
/// de `EfectosApp`. La alerta, el título con Sarko enojado, el texto, la
/// barra del Jefe, la línea de crisis, las reglas, el aviso de tiempo
/// extendido y los botones fijos "Enfrentar la auditoría" y "Ahora no".
class PantallaCrisis extends ConsumerStatefulWidget {
  const PantallaCrisis({required this.moduloId, super.key});

  final String moduloId;

  @override
  ConsumerState<PantallaCrisis> createState() => _PantallaCrisisState();
}

class _PantallaCrisisState extends ConsumerState<PantallaCrisis> {
  Future<void> _enfrentar(DatosCrisis datos) async {
    if (datos.vidas <= 0) {
      context.go(Rutas.sinVidasDe(widget.moduloId));
      return;
    }
    final mensajero = ScaffoldMessenger.of(context);
    try {
      await ref.read(examenProvider.notifier).iniciar();
    } on ExcepcionExamen catch (e) {
      if (!mounted) return;
      if (e.motivo == MotivoExcepcionExamen.sinVidas) {
        context.go(Rutas.sinVidasDe(widget.moduloId));
        return;
      }
      _avisar(
        mensajero,
        e.motivo == MotivoExcepcionExamen.sinConexion
            ? Textos.necesitasConexionExamen
            : Textos.examenErrorIniciar,
      );
    } on Object {
      if (mounted) _avisar(mensajero, Textos.examenErrorIniciar);
    }
  }

  static void _avisar(ScaffoldMessengerState mensajero, String texto) {
    mensajero
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: const ValueKey('aviso-examen'),
          content: Semantics(liveRegion: true, child: Text(texto)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final datos = ref.watch(datosCrisisProvider(widget.moduloId));
    final valor = datos.value;
    final error = datos.hasError ? datos.error : null;
    // Con error se muestra el mensaje aunque Riverpod siga reintentando.
    final Widget cuerpo = valor != null
        ? _Crisis(
            datos: valor,
            alEnfrentar: () => _enfrentar(valor),
            alAhoraNo: () => volverAlMapa(context, widget.moduloId),
          )
        : error is ExcepcionExamen && error.motivo == MotivoExcepcionExamen.examenNoDisponible
        ? MensajePantalla(
            texto: Textos.examenNoDisponible,
            textoBoton: Textos.volverAlMapa,
            alPresionar: () => volverAlMapa(context, widget.moduloId),
          )
        : error != null
        ? MensajePantalla(
            texto: Textos.examenErrorCarga,
            textoBoton: Textos.reintentar,
            alPresionar: () => ref.invalidate(datosCrisisProvider(widget.moduloId)),
          )
        : const _EsqueletoCrisis();
    // Siempre oscura: el botón y los mensajes usan los tokens claros sobre
    // el fondo fijo de la crisis (como en Figma, que no cambia con el tema).
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Theme(
        data: crearTemaClaro(),
        child: Scaffold(
          key: const ValueKey('pantalla-crisis'),
          backgroundColor: EfectosApp.fondoCrisis,
          body: SafeArea(child: cuerpo),
        ),
      ),
    );
  }
}

class _Crisis extends ConsumerWidget {
  const _Crisis({required this.datos, required this.alEnfrentar, required this.alAhoraNo});

  final DatosCrisis datos;
  final VoidCallback alEnfrentar;
  final VoidCallback alAhoraNo;

  static const double anchoSarko = 112;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estilos = context.estilos;
    final extendido = ref.watch(ajustesProvider.select((a) => a.tiempoExtendido));
    final enLinea = ref.watch(conexionProvider) != EstadoConexion.sinConexion;
    final iniciando = ref.watch(examenProvider.select((e) => e?.enviando ?? false));
    final segundos = LogicaJefe.segundosPorDecision(tiempoExtendido: extendido);
    final info = datos.info;

    Widget regla(IconData icono, String texto) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          IconoApp(icono, tamano: 20, color: EfectosApp.iconoReglaCrisis),
          const SizedBox(width: 12),
          Expanded(
            child: Text(texto, style: estilos.cuerpoBase.copyWith(color: EfectosApp.blancoCrisis)),
          ),
        ],
      ),
    );

    final alerta = Container(
      key: const ValueKey('alerta-jefe'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: EfectosApp.alertaCrisis,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const IconoApp(IconosApp.alert, tamano: 16, color: EfectosApp.blancoCrisis),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              Textos.alertaJefe,
              style: estilos.etiqueta.copyWith(color: EfectosApp.blancoCrisis),
            ),
          ),
        ],
      ),
    );

    // T27 (Figma 101:4895): alerta, Sarko, la barra del Jefe y la línea de
    // crisis × 1.4 en el panel izquierdo; título, reglas y botones a la derecha.
    if (context.clasePantalla.esAncho) {
      return _CrisisTablet(
        alerta: alerta,
        titulo: BloqueLectura(
          key: const ValueKey('titulo-crisis'),
          encabezado: true,
          autofocus: true,
          radio: 8,
          child: Text(
            info.titulo,
            textAlign: TextAlign.center,
            style: estilos.h1.copyWith(color: EfectosApp.blancoCrisis),
          ),
        ),
        descripcion: Text(
          info.descripcion,
          textAlign: TextAlign.center,
          style: estilos.cuerpoBase.copyWith(color: EfectosApp.textoCrisis),
        ),
        reglas: [
          regla(IconosApp.zap, Textos.reglaDecisiones(info.totalDecisiones, segundos)),
          regla(IconosApp.megaphone, Textos.reglaContraargumento),
          regla(IconosApp.lock, Textos.reglaComodines),
          regla(IconosApp.heart, Textos.reglaVidas),
        ],
        extendido: extendido ? Textos.tiempoExtendidoActivo(segundos) : null,
        enLinea: enLinea,
        iniciando: iniciando,
        alEnfrentar: alEnfrentar,
        alAhoraNo: alAhoraNo,
      );
    }

    final contenido = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            key: const ValueKey('alerta-jefe'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: EfectosApp.alertaCrisis,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const IconoApp(IconosApp.alert, tamano: 16, color: EfectosApp.blancoCrisis),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    Textos.alertaJefe,
                    style: estilos.etiqueta.copyWith(color: EfectosApp.blancoCrisis),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Título con Sarko a la derecha (detrás, como en Figma).
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned(
              right: 0,
              top: -18,
              child: SarkoImagen(pose: PoseSarko.enojado, ancho: anchoSarko, decorativa: true),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 102),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 96),
                child: BloqueLectura(
                  key: const ValueKey('titulo-crisis'),
                  encabezado: true,
                  autofocus: true,
                  radio: 8,
                  child: Text(
                    info.titulo,
                    style: estilos.h1.copyWith(color: EfectosApp.blancoCrisis),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(info.descripcion, style: estilos.cuerpoBase.copyWith(color: EfectosApp.textoCrisis)),
        const SizedBox(height: 16),
        const BarraDelJefe(hp: 100),
        const SizedBox(height: 12),
        const Padding(padding: EdgeInsets.only(left: 8), child: LineaDeCrisis()),
        const SizedBox(height: 16),
        Container(
          key: const ValueKey('reglas-crisis'),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: EfectosApp.fondoReglasCrisis,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              regla(IconosApp.zap, Textos.reglaDecisiones(info.totalDecisiones, segundos)),
              regla(IconosApp.megaphone, Textos.reglaContraargumento),
              regla(IconosApp.lock, Textos.reglaComodines),
              regla(IconosApp.heart, Textos.reglaVidas),
            ],
          ),
        ),
        if (extendido) ...[
          const SizedBox(height: 14),
          Row(
            key: const ValueKey('tiempo-extendido-crisis'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const IconoApp(IconosApp.accessibility, tamano: 16, color: EfectosApp.verdeCrisis),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  Textos.tiempoExtendidoActivo(segundos),
                  style: estilos.leyenda.copyWith(color: EfectosApp.verdeCrisis),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 28),
        const Spacer(),
        if (!enLinea) ...[
          Text(
            Textos.necesitasConexionExamen,
            key: const ValueKey('aviso-sin-conexion-examen'),
            textAlign: TextAlign.center,
            style: estilos.leyenda.copyWith(color: EfectosApp.textoCrisis),
          ),
          const SizedBox(height: 8),
        ],
        BotonApp(
          key: const ValueKey('boton-enfrentar'),
          texto: Textos.enfrentarAuditoria,
          tipo: TipoBoton.acento,
          cargando: iniciando,
          textoCargando: Textos.iniciandoExamen,
          alPresionar: enLinea ? alEnfrentar : null,
        ),
        const SizedBox(height: 4),
        Center(
          child: TextButton(
            key: const ValueKey('boton-ahora-no'),
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 48),
              foregroundColor: EfectosApp.textoCrisis,
            ),
            onPressed: alAhoraNo,
            child: Text(
              Textos.ahoraNo,
              style: estilos.cuerpoEnfasis.copyWith(color: EfectosApp.textoCrisis),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );

    return CustomScrollView(
      key: const ValueKey('crisis-desplazable'),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: contenido),
        ),
      ],
    );
  }
}

class _EsqueletoCrisis extends StatelessWidget {
  const _EsqueletoCrisis();

  @override
  Widget build(BuildContext context) {
    Widget bloque(double alto, {double? ancho, double radio = 16}) => Container(
      width: ancho,
      height: alto,
      decoration: BoxDecoration(
        color: EfectosApp.fondoReglasCrisis,
        borderRadius: BorderRadius.circular(radio),
      ),
    );
    return Semantics(
      label: Textos.cargandoExamen,
      liveRegion: true,
      excludeSemantics: true,
      child: SingleChildScrollView(
        key: const ValueKey('esqueleto-crisis'),
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bloque(28, ancho: 230, radio: 999),
            const SizedBox(height: 12),
            bloque(96, ancho: 240, radio: 8),
            const SizedBox(height: 10),
            bloque(60),
            const SizedBox(height: 16),
            bloque(80, radio: 18),
            const SizedBox(height: 12),
            bloque(40, ancho: 300),
            const SizedBox(height: 16),
            bloque(200, radio: 20),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 28 · Decisión, 28b · Contraargumento, 28c · Golpe
// =========================================================================

class _Decision extends ConsumerStatefulWidget {
  const _Decision({required this.moduloId});

  final String moduloId;

  @override
  ConsumerState<_Decision> createState() => _DecisionState();
}

class _DecisionState extends ConsumerState<_Decision> {
  final _mazo = GlobalKey<MazoSwipeState>();
  final _arrastre = ValueNotifier(const ArrastreVisible());
  final _focoReplica = FocusNode(debugLabel: 'réplica de la Inspectora');
  Timer? _temporizadorChip;

  /// Cambia si una respuesta no se pudo enviar: la tarjeta vuelve a entrar.
  int _reintento = 0;

  @override
  void dispose() {
    _temporizadorChip?.cancel();
    _arrastre.dispose();
    _focoReplica.dispose();
    super.dispose();
  }

  ExamenNotifier get _examen => ref.read(examenProvider.notifier);

  void _anunciar(String mensaje) {
    unawaited(SemanticsService.sendAnnouncement(View.of(context), mensaje, TextDirection.ltr));
  }

  void _alCambiar(EstadoExamenJefe? antes, EstadoExamenJefe? ahora) {
    if (ahora == null) return;
    if (ahora.fase == FaseJefe.feedback && antes?.fase != FaseJefe.feedback) {
      _temporizadorChip?.cancel();
      _temporizadorChip = Timer(EfectosApp.duracionChipJefe, () {
        if (mounted) _examen.continuar();
      });
    }
    if (ahora.fase == FaseJefe.replica && antes?.fase != FaseJefe.replica) {
      final replica = ahora.replica;
      final limite = ahora.limiteReplica ?? Duration.zero;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_focoReplica.context != null) _focoReplica.requestFocus();
        if (replica != null) {
          _anunciar(Textos.replicaAnuncio(replica.texto, limite.inSeconds));
        }
      });
    }
  }

  void _avisarError() {
    if (!mounted) return;
    setState(() {
      _reintento++;
      _arrastre.value = const ArrastreVisible();
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: const ValueKey('error-respuesta-examen'),
          content: Semantics(liveRegion: true, child: const Text(Textos.errorRespuestaExamen)),
        ),
      );
  }

  Future<void> _responder(Veredicto? veredicto) async {
    final haptica = ref.read(servicioHapticoProvider);
    try {
      final r = await _examen.responderDecision(veredicto);
      if (r == null) return;
      unawaited(r.correcta ? haptica.acierto() : haptica.error());
    } on Object {
      _avisarError();
    }
  }

  Future<void> _defender(int? fundamento) async {
    final haptica = ref.read(servicioHapticoProvider);
    try {
      final r = await _examen.responderContraargumento(fundamento);
      if (r == null) return;
      unawaited(r.correcto ? haptica.acierto() : haptica.error());
    } on Object {
      _avisarError();
    }
  }

  Future<void> _salir() async {
    final salir = await DialogoConfirmacion.mostrar(
      context,
      titulo: Textos.salirExamenTitulo,
      texto: Textos.salirExamenTexto,
      textoConfirmar: Textos.salirExamen,
      // El reloj no se detiene con el diálogo abierto: el foco inicial va al
      // botón que sigue en el examen (T-13).
      textoCancelar: Textos.seguirEnExamen,
      focoEnCancelar: true,
    );
    if (!salir || !mounted) return;
    final moduloId = widget.moduloId;
    final enrutador = GoRouter.of(context);
    await _examen.abandonar();
    enrutador.go(Rutas.mapaSprintsDe(moduloId));
  }

  void _anunciarSegundo(int s, Duration limite) {
    if (s == limite.inSeconds) {
      _anunciar(Textos.limiteDecision(s));
    } else if (s == 0) {
      _anunciar(Textos.tiempoAgotado);
    } else if (LogicaJefe.segundosAnunciados.contains(s)) {
      _anunciar(Textos.quedanSegundos(s));
    }
  }

  KeyEventResult _alTeclear(FocusNode _, KeyEvent evento) {
    if (evento is! KeyDownEvent && evento is! KeyRepeatEvent) return KeyEventResult.ignored;
    final mazo = _mazo.currentState;
    if (mazo == null || ref.read(examenProvider)?.fase != FaseJefe.decision) {
      return KeyEventResult.ignored;
    }
    // "P pausa" (atajos del Examen): con la misma regla que el botón, solo
    // con tiempo extendido (T-13; el atajo se anunciaba y no existía).
    if (evento.logicalKey == LogicalKeyboardKey.keyP && evento is KeyDownEvent) {
      if (!ref.read(ajustesProvider).tiempoExtendido) return KeyEventResult.ignored;
      unawaited(_examen.pausar());
      return KeyEventResult.handled;
    }
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
    ref.listen<EstadoExamenJefe?>(examenProvider, _alCambiar);
    final examen = ref.watch(examenProvider);
    if (examen == null) return const SizedBox.shrink();
    final tokens = context.tokens;
    final crear = ref.watch(crearCronometroJefeProvider);
    final ajustes = ref.watch(ajustesProvider);
    final sinConexion = ref.watch(conexionProvider) == EstadoConexion.sinConexion;
    final fase = examen.fase;
    final enPausa = fase == FaseJefe.pausa;
    final faseVisible = enPausa ? (examen.faseAntesDePausa ?? FaseJefe.decision) : fase;

    // En el chip de 28c ya se ve la siguiente decisión, con el tiempo lleno
    // y detenido hasta que el chip desaparece.
    final enChip = faseVisible == FaseJefe.feedback;
    final decision = (enChip ? examen.siguiente : null) ?? examen.decision!;
    final ronda = enChip && examen.siguiente != null ? examen.ronda + 1 : examen.ronda;
    final relojDetenido = enPausa || faseVisible != FaseJefe.decision || examen.enviando;

    final tarjeta = TarjetaCaso(
      etiquetaCaso: decision.etiquetaCaso,
      colorModulo: EfectosApp.etiquetaCrisis,
      iniciales: decision.iniciales ?? LogicaInicio.iniciales(decision.personaje),
      personaje: decision.personaje,
      rol: decision.rol,
      texto: decision.texto,
      soloBotones: ajustes.soloBotones,
    );

    final Widget zonaTarjeta;
    if (faseVisible == FaseJefe.replica) {
      // 28b: la tarjeta enviada queda en su pose de vuelo, con el sello.
      final v = examen.veredictoElegido ?? Veredicto.ilegal;
      final direccion = switch (v) {
        Veredicto.ilegal => -1.0,
        Veredicto.legal => 1.0,
        _ => 0.0,
      };
      zonaTarjeta = ExcludeSemantics(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              bottom: MazoSwipe.altoPila,
              child: Transform.translate(
                key: const ValueKey('tarjeta-enviada'),
                offset: Offset(90 * direccion, 20),
                child: Transform.rotate(angle: (14 * direccion) * math.pi / 180, child: tarjeta),
              ),
            ),
            Positioned(right: 0, top: 8, child: SelloVeredicto(veredicto: v)),
          ],
        ),
      );
    } else {
      zonaTarjeta = MazoSwipe(
        key: _mazo,
        claveTarjeta: '${decision.id}-$_reintento',
        restantes: examen.total - decision.indice,
        arrastre: _arrastre,
        // Solo se arrastra mientras se decide (no en el chip ni enviando).
        arrastreActivo:
            !ajustes.soloBotones && faseVisible == FaseJefe.decision && !examen.enviando,
        etiquetaSemantica: Textos.decisionSemantica(
          decision.indice,
          examen.total,
          decision.personaje,
          decision.rol,
          decision.texto,
        ),
        alConfirmar: _responder,
        // Tablet ancha: la tarjeta se queda con su sello hasta la siguiente
        // decisión (T-13).
        retenerAlConfirmar: context.clasePantalla.esAncho,
        tarjeta: tarjeta,
      );
    }

    final temporizador = RelojCrisis(
      key: const ValueKey('reloj-decision'),
      limite: decision.limite,
      ronda: ronda,
      crearCronometro: crear,
      detenido: relojDetenido,
      alAgotar: () => _responder(null),
      alSegundo: relojDetenido ? null : (s) => _anunciarSegundo(s, decision.limite),
      constructor: (context, restante) =>
          TemporizadorCrisis(restante: restante, limite: decision.limite),
    );

    final tablet = context.clasePantalla.esAncho;
    final feedback = examen.feedback;
    final chipGolpe = faseVisible == FaseJefe.feedback && feedback != null
        ? ChipGolpe(
            danio: feedback == TipoFeedback.golpe,
            texto: LogicaJefe.textoFeedback(feedback, examen.danio),
            etiquetaSemantica: LogicaJefe.anuncioFeedback(
              feedback,
              danio: examen.danio,
              hp: examen.hp,
              vidas: examen.vidas,
            ),
          )
        : null;
    final altoMinimoZona =
        TarjetaCaso.altoMinimoPara(MediaQuery.textScalerOf(context)) + MazoSwipe.altoPila;
    final zona = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: zonaTarjeta),
        Positioned(left: 16, top: -14, child: ChipHoraCrisis(hora: decision.hora)),
        Positioned(right: -12, top: -24, child: temporizador),
        if (sinConexion)
          const Positioned(
            left: 0,
            right: 0,
            top: 24,
            child: AvisoConexion(key: ValueKey('aviso-conexion-examen')),
          ),
      ],
    );
    final acciones = AccionesVeredicto(
      alElegir: faseVisible == FaseJefe.decision && !examen.enviando
          ? (v) => _mazo.currentState?.confirmar(v)
          : null,
    );

    final contenido = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BarraJuego(
          numeroSprint: 0,
          actual: decision.indice,
          total: examen.total,
          vidas: examen.vidas,
          paso: Textos.pasoCrisis(decision.indice, examen.total),
          colorProgreso: context.tokens.accionSecundaria,
          alSalir: _salir,
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: BarraDelJefe(hp: examen.hp),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: altoMinimoZona),
              child: zona,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: acciones),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Expanded(child: Center(child: PildoraComodinesBloqueados())),
              if (ajustes.tiempoExtendido) ...[
                const SizedBox(width: 8),
                BotonIconoCuadrado(
                  key: const ValueKey('boton-pausa'),
                  icono: IconosApp.pause,
                  etiqueta: Textos.pausar,
                  alPresionar: _examen.pausar,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (hecho, _) {
        if (!hecho) unawaited(_salir());
      },
      child: Scaffold(
        key: const ValueKey('pantalla-decision'),
        body: Focus(
          autofocus: true,
          skipTraversal: true,
          onKeyEvent: _alTeclear,
          child: Stack(
            children: [
              // Tinte de urgencia (decorativo).
              Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                    key: const ValueKey('tinte-urgencia'),
                    color: tokens.estadoIlegal.withValues(alpha: EfectosApp.opacidadUrgencia),
                  ),
                ),
              ),
              Positioned.fill(
                child: ValueListenableBuilder<ArrastreVisible>(
                  valueListenable: _arrastre,
                  builder: (context, arrastre, _) => TinteVeredicto(
                    veredicto: arrastre.veredicto,
                    opacidad: arrastre.progreso * LogicaSwipe.opacidadTinte,
                  ),
                ),
              ),
              // T28 (Figma 101:5001): la composición del juego en tablet con
              // "El Jefe" y los atajos en el panel lateral.
              if (tablet)
                ComposicionJuegoTablet(
                  barra: BarraJuegoTablet(
                    numeroSprint: 0,
                    actual: decision.indice,
                    total: examen.total,
                    vidas: examen.vidas,
                    racha: ref.watch(sesionProvider)?.racha ?? 0,
                    monedas: ref.watch(saldoJuegoProvider).value ?? 0,
                    paso: Textos.pasoCrisis(decision.indice, examen.total),
                    colorProgreso: context.tokens.accionSecundaria,
                    alSalir: _salir,
                    alPausar: ajustes.tiempoExtendido ? _examen.pausar : null,
                  ),
                  zonaTarjeta: zona,
                  altoMinimoZona: altoMinimoZona,
                  acciones: acciones,
                  comodines: const PildoraComodinesBloqueados(),
                  panel: [
                    TarjetaJefe(hp: examen.hp, chip: chipGolpe),
                    const TarjetaAtajos(lineas: Textos.atajosLineasExamen),
                  ],
                )
              else
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, restricciones) => SingleChildScrollView(
                      key: const ValueKey('decision-desplazable'),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: restricciones.maxHeight),
                        child: IntrinsicHeight(child: contenido),
                      ),
                    ),
                  ),
                ),
              // Chip de daño o de fallo, sobre la barra del Jefe (en tablet,
              // dentro de la tarjeta "El Jefe" del panel lateral).
              if (chipGolpe != null && !tablet)
                Positioned(
                  top: MediaQuery.paddingOf(context).top + BarraJuego.alto - 12,
                  right: 24,
                  left: 24,
                  child: Align(alignment: Alignment.centerRight, child: chipGolpe),
                ),
              // 28b: velo y panel de contraargumento.
              if (faseVisible == FaseJefe.replica && examen.replica != null) ...[
                const Positioned.fill(
                  child: ModalBarrier(
                    key: ValueKey('velo-contraargumento'),
                    color: EfectosApp.colorVelo,
                    dismissible: false,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: tablet ? 0 : null,
                  child: _ContenedorReplica(
                    tablet: tablet,
                    child: SingleChildScrollView(
                      child: RelojCrisis(
                        key: ValueKey('reloj-replica-${examen.ronda}'),
                        limite: examen.limiteReplica ?? Duration.zero,
                        ronda: examen.ronda,
                        crearCronometro: crear,
                        detenido: enPausa || examen.enviando,
                        alAgotar: () => _defender(null),
                        alSegundo: (s) {
                          if (s == 3) _anunciar(Textos.quedanSegundos(s));
                        },
                        constructor: (context, restante) => PanelContraargumento(
                          replica: examen.replica!,
                          segundosRestantes: TemporizadorCrisis.segundos(restante),
                          nodoFocoReplica: _focoReplica,
                          alElegir: examen.enviando || enPausa ? null : _defender,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              // Pausa: tapa todo (la tarjeta no se ve).
              if (enPausa)
                Positioned.fill(
                  child: _CapaPausa(alContinuar: _examen.reanudar, alSalir: _salir),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Capa opaca de la pausa (no está en Figma): "Examen en pausa", "El tiempo
/// está detenido." y los botones "Continuar" y "Salir del examen".
class _CapaPausa extends StatelessWidget {
  const _CapaPausa({required this.alContinuar, required this.alSalir});

  final VoidCallback alContinuar;
  final VoidCallback alSalir;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return ColoredBox(
      key: const ValueKey('capa-pausa'),
      color: tokens.fondoApp,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconoApp(IconosApp.pause, tamano: 40, color: tokens.textoPrimario),
                const SizedBox(height: 16),
                BloqueLectura(
                  encabezado: true,
                  enVivo: true,
                  autofocus: true,
                  radio: 8,
                  child: Text(
                    Textos.examenEnPausa,
                    textAlign: TextAlign.center,
                    style: estilos.h1.copyWith(color: tokens.textoPrimario),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Textos.tiempoDetenido,
                  textAlign: TextAlign.center,
                  style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
                ),
                const SizedBox(height: 24),
                BotonApp(
                  key: const ValueKey('boton-continuar-pausa'),
                  texto: Textos.continuar,
                  alPresionar: alContinuar,
                ),
                const SizedBox(height: 8),
                BotonApp(
                  key: const ValueKey('boton-salir-pausa'),
                  texto: Textos.salirDelExamen,
                  tipo: TipoBoton.fantasma,
                  altoMinimo: 48,
                  alPresionar: alSalir,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Contenedor del contraargumento (28b): en el móvil, abajo y hasta el 92 % del
/// alto; en tablet horizontal, la hoja lateral de 376 (T28b, Figma 101:5194).
class _ContenedorReplica extends StatelessWidget {
  const _ContenedorReplica({required this.tablet, required this.child});

  final bool tablet;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (tablet) return HojaLateral(etiqueta: Textos.hojaContraargumento, child: child);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.92),
      child: child,
    );
  }
}

/// T27 en tablet horizontal: el panel izquierdo de la crisis (`#162030` con un
/// halo) con la alerta, Sarko enojado, la barra del Jefe y la línea de crisis
/// de la versión móvil × 1.4; a la derecha, en la columna de 470, el título,
/// la descripción, las reglas, el tiempo extendido y los botones.
class _CrisisTablet extends StatelessWidget {
  const _CrisisTablet({
    required this.alerta,
    required this.titulo,
    required this.descripcion,
    required this.reglas,
    required this.extendido,
    required this.enLinea,
    required this.iniciando,
    required this.alEnfrentar,
    required this.alAhoraNo,
  });

  /// Lienzo de la ilustración (el ancho del móvil) y su escala (Figma: la
  /// barra del Jefe mide 478.8).
  static const double anchoBase = 342;
  static const double altoBase = 370;
  static const double escala = 1.4;
  static const double halo = 560;

  final Widget alerta;
  final Widget titulo;
  final Widget descripcion;
  final List<Widget> reglas;
  final String? extendido;
  final bool enLinea;
  final bool iniciando;
  final VoidCallback alEnfrentar;
  final VoidCallback alAhoraNo;

  @override
  Widget build(BuildContext context) {
    final estilos = context.estilos;
    final texto = extendido;
    return DisposicionResultadoTablet(
      key: const ValueKey('crisis-tablet'),
      colorPanel: EfectosApp.barraJefe,
      ilustracion: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // El halo no cuenta para el tamaño de la ilustración (sobresale).
          Positioned.fill(
            child: OverflowBox(
              maxWidth: halo,
              maxHeight: halo,
              child: Container(
                key: const ValueKey('halo-crisis'),
                width: halo,
                height: halo,
                decoration: const BoxDecoration(
                  color: EfectosApp.haloCrisis,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          IlustracionAmpliada(
            anchoBase: anchoBase,
            escala: escala,
            child: SizedBox(
              height: altoBase,
              child: Stack(
                children: [
                  Positioned(left: 4, top: 4, child: alerta),
                  const Positioned(
                    left: 234,
                    top: 26,
                    child: SarkoImagen(pose: PoseSarko.enojado, ancho: 112, decorativa: true),
                  ),
                  const Positioned(left: 4, right: 4, top: 226, child: BarraDelJefe(hp: 100)),
                  const Positioned(left: 12, right: 0, top: 318, child: LineaDeCrisis()),
                ],
              ),
            ),
          ),
        ],
      ),
      contenido: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titulo,
          const SizedBox(height: 14),
          descripcion,
          const SizedBox(height: 14),
          Container(
            key: const ValueKey('reglas-crisis'),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: EfectosApp.fondoReglasCrisis,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: reglas),
          ),
          if (texto != null) ...[
            const SizedBox(height: 14),
            Row(
              key: const ValueKey('tiempo-extendido-crisis'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const IconoApp(IconosApp.accessibility, tamano: 16, color: EfectosApp.verdeCrisis),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    texto,
                    style: estilos.leyenda.copyWith(color: EfectosApp.verdeCrisis),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          if (!enLinea) ...[
            Text(
              Textos.necesitasConexionExamen,
              key: const ValueKey('aviso-sin-conexion-examen'),
              textAlign: TextAlign.center,
              style: estilos.leyenda.copyWith(color: EfectosApp.textoCrisis),
            ),
            const SizedBox(height: 8),
          ],
          BotonApp(
            key: const ValueKey('boton-enfrentar'),
            texto: Textos.enfrentarAuditoria,
            tipo: TipoBoton.acento,
            cargando: iniciando,
            textoCargando: Textos.iniciandoExamen,
            alPresionar: enLinea ? alEnfrentar : null,
          ),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              key: const ValueKey('boton-ahora-no'),
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
                foregroundColor: EfectosApp.textoCrisis,
              ),
              onPressed: alAhoraNo,
              child: Text(
                Textos.ahoraNo,
                style: estilos.cuerpoEnfasis.copyWith(color: EfectosApp.textoCrisis),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
