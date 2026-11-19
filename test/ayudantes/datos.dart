import 'package:abogator/core/tema/colores_marca.dart';
import 'package:abogator/datos/modelos/modulo.dart';

/// Sprint de prueba de 8 tarjetas (5 normales, 2 con evidencia y 1 dilema).
Sprint sprintDePrueba(
  String id,
  EstadoSprint estado, {
  String titulo = 'S',
  int estrellas = 0,
  bool esExamenFinal = false,
}) => Sprint(
  id: id,
  titulo: titulo,
  objetivo: 'Objetivo de $titulo',
  tarjetasNormales: 5,
  tarjetasConEvidencia: 2,
  dilemas: 1,
  monedasMaximas: 50,
  minutosEstimados: 3,
  estado: estado,
  estrellas: estrellas,
  esExamenFinal: esExamenFinal,
);

/// Módulo [numero] con un sprint por estado y, si [conFinal], el Examen final
/// bloqueado al final.
Modulo moduloDePrueba(
  int numero,
  List<EstadoSprint> estados, {
  String? id,
  bool conFinal = false,
  EstadoSprint estadoFinal = EstadoSprint.bloqueado,
}) {
  final clave = id ?? 'mod-$numero';
  return Modulo(
    id: clave,
    numero: numero,
    nombre: 'Módulo $numero',
    color: ColoresModulo.enOrden[numero - 1],
    sprints: [
      for (final (i, e) in estados.indexed)
        sprintDePrueba('$clave-s${i + 1}', e, titulo: 'Sprint de prueba ${i + 1}'),
      if (conFinal)
        sprintDePrueba(
          '$clave-final',
          estadoFinal,
          titulo: 'Examen de prueba',
          esExamenFinal: true,
        ),
    ],
  );
}
