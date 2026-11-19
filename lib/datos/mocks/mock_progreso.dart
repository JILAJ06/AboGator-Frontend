import '../../core/tema/colores_marca.dart';
import '../modelos/estado_startup.dart';
import '../modelos/modulo.dart';
import '../repositorios/repositorio_progreso.dart';
import 'espera_simulada.dart';

/// Progreso simulado con los 5 módulos del diseño: cada uno tiene 5 sprints
/// más el Examen final (6 nodos en el mapa). Como en Figma: el módulo 1 lleva
/// 2 sprints completados (3 estrellas) y el 3.º en curso; los demás módulos
/// están bloqueados.
class MockProgreso implements RepositorioProgreso {
  MockProgreso({this.espera = esperaSimuladaPorDefecto});

  final Duration espera;

  /// Sprint de 8 tarjetas (5 normales, 2 con evidencia y 1 dilema).
  static Sprint _sprint(
    String id,
    String titulo,
    String objetivo, {
    EstadoSprint estado = EstadoSprint.bloqueado,
    int estrellas = 0,
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
      'Los inversores revisan tu Startup en una crisis de 72 horas.',
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
          'Identifica qué datos de tus usuarios son personales y cuáles son sensibles.',
          estado: EstadoSprint.completado,
          estrellas: 3,
        ),
        _sprint(
          'spr-1-2',
          'Consentimiento',
          'Decide cuándo necesitas el consentimiento de tus usuarios y cómo pedirlo.',
          estado: EstadoSprint.completado,
          estrellas: 3,
        ),
        const Sprint(
          id: 'spr-1-3',
          titulo: 'Aviso de privacidad',
          objetivo:
              'El MVP sale a producción el viernes. Revisa que el registro de usuarios '
              'cumpla con la LFPDPPP antes del lanzamiento.',
          tarjetasNormales: 6,
          tarjetasConEvidencia: 3,
          dilemas: 1,
          monedasMaximas: 60,
          minutosEstimados: 4,
          estado: EstadoSprint.enCurso,
        ),
        _sprint(
          'spr-1-4',
          'Derechos ARCO',
          'Responde a tiempo las solicitudes de acceso, rectificación, cancelación y oposición.',
        ),
        _sprint(
          'spr-1-5',
          'Brechas de seguridad',
          'Hubo una fuga de datos: decide a quién avisar y qué hacer primero.',
        ),
        _final(
          'spr-1',
          'Auditoría de inversores',
          'Los inversores auditan cómo tratas los datos de tus usuarios en una crisis de 72 horas.',
        ),
      ],
    ),
    Modulo(
      id: 'mod-2',
      numero: 2,
      nombre: 'Licencias y Propiedad Intelectual',
      color: ColoresModulo.licenciasYPropiedadIntelectual,
      sprints: _bloqueados('spr-2', [
        ('Software libre y copyleft', 'Usa librerías GPL sin poner en riesgo tu código cerrado.'),
        ('Licencias permisivas', 'Cumple las condiciones de MIT, BSD y Apache 2.0.'),
        ('Derechos de autor del código', 'Define quién es dueño del código que escribe tu equipo.'),
        ('Marcas y patentes de software', 'Protege el nombre y las ideas de tu Startup.'),
        ('Contenido generado con IA', 'Decide si puedes usar código e imágenes creados con IA.'),
      ]),
    ),
    Modulo(
      id: 'mod-3',
      numero: 3,
      nombre: 'Delitos Informáticos',
      color: ColoresModulo.delitosInformaticos,
      sprints: _bloqueados('spr-3', [
        ('Acceso ilícito a sistemas', 'Distingue una prueba autorizada de un acceso ilícito.'),
        ('Fraude informático', 'Detecta operaciones que podrían ser fraude.'),
        ('Suplantación de identidad', 'Protege a tus usuarios del robo de identidad.'),
        ('Evidencia digital', 'Conserva la evidencia de un incidente sin alterarla.'),
        ('Denuncia y cooperación', 'Decide cuándo denunciar y cómo cooperar con la autoridad.'),
      ]),
    ),
    Modulo(
      id: 'mod-4',
      numero: 4,
      nombre: 'Contratos Digitales',
      color: ColoresModulo.contratosDigitales,
      sprints: _bloqueados('spr-4', [
        ('Términos y condiciones', 'Redacta términos claros y válidos para tu app.'),
        ('Contratos de desarrollo', 'Acuerda entregables y propiedad con tus proveedores.'),
        ('Niveles de servicio (SLA)', 'Define qué pasa si tu servicio se cae.'),
        ('Firma electrónica', 'Usa la firma electrónica con validez legal.'),
        ('Comercio electrónico', 'Cumple las reglas de venta en línea y devoluciones.'),
      ]),
    ),
    Modulo(
      id: 'mod-5',
      numero: 5,
      nombre: 'Auditoría y Cumplimiento',
      color: ColoresModulo.auditoriaYCumplimiento,
      sprints: _bloqueados('spr-5', [
        ('Controles internos', 'Diseña controles que eviten errores y abusos.'),
        ('Normas ISO 27001', 'Prepara tu Startup para una certificación de seguridad.'),
        ('Gestión de riesgos', 'Prioriza los riesgos legales y técnicos.'),
        ('Auditoría externa', 'Atiende a un auditor externo sin sorpresas.'),
        ('Cumplimiento continuo', 'Mantén el cumplimiento mientras tu Startup crece.'),
      ]),
    ),
  ];

  @override
  Future<List<Modulo>> obtenerModulos() async {
    await esperar(espera);
    return modulos;
  }

  @override
  Future<EstadoStartup> obtenerEstadoStartup() async {
    await esperar(espera);
    return const EstadoStartup(presupuesto: 70, reputacion: 55, velocidad: 60, riesgoLegal: 25);
  }
}
