import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../componentes/anillo_foco.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/paginador_puntos.dart';
import '../../core/tema/efectos.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
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
  final _controlador = PageController();
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
    final duracion = EfectosApp.duracion(context, milisegundos: 250);
    if (duracion == Duration.zero) {
      _controlador.jumpToPage(_pagina + 1);
    } else {
      _controlador.nextPage(duration: duracion, curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
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
