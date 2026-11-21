import '../modelos/tarjeta.dart';

/// Una decisión del escenario tal como la guarda el servidor (con la
/// respuesta correcta y el fundamento correcto).
class DecisionEscenario {
  const DecisionEscenario({
    required this.hora,
    required this.personaje,
    required this.rol,
    required this.texto,
    required this.respuestaCorrecta,
    required this.replica,
    required this.fundamentos,
    required this.fundamentoCorrecto,
    this.iniciales,
  });

  final int hora;
  final String personaje;
  final String rol;
  final String texto;
  final String? iniciales;
  final Veredicto respuestaCorrecta;
  final String replica;
  final List<String> fundamentos;

  /// 0 o 1.
  final int fundamentoCorrecto;
}

/// Escenario del Examen Final del módulo 1 (Protección de datos):
/// "¡Ransomware! Se filtró la base de usuarios". Las decisiones 8 y 9 vienen
/// de Figma 28 y 28c; las demás siguen el ciclo de una brecha (detección,
/// contención, evidencia, aviso, documentación y proveedores). Sin números de
/// artículo: el contenido legal está listado en el reporte de la T-11 para
/// verificarlo contra el curso.
abstract final class EscenarioRansomware {
  static const String moduloId = 'mod-1';
  static const String titulo = '¡Ransomware! Se filtró la base de usuarios';
  static const String descripcion =
      'Tienes 72 horas para tomar las decisiones correctas antes de que la '
      'Inspectora Vega cierre la auditoría.';
  static const String etiqueta = 'CRISIS · BRECHA DE DATOS';

  /// Tema de las apelaciones de este examen.
  static const String tema = 'Brechas de seguridad';

  /// Máximo de caracteres del título de una apelación.
  static const int maximoTitulo = 45;

  /// Id de la decisión [indice] (1 a 10): `ran-01`…`ran-10`.
  static String idDe(int indice) => 'ran-${indice.toString().padLeft(2, '0')}';

  /// "Hora 24 · CTO", recortado con "…" a [maximoTitulo].
  static String tituloApelacion(int hora, String personaje) {
    final t = 'Hora $hora · $personaje';
    return t.length <= maximoTitulo ? t : '${t.substring(0, maximoTitulo - 1)}…';
  }

  static String tituloDe(DecisionEscenario d) => tituloApelacion(d.hora, d.personaje);

  /// La decisión [id] como tarjeta (para abrir su apelación en el juicio,
  /// 22); `null` si no es de este escenario. En T-14 la dará el servidor.
  static Tarjeta? comoTarjeta(String id) {
    final m = RegExp(r'^ran-(\d{2})$').firstMatch(id);
    if (m == null) return null;
    final i = int.parse(m.group(1)!) - 1;
    if (i < 0 || i >= decisiones.length) return null;
    final d = decisiones[i];
    return Tarjeta(
      id: id,
      tipo: TipoTarjeta.normal,
      etiquetaCaso: etiqueta,
      personaje: d.personaje,
      rol: d.rol,
      texto: d.texto,
      iniciales: d.iniciales,
      respuestaCorrecta: d.respuestaCorrecta,
      explicacion: d.fundamentos[d.fundamentoCorrecto],
      titulo: tituloDe(d),
      tema: tema,
    );
  }

  static const List<DecisionEscenario> decisiones = [
    DecisionEscenario(
      hora: 0,
      personaje: 'Analista de seguridad',
      rol: 'Equipo de TI',
      texto:
          'Aparecieron archivos cifrados y una nota de rescate en el servidor de clientes. '
          '¿Desconecto ese servidor de la red ahora mismo?',
      respuestaCorrecta: Veredicto.legal,
      replica: '¿Desconectar sin pedirle permiso a nadie? Vas a tumbar el servicio.',
      fundamentos: [
        'Aislar el equipo afectado es la primera medida de contención para que el ataque no se propague.',
        'Primero hay que averiguar quién fue el atacante y después decidir.',
      ],
      fundamentoCorrecto: 0,
    ),
    DecisionEscenario(
      hora: 1,
      personaje: 'Director de operaciones',
      rol: 'Operaciones',
      texto:
          'Los atacantes piden un pago en criptomonedas a cambio de no publicar la base. '
          '¿Les pago ya para cerrar el asunto?',
      respuestaCorrecta: Veredicto.escalar,
      replica: 'Pagar es lo más rápido. ¿Para qué complicarlo?',
      fundamentos: [
        'Pagar garantiza que borren los datos y que nadie se entere.',
        'Pagar no garantiza nada ni libera de responder por la brecha; lo decide la dirección con asesoría jurídica.',
      ],
      fundamentoCorrecto: 1,
    ),
    DecisionEscenario(
      hora: 3,
      personaje: 'Administradora de sistemas',
      rol: 'Infraestructura',
      texto:
          'Para volver a operar rápido, ¿formateo los servidores comprometidos antes de '
          'sacar una copia de la evidencia?',
      respuestaCorrecta: Veredicto.condicional,
      replica: 'Formatear de una vez es lo más limpio, ¿o no?',
      fundamentos: [
        'Se puede restaurar, pero solo después de preservar la evidencia y documentar el incidente.',
        'La evidencia no importa si ya sabemos que fue ransomware.',
      ],
      fundamentoCorrecto: 0,
    ),
    DecisionEscenario(
      hora: 6,
      personaje: 'Líder de soporte',
      rol: 'Atención a clientes',
      texto:
          'Varios usuarios preguntan en redes sociales si se filtraron sus datos. '
          '¿Les respondo que todo está bien mientras investigamos?',
      respuestaCorrecta: Veredicto.ilegal,
      replica: 'Decir que todo está bien calma a la gente. ¿Qué tiene de malo?',
      fundamentos: [
        'Mientras no esté confirmado se puede negar.',
        'Dar información falsa a los titulares sobre una vulneración les impide proteger sus datos.',
      ],
      fundamentoCorrecto: 1,
    ),
    DecisionEscenario(
      hora: 9,
      personaje: 'Responsable de datos',
      rol: 'Privacidad',
      texto:
          'Confirmamos que se filtraron nombres, correos y teléfonos. ¿Abro una bitácora con '
          'lo que pasó, los datos afectados y las medidas que tomamos?',
      respuestaCorrecta: Veredicto.legal,
      replica: '¿Documentarlo todo? Eso solo deja pruebas en tu contra.',
      fundamentos: [
        'Documentar la vulneración y las medidas es parte del deber de seguridad y sirve ante la autoridad.',
        'La bitácora solo hace falta si la autoridad la pide.',
      ],
      fundamentoCorrecto: 0,
    ),
    DecisionEscenario(
      hora: 12,
      personaje: 'Gerente de producto',
      rol: 'Producto',
      texto:
          'El proveedor de la nube que guarda los respaldos también pudo verse afectado. '
          '¿Le pido un reporte de lo que ocurrió de su lado?',
      respuestaCorrecta: Veredicto.legal,
      replica: 'Es su infraestructura, no tu problema. ¿Para qué preguntar?',
      fundamentos: [
        'El proveedor responde por su cuenta; no hace falta coordinarse.',
        'Quien trata datos por encargo también debe protegerlos; el responsable debe coordinarse con él y saber qué pasó.',
      ],
      fundamentoCorrecto: 1,
    ),
    DecisionEscenario(
      hora: 18,
      personaje: 'Directora de marketing',
      rol: 'Marketing',
      texto:
          'Propongo regalar un mes gratis a los afectados a cambio de que firmen que no van '
          'a reclamar nada. ¿Lo lanzo?',
      respuestaCorrecta: Veredicto.ilegal,
      replica: 'Es un regalo. Si firman, es porque quieren.',
      fundamentos: [
        'Condicionar un beneficio a que renuncien a sus derechos sobre sus datos no es válido: los conservan.',
        'Es válido si el regalo vale más que el daño.',
      ],
      fundamentoCorrecto: 0,
    ),
    // Figma 28 y 28b.
    DecisionEscenario(
      hora: 24,
      personaje: 'CTO',
      rol: 'Fundador técnico',
      iniciales: 'CT',
      texto:
          'Ya contuvimos el ataque. Propongo borrar los logs del incidente y no avisar a los '
          'usuarios para cuidar la reputación. ¿Lo hacemos?',
      respuestaCorrecta: Veredicto.ilegal,
      replica: '¿Seguro que no debes avisar? Si borras el log nadie se va a enterar.',
      fundamentos: [
        'Ocultar evidencia de una brecha agrava la infracción; hay que notificar a los titulares y a la autoridad.',
        'Solo hay que avisar si los datos filtrados eran contraseñas.',
      ],
      fundamentoCorrecto: 0,
    ),
    // Figma 28c.
    DecisionEscenario(
      hora: 48,
      personaje: 'Abogada externa',
      rol: 'Despacho jurídico',
      iniciales: 'AE',
      texto:
          'Ya pasaron 48 horas. ¿Notificamos ahora a la autoridad de protección de datos y a '
          'los usuarios afectados?',
      respuestaCorrecta: Veredicto.legal,
      replica: '¿Ahora? Mejor espera a tenerlo todo resuelto para no quedar mal.',
      fundamentos: [
        'Si ya pasó tiempo, conviene esperar a cerrar la investigación para avisar.',
        'Hay que avisar sin demora a los titulares y a la autoridad para que puedan protegerse; esperar agrava la falta.',
      ],
      fundamentoCorrecto: 1,
    ),
    DecisionEscenario(
      hora: 72,
      personaje: 'Directora general',
      rol: 'Dirección',
      texto:
          'La autoridad nos pide un informe del incidente. Yo puedo redactarlo hoy mismo sin '
          'consultar a nadie. ¿Lo envío?',
      respuestaCorrecta: Veredicto.escalar,
      replica: 'Tú conoces el incidente mejor que nadie. ¿Para qué meter a jurídico?',
      fundamentos: [
        'La respuesta a la autoridad tiene consecuencias legales: jurídico debe revisarla para que sea completa y veraz.',
        'Basta con que lo firme quien atendió el incidente.',
      ],
      fundamentoCorrecto: 0,
    ),
  ];
}
