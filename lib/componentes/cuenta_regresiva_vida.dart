import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../core/textos/textos.dart';
import '../core/utilidades/cronometro.dart';
import '../core/utilidades/extensiones_contexto.dart';

/// Cuenta regresiva a la próxima vida (Figma 20: `HH:MM:SS`, Fredoka Bold 52
/// estado/ilegal, alto 64).
///
/// Parte de [falta], lo que dijo el servidor, y descuenta con un reloj
/// monótono ([Cronometro]); **nunca** usa la hora del dispositivo. Se
/// redibuja cada segundo y, al llegar a 0, llama una vez a [alTerminar] (que
/// vuelve a pedir las vidas). Con texto grande encoge, nunca desborda.
///
/// Para el lector: el tiempo visible se excluye y en su lugar se lee
/// "Próxima vida en 1 hora y 47 minutos", que cambia por minuto y no se
/// anuncia solo (sin región en vivo).
class CuentaRegresivaVida extends StatefulWidget {
  const CuentaRegresivaVida({
    required this.falta,
    this.alTerminar,
    this.crearCronometro = CronometroSistema.new,
    super.key,
  });

  static const double alto = 64;
  static const double tamanoTexto = 52;

  final Duration falta;
  final VoidCallback? alTerminar;

  /// Reloj monótono (en las pruebas, uno falso).
  final Cronometro Function() crearCronometro;

  /// `01:47:32`.
  static String formato(Duration d) {
    final s = d.isNegative ? 0 : d.inSeconds;
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(s ~/ 3600)}:${dos(s % 3600 ~/ 60)}:${dos(s % 60)}';
  }

  @override
  State<CuentaRegresivaVida> createState() => _CuentaRegresivaVidaState();
}

class _CuentaRegresivaVidaState extends State<CuentaRegresivaVida> {
  /// Cada cuenta empieza en 0, aunque el cronómetro venga de antes.
  late final Cronometro _cronometro = widget.crearCronometro()..reiniciar();
  Timer? _tic;
  bool _avisado = false;

  Duration get _restante {
    final r = widget.falta - _cronometro.transcurrido;
    return r.isNegative ? Duration.zero : r;
  }

  @override
  void initState() {
    super.initState();
    _tic = Timer.periodic(const Duration(seconds: 1), (_) => _alTic());
  }

  @override
  void didUpdateWidget(CuentaRegresivaVida oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nuevo dato del servidor: se vuelve a contar desde ahí.
    if (oldWidget.falta != widget.falta) {
      _cronometro.reiniciar();
      _avisado = false;
    }
  }

  void _alTic() {
    if (!mounted) return;
    setState(() {});
    if (_restante == Duration.zero && !_avisado) {
      _avisado = true;
      widget.alTerminar?.call();
    }
  }

  @override
  void dispose() {
    _tic?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restante = _restante;
    return Semantics(
      key: const ValueKey('cuenta-regresiva'),
      label: Textos.proximaVidaSemantica(restante),
      excludeSemantics: true,
      child: SizedBox(
        height: CuentaRegresivaVida.alto,
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            CuentaRegresivaVida.formato(restante),
            key: const ValueKey('tiempo-vida'),
            maxLines: 1,
            style: context.estilos.h1.copyWith(
              fontSize: CuentaRegresivaVida.tamanoTexto,
              height: 1,
              color: context.tokens.estadoIlegal,
            ),
          ),
        ),
      ),
    );
  }
}
