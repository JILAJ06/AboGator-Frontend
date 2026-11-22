# Reporte
- **Tarea:** T-15f · Fin de sprint, Examen y resúmenes
- **Rama:** `15f-fin-de-sprint-examen-y-resumenes`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge.

## Resumen
- **Las pantallas de fin de sprint y la crisis del Examen arman ahora cada pieza una vez para móvil y tablet.**
- **Sin componentes nuevos:** todo quedó en variables locales o en widgets privados del mismo archivo (ningún patrón llega a 3 usos).
- **Líneas de `lib/`:** 35 355 → **35 263 (−92)**. **`test/`:** sin cambios (20 452).
- **Pruebas:** **3309**, las mismas; no cambió ninguna. La auditoría, incluida `acciones_de_tocar_test.dart`, pasa sin tocar sus escenas.
- **Cero cambios visibles:** mismas medidas, separaciones, claves, etiquetas, orden de foco (`ElementoOrdenado`) y escalas de tablet.
- **P-14 (`MarcoMazo`) no se tocó:** queda para la T-15g. No modifiqué `mazo_swipe.dart` ni el teclado del mazo.

## Por patrón
| Patrón | Archivo | Qué se arma una vez | Neto | Puntos de cambio |
|---|---|---|---|---|
| P-11 | `pantalla_sprint_completado.dart` | Sarko, estrellas, y título con subtítulo (`titulo(separacion:)`: 16 en tablet, 4 en móvil) | **−19** | 3 piezas: 2 → 1 |
| P-11 | `pantalla_startup_quiebra.dart` | Sarko triste, etiqueta de la causa y título | **−6** | 3 piezas: 2 → 1 |
| P-11 | `pantalla_juicio.dart` (resultado) | Sarko, corazones e insignia de vida | **−18** | 3 piezas: 2 → 1 |
| P-15 | `pantalla_jefe.dart` | `alerta` (ya existía; el móvil la copiaba), `_ReglasCrisis`, `_TiempoExtendido` y `_PieEnfrentar` | **−36** | 4 piezas: 2 → 1 |
| P-20 | `pantalla_sin_vidas.dart` | `FilaVidas` y el Sarko triste | **−13** | 2 piezas: 2 → 1 |
| **Total** | | | **−92** | 15 piezas: 30 → 15 |

### Examen (P-15)
- `_PieEnfrentar` reúne el aviso sin conexión, «Enfrentar auditoría» (deshabilitado sin conexión y cargando al iniciar) y «Ahora no». Es una `Column` con `mainAxisSize.min` y `stretch`, así que mide lo mismo en las dos vistas.
- `_CrisisTablet` ya no recibe `enLinea`, `iniciando`, `alEnfrentar` ni `alAhoraNo`: recibe `reglas`, `tiempoExtendido` y `pie` ya armados.
- Las claves siguen en los mismos widgets: `alerta-jefe`, `reglas-crisis`, `tiempo-extendido-crisis`, `aviso-sin-conexion-examen`, `boton-enfrentar` y `boton-ahora-no`.
- **No toqué** el cronómetro, el foco propio del Examen, la tecla P ni las políticas de error y sin conexión. `jefe_test` y `examen_tablet_test` pasan sin cambios.
- Los controles movidos (`BotonApp` y el `TextButton` de «Ahora no») siguen exponiendo la acción de tocar; la auditoría de acciones de tocar lo confirma en las escenas del Examen.

## Lo que quedó fuera
- **D1. `ColumnaFinSprint(ilustracion, cuerpo)` (la opción de P-11):** no la hice. En las cuatro pantallas, el orden y las separaciones de las piezas cambian entre móvil y tablet; por ejemplo, en la quiebra el móvil separa con 10, 12, 8, 8 y 30, y la tablet siempre con 16. `ColumnaFinSprint` no podría repartirlas sola sin una lista de excepciones.
- **D2. `_AlertaJefe` contra `ChipHoraCrisis` (`piezas_jefe.dart:216`):** no coinciden (relleno 12/6 contra 10-12/5, ícono 16 contra 14, texto flexible solo en la alerta) y son 2 usos. La alerta ya era una variable; solo dejé de copiarla en el móvil.
- **D3. `BotonTextoApp`:** no lo creé. «Ahora no» sigue con 2 usos, y ahora vive en un solo lugar (`_PieEnfrentar`).
- **D4. P-20 `PanelMarca`:** el logo y Sarko cambian de ancho, posición y contenedor en cada variante. Un ayudante privado agregaría ≈ 4 líneas.
- **D5. P-20 `BarraJuego` contra `BarraJuegoTablet`:** la columna del progreso usa otro estilo (Leyenda contra Etiqueta) y otra separación (6 contra 8). Una clase de parámetros o un widget privado agregaría ≈ 8 líneas.
- **D6. P-20 confeti:** son coordenadas de Figma. Las `x` de tablet son las del móvil × 1,5, pero las `y` no siguen ninguna regla. Derivarlas escondería los valores de Figma sin ahorrar líneas.

## Estimación contra resultado
- Estimado en `09`: ≈ −235 (P-11 −100, P-15 −90, P-20 −45). Real: **−92**.
- La estimación contaba como repetido el contenido completo de móvil y tablet. En realidad, las separaciones y algunas composiciones difieren: por ejemplo, el estado final de la Startup va en una caja con borde solo en tablet. Lo que sí era igual son las piezas: eso es lo que se unificó.

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test`: **3309 pruebas**.
```
+3309: All tests passed!
```

## Documentación y grafo
- `ai/conocimiento/09-duplicacion.md`:
  - La fila de la T-15f queda con sus patrones reales y se agrega la fila de la T-15g (P-14, sola).
  - En «Resultados por lote» agregué la T-15e-fix y la T-15f, con la tabla por patrón y lo que no se hizo.
- `ai/grafo.md`:
  - **`en curso`:** CODIGO-PANT-19, CODIGO-PANT-19b, CODIGO-PANT-20, CODIGO-PANT-22, CODIGO-PANT-27 y DOC-09.
  - **Nuevos y obsoletos:** ninguno (solo hay piezas privadas).
  - Entrada nueva en el registro de cambios.

## Dudas
- **D1 a D6:** las omisiones de la sección anterior. Si Claude Chat quiere alguna de todos modos, va en otro lote.
- **D7.** Con −92 líneas, la T-15 suma −289 en `lib/` contando la corrección (T-15b −76, T-15c −23, T-15e −80, fix −18, T-15f −92), lejos del ≈ −620 estimado. ¿Conviene que la T-15g y la T-15d se midan sobre todo por puntos de cambio, como ya dice `09`?
