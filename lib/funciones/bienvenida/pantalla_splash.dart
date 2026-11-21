import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../componentes/logo_app.dart';
import '../../core/adaptativo/clase_pantalla.dart';
import '../../core/recursos/imagenes_app.dart';
import '../../core/tema/efectos.dart';
import '../../core/tema/tokens_color.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import 'flujo_bienvenida.dart';

/// Pantalla 01 · Splash: logo, lema, puntos de carga y "Powered by LawSwipe".
/// Avanza sola a los 2 s.
///
/// Excepción al tema: el Splash es pantalla de marca y usa **siempre** los
/// colores del modo claro (fondo verde bosque `accion/primaria`, puntos en
/// blanco y textos en `fondo/destacado`), también en modo oscuro.
class PantallaSplash extends ConsumerStatefulWidget {
  const PantallaSplash({super.key});

  @override
  ConsumerState<PantallaSplash> createState() => _PantallaSplashState();
}

class _PantallaSplashState extends ConsumerState<PantallaSplash> {
  /// Factor del logo y el lema en tablet (469.4 / 323.7).
  static const double escalaTablet = 1.45;

  Timer? _temporizador;

  @override
  void initState() {
    super.initState();
    _temporizador = Timer(FlujoBienvenida.duracionSplash, _avanzar);
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  Future<void> _avanzar() async {
    final destino = await ref.read(flujoBienvenidaProvider).destinoTrasSplash();
    if (mounted) {
      context.go(destino);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colores de marca fijos (ver la nota de la clase).
    const marca = TokensColor.claro;
    final estilos = context.estilos;
    // Tablet (Figma T01, 94:26): el mismo Splash con el logo y el lema 1.45
    // veces más grandes (logo de 469.4, lema de 435 en 20.3/29), puntos de 12
    // y "Powered by LawSwipe" 68 debajo de los puntos.
    final tablet = context.clasePantalla.esTablet;
    final e = tablet ? escalaTablet : 1.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: marca.accionPrimaria,
        body: Semantics(
          label: Textos.splashSemantica,
          excludeSemantics: true,
          container: true,
          child: SafeArea(
            child: Column(
              children: [
                // Área central: logo con su parte superior en y≈280 del marco de 844.
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 54, 16, 0),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LogoApp(
                              key: const ValueKey('logo-splash'),
                              tono: TonoLogo.sobreVerde,
                              ancho: 323.7 * e,
                              decorativo: true,
                            ),
                            SizedBox(height: 6 * e),
                            SizedBox(
                              width: 300 * e,
                              child: Text(
                                Textos.splashLema,
                                style: estilos.cuerpoEnfasis.copyWith(
                                  color: marca.fondoDestacado,
                                  fontSize: estilos.cuerpoEnfasis.fontSize! * e,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _PuntosCarga(lado: tablet ? 12 : 10, hueco: tablet ? 9.6 : 8),
                SizedBox(height: tablet ? 68 : 20),
                Text(
                  Textos.splashPoweredBy,
                  style: estilos.leyenda.copyWith(color: marca.fondoDestacado),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tres puntos de 10 (hueco 8): el activo en blanco (texto/en-primario del
/// modo claro, fijo) y los demás al 40 %. El activo avanza cada 400 ms; con "reducir animaciones" quedan fijos.
class _PuntosCarga extends StatefulWidget {
  const _PuntosCarga({required this.lado, required this.hueco});

  final double lado;
  final double hueco;

  @override
  State<_PuntosCarga> createState() => _PuntosCargaState();
}

class _PuntosCargaState extends State<_PuntosCarga> {
  static const _intervalo = Duration(milliseconds: 400);
  Timer? _ciclo;
  int _activo = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducir = MediaQuery.disableAnimationsOf(context);
    if (reducir) {
      _ciclo?.cancel();
      _ciclo = null;
      _activo = 0;
    } else {
      _ciclo ??= Timer.periodic(_intervalo, (_) => setState(() => _activo = (_activo + 1) % 3));
    }
  }

  @override
  void dispose() {
    _ciclo?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = TokensColor.claro.textoEnPrimario;
    return Row(
      key: const ValueKey('puntos-carga'),
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) SizedBox(width: widget.hueco),
          Container(
            width: widget.lado,
            height: widget.lado,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == _activo
                  ? color
                  : color.withValues(alpha: EfectosApp.opacidadPuntoInactivo),
            ),
          ),
        ],
      ],
    );
  }
}
