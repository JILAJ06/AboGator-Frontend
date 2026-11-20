import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/marco_principal.dart';
import '../../app/rutas.dart';
import '../../componentes/dialogo_confirmacion.dart';
import '../../componentes/mensaje_pantalla.dart';
import '../../componentes/navegacion_inferior_app.dart';
import '../../componentes/piezas_perfil.dart';
import '../../core/tema/iconos_app.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/sincronizacion/estado_sincronizacion.dart';
import '../tienda/pantalla_tienda.dart';
import 'estado_perfil.dart';
import 'logica_perfil.dart';

/// Pantalla 25 · Perfil y progreso (Figma 18:2492), en la pestaña Perfil.
///
/// "Mi perfil" con el botón de ajustes, la tarjeta de perfil, las cuatro
/// estadísticas, las insignias y el menú (Accesibilidad, Notificaciones de
/// racha, Aviso de privacidad y Cerrar sesión).
class PantallaPerfil extends ConsumerWidget {
  const PantallaPerfil({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(datosPerfilProvider);
    final valor = datos.value;
    return MarcoPrincipal(
      pestana: PestanaApp.perfil,
      cuerpo: SafeArea(
        bottom: false,
        child: valor != null
            ? _Perfil(datos: valor)
            : datos.hasError
            ? MensajePantalla(
                texto: Textos.perfilErrorCarga,
                textoBoton: Textos.reintentar,
                alPresionar: () => ref.invalidate(datosPerfilProvider),
              )
            : const _EsqueletoPerfil(),
      ),
    );
  }
}

class _Perfil extends ConsumerStatefulWidget {
  const _Perfil({required this.datos});

  final DatosPerfil datos;

  @override
  ConsumerState<_Perfil> createState() => _PerfilState();
}

class _PerfilState extends ConsumerState<_Perfil> {
  bool _cerrando = false;

  Future<void> _cerrarSesion() async {
    if (_cerrando) return;
    final pendientes = ref.read(respuestasPendientesProvider);
    final confirmado = await DialogoConfirmacion.mostrar(
      context,
      titulo: Textos.confirmarCerrarSesionTitulo,
      texto: pendientes > 0
          ? '${Textos.confirmarCerrarSesionTexto} ${Textos.respuestasGuardadasAviso(pendientes)}'
          : Textos.confirmarCerrarSesionTexto,
      textoConfirmar: Textos.cerrarSesion,
    );
    if (!confirmado || !mounted) return;
    _cerrando = true;
    final enrutador = GoRouter.of(context);
    try {
      await cerrarSesion(ref);
      enrutador.go(Rutas.inicioSesion);
    } on Object {
      _cerrando = false;
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            key: const ValueKey('error-cerrar-sesion'),
            content: Semantics(liveRegion: true, child: const Text(Textos.errorCerrarSesion)),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final resumen = widget.datos.resumen;
    final usuario = resumen.usuario;

    Widget pareja(Widget a, Widget b) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: a),
          const SizedBox(width: 10),
          Expanded(child: b),
        ],
      ),
    );

    final estadisticas = Column(
      key: const ValueKey('estadisticas'),
      children: [
        pareja(
          TarjetaEstadistica(
            icono: IconosApp.flame,
            colorIcono: tokens.accionAcento,
            valor: Textos.rachaDias(usuario.racha),
            etiqueta: Textos.rachaActual,
          ),
          TarjetaEstadistica(
            icono: IconosApp.check,
            colorIcono: tokens.estadoLegal,
            valor: Textos.precisionValor(resumen.precision),
            etiqueta: Textos.precision,
          ),
        ),
        const SizedBox(height: 10),
        pareja(
          TarjetaEstadistica(
            icono: IconosApp.trophy,
            colorIcono: tokens.textoPrimario,
            valor: Textos.certificadosValor(resumen.certificados, resumen.certificadosTotales),
            valorSemantico: Textos.certificadosSemanticaValor(
              resumen.certificados,
              resumen.certificadosTotales,
            ),
            etiqueta: Textos.certificados,
          ),
          TarjetaEstadistica(
            icono: IconosApp.star,
            colorIcono: tokens.accionAcento,
            valor: '${resumen.sprintsPerfectos}',
            etiqueta: Textos.sprintsPerfectos,
          ),
        ),
      ],
    );

    // Si no caben, se desplazan en horizontal sin barra; la medalla nunca se
    // encoge ni se corta.
    final insignias = ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        key: const ValueKey('insignias'),
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, ins) in resumen.insignias.indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              MedallaInsignia(
                key: ValueKey('insignia-${ins.id}'),
                nombre: ins.nombre,
                icono: IconosApp.porNombre[ins.icono] ?? IconosApp.star,
                desbloqueada: ins.desbloqueada,
                colorModulo: widget.datos.coloresModulo[ins.moduloId],
              ),
            ],
          ],
        ),
      ),
    );

    return SingleChildScrollView(
      key: const ValueKey('perfil-desplazable'),
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: TituloPestana(Textos.perfilTitulo)),
              const SizedBox(width: 12),
              BotonIconoCuadrado(
                key: const ValueKey('boton-ajustes'),
                icono: IconosApp.settings,
                etiqueta: Textos.accesibilidadYAjustes,
                alPresionar: () => context.go(Rutas.ajustes),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TarjetaPerfil(
            iniciales: LogicaPerfil.iniciales(usuario.nombre),
            nombre: usuario.nombre,
            detalle: LogicaPerfil.detalle(usuario),
          ),
          const SizedBox(height: 10),
          estadisticas,
          const SizedBox(height: 16),
          const TituloSeccion(Textos.insigniasTitulo),
          const SizedBox(height: 10),
          insignias,
          const SizedBox(height: 24),
          MenuAgrupado(
            filas: [
              FilaMenu(
                key: const ValueKey('menu-accesibilidad'),
                icono: IconosApp.accessibility,
                texto: Textos.menuAccesibilidad,
                alPresionar: () => context.go(Rutas.ajustes),
              ),
              FilaMenu(
                key: const ValueKey('menu-notificaciones'),
                icono: IconosApp.bell,
                texto: Textos.menuNotificacionesRacha,
                alPresionar: () => context.go(Rutas.notificacionesRacha),
              ),
              FilaMenu(
                key: const ValueKey('menu-aviso'),
                icono: IconosApp.doc,
                texto: Textos.menuAvisoPrivacidad,
                alPresionar: () => context.go(Rutas.avisoPrivacidad),
              ),
              FilaMenu(
                key: const ValueKey('menu-cerrar-sesion'),
                icono: IconosApp.logout,
                texto: Textos.cerrarSesion,
                peligro: true,
                alPresionar: _cerrarSesion,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Esqueleto con las medidas del encabezado, la tarjeta, las estadísticas y
/// el menú.
class _EsqueletoPerfil extends StatelessWidget {
  const _EsqueletoPerfil();

  @override
  Widget build(BuildContext context) {
    final color = context.tokens.fondoSuperficieAlt;
    Widget bloque(double alto, {double? ancho, double radio = 16}) => Container(
      width: ancho,
      height: alto,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radio)),
    );
    return Semantics(
      label: Textos.cargandoPerfil,
      liveRegion: true,
      excludeSemantics: true,
      child: SingleChildScrollView(
        key: const ValueKey('esqueleto-perfil'),
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            bloque(48, radio: 12),
            const SizedBox(height: 10),
            bloque(92, radio: 22),
            const SizedBox(height: 10),
            bloque(140),
            const SizedBox(height: 16),
            bloque(130),
            const SizedBox(height: 24),
            bloque(196, radio: 18),
          ],
        ),
      ),
    );
  }
}
