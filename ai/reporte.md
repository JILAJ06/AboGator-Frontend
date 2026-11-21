# Reporte
- **Tarea:** T-12 · Base de tablet: clases de pantalla, riel de navegación, acceso, onboarding e Inicio
- **Rama:** `12-tablet`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11. **Sin dependencias nuevas.**
- **Comparé contra Figma** con el conector (solo lectura): riel `93:525`, T01 `94:26`, T02 `94:86`, T03 `94:132`, T03b `94:252`, T04 `94:390`, T05 `94:456`, T06 `94:539` y T07 `96:298` (con sus tarjetas `96:543`, `96:564` y `96:578`).
- **Prueba en el navegador** (web compilada, 1194×834 y 834×1194, claro y oscuro, cuenta de prueba del mock en localhost): Splash, onboarding, inicio de sesión, registro e Inicio coinciden con Figma. Ahí encontré y corregí que la ilustración del onboarding no crecía (el `Stack` del `AnimatedSwitcher` daba restricciones sueltas al `FittedBox`).

## Qué se hizo
1. **Infraestructura (`lib/core/adaptativo/clase_pantalla.dart`):**
   - `ClasePantalla` por ancho: `movil` (< 600), `tablet` (600–959) y `ancho` (≥ 960), con `esTablet` y `esAncho`.
   - `MedidasAdaptativas`: margen 32, medianil 24, riel 104, columna 470, hoja lateral 376 y una columna de máx. 640.
   - `context.clasePantalla` (ancho de la ventana) y el widget `Adaptativo` (ancho **disponible**, para paneles).
   - `AmbitoClasePantalla`: publica la clase del ancho real que recibe la app. Va en el `builder` de `app.dart` (ver D1).
   - Ayudante de pruebas `test/ayudantes/tamano_pantalla.dart`: `tamanoPantalla(tester, Tamano.tabletHorizontal / tabletVertical / tabletMinima / movil)` (1194×834, 834×1194, 600×960 y 390×844).
2. **Riel de navegación (`RielNavegacion`)** con las medidas de Figma: 104 de ancho, isotipo de 56, destinos de 80×72 con indicador de 56×32, insignia del Buzón de 20 en (50, 8) con "99+", Ajustes y avatar de 48 abajo. Activo: `fondoDestacado`, etiqueta Inter SemiBold 12 y `selected`; inactivo: Inter Medium 11 en `textoSecundario`. Si no cabe en alto, se desplaza.
3. **`MarcoPrincipal`:** en tablet pinta `Row(riel, cuerpo)` sin barra inferior ni botón flotante; reutiliza `irAPestana`. La insignia usa el total que trae la pantalla (Inicio y Mapa) o `totalBuzonRielProvider` (Buzón, Tienda y Perfil). En móvil el código es el mismo de antes.
4. **01 Splash:** logo y lema × 1.45 (469.4 y 435, lema 20.3/29), puntos de 12 con hueco de 9.6 y "Powered by" 68 bajo los puntos.
5. **02 a 04 Onboarding:** panel de `fondoSuperficie` (mitad, hasta 597) con la ilustración del móvil × 1.55 (círculo de 465) y la columna de 470 a la derecha: título H1 y texto alineados a la izquierda, separación 20, 48 antes del paginador, botón a todo el ancho y "Omitir" arriba a la derecha.
6. **05 Inicio de sesión:** `PanelMarca` (verde fijo, círculo de 520 al 6 % en (260, 388), logo de 400, Sarko alegre de 288 y lema) y el formulario en 470 con separación 16 y separador a todo el ancho. Los campos se comparten con el móvil.
7. **06 Registro:** `PanelMarca` variante registro (círculo en (−180, −152), logo de 320 en (64, 64), frase en H2 blanca, texto en crema y Sarko sorprendido de 240 abajo a la derecha), botón atrás arriba (4 antes de la columna) y el mismo formulario, que también se comparte con el móvil.
8. **07 Inicio (y 07b):**
   - Dos columnas (620 y 382, proporcionales si la ventana es menor de 1194): héroe de 620×200 (`MedidasHeroe.tablet`), "Ruta de tu Startup" y los módulos en 2 × 300 con separación 20; a la derecha reto, **Tu semana**, **Buzón** y el **consejo de Sarko** con Sarko de 120×150 al fondo.
   - Componentes nuevos: `TarjetaSemana`, `TarjetaBuzonInicio` y `TarjetaConsejoSarko`. `LogicaInicio.consejo` arma el consejo y `precisionInicioProvider` trae la precisión del Perfil.
   - Carga, error con reintento y sin datos se mantienen.
9. **Galería:** sección "Componentes de tablet" con el riel y las tres tarjetas en sus estados.

## Medidas que tomé de Figma (no venían en la tarea)
- **Riel:** activo con ícono `textoPrimario`; inactivo con ícono `textoSecundario`. Insignia en Leyenda.
- **T01 Splash:** logo vertical de 469.4 (isotipo 158.7 + marca 469.4 × 95.2), lema Inter SemiBold 20.3/29 en `#E8D8A8`, ancho 435; puntos de 12 con hueco 9.6 en y 648; "Powered by LawSwipe" en y 728.
- **T02 a T04:** panel `fondo/superficie` de 597; círculo `#E8D8A8` al 70 % de 465 (el mismo `fondoDestacado` del móvil); contenido en una columna de 470 en x 661 con separación 20, título Fredoka Bold 26/32, texto Inter 16/24 en `textoSecundario`, un espacio de 8 antes del paginador y botón primario a todo el ancho; "Omitir" Inter SemiBold 14 en `textoSecundario`, termina en x 1162.
- **T05:** el círculo es blanco al 6 % sobre el verde (`#1F4E35`); lema Inter SemiBold 14/20 en una línea.
- **T06:** círculo de 520 en (−180, −120 − 32); logo horizontal de 320; frase «Más vale prevenir que litigar.» Fredoka SemiBold 20/26 en blanco en (64, 198); texto "Crea tu perfil y Sarko ajustará la dificultad de cada sprint a tu experiencia." Inter 16/24 en `#E8D8A8` en (64, 240), ancho 469; Sarko **sorprendido** de 240×300 en (317, 472); botón atrás de 48 en (657, 16); columna en y 143 con separación 14.
- **T07:** Tu semana con relleno 20 y separación 12; estadísticas de `fondoSuperficieAlt` con relleno 12, separación 4; íconos flame y coin en `accionAcento` y check en `accionPrimaria`. Consejo con relleno 16 y separación 4.

## Decisiones propias (no vienen de Figma)
- **Tablet vertical (600 a 959):** riel y una sola columna. El Inicio se centra con máximo 640; el acceso lleva arriba una **franja de marca de 240** (logo de 300 y Sarko de 168) y debajo el formulario de 470; el onboarding pone la ilustración × 1.2 arriba y la columna debajo.
- **Ventanas entre 960 y 1194:** las columnas del Inicio se reparten en proporción 620:382; el panel de marca y el del onboarding miden la mitad de la ventana (hasta 597) y su contenido se reduce en la misma proporción (los textos no).
- **Onboarding en tablet sin `PageView`:** las páginas cambian con un fundido de 250 ms (ninguno con "Reducir animaciones"); no hay deslizamiento lateral. Siguen "Omitir", el paginador y el botón.
- **La ilustración del onboarding** es la del móvil escalada y centrada en el panel; en Figma cada página la centra según su propio contenido, así que el círculo queda hasta ~26 px más arriba o abajo que en Figma según la página.
- **Formulario de 05 y 06:** los huecos de 06 son los del móvil (6, 16, 12, 14…); Figma usa 14 en casi todos.
- **Buzón sin apelaciones:** "No tienes apelaciones pendientes." y **sin botón** (el riel sigue llevando al Buzón).
- **Consejo de Sarko:** usa el tramo del **módulo siguiente** con su artículo ("la Ronda Semilla"), como Figma, aunque el sprint en curso no sea el último del módulo. En el último módulo usa el título del sprint siguiente; sin sprint en curso, "¡Tu Startup va por buen camino! Sigue practicando." (ver D2).
- **Sin sprint en curso:** no hay tarjeta héroe (como en móvil) y "Ruta de tu Startup" sube.
- **Consejo y Sarko al fondo:** la columna derecha llega al menos hasta el borde inferior (menos 24) para que el consejo quede abajo como en Figma; si no cabe, fluye al final.
- **Héroe de tablet:** Sarko se oculta si la tarjeta mide menos de 596 de ancho (para que no quede cortado).
- **Panel de registro:** Sarko se oculta si el panel mide menos de 600 de alto.
- **Avatar del riel:** se anuncia "Perfil de Ana López" y lleva al Perfil.
- **Rotar a mitad del onboarding:** si la ventana pasa de tablet a móvil, el `PageView` se crea en la página en la que iba.

## Accesibilidad
- **Riel:** contenedor "Navegación principal"; cada destino es un botón con su nombre y `selected` en el activo; el Buzón se anuncia "Buzón, 6 apelaciones pendientes" (1: "1 apelación pendiente"); Ajustes "Ajustes de accesibilidad". Objetivos de 80×72 y 48×48.
- **Orden de foco:** riel primero (destinos → Ajustes → avatar) y luego el contenido. En el Inicio: héroe → módulos → Buzón (orden explícito, igual en una columna).
- **Tu semana:** cada estadística se lee como "Precisión: 82%" ("Precisión: sin datos" si falla).
- **Contrastes AA verificados en pruebas:** etiquetas del riel (`textoPrimario` sobre `fondoDestacado`, `textoSecundario` y `textoPrimario` sobre `fondoSuperficie`), `textoEnPrimario` sobre `estadoIlegal` (insignia), y `#E8D8A8` y blanco sobre el verde del panel (también con el círculo encima), en claro y oscuro.
- **Sin desbordes** en 1194×834, 834×1194 y 600×960 al 100 % y 200 %, en claro y oscuro (Inicio), y en las tres medidas al 100 % y 200 % para acceso, Splash y onboarding. Con texto grande, Tu semana apila sus estadísticas y la rejilla de módulos pasa a una columna.
- "Reducir animaciones", háptica, "solo botones" y el tamaño de texto de la T-10b se respetan igual (el `builder` de la app los sigue aplicando antes del ámbito).

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test` (1116 pruebas; antes de T-12, 1025):
```
+1116: All tests passed!
```
- **Pruebas nuevas (91):**
  - `clase_pantalla_test.dart`: 390/599/600/959/960/1194, medidas, `Adaptativo` con el ancho disponible y la extensión;
  - `riel_navegacion_test.dart`: medidas, activo, insignia (0, 1, 6, 99, 100 → "99+", sin dato), posición de la insignia, toques, Tab y Enter, colores del tema y contraste en claro/oscuro, 200 %;
  - `inicio_tablet_test.dart`: riel sin barra ni botón flotante, posiciones de Figma, consejo al fondo, Tu semana y "—", Buzón con 6 y 0, consejo general, navegación del riel (Buzón, Tienda, Perfil, Ajustes y Mapa), Mapa con riel, una columna en 834 y 600, sin desbordes (3 tamaños × 100/200 % × claro/oscuro), lógica del consejo y móvil sin cambios;
  - `acceso_tablet_test.dart`: panel y columna de 470, logo, Sarko, lema y círculo, formulario (errores, Enter, sesión), consentimientos separados, botón atrás, franja vertical, sin desbordes y contraste del panel;
  - `bienvenida_tablet_test.dart`: Splash de tablet y de móvil, panel con la ilustración × 1.55, columna, Omitir, las 4 páginas, reducir animaciones, vertical, sin desbordes y el paso de tablet a móvil a mitad del onboarding.
- **Ajustes en pruebas existentes:** solo la galería (22 botones, 24 logos y tocar "Perfil" dentro de la navegación inferior, porque el riel de la galería también dice "Perfil"). **Ninguna prueba cambió de tamaño.**

## Grafo
- **Actualizados (`en curso`):** APP, MARCO-PRINCIPAL, TEMA-EFECTOS, TEXTOS, PANT-GALERIA, CODIGO-PANT-01, CODIGO-PANT-02..04, CODIGO-PANT-05, CODIGO-PANT-06, LOGICA-INICIO, EST-INICIO, CODIGO-PANT-07, COMP-HEROE, TEST-GALERIA y TEST-AYUDA.
- **Nuevos:** ADAPTATIVO, COMP-RIEL, COMP-SEMANA, COMP-BUZON-INICIO, COMP-CONSEJO, PANEL-MARCA, TEST-ADAPTATIVO, TEST-TABLET, DEC-CLASE-PANTALLA y DEC-TABLET-VERTICAL.
- PANT-01 a PANT-07b anotan que su vista de tablet vive en el mismo archivo.
- **Obsoletos:** ninguno. Agregué una línea en el registro de cambios.

## Para T-12b, c y d
- **Clase de pantalla:** `context.clasePantalla` (`esTablet`, `esAncho`) para decidir la composición de una pantalla completa; `Adaptativo` dentro de paneles o columnas. No uses `MediaQuery.size` (ver D1).
- **Medidas:** `MedidasAdaptativas.margen`, `medianil`, `riel`, `columnaFormulario` (470), `hojaLateral` (376) y `contenidoUnaColumna` (640).
- **`MarcoPrincipal`** ya pinta el riel en Inicio, Mapa, Buzón, Tienda y Perfil. En tablet no hay botón Buzón ni barra inferior, así que las pantallas pueden dejar de reservar `MarcoPrincipal.reservaBuzon` cuando `MarcoPrincipal.conRiel(context)` sea `true` (hoy Mapa, Buzón, Tienda y Perfil siguen reservando ese espacio al final; no se nota, pero sobra). Para refrescar la insignia después de un juicio: `ref.invalidate(totalBuzonRielProvider)`.
- **Pruebas:** `tamanoPantalla(tester, Tamano.tabletHorizontal)` (y `tabletVertical`, `tabletMinima`, `movil`); los ayudantes existentes (`abrirInicio`, `abrirEn`, `montarApp`) ya aceptan `tamano`.
- **Componentes reutilizables:** `PanelMarca`/`DisposicionAccesoTablet` (panel + columna de 470) y `MedidasHeroe` como ejemplo de parametrizar medidas sin duplicar un componente.
- Ajustes (`/perfil/ajustes`) no usa `MarcoPrincipal`, así que en tablet se ve sin riel (le toca a T-12b).

## Dudas
- **D1.** Para que las pruebas existentes siguieran en móvil sin cambiar su tamaño, la clase de pantalla sale del ancho real que recibe la app (un `LayoutBuilder` en el `builder` de `MaterialApp`), no de `MediaQuery`: en las pruebas, `setSurfaceSize` no cambia `MediaQuery` (sigue en 800×600). Esto tocó `lib/app/app.dart`, que no estaba en los archivos permitidos (una línea). ¿Está bien así?
- **D2.** El consejo de Sarko: Figma dice "Termina el Sprint 3 hoy y desbloquea la Ronda Semilla", pero terminar el Sprint 3 desbloquea el Sprint 4, no el módulo 2. Lo dejé como Figma (tramo del módulo siguiente). ¿Prefieres que nombre el sprint siguiente ("Derechos ARCO") salvo en el último sprint del módulo?
- **D3.** En tablet el onboarding no se puede deslizar (no hay `PageView`, solo los botones). ¿Agrego el gesto de deslizar?
- **D4.** Con 0 apelaciones oculté el botón "Abrir Buzón" de la tarjeta del Inicio. ¿Lo prefieres deshabilitado y visible?
