# Reporte
- **Tarea:** T-12b · Tablet: Mapa de sprints + detalle (lista-detalle), Tienda, Perfil y Ajustes
- **Rama:** `12b-tablet-mapa-y-cuenta`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11. **Sin dependencias nuevas.**
- **Comparé contra Figma** con el conector (solo lectura): T08 `96:582`, T24 `101:4306`, T25 `101:4553` y T26 `101:4759` (con `101:4545`, `101:4734` y `101:4888` en detalle).
- **Prueba en el navegador** (web compilada a 1194×834, cuenta de prueba del mock en localhost): mapa con detalle, Tienda, Perfil, Ajustes y el diálogo de tamaño de texto coinciden con Figma (los revisé en modo oscuro, que es el que tenía el navegador).

## Qué se hizo
1. **Mapa + detalle (T08)**, solo a partir de 960 de ancho y dentro del riel:
   - **Panel izquierdo** (596 de 1090, proporcional si la ventana es menor): `EncabezadoModulo` con medidas de tablet (`arribaMinimo` 16 y `abajoExtra` 16 → 134 de alto) y `MapaSprints` del móvil dibujado a 390 y ampliado × 1.12 (436.8) centrado. El camino se mide en el mapa sin escalar, así que sigue pasando por los centros.
   - **Panel derecho** (494): `fondoSuperficie`, borde izquierdo de 1 y una columna de 430 centrada (también en alto) con el detalle y "Comenzar sprint" (430 × 52). Se desplaza si no cabe.
   - **Detalle compartido** (`DetalleSprint` en `lib/funciones/mapa/detalle_sprint.dart`): lo usan la intro del móvil (centrado, elipse de 230) y el panel (a la izquierda, elipse de 207 y separación 14). También se movieron ahí `SarkoConElipse` y `comenzarSprint`; la intro móvil se ve igual que antes.
   - **Selección:** al abrir queda el sprint actual (en curso o disponible), si no el último completado, si no el primero. Tocar o Enter sobre un sprint abierto lo selecciona sin navegar; los bloqueados no hacen nada y el Examen final habilitado abre la crisis.
   - **Enlace profundo:** la ruta de la intro, en ancho, muestra esta vista con ese sprint seleccionado (lo decide `PantallaIntroSprint`, no el enrutador, así no se tocó `enrutador.dart`). Desde esa ruta, "atrás" va al Inicio.
   - Entre 600 y 959 y en móvil, el mapa y la intro funcionan como antes (con riel en tablet).
2. **Tienda (T24):** margen 32 y arriba 20; catálogo en **4 columnas** con medianil 24 (238.5 cada una a 1194); separaciones 28 · 10 · 26 · 10 · 24 · 24; **consejo de Sarko destacado** (nuevo texto de Figma) con Sarko de 136 × 170 a 44 de la tarjeta.
3. **Perfil (T25):** dos columnas 500:502. A la izquierda la tarjeta, las estadísticas de 2 × 2 y las insignias **repartidas a todo el ancho**; a la derecha "Cuenta y preferencias" (H3), el menú y **"Progreso por módulo"** (`TarjetaProgresoModulos`: un renglón por módulo con nombre, "60 %" y barra de 8 del color del módulo). Para eso `DatosPerfil` guarda también los módulos (`modulos`), que ya se pedían; el porcentaje cuenta sprints completados sin el Examen final.
4. **Ajustes (T26):** en tablet va dentro de `MarcoPrincipal` con el riel (**Perfil activo**) y en dos columnas 500:502: Visual y la nueva **vista previa** ("VISTA PREVIA · TEXTO AL N %", con el tamaño elegido) a la izquierda; Motor y auditiva y Cognitiva a la derecha. En móvil, sin cambios y sin navegación.
5. **Diálogos en tablet:** `DialogoConfirmacion` llega a 440 (en móvil sigue en 400) y el selector de tamaño de texto pasa de hoja a **diálogo centrado de 440** con las esquinas redondeadas.
6. **Arreglos de la T-12:**
   - **Consejo de Sarko:** "Termina el Sprint N hoy y desbloquea <título del sprint siguiente>." y, en el último sprint normal, "… desbloquea el Examen final.". Se quitó `Textos.tramosConArticulo`.
   - **Reserva del Buzón:** con riel el mapa ya no reserva el lugar del botón. Buzón, Tienda y Perfil **no la reservaban** (no tienen botón flotante); el Inicio de tablet tampoco.
   - **Insignia del riel:** `totalBuzonRielProvider` depende de `apelacionesPendientesProvider`, que ya se invalida al resolver un juicio, registrar fallos del juego y terminar el Examen; así no hubo que tocar el juego, el Buzón ni el Examen. La Tienda lo invalida tras comprar.
7. **Galería:** consejo destacado, progreso por módulo, vista previa y un nodo seleccionado.

## Medidas que tomé de Figma (T24 a T26)
- **T24 Tienda:** título en y 20 (52 − 32); saldo de 87 × 38 que termina en x 1162; "Tu inventario" en y 80, píldoras en 116 (alto 34, separación 8); "Comodines" en 176; catálogo en 212, 4 tarjetas de 238 × 228 con 24 entre ellas; nota RN03 de 1026 × 44 en 464; consejo de 846 × 100 en 532 (`fondoDestacado`, radio 20, relleno 20, separación 6, Leyenda `textoAcento` y Cuerpo/Base `textoPrimario`); Sarko de 136 × 170 en (1026, 492).
- **T25 Perfil:** "Mi perfil" en y 20; botón de ajustes de 48 en (1114, 12); tarjeta de 500 × 92 en y 76; estadísticas de 245 × 62 con 10 entre ellas en y 184; "Insignias" en 346 y medallas en 386 (79 de ancho, x 0, 140, 280 y 420); derecha en x 660: "Cuenta y preferencias" (Fredoka SemiBold 17) en 80, menú de 502 × 198 en 116 (filas de 49), progreso de 502 × 248 en 338 (relleno 20, separación 12; fila: Cuerpo/Base, Etiqueta `textoSecundario`, barra de 8 con pista `fondoSuperficieAlt` y relleno del color del módulo, 6 debajo).
- **T26 Ajustes:** atrás de 48 en (132, 12); título en (192, 20); subtítulo en y 72; títulos de sección en 124 y tarjetas en 146 (separación 6); izquierda de 500 (Visual de 185 de alto y vista previa de 166 a 28 de ella: `fondoSuperficieAlt`, radio 20, relleno 20, separación 10, Leyenda `textoSecundario`, H2 y Cuerpo/Base `textoSecundario`); derecha de 502 en x 660 (Motor de 124 y Cognitiva en 298).

## Decisiones propias (no vienen de Figma)
- **Seleccionado en el mapa:** el actual se distingue por su aro de pulso; otro seleccionado lleva un **borde de 3 en `accionPrimaria`** a 4 de la cara. Los dos se anuncian como "seleccionado". Con teclado aparece además el anillo de foco.
- **Globo "Estás aquí" en tablet:** Figma T08 no lo muestra pero deja su espacio; lo oculté **conservando su lugar** y fuera del foco y del lector (el detalle ya tiene "Comenzar sprint").
- **Detalle centrado en alto** dentro del panel (en Figma queda a 91 arriba y 90 abajo).
- **Anuncio de la selección:** "Sprint 2, Consentimiento. Completado, 3 estrellas." (estado con mayúscula; las estrellas solo en completados).
- **600 a 959:** Tienda con catálogo de 2 columnas, Perfil y Ajustes en una columna; los tres con ancho máximo de 640 centrado, como el Inicio. El mapa como en móvil, con riel.
- **Progreso por módulo:** muestra los 5 módulos (Figma dibuja 4) con los nombres cortos del proyecto ("Licencias open source").
- **Insignias en tablet:** se reparten a todo el ancho si caben; si no (texto grande o muchas), se desplazan como en móvil.
- **Diálogos:** el de confirmación pasa de 400 a 440 solo en tablet.

## Accesibilidad
- **Mapa en tablet:** orden de foco riel → atrás → nodos abiertos (de arriba abajo) → "Comenzar sprint" del detalle. El detalle se anuncia con `liveRegion` al cambiar la selección; los nodos conservan su etiqueta de 04b y suman "seleccionado".
- **Progreso por módulo:** cada renglón se lee "1 · Protección de datos, 40 %".
- **Contrastes AA verificados en pruebas (claro y oscuro):** `textoAcento` y `textoPrimario` sobre `fondoDestacado` (consejo de la Tienda) y `textoSecundario` sobre `fondoSuperficieAlt` (vista previa).
- **Sin desbordes** en 1194×834, 834×1194 y 600×960 al 100 % y 200 %, claro y oscuro (mapa con detalle en 1194 en las cuatro combinaciones; Tienda, Perfil y Ajustes en las doce).
- Los ajustes se siguen aplicando al instante; "Solo botones", tamaño de texto y demás reglas de T-10b no cambian.

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test` (1188 pruebas; antes de T-12b, 1116):
```
+1188: All tests passed!
```
- **Pruebas nuevas:**
  - `mapa_tablet_test.dart`: paneles de 596 y 494, encabezado de 134, botón atrás en (120, 20), mapa × 1.12 en x 79.6, sin globo visible, las 6 piezas del detalle en 430, selección inicial (3 casos), tocar un completado (sin navegar, anuncio, borde, "seleccionado"), bloqueados y Examen bloqueado, Examen habilitado → crisis, "Comenzar sprint" → juego del seleccionado, ruta de la intro → vista combinada y atrás al Inicio, atrás sin pila, orden de foco, error, módulo no encontrado, 200 % claro/oscuro, 834 y 600 como hoy, reserva del Buzón con y sin riel y el texto del anuncio;
  - `cuenta_tablet_test.dart`: Tienda (4 columnas, consejo, saldo, 2 columnas en vertical, compra con diálogo de 440 centrado), Perfil (2 columnas, progreso de los 5 módulos, medallas repartidas, cierre de sesión con diálogo, una columna en vertical, porcentaje), Ajustes (riel con Perfil activo, 2 columnas, vista previa, ajuste al instante, diálogo de tamaño de 440, atrás, móvil sin riel y con hoja), sin desbordes (36 casos), **insignia N → N−1 al ganar un juicio** y contrastes;
  - consejo del Inicio con sprint siguiente, Examen final y general.
- **Ajustes en pruebas existentes:** solo la galería (superficie de 28000 para que quepan las piezas nuevas, 6 nodos, 2 consejos). **Ninguna prueba cambió de tamaño.**

## Grafo
- **Actualizados (`en curso`):** MARCO-PRINCIPAL, TEXTOS, PANT-GALERIA, LOGICA-INICIO, LOGICA-MAPA, CODIGO-PANT-08, CODIGO-PANT-09, COMP-ENCABEZADO-MODULO, COMP-NODO-SPRINT, EST-TIENDA, CODIGO-PANT-24, LOGICA-PERFIL, EST-PERFIL, CODIGO-PANT-25, COMP-PIEZAS-PERFIL, COMP-DIALOGO-CONFIRMACION, CODIGO-PANT-26, COMP-PIEZAS-AJUSTES, COMP-CONSEJO, TEST-GALERIA y TEST-TABLET.
- **Nuevos:** DETALLE-SPRINT, TEST-TABLET-12B y DEC-SELECCION-MAPA.
- PANT-08, 09, 24, 25 y 26 anotan su vista de tablet.
- **Obsoletos:** ninguno (`Textos.tramosConArticulo` se quitó; no tenía nodo). Agregué una línea en el registro de cambios.

## Para T-12c y T-12d
- **`DetalleSprint` + `comenzarSprint`** ya sirven para cualquier panel lateral con el detalle de un sprint.
- **Lista-detalle:** `_MapaConDetalle` es el patrón (dos `Expanded` con flex de Figma, panel derecho con borde izquierdo y columna centrada que se desplaza); el Buzón + Juicio (T-12d) puede seguirlo igual.
- **Escalar una pieza móvil:** `MapaSprints.escala` muestra cómo ampliar un diseño de 390 sin rehacerlo (`SizedBox` con el ancho final + `FittedBox` + `SizedBox` de 390).
- **Diálogos y hojas:** en tablet, diálogo centrado de 440 (`SelectorTamano.anchoDialogo`, `DialogoConfirmacion.anchoMaximoTablet`); las hojas laterales de 376 (`MedidasAdaptativas.hojaLateral`) quedan para T-12c.
- **Insignia:** si una acción nueva cambia el Buzón, basta invalidar `apelacionesPendientesProvider` (o `totalBuzonRielProvider`).

## Dudas
- **D1.** Ajustes vive en `lib/funciones/ajustes/`, no en `lib/funciones/perfil/` como decía la tarea; lo cambié ahí. ¿Bien?
- **D2.** Para el enlace profundo no toqué `enrutador.dart`: `PantallaIntroSprint` muestra el mapa con el detalle cuando el ancho es ≥ 960. Así, al rotar o cambiar el tamaño de la ventana se pasa de una vista a otra sin navegar. ¿Te parece bien o prefieres que lo decida la ruta?
- **D3.** En la vista combinada, ¿el globo debería volver? Hoy no está (Figma deja su lugar vacío) y su lugar se conserva.
- **D4.** "Progreso por módulo" usa el porcentaje de sprints completados (Ana: 40 % en el módulo 1). Figma dice 60 %. ¿El porcentaje debería venir del servidor o contar el sprint en curso?
- **D5.** El consejo de la Tienda es fijo (texto de Figma). ¿Debería cambiar según el inventario o los artículos?
