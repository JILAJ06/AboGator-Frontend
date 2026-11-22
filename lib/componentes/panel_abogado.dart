import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'bloque_lectura.dart';
import 'boton_app.dart';
import 'caja_superficie.dart';
import 'icono_app.dart';
import 'panel_evidencia.dart';

/// Panel del Abogado Senior (Figma 10c = 38:5065), en el contenedor de los
/// paneles del juego:
/// - título: cuadrado de 40 accion/secundaria (radio 12) con `briefcase` de 22
///   y, al lado, "Consulta al Abogado Senior" (H2) sobre "El caso, sin ruido y
///   en términos legales" (Leyenda texto/secundario);
/// - traducción: caja fondo/superficie-alt (radio 16, relleno 16/14,
///   separación 8) con "Lo que realmente se pregunta" y [traduccion];
/// - "NORMA APLICABLE" y una fila por norma con `doc` de 18;
/// - "Volver a la tarjeta".
///
/// Al abrirse, el foco va al título, que se anuncia.
class PanelAbogado extends StatelessWidget {
  const PanelAbogado({
    required this.traduccion,
    required this.normas,
    required this.alVolver,
    super.key,
  });

  final String traduccion;
  final List<String> normas;
  final VoidCallback alVolver;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return ContenedorPanelModal(
      key: const ValueKey('panel-abogado'),
      hijos: [
        BloqueLectura(
          key: const ValueKey('titulo-abogado'),
          etiqueta: Textos.abogadoTitulo,
          encabezado: true,
          enVivo: true,
          excluirHijos: true,
          autofocus: true,
          radio: 12,
          child: Row(
            children: [
              Container(
                key: const ValueKey('icono-abogado'),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tokens.accionSecundaria,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: IconoApp(IconosApp.briefcase, tamano: 22, color: tokens.textoEnPrimario),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Textos.abogadoTitulo,
                      style: estilos.h2.copyWith(color: tokens.textoPrimario),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Textos.abogadoSubtitulo,
                      style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        BloqueLectura(
          key: const ValueKey('traduccion-abogado'),
          child: CajaSuperficie(
            clave: const ValueKey('caja-traduccion'),
            ancho: double.infinity,
            relleno: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            fondo: FondoCaja.superficieAlt,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Textos.abogadoPregunta,
                  style: estilos.cuerpoEnfasis.copyWith(color: tokens.textoPrimario),
                ),
                const SizedBox(height: 8),
                Text(traduccion, style: estilos.cuerpoBase.copyWith(color: tokens.textoPrimario)),
              ],
            ),
          ),
        ),
        BloqueLectura(
          key: const ValueKey('normas-abogado'),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    Textos.normaAplicable,
                    style: estilos.etiqueta.copyWith(color: tokens.textoAcento),
                  ),
                ),
                for (final norma in normas) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: IconoApp(IconosApp.doc, tamano: 18, color: tokens.accionSecundaria),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          norma,
                          style: estilos.cuerpoBase.copyWith(color: tokens.textoPrimario),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        BotonApp(texto: Textos.volverALaTarjeta, alPresionar: alVolver),
      ],
    );
  }
}
