import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/tema/iconos_app.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'accion_enfocable.dart';
import 'icono_app.dart';

/// Fila de acordeón (Figma 32 y 33, T-13b): fondo/superficie y radio 16.
///
/// - Cerrada: alto ≥ 50, borde 1 borde/default, título en Cuerpo/Énfasis y
///   chevron a la derecha.
/// - Abierta: borde 2 accion/acento, chevron hacia abajo, título en negrita y
///   el [cuerpo] debajo en Cuerpo/Base.
///
/// Toda la cabecera es tocable (≥ 50, anillo de foco, Enter o Espacio). Se lee
/// como botón con estado expandido o contraído. El cambio se anima en 200 ms
/// (sin animación con "Reducir animaciones").
class FilaAcordeon extends StatelessWidget {
  const FilaAcordeon({
    required this.titulo,
    required this.cuerpo,
    required this.abierta,
    required this.alAlternar,
    this.etiquetaSemantica,
    super.key,
  });

  static const double altoCerrada = 50;
  static const double radio = 16;

  final String titulo;
  final String cuerpo;
  final bool abierta;
  final VoidCallback alAlternar;

  /// Lo que lee el lector en la cabecera (por defecto, [titulo]).
  final String? etiquetaSemantica;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final duracion = EfectosApp.duracion(context, milisegundos: 200);
    final cabecera = Semantics(
      container: true,
      child: AccionEnfocable(
        alPresionar: alAlternar,
        radio: radio,
        semantica: (hijo) => Semantics(
          button: true,
          expanded: abierta,
          label: etiquetaSemantica ?? titulo,
          onTap: alAlternar,
          excludeSemantics: true,
          child: hijo,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: altoCerrada),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    titulo,
                    style: estilos.cuerpoEnfasis.copyWith(
                      color: tokens.textoPrimario,
                      fontWeight: abierta ? FontWeight.w700 : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedRotation(
                  duration: duracion,
                  turns: abierta ? 0.25 : 0,
                  child: IconoApp(IconosApp.chevron, tamano: 20, color: tokens.textoSecundario),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return AnimatedContainer(
      key: ValueKey('acordeon-$titulo'),
      duration: duracion,
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        borderRadius: BorderRadius.circular(radio),
        border: Border.all(
          color: abierta ? tokens.accionAcento : tokens.bordeDefault,
          width: abierta ? 2 : 1,
        ),
      ),
      child: AnimatedSize(
        duration: duracion,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            cabecera,
            if (abierta)
              // Nodo propio: el lector lee el cuerpo aparte de la cabecera.
              Semantics(
                container: true,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    cuerpo,
                    key: const ValueKey('cuerpo-acordeon'),
                    style: estilos.cuerpoBase.copyWith(color: tokens.textoPrimario),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
