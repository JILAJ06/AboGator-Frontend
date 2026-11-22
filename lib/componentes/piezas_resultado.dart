import 'dart:ui' show PathMetric;

import 'package:material_ui/material_ui.dart';

import '../core/recursos/imagenes_app.dart';
import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'caja_superficie.dart';
import 'esqueleto_pantalla.dart';
import 'icono_app.dart';
import 'logo_app.dart';

/// Borde punteado de un rectángulo redondeado (trazo 2, guion 6 y hueco 4),
/// sin dependencias: recorre el contorno con `PathMetric`.
class PintorBordePunteado extends CustomPainter {
  const PintorBordePunteado({
    required this.color,
    this.radio = 20,
    this.grosor = 2,
    this.guion = 6,
    this.hueco = 4,
  });

  final Color color;
  final double radio;
  final double grosor;
  final double guion;
  final double hueco;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(grosor / 2);
    final contorno = Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radio)));
    final pincel = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor;
    for (final PathMetric tramo in contorno.computeMetrics()) {
      var d = 0.0;
      while (d < tramo.length) {
        canvas.drawPath(tramo.extractPath(d, d + guion), pincel);
        d += guion + hueco;
      }
    }
  }

  @override
  bool shouldRepaint(PintorBordePunteado old) =>
      old.color != color || old.radio != radio || old.grosor != grosor;
}

/// Tarjeta del certificado (Figma 29): fondo/superficie, borde 2 punteado
/// accion/acento, radio 20, relleno 20, separación 8 y todo centrado: el logo
/// horizontal, "CERTIFICADO DE MÓDULO", el módulo, el detalle y el folio. Se
/// lee como un solo bloque ([etiquetaSemantica]).
class TarjetaCertificado extends StatelessWidget {
  const TarjetaCertificado({
    required this.modulo,
    required this.detalle,
    required this.folio,
    required this.etiquetaSemantica,
    super.key,
  });

  static const double radio = 20;

  final String modulo;
  final String detalle;
  final String folio;
  final String etiquetaSemantica;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    // Si "Ana López · 9/10 aciertos · fecha" no cabe, parte en el "·".
    final partes = detalle.split(' · ');
    return Semantics(
      container: true,
      label: etiquetaSemantica,
      excludeSemantics: true,
      child: CustomPaint(
        key: const ValueKey('tarjeta-certificado'),
        // Encima del fondo de la tarjeta (si no, el fondo lo tapa).
        foregroundPainter: PintorBordePunteado(color: tokens.accionAcento),
        child: CajaSuperficie(
          ancho: double.infinity,
          relleno: const EdgeInsets.all(20),
          radio: radio,
          child: Column(
            children: [
              const LogoApp(forma: FormaLogo.horizontal, ancho: 178, decorativo: true),
              const SizedBox(height: 8),
              Text(
                Textos.certificadoDeModulo,
                textAlign: TextAlign.center,
                style: estilos.etiqueta.copyWith(color: tokens.textoAcento),
              ),
              const SizedBox(height: 8),
              Text(
                modulo,
                textAlign: TextAlign.center,
                style: estilos.h2.copyWith(color: tokens.textoPrimario),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  for (final (i, p) in partes.indexed)
                    Text(
                      i < partes.length - 1 ? '$p · ' : p,
                      style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                Textos.folio(folio),
                key: const ValueKey('folio-certificado'),
                textAlign: TextAlign.center,
                style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Esqueleto de la tarjeta del certificado mientras se registra.
class EsqueletoCertificado extends StatelessWidget {
  const EsqueletoCertificado({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    Widget bloque(double alto, double ancho) => BloqueEsqueleto(alto, ancho: ancho, radio: 8);
    return CustomPaint(
      key: const ValueKey('esqueleto-certificado'),
      foregroundPainter: PintorBordePunteado(color: tokens.bordeDefault),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            bloque(43, 178),
            const SizedBox(height: 8),
            bloque(16, 150),
            const SizedBox(height: 8),
            bloque(26, 260),
            const SizedBox(height: 8),
            bloque(14, 220),
            const SizedBox(height: 4),
            bloque(14, 120),
          ],
        ),
      ),
    );
  }
}

/// Trofeo de 29 (Figma 18:2936): círculo de 96 accion/acento con borde 6
/// fondo/destacado y `trophy` de 48. Decorativo.
class TrofeoCertificado extends StatelessWidget {
  const TrofeoCertificado({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ExcludeSemantics(
      child: Container(
        key: const ValueKey('trofeo'),
        width: 96,
        height: 96,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tokens.accionAcento,
          shape: BoxShape.circle,
          border: Border.all(color: tokens.fondoDestacado, width: 6),
        ),
        child: IconoApp(IconosApp.trophy, tamano: 48, color: tokens.textoEnPrimario),
      ),
    );
  }
}

/// Una tarjeta del resumen de 30: fondo/superficie, borde 1, radio 16,
/// relleno vertical 12; valor en Título/H2 y etiqueta en Leyenda.
class _TarjetaResumenExamen extends StatelessWidget {
  const _TarjetaResumenExamen({
    required this.valor,
    required this.etiqueta,
    required this.colorValor,
    super.key,
  });

  final String valor;
  final String etiqueta;
  final Color colorValor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return CajaSuperficie(
      ancho: double.infinity,
      relleno: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      conBorde: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            valor,
            textAlign: TextAlign.center,
            style: context.estilos.h2.copyWith(color: colorValor),
          ),
          const SizedBox(height: 2),
          Text(
            etiqueta,
            textAlign: TextAlign.center,
            style: context.estilos.leyenda.copyWith(color: tokens.textoSecundario),
          ),
        ],
      ),
    );
  }
}

/// Resumen de 30 (Figma 18:3100): "N/10 · Llegaste a", "N · Aciertos" y
/// "N · Por tiempo", en fila con separación 10 (en columna a partir de 1.5× de
/// texto). Se lee como un solo bloque.
class FilaResumenExamen extends StatelessWidget {
  const FilaResumenExamen({
    required this.jugadas,
    required this.total,
    required this.aciertos,
    required this.porTiempo,
    super.key,
  });

  /// Escala de texto a partir de la cual las tarjetas van en columna.
  static const double escalaColumna = 1.5;

  final int jugadas;
  final int total;
  final int aciertos;
  final int porTiempo;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final tarjetas = [
      _TarjetaResumenExamen(
        key: const ValueKey('resumen-llegaste'),
        valor: Textos.llegasteValor(jugadas, total),
        etiqueta: Textos.llegasteA,
        colorValor: tokens.textoPrimario,
      ),
      _TarjetaResumenExamen(
        key: const ValueKey('resumen-aciertos'),
        valor: '$aciertos',
        etiqueta: Textos.aciertos,
        colorValor: tokens.estadoLegal,
      ),
      _TarjetaResumenExamen(
        key: const ValueKey('resumen-tiempo'),
        valor: '$porTiempo',
        etiqueta: Textos.porTiempo,
        colorValor: tokens.estadoIlegal,
      ),
    ];
    final enColumna = MediaQuery.textScalerOf(context).scale(1) >= escalaColumna;
    return Semantics(
      container: true,
      label: Textos.resumenExamenSemantica(jugadas, total, aciertos, porTiempo),
      excludeSemantics: true,
      child: enColumna
          ? Column(
              key: const ValueKey('resumen-examen'),
              children: [
                for (final (i, t) in tarjetas.indexed) ...[
                  if (i > 0) const SizedBox(height: 10),
                  t,
                ],
              ],
            )
          : IntrinsicHeight(
              key: const ValueKey('resumen-examen'),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, t) in tarjetas.indexed) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(child: t),
                  ],
                ],
              ),
            ),
    );
  }
}
