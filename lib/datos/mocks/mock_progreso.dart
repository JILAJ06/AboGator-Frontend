import '../../core/tema/colores_marca.dart';
import '../modelos/estado_startup.dart';
import '../modelos/modulo.dart';
import '../repositorios/repositorio_progreso.dart';
import 'espera_simulada.dart';

/// Progreso simulado con los 5 módulos del diseño.
class MockProgreso implements RepositorioProgreso {
  MockProgreso({this.espera = esperaSimuladaPorDefecto});

  final Duration espera;

  static const List<Modulo> modulos = [
    Modulo(
      id: 'mod-1',
      numero: 1,
      nombre: 'Protección de Datos',
      color: ColoresModulo.proteccionDeDatos,
      sprints: [
        Sprint(
          id: 'spr-1-1',
          titulo: 'Consentimiento y aviso de privacidad',
          numeroTarjetas: 8,
          estado: EstadoSprint.completado,
        ),
        Sprint(
          id: 'spr-1-2',
          titulo: 'Derechos ARCO',
          numeroTarjetas: 8,
          estado: EstadoSprint.enCurso,
        ),
        Sprint(
          id: 'spr-1-final',
          titulo: 'Examen final: crisis de 72 horas',
          numeroTarjetas: 10,
          estado: EstadoSprint.bloqueado,
          esExamenFinal: true,
        ),
      ],
    ),
    Modulo(
      id: 'mod-2',
      numero: 2,
      nombre: 'Licencias y Propiedad Intelectual',
      color: ColoresModulo.licenciasYPropiedadIntelectual,
      sprints: [
        Sprint(
          id: 'spr-2-1',
          titulo: 'Software libre y licencias copyleft',
          numeroTarjetas: 8,
          estado: EstadoSprint.disponible,
        ),
      ],
    ),
    Modulo(
      id: 'mod-3',
      numero: 3,
      nombre: 'Delitos Informáticos',
      color: ColoresModulo.delitosInformaticos,
      sprints: [],
    ),
    Modulo(
      id: 'mod-4',
      numero: 4,
      nombre: 'Contratos Digitales',
      color: ColoresModulo.contratosDigitales,
      sprints: [],
    ),
    Modulo(
      id: 'mod-5',
      numero: 5,
      nombre: 'Auditoría y Cumplimiento',
      color: ColoresModulo.auditoriaYCumplimiento,
      sprints: [],
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
