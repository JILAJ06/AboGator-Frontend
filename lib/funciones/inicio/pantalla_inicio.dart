import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/marco_principal.dart';
import '../../app/rutas.dart';
import '../../componentes/avatar_app.dart';
import '../../componentes/chip_hud.dart';
import '../../componentes/mensaje_pantalla.dart';
import '../../componentes/navegacion_inferior_app.dart';
import '../../componentes/sarko_imagen.dart';
import '../../componentes/tarjeta_buzon_inicio.dart';
import '../../componentes/tarjeta_consejo_sarko.dart';
import '../../componentes/tarjeta_heroe_startup.dart';
import '../../componentes/tarjeta_modulo.dart';
import '../../componentes/tarjeta_reto_diario.dart';
import '../../componentes/tarjeta_semana.dart';
import '../../core/adaptativo/clase_pantalla.dart';
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
  static const double separacionBuzon = MarcoPrincipal.separacionBuzon;

  /// Reserva al final de la lista para que el Buzón no tape la última tarjeta.
  static const double reservaFinal = MarcoPrincipal.reservaBuzon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(sesionProvider);
    final datos = ref.watch(datosInicioProvider);

    return MarcoPrincipal(
      pestana: PestanaApp.mapa,
      apelacionesPendientes: datos.value?.apelacionesPendientes,
      cuerpo: usuario == null
          ? const SizedBox.shrink()
          : switch (datos) {
              AsyncData(:final value) =>
                context.clasePantalla.esTablet
                    ? _ContenidoTablet(
                        usuario: usuario,
                        datos: value,
                        dosColumnas: context.clasePantalla.esAncho,
                      )
                    : _Contenido(usuario: usuario, datos: value),
              AsyncError() => MensajePantalla(
                texto: Textos.inicioErrorCarga,
                textoBoton: Textos.reintentar,
                alPresionar: () => ref.invalidate(datosInicioProvider),
              ),
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

    return SafeArea(
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
                      LogicaInicio.totalSprints(actual.modulo),
                      LogicaInicio.nombreCorto(actual.modulo),
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
                    total: LogicaInicio.totalSprints(modulo),
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
    );
  }
}

/// Inicio en tablet (T07 y T07b). Con [dosColumnas] (≥ 960): a la izquierda
/// (620) la tarjeta héroe, "Ruta de tu Startup" y los módulos en dos columnas
/// de 300; a la derecha (382) el reto diario, "Tu semana", el Buzón y, al
/// fondo, el consejo de Sarko. Entre 600 y 959, una sola columna (la derecha
/// debajo de la izquierda), centrada con ancho máximo.
///
/// Orden de foco: encabezado → héroe → módulos → Buzón (el riel va antes).
class _ContenidoTablet extends ConsumerWidget {
  const _ContenidoTablet({required this.usuario, required this.datos, required this.dosColumnas});

  final Usuario usuario;
  final DatosInicio datos;
  final bool dosColumnas;

  /// Arriba del contenido (Figma: 52 − 32).
  static const double margenSuperior = 20;

  /// Abajo del contenido (Figma: Sarko termina 24 antes del borde).
  static const double margenInferior = 24;

  /// Encabezado → héroe y reto (Figma: 120 − 52 − 44).
  static const double huecoEncabezado = 24;

  /// Alto del encabezado en Figma (el avatar de 44).
  static const double altoEncabezado = 44;

  /// Proporciones de las dos columnas de Figma (620 y 382).
  static const int flexIzquierda = 620;
  static const int flexDerecha = 382;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final actual = LogicaInicio.actual(datos.modulos);
    final precision = ref.watch(precisionInicioProvider).value;
    var orden = 0.0;
    Widget ordenado(Widget hijo) =>
        FocusTraversalOrder(order: NumericFocusOrder(orden++), child: hijo);

    final heroe = actual == null
        ? null
        : ordenado(
            TarjetaHeroeStartup(
              medidas: MedidasHeroe.tablet,
              titulo: LogicaInicio.tramo(actual.modulo),
              subtitulo: Textos.heroeSubtitulo(
                actual.numeroSprint,
                LogicaInicio.totalSprints(actual.modulo),
                LogicaInicio.nombreCorto(actual.modulo),
              ),
              alContinuar: () =>
                  context.go(Rutas.introSprintDe(actual.modulo.id, actual.sprint.id)),
            ),
          );

    final modulos = [
      for (final modulo in datos.modulos)
        ordenado(
          TarjetaModulo(
            key: ValueKey('modulo-${modulo.id}'),
            numero: modulo.numero,
            nombreCorto: LogicaInicio.nombreCorto(modulo),
            titulo: LogicaInicio.tramo(modulo),
            estado: LogicaInicio.estadoDe(modulo),
            completados: LogicaInicio.completados(modulo),
            total: LogicaInicio.totalSprints(modulo),
            color: modulo.color,
            icono: LogicaInicio.iconoDe(modulo),
            alPresionar: () => context.go(Rutas.mapaSprintsDe(modulo.id)),
          ),
        ),
    ];

    final izquierda = Column(
      key: const ValueKey('inicio-columna-izquierda'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ?heroe,
        if (heroe != null) const SizedBox(height: 26),
        Semantics(
          header: true,
          label: Textos.rutaStartup,
          excludeSemantics: true,
          child: Text(
            Textos.rutaStartup,
            style: context.estilos.h2.copyWith(color: tokens.textoPrimario),
          ),
        ),
        const SizedBox(height: 14),
        _RejillaModulos(modulos: modulos),
      ],
    );

    final derechaArriba = <Widget>[
      TarjetaRetoDiario(
        titulo: Textos.retoTitulo,
        subtitulo: Textos.retoSubtitulo(usuario.racha, RetoDiario.monedas),
        actual: RetoDiario.actual,
        total: RetoDiario.total,
      ),
      const SizedBox(height: 20),
      TarjetaSemana(racha: usuario.racha, precision: precision, monedas: datos.monedas),
      const SizedBox(height: 16),
      ordenado(
        TarjetaBuzonInicio(
          pendientes: datos.apelacionesPendientes,
          alAbrir: () => irAPestana(context, PestanaApp.buzon),
        ),
      ),
    ];
    final consejo = _ConsejoConSarko(consejo: LogicaInicio.consejo(datos.modulos));

    return SafeArea(
      left: false,
      bottom: false,
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: LayoutBuilder(
          builder: (context, restricciones) {
            final encabezado = _Encabezado(usuario: usuario, datos: datos);
            final Widget cuerpo;
            if (dosColumnas) {
              // La columna derecha llega al menos hasta el fondo para que el
              // consejo de Sarko quede abajo, como en Figma; si no cabe, fluye.
              final altoDerecha =
                  restricciones.maxHeight -
                  margenSuperior -
                  altoEncabezado -
                  huecoEncabezado -
                  margenInferior;
              cuerpo = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: flexIzquierda, child: izquierda),
                  const SizedBox(width: MedidasAdaptativas.medianil),
                  Expanded(
                    flex: flexDerecha,
                    child: ConstrainedBox(
                      key: const ValueKey('inicio-columna-derecha'),
                      constraints: BoxConstraints(minHeight: altoDerecha < 0 ? 0 : altoDerecha),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: derechaArriba,
                          ),
                          Padding(padding: const EdgeInsets.only(top: 24), child: consejo),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              cuerpo = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  izquierda,
                  const SizedBox(height: MedidasAdaptativas.medianil),
                  ...derechaArriba,
                  const SizedBox(height: MedidasAdaptativas.medianil),
                  consejo,
                ],
              );
            }
            return SingleChildScrollView(
              key: const ValueKey('inicio-tablet'),
              padding: const EdgeInsets.fromLTRB(
                MedidasAdaptativas.margen,
                margenSuperior,
                MedidasAdaptativas.margen,
                margenInferior,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: dosColumnas
                        ? double.infinity
                        : MedidasAdaptativas.contenidoUnaColumna,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      encabezado,
                      const SizedBox(height: huecoEncabezado),
                      cuerpo,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Módulos del Inicio en tablet: dos columnas de 300 con separación 20 (en
/// horizontal y en vertical). Con menos de [anchoMinimoDosColumnas] o texto
/// grande, una sola columna.
class _RejillaModulos extends StatelessWidget {
  const _RejillaModulos({required this.modulos});

  static const double separacion = 20;
  static const double anchoMinimoDosColumnas = 520;

  final List<Widget> modulos;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final escala = MediaQuery.textScalerOf(context).scale(1);
        final columnas = restricciones.maxWidth >= anchoMinimoDosColumnas && escala <= 1.5 ? 2 : 1;
        final filas = <Widget>[];
        for (var i = 0; i < modulos.length; i += columnas) {
          if (filas.isNotEmpty) filas.add(const SizedBox(height: separacion));
          filas.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var j = 0; j < columnas; j++) ...[
                  if (j > 0) const SizedBox(width: separacion),
                  Expanded(
                    child: i + j < modulos.length ? modulos[i + j] : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          );
        }
        return Column(
          key: const ValueKey('rejilla-modulos'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: filas,
        );
      },
    );
  }
}

/// Consejo de Sarko (252 de ancho en Figma) con Sarko de 120 × 150 a su
/// derecha como adorno; la tarjeta termina 18 arriba del pie de Sarko.
class _ConsejoConSarko extends StatelessWidget {
  const _ConsejoConSarko({required this.consejo});

  final String consejo;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('consejo-sarko'),
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: TarjetaConsejoSarko(consejo: consejo),
          ),
        ),
        const SizedBox(width: 10),
        const SarkoImagen(
          key: ValueKey('sarko-consejo'),
          pose: PoseSarko.alegre,
          ancho: 120,
          decorativa: true,
        ),
      ],
    );
  }
}

/// Avatar y saludo a la izquierda; chips de racha, monedas y vidas a la derecha.
/// Con texto grande, pantallas muy angostas o si el saludo no cabe completo,
/// los chips bajan a otra fila.
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
      mainAxisSize: MainAxisSize.min,
      children: [
        AvatarApp(iniciales: LogicaInicio.iniciales(usuario.nombre)),
        const SizedBox(width: 10),
        Flexible(
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
        // Saludo a la izquierda y chips a la derecha; si el saludo completo no
        // cabe junto a los chips, los chips bajan a la segunda fila en lugar de
        // recortar el nombre (D6 de T-04b).
        return Wrap(
          key: const ValueKey('encabezado-inicio'),
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 10,
          children: [saludoBloque, chips],
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
