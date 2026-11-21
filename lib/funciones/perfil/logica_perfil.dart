import '../../core/textos/textos.dart';
import '../../datos/modelos/modulo.dart';
import '../../datos/modelos/usuario.dart';
import '../inicio/logica_inicio.dart';

/// Reglas puras del Perfil (pantalla 25).
abstract final class LogicaPerfil {
  /// Primera letra de las dos primeras palabras, en mayúsculas ("AL").
  static String iniciales(String nombre) => LogicaInicio.iniciales(nombre);

  /// Número con separador de miles: 1250 → "1,250".
  static String miles(int n) {
    final digitos = n.abs().toString();
    final partes = <String>[];
    for (var fin = digitos.length; fin > 0; fin -= 3) {
      partes.insert(0, digitos.substring(fin - 3 < 0 ? 0 : fin - 3, fin));
    }
    return '${n < 0 ? '-' : ''}${partes.join(',')}';
  }

  /// Rol neutro del registro ("Desarrollador", "Estudiante", "Legal").
  static String rol(PerfilUsuario perfil) => switch (perfil) {
    PerfilUsuario.estudiante => Textos.perfilEstudiante,
    PerfilUsuario.desarrollador => Textos.perfilDesarrollador,
    PerfilUsuario.legal => Textos.perfilLegal,
  };

  /// "Desarrollador · Nivel 4 · 1,250 XP".
  static String detalle(Usuario u) => Textos.nivelYXp(rol(u.perfil), u.nivel, miles(u.xp));

  /// Avance del módulo en porcentaje entero: sprints completados entre los
  /// sprints normales (sin el Examen final), como en el Inicio.
  static int porcentajeModulo(Modulo modulo) {
    final total = LogicaInicio.totalSprints(modulo);
    return total == 0 ? 0 : (LogicaInicio.completados(modulo) * 100 / total).round();
  }
}
