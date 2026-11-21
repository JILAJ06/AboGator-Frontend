# Reporte
- **Tarea:** T-12d · Tablet: resultados del sprint, Sin vidas, Buzón + Juicio, Sin conexión y Examen Final
- **Rama:** `12d-tablet-buzon-y-examen`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11. **Sin dependencias nuevas.**
- **Comparé contra Figma** con el conector (solo lectura): T19 `98:5016`, T19b `98:2433`, T20 `100:3887`, T21b `100:3950`, T22 `100:4212`, T22b `100:4281`, T23 `100:4342`, T27 `101:4895`, T28 `101:5001`, T28b `101:5194`, T29 `101:5592` y T30 `101:5666` (y `101:5171` y `101:4907` en detalle).
- **Prueba en el navegador** (web compilada a 1194×834, cuenta de prueba del mock en localhost): Buzón, Juicio, Apelación ganada y la crisis del Examen coinciden con Figma. Ahí cambié la tarjeta de la vista previa del Buzón para que muestre la pista de gestos (como en Figma) en lugar de "Elige con los botones".

## Qué se hizo
1. **Composición de resultado** (`DisposicionResultadoTablet` + `IlustracionAmpliada` en `lib/componentes/`): sin riel; a la izquierda un panel de hasta 597 (`fondoSuperficie`, o el color que se pase) con la ilustración del móvil ampliada y centrada y el confeti arriba; a la derecha el contenido en una columna de 470 centrada que se desplaza. `ColumnaFinSprint` y el `marco` de 29/30 la usan solo en tablet horizontal.
   - **T19:** Sarko y estrellas × 1.7 (elipse de 340, estrellas de 61.2 / 78.2), confeti con las 7 piezas de Figma sobre el panel (`ConfetiSprint` con lienzo de 597), título, texto, las tres estadísticas iguales, "Estado final de tu Startup" centrado con los indicadores en su caja (borde 1, radio 16, relleno 10), aviso del buzón solo con fallos y los dos botones.
   - **T19b:** Sarko triste y la etiqueta de la causa × 1.7; a la derecha indicadores, título, descripción y aviso.
   - **T20:** corazones y Sarko triste × 1.7, "Cerrar" en (24, 12) y a la derecha la cuenta regresiva, la nota y la sugerencia del Buzón.
   - **T22b:** Sarko, las vidas y la insignia × 1.6; título, texto y días de repaso.
   - **T29:** trofeo y Sarko × 1.6 con el confeti de Figma; **T30:** Sarko triste × 1.7.
2. **Buzón (T21) en lista-detalle:** riel con la insignia; a la izquierda (500) el título, el texto, la recompensa, la lista y "Iniciar apelaciones de hoy"; a la derecha (526, borde izquierdo) "PRÓXIMO JUICIO · DÍA N", el título, Sarko de 96, la tarjeta del caso de 342 × 440 con "La fallaste hace N días" e "Iniciar juicio" (342 × 52).
   - **Selección:** la primera al abrir; tocar una fila la selecciona (fondo `fondoDestacado`, "seleccionada" y un anuncio) sin navegar; las flechas arriba y abajo mueven la selección y el foco.
   - "Iniciar juicio" abre el juicio de la seleccionada; si aún no toca, avisa cuándo se abre (como el toque en móvil).
   - Vacío y 600–959: el Buzón del móvil centrado con ancho máximo de 640.
3. **Juicio (T22):** la composición del juego de T-12c (`ComposicionJuegoTablet`, que moví de `pantalla_juego.dart` a `lib/componentes/` para compartirla) con la barra del juicio, la tarjeta de 380 × 470, los botones, la nota "Las apelaciones no dan avance…" y, en el panel lateral, "APELACIÓN · DÍA N" con el título y "Fallaste esta tarjeta hace N días. Si aciertas ahora recuperas 1 vida." y los atajos.
4. **Examen:**
   - **T27:** panel izquierdo `#162030` con un halo de 560 (blanco al 6 %) y la alerta, Sarko enojado, la barra del Jefe y la línea de crisis del móvil × 1.4; a la derecha el título centrado, la descripción, las reglas, el tiempo extendido y los botones.
   - **T28 / T28c:** `ComposicionJuegoTablet` con `BarraJuegoTablet` (paso "Crisis · Decisión k de 10", HUD y **pausa solo con tiempo extendido**, como en móvil), la tarjeta con su hora y el temporizador, los botones y "Comodines desactivados"; panel lateral con **`TarjetaJefe`** ("INSPECTORA VEGA · AUDITORÍA", la barra del Jefe y la regla) y los atajos con "P pausa · Esc cierra el panel". El chip del golpe se ve igual que en móvil.
   - **T28b:** el contraargumento en `HojaLateral` (el panel lee `HojaLateral.radioDe/bordeDe`).
   - Reglas, reloj y estado del examen sin cambios.
5. **T23 Sin conexión:** en Figma es el juego con el aviso sobre la tarjeta y las respuestas guardadas en lugar de los comodines: ya quedó así en la T-12c; no hubo cambios.
6. **Galería:** fila del Buzón seleccionada y `TarjetaJefe`.

## Medidas que tomé de Figma
- **Resultados** (todos): panel de 597 a toda la altura; contenido en x 661, 470 de ancho, separación 16, centrado en alto.
  - T19b: ilustración de 391 × 476 en (103, 147): elipse de 374, Sarko de 299.2, etiqueta de 289.2 × 48.4; contenido en y 214 (indicadores, título, descripción de 40, aviso de 52, botones de 52 y 48).
  - T20: ilustración de 408 × 493 en (95, 139): corazones de 53 (hueco 17.7) arriba y elipse de 374 con Sarko de 299.2; Cerrar de 48 en (24, 12); contenido en y 189 (título, "Próxima vida en", cuenta de 63, nota con reloj de 16, sugerencia de 150 con relleno 18, botón de 48).
  - T22b: ilustración de 384 × 528 en (107, 121): elipse de 368, Sarko de 294.4, corazones de 49.9 y la insignia "+1 vida recuperada" de 256.6 × 45.2; contenido en y 261 (título, texto de 40, días de repaso de 228 × 28 centrados, botones).
  - T29: trofeo de 153.6 en (67, 241) y Sarko de 281.6 en (243, 209); 8 piezas de confeti; contenido en y 191 (título, texto de 40, certificado de 167, botones de 52 y 48).
  - T30: elipse de 391 en (103, 188) con Sarko de 312.8; contenido en y 211 (título, texto de 40, resumen de 3 × 107 × 68, próxima vida de 44, botones).
- **T22:** barra de 1146 × 56 en (24, 8) con "Apelación 1 de 2" y "+1 vida"; tarjeta de 380 × 470 en (207, 108) con el aviso en (231, 490); acciones en (230.5, 594); nota en y 702; panel lateral en x 794: contexto (142 de alto) y atajos (130) con 16 entre ellos.
- **T27:** panel `#162030`; halo de 560 en (20, 108); ilustración de 490 × 518 en (54, 126) con la alerta de 323 × 40, Sarko de 156.8, la barra del Jefe de 478.8 × 106.8 y la línea de crisis de 455.6; contenido en y 152 (título de 64 centrado, texto de 40, reglas de 220, tiempo extendido de 16, botón de 52, "Ahora no" de 20).
- **T28/T28b:** tinte de urgencia a pantalla completa; barra de 1146 × 64; hora de la crisis (126 × 26) y temporizador de 80 sobre la tarjeta; comodines bloqueados de 277 × 48; "El Jefe" de 376 × 216 (relleno 20, separación 12; barra del Jefe de 334 × 76) y atajos de 130 con 16 entre ellos; contraargumento en la hoja de 376 en y 357 (423 de alto), 22 sobre el borde.
- **T21b** en Figma es la **notificación del sistema** en la pantalla de bloqueo (no un Buzón vacío): no hay nada que dibujar en la app; el Buzón vacío de tablet no tiene diseño (ver decisiones).

## Decisiones propias (no vienen de Figma)
- **Tres estadísticas iguales** en T19 (repartidas en los 470; Figma las deja de 107).
- **Selección inicial** del Buzón: la primera apelación de la lista (la más próxima).
- **Flechas** en la lista: mueven la selección y el foco; Enter sobre una fila la selecciona.
- **"Iniciar juicio" de una apelación futura:** muestra el mismo aviso que el toque en móvil ("Se abre en N días") y, bajo el botón, el texto del plazo.
- **Buzón vacío en tablet:** el estado vacío del móvil con el riel, centrado en 640.
- **600 a 959:** todas estas pantallas como en móvil, centradas (Buzón y resultados con su ancho máximo).
- **Halo de T27:** blanco al 6 % (`EfectosApp.haloCrisis`), como el círculo del panel de marca.
- **Pausa del Examen en tablet:** solo con tiempo extendido (la regla de T-11); sin él, la barra no muestra el botón.
- **`ComposicionJuegoTablet`** se movió de `pantalla_juego.dart` (no estaba en los archivos permitidos) a `lib/componentes/` para reutilizarla en el juicio y el Examen; el juego no cambió (ver D1).

## Accesibilidad
- Resultados: el título se anuncia al abrir y tiene el foco; el orden de lectura es el del móvil (`ElementoOrdenado`); las estadísticas se leen como una frase.
- Buzón: riel → título → recompensa → lista (una parada por fila, flechas) → "Iniciar apelaciones de hoy" → detalle → "Iniciar juicio". La fila seleccionada se anuncia "seleccionada" y al seleccionar se anuncia "Seleccionada: <título>".
- Contraargumento: contenedor "Contraargumento de la Inspectora" en la hoja lateral, con el mismo foco inicial que en móvil.
- **Contrastes AA verificados en pruebas (claro y oscuro):** `textoSecundario` sobre `fondoDestacado` y sobre `fondoSuperficieAlt`, blanco sobre `estadoIlegal`, `textoAcento` sobre `fondoDestacado`.
- **Sin desbordes** en 1194×834, 834×1194 y 600×960 al 100 % y 200 %, claro y oscuro (19 y 20, Buzón, crisis y decisión).

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test` (1281 pruebas; antes de T-12d, 1219):
```
+1281: All tests passed!
```
- **Pruebas nuevas (62):**
  - `resultados_tablet_test.dart`: 19 (panel de 597, columna de 470, ilustración × 1.7 y estrellas, confeti de tablet, estadísticas iguales, caja de indicadores, aviso, botones), sin fallos sin aviso, "Continuar al mapa", 834/600/móvil con la columna de siempre, 19b (y "Reiniciar sprint"), 20 (Cerrar en (24, 12) y regreso al mapa), sin desbordes (12 casos);
  - `buzon_tablet_test.dart`: riel, lista 500 y detalle 526, tarjeta de 342 centrada, selección por toque (sin navegar) y flechas, "Iniciar juicio" de la seleccionada, apelación futura, vacío, vertical, juicio con la composición de juego y **ganar → 22b**, sin desbordes (12 casos), contrastes;
  - `examen_tablet_test.dart`: 27 (panel, halo, ilustración × 1.4, reglas), 28 (composición, paso, `TarjetaJefe`, atajos, comodines bloqueados, sin pausa), pausa con tiempo extendido, 28b en la hoja lateral (posición y etiqueta), **ganar → 29** y **perder → 30** en tablet, 30 en móvil sin cambios, sin desbordes (12 casos).
- **Ajustes en pruebas existentes:** solo la galería (superficie de 30000, 5 filas del Buzón, 2 barras del Jefe y `TarjetaJefe`). Las pruebas del juego, el Buzón, el juicio y el Examen en móvil siguen verdes **sin cambiar de tamaño**.

## Grafo
- **Actualizados (`en curso`):** PIEZAS-FIN-SPRINT, CODIGO-PANT-19, 19b, 20, 21, 22, 27 y 29, COMP-FILA-APELACION, COMP-PIEZAS-JEFE, COMP-CONFETI, COMP-BARRA-JUEGO, COMP-PANEL-LATERAL-JUEGO y CODIGO-PANT-10.
- **Nuevos:** COMP-RESULTADO-TABLET, COMP-COMPOSICION-JUEGO y TEST-TABLET-12D.
- PANT-19 a PANT-30 anotan su vista de tablet (PANT-23: el aviso de T-12c).
- **Obsoletos:** ninguno. Agregué una línea en el registro de cambios.

## Para la T-13 (pulido que vi en tablet)
- **La tarjeta sale volando al confirmar** (juego, juicio y Examen); en Figma queda con su sello mientras la hoja está abierta (D1 de T-12c).
- **Chip del golpe en T28:** se coloca como en móvil (arriba a la derecha); en tablet podría ir sobre la tarjeta "El Jefe".
- **Foco al cambiar de selección en el Buzón:** el anuncio es discreto (`liveRegion` + anuncio); con VoiceOver conviene probar que no se repita.
- **Esqueletos** de carga: en tablet siguen siendo los del móvil a ancho de contenido.
- **Confeti:** las piezas de tablet se pintan sobre el panel; con ventanas más angostas que 1194 (panel menor de 597) algunas quedan fuera.
- **Rotar** a mitad del Buzón o del Examen: la selección y el estado se conservan, pero no lo probé en dispositivo.

## Dudas
- **D1.** Moví la composición del juego de tablet (`_JuegoTablet`) de `pantalla_juego.dart` a `lib/componentes/composicion_juego_tablet.dart` para reutilizarla en el juicio y el Examen; `pantalla_juego.dart` no estaba en los archivos permitidos (solo cambió el nombre y el import). ¿Bien?
- **D2.** El Examen en tablet importa `saldoJuegoProvider` de `pantalla_juego.dart` para las monedas del HUD. ¿Lo movemos a un archivo compartido en la T-13?
- **D3.** Figma no tiene Buzón vacío de tablet (T21b es la notificación del sistema). ¿El estado vacío del móvil centrado está bien?
- **D4.** En la vista previa del Buzón, "Iniciar juicio" de una apelación que aún no toca muestra el aviso (como en móvil). ¿Lo prefieres deshabilitado?
