import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/tema/tokens_color.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import '../datos/modelos/estado_startup.dart';
import 'icono_app.dart';

/// Los cuatro indicadores de la Startup, con su ícono, nombre y color.
enum IndicadorStartup {
  presupuesto(IconosApp.coin, Textos.indicadorPresupuesto),
  reputacion(IconosApp.star, Textos.indicadorReputacion),
  velocidad(IconosApp.zap, Textos.indicadorVelocidad),
  riesgoLegal(IconosApp.alert, Textos.indicadorRiesgoLegal);

  const IndicadorStartup(this.icono, this.nombre);

  final IconData icono;
  final String nombre;

  Color color(TokensColor t) => switch (this) {
    IndicadorStartup.presupuesto => t.accionAcento,
    IndicadorStartup.reputacion => t.estadoCondicional,
    IndicadorStartup.velocidad => t.estadoLegal,
    IndicadorStartup.riesgoLegal => t.estadoIlegal,
  };

  int valorEn(EstadoStartup e) => switch (this) {
    IndicadorStartup.presupuesto => e.presupuesto,
    IndicadorStartup.reputacion => e.reputacion,
    IndicadorStartup.velocidad => e.velocidad,
    IndicadorStartup.riesgoLegal => e.riesgoLegal,
  };
}

/// Panel con los cuatro indicadores: radio 16, relleno 10, cuatro columnas
/// con espacio uniforme. Cada barra mide 68×6 y se llena según el valor (0–100).
class IndicadoresStartup extends StatelessWidget {
  const IndicadoresStartup({required this.estado, super.key});

  static const double anchoBarra = 68;
  static const double altoBarra = 6;

  final EstadoStartup estado;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.bordeDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final indicador in IndicadorStartup.values)
            Expanded(
              child: _Columna(indicador: indicador, valor: indicador.valorEn(estado)),
            ),
        ],
      ),
    );
  }
}

class _Columna extends StatelessWidget {
  const _Columna({required this.indicador, required this.valor});

  final IndicadorStartup indicador;
  final int valor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final acotado = valor.clamp(0, 100);
    return Semantics(
      label: Textos.indicadorValor(indicador.nombre, acotado),
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconoApp(indicador.icono, tamano: 14, color: indicador.color(tokens)),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  indicador.nombre,
                  style: context.estilos.leyenda.copyWith(color: tokens.textoSecundario),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, restricciones) {
              final ancho = restricciones.maxWidth < IndicadoresStartup.anchoBarra
                  ? restricciones.maxWidth
                  : IndicadoresStartup.anchoBarra;
              return SizedBox(
                width: ancho,
                height: IndicadoresStartup.altoBarra,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: tokens.fondoSuperficieAlt,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: ancho * acotado / 100,
                      decoration: BoxDecoration(
                        color: indicador.color(tokens),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
