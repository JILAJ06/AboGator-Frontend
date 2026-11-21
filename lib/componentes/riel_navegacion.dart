import 'package:material_ui/material_ui.dart';

import '../core/adaptativo/clase_pantalla.dart';
import '../core/recursos/imagenes_app.dart';
import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'accion_enfocable.dart';
import 'icono_app.dart';
import 'logo_app.dart';
import 'navegacion_inferior_app.dart';

/// Riel de navegación de tablet (Figma 93:525): sustituye a la navegación
/// inferior a partir de 600 de ancho.
///
/// 104 de ancho, fondo/superficie y borde derecho de 1 en borde/default.
/// Columna centrada (separación 8, relleno vertical 24): isotipo de 56,
/// separador de 24, los cuatro destinos de [PestanaApp] (80 × 72), espacio
/// flexible, Ajustes (círculo de 48) y el avatar (48) con las [iniciales].
///
/// El Buzón lleva una insignia con [pendientes] (se oculta con 0 o `null`; con
/// más de 99 dice "99+"). El destino activo no depende solo del color: su
/// etiqueta va en negrita y tiene `Semantics(selected: true)`.
class RielNavegacion extends StatelessWidget {
  const RielNavegacion({
    required this.actual,
    required this.alSeleccionar,
    required this.iniciales,
    required this.alAjustes,
    required this.alPerfil,
    this.pendientes,
    this.nombreUsuario,
    super.key,
  });

  static const double ancho = MedidasAdaptativas.riel;
  static const double anchoDestino = 80;
  static const double altoDestino = 72;
  static const double anchoIndicador = 56;
  static const double altoIndicador = 32;
  static const double ladoBoton = 48;
  static const double ladoIsotipo = 56;
  static const double ladoInsignia = 20;

  /// Posición de la insignia dentro del destino (Figma: x 50, y 8).
  static const Offset posicionInsignia = Offset(50, 8);

  /// Destino activo; `null` si la pantalla no es de ninguno (por ejemplo, Ajustes).
  final PestanaApp? actual;
  final ValueChanged<PestanaApp> alSeleccionar;
  final int? pendientes;
  final String iniciales;
  final String? nombreUsuario;
  final VoidCallback? alAjustes;
  final VoidCallback? alPerfil;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final contenido = Column(
      children: [
        const LogoApp(
          key: ValueKey('isotipo-riel'),
          forma: FormaLogo.isotipo,
          ancho: ladoIsotipo,
          decorativo: true,
        ),
        const SizedBox(height: 8 + 24 + 8),
        for (final (i, pestana) in PestanaApp.values.indexed) ...[
          if (i > 0) const SizedBox(height: 8),
          _Destino(
            key: ValueKey('riel-${pestana.name}'),
            pestana: pestana,
            activo: pestana == actual,
            pendientes: pestana == PestanaApp.buzon ? pendientes : null,
            alPresionar: () => alSeleccionar(pestana),
          ),
        ],
        const Spacer(),
        const SizedBox(height: 8),
        _BotonCircular(
          key: const ValueKey('riel-ajustes'),
          etiqueta: Textos.rielAjustes,
          alPresionar: alAjustes,
          borde: tokens.bordeDefault,
          child: IconoApp(IconosApp.settings, tamano: 22, color: tokens.textoPrimario),
        ),
        const SizedBox(height: 8),
        _BotonCircular(
          key: const ValueKey('riel-avatar'),
          etiqueta: Textos.rielAvatar(nombreUsuario),
          alPresionar: alPerfil,
          fondo: tokens.fondoDestacado,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              iniciales,
              style: context.estilos.cuerpoEnfasis.copyWith(color: tokens.textoPrimario),
            ),
          ),
        ),
      ],
    );

    return Semantics(
      key: const ValueKey('riel-navegacion'),
      container: true,
      explicitChildNodes: true,
      label: Textos.rielNavegacion,
      child: FocusTraversalGroup(
        child: Container(
          width: ancho,
          decoration: BoxDecoration(
            color: tokens.fondoSuperficie,
            border: Border(right: BorderSide(color: tokens.bordeDefault)),
          ),
          child: LayoutBuilder(
            builder: (context, restricciones) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: restricciones.hasBoundedHeight ? restricciones.maxHeight : 0,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: contenido,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Destino extends StatelessWidget {
  const _Destino({
    required this.pestana,
    required this.activo,
    required this.pendientes,
    required this.alPresionar,
    super.key,
  });

  final PestanaApp pestana;
  final bool activo;
  final int? pendientes;
  final VoidCallback alPresionar;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final cantidad = pendientes ?? 0;
    final etiqueta = pestana == PestanaApp.buzon
        ? Textos.rielBuzonSemantica(cantidad)
        : pestana.nombre;

    return AccionEnfocable(
      alPresionar: alPresionar,
      radio: 16,
      semantica: (hijo) => Semantics(
        button: true,
        selected: activo,
        label: etiqueta,
        onTap: alPresionar,
        excludeSemantics: true,
        child: hijo,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(width: RielNavegacion.anchoDestino)
            .copyWith(minHeight: RielNavegacion.altoDestino),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Center(
                heightFactor: 1,
                widthFactor: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      key: ValueKey('indicador-${pestana.name}'),
                      width: RielNavegacion.anchoIndicador,
                      height: RielNavegacion.altoIndicador,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: activo ? tokens.fondoDestacado : null,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconoApp(
                        pestana.icono,
                        color: activo ? tokens.textoPrimario : tokens.textoSecundario,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pestana.nombre,
                      style: activo
                          ? estilos.etiqueta.copyWith(color: tokens.textoPrimario)
                          : estilos.leyenda.copyWith(color: tokens.textoSecundario),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            if (cantidad > 0)
              Positioned(
                left: RielNavegacion.posicionInsignia.dx,
                top: RielNavegacion.posicionInsignia.dy,
                child: DecoratedBox(
                  key: const ValueKey('insignia-riel'),
                  decoration: BoxDecoration(
                    color: tokens.estadoIlegal,
                    borderRadius: BorderRadius.circular(RielNavegacion.ladoInsignia / 2),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: RielNavegacion.ladoInsignia,
                      minHeight: RielNavegacion.ladoInsignia,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Center(
                        widthFactor: 1,
                        heightFactor: 1,
                        // La insignia es fija (ya la dice la etiqueta del destino).
                        child: MediaQuery.withNoTextScaling(
                          child: Text(
                            Textos.rielInsignia(cantidad),
                            style: estilos.leyenda.copyWith(color: tokens.textoEnPrimario),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BotonCircular extends StatelessWidget {
  const _BotonCircular({
    required this.etiqueta,
    required this.alPresionar,
    required this.child,
    this.borde,
    this.fondo,
    super.key,
  });

  final String etiqueta;
  final VoidCallback? alPresionar;
  final Widget child;
  final Color? borde;
  final Color? fondo;

  @override
  Widget build(BuildContext context) {
    const lado = RielNavegacion.ladoBoton;
    return AccionEnfocable(
      alPresionar: alPresionar,
      radio: lado / 2,
      semantica: (hijo) => Semantics(
        button: true,
        label: etiqueta,
        onTap: alPresionar,
        excludeSemantics: true,
        child: hijo,
      ),
      child: Container(
        width: lado,
        height: lado,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: fondo,
          shape: BoxShape.circle,
          border: borde == null ? null : Border.all(color: borde!),
        ),
        child: child,
      ),
    );
  }
}
