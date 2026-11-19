import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'accion_enfocable.dart';
import 'icono_app.dart';

/// Estado de un módulo en la ruta de la Startup.
enum EstadoModulo {
  bloqueado(Textos.estadoModuloBloqueado),
  disponible(Textos.estadoModuloDisponible),
  enCurso(Textos.estadoModuloEnCurso),
  completado(Textos.estadoModuloCompletado);

  const EstadoModulo(this.texto);

  /// Estado legible para el lector de pantalla.
  final String texto;
}

/// Tarjeta de módulo: ancho completo, radio 22, relleno 16, separación 14,
/// borde 1 borde/default y sombra (0, 8, 12). Insignia de 56 (radio 16) con
/// ícono de 28, etiqueta "MÓDULO N · NOMBRE", título, progreso (barra 96×8 y
/// "n/5 sprints") y chevron de 20.
///
/// Bloqueado: fondo fondo/superficie-alt, candado, "Completa el módulo
/// anterior" y sin acción. Completado (derivado, no está en Figma): ícono check
/// y "5/5 sprints · Completado".
class TarjetaModulo extends StatelessWidget {
  const TarjetaModulo({
    required this.numero,
    required this.nombreCorto,
    required this.titulo,
    required this.estado,
    required this.completados,
    required this.total,
    required this.color,
    required this.icono,
    required this.alPresionar,
    super.key,
  });

  static const double radio = 22;
  static const double insignia = 56;
  static const double anchoBarra = 96;

  final int numero;
  final String nombreCorto;
  final String titulo;
  final EstadoModulo estado;
  final int completados;
  final int total;

  /// Color de marca del módulo (de `ColoresModulo`).
  final Color color;
  final IconData icono;

  /// Se ignora si el módulo está bloqueado.
  final VoidCallback? alPresionar;

  bool get _bloqueado => estado == EstadoModulo.bloqueado;

  String get _etiquetaSemantica {
    final base = Textos.moduloSemantica(numero, nombreCorto, titulo, estado.texto);
    return _bloqueado
        ? '$base, ${Textos.moduloBloqueadoAyuda}'
        : '$base, ${Textos.sprintsSemantica(completados, total)}';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final accion = _bloqueado ? null : alPresionar;

    final insigniaWidget = Container(
      key: const ValueKey('insignia-modulo'),
      width: insignia,
      height: insignia,
      decoration: BoxDecoration(
        color: _bloqueado ? tokens.fondoSuperficieAlt : color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: IconoApp(
          switch (estado) {
            EstadoModulo.bloqueado => IconosApp.lock,
            EstadoModulo.completado => IconosApp.check,
            _ => icono,
          },
          tamano: 28,
          color: _bloqueado ? tokens.textoSecundario : EfectosApp.iconoSobreModulo,
        ),
      ),
    );

    final progreso = switch (estado) {
      EstadoModulo.bloqueado => Text(
        Textos.moduloBloqueadoAyuda,
        style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
      ),
      EstadoModulo.completado => Text(
        Textos.sprintsCompletado(total),
        style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
      ),
      _ => Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 4,
        children: [
          _BarraSprints(completados: completados, total: total),
          Text(
            Textos.sprintsProgreso(completados, total),
            style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
          ),
        ],
      ),
    };

    final tarjeta = Container(
      key: const ValueKey('tarjeta-modulo'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bloqueado ? tokens.fondoSuperficieAlt : tokens.fondoSuperficie,
        borderRadius: BorderRadius.circular(radio),
        border: Border.all(color: tokens.bordeDefault),
        boxShadow: EfectosApp.sombraModulo,
      ),
      child: Row(
        children: [
          insigniaWidget,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Textos.moduloEtiqueta(numero, nombreCorto),
                  style: estilos.leyenda.copyWith(
                    color: _bloqueado ? tokens.textoSecundario : tokens.textoAcento,
                  ),
                ),
                const SizedBox(height: 4),
                Text(titulo, style: estilos.h3.copyWith(color: tokens.textoPrimario)),
                const SizedBox(height: 6),
                progreso,
              ],
            ),
          ),
          const SizedBox(width: 14),
          IconoApp(
            IconosApp.chevron,
            tamano: 20,
            color: _bloqueado ? tokens.bordeControl : tokens.textoSecundario,
          ),
        ],
      ),
    );

    return AccionEnfocable(
      alPresionar: accion,
      radio: radio,
      semantica: (hijo) => Semantics(
        button: true,
        enabled: !_bloqueado,
        label: _etiquetaSemantica,
        onTap: accion,
        excludeSemantics: true,
        child: hijo,
      ),
      child: tarjeta,
    );
  }
}

/// Barra de 96×8 con el avance del módulo.
class _BarraSprints extends StatelessWidget {
  const _BarraSprints({required this.completados, required this.total});

  final int completados;
  final int total;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final fraccion = total == 0 ? 0.0 : (completados / total).clamp(0.0, 1.0);
    return Container(
      key: const ValueKey('barra-sprints'),
      width: TarjetaModulo.anchoBarra,
      height: 8,
      decoration: BoxDecoration(
        color: tokens.fondoSuperficieAlt,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.centerLeft,
      child: Container(
        key: const ValueKey('relleno-sprints'),
        width: TarjetaModulo.anchoBarra * fraccion,
        decoration: BoxDecoration(
          color: tokens.accionPrimaria,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
