import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/marco_principal.dart';
import '../../componentes/bloque_lectura.dart';
import '../../componentes/dialogo_confirmacion.dart';
import '../../componentes/mensaje_pantalla.dart';
import '../../componentes/navegacion_inferior_app.dart';
import '../../componentes/piezas_tienda.dart';
import '../../componentes/sarko_imagen.dart';
import '../../componentes/tarjeta_consejo_sarko.dart';
import '../../core/adaptativo/clase_pantalla.dart';
import '../../core/tema/iconos_app.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/articulo_tienda.dart';
import '../../datos/modelos/excepcion_tienda.dart';
import '../../datos/repositorios/proveedores_repositorios.dart';
import '../../datos/sincronizacion/estado_sincronizacion.dart';
import '../../datos/sincronizacion/servicio_conexion.dart';
import '../ajustes/estado_ajustes.dart';
import 'estado_tienda.dart';
import 'logica_tienda.dart';

/// Ícono de cada artículo (Figma 24 y la tarea T-10).
IconData iconoArticulo(ArticuloTienda a) => switch (a.comodin) {
  Comodin.lupaAuditor => IconosApp.search,
  Comodin.abogadoSenior => IconosApp.briefcase,
  Comodin.amparo => IconosApp.shieldCheck,
  null => IconosApp.snowflake,
};

/// Nombre corto del inventario ("Lupa", "Abogado", "Amparo", "Congelar racha").
String nombreCortoArticulo(ArticuloTienda a) => switch (a.comodin) {
  Comodin.lupaAuditor => Textos.comodinLupa,
  Comodin.abogadoSenior => Textos.comodinAbogado,
  Comodin.amparo => Textos.comodinAmparo,
  null => Textos.inventarioCongelar,
};

/// Pantalla 24 · Tienda (Figma 18:2347), en la pestaña Tienda.
///
/// Título y saldo, "Tu inventario", "Comodines" con el catálogo de 2
/// columnas y la nota RN03 al final. Comprar pide confirmación y conexión; las
/// monedas y las cantidades las devuelve el servidor.
class PantallaTienda extends ConsumerWidget {
  const PantallaTienda({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(datosTiendaProvider);
    final valor = datos.value;
    return MarcoPrincipal(
      pestana: PestanaApp.tienda,
      cuerpo: SafeArea(
        bottom: false,
        child: valor != null
            ? _Tienda(datos: valor)
            : datos.hasError
            ? MensajePantalla(
                texto: Textos.tiendaErrorCarga,
                textoBoton: Textos.reintentar,
                alPresionar: () => ref.invalidate(datosTiendaProvider),
              )
            : const _EsqueletoTienda(),
      ),
    );
  }
}

/// Título de pestaña (H1, encabezado con el foco al abrir).
class TituloPestana extends StatelessWidget {
  const TituloPestana(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => BloqueLectura(
    key: const ValueKey('titulo-pestana'),
    encabezado: true,
    autofocus: true,
    radio: 8,
    child: Text(texto, style: context.estilos.h1.copyWith(color: context.tokens.textoPrimario)),
  );
}

/// Subtítulo de sección (Título/H2, encabezado).
class TituloSeccion extends StatelessWidget {
  const TituloSeccion(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(texto, style: context.estilos.h2.copyWith(color: context.tokens.textoPrimario)),
  );
}

class _Tienda extends ConsumerStatefulWidget {
  const _Tienda({required this.datos});

  final DatosTienda datos;

  @override
  ConsumerState<_Tienda> createState() => _TiendaState();
}

class _TiendaState extends ConsumerState<_Tienda> {
  /// Artículo que se está comprando (sin doble toque).
  String? _comprando;

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: const ValueKey('aviso-tienda'),
          content: Semantics(liveRegion: true, child: Text(mensaje)),
        ),
      );
  }

  Future<void> _comprar(ArticuloTienda articulo) async {
    if (_comprando != null) return;
    final monedas = widget.datos.monedas;
    final confirmado = await DialogoConfirmacion.mostrar(
      context,
      titulo: Textos.confirmarCompraTitulo(articulo.nombre),
      texto: Textos.confirmarCompraTexto(articulo.precio, monedas - articulo.precio),
      textoConfirmar: Textos.comprar,
    );
    if (!confirmado || !mounted) return;
    setState(() => _comprando = articulo.id);
    try {
      final r = await ref.read(repositorioTiendaProvider).comprarArticulo(articulo.id);
      unawaited(ref.read(servicioHapticoProvider).suave());
      if (!mounted) return;
      refrescarTrasCompra(ref);
      _avisar(Textos.compraHecha(articulo.nombre, r.cantidadNueva, r.monedasRestantes));
    } on ExcepcionTienda catch (e) {
      if (!mounted) return;
      switch (e.motivo) {
        case MotivoExcepcionTienda.monedasInsuficientes:
          refrescarTrasCompra(ref);
          _avisar(Textos.compraSinMonedas);
        case MotivoExcepcionTienda.maximoAlcanzado:
          refrescarTrasCompra(ref);
          _avisar(Textos.compraMaximo);
        case MotivoExcepcionTienda.articuloInexistente:
          _avisar(Textos.compraError);
      }
    } on Object {
      if (mounted) _avisar(Textos.compraError);
    } finally {
      if (mounted) setState(() => _comprando = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final datos = widget.datos;
    final enLinea = ref.watch(conexionProvider) != EstadoConexion.sinConexion;
    final comodines = datos.articulos.where((a) => a.comodin != null).toList();
    final congelar = datos.articulos.where((a) => a.comodin == null).firstOrNull;
    final inventario = [
      ...comodines,
      if (congelar != null && datos.cantidad(congelar) > 0) congelar,
    ];

    Widget tarjeta(ArticuloTienda a) {
      final bloqueo = LogicaTienda.bloqueo(
        a,
        monedas: datos.monedas,
        cantidad: datos.cantidad(a),
        enLinea: enLinea,
      );
      return TarjetaArticulo(
        key: ValueKey('articulo-${a.id}'),
        icono: iconoArticulo(a),
        nombre: a.nombre,
        descripcion: a.descripcion,
        precio: a.precio,
        bloqueo: bloqueo,
        faltan: LogicaTienda.faltan(a, datos.monedas),
        cargando: _comprando == a.id,
        alComprar: () => _comprar(a),
      );
    }

    final clase = context.clasePantalla;
    // Móvil: 2 columnas con separación 12. Tablet horizontal (T24): las 4 en
    // una fila con el medianil de 24; entre 600 y 959, 2 columnas de 24.
    final columnas = clase.esAncho ? 4 : 2;
    final separacion = clase.esTablet ? MedidasAdaptativas.medianil : 12.0;
    final filas = <Widget>[
      for (var i = 0; i < datos.articulos.length; i += columnas) ...[
        if (i > 0) SizedBox(height: separacion),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < columnas; j++) ...[
                if (j > 0) SizedBox(width: separacion),
                Expanded(
                  child: i + j < datos.articulos.length
                      ? tarjeta(datos.articulos[i + j])
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      ],
    ];

    final tablet = clase.esTablet;
    return SingleChildScrollView(
      key: const ValueKey('tienda-desplazable'),
      padding: tablet
          ? const EdgeInsets.fromLTRB(
              MedidasAdaptativas.margen,
              20,
              MedidasAdaptativas.margen,
              MedidasAdaptativas.medianil,
            )
          : const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: _AnchoTablet(
        activo: tablet && !clase.esAncho,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                const TituloPestana(Textos.tiendaTitulo),
                PildoraSaldo(monedas: datos.monedas),
              ],
            ),
            SizedBox(height: tablet ? 28 : 14),
            const TituloSeccion(Textos.tuInventario),
            SizedBox(height: tablet ? 10 : 8),
            Semantics(
              container: true,
              label: Textos.inventarioLista(inventario.length),
              child: Wrap(
                key: const ValueKey('inventario'),
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final a in inventario)
                    PildoraInventario(
                      key: ValueKey('inventario-${a.id}'),
                      icono: iconoArticulo(a),
                      nombreCorto: nombreCortoArticulo(a),
                      nombre: a.nombre,
                      cantidad: datos.cantidad(a),
                    ),
                ],
              ),
            ),
            SizedBox(height: tablet ? 26 : 18),
            const TituloSeccion(Textos.comodinesSeccion),
            const SizedBox(height: 10),
            if (!enLinea) ...[
              const NotaTienda(
                key: ValueKey('nota-sin-conexion'),
                texto: Textos.necesitasConexionComprar,
                icono: IconosApp.alert,
              ),
              const SizedBox(height: 12),
            ],
            ...filas,
            SizedBox(height: tablet ? MedidasAdaptativas.medianil : 16),
            const NotaTienda(key: ValueKey('nota-rn03'), texto: Textos.notaRn03),
            if (tablet) ...[
              const SizedBox(height: MedidasAdaptativas.medianil),
              const _ConsejoTienda(),
            ],
          ],
        ),
      ),
    );
  }
}

/// Entre 600 y 959 el contenido se centra con el ancho máximo de una columna.
class _AnchoTablet extends StatelessWidget {
  const _AnchoTablet({required this.activo, required this.child});

  final bool activo;
  final Widget child;

  @override
  Widget build(BuildContext context) => activo
      ? Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: MedidasAdaptativas.contenidoUnaColumna),
            child: child,
          ),
        )
      : child;
}

/// Consejo de Sarko de la Tienda en tablet (Figma 101:4545 y 101:4548): la
/// tarjeta destacada y Sarko de 136 × 170 a la derecha, 44 aparte; la tarjeta
/// termina 30 arriba del pie de Sarko.
class _ConsejoTienda extends StatelessWidget {
  const _ConsejoTienda();

  @override
  Widget build(BuildContext context) {
    return const Row(
      key: ValueKey('consejo-tienda'),
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: 30),
            child: TarjetaConsejoSarko(consejo: Textos.tiendaConsejo, destacada: true),
          ),
        ),
        SizedBox(width: 44),
        SarkoImagen(
          key: ValueKey('sarko-tienda'),
          pose: PoseSarko.alegre,
          ancho: 136,
          decorativa: true,
        ),
      ],
    );
  }
}

/// Esqueleto con las medidas del encabezado, el inventario y el catálogo.
class _EsqueletoTienda extends StatelessWidget {
  const _EsqueletoTienda();

  @override
  Widget build(BuildContext context) {
    final color = context.tokens.fondoSuperficieAlt;
    Widget bloque(double alto, {double? ancho, double radio = 16}) => Container(
      width: ancho,
      height: alto,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radio)),
    );
    return Semantics(
      label: Textos.cargandoTienda,
      liveRegion: true,
      excludeSemantics: true,
      child: SingleChildScrollView(
        key: const ValueKey('esqueleto-tienda'),
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bloque(38, ancho: 342, radio: 999),
            const SizedBox(height: 14),
            bloque(26, ancho: 160, radio: 8),
            const SizedBox(height: 8),
            bloque(34, ancho: 300, radio: 999),
            const SizedBox(height: 18),
            bloque(26, ancho: 140, radio: 8),
            const SizedBox(height: 10),
            bloque(226, radio: 22),
            const SizedBox(height: 12),
            bloque(226, radio: 22),
          ],
        ),
      ),
    );
  }
}
