import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import '../core/recursos/imagenes_app.dart';
import '../core/tema/efectos.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'logo_app.dart';

/// Maqueta de la notificación de apelación (Figma 21b = 41:5499). Es una
/// notificación del sistema: este componente solo sirve de referencia en la
/// galería (no se muestra dentro de la app). Sus colores imitan al sistema y
/// están en `EfectosApp`, igual en claro y en oscuro.
///
/// Ancho 358, fondo blanco al 88 % con desenfoque 10, radio 22, sombra (0, 8)
/// de 12 al 18 %, relleno 14×12 y separación 12: ícono de la app (38, verde
/// de marca, radio 8.4, isotipo de 31.7) y el texto ("ABOGATOR" / [hora],
/// título y cuerpo, separación 2).
class NotificacionApelacion extends StatelessWidget {
  const NotificacionApelacion({
    required this.tituloCaso,
    required this.dias,
    this.hora = Textos.notificacionAhora,
    super.key,
  });

  static const double ancho = NotificacionSistema.ancho;
  static const double radio = NotificacionSistema.radio;

  /// Título del caso fallado (va entre comillas en el cuerpo).
  final String tituloCaso;

  /// Días desde el fallo (3 o 7).
  final int dias;

  /// "ahora", "hace 2 h"…
  final String hora;

  @override
  Widget build(BuildContext context) => NotificacionSistema(
    claveContenedor: const ValueKey('notificacion-apelacion'),
    titulo: Textos.notificacionApelacionTitulo,
    cuerpo: Textos.notificacionApelacionCuerpo(tituloCaso, dias),
    hora: hora,
  );
}

/// Maqueta de una notificación del sistema de AboGator (21b y 34b, T-13b):
/// la misma de [NotificacionApelacion] con otro [titulo] y [cuerpo].
class NotificacionSistema extends StatelessWidget {
  const NotificacionSistema({
    required this.titulo,
    required this.cuerpo,
    this.hora = Textos.notificacionAhora,
    this.claveContenedor = const ValueKey('notificacion-sistema'),
    super.key,
  });

  static const double ancho = 358;
  static const double radio = 22;

  final String titulo;
  final String cuerpo;
  final String hora;
  final Key claveContenedor;

  @override
  Widget build(BuildContext context) {
    final estilos = context.estilos;
    const secundario = EfectosApp.textoSecundarioNotificacion;
    const principal = EfectosApp.textoNotificacion;
    return Semantics(
      container: true,
      label: '${Textos.notificacionApp}, $hora. $titulo. $cuerpo',
      excludeSemantics: true,
      child: Container(
        key: claveContenedor,
        width: ancho,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radio),
          boxShadow: EfectosApp.sombraNotificacion,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radio),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: EfectosApp.desenfoqueNotificacion,
              sigmaY: EfectosApp.desenfoqueNotificacion,
            ),
            child: Container(
              color: EfectosApp.fondoNotificacion,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    key: const ValueKey('icono-app-notificacion'),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: EfectosApp.iconoAppNotificacion,
                      borderRadius: BorderRadius.circular(8.4),
                    ),
                    child: const Center(
                      child: LogoApp(
                        forma: FormaLogo.isotipo,
                        tono: TonoLogo.negativo,
                        ancho: 31.7,
                        decorativo: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Textos.notificacionApp,
                              style: estilos.leyenda.copyWith(color: secundario),
                            ),
                            Text(hora, style: estilos.leyenda.copyWith(color: secundario)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(titulo, style: estilos.cuerpoEnfasis.copyWith(color: principal)),
                        const SizedBox(height: 2),
                        Text(cuerpo, style: estilos.cuerpoBase.copyWith(color: principal)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
