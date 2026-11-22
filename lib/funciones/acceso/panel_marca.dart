import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../componentes/logo_app.dart';
import '../../componentes/sarko_imagen.dart';
import '../../core/adaptativo/clase_pantalla.dart';
import '../../core/recursos/imagenes_app.dart';
import '../../core/tema/efectos.dart';
import '../../core/tema/tokens_color.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';

/// Pantalla de acceso a la que pertenece el panel de marca.
enum VariantePanelMarca { inicioSesion, registro }

/// Panel de marca de tablet para 05 Inicio de sesión (Figma 94:468) y 06
/// Registro (94:551).
///
/// Es pantalla de marca: verde bosque **fijo en ambos modos** (el
/// `accion/primaria` del modo claro), como el Splash. Las medidas son las del
/// lienzo de Figma (597 × 802 sin la barra de estado) y se reducen en la misma
/// proporción si el panel es más chico; los textos no se reducen.
///
/// - Inicio de sesión: círculo de 520 en (260, 388), logo horizontal de 400,
///   Sarko alegre de 288 y el lema (Cuerpo/Énfasis en crema) centrados.
/// - Registro: círculo de 520 en (−180, −152), logo de 320 en (64, 64), la
///   frase (H2 en blanco), el texto (Cuerpo/Grande en crema) y Sarko
///   sorprendido de 240 abajo a la derecha.
///
/// [pose] cambia la expresión de Sarko (la recuperación de contraseña, T-13b,
/// usa el panel de inicio de sesión con la expresión de cada paso).
class PanelMarca extends StatelessWidget {
  const PanelMarca({required this.variante, this.pose, super.key});

  /// Lienzo del panel en Figma (la mitad izquierda de 1194 × 802).
  static const Size lienzo = Size(597, 802);
  static const double diametroCirculo = 520;

  final VariantePanelMarca variante;
  final PoseSarko? pose;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const ValueKey('panel-marca'),
      color: _Marca.verde,
      child: LayoutBuilder(
        builder: (context, restricciones) {
          final escala = math.min(
            1.0,
            math.min(
              restricciones.maxWidth / lienzo.width,
              restricciones.maxHeight / lienzo.height,
            ),
          );
          return ClipRect(
            child: switch (variante) {
              VariantePanelMarca.inicioSesion => _InicioSesion(
                escala: escala,
                pose: pose ?? PoseSarko.alegre,
              ),
              VariantePanelMarca.registro => _Registro(
                escala: escala,
                pose: pose ?? PoseSarko.sorprendido,
              ),
            },
          );
        },
      ),
    );
  }
}

/// Franja de marca de tablet en vertical (600 a 959): 240 de alto en el mismo
/// verde, con el logo y Sarko en fila. Decisión propia (Figma solo dibuja la
/// tablet en horizontal).
class FranjaMarca extends StatelessWidget {
  const FranjaMarca({required this.variante, this.pose, super.key});

  static const double alto = 240;

  final VariantePanelMarca variante;
  final PoseSarko? pose;

  @override
  Widget build(BuildContext context) {
    final pose =
        this.pose ??
        (variante == VariantePanelMarca.registro ? PoseSarko.sorprendido : PoseSarko.alegre);
    return ColoredBox(
      key: const ValueKey('franja-marca'),
      color: _Marca.verde,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: alto,
          child: ClipRect(
            child: Stack(
              children: [
                const Positioned(
                  right: -120,
                  top: -260,
                  child: _Circulo(diametro: PanelMarca.diametroCirculo),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: MedidasAdaptativas.margen),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: LogoApp(
                            forma: FormaLogo.horizontal,
                            tono: TonoLogo.sobreVerde,
                            ancho: 300,
                          ),
                        ),
                      ),
                      const SizedBox(width: MedidasAdaptativas.medianil),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: SarkoImagen(pose: pose, ancho: 168, decorativa: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Colores fijos del panel (ver la nota de [PanelMarca]).
abstract final class _Marca {
  static Color get verde => TokensColor.claro.accionPrimaria;
  static Color get crema => TokensColor.claro.fondoDestacado;
  static Color get blanco => TokensColor.claro.textoEnPrimario;
}

class _Circulo extends StatelessWidget {
  const _Circulo({required this.diametro});

  final double diametro;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('circulo-panel-marca'),
      width: diametro,
      height: diametro,
      decoration: const BoxDecoration(color: EfectosApp.circuloPanelMarca, shape: BoxShape.circle),
    );
  }
}

class _InicioSesion extends StatelessWidget {
  const _InicioSesion({required this.escala, required this.pose});

  final double escala;
  final PoseSarko pose;

  @override
  Widget build(BuildContext context) {
    final e = escala;
    return Stack(
      children: [
        Positioned(
          left: 260 * e,
          top: 388 * e,
          child: _Circulo(diametro: PanelMarca.diametroCirculo * e),
        ),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 60),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LogoApp(
                  key: const ValueKey('logo-panel-marca'),
                  forma: FormaLogo.horizontal,
                  tono: TonoLogo.sobreVerde,
                  ancho: 400 * e,
                ),
                // Figma: logo en y 108 (alto 97), Sarko en 258 y lema en 648.
                SizedBox(height: 53 * e),
                SarkoImagen(
                  key: const ValueKey('sarko-panel-marca'),
                  pose: pose,
                  ancho: 288 * e,
                  decorativa: true,
                ),
                SizedBox(height: 30 * e),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 477),
                  child: Text(
                    Textos.lemaUnaLinea,
                    style: context.estilos.cuerpoEnfasis.copyWith(color: _Marca.crema),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Registro extends StatelessWidget {
  const _Registro({required this.escala, required this.pose});

  final double escala;
  final PoseSarko pose;

  @override
  Widget build(BuildContext context) {
    final e = escala;
    final estilos = context.estilos;
    return LayoutBuilder(
      builder: (context, restricciones) {
        // Sarko se oculta si el panel es tan bajo que taparía los textos.
        final conSarko = restricciones.maxHeight >= 600;
        return Stack(
          children: [
            Positioned(
              left: -180 * e,
              top: -152 * e,
              child: _Circulo(diametro: PanelMarca.diametroCirculo * e),
            ),
            if (conSarko)
              Positioned(
                right: 40 * e,
                bottom: 30 * e,
                child: SarkoImagen(
                  key: const ValueKey('sarko-panel-marca'),
                  pose: pose,
                  ancho: 240 * e,
                  decorativa: true,
                ),
              ),
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(64 * e, 64 * e, 64 * e, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LogoApp(
                    key: const ValueKey('logo-panel-marca'),
                    forma: FormaLogo.horizontal,
                    tono: TonoLogo.sobreVerde,
                    ancho: 320 * e,
                  ),
                  // Figma: logo en y 64 (alto 77.6), frase en 198 y texto en 240.
                  SizedBox(height: 56 * e),
                  Text(Textos.registroPanelFrase, style: estilos.h2.copyWith(color: _Marca.blanco)),
                  const SizedBox(height: 16),
                  Text(
                    Textos.registroPanelTexto,
                    style: estilos.cuerpoGrande.copyWith(color: _Marca.crema),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Composición de tablet de 05 y 06: el panel de marca a la izquierda (la mitad
/// del ancho, hasta 597) y, a la derecha, el [formulario] en una columna de 470
/// centrada (en vertical también). El [encabezado] opcional (el botón atrás de
/// 06) queda arriba, alineado con la columna.
///
/// Entre 600 y 959 de ancho, el panel pasa arriba como [FranjaMarca] y el
/// formulario va debajo, centrado en 470. La columna se desplaza si el teclado
/// o el texto grande no caben.
class DisposicionAccesoTablet extends StatelessWidget {
  const DisposicionAccesoTablet({
    required this.variante,
    required this.formulario,
    this.encabezado,
    this.pose,
    super.key,
  });

  final VariantePanelMarca variante;

  /// Expresión de Sarko en el panel o la franja (por defecto, la de la
  /// variante).
  final PoseSarko? pose;
  final Widget formulario;
  final Widget? encabezado;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final ancho = ClasePantalla.deAncho(restricciones.maxWidth).esAncho;
        if (ancho) {
          final anchoPanel = math.min(PanelMarca.lienzo.width, restricciones.maxWidth / 2);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: anchoPanel,
                child: PanelMarca(variante: variante, pose: pose),
              ),
              Expanded(
                child: SafeArea(
                  left: false,
                  child: _ColumnaFormulario(encabezado: encabezado, formulario: formulario),
                ),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FranjaMarca(variante: variante, pose: pose),
            Expanded(
              child: SafeArea(
                top: false,
                child: _ColumnaFormulario(encabezado: encabezado, formulario: formulario),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ColumnaFormulario extends StatelessWidget {
  const _ColumnaFormulario({required this.formulario, this.encabezado});

  static const double relleno = 24;

  final Widget formulario;
  final Widget? encabezado;

  @override
  Widget build(BuildContext context) {
    Widget enColumna(Widget hijo) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: MedidasAdaptativas.columnaFormulario),
        child: hijo,
      ),
    );
    final cabeza = encabezado;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (cabeza != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              MedidasAdaptativas.margen,
              16,
              MedidasAdaptativas.margen,
              0,
            ),
            child: enColumna(Align(alignment: Alignment.centerLeft, child: cabeza)),
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, restricciones) => SingleChildScrollView(
              key: const ValueKey('columna-formulario'),
              padding: const EdgeInsets.symmetric(
                horizontal: MedidasAdaptativas.margen,
                vertical: relleno,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: math.max(0, restricciones.maxHeight - 2 * relleno),
                ),
                child: enColumna(formulario),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
