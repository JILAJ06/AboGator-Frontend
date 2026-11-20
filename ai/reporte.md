# Reporte
- **Tarea:** T-10b · Ajustes de accesibilidad y modo oscuro (pantalla 26)
- **Rama:** `10b-ajustes-accesibilidad`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11. Sin dependencias nuevas.
- **Comparé contra Figma** con el conector (solo lectura): 26 (`18:2634`).
- **Colores del interruptor (leídos de la imagen de Figma):** encendido verde #1F4E35, que es `accionPrimaria`; apagado gris pizarra, que coincide con `bordeControl` (#64748B). El pulgar es blanco, y uso `fondoSuperficie` (blanco en claro).
- **Prueba en el navegador** (web a 390×844, cuenta de prueba del mock en localhost):
  - La pantalla 26 coincide con Figma: encabezado, secciones, filas, interruptores y chips.
  - El modo oscuro cambia la app al instante y aparece "Usar el modo del sistema".
  - El selector de tamaño se abre, elegí 140 % y todo el texto crece.
  - **Error encontrado y corregido:** en oscuro la hoja del selector salía con fondo claro y texto claro. Ahora el selector pinta su propio fondo con los tokens del tema vigente, y una prueba lo cubre.

## Qué se hizo
1. **Datos:**
   - Modelo `Ajustes` con `copyWith` y estos valores por defecto: sistema, 100 %, sin solo botones, **háptica encendida**, sin tiempo extendido y sin reducir animaciones.
   - `RepositorioAjustes` con `CodecAjustes`: claves `modo_tema`, `escala_texto`, `solo_botones`, `haptica`, `tiempo_extendido` y `reducir_animaciones`. Un valor inválido o ausente toma el por defecto, y el tamaño solo acepta 100/120/140/160.
   - `AjustesSqlite` usa la tabla `ajustes` de `BaseLocal`; `AjustesEnMemoria` es para web y pruebas.
   - `repositorioAjustesProvider` elige con `usarBaseLocal`, como el onboarding.
   - Cerrar sesión no los toca.
2. **Estado (`estado_ajustes.dart`):**
   - `ajustesProvider` aplica el cambio al instante y lo guarda. Si guardar falla, revierte y la pantalla muestra un SnackBar en región en vivo.
   - `main` crea el contenedor con `crearContenedor()`, que hace `await` de `cargar()` antes de `runApp` y usa `UncontrolledProviderScope`. Así el tema y el tamaño salen bien **desde el primer cuadro**; si cargar falla, se usan los por defecto.
   - `modoTemaProvider` conserva su API: lee de los ajustes y `establecer` guarda.
3. **Efectos reales:**
   - **Modo oscuro:** el interruptor muestra el modo efectivo (incluye "sistema" con el sistema en oscuro) y al tocarlo guarda `dark` o `light` explícito. Con un modo explícito aparece "Usar el modo del sistema" (alto 48), que vuelve a `system`.
   - **Tamaño de texto:** escala efectiva = sistema × porcentaje, con tope de 2.0. Se aplica en `MaterialApp.builder`, así llega a diálogos y paneles. Con 100 % se deja la escala del sistema tal cual, y el ajuste nunca la reduce.
   - **Reducir animaciones:** en el mismo `builder`, `disableAnimations` = sistema o ajuste.
   - **Vibración:** `ServicioHaptico` con `acierto`, `parcial`, `error` (dos `mediumImpact` separados 90 ms) y `suave`. No vibra en web ni con el ajuste apagado.
     - Reemplaza todas las llamadas directas: juego (correcto, parcial, error/Amparo), juicio (ganada suave, perdida error) y compra (suave).
     - Al encender el ajuste da una muestra suave.
   - **Solo botones:** `MazoSwipe(arrastreActivo: false)` quita el reconocedor de arrastre. En tarjetas con evidencia queda un reconocedor de toque que abre el visor. Botones, teclado y acciones del lector califican igual. La pista dice "Elige con los botones". Aplica en el juego y en el juicio.
   - **Tiempo extendido:** solo se guarda en `ajustesProvider`; lo usará el Examen Final en la T-11. No agregué temporizadores.
4. **Pantalla 26 (`pantalla_ajustes.dart`):**
   - Atrás (48, flecha, en x 20) y título con el foco al abrir; el subtítulo.
   - Tres secciones (Visual, Motor y auditiva, Cognitiva) con encabezados semánticos y tarjetas de radio 18 con divisores.
   - Filas ≥ 56, tocables en toda su superficie.
   - Selector de tamaño en una hoja: 4 opciones de radio ≥ 48, "Aa" a cada tamaño, foco en la actual, y se cierra al elegir.
5. **Componentes nuevos** (`piezas_ajustes.dart`): `InterruptorApp` (propio, porque el `Switch` del tema no llega a 48×28), `ChipValor`, `FilaAjuste`, `EncabezadoSeccionAjustes` y `OpcionTamano`. Todos están en la galería.
6. **Rutas:** `/perfil/ajustes` es `PantallaAjustes`, hija del Perfil (la cubre su redirección sin sesión) y sin barra inferior. Borré `Textos.pendienteAjustes`.

## Decisiones que no vienen de Figma
- **Valores por defecto reales:** los de la tarea, no los de Figma (Figma tiene todos encendidos salvo "Reducir animaciones").
- **"Disponible":** el chip dice "Activo" solo si el lector está activo (`accessibleNavigation`); si no, "Disponible". Es informativo: no se toca ni recibe foco.
- **Selector de tamaño**, botón "Usar el modo del sistema" y **vibración doble de error**.
- **Botón de atrás:** uso el cuadrado de 48 con flecha de Figma (`BotonIconoCuadrado`, el mismo del botón de ajustes del Perfil). La tarea mencionaba `BotonCerrar`, pero ese lleva una X.
- **Chip de tamaño:** "Aa 120 %", con espacio antes del %, como pide la tarea (Figma: "Aa  120%").
- **Reducir animaciones con el sistema ya en "reducir":** el interruptor muestra lo que guardó la persona, pero el efecto es el del sistema (sigue reducido aunque lo apague).
- **Texto grande:** con 200 % en 320/360 de ancho, el control de cada fila usa como máximo el 40 % del ancho y el chip parte su texto en lugar de desbordarse.

## Accesibilidad
- **Filas con interruptor:** una sola etiqueta ("Modo oscuro, contraste alto en fondos oscuros") con `toggled`. El interruptor interno se excluye para que no se lea dos veces.
- La fila de tamaño es un botón con valor ("100 por ciento").
- El lector lee "Etiquetas para lector: activo/disponible".
- El título recibe el foco al abrir; secciones como encabezados; objetivos ≥ 48 (filas ≥ 56).
- **Contraste verificado con pruebas en claro y oscuro:**
  - pista contra la tarjeta y pulgar contra la pista, encendido y apagado: ≥ 3:1 (WCAG 1.4.11);
  - texto del chip sobre `fondoSuperficieAlt` y subtítulo sobre `fondoApp`: ≥ 4.5:1.
- **Sin desbordes** en 390×844, 360×640 y 320×640 al 100 % y 200 %, en oscuro y con el botón "Usar el modo del sistema" visible.

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test` (938 pruebas; antes de T-10b, 893):
```
+938: All tests passed!
```
- **Pruebas nuevas en `ajustes_test.dart` (47):**
  - repositorio: valores por defecto; memoria; SQLite con `sqflite_common_ffi`, incluido reabrir la base; inválidos;
  - lógica: tope de 200 % con el sistema en 150 %; modo efectivo; animaciones;
  - servicio háptico: patrones, error doble, apagado y web;
  - estado: cambio al instante, revertir, `modoTemaProvider` que guarda, `crearContenedor` con y sin error;
  - efectos:
    - arranque con dark y 140 % aplicados en el primer cuadro;
    - tema al instante con el interruptor del modo efectivo, y "Usar el modo del sistema";
    - selector y tamaños 120/140/160;
    - animaciones en el juego y el Splash;
    - háptica: muestra al encender, juego sin vibrar con el ajuste apagado, compra y juicio por el servicio;
  - solo botones: arrastrar no mueve, botones y teclado califican, pista, toque que abre el visor y el juicio;
  - pantalla: claro/oscuro con medidas y valores por defecto, "Activo"/"Disponible", interruptores que se guardan, error que revierte, semántica y foco, atrás (botón y sistema) al Perfil, ajustes que sobreviven al cierre de sesión, selector en oscuro, contrastes y desbordes.
- **Ajustes en pruebas existentes:**
  - el error vibra dos veces;
  - los destinos pendientes del Perfil ya no incluyen los ajustes;
  - `abrirJuego` acepta `ajustes`, `repoAjustes` y `haptica`.

## Grafo
- **Actualizados (`en curso`):** MAIN, APP, ENRUTADOR, PANT-PENDIENTE, MODO-TEMA, TEXTOS, MOD, PROV-REPO, PANT-GALERIA, MAZO-SWIPE, CODIGO-PANT-10, COMP-TARJETA-CASO, CODIGO-PANT-22, CODIGO-PANT-24, TEST-VEREDICTO y TEST-PERFIL.
- **Nuevos:** REPO-AJUSTES, LOCAL-AJUSTES, MOCK-AJUSTES, SERV-HAPTICO, EST-AJUSTES, LOGICA-AJUSTES, CODIGO-PANT-26, COMP-PIEZAS-AJUSTES y TEST-AJUSTES.
- PANT-26 apunta a su código.
- **Obsoletos:** ninguno. Agregué una línea en el registro de cambios.

## Dudas
1. **Tope de 200 % con el sistema ya por encima:** si el sistema ya está en 250 % y la persona elige 120 %, dejo 250 % (el ajuste nunca reduce la escala del sistema). ¿Prefieren limitar siempre a 200 %?
2. **En web los ajustes viven en memoria**, como la cola de respuestas y el onboarding: se pierden al recargar la página. ¿Hace falta guardarlos en web (por ejemplo, en el almacenamiento del navegador) o basta con móvil?
3. **Foco tras el selector:** al cerrarlo, el foco vuelve al título y en web con ratón se ve su anillo, igual que pasaba en la Tienda. ¿Debe volver a la fila "Tamaño de texto"?
4. **Amparo y vibración:** cuando el Amparo absorbe un error, el juego usa la vibración de error (doble), como antes usaba la media. ¿Debería ser otra?
