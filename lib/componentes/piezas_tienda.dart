import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'accion_enfocable.dart';
import 'chip_hud.dart';
import 'foco_retorno.dart';
import 'icono_app.dart';
import 'pildora.dart';

/// Saldo de la Tienda (Figma 24): píldora fondo/destacado, relleno 12/16/8,
/// separación 8, moneda de 22 y el saldo en Título/H3. Se lee "Tienes N
/// monedas".
class PildoraSaldo extends StatelessWidget {
  const PildoraSaldo({required this.monedas, super.key});

  final int monedas;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      container: true,
      label: Textos.saldoSemantica(monedas),
      excludeSemantics: true,
      child: Pildora(
        clave: const ValueKey('pildora-saldo'),
        fondo: tokens.fondoDestacado,
        relleno: const EdgeInsets.only(left: 12, right: 16, top: 8, bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconoApp(
              IconosApp.coin,
              tamano: 22,
              color: ChipHud.colorIcono(TipoChipHud.monedas, tokens),
            ),
            const SizedBox(width: 8),
            Text('$monedas', style: context.estilos.h3.copyWith(color: tokens.textoPrimario)),
          ],
        ),
      ),
    );
  }
}

/// Píldora del inventario (Figma 24): fondo/superficie, borde 1, radio 999,
/// relleno 10/12/8, separación 6, ícono de 16 y Etiqueta ("Lupa ×2"). Se
/// lee "Lupa de Auditor, 2 en inventario".
class PildoraInventario extends StatelessWidget {
  const PildoraInventario({
    required this.icono,
    required this.nombreCorto,
    required this.nombre,
    required this.cantidad,
    super.key,
  });

  final IconData icono;
  final String nombreCorto;

  /// Nombre completo (para el lector).
  final String nombre;
  final int cantidad;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      container: true,
      label: Textos.inventarioSemantica(nombre, cantidad),
      excludeSemantics: true,
      child: Pildora(
        fondo: tokens.fondoSuperficie,
        relleno: const EdgeInsets.only(left: 10, right: 12, top: 8, bottom: 8),
        borde: Border.all(color: tokens.bordeDefault),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconoApp(icono, tamano: 16, color: tokens.textoAcento),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                Textos.inventarioPildora(nombreCorto, cantidad),
                style: context.estilos.etiqueta.copyWith(color: tokens.textoPrimario),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Por qué no se puede comprar un artículo (o `ninguno`).
enum BloqueoCompra { ninguno, sinMonedas, maximo, sinConexion }

/// Botón de precio (Figma 24): alto 48, radio 12, accion/primaria, moneda de
/// 18 y el precio en Botón texto/en-primario. Deshabilitado en
/// fondo/superficie-alt con texto/secundario; en máximo dice "Máximo".
class BotonPrecio extends StatelessWidget {
  const BotonPrecio({
    required this.precio,
    required this.etiquetaSemantica,
    required this.alPresionar,
    this.maximo = false,
    this.cargando = false,
    super.key,
  });

  static const double alto = 48;
  static const double radio = 12;

  final int precio;
  final String etiquetaSemantica;

  /// `null` lo deja deshabilitado.
  final VoidCallback? alPresionar;
  final bool maximo;

  /// Compra en curso: no responde a otro toque y muestra un indicador.
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final habilitado = alPresionar != null;
    final colorTexto = habilitado ? tokens.textoEnPrimario : tokens.textoSecundario;
    final contenido = cargando
        ? SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: colorTexto),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!maximo) ...[
                IconoApp(
                  IconosApp.coin,
                  tamano: 18,
                  color: habilitado
                      ? tokens.textoEnPrimario
                      : ChipHud.colorIcono(TipoChipHud.monedas, tokens),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  maximo ? Textos.precioMaximo : '$precio',
                  style: context.estilos.boton.copyWith(color: colorTexto),
                ),
              ),
            ],
          );
    return AccionEnfocable(
      alPresionar: cargando ? null : alPresionar,
      radio: radio,
      semantica: (hijo) => Semantics(
        button: true,
        enabled: habilitado,
        label: cargando ? Textos.comprando : etiquetaSemantica,
        excludeSemantics: true,
        child: hijo,
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: alto),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: habilitado ? tokens.accionPrimaria : tokens.fondoSuperficieAlt,
          borderRadius: BorderRadius.circular(radio),
        ),
        child: contenido,
      ),
    );
  }
}

/// Tarjeta de artículo (Figma 24): ancho 165, fondo/superficie, borde 1,
/// radio 22, sombra de módulo, relleno 16 y separación 10: cuadro de ícono de
/// 52 (fondo/destacado, radio 16, ícono 28), nombre (Título/H3), descripción
/// (Leyenda) y el botón de precio, que queda al pie aunque la tarjeta crezca.
/// Con saldo insuficiente aparece "Te faltan N" bajo el botón.
class TarjetaArticulo extends StatelessWidget {
  const TarjetaArticulo({
    required this.icono,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.bloqueo,
    required this.alComprar,
    this.faltan = 0,
    this.cargando = false,
    this.nodoFoco,
    super.key,
  });

  static const double ancho = 165;

  final IconData icono;
  final String nombre;
  final String descripcion;
  final int precio;
  final BloqueoCompra bloqueo;
  final VoidCallback alComprar;

  /// Monedas que faltan (con [BloqueoCompra.sinMonedas]).
  final int faltan;
  final bool cargando;

  /// Nodo al que vuelve el foco al cerrar el diálogo de compra (T-13); no es
  /// parada de Tab (ver [FocoRetorno]).
  final FocusNode? nodoFoco;

  @override
  Widget build(BuildContext context) {
    final nodo = nodoFoco;
    final tarjeta = _tarjeta(context);
    return nodo == null ? tarjeta : FocoRetorno(nodoFoco: nodo, radio: 22, child: tarjeta);
  }

  Widget _tarjeta(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final etiqueta = switch (bloqueo) {
      BloqueoCompra.ninguno => Textos.comprarSemantica(nombre, precio),
      BloqueoCompra.sinMonedas => Textos.comprarFaltanSemantica(nombre, precio, faltan),
      BloqueoCompra.maximo => Textos.comprarMaximoSemantica(nombre, precio),
      BloqueoCompra.sinConexion => Textos.comprarSinConexionSemantica(nombre, precio),
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tokens.bordeDefault),
        boxShadow: EfectosApp.sombraModulo,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tokens.fondoDestacado,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconoApp(icono, tamano: 28, color: tokens.textoAcento),
          ),
          const SizedBox(height: 10),
          Text(nombre, style: estilos.h3.copyWith(color: tokens.textoPrimario)),
          const SizedBox(height: 10),
          Text(descripcion, style: estilos.leyenda.copyWith(color: tokens.textoSecundario)),
          const SizedBox(height: 10),
          const Spacer(),
          BotonPrecio(
            precio: precio,
            etiquetaSemantica: etiqueta,
            maximo: bloqueo == BloqueoCompra.maximo,
            cargando: cargando,
            alPresionar: bloqueo == BloqueoCompra.ninguno ? alComprar : null,
          ),
          if (bloqueo == BloqueoCompra.sinMonedas) ...[
            const SizedBox(height: 6),
            ExcludeSemantics(
              child: Text(
                Textos.teFaltan(faltan),
                style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Nota informativa en fondo/superficie-alt (Figma 24, RN03): radio 16,
/// relleno 14×12, separación 10, ícono `info` de 20 y Leyenda.
class NotaTienda extends StatelessWidget {
  const NotaTienda({required this.texto, this.icono = IconosApp.info, super.key});

  final String texto;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: tokens.fondoSuperficieAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            IconoApp(icono, tamano: 20, color: tokens.textoPrimario),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                texto,
                style: context.estilos.leyenda.copyWith(color: tokens.textoPrimario),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
