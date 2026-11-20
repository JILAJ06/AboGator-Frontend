import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'accion_enfocable.dart';
import 'icono_app.dart';

/// Tarjeta de perfil (Figma 25): accion/primaria, radio 22, relleno 16,
/// separación 14; avatar de 60 (fondo/destacado) con las iniciales en
/// Título/H2 accion/secundaria, el nombre en Título/H2 y el detalle ("Rol ·
/// Nivel N · X XP") en Leyenda, ambos texto/en-primario. Se lee como un bloque.
class TarjetaPerfil extends StatelessWidget {
  const TarjetaPerfil({
    required this.iniciales,
    required this.nombre,
    required this.detalle,
    super.key,
  });

  final String iniciales;
  final String nombre;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return Semantics(
      container: true,
      label: Textos.tarjetaPerfilSemantica(nombre, detalle),
      excludeSemantics: true,
      child: Container(
        key: const ValueKey('tarjeta-perfil'),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tokens.accionPrimaria,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: tokens.fondoDestacado, shape: BoxShape.circle),
              child: FittedBox(
                child: Text(iniciales, style: estilos.h2.copyWith(color: tokens.accionSecundaria)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre, style: estilos.h2.copyWith(color: tokens.textoEnPrimario)),
                  const SizedBox(height: 2),
                  Text(detalle, style: estilos.leyenda.copyWith(color: tokens.textoEnPrimario)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de estadística (Figma 25): ancho 166, fondo/superficie, borde 1,
/// radio 16, relleno 14×12, separación 10; ícono de 22, valor en Título/H3 y
/// etiqueta en Leyenda texto/secundario. Se lee "Racha actual: 7 días".
class TarjetaEstadistica extends StatelessWidget {
  const TarjetaEstadistica({
    required this.icono,
    required this.colorIcono,
    required this.valor,
    required this.etiqueta,
    this.valorSemantico,
    super.key,
  });

  static const double ancho = 166;

  final IconData icono;
  final Color colorIcono;
  final String valor;
  final String etiqueta;

  /// Valor como se lee (por defecto, [valor]); p. ej. "0 de 5".
  final String? valorSemantico;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return Semantics(
      container: true,
      label: Textos.estadisticaSemantica(etiqueta, valorSemantico ?? valor),
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: tokens.fondoSuperficie,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tokens.bordeDefault),
        ),
        child: Row(
          children: [
            IconoApp(icono, tamano: 22, color: colorIcono),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(valor, style: estilos.h3.copyWith(color: tokens.textoPrimario)),
                  Text(etiqueta, style: estilos.leyenda.copyWith(color: tokens.textoSecundario)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Medalla de insignia (Figma 25): ancho 79, círculo de 60 con borde 3
/// accion/acento, fondo del color del módulo e ícono blanco de 26, y el
/// nombre en Leyenda centrada (máximo dos líneas). Bloqueada:
/// fondo/superficie-alt, borde/default, `lock` y texto/secundario. Se lee
/// "Guardián de datos, obtenida" / "…, bloqueada".
class MedallaInsignia extends StatelessWidget {
  const MedallaInsignia({
    required this.nombre,
    required this.icono,
    required this.desbloqueada,
    this.colorModulo,
    super.key,
  });

  static const double ancho = 79;
  static const double diametro = 60;

  final String nombre;
  final IconData icono;
  final bool desbloqueada;

  /// Fondo de la medalla desbloqueada.
  final Color? colorModulo;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      container: true,
      label: Textos.insigniaSemantica(nombre, obtenida: desbloqueada),
      excludeSemantics: true,
      child: SizedBox(
        width: ancho,
        child: Column(
          children: [
            Container(
              width: diametro,
              height: diametro,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: desbloqueada
                    ? (colorModulo ?? tokens.accionPrimaria)
                    : tokens.fondoSuperficieAlt,
                border: Border.all(
                  color: desbloqueada ? tokens.accionAcento : tokens.bordeDefault,
                  width: 3,
                ),
              ),
              child: IconoApp(
                desbloqueada ? icono : IconosApp.lock,
                tamano: 26,
                color: desbloqueada ? EfectosApp.iconoSobreModulo : tokens.textoSecundario,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              nombre,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.estilos.leyenda.copyWith(
                color: desbloqueada ? tokens.textoPrimario : tokens.textoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila del menú del Perfil (Figma 25): relleno 16×14, separación 12, ícono
/// de 20, texto en Cuerpo/Énfasis y `chevron-right` de 18; alto ≥ 48.
/// [peligro] la pinta en estado/ilegal ("Cerrar sesión").
class FilaMenu extends StatelessWidget {
  const FilaMenu({
    required this.icono,
    required this.texto,
    required this.alPresionar,
    this.peligro = false,
    super.key,
  });

  final IconData icono;
  final String texto;
  final VoidCallback alPresionar;
  final bool peligro;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = peligro ? tokens.estadoIlegal : tokens.textoPrimario;
    return AccionEnfocable(
      alPresionar: alPresionar,
      radio: 12,
      semantica: (hijo) =>
          Semantics(button: true, label: texto, excludeSemantics: true, child: hijo),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            IconoApp(icono, tamano: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(texto, style: context.estilos.cuerpoEnfasis.copyWith(color: color)),
            ),
            const SizedBox(width: 12),
            IconoApp(IconosApp.chevron, tamano: 18, color: tokens.textoSecundario),
          ],
        ),
      ),
    );
  }
}

/// Menú agrupado (Figma 25): fondo/superficie, borde 1, radio 18 y las
/// [filas] separadas por divisores de 1 (sin divisor después de la última).
class MenuAgrupado extends StatelessWidget {
  const MenuAgrupado({required this.filas, super.key});

  final List<Widget> filas;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      key: const ValueKey('menu-perfil'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.bordeDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, f) in filas.indexed) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: tokens.bordeDefault),
            f,
          ],
        ],
      ),
    );
  }
}

/// Botón cuadrado de 48 (Figma 25, ajustes): fondo/superficie, borde 1,
/// radio 12 e ícono de 20.
class BotonIconoCuadrado extends StatelessWidget {
  const BotonIconoCuadrado({
    required this.icono,
    required this.etiqueta,
    required this.alPresionar,
    super.key,
  });

  final IconData icono;
  final String etiqueta;
  final VoidCallback alPresionar;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AccionEnfocable(
      alPresionar: alPresionar,
      radio: 12,
      semantica: (hijo) =>
          Semantics(button: true, label: etiqueta, excludeSemantics: true, child: hijo),
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tokens.fondoSuperficie,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tokens.bordeDefault),
        ),
        child: IconoApp(icono, tamano: 20, color: tokens.textoPrimario),
      ),
    );
  }
}
