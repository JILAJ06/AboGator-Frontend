import '../../core/tema/colores_marca.dart';
import '../modelos/estado_startup.dart';
import '../modelos/modulo.dart';
import '../repositorios/repositorio_progreso.dart';
import 'espera_simulada.dart';

/// Progreso simulado con los 5 módulos del diseño: cada uno tiene 5 sprints
/// más el Examen final (6 nodos en el mapa). Como en Figma: el módulo 1 lleva
/// 2 sprints completados (3 estrellas) y el 3.º en curso; los demás módulos
/// están bloqueados.
///
/// Los sprints completados y el estado de la Startup se guardan en memoria;
/// cada instancia empieza con [modulos] y [estadoInicial] (las pruebas crean
/// una nueva para reiniciar).
class MockProgreso implements RepositorioProgreso {
  MockProgreso({this.espera = esperaSimuladaPorDefecto, List<Modulo>? modulos})
    : _modulos = modulos ?? MockProgreso.modulos;

  final Duration espera;
  List<Modulo> _modulos;
  EstadoStartup _estado = estadoInicial;

  /// Estado de la Startup al empezar (como en Figma 09 y 10).
  static const EstadoStartup estadoInicial = EstadoStartup(
    presupuesto: 70,
    reputacion: 60,
    velocidad: 50,
    riesgoLegal: 25,
  );

  /// Sprint de 8 tarjetas (5 normales, 2 con evidencia y 1 dilema).
  static Sprint _sprint(
    String id,
    String titulo,
    String objetivo, {
    EstadoSprint estado = EstadoSprint.bloqueado,
    int estrellas = 0,
    String? mensajeCompletado,
    String? mensajeQuiebra,
  }) => Sprint(
    id: id,
    titulo: titulo,
    objetivo: objetivo,
    tarjetasNormales: 5,
    tarjetasConEvidencia: 2,
    dilemas: 1,
    monedasMaximas: 50,
    minutosEstimados: 3,
    estado: estado,
    estrellas: estrellas,
    mensajeCompletado: mensajeCompletado,
    mensajeQuiebra: mensajeQuiebra,
  );

  static Sprint _final(String prefijo, String titulo, String objetivo) => Sprint(
    id: '$prefijo-final',
    titulo: titulo,
    objetivo: objetivo,
    tarjetasNormales: 10,
    tarjetasConEvidencia: 0,
    dilemas: 0,
    monedasMaximas: 100,
    minutosEstimados: 3,
    estado: EstadoSprint.bloqueado,
    esExamenFinal: true,
  );

  /// Cinco sprints bloqueados más el Examen final.
  static List<Sprint> _bloqueados(String prefijo, List<(String, String)> sprints) => [
    for (final (i, (titulo, objetivo)) in sprints.indexed)
      _sprint('$prefijo-${i + 1}', titulo, objetivo),
    _final(
      prefijo,
      'Auditoría de inversores',
      'los inversores revisan tu Startup en una crisis de 72 horas.',
    ),
  ];

  static final List<Modulo> modulos = [
    Modulo(
      id: 'mod-1',
      numero: 1,
      nombre: 'Protección de Datos',
      color: ColoresModulo.proteccionDeDatos,
      sprints: [
        _sprint(
          'spr-1-1',
          'Datos personales',
          'identifica qué datos de tus usuarios son personales y cuáles son sensibles.',
          estado: EstadoSprint.completado,
          estrellas: 3,
          mensajeCompletado: 'Ya distingues los datos personales de los sensibles en tu app.',
          mensajeQuiebra:
              'Guardaste datos de salud sin protegerlos como datos sensibles. Una queja de '
              'tus usuarios terminó en multa y la Startup no la pudo pagar.',
        ),
        _sprint(
          'spr-1-2',
          'Consentimiento',
          'decide cuándo necesitas el consentimiento de tus usuarios y cómo pedirlo.',
          estado: EstadoSprint.completado,
          estrellas: 3,
          mensajeCompletado: 'Tu registro pide el consentimiento correcto en cada caso.',
          mensajeQuiebra:
              'Usaste los datos de tus usuarios sin su consentimiento. Las quejas y la '
              'multa dejaron a la Startup sin presupuesto.',
        ),
        const Sprint(
          id: 'spr-1-3',
          titulo: 'Aviso de privacidad',
          tituloIntro: 'Aviso de privacidad en el MVP',
          objetivo:
              'el MVP sale a producción el viernes. Revisa que el registro de usuarios '
              'cumpla con la LFPDPPP antes del lanzamiento.',
          tarjetasNormales: 6,
          tarjetasConEvidencia: 3,
          dilemas: 1,
          monedasMaximas: 60,
          minutosEstimados: 4,
          estado: EstadoSprint.enCurso,
          mensajeCompletado:
              'Tu MVP ya cumple con el aviso de privacidad y la Startup sigue en pie.',
          mensajeQuiebra:
              'Una auditoría encontró la librería GPL-3.0 en tu código cerrado. La demanda '
              'se llevó el presupuesto y los inversionistas se fueron.',
        ),
        _sprint(
          'spr-1-4',
          'Derechos ARCO',
          'responde a tiempo las solicitudes de acceso, rectificación, cancelación y oposición.',
          mensajeCompletado: 'Tus usuarios ya pueden ejercer sus derechos ARCO sin trabas.',
          mensajeQuiebra:
              'Ignoraste las solicitudes ARCO de tus usuarios. La autoridad abrió un '
              'procedimiento y la multa hundió a la Startup.',
        ),
        _sprint(
          'spr-1-5',
          'Brechas de seguridad',
          'hubo una fuga de datos: decide a quién avisar y qué hacer primero.',
          mensajeCompletado: 'Contuviste la fuga y avisaste a tiempo a los afectados.',
          mensajeQuiebra:
              'Ocultaste la fuga de datos. Cuando salió a la luz, los usuarios se fueron '
              'y los inversionistas también.',
        ),
        _final(
          'spr-1',
          'Auditoría de inversores',
          'los inversores auditan cómo tratas los datos de tus usuarios en una crisis de 72 horas.',
        ),
      ],
    ),
    Modulo(
      id: 'mod-2',
      numero: 2,
      nombre: 'Licencias y Propiedad Intelectual',
      color: ColoresModulo.licenciasYPropiedadIntelectual,
      sprints: _bloqueados('spr-2', [
        ('Software libre y copyleft', 'usa librerías GPL sin poner en riesgo tu código cerrado.'),
        ('Licencias permisivas', 'cumple las condiciones de MIT, BSD y Apache 2.0.'),
        ('Derechos de autor del código', 'define quién es dueño del código que escribe tu equipo.'),
        ('Marcas y patentes de software', 'protege el nombre y las ideas de tu Startup.'),
        ('Contenido generado con IA', 'decide si puedes usar código e imágenes creados con IA.'),
      ]),
    ),
    Modulo(
      id: 'mod-3',
      numero: 3,
      nombre: 'Delitos Informáticos',
      color: ColoresModulo.delitosInformaticos,
      sprints: _bloqueados('spr-3', [
        ('Acceso ilícito a sistemas', 'distingue una prueba autorizada de un acceso ilícito.'),
        ('Fraude informático', 'detecta operaciones que podrían ser fraude.'),
        ('Suplantación de identidad', 'protege a tus usuarios del robo de identidad.'),
        ('Evidencia digital', 'conserva la evidencia de un incidente sin alterarla.'),
        ('Denuncia y cooperación', 'decide cuándo denunciar y cómo cooperar con la autoridad.'),
      ]),
    ),
    Modulo(
      id: 'mod-4',
      numero: 4,
      nombre: 'Contratos Digitales',
      color: ColoresModulo.contratosDigitales,
      sprints: _bloqueados('spr-4', [
        ('Términos y condiciones', 'redacta términos claros y válidos para tu app.'),
        ('Contratos de desarrollo', 'acuerda entregables y propiedad con tus proveedores.'),
        ('Niveles de servicio (SLA)', 'define qué pasa si tu servicio se cae.'),
        ('Firma electrónica', 'usa la firma electrónica con validez legal.'),
        ('Comercio electrónico', 'cumple las reglas de venta en línea y devoluciones.'),
      ]),
    ),
    Modulo(
      id: 'mod-5',
      numero: 5,
      nombre: 'Auditoría y Cumplimiento',
      color: ColoresModulo.auditoriaYCumplimiento,
      sprints: _bloqueados('spr-5', [
        ('Controles internos', 'diseña controles que eviten errores y abusos.'),
        ('Normas ISO 27001', 'prepara tu Startup para una certificación de seguridad.'),
        ('Gestión de riesgos', 'prioriza los riesgos legales y técnicos.'),
        ('Auditoría externa', 'atiende a un auditor externo sin sorpresas.'),
        ('Cumplimiento continuo', 'mantén el cumplimiento mientras tu Startup crece.'),
      ]),
    ),
  ];

  @override
  Future<List<Modulo>> obtenerModulos() async {
    await esperar(espera);
    return _modulos;
  }

  @override
  Future<EstadoStartup> obtenerEstadoStartup() async {
    await esperar(espera);
    return _estado;
  }

  @override
  Future<void> registrarSprintCompletado({
    required String sprintId,
    required int estrellas,
    required EstadoStartup estadoFinal,
  }) async {
    await esperar(espera);
    _modulos = [
      for (final modulo in _modulos)
        modulo.sprints.any((s) => s.id == sprintId)
            ? modulo.copiar(sprints: _completar(modulo.sprints, sprintId, estrellas))
            : modulo,
    ];
    _estado = estadoFinal;
  }

  @override
  Future<void> registrarExamenAprobado({required String moduloId}) async {
    await esperar(espera);
    final i = _modulos.indexWhere((m) => m.id == moduloId);
    if (i < 0) return;
    _modulos = [
      for (final (j, modulo) in _modulos.indexed)
        if (j == i)
          modulo.copiar(
            sprints: [
              for (final s in modulo.sprints)
                s.esExamenFinal
                    ? s.copiar(estado: EstadoSprint.completado, estrellas: Sprint.maximoEstrellas)
                    : s,
            ],
          )
        else if (j == i + 1)
          modulo.copiar(
            sprints: [
              for (final (k, s) in modulo.sprints.indexed)
                k == 0 && s.estado == EstadoSprint.bloqueado
                    ? s.copiar(estado: EstadoSprint.enCurso)
                    : s,
            ],
          )
        else
          modulo,
    ];
  }

  /// Marca [sprintId] completado (con el máximo de estrellas) y pone en curso
  /// el siguiente sprint si estaba bloqueado. El Examen final no cambia: se
  /// habilita solo cuando todos los sprints están completados.
  static List<Sprint> _completar(List<Sprint> sprints, String sprintId, int estrellas) {
    final indice = sprints.indexWhere((s) => s.id == sprintId);
    return [
      for (final (i, s) in sprints.indexed)
        if (i == indice)
          s.copiar(
            estado: EstadoSprint.completado,
            estrellas: estrellas.clamp(s.estrellas, Sprint.maximoEstrellas),
          )
        else if (i == indice + 1 && !s.esExamenFinal && s.estado == EstadoSprint.bloqueado)
          s.copiar(estado: EstadoSprint.enCurso)
        else
          s,
    ];
  }
}
