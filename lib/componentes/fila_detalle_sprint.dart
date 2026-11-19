import 'package:material_ui/material_ui.dart';

import '../core/utilidades/extensiones_contexto.dart';
import 'icono_app.dart';

/// Fila de detalle de la intro del sprint (Figma 13:850): ícono de 22 en
/// accion/primaria, título en Cuerpo/Énfasis y texto en Leyenda
/// texto/secundario (separación 2), relleno vertical 12 y 12 entre ícono y
/// texto. Se lee como un solo bloque.
class FilaDetalleSprint extends StatelessWidget {
  const FilaDetalleSprint({
    required this.icono,
    required this.titulo,
    required this.texto,
    super.key,
  });

  static const double tamanoIcono = 22;

  final IconData icono;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            IconoApp(icono, tamano: tamanoIcono, color: tokens.accionPrimaria),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: estilos.cuerpoEnfasis.copyWith(color: tokens.textoPrimario)),
                  const SizedBox(height: 2),
                  Text(texto, style: estilos.leyenda.copyWith(color: tokens.textoSecundario)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta que agrupa las filas de detalle: fondo/superficie, ancho 342 (el
/// del contenedor), borde 1 borde/default, radio 18 y relleno horizontal 16.
class TarjetaDetallesSprint extends StatelessWidget {
  const TarjetaDetallesSprint({required this.filas, super.key});

  static const double radio = 18;

  final List<FilaDetalleSprint> filas;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      key: const ValueKey('tarjeta-detalles'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        borderRadius: BorderRadius.circular(radio),
        border: Border.all(color: tokens.bordeDefault),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: filas),
    );
  }
}
