import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../core/utilidades/cronometro.dart';

/// Cuenta regresiva del examen con un [Cronometro] monótono (nunca el reloj
/// del dispositivo). Mientras [detenido] no corre (pausa, envío, chip de
/// golpe) y al volver sigue desde donde iba. Cambiar [ronda] la reinicia.
///
/// Llama [alAgotar] una sola vez al llegar a 0 y [alSegundo] cada vez que
/// cambia el segundo que se muestra (para los anuncios).
class RelojCrisis extends StatefulWidget {
  const RelojCrisis({
    required this.limite,
    required this.ronda,
    required this.crearCronometro,
    required this.constructor,
    this.detenido = false,
    this.alAgotar,
    this.alSegundo,
    super.key,
  });

  final Duration limite;
  final Object ronda;
  final Cronometro Function() crearCronometro;
  final Widget Function(BuildContext context, Duration restante) constructor;
  final bool detenido;
  final VoidCallback? alAgotar;
  final ValueChanged<int>? alSegundo;

  /// Cada cuánto se revisa el cronómetro.
  static const Duration tic = Duration(milliseconds: 200);

  @override
  State<RelojCrisis> createState() => _RelojCrisisState();
}

class _RelojCrisisState extends State<RelojCrisis> {
  late final Cronometro _cronometro = widget.crearCronometro();
  Timer? _tic;

  /// Lo que corrió antes de la última pausa.
  Duration _acumulado = Duration.zero;
  bool _agotado = false;
  int? _ultimoSegundo;

  Duration get _transcurrido =>
      _acumulado + (widget.detenido ? Duration.zero : _cronometro.transcurrido);

  Duration get _restante {
    final r = widget.limite - _transcurrido;
    return r.isNegative ? Duration.zero : r;
  }

  static int _segundos(Duration d) => (d.inMilliseconds / 1000).ceil();

  @override
  void initState() {
    super.initState();
    _cronometro.reiniciar();
    _tic = Timer.periodic(RelojCrisis.tic, (_) => _revisar());
    WidgetsBinding.instance.addPostFrameCallback((_) => _revisar(forzar: true));
  }

  @override
  void didUpdateWidget(RelojCrisis viejo) {
    super.didUpdateWidget(viejo);
    if (viejo.ronda != widget.ronda) {
      _acumulado = Duration.zero;
      _agotado = false;
      _ultimoSegundo = null;
      _cronometro.reiniciar();
      WidgetsBinding.instance.addPostFrameCallback((_) => _revisar(forzar: true));
      return;
    }
    if (!viejo.detenido && widget.detenido) {
      // Se detiene: guarda lo corrido.
      _acumulado += _cronometro.transcurrido;
    } else if (viejo.detenido && !widget.detenido) {
      _cronometro.reiniciar();
    }
  }

  void _revisar({bool forzar = false}) {
    if (!mounted) return;
    final restante = _restante;
    final s = _segundos(restante);
    if (s != _ultimoSegundo || forzar) {
      _ultimoSegundo = s;
      setState(() {});
      if (!widget.detenido) widget.alSegundo?.call(s);
    }
    if (restante == Duration.zero && !_agotado && !widget.detenido) {
      _agotado = true;
      widget.alAgotar?.call();
    }
  }

  @override
  void dispose() {
    _tic?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.constructor(context, _restante);
}
