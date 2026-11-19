import '../../core/tema/colores_marca.dart';
import '../modelos/estado_startup.dart';
import '../modelos/modulo.dart';
import '../repositorios/repositorio_progreso.dart';
import 'espera_simulada.dart';

/// Progreso simulado con los 5 módulos del diseño, de 5 sprints cada uno
/// (el último es el Examen final). Como en Figma: el módulo 1 lleva 2 sprints
/// completados y el 3.º en curso; los demás módulos están bloqueados.
class MockProgreso implements RepositorioProgreso {
  MockProgreso({this.espera = esperaSimuladaPorDefecto});

  final Duration espera;

  static Sprint _final(String moduloId) => Sprint(
    id: '$moduloId-final',
    titulo: 'Examen final: crisis de 72 horas',
    numeroTarjetas: 10,
    estado: EstadoSprint.bloqueado,
    esExamenFinal: true,
  );

  static List<Sprint> _bloqueados(String prefijo, List<String> titulos) => [
    for (final (i, titulo) in titulos.indexed)
      Sprint(
        id: '$prefijo-${i + 1}',
        titulo: titulo,
        numeroTarjetas: 8,
        estado: EstadoSprint.bloqueado,
      ),
    _final(prefijo),
  ];

  static final List<Modulo> modulos = [
    Modulo(
      id: 'mod-1',
      numero: 1,
      nombre: 'Protección de Datos',
      color: ColoresModulo.proteccionDeDatos,
      sprints: [
        const Sprint(
          id: 'spr-1-1',
          titulo: 'Consentimiento y aviso de privacidad',
          numeroTarjetas: 8,
          estado: EstadoSprint.completado,
        ),
        const Sprint(
          id: 'spr-1-2',
          titulo: 'Derechos ARCO',
          numeroTarjetas: 8,
          estado: EstadoSprint.completado,
        ),
        const Sprint(
          id: 'spr-1-3',
          titulo: 'Transferencias de datos a terceros',
          numeroTarjetas: 8,
          estado: EstadoSprint.enCurso,
        ),
        const Sprint(
          id: 'spr-1-4',
          titulo: 'Brechas de seguridad y notificación',
          numeroTarjetas: 8,
          estado: EstadoSprint.bloqueado,
        ),
        _final('spr-1'),
      ],
    ),
    Modulo(
      id: 'mod-2',
      numero: 2,
      nombre: 'Licencias y Propiedad Intelectual',
      color: ColoresModulo.licenciasYPropiedadIntelectual,
      sprints: _bloqueados('spr-2', [
        'Software libre y licencias copyleft',
        'Licencias permisivas',
        'Derechos de autor del código',
        'Marcas y patentes de software',
      ]),
    ),
    Modulo(
      id: 'mod-3',
      numero: 3,
      nombre: 'Delitos Informáticos',
      color: ColoresModulo.delitosInformaticos,
      sprints: _bloqueados('spr-3', [
        'Acceso ilícito a sistemas',
        'Fraude informático',
        'Suplantación de identidad',
        'Evidencia digital',
      ]),
    ),
    Modulo(
      id: 'mod-4',
      numero: 4,
      nombre: 'Contratos Digitales',
      color: ColoresModulo.contratosDigitales,
      sprints: _bloqueados('spr-4', [
        'Términos y condiciones',
        'Contratos de desarrollo',
        'Niveles de servicio (SLA)',
        'Firma electrónica',
      ]),
    ),
    Modulo(
      id: 'mod-5',
      numero: 5,
      nombre: 'Auditoría y Cumplimiento',
      color: ColoresModulo.auditoriaYCumplimiento,
      sprints: _bloqueados('spr-5', [
        'Controles internos',
        'Normas ISO 27001',
        'Gestión de riesgos',
        'Auditoría externa',
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
