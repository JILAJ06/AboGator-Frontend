import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
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

  /// Color del texto del cambio (chips de impacto y "+10" junto a la barra):
  /// el de la barra, salvo Presupuesto, que usa texto/acento para tener
  /// contraste de texto (como en Figma 12c).
  Color colorTexto(TokensColor t) =>
      this == IndicadorStartup.presupuesto ? t.textoAcento : color(t);

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
///
/// Con [cambios] (mientras está abierto un panel de veredicto) muestra el
/// cambio con signo junto a cada barra que se movió, como en Figma 14. El
/// relleno se anima al nuevo valor (salta con "reducir animaciones").
class IndicadoresStartup extends StatelessWidget {
  const IndicadoresStartup({required this.estado, this.cambios = const {}, super.key});

  static const double anchoBarra = 68;

  /// Con un cambio al lado, la barra se acorta para que las 4 columnas sigan
  /// en una fila (en Figma 14 la pista es flexible).
  static const double anchoBarraConCambio = 44;
  static const double altoBarra = 6;

  final EstadoStartup estado;

  /// Cambio de cada indicador; los que valen 0 no se muestran.
  final Map<IndicadorStartup, int> cambios;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 46),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.bordeDefault),
      ),
      // Columnas de ancho intrínseco con espacio uniforme entre ellas. Con
      // texto grande o pantallas angostas pasan a una segunda fila en vez de
      // cortar palabras.
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 8,
        children: [
          for (final indicador in IndicadorStartup.values)
            _Columna(
              indicador: indicador,
              valor: indicador.valorEn(estado),
              cambio: cambios[indicador] ?? 0,
            ),
        ],
      ),
    );
  }
}

class _Columna extends StatelessWidget {
  const _Columna({required this.indicador, required this.valor, required this.cambio});

  final IndicadorStartup indicador;
  final int valor;
  final int cambio;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final acotado = valor.clamp(0, 100);
    final anchoPista = cambio == 0
        ? IndicadoresStartup.anchoBarra
        : IndicadoresStartup.anchoBarraConCambio;
    return Semantics(
      label: cambio == 0
          ? Textos.indicadorValor(indicador.nombre, acotado)
          : '${Textos.indicadorValor(indicador.nombre, acotado)}, ${Textos.impactoValor(cambio)}',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: anchoPista,
                height: IndicadoresStartup.altoBarra,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: tokens.fondoSuperficieAlt,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      key: ValueKey('relleno-${indicador.name}'),
                      duration: EfectosApp.duracion(context, milisegundos: 400),
                      curve: Curves.easeOut,
                      width: anchoPista * acotado / 100,
                      decoration: BoxDecoration(
                        color: indicador.color(tokens),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              if (cambio != 0) ...[
                const SizedBox(width: 4),
                Text(
                  Textos.impactoValor(cambio),
                  key: ValueKey('cambio-${indicador.name}'),
                  style: context.estilos.leyenda.copyWith(
                    color: indicador.colorTexto(tokens),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
