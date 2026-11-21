import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import '../datos/modelos/examen.dart';
import 'hoja_lateral.dart';
import 'icono_app.dart';
import 'opcion_justificacion.dart';

/// Avatar de la Inspectora Vega (Figma 33:424): 44, radio 14, `#6B4BA1` y el
/// mazo blanco de 24. Decorativo.
class AvatarJefe extends StatelessWidget {
  const AvatarJefe({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: EfectosApp.avatarJefe,
      borderRadius: BorderRadius.circular(14),
    ),
    child: const IconoApp(IconosApp.gavel, tamano: 24, color: EfectosApp.blancoCrisis),
  );
}

/// Barra del Jefe (Figma 33:423): `#162030`, radio 18, relleno 12/14/10,
/// separación 12; el avatar y una columna con "Inspectora Vega" y "HP N%",
/// la pista de 10 con la vida proporcional al HP (baja en 300 ms; sin
/// animación con "reducir animaciones") y "Auditora de protección de datos".
/// Se lee como un bloque.
class BarraDelJefe extends StatelessWidget {
  const BarraDelJefe({required this.hp, super.key});

  /// 0 a 100.
  final int hp;

  @override
  Widget build(BuildContext context) {
    final estilos = context.estilos;
    final fraccion = (hp / 100).clamp(0.0, 1.0);
    final duracion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : EfectosApp.duracionVidaJefe;
    return Semantics(
      container: true,
      label: Textos.barraJefeSemantica(hp),
      excludeSemantics: true,
      child: Container(
        key: const ValueKey('barra-jefe'),
        padding: const EdgeInsets.only(left: 12, right: 14, top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: EfectosApp.barraJefe,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const AvatarJefe(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Textos.inspectoraVega,
                          style: estilos.cuerpoEnfasis.copyWith(color: EfectosApp.blancoCrisis),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Textos.hpJefe(hp),
                        key: const ValueKey('hp-jefe'),
                        style: estilos.etiqueta.copyWith(color: EfectosApp.vidaJefe),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 10,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: EfectosApp.pistaVidaJefe,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: fraccion),
                        duration: duracion,
                        builder: (context, valor, _) => FractionallySizedBox(
                          key: const ValueKey('vida-jefe'),
                          widthFactor: valor,
                          heightFactor: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: EfectosApp.vidaJefe,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Textos.auditoraDatos,
                    style: estilos.leyenda.copyWith(color: EfectosApp.textoCrisisSecundario),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Línea de crisis (Figma 27): H0 Detección · H6 Contención · H24 Aviso ·
/// H72 Autoridad. Punto 34×24 radio 12 con la hora y la etiqueta debajo,
/// conectores 28×2. Activo: `#B52426` con texto blanco; inactivo: `#2A3850`
/// con `#94A3B8`. Se lee como un bloque.
class LineaDeCrisis extends StatelessWidget {
  const LineaDeCrisis({this.activa = FaseCrisis.deteccion, super.key});

  final FaseCrisis activa;

  static String etiqueta(FaseCrisis f) => switch (f) {
    FaseCrisis.deteccion => Textos.faseDeteccion,
    FaseCrisis.contencion => Textos.faseContencion,
    FaseCrisis.aviso => Textos.faseAviso,
    FaseCrisis.autoridad => Textos.faseAutoridad,
  };

  @override
  Widget build(BuildContext context) {
    final estilos = context.estilos;
    Widget punto(FaseCrisis f) {
      final activo = f == activa;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            key: ValueKey('punto-${f.name}'),
            constraints: const BoxConstraints(minWidth: 34, minHeight: 24),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: activo ? EfectosApp.alertaCrisis : EfectosApp.inactivoCrisis,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              Textos.horaCorta(f.hora),
              style: estilos.leyenda.copyWith(
                color: activo ? EfectosApp.blancoCrisis : EfectosApp.textoCrisisSecundario,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(etiqueta(f), style: estilos.leyenda.copyWith(color: EfectosApp.textoCrisis)),
        ],
      );
    }

    return Semantics(
      container: true,
      label: Textos.lineaCrisisSemantica,
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          key: const ValueKey('linea-crisis'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, f) in FaseCrisis.values.indexed) ...[
              if (i > 0)
                Container(
                  width: 28,
                  height: 2,
                  margin: const EdgeInsets.only(left: 6, right: 6, top: 11),
                  color: EfectosApp.inactivoCrisis,
                ),
              punto(f),
            ],
          ],
        ),
      ),
    );
  }
}

/// Chip "Hora 24 de 72" (Figma 28): `#B52426`, radio 999, relleno 10/12/5,
/// separación 6, `clock` 14 y Etiqueta blanca.
class ChipHoraCrisis extends StatelessWidget {
  const ChipHoraCrisis({required this.hora, super.key});

  final int hora;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: Textos.horaCrisis(hora),
    excludeSemantics: true,
    child: Container(
      key: const ValueKey('hora-crisis'),
      padding: const EdgeInsets.only(left: 10, right: 12, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: EfectosApp.alertaCrisis,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const IconoApp(IconosApp.clock, tamano: 14, color: EfectosApp.blancoCrisis),
          const SizedBox(width: 6),
          Text(
            Textos.horaCrisis(hora),
            style: context.estilos.etiqueta.copyWith(color: EfectosApp.blancoCrisis),
          ),
        ],
      ),
    ),
  );
}

/// Temporizador de la decisión (Figma 10:188): fondo circular de 80 con la
/// sombra de tarjeta y anillo de 64 (trazo 6, pista fondo/superficie-alt) que
/// se vacía con el tiempo, con el número en Fredoka Bold 24. Normal en
/// accion/primaria; urgente (≤ 5 s) en estado/ilegal. Se lee "Quedan N
/// segundos" (los avisos los hace quien lo usa).
class TemporizadorCrisis extends StatelessWidget {
  const TemporizadorCrisis({required this.restante, required this.limite, super.key});

  static const double fondo = 80;
  static const double anillo = 64;
  static const double grosor = 6;

  /// Segundos para considerarlo urgente.
  static const int umbralUrgente = 5;

  final Duration restante;
  final Duration limite;

  static int segundos(Duration d) => (d.inMilliseconds / 1000).ceil().clamp(0, 999);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final s = segundos(restante);
    final urgente = s <= umbralUrgente;
    final color = urgente ? tokens.estadoIlegal : tokens.accionPrimaria;
    final fraccion = limite.inMilliseconds == 0
        ? 0.0
        : (restante.inMilliseconds / limite.inMilliseconds).clamp(0.0, 1.0);
    return Semantics(
      container: true,
      label: Textos.quedanSegundos(s),
      excludeSemantics: true,
      child: Container(
        key: const ValueKey('temporizador-crisis'),
        width: fondo,
        height: fondo,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tokens.fondoSuperficie,
          shape: BoxShape.circle,
          boxShadow: EfectosApp.sombraVeredicto,
        ),
        child: SizedBox.square(
          dimension: anillo,
          child: CustomPaint(
            painter: PintorAnillo(
              fraccion: fraccion,
              color: color,
              pista: tokens.fondoSuperficieAlt,
            ),
            child: Center(
              child: Text(
                '$s',
                key: const ValueKey('segundos-crisis'),
                textScaler: TextScaler.noScaling,
                style: context.estilos.h1.copyWith(fontSize: 24, height: 1, color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Anillo del temporizador: pista completa y arco desde arriba, en sentido
/// horario, con punta redonda.
class PintorAnillo extends CustomPainter {
  const PintorAnillo({required this.fraccion, required this.color, required this.pista});

  final double fraccion;
  final Color color;
  final Color pista;

  @override
  void paint(Canvas canvas, Size size) {
    const g = TemporizadorCrisis.grosor;
    final rect = Offset.zero & size;
    final circulo = rect.deflate(g / 2);
    canvas.drawArc(
      circulo,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = pista
        ..style = PaintingStyle.stroke
        ..strokeWidth = g,
    );
    if (fraccion <= 0) return;
    canvas.drawArc(
      circulo,
      -math.pi / 2,
      2 * math.pi * fraccion,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = g,
    );
  }

  @override
  bool shouldRepaint(PintorAnillo old) =>
      old.fraccion != fraccion || old.color != color || old.pista != pista;
}

/// Chip de daño o de fallo (Figma 28c, sobre la barra del Jefe).
/// - Daño: `#B52426`, sombra elevada, `zap` y "−20 HP · ¡Argumento sólido!"
///   en Etiqueta blanca.
/// - Fallo (no está en Figma): fondo/superficie con borde estado/ilegal,
///   `heart` y el motivo en Etiqueta texto/primario.
///
/// Se anuncia (región en vivo) con [etiquetaSemantica].
class ChipGolpe extends StatelessWidget {
  const ChipGolpe({
    required this.texto,
    required this.etiquetaSemantica,
    this.danio = true,
    super.key,
  });

  final String texto;
  final String etiquetaSemantica;
  final bool danio;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colorTexto = danio ? EfectosApp.blancoCrisis : tokens.textoPrimario;
    return Semantics(
      container: true,
      liveRegion: true,
      label: etiquetaSemantica,
      excludeSemantics: true,
      child: Container(
        key: ValueKey(danio ? 'chip-danio' : 'chip-fallo'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: danio ? EfectosApp.alertaCrisis : tokens.fondoSuperficie,
          borderRadius: BorderRadius.circular(999),
          border: danio ? null : Border.all(color: tokens.estadoIlegal, width: 1.5),
          boxShadow: EfectosApp.sombraChipDanio,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconoApp(
              danio ? IconosApp.zap : IconosApp.heart,
              tamano: 16,
              color: danio ? EfectosApp.blancoCrisis : tokens.estadoIlegal,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(texto, style: context.estilos.etiqueta.copyWith(color: colorTexto)),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Comodines desactivados en el examen" (Figma 33:413): píldora de 48,
/// fondo/superficie-alt, `lock` 16 y Etiqueta texto/secundario.
class PildoraComodinesBloqueados extends StatelessWidget {
  const PildoraComodinesBloqueados({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      container: true,
      label: Textos.comodinesDesactivados,
      excludeSemantics: true,
      child: Container(
        key: const ValueKey('comodines-bloqueados'),
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.only(left: 10, right: 12, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: tokens.fondoSuperficieAlt,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconoApp(IconosApp.lock, tamano: 16, color: tokens.textoSecundario),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                Textos.comodinesDesactivados,
                style: context.estilos.etiqueta.copyWith(color: tokens.textoSecundario),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Panel de contraargumento (Figma 34:853): fondo/superficie, radio superior
/// 28, sombra elevada, relleno 12/34/24 y separación 14. Agarre, la réplica
/// (avatar del Jefe y globo `#162030` con "INSPECTORA VEGA" y la cita), "Defiende
/// tu veredicto · elige el fundamento", las dos opciones (tocar responde) y la
/// fila de tiempo con la cuenta regresiva.
class PanelContraargumento extends StatelessWidget {
  const PanelContraargumento({
    required this.replica,
    required this.segundosRestantes,
    required this.alElegir,
    this.nodoFocoReplica,
    super.key,
  });

  final Replica replica;
  final int segundosRestantes;

  /// `null` mientras se envía (no se puede elegir dos veces).
  final ValueChanged<int>? alElegir;
  final FocusNode? nodoFocoReplica;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final elegir = alElegir;
    return Container(
      key: const ValueKey('panel-contraargumento'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 34),
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        // En tablet (hoja lateral, T28b): las cuatro esquinas y borde de 1.
        borderRadius: HojaLateral.radioDe(context, 28),
        border: HojaLateral.bordeDe(context, tokens.bordeDefault),
        boxShadow: EfectosApp.sombraBuzon,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: tokens.bordeDefault,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 14),
          Focus(
            focusNode: nodoFocoReplica,
            child: Semantics(
              container: true,
              label: '${Textos.inspectoraVega}: ${replica.texto}',
              excludeSemantics: true,
              child: Row(
                key: const ValueKey('replica-jefe'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AvatarJefe(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: const BoxDecoration(
                        color: EfectosApp.barraJefe,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Textos.inspectoraVegaMayusculas,
                            style: estilos.leyenda.copyWith(color: EfectosApp.textoReplica),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Textos.replicaCita(replica.texto),
                            style: estilos.h3.copyWith(color: EfectosApp.blancoCrisis),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            Textos.defiendeVeredicto,
            textAlign: TextAlign.center,
            style: estilos.etiqueta.copyWith(color: tokens.textoSecundario),
          ),
          for (final (i, f) in replica.fundamentos.indexed) ...[
            const SizedBox(height: 14),
            OpcionJustificacion(
              key: ValueKey('fundamento-$i'),
              texto: f,
              posicion: i + 1,
              total: replica.fundamentos.length,
              alElegir: elegir == null ? null : () => elegir(i),
            ),
          ],
          const SizedBox(height: 14),
          ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconoApp(IconosApp.alert, tamano: 14, color: tokens.estadoIlegal),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    Textos.tienesParaResponder(segundosRestantes),
                    key: const ValueKey('tiempo-replica'),
                    style: estilos.leyenda.copyWith(color: tokens.estadoIlegal),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "El Jefe" del panel lateral del Examen en tablet (T28, Figma `101:5171`):
/// fondo/superficie, borde 1, radio 20, relleno 20 y separación 12;
/// "INSPECTORA VEGA · AUDITORÍA" (Leyenda texto/acento), la barra del Jefe y
/// la regla (Cuerpo/Base texto/secundario).
class TarjetaJefe extends StatelessWidget {
  const TarjetaJefe({required this.hp, super.key});

  final int hp;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return Container(
      key: const ValueKey('tarjeta-jefe'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.bordeDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Textos.tarjetaJefeEtiqueta,
            style: estilos.leyenda.copyWith(color: tokens.textoAcento),
          ),
          const SizedBox(height: 12),
          BarraDelJefe(hp: hp),
          const SizedBox(height: 12),
          Text(
            Textos.tarjetaJefeTexto,
            style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
          ),
        ],
      ),
    );
  }
}
