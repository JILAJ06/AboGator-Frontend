# Reporte
- **Tarea:** T-13b · Pantallas de cuenta, legal y notificaciones (ronda 2: correcciones tras la revisión)
- **Rama:** `13b-pantallas-cuenta-y-legal`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11. **Sin dependencias nuevas.**
- Medidas de T34 tomadas de `siguiente.md` (Figma `150:5709`).

## Ronda 2 · lo corregido
### A · Notificaciones de racha en tablet (T34): panel de ilustración
- **Composición nueva** `DisposicionIlustracionTablet` (`lib/componentes/disposicion_ilustracion_tablet.dart`, para la T-15).
  - No reutilicé `DisposicionAccesoTablet`: su panel es el verde de marca, con logo y lema. Este es el panel `fondo/destacado` del onboarding, sin logo.
- **1194×834:**
  - Panel izquierdo de 597 × 834 en `fondo/destacado` con `IlustracionRacha` centrada:
    - círculo `fondo/superficie` de 340;
    - Sarko alegre de 230 de ancho, a (+55, +12) del círculo;
    - insignia de 84 `accionPrimaria` con `flame` de 40, a (+257, −18): arriba a la derecha del círculo, como en Figma.
  - La ilustración no crece y se reduce si el panel es más chico.
  - Atrás de 48 × 48 en el panel, en (32, 32).
  - A la derecha, la columna de 470 centrada en alto, **sin** Sarko ni atrás: título, descripción, tarjeta de tres filas (470 de ancho), nota, "Activar notificaciones" y "Ahora no".
- **834×1194 y 600–959:** el panel pasa a una franja de 260 arriba, con la misma ilustración reducida y el atrás, y la columna de 470 debajo (el mismo patrón que Recuperar).
- **Selector de hora (34c) en tablet:** sigue siendo el diálogo de 440 sobre el velo del 40 %; no cambió.
- **Móvil:** como antes, salvo las filas (B).

### B · Filas de 34 sin íconos
- `FilaAjuste.icono` ahora es opcional (Ajustes lo sigue pasando) y hay `rellenoHorizontal`: 16 en móvil y 20 en tablet.
- Las tres filas de 34 (y la del recordatorio, que es propia) ya no llevan `flame`, `gavel` ni `clock`.
- El texto empieza en x16 (móvil) o x20 (tablet) y el interruptor de 52 × 32 queda a la derecha.

### Respuestas aplicadas
- D1, D2, D3 y D6: sin cambios.
- D7: Claude Chat agregó PANT-31 a PANT-34; `PantallaPendiente` se borra en la T-15.
- D8: queda "el correo del equipo del proyecto".

## Qué hay en la T-13b (resumen de la ronda 1, aprobada)
- **Recuperar contraseña (31 a 31e):**
  - Rutas `/recuperar`, `/enviado`, `/nueva?token=`, `/listo` y `/caducado`.
  - Mock con `solicitarRecuperacion` y `restablecer`: el token `caducado` lleva a 31e.
  - Cuenta de 45 s para reenviar, anunciada una vez.
  - Validaciones con foco en el primer campo con error.
  - En tablet, el panel de marca con la expresión de cada paso y la insignia de 96 en la columna.
- **Aviso de Privacidad y Términos de uso (32, 33):**
  - `PantallaLegal` con `FilaAcordeon`: una sección abierta a la vez, con borde de 2 `accionAcento` y semántica expandida.
  - Textos en `textos_legales.dart`, marcados como BORRADOR.
  - En tablet, columna de 640.
  - Accesos desde el Registro (enlaces con push), el Perfil y Ajustes ("Legal").
- **Notificaciones de racha (34, 34c, 34b):**
  - `/ajustes/notificaciones`, de primer nivel.
  - Interruptores guardados al instante en el repositorio de ajustes.
  - Selector de hora aislado: hoja en móvil, diálogo en tablet, ajustable con lector y teclado, y botones + y − con "Solo botones".
  - Se abre tras el primer registro, una vez.
  - En la galería, las dos notificaciones de 34b con `NotificacionSistema`.

## Componentes compartidos (para la T-15)
- **Nuevo en la ronda 2:** `DisposicionIlustracionTablet`.
- **De la ronda 1:**
  - `InsigniaCircular` (ahora con `tamanoIcono`) e `IlustracionInsignia`;
  - `FilaAcordeon`;
  - `InterruptorApp(grande:)` e `InterruptorTocable`;
  - `NotificacionSistema`;
  - `RuedaSelector`;
  - `PanelMarca`, `FranjaMarca` y `DisposicionAccesoTablet` con `pose`.
- **Sin compartir:** `IlustracionRacha` vive en `pantalla_notificaciones.dart` porque es propia de T34.

## Decisiones propias (ronda 2)
- **Círculo del panel en `fondo/superficie`:** así se distingue del panel `fondo/destacado`, como el del onboarding.
- **Sarko de 230 × 287.5:** `SarkoImagen` guarda la relación 4:5, así que no llega a los 301 de alto de Figma. No lo deformé.
- **La franja vertical mide 260:** la ilustración de 341 × 358 se reduce para caber.
- **El atrás de la franja** va en (32, 32), igual que en el panel.

## Accesibilidad
- La auditoría de cuenta (13 escenas × 4 tamaños × claro y oscuro × 100, 160 y 200 % = 312 combinaciones) y el foco visible en 31, 31c, 32 y 34 siguen verdes con la composición nueva.
- Se verifica: sin desbordes, zona táctil Android e iOS, etiquetas, contraste y anillo en cada parada de Tab.
- En tablet el orden de foco es: atrás (en el panel) → título → filas → botones.

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test`: **3025 pruebas** (3019 en la ronda 1; 6 más en esta):
```
+3025: All tests passed!
```
- **Pruebas nuevas o ajustadas en la ronda 2:**
  - notificaciones: 20 (antes 14). La de "columna de 470 centrada" se reemplazó por:
    - panel de 597 con círculo, Sarko, insignia y atrás en (32, 32);
    - columna de 470 a la derecha, sin Sarko ni atrás, y cuyo atrás cierra;
    - franja en 834×1194 y en 600×960;
    - selector como diálogo;
    - filas sin íconos en móvil y tablet, con el texto en x16 o x20.
  - galería: la ilustración de T34 suma una imagen de Sarko.

## Grafo actualizado
- **`en curso`:** COMP-PIEZAS-AJUSTES, COMP-ILUSTRACION-INSIGNIA, CODIGO-PANT-34, PANT-GALERIA, TEST-NOTIFICACIONES y TEST-GALERIA.
- **Nuevo:** COMP-DISPOSICION-ILUSTRACION.
- **Obsoletos:** sin nuevos (PANT-PENDIENTE sigue `obsoleto` desde la ronda 1).
- Línea nueva en el registro de cambios.

## Para la T-14 (sin cambios desde la ronda 1)
- **Recuperación:**
  - el enlace profundo del correo y "Abrir correo" (hoy, el token `demo`);
  - la caducidad real (30 minutos) y el uso único del token;
  - el reenvío con límite del servidor;
  - el cierre de las sesiones en otros dispositivos.
- **Notificaciones:**
  - el permiso del sistema y el alta del dispositivo al "Activar";
  - el envío real (racha, días 3, 7 y 14, máximo 2 al día);
  - la hora del recordatorio programada por el servidor, con la zona horaria.
- **Legal:** la versión y la fecha vigentes del Aviso y los Términos, y qué versión aceptó cada usuario.

## Dudas
- **D1.** Sarko del panel de T34 mide 230 × 287.5 (4:5) y no 230 × 301 como en Figma, para no deformar la imagen. ¿Bien así, o lo hago de 240 de ancho para acercarme a los 301 de alto?
