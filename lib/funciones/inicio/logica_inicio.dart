import 'package:material_ui/material_ui.dart';

import '../../componentes/tarjeta_modulo.dart';
import '../../core/tema/iconos_app.dart';
import '../../core/textos/textos.dart';
import '../../datos/modelos/modulo.dart';
import '../../datos/modelos/usuario.dart';

/// Reglas puras del Inicio (sin widgets ni repositorios).
abstract final class LogicaInicio {
  /// Primera letra del nombre y del apellido (una sola si hay una palabra).
  static String iniciales(String nombre) {
    final palabras = nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (palabras.isEmpty) return '';
    final primera = palabras.first.characters.first.toUpperCase();
    if (palabras.length == 1) return primera;
    return primera + palabras[1].characters.first.toUpperCase();
  }

  static String primerNombre(String nombre) {
    final palabras = nombre.trim().split(RegExp(r'\s+'));
    return palabras.isEmpty ? '' : palabras.first;
  }

  /// Perfil legible y corto (Figma muestra "Dev").
  static String perfilCorto(PerfilUsuario perfil) => switch (perfil) {
    PerfilUsuario.estudiante => Textos.perfilCortoEstudiante,
    PerfilUsuario.desarrollador => Textos.perfilCortoDesarrollador,
    PerfilUsuario.legal => Textos.perfilCortoLegal,
  };

  /// Bloqueado si todos sus sprints están bloqueados (o no tiene sprints);
  /// completado si todos están completados; en curso si alguno está en curso
  /// o hay algunos completados; si no, disponible.
  static EstadoModulo estadoDe(Modulo modulo) {
    final estados = modulo.sprints.map((s) => s.estado).toList();
    if (estados.isEmpty || estados.every((e) => e == EstadoSprint.bloqueado)) {
      return EstadoModulo.bloqueado;
    }
    if (estados.every((e) => e == EstadoSprint.completado)) return EstadoModulo.completado;
    if (estados.any((e) => e == EstadoSprint.enCurso || e == EstadoSprint.completado)) {
      return EstadoModulo.enCurso;
    }
    return EstadoModulo.disponible;
  }

  /// Solo cuenta los sprints completados (decisión de T-04).
  static int completados(Modulo modulo) =>
      modulo.sprints.where((s) => s.estado == EstadoSprint.completado).length;

  /// Módulo y sprint actuales: el primer módulo con un sprint en curso; si no
  /// hay, el primer sprint disponible. `null` si no hay ninguno.
  static ({Modulo modulo, Sprint sprint, int numeroSprint})? actual(List<Modulo> modulos) {
    for (final buscado in [EstadoSprint.enCurso, EstadoSprint.disponible]) {
      for (final modulo in modulos) {
        final i = modulo.sprints.indexWhere((s) => s.estado == buscado);
        if (i >= 0) return (modulo: modulo, sprint: modulo.sprints[i], numeroSprint: i + 1);
      }
    }
    return null;
  }

  static String _porNumero(List<String> lista, int numero, String porDefecto) =>
      numero >= 1 && numero <= lista.length ? lista[numero - 1] : porDefecto;

  /// Nombre corto del módulo para la etiqueta (como en Figma).
  static String nombreCorto(Modulo modulo) =>
      _porNumero(Textos.modulosCortos, modulo.numero, modulo.nombre);

  /// Tramo de la Startup que representa el módulo (título de la tarjeta).
  static String tramo(Modulo modulo) =>
      _porNumero(Textos.tramosStartup, modulo.numero, modulo.nombre);

  static IconData iconoDe(Modulo modulo) => switch (modulo.numero) {
    1 => IconosApp.shield,
    2 => IconosApp.code,
    3 => IconosApp.gavel,
    4 => IconosApp.doc,
    _ => IconosApp.shieldCheck,
  };
}

/// Reto diario: por ahora es fijo (solo presentación).
abstract final class RetoDiario {
  static const int actual = 1;
  static const int total = 3;
  static const int monedas = 15;
}
