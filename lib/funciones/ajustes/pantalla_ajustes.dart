import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/marco_principal.dart';
import '../../app/rutas.dart';
import '../../componentes/aviso_snack.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/foco_retorno.dart';
import '../../componentes/icono_app.dart';
import '../../componentes/navegacion_inferior_app.dart';
import '../../componentes/piezas_ajustes.dart';
import '../../componentes/piezas_perfil.dart';
import '../../componentes/titulo_enfocado.dart';
import '../../core/adaptativo/clase_pantalla.dart';
import '../../core/tema/efectos.dart';
import '../../core/tema/iconos_app.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/ajustes.dart';
import 'estado_ajustes.dart';
import 'logica_ajustes.dart';

/// Pantalla 26 · Ajustes de accesibilidad (Figma 18:2634), hija del Perfil y
/// sin navegación inferior.
///
/// Atrás y "Accesibilidad", el subtítulo y tres secciones (Visual, Motor y
/// auditiva, Cognitiva). Cada cambio se aplica al instante y se guarda en el
/// dispositivo; si no se puede guardar, se revierte y se avisa.
class PantallaAjustes extends ConsumerStatefulWidget {
  const PantallaAjustes({super.key});

  /// Vuelve al Perfil (o a la pantalla anterior si la hay).
  static void volver(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Rutas.perfil);
    }
  }

  @override
  ConsumerState<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends ConsumerState<PantallaAjustes> {
  /// Fila "Tamaño de texto": el foco vuelve a ella al cerrar el selector
  /// (con o sin elección; T-13).
  final _focoTamano = FocusNode(debugLabel: 'ajuste tamaño de texto');

  @override
  void dispose() {
    _focoTamano.dispose();
    super.dispose();
  }

  Future<void> _cambiar(BuildContext context, WidgetRef ref, Ajustes nuevos) async {
    final mensajero = ScaffoldMessenger.of(context);
    final guardado = await ref.read(ajustesProvider.notifier).cambiar(nuevos);
    if (guardado) return;
    mostrarAvisoEn(
      mensajero,
      Textos.errorGuardarAjuste,
      clave: const ValueKey('error-guardar-ajuste'),
    );
  }

  Future<void> _elegirTamano(BuildContext context, WidgetRef ref) async {
    final actual = ref.read(ajustesProvider).escalaTexto;
    // En tablet la hoja pasa a diálogo centrado de 440 como máximo.
    final elegido = context.clasePantalla.esTablet
        ? await showDialog<int>(
            context: context,
            barrierColor: EfectosApp.colorVelo,
            builder: (contexto) => Dialog(
              backgroundColor: const Color(0x00000000),
              elevation: 0,
              insetPadding: const EdgeInsets.all(MedidasAdaptativas.margen),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: SelectorTamano.anchoDialogo),
                child: SelectorTamano(actual: actual, enDialogo: true),
              ),
            ),
          )
        : await showModalBottomSheet<int>(
            context: context,
            // El fondo lo pinta el selector con los tokens del tema vigente.
            backgroundColor: const Color(0x00000000),
            elevation: 0,
            barrierColor: EfectosApp.colorVelo,
            isScrollControlled: true,
            builder: (contexto) => SelectorTamano(actual: actual),
          );
    if (!context.mounted) return;
    devolverFoco(_focoTamano);
    if (elegido == null) return;
    await _cambiar(context, ref, ref.read(ajustesProvider).copyWith(escalaTexto: elegido));
  }

  @override
  Widget build(BuildContext context) => _construir(context, ref);

  Widget _construir(BuildContext context, WidgetRef ref) {
    final ajustes = ref.watch(ajustesProvider);
    final tokens = context.tokens;
    final estilos = context.estilos;
    final oscuro = LogicaAjustes.oscuroEfectivo(
      ajustes.modoTema,
      MediaQuery.platformBrightnessOf(context),
    );
    final lectorActivo = MediaQuery.accessibleNavigationOf(context);

    void alternar(Ajustes nuevos) => unawaited(_cambiar(context, ref, nuevos));

    final visual = MenuAgrupado(
      filas: [
        FilaAjuste(
          key: const ValueKey('ajuste-modo-oscuro'),
          icono: IconosApp.moon,
          titulo: Textos.modoOscuro,
          detalle: Textos.modoOscuroDetalle,
          interruptor: oscuro,
          control: InterruptorApp(valor: oscuro),
          alPresionar: () =>
              alternar(ajustes.copyWith(modoTema: oscuro ? ThemeMode.light : ThemeMode.dark)),
        ),
        FilaAjuste(
          key: const ValueKey('ajuste-tamano'),
          icono: IconosApp.type,
          titulo: Textos.tamanoTexto,
          detalle: Textos.tamanoTextoDetalle,
          valorSemantico: Textos.porcentajeSemantica(ajustes.escalaTexto),
          control: ChipValor(texto: Textos.tamanoValor(ajustes.escalaTexto)),
          nodoFoco: _focoTamano,
          alPresionar: () => _elegirTamano(context, ref),
        ),
        FilaAjuste(
          key: const ValueKey('ajuste-lector'),
          icono: IconosApp.eye,
          titulo: Textos.etiquetasLector,
          detalle: Textos.etiquetasLectorDetalle,
          etiquetaSemantica: Textos.lectorSemantica(lectorActivo),
          control: ChipValor(texto: lectorActivo ? Textos.lectorActivo : Textos.lectorDisponible),
        ),
      ],
    );

    final motora = MenuAgrupado(
      filas: [
        FilaAjuste(
          key: const ValueKey('ajuste-solo-botones'),
          icono: IconosApp.check,
          titulo: Textos.soloBotones,
          detalle: Textos.soloBotonesDetalle,
          interruptor: ajustes.soloBotones,
          control: InterruptorApp(valor: ajustes.soloBotones),
          alPresionar: () => alternar(ajustes.copyWith(soloBotones: !ajustes.soloBotones)),
        ),
        FilaAjuste(
          key: const ValueKey('ajuste-haptica'),
          icono: IconosApp.vibrate,
          titulo: Textos.vibracion,
          detalle: Textos.vibracionDetalle,
          interruptor: ajustes.haptica,
          control: InterruptorApp(valor: ajustes.haptica),
          alPresionar: () async {
            final encender = !ajustes.haptica;
            await _cambiar(context, ref, ajustes.copyWith(haptica: encender));
            // Muestra de cómo se siente.
            if (encender) await ref.read(servicioHapticoProvider).suave();
          },
        ),
      ],
    );

    final cognitiva = MenuAgrupado(
      filas: [
        FilaAjuste(
          key: const ValueKey('ajuste-tiempo'),
          icono: IconosApp.clock,
          titulo: Textos.tiempoExtendido,
          detalle: Textos.tiempoExtendidoDetalle,
          interruptor: ajustes.tiempoExtendido,
          control: InterruptorApp(valor: ajustes.tiempoExtendido),
          alPresionar: () => alternar(ajustes.copyWith(tiempoExtendido: !ajustes.tiempoExtendido)),
        ),
        FilaAjuste(
          key: const ValueKey('ajuste-animaciones'),
          icono: IconosApp.pause,
          titulo: Textos.reducirAnimaciones,
          detalle: Textos.reducirAnimacionesDetalle,
          interruptor: ajustes.reducirAnimaciones,
          control: InterruptorApp(valor: ajustes.reducirAnimaciones),
          alPresionar: () =>
              alternar(ajustes.copyWith(reducirAnimaciones: !ajustes.reducirAnimaciones)),
        ),
      ],
    );

    // T-13b: Notificaciones (34) y Legal (32 y 33); se abren con push para
    // volver aquí.
    Widget chevron() => IconoApp(IconosApp.chevron, tamano: 20, color: tokens.textoSecundario);
    final notificaciones = MenuAgrupado(
      filas: [
        FilaAjuste(
          key: const ValueKey('ajuste-notificaciones'),
          icono: IconosApp.bell,
          titulo: Textos.menuNotificaciones,
          detalle: Textos.menuNotificacionesDetalle,
          control: chevron(),
          alPresionar: () => context.push(Rutas.notificacionesRacha),
        ),
      ],
    );
    final legal = MenuAgrupado(
      filas: [
        FilaAjuste(
          key: const ValueKey('ajuste-aviso'),
          icono: IconosApp.doc,
          titulo: Textos.avisoPrivacidadTitulo,
          detalle: Textos.versionLegal,
          control: chevron(),
          alPresionar: () => context.push(Rutas.legalAviso),
        ),
        FilaAjuste(
          key: const ValueKey('ajuste-terminos'),
          icono: IconosApp.doc,
          titulo: Textos.terminosTitulo,
          detalle: Textos.versionLegal,
          control: chevron(),
          alPresionar: () => context.push(Rutas.legalTerminos),
        ),
      ],
    );

    final encabezado = Row(
      children: [
        // El botón va 4 antes del margen, como en Figma (móvil y tablet).
        Transform.translate(
          offset: const Offset(-4, 0),
          child: BotonIconoCuadrado(
            key: const ValueKey('boton-atras-ajustes'),
            icono: IconosApp.back,
            etiqueta: Textos.atras,
            alPresionar: () => PantallaAjustes.volver(context),
          ),
        ),
        const SizedBox(width: 4),
        const Expanded(
          child: TituloEnfocado(Textos.ajustesTitulo, clave: ValueKey('titulo-ajustes')),
        ),
      ],
    );
    final usarSistema = ajustes.modoTema == ThemeMode.system
        ? null
        : Align(
            alignment: Alignment.centerLeft,
            child: BotonApp(
              key: const ValueKey('usar-modo-sistema'),
              texto: Textos.usarModoSistema,
              tipo: TipoBoton.fantasma,
              expandido: false,
              altoMinimo: 48,
              alPresionar: () => alternar(ajustes.copyWith(modoTema: ThemeMode.system)),
            ),
          );

    final clase = context.clasePantalla;
    if (clase.esTablet) {
      return _AjustesTablet(
        dosColumnas: clase.esAncho,
        encabezado: encabezado,
        visual: visual,
        usarSistema: usarSistema,
        motora: motora,
        cognitiva: cognitiva,
        notificaciones: notificaciones,
        legal: legal,
        vistaPrevia: VistaPreviaTexto(porcentaje: ajustes.escalaTexto),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          key: const ValueKey('ajustes-desplazable'),
          padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              encabezado,
              const SizedBox(height: 10),
              Text(
                Textos.ajustesSubtitulo,
                style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
              ),
              const SizedBox(height: 22),
              const EncabezadoSeccionAjustes(Textos.seccionVisual),
              const SizedBox(height: 6),
              visual,
              ?usarSistema,
              const SizedBox(height: 22),
              const EncabezadoSeccionAjustes(Textos.seccionMotora),
              const SizedBox(height: 6),
              motora,
              const SizedBox(height: 22),
              const EncabezadoSeccionAjustes(Textos.seccionCognitiva),
              const SizedBox(height: 6),
              cognitiva,
              const SizedBox(height: 22),
              const EncabezadoSeccionAjustes(Textos.menuNotificaciones),
              const SizedBox(height: 6),
              notificaciones,
              const SizedBox(height: 22),
              const EncabezadoSeccionAjustes(Textos.seccionLegal),
              const SizedBox(height: 6),
              legal,
            ],
          ),
        ),
      ),
    );
  }
}

/// Ajustes en tablet (T26, Figma 101:4759), con el riel (Perfil activo). Con
/// [dosColumnas] (≥ 960): atrás, título y subtítulo arriba; a la izquierda
/// (500) "Visual" y la vista previa; a la derecha (502) "Motor y auditiva" y
/// "Cognitiva". Entre 600 y 959, una columna centrada de hasta 640.
class _AjustesTablet extends StatelessWidget {
  const _AjustesTablet({
    required this.dosColumnas,
    required this.encabezado,
    required this.visual,
    required this.usarSistema,
    required this.motora,
    required this.cognitiva,
    required this.notificaciones,
    required this.legal,
    required this.vistaPrevia,
  });

  static const int flexIzquierda = 500;
  static const int flexDerecha = 502;

  /// Entre secciones (Figma: 28) y entre el título de sección y su tarjeta (6).
  static const double entreSecciones = 28;
  static const double bajoTitulo = 6;

  final bool dosColumnas;
  final Widget encabezado;
  final Widget visual;
  final Widget? usarSistema;
  final Widget motora;
  final Widget cognitiva;
  final Widget notificaciones;
  final Widget legal;
  final Widget vistaPrevia;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final izquierda = <Widget>[
      const EncabezadoSeccionAjustes(Textos.seccionVisual),
      const SizedBox(height: bajoTitulo),
      visual,
      ?usarSistema,
      const SizedBox(height: entreSecciones),
      vistaPrevia,
    ];
    final derecha = <Widget>[
      const EncabezadoSeccionAjustes(Textos.seccionMotora),
      const SizedBox(height: bajoTitulo),
      motora,
      const SizedBox(height: entreSecciones),
      const EncabezadoSeccionAjustes(Textos.seccionCognitiva),
      const SizedBox(height: bajoTitulo),
      cognitiva,
      const SizedBox(height: entreSecciones),
      const EncabezadoSeccionAjustes(Textos.menuNotificaciones),
      const SizedBox(height: bajoTitulo),
      notificaciones,
      const SizedBox(height: entreSecciones),
      const EncabezadoSeccionAjustes(Textos.seccionLegal),
      const SizedBox(height: bajoTitulo),
      legal,
    ];
    final Widget cuerpo = dosColumnas
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: flexIzquierda,
                child: Column(
                  key: const ValueKey('ajustes-columna-izquierda'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: izquierda,
                ),
              ),
              const SizedBox(width: MedidasAdaptativas.medianil),
              Expanded(
                flex: flexDerecha,
                child: Column(
                  key: const ValueKey('ajustes-columna-derecha'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: derecha,
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...izquierda,
              const SizedBox(height: entreSecciones),
              ...derecha,
            ],
          );

    return MarcoPrincipal(
      pestana: PestanaApp.perfil,
      cuerpo: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          key: const ValueKey('ajustes-desplazable'),
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
                children: [
                  encabezado,
                  const SizedBox(height: 12),
                  Text(
                    Textos.ajustesSubtitulo,
                    style: context.estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
                  ),
                  const SizedBox(height: 32),
                  cuerpo,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Hoja "Tamaño de texto": título y las cuatro opciones; se cierra al elegir
/// (devuelve el porcentaje). El foco empieza en la opción actual. En tablet se
/// muestra como diálogo centrado ([enDialogo], todas las esquinas redondeadas).
class SelectorTamano extends StatefulWidget {
  const SelectorTamano({required this.actual, this.enDialogo = false, super.key});

  /// Ancho máximo del diálogo en tablet.
  static const double anchoDialogo = 440;

  final int actual;
  final bool enDialogo;

  @override
  State<SelectorTamano> createState() => _SelectorTamanoState();
}

class _SelectorTamanoState extends State<SelectorTamano> {
  final _focoActual = FocusNode(debugLabel: 'tamaño actual');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focoActual.requestFocus();
    });
  }

  @override
  void dispose() {
    _focoActual.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return DecoratedBox(
      key: const ValueKey('fondo-selector-tamano'),
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        borderRadius: widget.enDialogo
            ? BorderRadius.circular(22)
            : const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          key: const ValueKey('selector-tamano'),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  Textos.tamanoTexto,
                  style: context.estilos.h2.copyWith(color: tokens.textoPrimario),
                ),
              ),
              const SizedBox(height: 12),
              for (final p in Ajustes.escalas)
                OpcionTamano(
                  key: ValueKey('tamano-$p'),
                  porcentaje: p,
                  elegida: p == widget.actual,
                  nodoFoco: p == widget.actual ? _focoActual : null,
                  alElegir: () => Navigator.of(context).pop(p),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
