import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'icono_app.dart';

/// Barra de comodines (Figma 33:393): tres píldoras de 48 de alto con borde
/// 1.5 accion/acento, fondo/superficie, ícono de 18 y texto Etiqueta
/// ("Lupa ×2"), separadas 8. En T-05 solo se muestran (no son tocables); se
/// leen como texto ("Lupa, 2 disponibles").
class BarraComodines extends StatelessWidget {
  const BarraComodines({
    required this.lupa,
    required this.abogado,
    required this.amparo,
    super.key,
  });

  static const double alto = 48;

  final int lupa;
  final int abogado;
  final int amparo;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const ValueKey('barra-comodines'),
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _Pildora(icono: IconosApp.search, nombre: Textos.comodinLupa, cantidad: lupa),
        _Pildora(icono: IconosApp.briefcase, nombre: Textos.comodinAbogado, cantidad: abogado),
        _Pildora(icono: IconosApp.shieldCheck, nombre: Textos.comodinAmparo, cantidad: amparo),
      ],
    );
  }
}

class _Pildora extends StatelessWidget {
  const _Pildora({required this.icono, required this.nombre, required this.cantidad});

  final IconData icono;
  final String nombre;
  final int cantidad;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      label: Textos.comodinSemantica(nombre, cantidad),
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: BarraComodines.alto),
        padding: const EdgeInsets.only(left: 10, right: 12, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: tokens.fondoSuperficie,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: tokens.accionAcento, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconoApp(icono, tamano: 18, color: tokens.accionAcento),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                Textos.comodinCantidad(nombre, cantidad),
                style: context.estilos.etiqueta.copyWith(color: tokens.textoPrimario),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
