import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/marco_principal.dart';
import '../../app/rutas.dart';
import '../../componentes/bloque_lectura.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/fila_apelacion.dart';
import '../../componentes/mensaje_pantalla.dart';
import '../../componentes/navegacion_inferior_app.dart';
import '../../componentes/piezas_apelacion.dart';
import '../../componentes/sarko_imagen.dart';
import '../../componentes/tarjeta_caso.dart';
import '../../core/adaptativo/clase_pantalla.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/apelacion.dart';
import '../../datos/modelos/buzon_apelaciones.dart';
import '../../datos/modelos/tarjeta.dart';
import '../../datos/repositorios/proveedores_repositorios.dart';
import '../inicio/logica_inicio.dart';
import 'logica_apelacion.dart';
import 'sesion_apelaciones.dart';

/// Lo que necesita el Buzón: el Buzón del servidor y el color de cada módulo.
class DatosBuzon {
  const DatosBuzon({required this.buzon, this.coloresModulo = const {}});

  final BuzonApelaciones buzon;
  final Map<String, Color> coloresModulo;
}

/// Carga el Buzón y los módulos (para el color de las franjas). Para
/// reintentar: `ref.invalidate(datosBuzonProvider)`.
final datosBuzonProvider = FutureProvider.autoDispose<DatosBuzon>((ref) async {
  final (buzon, modulos) = await (
    ref.watch(repositorioApelacionesProvider).obtenerBuzon(),
    ref.watch(repositorioProgresoProvider).obtenerModulos(),
  ).wait;
  return DatosBuzon(buzon: buzon, coloresModulo: {for (final m in modulos) m.id: m.color});
});

/// Pantalla 21 · Buzón de Apelaciones (Figma 41:5631), en la pestaña Buzón.
///
/// Título, subtítulo y Sarko; la recompensa con las de hoy; la lista (las de
/// hoy abren el juicio, las futuras avisan cuándo se abren) y, fijos encima de
/// la barra, "Iniciar apelaciones de hoy" y su nota. Los plazos salen de la
/// fecha del servidor. Con el Buzón vacío muestra un estado propio.
class PantallaBuzon extends ConsumerWidget {
  const PantallaBuzon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(datosBuzonProvider);
    return MarcoPrincipal(
      pestana: PestanaApp.buzon,
      cuerpo: SafeArea(
        bottom: false,
        child: switch (datos) {
          AsyncData(:final value) when value.buzon.total == 0 => const _UnaColumna(
            child: _BuzonVacio(),
          ),
          // T21 (tablet horizontal): lista-detalle.
          AsyncData(:final value) when context.clasePantalla.esAncho => _BuzonTablet(datos: value),
          AsyncData(:final value) => _UnaColumna(child: _Buzon(datos: value)),
          AsyncError() => MensajePantalla(
            texto: Textos.buzonErrorCarga,
            textoBoton: Textos.reintentar,
            alPresionar: () => ref.invalidate(datosBuzonProvider),
          ),
          _ => const _EsqueletoBuzon(),
        },
      ),
    );
  }
}

/// Título "Buzón de Apelaciones" (H1): encabezado con el foco al abrir.
class _Titulo extends StatelessWidget {
  const _Titulo();

  @override
  Widget build(BuildContext context) => BloqueLectura(
    key: const ValueKey('titulo-buzon'),
    encabezado: true,
    autofocus: true,
    radio: 8,
    child: Text(
      Textos.buzonTitulo,
      style: context.estilos.h1.copyWith(color: context.tokens.textoPrimario),
    ),
  );
}

class _Buzon extends ConsumerWidget {
  const _Buzon({required this.datos});

  final DatosBuzon datos;

  static const double anchoSarko = 104;

  /// Empieza una sesión con [ids] y abre el juicio de la primera.
  static void _iniciar(BuildContext context, WidgetRef ref, List<String> ids) {
    ref.read(sesionApelacionesProvider.notifier).iniciar(ids);
    context.go(Rutas.juicioApelacionDe(ids.first));
  }

  static void _abrir(BuildContext context, WidgetRef ref, Apelacion a, int dias) {
    if (dias <= 0) {
      _iniciar(context, ref, [a.id]);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: const ValueKey('aviso-apelacion-futura'),
          content: Semantics(liveRegion: true, child: Text(Textos.avisoApelacionFutura(dias))),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final buzon = datos.buzon;
    final deHoy = buzon.deHoy;
    final apelaciones = buzon.apelaciones;

    final encabezado = ConstrainedBox(
      // Sarko (130 de alto, 10 por encima del título) no toca la recompensa.
      constraints: const BoxConstraints(minHeight: 120),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Sarko va detrás: el título pasa por delante de su borde, como en
          // Figma (título de 260 desde x 24 y Sarko desde x 262).
          const Positioned(
            right: 0,
            top: -10,
            child: SarkoImagen(pose: PoseSarko.alegre, ancho: anchoSarko, decorativa: true),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Titulo(),
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 230),
                child: Text(
                  Textos.buzonSubtitulo,
                  style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final lista = Semantics(
      container: true,
      label: Textos.listaApelaciones(apelaciones.length),
      child: Container(
        key: const ValueKey('lista-apelaciones'),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: tokens.fondoSuperficie,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: tokens.bordeDefault),
        ),
        child: Column(
          children: [
            for (final (i, a) in apelaciones.indexed) ...[
              if (i > 0) Divider(height: 1, thickness: 1, color: tokens.bordeDefault),
              FilaApelacion(
                key: ValueKey('fila-${a.id}'),
                titulo: a.titulo,
                tema: a.tema,
                dia: a.diaRepaso,
                dias: buzon.diasHasta(a),
                colorModulo: datos.coloresModulo[a.moduloId] ?? tokens.bordeControl,
                alPresionar: () => _abrir(context, ref, a, buzon.diasHasta(a)),
              ),
            ],
          ],
        ),
      ),
    );

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            key: const ValueKey('buzon-desplazable'),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                encabezado,
                const SizedBox(height: 12),
                TarjetaRecompensaBuzon(deHoy: deHoy.length),
                const SizedBox(height: 12),
                lista,
              ],
            ),
          ),
        ),
        // Fijos encima de la barra inferior.
        Padding(
          key: const ValueKey('acciones-buzon'),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BotonApp(
                texto: Textos.iniciarApelacionesHoy,
                alPresionar: deHoy.isEmpty
                    ? null
                    : () => _iniciar(context, ref, [for (final a in deHoy) a.id]),
              ),
              const SizedBox(height: 8),
              Text(
                Textos.notaApelaciones,
                textAlign: TextAlign.center,
                style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tarjeta de una apelación (para la vista previa del juicio en tablet, también
/// de las que aún no se abren).
final tarjetaApelacionProvider = FutureProvider.autoDispose.family<Tarjeta, String>(
  (ref, tarjetaId) => ref.watch(repositorioTarjetasProvider).obtenerTarjeta(tarjetaId),
);

/// Buzón en tablet horizontal (T21, Figma `100:4028`): lista-detalle. A la
/// izquierda (500 de 1058) el título, la recompensa, la lista y "Iniciar
/// apelaciones de hoy"; a la derecha (526) la vista previa del juicio de la
/// apelación **seleccionada** (la primera al abrir). Tocar una fila la
/// selecciona; las flechas arriba y abajo recorren la lista.
class _BuzonTablet extends ConsumerStatefulWidget {
  const _BuzonTablet({required this.datos});

  final DatosBuzon datos;

  static const int flexLista = 500;
  static const int flexDetalle = 526;

  @override
  ConsumerState<_BuzonTablet> createState() => _BuzonTabletState();
}

class _BuzonTabletState extends ConsumerState<_BuzonTablet> {
  String? _seleccionada;
  final Map<String, FocusNode> _focos = {};

  FocusNode _foco(String id) => _focos.putIfAbsent(id, () => FocusNode(debugLabel: id));

  @override
  void dispose() {
    for (final f in _focos.values) {
      f.dispose();
    }
    super.dispose();
  }

  Apelacion? get _actual {
    final apelaciones = widget.datos.buzon.apelaciones;
    if (apelaciones.isEmpty) return null;
    return apelaciones.where((a) => a.id == _seleccionada).firstOrNull ?? apelaciones.first;
  }

  void _seleccionar(Apelacion a) {
    // La fila elegida toma el foco, así las flechas siguen desde ella.
    _foco(a.id).requestFocus();
    // Volver a elegir la que ya está seleccionada (o topar con el extremo de
    // la lista con las flechas) no repite el anuncio: uno por cambio real
    // (T-13).
    if (a.id == _actual?.id) return;
    setState(() => _seleccionada = a.id);
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        Textos.juicioSeleccionado(a.titulo),
        TextDirection.ltr,
      ),
    );
  }

  /// Flechas arriba y abajo: mueven la selección (y el foco) por la lista.
  KeyEventResult _alTeclear(FocusNode _, KeyEvent evento) {
    if (evento is! KeyDownEvent && evento is! KeyRepeatEvent) return KeyEventResult.ignored;
    final paso = switch (evento.logicalKey) {
      LogicalKeyboardKey.arrowDown => 1,
      LogicalKeyboardKey.arrowUp => -1,
      _ => 0,
    };
    if (paso == 0) return KeyEventResult.ignored;
    final apelaciones = widget.datos.buzon.apelaciones;
    final actual = _actual;
    if (actual == null) return KeyEventResult.ignored;
    final i = (apelaciones.indexOf(actual) + paso).clamp(0, apelaciones.length - 1);
    final destino = apelaciones[i];
    _seleccionar(destino);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final datos = widget.datos;
    final buzon = datos.buzon;
    final deHoy = buzon.deHoy;
    final actual = _actual;

    final lista = Focus(
      onKeyEvent: _alTeclear,
      skipTraversal: true,
      child: Semantics(
        container: true,
        label: Textos.listaApelaciones(buzon.apelaciones.length),
        child: Container(
          key: const ValueKey('lista-apelaciones'),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: tokens.fondoSuperficie,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: tokens.bordeDefault),
          ),
          child: Column(
            children: [
              for (final (i, a) in buzon.apelaciones.indexed) ...[
                if (i > 0) Divider(height: 1, thickness: 1, color: tokens.bordeDefault),
                FilaApelacion(
                  key: ValueKey('fila-${a.id}'),
                  titulo: a.titulo,
                  tema: a.tema,
                  dia: a.diaRepaso,
                  dias: buzon.diasHasta(a),
                  colorModulo: datos.coloresModulo[a.moduloId] ?? tokens.bordeControl,
                  seleccionada: a.id == actual?.id,
                  nodoFoco: _foco(a.id),
                  alPresionar: () => _seleccionar(a),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    final columnaLista = SingleChildScrollView(
      key: const ValueKey('buzon-desplazable'),
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Titulo(),
          const SizedBox(height: 8),
          Text(
            Textos.buzonSubtitulo,
            style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
          ),
          const SizedBox(height: 28),
          TarjetaRecompensaBuzon(deHoy: deHoy.length),
          const SizedBox(height: 16),
          lista,
          const SizedBox(height: 24),
          BotonApp(
            key: const ValueKey('boton-apelaciones-hoy'),
            texto: Textos.iniciarApelacionesHoy,
            alPresionar: deHoy.isEmpty
                ? null
                : () => _Buzon._iniciar(context, ref, [for (final a in deHoy) a.id]),
          ),
          const SizedBox(height: 12),
          Text(
            Textos.notaApelaciones,
            textAlign: TextAlign.center,
            style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
          ),
        ],
      ),
    );

    final detalle = actual == null
        ? const SizedBox.shrink()
        : _DetalleJuicio(
            key: ValueKey('detalle-${actual.id}'),
            apelacion: actual,
            dias: buzon.diasHasta(actual),
            colorModulo: datos.coloresModulo[actual.moduloId] ?? tokens.textoAcento,
            alIniciar: () => _Buzon._abrir(context, ref, actual, buzon.diasHasta(actual)),
          );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(width: MedidasAdaptativas.margen),
        Expanded(flex: _BuzonTablet.flexLista, child: columnaLista),
        const SizedBox(width: MedidasAdaptativas.margen),
        Expanded(
          flex: _BuzonTablet.flexDetalle,
          child: DecoratedBox(
            key: const ValueKey('panel-detalle-juicio'),
            decoration: BoxDecoration(
              color: tokens.fondoSuperficie,
              border: Border(left: BorderSide(color: tokens.bordeDefault)),
            ),
            child: detalle,
          ),
        ),
      ],
    );
  }
}

/// Vista previa del juicio en el panel de detalle del Buzón (T21): "PRÓXIMO
/// JUICIO · DÍA N" (Leyenda texto/acento), el título (H2), Sarko de 96 arriba a
/// la derecha, la tarjeta del caso de 342 × 440 con el aviso "La fallaste hace
/// N días" y "Iniciar juicio" (342 × 52). Se desplaza si no cabe.
class _DetalleJuicio extends ConsumerWidget {
  const _DetalleJuicio({
    required this.apelacion,
    required this.dias,
    required this.colorModulo,
    required this.alIniciar,
    super.key,
  });

  /// Ancho de la tarjeta y del botón (los del móvil).
  static const double ancho = 342;

  final Apelacion apelacion;
  final int dias;
  final Color colorModulo;
  final VoidCallback alIniciar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final tarjeta = ref.watch(tarjetaApelacionProvider(apelacion.tarjetaId)).value;
    final altoTarjeta =
        TarjetaCaso.alto >
            TarjetaCaso.altoMinimoPara(MediaQuery.textScalerOf(context), conAviso: true)
        ? TarjetaCaso.alto
        : TarjetaCaso.altoMinimoPara(MediaQuery.textScalerOf(context), conAviso: true);

    return SingleChildScrollView(
      key: const ValueKey('detalle-juicio'),
      padding: const EdgeInsets.fromLTRB(39, 24, 39, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                // Sin región en vivo: el cambio de selección ya se anuncia una
                // vez desde la lista (T-13).
                child: Semantics(
                  container: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Textos.proximoJuicio(apelacion.diaRepaso),
                        style: estilos.leyenda.copyWith(color: tokens.textoAcento),
                      ),
                      const SizedBox(height: 8),
                      Semantics(
                        header: true,
                        child: Text(
                          apelacion.titulo,
                          style: estilos.h2.copyWith(color: tokens.textoPrimario),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const SarkoImagen(
                key: ValueKey('sarko-detalle-juicio'),
                pose: PoseSarko.alegre,
                ancho: 96,
                decorativa: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: ancho,
              height: altoTarjeta,
              child: tarjeta == null
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        color: tokens.fondoSuperficieAlt,
                        borderRadius: BorderRadius.circular(TarjetaCaso.radio),
                      ),
                    )
                  : TarjetaCaso(
                      key: const ValueKey('tarjeta-detalle-juicio'),
                      // Vista previa con la pista de gestos, como en Figma
                      // (aquí no se arrastra: el juicio se abre con el botón).
                      etiquetaCaso: LogicaApelacion.etiqueta(apelacion.tema),
                      colorModulo: colorModulo,
                      iniciales: tarjeta.iniciales ?? LogicaInicio.iniciales(tarjeta.personaje),
                      personaje: tarjeta.personaje,
                      rol: tarjeta.rol,
                      texto: tarjeta.texto,
                      aviso: AvisoFallo(dias: apelacion.diaRepaso),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: ancho,
              child: BotonApp(
                key: const ValueKey('boton-iniciar-juicio'),
                texto: Textos.iniciarJuicio,
                alPresionar: alIniciar,
              ),
            ),
          ),
          if (dias > 0) ...[
            const SizedBox(height: 8),
            Text(
              Textos.avisoApelacionFutura(dias),
              textAlign: TextAlign.center,
              style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
            ),
          ],
        ],
      ),
    );
  }
}

/// En tablet (vertical o el Buzón vacío) el contenido del móvil se centra con
/// el ancho máximo de una columna (640); en móvil no cambia.
class _UnaColumna extends StatelessWidget {
  const _UnaColumna({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => context.clasePantalla.esTablet
      ? Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: MedidasAdaptativas.contenidoUnaColumna),
            child: child,
          ),
        )
      : child;
}

/// Buzón sin apelaciones (no está en Figma): Sarko sorprendido, "Tu Buzón
/// está vacío" y la explicación. Sin botón.
class _BuzonVacio extends StatelessWidget {
  const _BuzonVacio();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SingleChildScrollView(
      key: const ValueKey('buzon-vacio'),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Titulo(),
          const SizedBox(height: 32),
          const Center(
            child: SarkoImagen(pose: PoseSarko.sorprendido, ancho: 160, decorativa: true),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              Textos.buzonVacioTitulo,
              textAlign: TextAlign.center,
              style: context.estilos.h1.copyWith(color: tokens.textoPrimario),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              Textos.buzonVacioTexto,
              textAlign: TextAlign.center,
              style: context.estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
            ),
          ),
        ],
      ),
    );
  }
}

/// Esqueleto con las medidas del título, la recompensa y la lista.
class _EsqueletoBuzon extends StatelessWidget {
  const _EsqueletoBuzon();

  @override
  Widget build(BuildContext context) {
    final color = context.tokens.fondoSuperficieAlt;
    Widget bloque(double alto, {double? ancho, double radio = 16}) => Container(
      width: ancho,
      height: alto,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radio)),
    );
    return Semantics(
      label: Textos.cargandoBuzon,
      liveRegion: true,
      excludeSemantics: true,
      child: SingleChildScrollView(
        key: const ValueKey('esqueleto-buzon'),
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bloque(32, ancho: 260, radio: 8),
            const SizedBox(height: 8),
            bloque(40, ancho: 230, radio: 8),
            const SizedBox(height: 44),
            bloque(64, radio: 18),
            const SizedBox(height: 12),
            bloque(340, radio: 20),
          ],
        ),
      ),
    );
  }
}
