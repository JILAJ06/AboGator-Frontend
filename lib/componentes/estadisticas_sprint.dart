import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'bloque_lectura.dart';
import 'caja_superficie.dart';
import 'icono_app.dart';

/// Tres tarjetas con el resultado del sprint (19): aciertos, XP (con bonus) y
/// monedas. Cada una: `fondo/superficie`, borde 1 `borde/default`, radio 18,
/// relleno vertical 12; ícono de 20, valor Título/H2 y etiqueta Leyenda.
/// Se leen como un bloque: "8 de 10 aciertos, 95 XP con bonus, 45 monedas".
class EstadisticasSprint extends StatelessWidget {
  const EstadisticasSprint({
    required this.aciertos,
    required this.total,
    required this.xp,
    required this.monedas,
    super.key,
  });

  static const double separacion = 10;
  static const double radio = 18;
  static const double tamanoIcono = 20;

  final int aciertos;
  final int total;
  final int xp;
  final int monedas;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return BloqueLectura(
      etiqueta: Textos.estadisticasSemantica(aciertos, total, xp, monedas),
      excluirHijos: true,
      radio: radio,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _Estadistica(
                key: const ValueKey('estadistica-aciertos'),
                icono: IconosApp.check,
                colorIcono: tokens.estadoLegal,
                valor: Textos.valorAciertos(aciertos, total),
                etiqueta: Textos.estadisticaAciertos,
              ),
            ),
            const SizedBox(width: separacion),
            Expanded(
              child: _Estadistica(
                key: const ValueKey('estadistica-xp'),
                icono: IconosApp.star,
                colorIcono: tokens.accionPrimaria,
                valor: Textos.valorGanado(xp),
                etiqueta: Textos.estadisticaXp,
              ),
            ),
            const SizedBox(width: separacion),
            Expanded(
              child: _Estadistica(
                key: const ValueKey('estadistica-monedas'),
                icono: IconosApp.coin,
                colorIcono: tokens.accionAcento,
                valor: Textos.valorGanado(monedas),
                etiqueta: Textos.estadisticaMonedas,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Estadistica extends StatelessWidget {
  const _Estadistica({
    required this.icono,
    required this.colorIcono,
    required this.valor,
    required this.etiqueta,
    super.key,
  });

  final IconData icono;
  final Color colorIcono;
  final String valor;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return CajaSuperficie(
      relleno: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      radio: EstadisticasSprint.radio,
      conBorde: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconoApp(icono, tamano: EstadisticasSprint.tamanoIcono, color: colorIcono),
          const SizedBox(height: 4),
          Text(
            valor,
            style: estilos.h2.copyWith(color: tokens.textoPrimario),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            etiqueta,
            style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
