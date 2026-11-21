# Reporte
- **Tarea:** T-13 · Accesibilidad y pulido (WCAG 2.1 AA)
- **Rama:** `13-accesibilidad-y-pulido`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11. **Sin dependencias nuevas.**
- Figma (solo lectura) para el punto 7: T28c `101:5420`.

## Parte A · Pulido (los 10 puntos hechos; el 11 no)
1. **Foco tras los diálogos.**
   - Tienda: cada tarjeta tiene un nodo de regreso (`FocoRetorno`, sin parada de Tab ni nodo semántico propio). Al cerrar la compra (confirmar, cancelar o Esc) el foco vuelve ahí, aunque el botón haya quedado deshabilitado ("Máximo").
   - Ajustes: el foco vuelve a la fila "Tamaño de texto" al cerrar el selector (hoja o diálogo, con o sin elección).
2. **Salir del examen.** El texto termina con "El tiempo sigue corriendo.". El botón fantasma dice "Seguir en el examen" y lleva el foco inicial (`DialogoConfirmacion` ganó `textoCancelar` y `focoEnCancelar`). Los demás diálogos no cambian.
3. **Barra del examen** con relleno `accion/secundaria`, en móvil y tablet (`BarraProgreso.colorRelleno`). Contraste contra la pista: 13.4:1 en claro y 11.7:1 en oscuro.
4. **Orden 26b verificado** en juego, juicio y Examen, en 390×844 y 1194×834. Encontré dos fallos y los corregí:
   - **la tarjeta no era parada de Tab.** Ahora lo es, con anillo de radio 28 solo con teclado; las flechas, Enter y Esc siguen llegando a la pantalla.
   - **En tablet, "Tu Startup" del panel lateral era parada de Tab.** Ahora es solo lectura: el lector la lee, Tab no se detiene.
   - Órdenes resultantes:
     - Móvil: Salir → indicadores → tarjeta → Ilegal → Escalar → Condicional → Legal → comodines.
     - Tablet: Salir → Pausa → tarjeta → botones → comodines.
     - Juicio y Examen: no tienen comodines enfocables; la pausa del Examen aparece solo con tiempo extendido.
5. **Onboarding en tablet se desliza** (izquierda = siguiente, derecha = anterior; umbral de 48 dp o 300 dp/s). Con "Solo botones" no se desliza (ver D2).
6. **La tarjeta se queda con su sello** (solo `ClasePantalla.ancho`; juego, juicio y Examen).
   - `MazoSwipe.retenerAlConfirmar`: al confirmar, la tarjeta va al umbral con su sello completo, en los mismos 280 ms del vuelo. `alConfirmar` se llama en el mismo momento que antes, así que el estado, el veredicto, el guardado y el orden de eventos no cambian.
   - Cuando llega la siguiente tarjeta (al cerrar la hoja), una copia de la anterior sale volando por encima.
   - Con "Reducir animaciones" simplemente desaparece.
   - Móvil y 600–959: igual que antes.
7. **Chip del golpe (T28c).** En Figma (`101:5587`, 214 × 28) está **dentro de la tarjeta "El Jefe"**, a 14 de su borde superior y 16 del derecho. En tablet ahora va ahí (`TarjetaJefe.chip`); en móvil sigue sobre la barra del Jefe.
8. **Confeti proporcional** (`ConfetiSprint.proporcional`): en tablet las `x` se escalan con el ancho real del panel y ninguna pieza sale de él. Con 597 queda igual que Figma.
9. **`saldoJuegoProvider`** está ahora en `lib/funciones/juego/saldo_juego.dart`; el juego y el Examen lo importan de ahí.
10. **Anuncio del Buzón:** uno por cambio real.
    - Volver a tocar la fila seleccionada, o topar con el extremo con las flechas, no anuncia.
    - El detalle ya no es región en vivo; antes duplicaba el anuncio.
11. **Consejo de la Tienda según el inventario: no lo hice.** Requiere texto nuevo para cada caso (D3).

## Parte B · Auditoría automática (`test/auditoria/`)
- **Matriz:** 50 escenas × 4 tamaños (360×640, 390×844, 834×1194, 1194×834) × claro y oscuro × texto al 100, 160 y 200 % = **1200 pruebas**.
  - Escenas: 01 a 30 en sus estados principales (incluidas 11, 12, 12c, 14, 14b, 16, 18, 10b, 10c, 19, 19b, 20, 21 vacío, 22b ganada y perdida, 23, 28b, 28c y el fallo), más Ajustes, el selector de tamaño y los diálogos de compra, cerrar sesión, salir del juego, salir del Examen y pausa.
  - En cada una se verifica:
    - que no haya desbordes ni excepciones;
    - zona táctil Android (48) e iOS (44);
    - etiquetas (`labeledTapTargetGuideline`);
    - contraste de texto (`textContrastGuideline`).
  - Está repartida en cinco archivos para que corra en paralelo.
- **Contrastes** (`contrastes_test.dart`): **43 pares** de tokens con su uso, en claro y oscuro. Todos cumplen; la tabla con las razones está en `08-accesibilidad.md`.
- **Criterios** (`criterios_test.dart`):
  - orientación permitida y rotación a mitad del juego, del Buzón y del Examen;
  - anillo de foco visible y dentro de la pantalla en cada parada de Tab (8 pantallas y el acceso, en móvil y tablet);
  - Shift+Tab;
  - diálogo que encierra el foco, Esc y regreso del foco;
  - Enter y Espacio;
  - panel de veredicto no descartable;
  - un sprint completo con "Solo botones" y sin animaciones;
  - tecla P;
  - información que no depende solo del color (sellos, botones, impacto, plazo);
  - la guía `ZonaTactilMinima`.

### Fallos que encontró la auditoría y cómo se corrigieron
| # | Fallo | Dónde | Corrección |
|---|---|---|---|
| 1 | Zona táctil de los campos de texto de 24 a 38 de alto (el nodo era solo la línea de texto, no la caja de 52) | 05 y 06, todos los tamaños | El relleno vertical de 14 pasó de un `Padding` externo al `contentPadding` del `TextField`; el aspecto no cambia y la caja completa es tocable. |
| 2 | Chip de perfil cortado 2 dp al enfocar el primer error | 06 con errores, 834×1194 al 200 % | Al marcar el error de perfil se desplaza hasta mostrar el grupo completo de chips. |
| 3 | Desborde de la insignia "Vidas al máximo" en la barra del juicio | 22, 22b; 360 y 390 al 160 y 200 % | La insignia es `Flexible` y parte su texto. |
| 4 | **La app se bloqueaba en vertical también en tablet** (WCAG 1.3.4) | `main.dart` | `orientacionesPermitidas`: teléfono (lado corto < 600) vertical; tablet, todas. iOS y Android ya lo permitían. |
| 5 | Al rotar, el Buzón perdía la apelación seleccionada | 21 en tablet | La selección vive en `seleccionBuzonProvider` (se libera al salir del Buzón). |
| 6 | Al dar la vuelta con Tab, el control enfocado quedaba fuera de la vista (Flutter usa la política del extremo contrario) | Ajustes en móvil; mapa e intro en tablet | `FocoSiempreVisible` en la app: solo con teclado, desplaza para mostrar el control enfocado. |
| 7 | "Mostrar contraseña" sin anillo de foco | 05 y 06 | Usa `AccionEnfocable` (anillo de radio 24) en lugar de `InkResponse`. |
| 8 | La tarjeta no era parada de Tab (26b) y el panel lateral sí | Juego, juicio y Examen | Ver el punto A4. |
| 9 | Los atajos del Examen anuncian "P pausa" y la tecla no hacía nada | 28 | P pausa con la misma regla que el botón (solo con tiempo extendido). |
| — | Falsos positivos de zona táctil en nodos del mapa medio ocultos bajo el encabezado fijo | 08 y 09 | No es un fallo de la app: ver D5. |

**Sin fallos:** etiquetas, contraste de texto pintado, desbordes en el resto de pantallas, información solo por color, diálogos y trampas de teclado.

## Parte C · Documento
`ai/conocimiento/08-accesibilidad.md`:
- matriz WCAG 2.1 AA (criterio → cómo → verificación, con los criterios que quedan solo manuales);
- tabla de contrastes;
- orden de foco de las pantallas complejas;
- alternativas al gesto y atajos de teclado;
- lista de verificación manual por herramienta (TalkBack, VoiceOver, teclado físico, texto grande, rotación, modo oscuro) y por flujo (acceso, sprint, Buzón, Examen, cuenta).

No hay un índice aparte en `ai/conocimiento/`: agregué DOC-08 al grafo (D4).

## Decisiones propias
- **Tarjeta retenida:** la salida se anima con una copia de la tarjeta anterior cuando cambia la tarjeta. Así `MazoSwipe` no necesita que la pantalla le avise del cierre de la hoja, y no cambia ningún tiempo del estado. En 28b el Examen ya dibujaba su "tarjeta enviada" con sello (T-11), así que ahí no cambió nada.
- **Foco de regreso en la Tienda:** va a la tarjeta, no al botón de precio, porque el botón puede quedar deshabilitado tras la compra. La tarjeta no es parada de Tab: desde ella, Tab sigue con su botón.
- **Panel lateral solo lectura en tablet:** "Tu Startup" se lee como un bloque, sin parada de Tab.
- **Anillo de la tarjeta:** radio 28 (el de la tarjeta), solo con teclado.
- **Orientación:** se decide por el lado corto del dispositivo, que no cambia al rotar.
- **"P" del Examen:** solo con tiempo extendido y durante la decisión, como el botón.
- **Guía de zona táctil propia** para la auditoría (D5).

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test`: **2650 pruebas** (antes de T-13, 1281; nuevas 1369: matriz 1200, contrastes 89, criterios 42, pulido 38):
```
+2650: All tests passed!
```
- **Pruebas existentes que ajusté** (sin cambiar su tamaño de pantalla): dos de `juego_test.dart` que fijaban el orden 26b sin la tarjeta ("con el foco en un botón, Enter y Espacio…" ahora usa 4 Tab en lugar de 3, y "orden de foco de Figma 26b" incluye la tarjeta). Las demás siguen verdes sin cambios.

## Grafo actualizado
- **`en curso`:**
  - núcleo y app: MAIN, APP, ADAPTATIVO, TEXTOS;
  - componentes: COMP-BARRA-JUEGO, COMP-PROGRESO, COMP-BOTON, COMP-CAMPO, COMP-CONFETI, COMP-DIALOGO-CONFIRMACION, COMP-PANEL-LATERAL-JUEGO, COMP-PIEZAS-AJUSTES, COMP-PIEZAS-JEFE, COMP-PIEZAS-TIENDA;
  - pantallas: MAZO-SWIPE y CODIGO-PANT-02..04, 06, 10, 19, 21, 22, 24, 26, 27 y 29;
  - pruebas: TEST-JUEGO.
- **Nuevos:** FOCO-SIEMPRE-VISIBLE, COMP-FOCO-RETORNO, SALDO-JUEGO, TEST-AUDITORIA, TEST-PULIDO, DEC-TARJETA-RETENIDA, DEC-ORIENTACION, DEC-GUIA-ZONA-TACTIL y DOC-08.
- PANT-26b anota la tarjeta en el orden.
- Obsoletos: ninguno.
- Línea nueva en el registro de cambios.

## Solo para prueba manual
- Cómo suenan TalkBack y VoiceOver: que el anuncio de la selección del Buzón y el de los segundos del Examen no se repitan, y que la tarjeta se lea completa.
- Teclado físico en tablet real: el anillo de la tarjeta, la tecla P y la vuelta con Tab.
- Texto grande del sistema (la auditoría usa el ajuste de la app, que pasa por el mismo `MediaQuery`).
- Rotación en dispositivo: la orientación solo se puede comprobar en un iPad o una tablet Android.
- El vuelo de la tarjeta retenida al cerrar la hoja: se ve bien en pruebas, pero conviene mirarlo.

## Para la T-14 (lo que depende del servidor)
- **Hora del servidor:**
  - regeneración de vidas (`MockVidas.ahoraServidor`, cuenta de 20 y de 30);
  - plazos de las apelaciones (`MockApelaciones.ahoraServidor`: días 3, 7 y 14, "hoy" o "en N días");
  - reloj del Examen (límite de 15 o 22 s);
  - fecha y folio del certificado.
- **Conectividad:** `ServicioConexion` (hoy simulado con el interruptor de depuración) y la cola de respuestas en SQLite con UUID de cliente, que el servidor debe recibir una sola vez.
- **Compras:** saldo y máximo de 9 los valida el servidor (`ExcepcionTienda`); `saldoJuegoProvider` lee el saldo una vez al abrir el juego.
- **Resultados:** registro del Examen y desbloqueo del módulo siguiente, avance del mapa y estrellas.
- **Sesión:** tokens en almacenamiento seguro (hoy simulado).

## Dudas
- **D1.** La tarjeta ahora es parada de Tab (26b de esta tarea) y eso me obligó a actualizar dos pruebas de la T-05 que fijaban el orden sin ella. ¿Bien?
- **D2.** "Solo botones" también apaga el deslizamiento del onboarding en **móvil** (el `PageView`), no solo en tablet, por coherencia con el nombre del ajuste ("Botones en lugar de deslizar"). ¿Lo dejamos así?
- **D3.** Punto 11 (consejo de la Tienda según el inventario): no lo hice porque necesita textos nuevos para cada caso (por ejemplo, "Ya tienes 9 Lupas; prueba el Amparo"). Si me das los textos, es un cambio pequeño en `_ConsejoTienda` y `LogicaTienda`.
- **D4.** No hay índice en `ai/conocimiento/`, así que agregué la fila DOC-08 al grafo aunque los DOC-* son de Claude Chat. Revísala, y si quieres menciona 08 en `01-flujo-de-trabajo.md` ("leer 00 a 08").
- **D5.** La guía de zona táctil de Flutter marcaba como pequeños los nodos del mapa medio ocultos bajo el encabezado fijo: compara rectángulos en sistemas de coordenadas distintos. La auditoría usa `ZonaTactilMinima`, la misma guía con esa comparación corregida; detecta igual un control de 40 × 40 (hay prueba). ¿Te parece bien o prefieres que esas escenas desplacen el mapa antes de medir?
- **D6.** `borde/control` sobre `fondo/destacado` da 2.6:1 en oscuro. No se usa en ninguna pantalla, así que lo dejé fuera de la tabla y con una prueba que lo documenta. Si en el futuro se usa, habría que aclarar `borde/control` en oscuro.
- **D7.** En móvil el paso "progreso/HUD" del 26b es la parada de los indicadores de la Startup. La barra de progreso y el chip de vidas los lee el lector dentro de la barra, pero no son paradas de Tab propias (no hacen nada al activarlos). ¿Bien?
