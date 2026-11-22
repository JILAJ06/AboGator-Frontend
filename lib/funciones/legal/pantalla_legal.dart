import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/rutas.dart';
import '../../componentes/bloque_lectura.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/boton_atras.dart';
import '../../componentes/fila_acordeon.dart';
import '../../core/adaptativo/clase_pantalla.dart';
import '../../core/textos/textos.dart';
import '../../core/textos/textos_legales.dart';
import '../../core/utilidades/extensiones_contexto.dart';

/// Documento que muestra [PantallaLegal].
enum TipoDocumentoLegal {
  avisoPrivacidad(TextosLegales.avisoPrivacidad),
  terminos(TextosLegales.terminos);

  const TipoDocumentoLegal(this.documento);

  final DocumentoLegal documento;
}

/// 32 · Aviso de Privacidad y 33 · Términos de uso (T-13b).
///
/// Atrás, el título centrado, la versión y las secciones en acordeón (una
/// abierta a la vez; al entrar, la de [DocumentoLegal.abiertaPorDefecto]) y
/// el botón fijo "Entendido", que cierra. En tablet, una columna de lectura de
/// 640 centrada. Se abre desde el Registro, el Perfil y Ajustes (sin sesión
/// también, por el Registro).
class PantallaLegal extends StatefulWidget {
  const PantallaLegal({required this.tipo, super.key});

  /// Ancho de la columna de lectura en tablet.
  static const double anchoTablet = 640;

  final TipoDocumentoLegal tipo;

  /// Cierra: regresa a quien la abrió o, sin historial, al Perfil (que manda
  /// al inicio de sesión si no hay sesión).
  static void cerrar(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Rutas.perfil);
    }
  }

  @override
  State<PantallaLegal> createState() => _PantallaLegalState();
}

class _PantallaLegalState extends State<PantallaLegal> {
  late int? _abierta = widget.tipo.documento.abiertaPorDefecto;

  void _alternar(int i) => setState(() => _abierta = _abierta == i ? null : i);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final documento = widget.tipo.documento;
    final secciones = documento.secciones;
    final tablet = context.clasePantalla.esTablet;

    Widget enColumna(Widget hijo) => tablet
        ? Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: PantallaLegal.anchoTablet),
              child: hijo,
            ),
          )
        : hijo;

    final encabezado = Row(
      children: [
        BotonAtras(alPresionar: () => PantallaLegal.cerrar(context)),
        const SizedBox(width: 8),
        Expanded(
          child: BloqueLectura(
            key: const ValueKey('titulo-legal'),
            encabezado: true,
            autofocus: true,
            radio: 8,
            child: Text(
              documento.titulo,
              textAlign: TextAlign.center,
              style: estilos.h3.copyWith(color: tokens.textoPrimario, fontSize: 18),
            ),
          ),
        ),
        const SizedBox(width: 8 + BotonAtras.lado),
      ],
    );

    final lista = ListView.separated(
      key: const ValueKey('secciones-legales'),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      itemCount: secciones.length + 1,
      separatorBuilder: (_, i) => SizedBox(height: i == 0 ? 16 : 10),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Text(
            Textos.versionLegal,
            style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
          );
        }
        final s = secciones[i - 1];
        return FilaAcordeon(
          titulo: s.titulo,
          cuerpo: s.cuerpo,
          abierta: _abierta == i - 1,
          etiquetaSemantica: Textos.seccionLegalSemantica(s.titulo, i, secciones.length),
          alAlternar: () => _alternar(i - 1),
        );
      },
    );

    return Scaffold(
      body: SafeArea(
        child: enColumna(
          Column(
            key: ValueKey('pantalla-legal-${widget.tipo.name}'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(padding: const EdgeInsets.fromLTRB(24, 8, 24, 16), child: encabezado),
              Expanded(child: lista),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: BotonApp(
                  key: const ValueKey('boton-entendido-legal'),
                  texto: Textos.entendido,
                  alPresionar: () => PantallaLegal.cerrar(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
