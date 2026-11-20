# Reporte
- **Tarea:** T-07 · Evidencia y justificación (pantallas 15, 16, 16b, 17 y 18)
- **Rama:** `07-evidencia-y-comodines`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge. Los comodines y el Amparo quedan para T-07b.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11.
- **Comparé contra Figma** con el conector (solo lectura): contexto de diseño de 15 (`38:3956`), 16b (`38:4355`) y 18 (`38:4737`). De ahí salen los textos, las medidas, el snippet `registro_form.dart`, la tarjeta de contraseñas y las opciones de 18.
- **Prueba en el navegador:** compilé la app para web y jugué `spr-1-3` a 390×844, en claro y en oscuro.
  - **15:** tarjeta 6 con el chip "Evidencia" a la derecha y el botón discontinuo bajo el globo.
  - **16 y 16b:** el visor se abre con el botón y tocando la tarjeta; marqué las líneas 4 a 6 arrastrando y apareció 16b con el chip de bonus. Al acertar Ilegal salió 12b "+15 XP en total · +5 monedas".
  - **Línea equivocada:** se ve con su título y su texto, sin chip.
  - **17 y 18:** tarjeta 10 con "Dilema ×2" y el aviso; al dictar Ilegal se abrió 18. Elegir la primera opción solo la seleccionó y "Confirmar justificación" llevó a 12b "+15 XP en total · +10 monedas".

## Qué se hizo
1. **Modelo** (`tarjeta.dart`):
   - `EvidenciaTarjeta{archivo, lineas, lineasClave (desde 1), mensajeAcierto, mensajeFallo}` reemplaza al `String? evidencia`.
   - `Justificacion{opciones (3), indiceCorrecto}` va en `Tarjeta.justificacion`.
2. **Mocks** (`mock_tarjetas.dart`):
   - Las 10 evidencias pasaron a `EvidenciaTarjeta`, una línea por renglón, con sus líneas clave y sus dos mensajes.
   - Los 5 dilemas tienen justificación. La correcta va segunda en `spr-1-1`, tercera en `spr-1-4` y primera en los demás; la de Figma va primera, como en el diseño.
   - **Tarjeta 6 de `spr-1-3` (Figma 15 y 16b):** `registro_form.dart` de 7 líneas, con las líneas clave 4, 5 y 6 y el mensaje de Figma. Es "CASO 6 · PROTECCIÓN DE DATOS", de QA Tester, y la correcta es Ilegal.
   - **Tarjeta 10 de `spr-1-3` (Figma 17 y 18):** el dilema de contraseñas en texto plano de "Cliente · Inversionista ángel", con las opciones tal cual en Figma. Sustituye al dilema del inversionista que pedía la base de usuarios.
   - **Para conservar la composición de `spr-1-3`** (6 normales, 3 con evidencia y 1 dilema):
     - la tarjeta de menores de edad (normal) pasó a la 8, como "CASO 8 · MENORES DE EDAD";
     - salió la de cookies, que era de evidencia.
   - **En `spr-1-5`:** la bitácora tenía evidencia pero su respuesta es Legal, así que no hay línea que viole la ley. Pasó a normal, y las contraseñas en texto plano (Ilegal) pasaron a tener evidencia (`usuarios.dart`, línea clave 3).
   - Sin plazos, montos ni cifras legales nuevas; la prueba de cifras ahora revisa también las líneas, los mensajes y las justificaciones.
3. **Micro-preguntas retiradas** (tarjetas de evidencia y de dilema; su bonus es otro):
   - `tar-datos-03` (spr-1-1, religión);
   - `tar-consen-05` (spr-1-2, revocación);
   - `tar-derechos-06` (spr-1-4, borrado real);
   - `tar-brecha-03` (spr-1-5, el aviso);
   - `tar-aviso-03` (spr-1-3, finalidades);
   - `tar-gpl-01` (spr-1-3, GPL).

   Los dilemas no tenían. Cada sprint se queda con 2 micro-preguntas, todas en tarjetas normales.
4. **Lógica** (`LogicaVeredicto`):
   - `aciertaEvidencia(evidencia, lineas)`: acierta si las líneas incluyen alguna clave.
   - `bonusEvidencia`: tarjeta de evidencia, marcó bien y el veredicto es correcto.
   - `bonusJustificacion`: tarjeta de dilema, veredicto correcto y opción correcta. Con el veredicto equivocado la justificación no cuenta.
   - `conBonus(monedasDobles:)`: suma +5 XP y, en los dilemas, duplica las monedas (`monedasCorrecto × 2`).
   - El bonus no toca vidas, indicadores ni estrellas: `ResultadoTarjeta.bonus` ya contaba como acierto.
5. **Estado** (`EstadoJuego`, `JuegoNotifier`):
   - `evidenciaMarcada` (id → acertó) y `lineasMarcadas`, para volver a mostrar el resultado.
   - `marcarEvidencia` marca **una sola vez**; si ya estaba marcada, devuelve lo anterior.
   - `responder(tarjeta, veredicto, justificacion:)`: con bonus, el panel abre directo en Bonus (12b) y `ResultadoTarjeta.bonus = true`. La micro-pregunta solo aparece si no hubo bonus.
6. **Pantalla 10:**
   - **Visor de evidencia:** `showModalBottomSheet` con `isDismissible: true` y sin arrastre. Se cierra con "Volver y decidir", atrás, Esc o tocando fuera. Al cerrar, el foco vuelve al botón de evidencia.
   - **Abrirlo:** tocar la tarjeta sin moverla (≤ 8 dp) o el botón. El reconocedor de arrastre de la T-05 gana la arena al tocar, así que el "toque" se detecta al soltar en `MazoSwipe.alInspeccionar`; el arrastre sigue igual.
   - **Dilemas:** al deslizar o pulsar un veredicto se abre primero el panel de justificación, sin descarte, y luego el de veredicto.
   - **Lector:** la tarjeta agrega su tipo ("con evidencia por inspeccionar", "evidencia ya inspeccionada" o "dilema: …") y la acción "Inspeccionar evidencia".
7. **Componentes:**
   - **`SnippetCodigo` (nuevo):**
     - barra con los 3 botones de ventana y el archivo, y líneas de 24 numeradas con ancho fijo;
     - JetBrains Mono 12/18 sin saltos: el bloque se desplaza en horizontal;
     - línea clave revelada en `rgba(181,36,38,0.28)` con texto `#FECACA`;
     - resaltado del jugador como **un rectángulo por tramo** de líneas seguidas, a 12 de los lados, con borde 2 y radio 6 (como `38:4552-4553`);
     - cada línea es un botón: se marca tocando o arrastrando en vertical (cuenta la línea donde empieza el dedo); con teclado, flechas y Enter o Espacio.
   - **`PanelEvidencia` (nuevo):** 16, 16b y línea equivocada, más `ContenedorPanelModal`, el contenedor compartido con 18, y `ChipBonusEvidencia`.
   - **`PanelJustificacion` (nuevo):** chip "Dictaste: …" del color del veredicto, título H1 centrado, subtítulo, 3 opciones y el botón deshabilitado hasta elegir.
   - **`TarjetaCaso`:** recibe `tipo` y muestra `ChipTipoTarjeta`, `BotonEvidencia` (borde discontinuo pintado, 48, foco, Enter y Espacio) y `AvisoDilema`. `altoMinimoPara` cuenta el botón o el aviso.
   - **`OpcionJustificacion`:** modo selección con `seleccionada` (borde 2.5 `accion/secundaria`, círculo relleno, se lee "seleccionada"). Sin `seleccionada` sigue confirmando al elegir, como en la micro-pregunta de la T-06.
8. **`EfectosApp`:** colores del snippet y del resaltado, y duración del resaltado (150 ms; cero con "reducir animaciones").
9. **Galería:** sección "Evidencia y dilema" con las tarjetas por tipo, dos snippets, los 3 visores, opciones en modo selección y el panel 18.

### Copy de la variante "línea equivocada" (no está en Figma)
- Título: **"Esa no es la línea clave"**, con ícono `x` en `estado/ilegal`. En 16b el `check` va en `estado/legal`, como en Figma.
- Texto (`mensajeFallo`, igual en todas las tarjetas): **"Esa línea no es la que viola la ley. Ahora regresa a la tarjeta y dicta tu veredicto."**
- Sin chip de bonus y con el mismo botón "Volver y decidir".

### Decisión: la justificación es un panel previo, no una fase de `FasePanel`
La califico **después** de confirmar, con `responder(…, justificacion:)`. Así la calificación sigue siendo un solo paso y el panel de veredicto no sabe nada de la justificación: abre en Bonus o en Correcto según el resultado. Con una fase nueva habría que calificar antes, guardar un resultado provisional y cambiarlo al confirmar; además los indicadores mostrarían el cambio mientras se elige.

## Accesibilidad
- **Foco:** al abrir, va al título del visor ("Inspecciona la evidencia") y al de 18 ("Dictaste ILEGAL. ¿Por qué es ilegal?"). Ambos se anuncian y, cuando cambian (al marcar), se vuelven a anunciar.
- **Nada depende solo del color:**
  - cada línea se lee "Línea 4: …; marcada; línea clave", y la marcada lleva borde;
  - la opción elegida lleva el círculo relleno y se lee "seleccionada".
- **Contraste AA** sobre el fondo oscuro, verificado en pruebas: texto, números, nombre de archivo, línea clave, y texto marcado sobre el resaltado.
- **Objetivos táctiles:** el botón de evidencia mide ≥ 48. Las líneas se quedan en 24: no amplié su área a 44 porque se solaparían con las vecinas; con teclado no hay problema.
- **Sin animaciones** en el resaltado con "reducir animaciones".
- **Al 200 %:** el snippet se desplaza en horizontal y los paneles en vertical. Si no cabe en una línea, el chip de tipo baja debajo de la etiqueta.

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test` (647 pruebas; antes de T-07, 556):
```
+647: All tests passed!
```
- **Pruebas nuevas o cambiadas:**
  - **Lógica:** acierto de evidencia con una o varias líneas; bonus de evidencia (marcó bien o mal, no marcó, acierta o falla); monedas dobles; la justificación no cuenta con el veredicto equivocado; tarjetas normales sin bonus.
  - **Mocks:** evidencia y justificación solo donde el tipo lo pide; líneas clave en rango y sin `\n`; 3 opciones; tarjetas 6 y 10 de Figma; 2 micro-preguntas por sprint, solo en normales.
  - **Componentes:**
    - `SnippetCodigo`: líneas, revelada, tramos, teclado, semántica, desplazamiento y contraste;
    - tarjeta por tipo, en claro y oscuro;
    - opción en modo selección;
    - visores y panel 18, en claro y oscuro, al 100 % y al 200 %.
  - **Pantalla 10 (`evidencia_justificacion_test.dart`):**
    - visor: abrirlo con el botón, con un toque y con la acción del lector; marcar bien, mal, varias líneas y con teclado; marcar una sola vez; cerrar sin marcar con Esc, atrás o fuera, y reabrir; 12b con +15 XP;
    - justificación: abrirla tras los 4 botones y los 4 swipes; elegir no confirma; los tres resultados más el parcial; sin descarte; foco y anuncio;
    - sin desbordes en 390×844, 360×640 y 320×640, al 100 % y al 200 %, en claro y en oscuro.

## Grafo
- **Actualizados (`en curso`):** MOD, MOCK-TARJ, TEMA-EFECTOS, TEXTOS, PANT-GALERIA, EST-JUEGO, MAZO-SWIPE, CODIGO-PANT-10, LOGICA-VEREDICTO, COMP-TARJETA-CASO, COMP-OPCION-JUSTIFICACION, TEST-JUEGO, TEST-VEREDICTO, TEST-FIN-SPRINT, TEST-COMP, TEST-AYUDA y TEST-GALERIA.
- **Nuevos:** COMP-SNIPPET, COMP-PANEL-EVIDENCIA, COMP-PANEL-JUSTIFICACION y TEST-EVIDENCIA.
- **Obsoletos:** ninguno. Agregué una línea en el registro de cambios.

## Dudas
1. **Ícono de dedo (`38:4554`):** no hay SVG local, así que lo omití, como pide la tarea.
2. **Resaltado:** Figma usa `#FFE27A` con mezcla multiply al 55 %. Sobre `#0B1220`, multiply casi no tiñe, así que usé un relleno al 12 % más el borde de 2, que es lo que se ve en Figma. ¿Está bien?
3. **Modo oscuro:** la barra del snippet (`#162030`) casi coincide con `fondo/superficie` del panel en oscuro, así que la barra se pierde. Dejé los valores fijos de la tarea. ¿Hace falta una variante oscura?
4. **Iniciales del avatar:** Figma muestra "QA" para "QA Tester" y "CL" para "Cliente"; la regla de `LogicaInicio.iniciales` da "QT" y "C". ¿Cambiamos la regla o los nombres?
5. **Cambios de contenido en los mocks:** salieron la tarjeta de cookies y el dilema del inversionista de `spr-1-3`, y la evidencia de `spr-1-5` pasó de la bitácora a las contraseñas. ¿Está bien?
6. **`mensajeFallo`:** es el mismo texto genérico en todas las tarjetas. ¿Quieres uno propio por tarjeta?
7. **Fondo de 18:** en Figma la tarjeta lanzada se ve inclinada con el sello detrás del panel. Aquí, como en 12 y 14 desde la T-06, la tarjeta ya salió y no se ve.
