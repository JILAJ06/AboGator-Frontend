import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../componentes/bloque_lectura.dart';
import '../../../componentes/sarko_imagen.dart';
import '../../../core/adaptativo/clase_pantalla.dart';
import '../../../core/utilidades/extensiones_contexto.dart';
import '../panel_marca.dart';

/// Marco de las pantallas de recuperación de contraseña (31 a 31e, T-13b).
///
/// - Móvil (390 × 844): márgenes de 24, el botón de [cabecera] arriba a la
///   izquierda (y 60 con la barra de estado), el [cuerpo] desplazable y el
///   [pie] abajo.
/// - Tablet: el panel de marca a la izquierda (en vertical, la franja) con
///   Sarko en la [pose] del paso y el formulario en la columna de 470.
class MarcoRecuperacion extends StatelessWidget {
  const MarcoRecuperacion({
    required this.pose,
    required this.cuerpo,
    this.cabecera,
    this.pie,
    super.key,
  });

  final PoseSarko pose;
  final Widget? cabecera;

  /// Contenido en orden (título, textos, campos y botones).
  final List<Widget> cuerpo;

  /// Leyenda al pie (móvil) o al final de la columna (tablet).
  final Widget? pie;

  @override
  Widget build(BuildContext context) {
    final pie = this.pie;
    if (context.clasePantalla.esTablet) {
      return Scaffold(
        body: DisposicionAccesoTablet(
          variante: VariantePanelMarca.inicioSesion,
          pose: pose,
          encabezado: cabecera,
          formulario: Column(
            key: const ValueKey('formulario-recuperacion'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...cuerpo,
              if (pie != null) ...[const SizedBox(height: 24), pie],
            ],
          ),
        ),
      );
    }
    final cabeza = cabecera;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, restricciones) => SingleChildScrollView(
            key: const ValueKey('recuperacion-desplazable'),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            // El pie queda abajo sin medidas intrínsecas: la columna mide al
            // menos el alto disponible y reparte el espacio sobrante.
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: math.max(0, restricciones.maxHeight - 36)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (cabeza != null) Align(alignment: Alignment.centerLeft, child: cabeza),
                      ...cuerpo,
                    ],
                  ),
                  if (pie != null) Padding(padding: const EdgeInsets.only(top: 24), child: pie),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Título de la recuperación (H1, encabezado con el foco al abrir).
class TituloRecuperacion extends StatelessWidget {
  const TituloRecuperacion(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => BloqueLectura(
    key: const ValueKey('titulo-recuperacion'),
    encabezado: true,
    autofocus: true,
    radio: 8,
    child: Text(texto, style: context.estilos.h1.copyWith(color: context.tokens.textoPrimario)),
  );
}

/// Texto de apoyo (Cuerpo/Base texto/secundario).
class TextoRecuperacion extends StatelessWidget {
  const TextoRecuperacion(this.texto, {this.centrado = false, super.key});

  final String texto;
  final bool centrado;

  @override
  Widget build(BuildContext context) => Text(
    texto,
    textAlign: centrado ? TextAlign.center : TextAlign.start,
    style: context.estilos.cuerpoBase.copyWith(color: context.tokens.textoSecundario),
  );
}

/// Nota o leyenda (Leyenda texto/secundario).
class NotaRecuperacion extends StatelessWidget {
  const NotaRecuperacion(this.texto, {this.centrada = false, super.key});

  final String texto;
  final bool centrada;

  @override
  Widget build(BuildContext context) => Text(
    texto,
    textAlign: centrada ? TextAlign.center : TextAlign.start,
    style: context.estilos.leyenda.copyWith(color: context.tokens.textoSecundario),
  );
}
