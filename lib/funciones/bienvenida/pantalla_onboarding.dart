import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../componentes/anillo_foco.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/paginador_puntos.dart';
import '../../core/adaptativo/clase_pantalla.dart';
import '../../core/tema/efectos.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../ajustes/estado_ajustes.dart';
import 'flujo_bienvenida.dart';
import 'ilustraciones_onboarding.dart';

/// Contenido de cada página del onboarding.
class PaginaOnboarding {
  const PaginaOnboarding({
    required this.titulo,
    required this.texto,
    required this.boton,
    this.huecoTexto = 12,
  });

  final String titulo;
  final String texto;
  final String boton;

  /// Hueco entre título y texto (10 en la página 2, 12 en las demás).
  final double huecoTexto;

  /// Pantallas 02, 03, 03b y 04.
  static const List<PaginaOnboarding> todas = [
    PaginaOnboarding(
      titulo: Textos.onboarding1Titulo,
      texto: Textos.onboarding1Texto,
      boton: Textos.onboardingSiguiente,
    ),
    PaginaOnboarding(
      titulo: Textos.onboarding2Titulo,
      texto: Textos.onboarding2Texto,
      boton: Textos.onboardingSiguiente,
      huecoTexto: 10,
    ),
    PaginaOnboarding(
      titulo: Textos.onboarding3Titulo,
      texto: Textos.onboarding3Texto,
      boton: Textos.onboardingSiguiente,
    ),
    PaginaOnboarding(
      titulo: Textos.onboarding4Titulo,
      texto: Textos.onboarding4Texto,
      boton: Textos.onboardingComenzar,
    ),
  ];
}

/// Pantallas 02–04 · Onboarding: un paginador de 4 páginas con "Omitir".
class PantallaOnboarding extends ConsumerStatefulWidget {
  const PantallaOnboarding({super.key});

  @override
  ConsumerState<PantallaOnboarding> createState() => _PantallaOnboardingState();
}

class _PantallaOnboardingState extends ConsumerState<PantallaOnboarding> {
  var _controlador = PageController();
  int _pagina = 0;

  static const _paginas = PaginaOnboarding.todas;

  bool get _esUltima => _pagina == _paginas.length - 1;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _terminar() async {
    final destino = await ref.read(flujoBienvenidaProvider).terminarOnboarding();
    if (mounted) {
      context.go(destino);
    }
  }

  void _siguiente() {
    if (_esUltima) {
      _terminar();
      return;
    }
    // En tablet no hay PageView: se cambia de página directamente.
    if (!_controlador.hasClients) {
      setState(() => _pagina++);
      return;
    }
    final duracion = EfectosApp.duracion(context, milisegundos: 250);
    if (duracion == Duration.zero) {
      _controlador.jumpToPage(_pagina + 1);
    } else {
      _controlador.nextPage(duration: duracion, curve: Curves.easeOut);
    }
  }

  /// Deslizar en tablet (T-13): hacia la izquierda pasa a la siguiente
  /// página y hacia la derecha vuelve a la anterior, como el PageView del
  /// móvil (en la última página no termina el onboarding: eso es del botón).
  void _alDeslizar(DragEndDetails detalles, double recorrido) {
    final velocidad = detalles.primaryVelocity ?? 0;
    final haciaIzquierda = recorrido < -umbralDeslizar || velocidad < -velocidadDeslizar;
    final haciaDerecha = recorrido > umbralDeslizar || velocidad > velocidadDeslizar;
    if (haciaIzquierda && !_esUltima) {
      setState(() => _pagina++);
    } else if (haciaDerecha && _pagina > 0) {
      setState(() => _pagina--);
    }
  }

  /// Recorrido (dp) o velocidad (dp/s) mínimos para cambiar de página.
  static const double umbralDeslizar = 48;
  static const double velocidadDeslizar = 300;

  @override
  Widget build(BuildContext context) {
    // "Botones en lugar de deslizar": las páginas solo cambian con el botón.
    final soloBotones = ref.watch(ajustesProvider.select((a) => a.soloBotones));
    if (context.clasePantalla.esTablet) {
      var recorrido = 0.0;
      final tablet = _OnboardingTablet(
        indice: _pagina,
        pagina: _paginas[_pagina],
        total: _paginas.length,
        alSiguiente: _siguiente,
        alOmitir: _terminar,
      );
      return Scaffold(
        body: soloBotones
            ? tablet
            : GestureDetector(
                key: const ValueKey('deslizar-onboarding'),
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: (_) => recorrido = 0,
                onHorizontalDragUpdate: (d) => recorrido += d.primaryDelta ?? 0,
                onHorizontalDragEnd: (d) => _alDeslizar(d, recorrido),
                child: tablet,
              ),
      );
    }
    // Al pasar de tablet a móvil (rotar) el PageView empieza en la página actual.
    if (!_controlador.hasClients && _controlador.initialPage != _pagina) {
      _controlador.dispose();
      _controlador = PageController(initialPage: _pagina);
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _BotonOmitir(alPresionar: _terminar),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: PageView.builder(
                controller: _controlador,
                physics: soloBotones ? const NeverScrollableScrollPhysics() : null,
                itemCount: _paginas.length,
                onPageChanged: (i) => setState(() => _pagina = i),
                itemBuilder: (context, i) => _ContenidoPagina(indice: i, pagina: _paginas[i]),
              ),
            ),
            const SizedBox(height: 8),
            PaginadorPuntos(total: _paginas.length, actual: _pagina),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: BotonApp(texto: _paginas[_pagina].boton, alPresionar: _siguiente),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

/// 02 a 04 en tablet (Figma T02 94:86, T03 94:132, T03b 94:252 y T04 94:390).
///
/// En horizontal (≥ 960): a la izquierda un panel de fondo/superficie (la mitad,
/// hasta 597) con la misma ilustración del móvil 1.55 veces más grande (el
/// círculo de 300 pasa a 465) y centrada; a la derecha, en una columna de 470
/// centrada, el título (H1), el texto (Cuerpo/Grande), el paginador y el botón,
/// alineados a la izquierda y con separación 20 (48 antes del paginador).
/// "Omitir" arriba a la derecha.
///
/// Entre 600 y 959, la ilustración arriba y la columna de 470 debajo. Las
/// páginas cambian con un fundido corto (sin animación con "reducir
/// animaciones").
class _OnboardingTablet extends StatelessWidget {
  const _OnboardingTablet({
    required this.indice,
    required this.pagina,
    required this.total,
    required this.alSiguiente,
    required this.alOmitir,
  });

  /// La ilustración del móvil escalada (Figma: círculo de 465 en lugar de 300).
  static const double escalaIlustracion = 1.55;

  /// Escala de la ilustración en tablet vertical (decisión propia).
  static const double escalaVertical = 1.2;

  /// Ancho del lienzo que debe caber en el panel: en Figma el lienzo escalado
  /// (604.5) pasa 7.5 del panel de 597, así que cabe con 597 / 1.55.
  static const double anchoUtilIlustracion = anchoPanel / escalaIlustracion;

  /// Ancho máximo del panel de la ilustración (la mitad del lienzo de Figma).
  static const double anchoPanel = 597;

  final int indice;
  final PaginaOnboarding pagina;
  final int total;
  final VoidCallback alSiguiente;
  final VoidCallback alOmitir;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final duracion = EfectosApp.duracion(context, milisegundos: 250);

    // La ilustración del móvil a una escala exacta. El lienzo de 390 tiene
    // márgenes vacíos a los lados, así que puede pasar un poco del panel (se
    // recorta), como en Figma.
    Widget ilustracion(double escala) => SizedBox(
      width: LienzoOnboarding.ancho * escala,
      height: LienzoOnboarding.alto * escala,
      child: AnimatedSwitcher(
        duration: duracion,
        // SizedBox.expand: el Stack del AnimatedSwitcher da restricciones
        // sueltas y el FittedBox no crecería.
        child: SizedBox.expand(
          key: ValueKey('ilustracion-tablet-$indice'),
          child: FittedBox(child: LienzoOnboarding(pagina: indice)),
        ),
      ),
    );

    /// Escala que cabe en [restricciones] sin pasar de [maxima].
    double escalaQueCabe(BoxConstraints restricciones, double maxima) => math.min(
      maxima,
      math.min(
        restricciones.maxWidth / anchoUtilIlustracion,
        restricciones.maxHeight / LienzoOnboarding.alto,
      ),
    );

    final contenido = AnimatedSwitcher(
      duration: duracion,
      layoutBuilder: (actual, anteriores) =>
          Stack(alignment: Alignment.topLeft, children: [...anteriores, ?actual]),
      child: Column(
        key: ValueKey('contenido-tablet-$indice'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(pagina.titulo, style: estilos.h1.copyWith(color: tokens.textoPrimario)),
          ),
          const SizedBox(height: 20),
          Text(pagina.texto, style: estilos.cuerpoGrande.copyWith(color: tokens.textoSecundario)),
        ],
      ),
    );

    final columna = ConstrainedBox(
      key: const ValueKey('columna-onboarding'),
      constraints: const BoxConstraints(maxWidth: MedidasAdaptativas.columnaFormulario),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          contenido,
          // Figma: 20 + espacio de 8 + 20 antes del paginador.
          const SizedBox(height: 48),
          Align(
            alignment: Alignment.centerLeft,
            child: PaginadorPuntos(total: total, actual: indice),
          ),
          const SizedBox(height: 20),
          BotonApp(texto: pagina.boton, alPresionar: alSiguiente),
        ],
      ),
    );

    Widget desplazable(Widget hijo) => LayoutBuilder(
      builder: (context, restricciones) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: MedidasAdaptativas.margen, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: math.max(0, restricciones.maxHeight - 48)),
          child: Center(child: hijo),
        ),
      ),
    );

    final omitir = Align(
      alignment: Alignment.topRight,
      child: Padding(
        // Figma: el texto termina en el margen de 32 (12 de relleno propio).
        padding: const EdgeInsets.only(right: MedidasAdaptativas.margen - 12, top: 8),
        child: _BotonOmitir(alPresionar: alOmitir),
      ),
    );

    return LayoutBuilder(
      builder: (context, restricciones) {
        if (ClasePantalla.deAncho(restricciones.maxWidth).esAncho) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: math.min(anchoPanel, restricciones.maxWidth / 2),
                child: ColoredBox(
                  key: const ValueKey('panel-ilustracion'),
                  color: tokens.fondoSuperficie,
                  child: SafeArea(
                    right: false,
                    child: LayoutBuilder(
                      builder: (context, panel) => ClipRect(
                        child: OverflowBox(
                          maxWidth: double.infinity,
                          maxHeight: double.infinity,
                          child: ilustracion(escalaQueCabe(panel, escalaIlustracion)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SafeArea(
                  left: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      omitir,
                      Expanded(child: desplazable(columna)),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              omitir,
              Expanded(
                child: desplazable(
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LayoutBuilder(
                        builder: (context, caja) => ilustracion(
                          math.min(escalaVertical, caja.maxWidth / LienzoOnboarding.ancho),
                        ),
                      ),
                      const SizedBox(height: 32),
                      columna,
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContenidoPagina extends StatelessWidget {
  const _ContenidoPagina({required this.indice, required this.pagina});

  final int indice;
  final PaginaOnboarding pagina;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return LayoutBuilder(
      builder: (context, restricciones) {
        // El lienzo cede espacio al texto en pantallas bajas.
        final altoLienzo = (restricciones.maxHeight - 180).clamp(160.0, LienzoOnboarding.alto);
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: altoLienzo,
                child: Center(child: LienzoOnboarding(pagina: indice)),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 330),
                  child: Column(
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          pagina.titulo,
                          style: estilos.h1.copyWith(color: tokens.textoPrimario),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: pagina.huecoTexto),
                      Text(
                        pagina.texto,
                        style: estilos.cuerpoGrande.copyWith(color: tokens.textoSecundario),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

/// "Omitir": texto Cuerpo/Énfasis en texto/secundario, zona táctil ≥ 48 y
/// anillo de foco con teclado.
class _BotonOmitir extends StatefulWidget {
  const _BotonOmitir({required this.alPresionar});

  final VoidCallback alPresionar;

  @override
  State<_BotonOmitir> createState() => _BotonOmitirState();
}

class _BotonOmitirState extends State<_BotonOmitir> {
  bool _foco = false;
  static const double _radio = 12;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: Textos.onboardingOmitir,
      onTap: widget.alPresionar,
      excludeSemantics: true,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (valor) => setState(() => _foco = valor),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.alPresionar();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.alPresionar,
          child: AnilloFoco(
            visible: _foco,
            radio: _radio,
            // Alto de 48 y ancho del texto + 12 por lado (≥ 48): no se estira.
            child: ConstrainedBox(
              key: const ValueKey('boton-omitir'),
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    Textos.onboardingOmitir,
                    style: context.estilos.cuerpoEnfasis.copyWith(
                      color: context.tokens.textoSecundario,
                    ),
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
