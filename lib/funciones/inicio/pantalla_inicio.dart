import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/rutas.dart';
import '../../componentes/avatar_app.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/boton_buzon.dart';
import '../../componentes/chip_hud.dart';
import '../../componentes/navegacion_inferior_app.dart';
import '../../componentes/tarjeta_heroe_startup.dart';
import '../../componentes/tarjeta_modulo.dart';
import '../../componentes/tarjeta_reto_diario.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/usuario.dart';
import '../acceso/sesion.dart';
import 'estado_inicio.dart';
import 'logica_inicio.dart';

/// Pantalla 07 · Inicio (07b es el mismo código en modo oscuro).
class PantallaInicio extends ConsumerWidget {
  const PantallaInicio({super.key});

  /// Espacio entre el botón Buzón y la barra inferior (Figma: 760 − 732).
  static const double separacionBuzon = 28;

  /// Reserva al final de la lista para que el Buzón no tape la última tarjeta.
  static const double reservaFinal = BotonBuzon.lado + separacionBuzon + 16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(sesionProvider);
    final datos = ref.watch(datosInicioProvider);

    return Scaffold(
      bottomNavigationBar: NavegacionInferiorApp(
        actual: PestanaApp.mapa,
        alSeleccionar: (pestana) => switch (pestana) {
          PestanaApp.mapa => null,
          PestanaApp.buzon => context.go(Rutas.buzon),
          PestanaApp.tienda => context.go(Rutas.tienda),
          PestanaApp.perfil => context.go(Rutas.perfil),
        },
      ),
      body: usuario == null
          ? const SizedBox.shrink()
          : switch (datos) {
              AsyncData(:final value) => _Contenido(usuario: usuario, datos: value),
              AsyncError() => _ErrorCarga(alReintentar: () => ref.invalidate(datosInicioProvider)),
              _ => const _Esqueleto(),
            },
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.usuario, required this.datos});

  final Usuario usuario;
  final DatosInicio datos;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final actual = LogicaInicio.actual(datos.modulos);

    return Stack(
      children: [
        SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, PantallaInicio.reservaFinal),
                sliver: SliverList.list(
                  children: [
                    _Encabezado(usuario: usuario, datos: datos),
                    const SizedBox(height: 22),
                    if (actual != null)
                      TarjetaHeroeStartup(
                        titulo: LogicaInicio.tramo(actual.modulo),
                        subtitulo: Textos.heroeSubtitulo(
                          actual.numeroSprint,
                          actual.modulo.sprints.length,
                          actual.modulo.nombre,
                        ),
                        alContinuar: () =>
                            context.go(Rutas.introSprintDe(actual.modulo.id, actual.sprint.id)),
                      ),
                    const SizedBox(height: 14),
                    TarjetaRetoDiario(
                      titulo: Textos.retoTitulo,
                      subtitulo: Textos.retoSubtitulo(usuario.racha, RetoDiario.monedas),
                      actual: RetoDiario.actual,
                      total: RetoDiario.total,
                    ),
                    const SizedBox(height: 18),
                    Semantics(
                      header: true,
                      label: Textos.rutaStartup,
                      excludeSemantics: true,
                      child: Text(
                        Textos.rutaStartup,
                        style: context.estilos.h2.copyWith(color: tokens.textoPrimario),
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final (i, modulo) in datos.modulos.indexed) ...[
                      if (i > 0) const SizedBox(height: 12),
                      TarjetaModulo(
                        key: ValueKey('modulo-${modulo.id}'),
                        numero: modulo.numero,
                        nombreCorto: LogicaInicio.nombreCorto(modulo),
                        titulo: LogicaInicio.tramo(modulo),
                        estado: LogicaInicio.estadoDe(modulo),
                        completados: LogicaInicio.completados(modulo),
                        total: modulo.sprints.length,
                        color: modulo.color,
                        icono: LogicaInicio.iconoDe(modulo),
                        alPresionar: () => context.go(Rutas.mapaSprintsDe(modulo.id)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        // Fijo sobre la lista, 28 dp por encima de la barra inferior.
        Positioned(
          right: 24,
          bottom: PantallaInicio.separacionBuzon,
          child: BotonBuzon(
            pendientes: datos.apelacionesPendientes,
            alPresionar: () => context.go(Rutas.buzon),
          ),
        ),
      ],
    );
  }
}

/// Avatar y saludo a la izquierda; chips de racha, monedas y vidas a la derecha.
/// Con texto grande o pantallas muy angostas, los chips bajan a otra fila.
class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.usuario, required this.datos});

  final Usuario usuario;
  final DatosInicio datos;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final saludo = Textos.saludo(LogicaInicio.primerNombre(usuario.nombre));
    final perfil = Textos.perfilYNivel(LogicaInicio.perfilCorto(usuario.perfil), usuario.nivel);

    final saludoBloque = Row(
      children: [
        AvatarApp(iniciales: LogicaInicio.iniciales(usuario.nombre)),
        const SizedBox(width: 10),
        Expanded(
          child: Semantics(
            header: true,
            label: '$saludo. $perfil',
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  saludo,
                  style: estilos.h3.copyWith(color: tokens.textoPrimario),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  perfil,
                  style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );

    final chips = Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ChipHud.racha(usuario.racha),
        ChipHud.monedas(datos.monedas),
        ChipHud.vidas(datos.vidas.cantidad),
      ],
    );

    return LayoutBuilder(
      builder: (context, restricciones) {
        final apilar =
            MediaQuery.textScalerOf(context).scale(1) > 1.3 || restricciones.maxWidth < 300;
        if (apilar) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [saludoBloque, const SizedBox(height: 10), chips],
          );
        }
        return Row(
          children: [
            Expanded(child: saludoBloque),
            const SizedBox(width: 6),
            chips,
          ],
        );
      },
    );
  }
}

/// Esqueleto con las mismas medidas mientras cargan los datos.
class _Esqueleto extends StatelessWidget {
  const _Esqueleto();

  @override
  Widget build(BuildContext context) {
    final color = context.tokens.fondoSuperficieAlt;
    Widget bloque(double alto, {double? ancho, double radio = 18}) => Container(
      width: ancho,
      height: alto,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radio)),
    );

    return Semantics(
      label: Textos.cargandoInicio,
      liveRegion: true,
      excludeSemantics: true,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          key: const ValueKey('esqueleto-inicio'),
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  bloque(44, ancho: 44, radio: 22),
                  const SizedBox(width: 10),
                  Expanded(child: bloque(36, radio: 8)),
                ],
              ),
              const SizedBox(height: 22),
              bloque(TarjetaHeroeStartup.alto, radio: TarjetaHeroeStartup.radio),
              const SizedBox(height: 14),
              bloque(60),
              const SizedBox(height: 18),
              bloque(26, ancho: 168, radio: 8),
              const SizedBox(height: 10),
              for (var i = 0; i < 3; i++) ...[
                bloque(92, radio: TarjetaModulo.radio),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCarga extends StatelessWidget {
  const _ErrorCarga({required this.alReintentar});

  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                liveRegion: true,
                child: Text(
                  Textos.inicioErrorCarga,
                  style: context.estilos.cuerpoGrande.copyWith(color: tokens.textoPrimario),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              BotonApp(
                texto: Textos.reintentar,
                tipo: TipoBoton.secundario,
                expandido: false,
                alPresionar: alReintentar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
