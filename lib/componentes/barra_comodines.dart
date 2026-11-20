import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'accion_enfocable.dart';
import 'icono_app.dart';

/// Estado de una píldora de comodín.
enum EstadoComodin {
  /// Como en Figma 33:393: fondo/superficie y borde accion/acento.
  disponible,

  /// Lupa usada en la tarjeta actual, Abogado consultado o Amparo armado:
  /// fondo accion/acento, texto e ícono texto/en-primario.
  activo,

  /// Sin cantidad, no aplica a la tarjeta, con un panel abierto o en el
  /// Examen: fondo/superficie-alt, borde borde/default y texto/secundario.
  deshabilitado,
}

/// Barra de comodines (Figma 33:393): tres píldoras de 48 de alto con borde
/// 1.5, ícono de 18 y texto Etiqueta ("Lupa ×2"), separadas 8; si no caben,
/// bajan de línea.
///
/// Cada píldora es un botón (foco, Enter y Espacio) cuando tiene acción. Se
/// lee "Lupa, 2 disponibles" más su estado ("activa" o "no disponible").
/// Con [habilitados] en `false` (Examen final, RN03) todas quedan
/// deshabilitadas.
class BarraComodines extends StatelessWidget {
  const BarraComodines({
    required this.lupa,
    required this.abogado,
    required this.amparo,
    this.estadoLupa = EstadoComodin.disponible,
    this.estadoAbogado = EstadoComodin.disponible,
    this.estadoAmparo = EstadoComodin.disponible,
    this.alUsarLupa,
    this.alUsarAbogado,
    this.alUsarAmparo,
    this.habilitados = true,
    this.nodoFocoAbogado,
    super.key,
  });

  static const double alto = 48;

  final int lupa;
  final int abogado;
  final int amparo;
  final EstadoComodin estadoLupa;
  final EstadoComodin estadoAbogado;
  final EstadoComodin estadoAmparo;
  final VoidCallback? alUsarLupa;
  final VoidCallback? alUsarAbogado;
  final VoidCallback? alUsarAmparo;
  final bool habilitados;

  /// Foco de la píldora del Abogado (vuelve aquí al cerrar su panel).
  final FocusNode? nodoFocoAbogado;

  @override
  Widget build(BuildContext context) {
    EstadoComodin estado(EstadoComodin e) => habilitados ? e : EstadoComodin.deshabilitado;
    VoidCallback? accion(VoidCallback? a) => habilitados ? a : null;
    return Wrap(
      key: const ValueKey('barra-comodines'),
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        PildoraComodin(
          key: const ValueKey('comodin-lupa'),
          icono: IconosApp.search,
          nombre: Textos.comodinLupa,
          cantidad: lupa,
          estado: estado(estadoLupa),
          alPresionar: accion(alUsarLupa),
        ),
        PildoraComodin(
          key: const ValueKey('comodin-abogado'),
          icono: IconosApp.briefcase,
          nombre: Textos.comodinAbogado,
          cantidad: abogado,
          estado: estado(estadoAbogado),
          alPresionar: accion(alUsarAbogado),
          nodoFoco: nodoFocoAbogado,
        ),
        PildoraComodin(
          key: const ValueKey('comodin-amparo'),
          icono: IconosApp.shieldCheck,
          nombre: Textos.comodinAmparo,
          cantidad: amparo,
          estado: estado(estadoAmparo),
          alPresionar: accion(alUsarAmparo),
          etiquetaActiva: Textos.amparoArmado,
        ),
      ],
    );
  }
}

/// Una píldora de la barra de comodines.
class PildoraComodin extends StatelessWidget {
  const PildoraComodin({
    required this.icono,
    required this.nombre,
    required this.cantidad,
    this.estado = EstadoComodin.disponible,
    this.alPresionar,
    this.etiquetaActiva,
    this.nodoFoco,
    super.key,
  });

  static const double radio = BarraComodines.alto / 2;

  final IconData icono;
  final String nombre;
  final int cantidad;
  final EstadoComodin estado;
  final VoidCallback? alPresionar;

  /// Lo que se lee cuando está activa en lugar de "activa" (Amparo armado).
  final String? etiquetaActiva;
  final FocusNode? nodoFoco;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final (fondo, borde, colorIcono, colorTexto) = switch (estado) {
      EstadoComodin.disponible => (
        tokens.fondoSuperficie,
        tokens.accionAcento,
        tokens.accionAcento,
        tokens.textoPrimario,
      ),
      EstadoComodin.activo => (
        tokens.accionAcento,
        tokens.accionAcento,
        tokens.textoEnPrimario,
        tokens.textoEnPrimario,
      ),
      EstadoComodin.deshabilitado => (
        tokens.fondoSuperficieAlt,
        tokens.bordeDefault,
        tokens.textoSecundario,
        tokens.textoSecundario,
      ),
    };
    final etiqueta = Textos.comodinEstadoSemantica(
      Textos.comodinSemantica(nombre, cantidad),
      switch (estado) {
        EstadoComodin.disponible => null,
        EstadoComodin.activo => etiquetaActiva ?? Textos.comodinActivo,
        EstadoComodin.deshabilitado => Textos.comodinNoDisponible,
      },
    );
    return AccionEnfocable(
      alPresionar: alPresionar,
      nodoFoco: nodoFoco,
      radio: radio,
      semantica: (hijo) => Semantics(
        button: alPresionar != null,
        enabled: alPresionar != null,
        selected: estado == EstadoComodin.activo,
        label: etiqueta,
        onTap: alPresionar,
        excludeSemantics: true,
        child: hijo,
      ),
      child: Container(
        key: ValueKey('pildora-$nombre'),
        constraints: const BoxConstraints(minHeight: BarraComodines.alto),
        padding: const EdgeInsets.only(left: 10, right: 12, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borde, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconoApp(icono, tamano: 18, color: colorIcono),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                Textos.comodinCantidad(nombre, cantidad),
                style: context.estilos.etiqueta.copyWith(color: colorTexto),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
