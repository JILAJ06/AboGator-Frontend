import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/marco_principal.dart';
import '../../app/rutas.dart';
import '../../componentes/aviso_snack.dart';
import '../../componentes/dialogo_confirmacion.dart';
import '../../componentes/esqueleto_pantalla.dart';
import '../../componentes/navegacion_inferior_app.dart';
import '../../componentes/piezas_perfil.dart';
import '../../componentes/vista_asincrona.dart';
import '../../core/adaptativo/clase_pantalla.dart';
import '../../core/tema/iconos_app.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/sincronizacion/estado_sincronizacion.dart';
import '../inicio/logica_inicio.dart';
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
    return MarcoPrincipal(
      pestana: PestanaApp.perfil,
      cuerpo: SafeArea(
        bottom: false,
        child: VistaAsincrona(
          valor: datos,
          conservarValor: true,
          datos: (valor) => _Perfil(datos: valor),
          textoError: Textos.perfilErrorCarga,
          alReintentar: () => ref.invalidate(datosPerfilProvider),
          esqueleto: const _EsqueletoPerfil(),
        ),
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
      mostrarAviso(context, Textos.errorCerrarSesion, clave: const ValueKey('error-cerrar-sesion'));
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

    final encabezado = Row(
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
    );
    final tarjeta = TarjetaPerfil(
      iniciales: LogicaPerfil.iniciales(usuario.nombre),
      nombre: usuario.nombre,
      detalle: LogicaPerfil.detalle(usuario),
    );
    final menu = MenuAgrupado(
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
          alPresionar: () => context.push(Rutas.notificacionesRacha),
        ),
        FilaMenu(
          key: const ValueKey('menu-aviso'),
          icono: IconosApp.doc,
          texto: Textos.menuAvisoPrivacidad,
          alPresionar: () => context.push(Rutas.legalAviso),
        ),
        FilaMenu(
          key: const ValueKey('menu-terminos'),
          icono: IconosApp.doc,
          texto: Textos.menuTerminos,
          alPresionar: () => context.push(Rutas.legalTerminos),
        ),
        FilaMenu(
          key: const ValueKey('menu-cerrar-sesion'),
          icono: IconosApp.logout,
          texto: Textos.cerrarSesion,
          peligro: true,
          alPresionar: _cerrarSesion,
        ),
      ],
    );

    final clase = context.clasePantalla;
    if (clase.esTablet) {
      return _PerfilTablet(
        dosColumnas: clase.esAncho,
        encabezado: encabezado,
        tarjeta: tarjeta,
        estadisticas: estadisticas,
        insignias: _InsigniasTablet(datos: widget.datos, desplazables: insignias),
        menu: menu,
        progreso: TarjetaProgresoModulos(
          modulos: [
            for (final m in widget.datos.modulos)
              AvanceModulo(
                nombre: Textos.moduloProgresoNombre(m.numero, LogicaInicio.nombreCorto(m)),
                porcentaje: LogicaPerfil.porcentajeModulo(m),
                color: m.color,
              ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      key: const ValueKey('perfil-desplazable'),
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          encabezado,
          const SizedBox(height: 10),
          tarjeta,
          const SizedBox(height: 10),
          estadisticas,
          const SizedBox(height: 16),
          const TituloSeccion(Textos.insigniasTitulo),
          const SizedBox(height: 10),
          insignias,
          const SizedBox(height: 24),
          menu,
        ],
      ),
    );
  }
}

/// Perfil en tablet (T25, Figma 101:4553). Con [dosColumnas] (≥ 960): "Mi
/// perfil" y el botón de ajustes arriba a todo el ancho; a la izquierda (500)
/// la tarjeta, las estadísticas de 2 × 2 y las insignias; a la derecha (502)
/// "Cuenta y preferencias" con el menú y "Progreso por módulo". Entre 600 y
/// 959, todo en una columna centrada de hasta 640.
class _PerfilTablet extends StatelessWidget {
  const _PerfilTablet({
    required this.dosColumnas,
    required this.encabezado,
    required this.tarjeta,
    required this.estadisticas,
    required this.insignias,
    required this.menu,
    required this.progreso,
  });

  /// Proporciones de las columnas de Figma (500 y 502).
  static const int flexIzquierda = 500;
  static const int flexDerecha = 502;

  final bool dosColumnas;
  final Widget encabezado;
  final Widget tarjeta;
  final Widget estadisticas;
  final Widget insignias;
  final Widget menu;
  final Widget progreso;

  @override
  Widget build(BuildContext context) {
    final izquierda = <Widget>[
      tarjeta,
      const SizedBox(height: 16),
      estadisticas,
      const SizedBox(height: 28),
      const TituloSeccion(Textos.insigniasTitulo),
      const SizedBox(height: 14),
      insignias,
    ];
    final derecha = <Widget>[
      Semantics(
        header: true,
        child: Text(
          Textos.cuentaYPreferencias,
          style: context.estilos.h3.copyWith(color: context.tokens.textoPrimario),
        ),
      ),
      const SizedBox(height: 14),
      menu,
      const SizedBox(height: MedidasAdaptativas.medianil),
      progreso,
    ];
    final Widget cuerpo = dosColumnas
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: flexIzquierda,
                child: Column(
                  key: const ValueKey('perfil-columna-izquierda'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: izquierda,
                ),
              ),
              const SizedBox(width: MedidasAdaptativas.medianil),
              Expanded(
                flex: flexDerecha,
                child: Padding(
                  // Figma: el título de la derecha queda 4 abajo de la tarjeta.
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    key: const ValueKey('perfil-columna-derecha'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: derecha,
                  ),
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [...izquierda, const SizedBox(height: 28), ...derecha],
          );

    return SingleChildScrollView(
      key: const ValueKey('perfil-desplazable'),
      padding: const EdgeInsets.fromLTRB(
        MedidasAdaptativas.margen,
        12,
        MedidasAdaptativas.margen,
        MedidasAdaptativas.medianil,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: dosColumnas ? double.infinity : MedidasAdaptativas.contenidoUnaColumna,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [encabezado, const SizedBox(height: 16), cuerpo],
          ),
        ),
      ),
    );
  }
}

/// Insignias en tablet: repartidas a todo el ancho (Figma: 4 medallas de 79
/// en 500); si no caben, se desplazan en horizontal como en móvil.
class _InsigniasTablet extends StatelessWidget {
  const _InsigniasTablet({required this.datos, required this.desplazables});

  /// Ancho de cada medalla y separación mínima entre ellas.
  static const double anchoMedalla = 79;
  static const double separacionMinima = 8;

  final DatosPerfil datos;
  final Widget desplazables;

  @override
  Widget build(BuildContext context) {
    final insignias = datos.resumen.insignias;
    return LayoutBuilder(
      builder: (context, restricciones) {
        final necesario =
            insignias.length * anchoMedalla + (insignias.length - 1) * separacionMinima;
        if (insignias.length < 2 || necesario > restricciones.maxWidth) return desplazables;
        return Row(
          key: const ValueKey('insignias'),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final ins in insignias)
              MedallaInsignia(
                key: ValueKey('insignia-${ins.id}'),
                nombre: ins.nombre,
                icono: IconosApp.porNombre[ins.icono] ?? IconosApp.star,
                desbloqueada: ins.desbloqueada,
                colorModulo: datos.coloresModulo[ins.moduloId],
              ),
          ],
        );
      },
    );
  }
}

/// Esqueleto con las medidas del encabezado, la tarjeta, las estadísticas y
/// el menú.
class _EsqueletoPerfil extends StatelessWidget {
  const _EsqueletoPerfil();

  @override
  Widget build(BuildContext context) => const EsqueletoPantalla(
    etiqueta: Textos.cargandoPerfil,
    clave: ValueKey('esqueleto-perfil'),
    relleno: EdgeInsets.fromLTRB(24, 6, 24, 0),
    alineacion: CrossAxisAlignment.stretch,
    hijos: [
      BloqueEsqueleto(48, radio: 12),
      SizedBox(height: 10),
      BloqueEsqueleto(92, radio: 22),
      SizedBox(height: 10),
      BloqueEsqueleto(140),
      SizedBox(height: 16),
      BloqueEsqueleto(130),
      SizedBox(height: 24),
      BloqueEsqueleto(196, radio: 18),
    ],
  );
}
