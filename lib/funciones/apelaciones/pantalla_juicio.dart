import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/rutas.dart';
import '../../componentes/acciones_veredicto.dart';
import '../../componentes/barra_progreso.dart';
import '../../componentes/bloque_lectura.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/boton_cerrar.dart';
import '../../componentes/composicion_juego_tablet.dart';
import '../../componentes/corazon_vida.dart';
import '../../componentes/disposicion_resultado_tablet.dart';
import '../../componentes/ilustracion_sarko.dart';
import '../../componentes/mensaje_pantalla.dart';
import '../../componentes/panel_lateral_juego.dart';
import '../../componentes/piezas_apelacion.dart';
import '../../componentes/sarko_imagen.dart';
import '../../componentes/tarjeta_caso.dart';
import '../../componentes/tinte_veredicto.dart';
import '../../core/adaptativo/clase_pantalla.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/apelacion.dart';
import '../../datos/modelos/tarjeta.dart';
import '../../datos/modelos/vidas.dart';
import '../../datos/repositorios/proveedores_repositorios.dart';
import '../../datos/sincronizacion/estado_sincronizacion.dart';
import '../../datos/sincronizacion/servicio_conexion.dart';
import '../ajustes/estado_ajustes.dart';
import '../inicio/logica_inicio.dart';
import '../juego/logica_swipe.dart';
import '../juego/mazo_swipe.dart';
import '../juego/piezas_fin_sprint.dart';
import 'logica_apelacion.dart';
import 'pantalla_buzon.dart';
import 'sesion_apelaciones.dart';

/// Lo que necesita el juicio: la apelación, su tarjeta, el color del módulo,
/// los días desde el fallo y las vidas.
class DatosJuicio {
  const DatosJuicio({
    required this.apelacion,
    required this.tarjeta,
    required this.colorModulo,
    required this.diasDesdeFallo,
    required this.vidas,
  });

  final Apelacion apelacion;
  final Tarjeta tarjeta;
  final Color? colorModulo;
  final int diasDesdeFallo;
  final int vidas;
}

/// Carga el juicio de una apelación; `null` si ya no existe o no se abre hoy
/// (fecha del servidor).
final datosJuicioProvider = FutureProvider.autoDispose.family<DatosJuicio?, String>((
  ref,
  id,
) async {
  final datos = await ref.watch(datosBuzonProvider.future);
  final buzon = datos.buzon;
  final apelacion = buzon.apelaciones.where((a) => a.id == id).firstOrNull;
  if (apelacion == null || buzon.diasHasta(apelacion) > 0) return null;
  final (tarjeta, vidas) = await (
    ref.watch(repositorioTarjetasProvider).obtenerTarjeta(apelacion.tarjetaId),
    ref.watch(repositorioVidasProvider).obtenerVidas(),
  ).wait;
  return DatosJuicio(
    apelacion: apelacion,
    tarjeta: tarjeta,
    colorModulo: datos.coloresModulo[apelacion.moduloId],
    diasDesdeFallo: apelacion.diaRepaso,
    vidas: vidas.cantidad,
  );
});

/// Pantalla 22 · Juicio de apelación (Figma 41:5785) y su resultado: 22b
/// Apelación ganada (Figma 41:5862) o la perdida (no está en Figma).
///
/// Sin navegación inferior, indicadores ni comodines. Salir (o atrás) vuelve
/// al Buzón sin resolver. Pide conexión: el servidor decide el resultado.
class PantallaJuicio extends ConsumerStatefulWidget {
  const PantallaJuicio({required this.apelacionId, super.key});

  final String apelacionId;

  /// Cruce entre el juicio y el resultado.
  static const Duration duracionCruce = Duration(milliseconds: 200);

  @override
  ConsumerState<PantallaJuicio> createState() => _PantallaJuicioState();
}

class _PantallaJuicioState extends ConsumerState<PantallaJuicio> {
  @override
  void initState() {
    super.initState();
    _asegurarSesion();
  }

  @override
  void didUpdateWidget(PantallaJuicio oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.apelacionId != widget.apelacionId) _asegurarSesion();
  }

  /// Enlace profundo sin sesión (o con otra): empieza una de una. No se puede
  /// cambiar un proveedor mientras se construye el árbol.
  void _asegurarSesion() {
    final id = widget.apelacionId;
    unawaited(
      Future.microtask(() {
        if (mounted) ref.read(sesionApelacionesProvider.notifier).asegurar(id);
      }),
    );
  }

  /// Vuelve al Buzón y termina la sesión (sin resolver la actual).
  void _volverAlBuzon() {
    ref.read(sesionApelacionesProvider.notifier).terminar();
    context.go(Rutas.buzon);
  }

  void _siguiente() {
    final siguiente = ref.read(sesionApelacionesProvider.notifier).avanzar();
    if (siguiente == null) {
      _volverAlBuzon();
    } else {
      context.go(Rutas.juicioApelacionDe(siguiente));
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.apelacionId;
    final sesion = ref.watch(sesionApelacionesProvider);
    final enSesion = sesion != null && sesion.ids.contains(id);
    final actual = enSesion ? sesion.ids.indexOf(id) + 1 : 1;
    final total = enSesion ? sesion.total : 1;
    final enResultado = enSesion && sesion.actual == id && sesion.fase == FaseApelacion.resultado;
    final sinAnimaciones = MediaQuery.disableAnimationsOf(context);

    final Widget cuerpo;
    if (enResultado) {
      cuerpo = _Resultado(
        key: const ValueKey('resultado-apelacion'),
        sesion: sesion,
        alSiguiente: _siguiente,
        alVolver: _volverAlBuzon,
      );
    } else {
      final sinConexion = ref.watch(conexionProvider) == EstadoConexion.sinConexion;
      final datos = ref.watch(datosJuicioProvider(id));
      cuerpo = Scaffold(
        key: const ValueKey('juicio-apelacion'),
        body: switch (datos) {
          _ when sinConexion => MensajePantalla(
            texto: Textos.necesitasConexionApelar,
            textoBoton: Textos.volverAlBuzon,
            alPresionar: _volverAlBuzon,
          ),
          AsyncData(:final value?) => _Juicio(
            key: ValueKey('juicio-$id'),
            datos: value,
            actual: actual,
            total: total,
            alSalir: _volverAlBuzon,
          ),
          AsyncData() || AsyncError() => MensajePantalla(
            texto: Textos.apelacionNoDisponible,
            textoBoton: Textos.volverAlBuzon,
            alPresionar: _volverAlBuzon,
          ),
          _ => const _EsqueletoJuicio(),
        },
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (hecho, _) {
        if (!hecho) _volverAlBuzon();
      },
      child: AnimatedSwitcher(
        duration: sinAnimaciones ? Duration.zero : PantallaJuicio.duracionCruce,
        child: cuerpo,
      ),
    );
  }
}

class _Juicio extends ConsumerStatefulWidget {
  const _Juicio({
    required this.datos,
    required this.actual,
    required this.total,
    required this.alSalir,
    super.key,
  });

  final DatosJuicio datos;
  final int actual;
  final int total;
  final VoidCallback alSalir;

  @override
  ConsumerState<_Juicio> createState() => _JuicioState();
}

class _JuicioState extends ConsumerState<_Juicio> {
  final _mazo = GlobalKey<MazoSwipeState>();
  final _arrastre = ValueNotifier(const ArrastreVisible());

  /// Cambia tras un error al guardar: la tarjeta vuelve a entrar.
  int _intento = 0;
  bool _resolviendo = false;

  @override
  void dispose() {
    _arrastre.dispose();
    super.dispose();
  }

  Future<void> _alConfirmar(Veredicto veredicto) async {
    if (_resolviendo) return;
    setState(() => _resolviendo = true);
    final datos = widget.datos;
    try {
      await ref
          .read(sesionApelacionesProvider.notifier)
          .resolver(apelacion: datos.apelacion, tarjeta: datos.tarjeta, veredicto: veredicto);
      _vibrar(ganada: LogicaApelacion.gana(datos.tarjeta, veredicto));
    } on Object {
      if (!mounted) return;
      setState(() {
        _resolviendo = false;
        _intento++;
        _arrastre.value = const ArrastreVisible();
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            key: const ValueKey('error-guardar-apelacion'),
            content: Semantics(liveRegion: true, child: const Text(Textos.errorGuardarApelacion)),
          ),
        );
    }
  }

  /// Ganada: vibración suave; perdida: la de error (servicio háptico).
  void _vibrar({required bool ganada}) {
    final haptica = ref.read(servicioHapticoProvider);
    unawaited(ganada ? haptica.suave() : haptica.error());
  }

  /// Flechas: previsualizan; Enter confirma y Esc cancela (como el juego).
  KeyEventResult _alTeclear(FocusNode _, KeyEvent evento) {
    if (evento is! KeyDownEvent && evento is! KeyRepeatEvent) return KeyEventResult.ignored;
    final mazo = _mazo.currentState;
    if (mazo == null || _resolviendo) return KeyEventResult.ignored;
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
    final tokens = context.tokens;
    final estilos = context.estilos;
    final datos = widget.datos;
    final tarjeta = datos.tarjeta;
    final colorModulo = datos.colorModulo ?? tokens.textoAcento;
    final soloBotones = ref.watch(ajustesProvider.select((a) => a.soloBotones));

    final barra = BarraJuicio(
      actual: widget.actual,
      total: widget.total,
      vidas: datos.vidas,
      alSalir: widget.alSalir,
    );
    final altoMinimoZona =
        TarjetaCaso.altoMinimoPara(MediaQuery.textScalerOf(context), conAviso: true) +
        MazoSwipe.altoPila;
    final zonaTarjeta = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: MazoSwipe(
            key: _mazo,
            claveTarjeta: '${datos.apelacion.id}-$_intento',
            restantes: 0,
            arrastre: _arrastre,
            etiquetaSemantica:
                '${Textos.tarjetaApelacionSemantica(widget.actual, widget.total, tarjeta.personaje, tarjeta.rol, tarjeta.texto)} '
                '${Textos.falladaHace(datos.diasDesdeFallo)}.',
            alConfirmar: _alConfirmar,
            arrastreActivo: !soloBotones,
            retenerAlConfirmar: context.clasePantalla.esAncho,
            tarjeta: TarjetaCaso(
              soloBotones: soloBotones,
              etiquetaCaso: LogicaApelacion.etiqueta(datos.apelacion.tema),
              colorModulo: colorModulo,
              iniciales: tarjeta.iniciales ?? LogicaInicio.iniciales(tarjeta.personaje),
              personaje: tarjeta.personaje,
              rol: tarjeta.rol,
              texto: tarjeta.texto,
              aviso: AvisoFallo(dias: datos.diasDesdeFallo),
            ),
          ),
        ),
      ],
    );
    final acciones = AccionesVeredicto(
      alElegir: _resolviendo ? null : (v) => _mazo.currentState?.confirmar(v),
    );
    final nota = Text(
      Textos.notaJuicio,
      key: const ValueKey('nota-juicio'),
      textAlign: TextAlign.center,
      style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
    );

    final contenido = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        barra,
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: altoMinimoZona),
              child: zonaTarjeta,
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: acciones),
        const SizedBox(height: 18),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: nota),
        const SizedBox(height: 16),
      ],
    );

    return Focus(
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
          // T22 (Figma 100:4212): la composición del juego en tablet, con el
          // contexto de la apelación y los atajos en el panel lateral.
          if (context.clasePantalla.esAncho)
            ComposicionJuegoTablet(
              barra: barra,
              zonaTarjeta: zonaTarjeta,
              altoMinimoZona: altoMinimoZona,
              acciones: acciones,
              comodines: nota,
              panel: [
                TarjetaContextoSprint(
                  etiqueta: Textos.contextoApelacion(datos.apelacion.diaRepaso),
                  titulo: datos.apelacion.titulo,
                  objetivo: Textos.contextoApelacionTexto(datos.diasDesdeFallo),
                ),
                const TarjetaAtajos(),
              ],
            )
          else
            SafeArea(
              child: LayoutBuilder(
                builder: (context, restricciones) => SingleChildScrollView(
                  key: const ValueKey('juicio-desplazable'),
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

/// Barra del juicio (Figma 22; alto 56, relleno 20, separación 12): Salir de 48, "Apelación k de n" con su
/// progreso y, a la derecha, la recompensa: "+1 vida" o, con las 5, "Vidas
/// al máximo".
class BarraJuicio extends StatelessWidget {
  const BarraJuicio({
    required this.actual,
    required this.total,
    required this.vidas,
    required this.alSalir,
    super.key,
  });

  final int actual;
  final int total;
  final int vidas;
  final VoidCallback? alSalir;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final alMaximo = vidas >= Vidas.maximo;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Row(
          children: [
            BotonCerrar(alPresionar: alSalir, etiqueta: Textos.salir),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                    child: Text(
                      Textos.apelacionPaso(actual, total),
                      style: context.estilos.leyenda.copyWith(color: tokens.textoSecundario),
                    ),
                  ),
                  const SizedBox(height: 6),
                  BarraProgreso(
                    valor: total == 0 ? 0 : actual / total,
                    etiquetaSemantica: Textos.apelacionPaso(actual, total),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Con texto grande la insignia parte su texto en lugar de empujar
            // la barra fuera de la pantalla (T-13).
            Flexible(
              child: InsigniaVida(
                key: const ValueKey('recompensa-juicio'),
                texto: alMaximo ? Textos.vidasAlMaximo : Textos.masUnaVida,
                destacada: !alMaximo,
                conIcono: true,
                etiquetaSemantica: alMaximo
                    ? Textos.vidasAlMaximoSemantica
                    : Textos.recompensaApelacionSemantica,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 22b (ganada) y la perdida: Sarko sobre fondo/destacado, las vidas tras la
/// apelación, la insignia, el título (con el foco y el anuncio), el texto,
/// los días de repaso y los botones.
class _Resultado extends StatefulWidget {
  const _Resultado({
    required this.sesion,
    required this.alSiguiente,
    required this.alVolver,
    super.key,
  });

  final SesionApelaciones sesion;
  final VoidCallback alSiguiente;
  final VoidCallback alVolver;

  @override
  State<_Resultado> createState() => _ResultadoState();
}

class _ResultadoState extends State<_Resultado> {
  final _focoTitulo = FocusNode(debugLabel: 'título del resultado');

  @override
  void initState() {
    super.initState();
    // El juicio tenía el foco (autofocus no lo quita): el título lo pide
    // tras el primer cuadro.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focoTitulo.requestFocus();
    });
  }

  @override
  void dispose() {
    _focoTitulo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sesion = widget.sesion;
    final alSiguiente = widget.alSiguiente;
    final alVolver = widget.alVolver;
    final tokens = context.tokens;
    final estilos = context.estilos;
    final resultado = sesion.resultado!;
    final ganada = resultado.ganada;
    final antes = sesion.vidasAntes ?? 0;
    final despues = sesion.vidasDespues ?? antes;
    final recuperada = despues > antes;
    final insignia = recuperada
        ? Textos.vidaRecuperadaInsignia
        : ganada
        ? Textos.vidasAlMaximo
        : Textos.noPierdesVidas;
    final titulo = ganada ? Textos.apelacionGanadaTitulo : Textos.apelacionPerdidaTitulo;

    final textoResultado = ElementoOrdenado(
      orden: 4,
      child: Text(
        LogicaApelacion.texto(sesion.tarjeta!, resultado),
        key: const ValueKey('texto-resultado'),
        textAlign: TextAlign.center,
        style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
      ),
    );
    final repaso = ElementoOrdenado(
      orden: 5,
      child: FilaRepaso(
        hechos: LogicaApelacion.hechos(sesion.apelacion!.diaRepaso, ganada: ganada),
      ),
    );
    final tituloResultado = ElementoOrdenado(
      orden: 1,
      child: BloqueLectura(
        key: const ValueKey('titulo-resultado-apelacion'),
        encabezado: true,
        enVivo: true,
        autofocus: true,
        radio: 8,
        etiqueta: Textos.anuncioApelacion(titulo, insignia, despues),
        excluirHijos: true,
        nodoFoco: _focoTitulo,
        child: Text(
          titulo,
          textAlign: TextAlign.center,
          style: estilos.h1.copyWith(color: tokens.textoPrimario),
        ),
      ),
    );
    return ColumnaFinSprint(
      // T22b (Figma 100:4281): Sarko, las vidas y la insignia × 1.6 a la
      // izquierda; título, texto, días de repaso y botones a la derecha.
      ilustracionTablet: IlustracionAmpliada(
        anchoBase: 240,
        escala: 1.6,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IlustracionSarko(
              pose: ganada ? PoseSarko.alegre : PoseSarko.triste,
              diametro: 230,
              anchoSarko: 184,
              colorFondo: tokens.fondoDestacado,
            ),
            const SizedBox(height: 16),
            ElementoOrdenado(
              orden: 2,
              child: FilaVidas(
                key: const ValueKey('vidas-resultado'),
                cantidad: despues,
                tamano: 31.2,
                hueco: 10.4,
              ),
            ),
            const SizedBox(height: 12),
            ElementoOrdenado(
              orden: 3,
              child: InsigniaVida(
                key: const ValueKey('insignia-resultado'),
                texto: insignia,
                destacada: recuperada,
                grande: true,
              ),
            ),
          ],
        ),
      ),
      contenidoTablet: [
        tituloResultado,
        const SizedBox(height: 16),
        textoResultado,
        const SizedBox(height: 16),
        Center(child: repaso),
      ],
      contenido: [
        const SizedBox(height: 20),
        IlustracionSarko(
          pose: ganada ? PoseSarko.alegre : PoseSarko.triste,
          diametro: 230,
          anchoSarko: 184,
          colorFondo: tokens.fondoDestacado,
        ),
        const SizedBox(height: 16),
        ElementoOrdenado(
          orden: 2,
          child: FilaVidas(
            key: const ValueKey('vidas-resultado'),
            cantidad: despues,
            tamano: 31.2,
            hueco: 10.4,
          ),
        ),
        const SizedBox(height: 12),
        ElementoOrdenado(
          orden: 3,
          child: InsigniaVida(
            key: const ValueKey('insignia-resultado'),
            texto: insignia,
            destacada: recuperada,
            grande: true,
          ),
        ),
        const SizedBox(height: 16),
        tituloResultado,
        const SizedBox(height: 8),
        textoResultado,
        const SizedBox(height: 18),
        repaso,
      ],
      botones: [
        if (sesion.esUltima)
          ElementoOrdenado(
            orden: 6,
            child: BotonApp(
              key: const ValueKey('boton-volver-buzon'),
              texto: Textos.volverAlBuzon,
              alPresionar: alVolver,
            ),
          )
        else ...[
          ElementoOrdenado(
            orden: 6,
            child: BotonApp(
              key: const ValueKey('boton-siguiente-apelacion'),
              texto: Textos.siguienteApelacion,
              alPresionar: alSiguiente,
            ),
          ),
          const SizedBox(height: 8),
          ElementoOrdenado(
            orden: 7,
            child: BotonApp(
              key: const ValueKey('boton-volver-buzon'),
              texto: Textos.volverAlBuzon,
              tipo: TipoBoton.fantasma,
              altoMinimo: 48,
              alPresionar: alVolver,
            ),
          ),
        ],
      ],
    );
  }
}

/// Esqueleto con las medidas de la barra, la tarjeta y las acciones.
class _EsqueletoJuicio extends StatelessWidget {
  const _EsqueletoJuicio();

  @override
  Widget build(BuildContext context) {
    final color = context.tokens.fondoSuperficieAlt;
    Widget bloque(double alto, {double radio = 16}) => Container(
      height: alto,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radio)),
    );
    return Semantics(
      label: Textos.cargandoApelacion,
      liveRegion: true,
      excludeSemantics: true,
      child: SafeArea(
        child: SingleChildScrollView(
          key: const ValueKey('esqueleto-juicio'),
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 4),
              bloque(48, radio: 12),
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
