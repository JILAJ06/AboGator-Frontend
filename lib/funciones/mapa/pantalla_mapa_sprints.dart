import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/semantics.dart' show OrdinalSortKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/marco_principal.dart';
import '../../app/rutas.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/camino_sprints.dart';
import '../../componentes/encabezado_modulo.dart';
import '../../componentes/esqueleto_pantalla.dart';
import '../../componentes/globo_sprint_actual.dart';
import '../../componentes/mensaje_pantalla.dart';
import '../../componentes/navegacion_inferior_app.dart';
import '../../componentes/nodo_sprint.dart';
import '../../componentes/sarko_imagen.dart';
import '../../componentes/vista_asincrona.dart';
import '../../core/adaptativo/clase_pantalla.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/modulo.dart';
import '../inicio/logica_inicio.dart';
import 'detalle_sprint.dart';
import 'estado_mapa.dart';
import 'logica_mapa.dart';

/// Pantalla 08 · Mapa de sprints de un módulo (Figma 13:562).
///
/// Encabezado fijo del color del módulo y, debajo, el mapa que se desplaza:
/// nodos en zigzag unidos por el camino, el globo del sprint actual con
/// "Comenzar" y Sarko junto al nodo actual. Navegación inferior con "Mapa"
/// activo y el Buzón fijo, como en el Inicio.
class PantallaMapaSprints extends ConsumerWidget {
  const PantallaMapaSprints({required this.moduloId, this.sprintId, super.key});

  final String moduloId;

  /// Sprint que queda seleccionado en tablet horizontal (la ruta de la intro
  /// muestra esta vista con ese sprint, T08). `null` en la ruta del mapa.
  final String? sprintId;

  /// Orden de foco: atrás (0), nodos (1 a 6), "Comenzar" y luego el Buzón.
  /// En tablet, el botón del detalle va al final.
  static const double ordenAtras = 0;
  static const double ordenComenzar = 100;
  static const double ordenDetalle = 200;

  void _volverAlInicio(BuildContext context) {
    // Desde la ruta de la intro (tablet) "atrás" va al Inicio, no al mapa.
    if (sprintId != null) {
      context.go(Rutas.inicio);
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Rutas.inicio);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(datosModuloProvider(moduloId));
    final valor = datos.value;
    final modulo = valor?.modulo;

    return MarcoPrincipal(
      pestana: PestanaApp.mapa,
      apelacionesPendientes: modulo == null ? null : valor?.apelacionesPendientes,
      focoOrdenado: true,
      cuerpo: VistaAsincrona(
        valor: datos,
        datos: (valor) => switch (valor) {
          DatosModulo(modulo: final Modulo modulo, :final vidas)
              when context.clasePantalla.esAncho =>
            _MapaConDetalle(
              modulo: modulo,
              vidas: vidas.cantidad,
              sprintInicial: sprintId,
              alAtras: () => _volverAlInicio(context),
            ),
          DatosModulo(modulo: final Modulo modulo, :final vidas) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FocusTraversalOrder(
                order: const NumericFocusOrder(ordenAtras),
                child: EncabezadoModulo(
                  numero: modulo.numero,
                  nombreCorto: LogicaInicio.nombreCorto(modulo),
                  titulo: LogicaInicio.tramo(modulo),
                  color: modulo.color,
                  vidas: vidas.cantidad,
                  completados: LogicaInicio.completados(modulo),
                  total: LogicaInicio.totalSprints(modulo),
                  alAtras: () => _volverAlInicio(context),
                ),
              ),
              Expanded(child: MapaSprints(modulo: modulo)),
            ],
          ),
          _ => MensajePantalla(
            texto: Textos.moduloNoEncontrado,
            textoBoton: Textos.volverAlInicio,
            alPresionar: () => context.go(Rutas.inicio),
          ),
        },
        textoError: Textos.mapaErrorCarga,
        alReintentar: () => ref.invalidate(datosModuloProvider(moduloId)),
        esqueleto: const _EsqueletoMapa(),
      ),
    );
  }
}

/// Mapa que se desplaza: una columna de filas (nodo, globo del sprint actual,
/// nodo…) con el camino pintado detrás. Los centros de los nodos se miden
/// después de cada diseño para que el camino siempre pase por ellos, con
/// cualquier ancho o tamaño de texto.
class MapaSprints extends StatefulWidget {
  const MapaSprints({
    required this.modulo,
    this.escala = 1,
    this.conGlobo = true,
    this.seleccionado,
    this.alSeleccionar,
    super.key,
  });

  final Modulo modulo;

  /// Escala del mapa (tablet: 1.12). Se dibuja a [anchoBase] y se amplía
  /// centrado; los centros del camino se miden en el mapa sin escalar.
  final double escala;

  /// Sin globo (tablet), su lugar queda vacío como en Figma T08.
  final bool conGlobo;

  /// Id del sprint seleccionado (tablet); `null` en móvil.
  final String? seleccionado;

  /// Con valor, tocar un sprint completado o en curso lo selecciona en lugar
  /// de abrir la intro (tablet). El Examen final sigue abriendo la crisis.
  final ValueChanged<Sprint>? alSeleccionar;

  /// Ancho del marco móvil de Figma.
  static const double anchoBase = 390;

  /// Arriba del mapa escalado (Figma T08: el camino empieza en y 10 y el primer
  /// nodo 22.4 más abajo).
  static const double margenSuperiorEscalado = 10;
  static const double margenInternoEscalado = 20;

  /// Medidas de Figma (marco 390, el encabezado termina en 150).
  static const double margenSuperior = 50;
  static const double separacionAntesDelActual = 14;
  static const double separacionDespuesDelActual = 24;
  static const double separacionGlobo = 10;
  static const double margenInferior = 94;

  /// Margen lateral mínimo de etiquetas y globo.
  static const double margenLateral = 16;

  /// Separación entre el nodo y su etiqueta.
  static const double separacionEtiqueta = 8;

  /// La etiqueta empieza a 30 de la parte de arriba del nodo.
  static const double arribaEtiqueta = 30;

  /// Sarko alegre de 88×110, a 119 del borde izquierdo del nodo actual y 30
  /// por encima (en Figma: (262, 410) con el nodo en (143, 440)).
  static const double anchoSarko = 88;
  static const double desplazamientoSarko = 119;
  static const double arribaSarko = -30;

  @override
  State<MapaSprints> createState() => _MapaSprintsState();
}

class _MapaSprintsState extends State<MapaSprints> {
  final _claveContenido = GlobalKey();
  final _controlador = ScrollController();
  late List<GlobalKey> _clavesNodos;
  List<Offset> _puntos = const [];
  bool _desplazado = false;

  @override
  void initState() {
    super.initState();
    _crearClaves();
  }

  @override
  void didUpdateWidget(MapaSprints anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.modulo.sprints.length != widget.modulo.sprints.length) _crearClaves();
  }

  void _crearClaves() {
    _clavesNodos = [for (final _ in widget.modulo.sprints) GlobalKey()];
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  /// Mide los centros de las caras y, la primera vez, deja a la vista el
  /// sprint actual.
  void _despuesDelDiseno(Duration _) {
    if (!mounted) return;
    final contenido = _claveContenido.currentContext?.findRenderObject() as RenderBox?;
    if (contenido == null || !contenido.hasSize) return;
    final puntos = <Offset>[];
    for (final (i, sprint) in widget.modulo.sprints.indexed) {
      final caja = _clavesNodos[i].currentContext?.findRenderObject() as RenderBox?;
      if (caja == null || !caja.hasSize) return;
      final centro = LogicaMapa.tipoNodo(sprint).centroCara;
      puntos.add(caja.localToGlobal(centro, ancestor: contenido));
    }
    if (!listEquals(puntos, _puntos)) setState(() => _puntos = puntos);

    if (!_desplazado) {
      _desplazado = true;
      final actual = LogicaMapa.sprintActual(widget.modulo);
      if (actual == null) return;
      final i = widget.modulo.sprints.indexOf(actual.sprint);
      final contexto = _clavesNodos[i].currentContext;
      if (contexto != null) {
        Scrollable.ensureVisible(contexto, alignment: 0.2);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(_despuesDelDiseno);
    final modulo = widget.modulo;
    final actual = LogicaMapa.sprintActual(modulo);
    final indiceActual = actual == null ? -1 : modulo.sprints.indexOf(actual.sprint);

    final filas = <Widget>[];
    var indiceNormal = 0;
    for (final (i, sprint) in modulo.sprints.indexed) {
      if (i > 0) {
        final despuesDelActual = indiceActual >= 0 && i > indiceActual;
        filas.add(
          SizedBox(
            height: despuesDelActual
                ? MapaSprints.separacionDespuesDelActual
                : MapaSprints.separacionAntesDelActual,
          ),
        );
      }
      final fraccion = LogicaMapa.fraccionX(indiceNormal, esExamenFinal: sprint.esExamenFinal);
      if (!sprint.esExamenFinal) indiceNormal++;
      final esActual = i == indiceActual;
      filas.add(
        _FilaNodo(
          clave: _clavesNodos[i],
          modulo: modulo,
          sprint: sprint,
          fraccion: fraccion,
          orden: i + 1,
          esActual: esActual,
          seleccionado: widget.alSeleccionar == null ? null : sprint.id == widget.seleccionado,
          alSeleccionar: widget.alSeleccionar,
        ),
      );
      if (esActual) {
        filas.add(
          Padding(
            padding: const EdgeInsets.only(
              top: MapaSprints.separacionGlobo,
              bottom: MapaSprints.separacionAntesDelActual,
            ),
            child: _FilaGlobo(
              visible: widget.conGlobo,
              fraccion: fraccion,
              globo: FocusTraversalOrder(
                order: const NumericFocusOrder(PantallaMapaSprints.ordenComenzar),
                child: Semantics(
                  container: true,
                  sortKey: const OrdinalSortKey(PantallaMapaSprints.ordenComenzar),
                  child: GloboSprintActual(
                    titulo: Textos.globoTitulo(actual!.numero, sprint.titulo),
                    detalle: Textos.globoDetalle(sprint.numeroTarjetas, sprint.minutosEstimados),
                    alComenzar: () => context.go(Rutas.introSprintDe(modulo.id, sprint.id)),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    // Con el riel (tablet) no hay botón Buzón flotante: no se reserva su lugar.
    final reserva = MarcoPrincipal.conRiel(context) ? 0.0 : MarcoPrincipal.reservaBuzon;
    final contenido = Stack(
      key: _claveContenido,
      children: [
        Positioned.fill(child: CaminoSprints(puntos: _puntos)),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: filas),
      ],
    );
    if (widget.escala == 1) {
      return SingleChildScrollView(
        key: const ValueKey('mapa-sprints'),
        controller: _controlador,
        padding: EdgeInsets.only(
          top: MapaSprints.margenSuperior,
          bottom: MapaSprints.margenInferior + reserva,
        ),
        child: contenido,
      );
    }
    return SingleChildScrollView(
      key: const ValueKey('mapa-sprints'),
      controller: _controlador,
      padding: const EdgeInsets.only(top: MapaSprints.margenSuperiorEscalado),
      child: Center(
        child: SizedBox(
          key: const ValueKey('mapa-escalado'),
          width: MapaSprints.anchoBase * widget.escala,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: MapaSprints.anchoBase,
              child: Padding(
                padding: EdgeInsets.only(
                  top: MapaSprints.margenInternoEscalado,
                  bottom: MapaSprints.margenInferior + reserva,
                ),
                child: contenido,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fila de un nodo: el nodo en su posición del zigzag y, a un lado, su
/// etiqueta ("Sprint N" y título). Junto al nodo actual va Sarko en lugar de
/// la etiqueta (su título está en el globo).
class _FilaNodo extends StatelessWidget {
  const _FilaNodo({
    required this.clave,
    required this.modulo,
    required this.sprint,
    required this.fraccion,
    required this.orden,
    required this.esActual,
    this.seleccionado,
    this.alSeleccionar,
  });

  final GlobalKey clave;
  final bool? seleccionado;
  final ValueChanged<Sprint>? alSeleccionar;
  final Modulo modulo;
  final Sprint sprint;
  final double fraccion;
  final int orden;
  final bool esActual;

  void _abrir(BuildContext context) {
    final seleccionar = alSeleccionar;
    if (seleccionar != null && !sprint.esExamenFinal) {
      seleccionar(sprint);
      return;
    }
    if (sprint.esExamenFinal) {
      context.push(Rutas.crisisJefeDe(modulo.id));
    } else {
      context.go(Rutas.introSprintDe(modulo.id, sprint.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipo = LogicaMapa.tipoNodo(sprint);
    final abre = LogicaMapa.puedeAbrir(modulo, sprint);

    return LayoutBuilder(
      builder: (context, restricciones) {
        final ancho = restricciones.maxWidth;
        final izquierdaNodo = (ancho * fraccion - tipo.ancho / 2).clamp(0.0, ancho - tipo.ancho);
        final nodo = Positioned(
          left: izquierdaNodo,
          top: 0,
          child: FocusTraversalOrder(
            order: NumericFocusOrder(orden.toDouble()),
            child: Semantics(
              container: true,
              sortKey: OrdinalSortKey(orden.toDouble()),
              child: NodoSprint(
                key: clave,
                tipo: tipo,
                estrellas: sprint.estrellas,
                etiquetaSemantica: LogicaMapa.semanticaNodo(modulo, sprint),
                seleccionado: seleccionado,
                alPresionar: abre ? () => _abrir(context) : null,
              ),
            ),
          ),
        );

        final Widget lado;
        if (esActual) {
          lado = _sarko(ancho, izquierdaNodo, tipo);
        } else {
          lado = _etiqueta(context, ancho, izquierdaNodo, tipo);
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(width: ancho, height: tipo.alto),
            lado,
            nodo,
          ],
        );
      },
    );
  }

  Widget _etiqueta(BuildContext context, double ancho, double izquierdaNodo, TipoNodoSprint tipo) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final bloqueado = !LogicaMapa.puedeAbrir(modulo, sprint);
    final aLaIzquierda = LogicaMapa.etiquetaALaIzquierda(fraccion);
    final alineacion = aLaIzquierda ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textoAlineado = aLaIzquierda ? TextAlign.right : TextAlign.left;
    final relleno = aLaIzquierda
        ? EdgeInsets.only(
            left: MapaSprints.margenLateral,
            right: ancho - izquierdaNodo + MapaSprints.separacionEtiqueta,
            top: MapaSprints.arribaEtiqueta,
          )
        : EdgeInsets.only(
            left: izquierdaNodo + tipo.ancho + MapaSprints.separacionEtiqueta,
            right: MapaSprints.margenLateral,
            top: MapaSprints.arribaEtiqueta,
          );

    return ExcludeSemantics(
      child: Padding(
        padding: relleno,
        child: Align(
          alignment: aLaIzquierda ? Alignment.topRight : Alignment.topLeft,
          child: Column(
            key: ValueKey('etiqueta-${sprint.id}'),
            crossAxisAlignment: alineacion,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LogicaMapa.nombreNodo(modulo, sprint),
                textAlign: textoAlineado,
                style: estilos.etiqueta.copyWith(
                  color: bloqueado && !sprint.esExamenFinal
                      ? tokens.textoSecundario
                      : tokens.textoPrimario,
                ),
              ),
              Text(
                sprint.titulo,
                textAlign: textoAlineado,
                style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Sarko a la derecha del nodo actual; si no cabe, a la izquierda; si
  /// tampoco, no se muestra.
  Widget _sarko(double ancho, double izquierdaNodo, TipoNodoSprint tipo) {
    var izquierda = izquierdaNodo + MapaSprints.desplazamientoSarko;
    if (izquierda + MapaSprints.anchoSarko > ancho - MapaSprints.margenLateral / 2) {
      izquierda =
          izquierdaNodo - MapaSprints.desplazamientoSarko + tipo.ancho - MapaSprints.anchoSarko;
    }
    if (izquierda < 0) return const SizedBox.shrink();
    return Positioned(
      left: izquierda,
      top: MapaSprints.arribaSarko,
      child: const SarkoImagen(
        key: ValueKey('sarko-mapa'),
        pose: PoseSarko.alegre,
        ancho: MapaSprints.anchoSarko,
        decorativa: true,
      ),
    );
  }
}

/// Fila del globo, centrado bajo el nodo actual (sin salirse de los márgenes).
class _FilaGlobo extends StatelessWidget {
  const _FilaGlobo({required this.fraccion, required this.globo, this.visible = true});

  final double fraccion;
  final Widget globo;

  /// Oculto (tablet) conserva su lugar, como en Figma T08.
  final bool visible;

  /// Si el espacio centrado bajo el nodo es menor, el globo se centra en la pantalla.
  static const double anchoMinimo = 260;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final ancho = restricciones.maxWidth;
        final centro = ancho * fraccion;
        // Área simétrica alrededor del centro del nodo.
        final mitad = math.min(centro, ancho - centro);
        final usaCentroDelNodo = mitad * 2 >= anchoMinimo;
        final relleno = usaCentroDelNodo
            ? EdgeInsets.only(left: centro - mitad, right: ancho - centro - mitad)
            : const EdgeInsets.symmetric(horizontal: MapaSprints.margenLateral);
        return Padding(
          padding: relleno,
          child: Padding(
            padding: usaCentroDelNodo
                ? const EdgeInsets.symmetric(horizontal: MapaSprints.margenLateral)
                : EdgeInsets.zero,
            child: Center(
              child: Visibility(
                visible: visible,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: globo,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Mapa de sprints con el detalle del sprint en tablet horizontal (T08, Figma
/// 96:582): a la izquierda (596 de 1090) el encabezado del módulo y el mapa
/// × 1.12 centrado; a la derecha (494) el panel "Detalle del sprint".
///
/// Tocar un sprint completado o en curso lo **selecciona** y cambia el detalle
/// sin navegar; los bloqueados no hacen nada y el Examen final habilitado abre
/// la crisis, como en móvil.
class _MapaConDetalle extends ConsumerStatefulWidget {
  const _MapaConDetalle({
    required this.modulo,
    required this.vidas,
    required this.sprintInicial,
    required this.alAtras,
  });

  final Modulo modulo;
  final int vidas;
  final String? sprintInicial;
  final VoidCallback alAtras;

  /// Proporción de los paneles en Figma (596 y 494).
  static const int flexMapa = 596;
  static const int flexDetalle = 494;

  /// Escala del mapa del móvil en tablet (nodos de 72 → 80.64).
  static const double escalaMapa = 1.12;

  @override
  ConsumerState<_MapaConDetalle> createState() => _MapaConDetalleState();
}

class _MapaConDetalleState extends ConsumerState<_MapaConDetalle> {
  late String? _seleccionado = LogicaMapa.seleccionInicial(
    widget.modulo,
    sprintId: widget.sprintInicial,
  )?.id;

  @override
  void didUpdateWidget(_MapaConDetalle anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.sprintInicial != widget.sprintInicial) {
      _seleccionado = LogicaMapa.seleccionInicial(
        widget.modulo,
        sprintId: widget.sprintInicial,
      )?.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final modulo = widget.modulo;
    final id = _seleccionado;
    final sprint = id == null ? null : LogicaMapa.sprintPorId(modulo, id);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: _MapaConDetalle.flexMapa,
          child: Column(
            key: const ValueKey('panel-mapa'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FocusTraversalOrder(
                order: const NumericFocusOrder(PantallaMapaSprints.ordenAtras),
                child: EncabezadoModulo(
                  numero: modulo.numero,
                  nombreCorto: LogicaInicio.nombreCorto(modulo),
                  titulo: LogicaInicio.tramo(modulo),
                  color: modulo.color,
                  vidas: widget.vidas,
                  completados: LogicaInicio.completados(modulo),
                  total: LogicaInicio.totalSprints(modulo),
                  alAtras: widget.alAtras,
                  arribaMinimo: EncabezadoModulo.arribaTablet,
                  abajoExtra: EncabezadoModulo.abajoTablet,
                ),
              ),
              Expanded(
                child: MapaSprints(
                  modulo: modulo,
                  escala: _MapaConDetalle.escalaMapa,
                  conGlobo: false,
                  seleccionado: id,
                  alSeleccionar: (s) => setState(() => _seleccionado = s.id),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: _MapaConDetalle.flexDetalle,
          child: _PanelDetalle(modulo: modulo, sprint: sprint),
        ),
      ],
    );
  }
}

/// Panel derecho "Detalle del sprint" (Figma 96:844): fondo/superficie, borde
/// izquierdo de 1 y una columna de 430 centrada (también en alto) con el
/// detalle compartido con la intro y "Comenzar sprint". Se desplaza si no cabe.
class _PanelDetalle extends ConsumerWidget {
  const _PanelDetalle({required this.modulo, required this.sprint});

  static const double anchoColumna = 430;
  static const double relleno = 24;

  final Modulo modulo;
  final Sprint? sprint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final elegido = sprint;
    return DecoratedBox(
      key: const ValueKey('panel-detalle'),
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        border: Border(left: BorderSide(color: tokens.bordeDefault)),
      ),
      child: SafeArea(
        left: false,
        child: LayoutBuilder(
          builder: (context, restricciones) => SingleChildScrollView(
            key: const ValueKey('detalle-desplazable'),
            padding: const EdgeInsets.symmetric(horizontal: relleno, vertical: relleno),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: math.max(0, restricciones.maxHeight - 2 * relleno),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: anchoColumna),
                  child: elegido == null
                      ? const SizedBox.shrink()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Anuncia la selección cada vez que cambia.
                            Semantics(
                              key: ValueKey('anuncio-${elegido.id}'),
                              liveRegion: true,
                              label: LogicaMapa.anuncioSeleccion(modulo, elegido),
                              child: const SizedBox.shrink(),
                            ),
                            DetalleSprint(
                              key: ValueKey('detalle-${elegido.id}'),
                              modulo: modulo,
                              sprint: elegido,
                              disposicion: DisposicionDetalle.panel,
                            ),
                            const SizedBox(height: 14),
                            FocusTraversalOrder(
                              order: const NumericFocusOrder(PantallaMapaSprints.ordenDetalle),
                              child: BotonApp(
                                key: const ValueKey('comenzar-detalle'),
                                texto: Textos.comenzarSprint,
                                alPresionar: LogicaMapa.puedeAbrir(modulo, elegido)
                                    ? () => comenzarSprint(context, ref, modulo, elegido)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Esqueleto con las medidas del encabezado y de los primeros nodos.
class _EsqueletoMapa extends StatelessWidget {
  const _EsqueletoMapa();

  @override
  Widget build(BuildContext context) {
    final color = context.tokens.fondoSuperficieAlt;
    final arriba = math.max(MediaQuery.paddingOf(context).top, EncabezadoModulo.altoBarraEstado);
    Widget circulo(double lado) => Container(
      width: lado,
      height: lado,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );

    return EsqueletoPantalla(
      etiqueta: Textos.cargandoMapa,
      clave: const ValueKey('esqueleto-mapa'),
      alineacion: CrossAxisAlignment.stretch,
      hijos: [
        Container(height: arriba + EncabezadoModulo.altoContenido, color: color),
        const SizedBox(height: MapaSprints.margenSuperior + 10),
        LayoutBuilder(
          builder: (context, restricciones) {
            final ancho = restricciones.maxWidth;
            return Column(
              children: [
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      left: (ancho * LogicaMapa.fraccionX(i, esExamenFinal: false) - 36).clamp(
                        0.0,
                        ancho - 72,
                      ),
                      bottom: 48,
                    ),
                    child: Align(alignment: Alignment.centerLeft, child: circulo(72)),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
