import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'boton_icono_caja.dart';
import 'chip_hud.dart';

/// Encabezado del mapa de sprints (Figma 13:574): fondo del color del módulo,
/// botón atrás de 48 (blanco al 18 %, radio 12), etiqueta "MÓDULO N · NOMBRE"
/// (Leyenda, color del módulo mezclado con blanco al 85 %), título del tramo
/// (H2 blanco), chip de vidas y barra de avance de 8 (pista blanca al 25 %,
/// relleno ámbar claro, radio 4) con "n/total".
///
/// En Figma mide 150 contando la barra de estado de 48: aquí la zona segura
/// superior ocupa ese lugar (mínimo [altoBarraEstado]) y el contenido mide 102.
/// Si el texto blanco no alcanza 4.5:1 sobre el color del módulo, el fondo se
/// oscurece lo mínimo (`EfectosApp.fondoEncabezado`).
class EncabezadoModulo extends StatelessWidget {
  const EncabezadoModulo({
    required this.numero,
    required this.nombreCorto,
    required this.titulo,
    required this.color,
    required this.vidas,
    required this.completados,
    required this.total,
    required this.alAtras,
    this.arribaMinimo = altoBarraEstado,
    this.abajoExtra = 0,
    super.key,
  });

  /// Medidas de tablet (T08, Figma 96:717): sin barra de estado propia, el
  /// contenido empieza 16 abajo y el encabezado mide 16 + 102 + 16 = 134.
  static const double arribaTablet = 16;
  static const double abajoTablet = 16;

  /// Alto de la barra de estado del marco de Figma.
  static const double altoBarraEstado = 48;

  /// Alto del contenido debajo de la barra de estado (150 − 48).
  static const double altoContenido = 102;
  static const double radioAtras = 12;
  static const double altoBarra = 8;

  final int numero;
  final String nombreCorto;
  final String titulo;

  /// Color del módulo.
  final Color color;
  final int vidas;
  final int completados;
  final int total;
  final VoidCallback? alAtras;

  /// Espacio mínimo arriba del contenido (la zona segura, si es mayor, manda).
  final double arribaMinimo;

  /// Alto que se suma abajo (tablet).
  final double abajoExtra;

  @override
  Widget build(BuildContext context) {
    final estilos = context.estilos;
    const blanco = EfectosApp.textoEncabezado;
    final fondo = EfectosApp.fondoEncabezado(color);
    final etiqueta = Textos.moduloEtiqueta(numero, nombreCorto);
    final arriba = math.max(MediaQuery.paddingOf(context).top, arribaMinimo);
    final avance = total == 0 ? 0.0 : (completados / total).clamp(0.0, 1.0);

    return Container(
      key: const ValueKey('encabezado-modulo'),
      color: fondo,
      constraints: BoxConstraints(minHeight: arriba + altoContenido + abajoExtra),
      padding: EdgeInsets.only(top: arriba, bottom: 21 + abajoExtra),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BotonAtrasEncabezado(alPresionar: alAtras),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Semantics(
                      header: true,
                      label: '$etiqueta. $titulo',
                      excludeSemantics: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            etiqueta,
                            style: estilos.leyenda.copyWith(
                              color: EfectosApp.etiquetaEncabezado(fondo),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(titulo, style: estilos.h2.copyWith(color: blanco)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(padding: const EdgeInsets.only(top: 8), child: ChipHud.vidas(vidas)),
              ],
            ),
          ),
          // En Figma "n/5" (16 de alto) queda centrado en la barra de 8.
          const SizedBox(height: 13),
          Semantics(
            label: Textos.avanceModuloSemantica(completados, total),
            value: '${(avance * 100).round()} %',
            excludeSemantics: true,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 40),
              child: Row(
                children: [
                  Expanded(child: _BarraAvance(valor: avance)),
                  const SizedBox(width: 12),
                  Text(
                    Textos.avanceModulo(completados, total),
                    style: estilos.etiqueta.copyWith(color: blanco),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarraAvance extends StatelessWidget {
  const _BarraAvance({required this.valor});

  final double valor;

  @override
  Widget build(BuildContext context) {
    const radio = BorderRadius.all(Radius.circular(EncabezadoModulo.altoBarra / 2));
    return LayoutBuilder(
      builder: (context, restricciones) => Container(
        key: const ValueKey('barra-encabezado'),
        height: EncabezadoModulo.altoBarra,
        alignment: Alignment.centerLeft,
        decoration: const BoxDecoration(color: EfectosApp.pistaEncabezado, borderRadius: radio),
        child: Container(
          key: const ValueKey('relleno-encabezado'),
          width: restricciones.maxWidth * valor,
          decoration: const BoxDecoration(color: EfectosApp.rellenoEncabezado, borderRadius: radio),
        ),
      ),
    );
  }
}

class _BotonAtrasEncabezado extends StatelessWidget {
  const _BotonAtrasEncabezado({required this.alPresionar});

  final VoidCallback? alPresionar;

  @override
  Widget build(BuildContext context) => BotonIconoCaja(
    claveCaja: const ValueKey('atras-encabezado'),
    icono: IconosApp.back,
    etiqueta: Textos.atras,
    alPresionar: alPresionar,
    fondo: EfectosApp.fondoAtrasEncabezado,
    conBorde: false,
    colorIcono: EfectosApp.textoEncabezado,
  );
}
