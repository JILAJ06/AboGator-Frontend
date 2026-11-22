import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'caja_superficie.dart';
import 'icono_app.dart';

/// "Tu semana" del Inicio en tablet (Figma 96:543): fondo/superficie, borde 1
/// borde/default, radio 20, relleno 20 y separación 12. Título (H3) y tres
/// estadísticas iguales en fila (fondo/superficie-alt, radio 14, relleno 12,
/// ícono de 20, valor en H3 y etiqueta en Leyenda): racha, precisión y monedas.
///
/// Sin [precision] (cargando o con error) muestra "—". Con texto grande, si
/// las tres no caben en fila, se apilan. Solo presentación.
class TarjetaSemana extends StatelessWidget {
  const TarjetaSemana({
    required this.racha,
    required this.precision,
    required this.monedas,
    super.key,
  });

  static const double radio = 20;
  static const double radioEstadistica = 14;

  final int racha;

  /// Porcentaje de aciertos (0 a 100); `null` si no se pudo cargar.
  final int? precision;
  final int monedas;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final precisionTexto = precision == null
        ? Textos.semanaSinDato
        : Textos.semanaPorcentaje(precision!);
    final estadisticas = [
      _Estadistica(
        key: const ValueKey('semana-racha'),
        icono: IconosApp.flame,
        color: tokens.accionAcento,
        valor: Textos.semanaDias(racha),
        etiqueta: Textos.semanaRacha,
      ),
      _Estadistica(
        key: const ValueKey('semana-precision'),
        icono: IconosApp.check,
        color: tokens.accionPrimaria,
        valor: precisionTexto,
        valorSemantico: precision == null ? Textos.semanaSinDatoSemantica : precisionTexto,
        etiqueta: Textos.semanaPrecision,
      ),
      _Estadistica(
        key: const ValueKey('semana-monedas'),
        icono: IconosApp.coin,
        color: tokens.accionAcento,
        valor: '$monedas',
        etiqueta: Textos.semanaMonedas,
      ),
    ];

    return CajaSuperficie(
      clave: const ValueKey('tarjeta-semana'),
      relleno: const EdgeInsets.all(20),
      radio: radio,
      conBorde: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              Textos.semanaTitulo,
              style: context.estilos.h3.copyWith(color: tokens.textoPrimario),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, restricciones) {
              final escala = MediaQuery.textScalerOf(context).scale(1);
              final apilar = escala > 1.5 || restricciones.maxWidth < 280;
              if (apilar) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, e) in estadisticas.indexed) ...[
                      if (i > 0) const SizedBox(height: 12),
                      e,
                    ],
                  ],
                );
              }
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, e) in estadisticas.indexed) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(child: e),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Estadistica extends StatelessWidget {
  const _Estadistica({
    required this.icono,
    required this.color,
    required this.valor,
    required this.etiqueta,
    this.valorSemantico,
    super.key,
  });

  final IconData icono;
  final Color color;
  final String valor;
  final String? valorSemantico;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return Semantics(
      container: true,
      label: Textos.semanaEstadistica(etiqueta, valorSemantico ?? valor),
      excludeSemantics: true,
      child: CajaSuperficie(
        relleno: const EdgeInsets.all(12),
        fondo: FondoCaja.superficieAlt,
        radio: TarjetaSemana.radioEstadistica,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconoApp(icono, tamano: 20, color: color),
            const SizedBox(height: 4),
            Text(valor, style: estilos.h3.copyWith(color: tokens.textoPrimario)),
            const SizedBox(height: 4),
            Text(etiqueta, style: estilos.leyenda.copyWith(color: tokens.textoSecundario)),
          ],
        ),
      ),
    );
  }
}
