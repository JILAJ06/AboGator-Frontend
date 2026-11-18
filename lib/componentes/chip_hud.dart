import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/tema/tokens_color.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import '../datos/modelos/vidas.dart';
import 'corazon_vida.dart';
import 'icono_app.dart';

enum TipoChipHud { vidas, monedas, racha, comodines, amparo }

/// Píldora del HUD: ícono de 20 y valor en Cuerpo/Énfasis.
///
/// Colores de los íconos provisionales (decisión del reporte de T-01):
/// Vidas estado/ilegal (corazón relleno), Monedas y Racha accion/acento,
/// Comodines texto/acento y Amparo accion/secundaria.
class ChipHud extends StatelessWidget {
  const ChipHud({
    required this.tipo,
    required this.valor,
    required this.etiquetaSemantica,
    super.key,
  });

  factory ChipHud.vidas(int cantidad, {int maximo = Vidas.maximo, Key? key}) => ChipHud(
    key: key,
    tipo: TipoChipHud.vidas,
    valor: '$cantidad',
    etiquetaSemantica: Textos.chipVidas(cantidad, maximo),
  );

  factory ChipHud.monedas(int cantidad, {Key? key}) => ChipHud(
    key: key,
    tipo: TipoChipHud.monedas,
    valor: '$cantidad',
    etiquetaSemantica: Textos.chipMonedas(cantidad),
  );

  factory ChipHud.racha(int dias, {Key? key}) => ChipHud(
    key: key,
    tipo: TipoChipHud.racha,
    valor: '$dias',
    etiquetaSemantica: Textos.chipRacha(dias),
  );

  factory ChipHud.comodines(int cantidad, {Key? key}) => ChipHud(
    key: key,
    tipo: TipoChipHud.comodines,
    valor: '$cantidad',
    etiquetaSemantica: Textos.chipComodines(cantidad),
  );

  factory ChipHud.amparo(int cantidad, {Key? key}) => ChipHud(
    key: key,
    tipo: TipoChipHud.amparo,
    valor: '$cantidad',
    etiquetaSemantica: Textos.chipAmparo(cantidad),
  );

  static const double tamanoIcono = 20;

  final TipoChipHud tipo;
  final String valor;
  final String etiquetaSemantica;

  static Color colorIcono(TipoChipHud tipo, TokensColor t) => switch (tipo) {
    TipoChipHud.vidas => t.estadoIlegal,
    TipoChipHud.monedas || TipoChipHud.racha => t.accionAcento,
    TipoChipHud.comodines => t.textoAcento,
    TipoChipHud.amparo => t.accionSecundaria,
  };

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = colorIcono(tipo, tokens);
    final icono = switch (tipo) {
      TipoChipHud.vidas => const CorazonVida(lleno: true, tamano: tamanoIcono),
      TipoChipHud.monedas => IconoApp(IconosApp.coin, tamano: tamanoIcono, color: color),
      TipoChipHud.racha => IconoApp(IconosApp.flame, tamano: tamanoIcono, color: color),
      TipoChipHud.comodines => IconoApp(IconosApp.bulb, tamano: tamanoIcono, color: color),
      TipoChipHud.amparo => IconoApp(IconosApp.shieldCheck, tamano: tamanoIcono, color: color),
    };
    final borde = tipo == TipoChipHud.amparo
        ? Border.all(color: tokens.accionSecundaria, width: 1.5)
        : Border.all(color: tokens.bordeDefault);

    return Semantics(
      label: etiquetaSemantica,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 12, top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: tokens.fondoSuperficie,
          borderRadius: BorderRadius.circular(999),
          border: borde,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icono,
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                valor,
                style: context.estilos.cuerpoEnfasis.copyWith(color: tokens.textoPrimario),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
