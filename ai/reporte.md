# Reporte

- **Tarea:** T-06 · Veredictos (pantallas 12, 12b, 12c, 14 y 14b)
- **Rama:** `06-veredictos`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11.
- Durante la tarea, Windows Device Guard bloqueó `dart.exe` un rato. Me detuve hasta que se desbloqueó; desde entonces cada paso pasó por `dart format`, `flutter analyze` y `flutter test`.
- **Comparé contra Figma** con el conector (solo lectura):
  - Metadatos de las pantallas 12 (`37:2287`) y 14 (`37:3147`).
  - Contexto de diseño de 14 y de los paneles `37:2427`, `37:2671`, `37:4047` y `38:5384`.
  - Lo que confirmé:
    - Hay un **velo `#0B1220` al 40 %** sobre toda la pantalla.
    - La tarjeta ya salió de la pantalla y se ve la pila.
    - Los indicadores muestran el cambio ("+10", "+25") junto a cada barra.
    - Los paneles miden 487 (12) y 419 (14).
- Probé la app compilada para web en el navegador, a 390×844: acierto con micro-pregunta (12), opción correcta → bonus (12b), Continuar → tarjeta 2, error (14) con la barra en 4 vidas.

## Qué se hizo
1. **Datos:**
   - `ImpactoTarjeta`: presupuesto, reputación, velocidad y riesgo legal; todos 0 por defecto.
   - `MicroPregunta`: enunciado, 2 o 3 opciones e índice correcto.
   - `Tarjeta` tiene ahora `impactoAcierto`, `impactoFallo`, `impactoParcial`, `microPregunta`, `explicacionFallo` y `explicacionParcial`.
   - `MockTarjetas`: las 10 tarjetas de `spr-1-3` tienen sus 3 impactos y 4 llevan micro-pregunta. La tarjeta de la GPL (`spr-2-1`) tiene los valores, la micro-pregunta y los 3 textos de Figma (bonus, parcial y fallo).
2. **Lógica pura** (`LogicaVeredicto`):
   - `calificar` devuelve correcto, parcial, incorrecto o Amparo, con sus XP, monedas, vida e impacto. `conBonus` suma los 5 XP de la micro-pregunta.
   - `aplicar` deja cada indicador entre 0 y 100.
   - `haQuebrado`: Riesgo legal en 100 o Presupuesto en 0.
   - `destino`: quiebra → sin vidas → última tarjeta → siguiente.
   - `explicacion` elige el texto según el resultado.
3. **Estado del sprint** (`EstadoJuego` y `JuegoNotifier`):
   - Guarda el estado de la Startup, vidas, XP, monedas, resultados (con bonus), falladas, el panel pendiente (con su fase: micro-pregunta, explicación o bonus) y si el Amparo está activo.
   - `responder` califica y abre el panel. `elegirOpcion` y `saltarBonus` mueven la micro-pregunta. `cerrarPanel` decide el destino y solo avanza la tarjeta si toca la siguiente.
   - El Amparo se gasta al absorber un error; `establecerAmparo` queda listo para T-07.
4. **Componentes nuevos** (con pruebas y en la galería):
   - `PanelVeredicto`: un solo componente con las 5 variantes de la tabla de `07-componentes.md`.
   - `OpcionJustificacion`.
   - `BloqueLectura`: lo extraje de la pantalla de juego para reusarlo en el panel.
   - `IndicadoresStartup` ahora muestra el cambio junto a la barra (y la acorta para no pasar a dos filas) y anima el relleno.
   - `ImpactoStartup` usa `texto/acento` para Presupuesto, como en Figma 12c.
5. **Flujo en la pantalla:**
   - Al confirmar (arrastre, botón, teclado o lector), la tarjeta sale volando. Al terminar el vuelo se ocultan el sello y el tinte, se califica y vibra según el tipo (en web no).
   - Sube el panel: hoja modal sin descarte (no se cierra con Esc, atrás ni tocando fuera), con el velo de Figma, en 280 ms ease-out; con "reducir animaciones" aparece sin movimiento.
   - Mientras está abierto, la barra de juego muestra las vidas nuevas y los indicadores, los valores nuevos con sus cambios.
   - Al pulsar el botón se cierra y la app va a quiebra (`Rutas.startupQuiebraDe`), sin vidas (`Rutas.sinVidas`), sprint completado o la siguiente tarjeta. Las tres rutas son marcadores (`PANT-PENDIENTE`).

## Resultados
`dart format --set-exit-if-changed lib test`: sin cambios.

`flutter analyze`:
```
No issues found!
```
`flutter test` (474 pruebas; antes 409):
```
+474: All tests passed!
```
- `test/funciones/juego/logica_veredicto_test.dart`:
  - Calificación: correcto, bonus, parcial con Escalar (y no con Condicional ni Legal), Escalar cuando sí era Escalar, incorrecto, Amparo (+20 en lugar de +25), Amparo con aumento menor a 5 (queda en 0), y Amparo que no cambia un acierto ni un parcial.
  - Indicadores: límites 0–100 y quiebra por Riesgo y por Presupuesto.
  - Prioridad de destino y explicaciones por resultado.
  - Mock: 10 tarjetas con impactos y 4 micro-preguntas.
- `test/funciones/juego/veredicto_test.dart`:
  - Las 5 variantes con XP, monedas, vidas, falladas e indicadores; micro-pregunta acertada, fallada y saltada.
  - Panel modal: no se cierra con Esc, atrás ni tocando fuera; sello y tinte ocultos; velo de `#0B1220` al 40 %; título anunciado y con el foco.
  - Destinos: última tarjeta, 0 vidas, quiebra por Riesgo con prioridad sobre 0 vidas, y quiebra por Presupuesto.
  - Vibraciones: ligera, de selección y media.
  - Sin desbordes con el panel abierto en 390×844 y 360×640 al 200 %, y 320×640 al 100 % y 200 %, en claro y oscuro.
- `test/componentes/veredicto_componentes_test.dart`:
  - Las 5 variantes en claro y oscuro: insignia, ícono, título, subtítulo, pose de Sarko, explicación y tipo de botón. Correcto con micro-pregunta y "Saltar bonus".
  - Separación 14 (16 en Incorrecto).
  - Accesibilidad: anuncio y foco del título, y orden de foco impacto → explicación → botón.
  - **Contraste ≥ 4.5:1** de los 5 colores de título sobre `fondo/superficie`, del ícono sobre la insignia y de los 4 chips de impacto sobre su fondo, en ambos modos.
  - Sin desbordes a 390/360 al 200 % y a 320.
  - Indicadores con cambios y animación (salta con "reducir animaciones"), y `OpcionJustificacion`.
- Ajusté las pruebas de T-05: ahora la tarjeta avanza al cerrar el panel (ayudante `cerrarPanel`). Galería con los 5 paneles.

## Decisiones
- **Panel como hoja modal** (DEC-PANEL-MODAL): `showModalBottomSheet` con `isDismissible: false`, `enableDrag: false` y `PopScope(canPop: false)`. La pantalla decide el destino al cerrarla.
- **Sombra del panel:** (0, 16, 40) al 22 % ("Sombra/Elevada"), como dice `07-componentes.md`. El código de Figma la exporta como `drop-shadow(0 16 20)`, que es la misma sombra en CSS.
- **Barras con cambio:** con un cambio al lado, la pista mide 44 en lugar de 68, para que las 4 columnas sigan en una fila como en Figma 14 (allí la pista es flexible).
- **Sello y tinte tras el vuelo:** se ocultan hasta la siguiente tarjeta; en Figma 12 y 14 ya no se ven.
- **Foco inicial:** el título del panel recibe el foco al abrirse, pero no dibuja el anillo. El anillo solo aparece al llegar navegando con teclado; antes se veía con el ratón en web.
- **Explicación del Amparo:** usa la del fallo (`explicacionFallo`). Figma 14b tiene un texto propio que menciona el Amparo (ver D2).
- **Íconos de la insignia:** check, star, arrow-down, x y shield-check de Lucide, que ya existían en `IconosApp`.

## Límites conocidos
- **Estado local:** vidas, XP, monedas, indicadores y falladas viven solo durante el sprint; los repositorios solo se leen al entrar. Lo guardará el servidor en T-14.
- **Amparo sin activar:** existen el parámetro, el estado `amparoActivo` (falso por defecto) y la variante 14b, pero el comodín se activa en T-07. En las pruebas se activa a mano.
- **Parcial solo con Escalar:** elegir Condicional cuando no era la respuesta cuenta como incorrecto (decisión de Chat).
- **Falladas:** quedan en `EstadoJuego.falladas`; no van al Buzón hasta T-09.

## Grafo actualizado
Toqué la sección 4 (Código), las filas PANT-12, 12b, 12c, 14 y 14b (sección 5), la línea "Última actualización" y el registro de cambios. Comprobé que todas las rutas de `lib/` y `test/` del grafo existen.
- **Cambiados (`en curso`):**
  - App y rutas: ENRUTADOR, RUTAS y PANT-PENDIENTE.
  - Tema y textos: TEMA-EFECTOS y TEXTOS.
  - Datos: MOD y MOCK-TARJ.
  - Juego: EST-JUEGO, MAZO-SWIPE y CODIGO-PANT-10.
  - Componentes: COMP-BOTON (solo relaciones), COMP-INDICADORES y COMP-IMPACTO.
  - Galería y pruebas: PANT-GALERIA, TEST-GALERIA, TEST-JUEGO, TEST-COMP y TEST-DATOS.
- **Nuevos:** LOGICA-VEREDICTO, COMP-BLOQUE-LECTURA, COMP-OPCION-JUSTIFICACION, COMP-PANEL-VEREDICTO, TEST-VEREDICTO y DEC-PANEL-MODAL.
- **Obsoletos:** ninguno. La clase privada `_BloqueEnfocable` de la pantalla de juego se reemplazó por `BloqueLectura`; no tenía nodo propio.

## Dudas
- **D1 · Tarjeta de la GPL.** Figma muestra la GPL como la tarjeta 5 del Sprint 3 (Aviso de privacidad), pero en el mock está en `spr-2-1` (Licencias). Le puse ahí los valores y textos de Figma, y a las 10 de `spr-1-3` valores parecidos sobre privacidad. ¿Se mueve la GPL al Sprint 3, o se queda en Licencias?
- **D2 · Texto del Amparo.** Figma 14b tiene una explicación propia ("Tu Amparo absorbió el error esta vez…"). ¿Se agrega un campo `explicacionAmparo` a la tarjeta, o un texto fijo que se añade a la explicación del fallo?
- **D3 · Velo en modo oscuro.** El velo `#0B1220` al 40 % casi no se nota sobre el fondo oscuro. ¿Se usa otro valor en oscuro?
- **D4 · Star de la insignia.** El ícono star de Lucide es de contorno; en el bonus de Figma también se ve de contorno, pero en la micro-pregunta parece relleno. Lo dejé de contorno en los dos. ¿Se rellena el de la micro-pregunta?
- **D5 · XP y monedas fuera del sprint.** El XP y las monedas ganados no cambian todavía el nivel ni las monedas del Inicio (no hay guardado). ¿Se suma en T-06b o en T-14?
