import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'accion_enfocable.dart';
import 'icono_app.dart';
import 'sarko_imagen.dart';

/// Tarjeta héroe del Inicio: 342×168 en accion/primaria, radio 24, sombra
/// (0, 8, 24) y recorte. Elipse decorativa de 220 en (190, −30), etiqueta,
/// título de dos líneas (ancho 200), subtítulo, botón "Continuar sprint"
/// (148×48, accion/acento, radio 12) y Sarko de 120×150 en (226, 22).
///
/// Crece en alto con el texto dinámico. Con menos de [anchoMinimoSarko] de
/// ancho, Sarko se oculta para no quedar cortado (D4 de T-04).
///
/// En tablet se usa con [MedidasHeroe.tablet] (T07: 620×200, elipse de 286 en
/// (394, −40) y Sarko de 150 en (446, 16.5)); el ancho lo da el contenedor.
class TarjetaHeroeStartup extends StatelessWidget {
  const TarjetaHeroeStartup({
    required this.titulo,
    required this.subtitulo,
    required this.alContinuar,
    this.medidas = MedidasHeroe.movil,
    super.key,
  });

  static const double alto = 168;
  static const double radio = 24;
  static const double anchoTexto = 200;

  /// Ancho mínimo de la tarjeta para mostrar a Sarko.
  static const double anchoMinimoSarko = 320;

  final String titulo;
  final String subtitulo;
  final VoidCallback? alContinuar;
  final MedidasHeroe medidas;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) =>
          _construir(context, conSarko: restricciones.maxWidth >= medidas.anchoMinimoSarko),
    );
  }

  Widget _construir(BuildContext context, {required bool conSarko}) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final colorTexto = tokens.textoEnPrimario;

    return Container(
      key: const ValueKey('tarjeta-heroe'),
      constraints: BoxConstraints(minHeight: medidas.alto),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: tokens.accionPrimaria,
        borderRadius: BorderRadius.circular(radio),
        boxShadow: EfectosApp.sombraHeroe,
      ),
      child: Stack(
        children: [
          Positioned(
            left: medidas.elipse.dx,
            top: medidas.elipse.dy,
            child: Container(
              width: medidas.diametroElipse,
              height: medidas.diametroElipse,
              decoration: const BoxDecoration(
                color: EfectosApp.elipseHeroe,
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (conSarko)
            Positioned(
              left: medidas.sarko.dx,
              top: medidas.sarko.dy,
              child: SarkoImagen(
                pose: PoseSarko.alegre,
                ancho: medidas.anchoSarko,
                decorativa: true,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                MergeSemantics(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: anchoTexto),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Textos.heroeEtiqueta,
                          style: estilos.leyenda.copyWith(color: colorTexto),
                        ),
                        const SizedBox(height: 6),
                        Text(titulo, style: estilos.h1.copyWith(color: colorTexto)),
                        const SizedBox(height: 4),
                        Text(subtitulo, style: estilos.leyenda.copyWith(color: colorTexto)),
                      ],
                    ),
                  ),
                ),
                _BotonContinuar(alPresionar: alContinuar),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Medidas de la tarjeta héroe en móvil (07) y en tablet (T07).
class MedidasHeroe {
  const MedidasHeroe({
    required this.alto,
    required this.diametroElipse,
    required this.elipse,
    required this.anchoSarko,
    required this.sarko,
    required this.anchoMinimoSarko,
  });

  /// 342×168: elipse de 220 en (190, −30) y Sarko de 120 en (226, 22).
  static const MedidasHeroe movil = MedidasHeroe(
    alto: TarjetaHeroeStartup.alto,
    diametroElipse: 220,
    elipse: Offset(190, -30),
    anchoSarko: 120,
    sarko: Offset(226, 22),
    anchoMinimoSarko: TarjetaHeroeStartup.anchoMinimoSarko,
  );

  /// 620×200: elipse de 286 en (394, −40) y Sarko de 150 en (446, 16.5).
  static const MedidasHeroe tablet = MedidasHeroe(
    alto: 200,
    diametroElipse: 286,
    elipse: Offset(394, -40),
    anchoSarko: 150,
    sarko: Offset(446, 16.5),
    anchoMinimoSarko: 446 + 150,
  );

  final double alto;
  final double diametroElipse;
  final Offset elipse;
  final double anchoSarko;
  final Offset sarko;

  /// Con menos ancho, Sarko se oculta para no quedar cortado.
  final double anchoMinimoSarko;
}

class _BotonContinuar extends StatelessWidget {
  const _BotonContinuar({required this.alPresionar});

  final VoidCallback? alPresionar;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = tokens.textoEnPrimario;
    return AccionEnfocable(
      alPresionar: alPresionar,
      radio: 12,
      semantica: (hijo) => Semantics(
        button: true,
        label: Textos.continuarSprint,
        onTap: alPresionar,
        excludeSemantics: true,
        child: hijo,
      ),
      child: Container(
        key: const ValueKey('boton-continuar'),
        constraints: const BoxConstraints(minWidth: 148, minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: tokens.accionAcento,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                Textos.continuarSprint,
                style: context.estilos.etiqueta.copyWith(color: color),
              ),
            ),
            const SizedBox(width: 6),
            IconoApp(IconosApp.chevron, tamano: 16, color: color),
          ],
        ),
      ),
    );
  }
}
