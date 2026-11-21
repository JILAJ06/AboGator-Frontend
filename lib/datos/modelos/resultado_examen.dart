/// Certificado de un módulo (29, RF-41). Lo emite el servidor.
class Certificado {
  const Certificado({
    required this.folio,
    required this.moduloId,
    required this.nombreModulo,
    required this.nombrePersona,
    required this.aciertos,
    required this.totalDecisiones,
    required this.fecha,
  });

  /// Folio único (por ejemplo `AG-M1-0001`).
  final String folio;
  final String moduloId;
  final String nombreModulo;
  final String nombrePersona;
  final int aciertos;
  final int totalDecisiones;

  /// Fecha de emisión (hora del servidor).
  final DateTime fecha;

  /// Meses abreviados en español, en minúscula y sin punto.
  static const List<String> mesesCortos = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  /// Meses completos (para el lector de pantalla).
  static const List<String> meses = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  /// "28 oct 2026".
  static String fechaCorta(DateTime f) => '${f.day} ${mesesCortos[f.month - 1]} ${f.year}';

  /// "28 de octubre de 2026".
  static String fechaLarga(DateTime f) => '${f.day} de ${meses[f.month - 1]} de ${f.year}';
}

/// El módulo que se desbloqueó al aprobar.
class ModuloDesbloqueado {
  const ModuloDesbloqueado({required this.id, required this.numero, required this.nombre});

  final String id;
  final int numero;
  final String nombre;
}

/// Resultado del Examen Final ya registrado por el servidor.
class ResultadoRegistrado {
  const ResultadoRegistrado({
    required this.aprobado,
    required this.vidas,
    this.certificado,
    this.siguienteModulo,
    this.faltaParaProximaVida,
  });

  final bool aprobado;

  /// Solo si aprobó.
  final Certificado? certificado;

  /// `null` si era el último módulo (o si reprobó).
  final ModuloDesbloqueado? siguienteModulo;
  final int vidas;

  /// Tiempo para la próxima vida; `null` con 5 vidas.
  final Duration? faltaParaProximaVida;
}
