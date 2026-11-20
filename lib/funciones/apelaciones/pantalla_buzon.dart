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
import '../../componentes/sarko_imagen.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/apelacion.dart';
import '../../datos/modelos/buzon_apelaciones.dart';
import '../../datos/repositorios/proveedores_repositorios.dart';
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
          AsyncData(:final value) when value.buzon.total == 0 => const _BuzonVacio(),
          AsyncData(:final value) => _Buzon(datos: value),
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

  void _abrir(BuildContext context, WidgetRef ref, Apelacion a, int dias) {
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
