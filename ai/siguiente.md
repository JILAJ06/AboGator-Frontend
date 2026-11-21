# T-12 · Base de tablet: clases de pantalla, riel de navegación, acceso, onboarding e Inicio

**Rama:** `12-tablet` (ya creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-12**).
**Figma** (archivo `SYNAyUal3xVk4k8SEBEb7f`, páginas "Tablet · Vistas" `94:23` y "Tablet · Navegación" `103:23`). La tablet son **41 vistas**, así que se divide en cuatro tareas: **T-12** (esta: base, acceso, onboarding e Inicio), **T-12b** (mapa + intro, Tienda, Perfil, Ajustes), **T-12c** (juego y hojas laterales) y **T-12d** (Sin vidas, Buzón + Juicio, offline y Examen).

## Objetivo
Que la app se adapte a tablet **sin duplicar pantallas**: los mismos componentes, tokens (claro y oscuro), Sarko y logos; solo cambia la distribución. Esta tarea deja la **infraestructura** que usarán T-12b, c y d y las vistas más sencillas: acceso, onboarding e Inicio.

## Reglas de adaptación (Figma `106:10163`)
- **Lienzo:** iPad 11" horizontal, **1194 × 834 dp**. Rejilla de 12 columnas, **margen 32, medianil 24**. La barra de estado de 32 dp que se ve en Figma es del sistema: **no se dibuja**; todas las posiciones de abajo ya la restan (`y` relativa al contenido de la app) salvo que se diga lo contrario.
- **Navegación:** la barra inferior se convierte en un **riel lateral de 104 dp** (componente "Riel de navegación"). El Buzón siempre muestra su contador, así que **el botón flotante del Buzón desaparece** en tablet.
- **Listas-detalle** (08+09 y 21+22), **zona de juego + panel lateral**, **hojas laterales de 376** y **pantallas de resultado con Sarko a la izquierda y columna de 470**: las hacen T-12b, c y d. **Esta tarea solo deja los ayudantes para ellas** (ver "Infraestructura").
- Mismos criterios de accesibilidad WCAG 2.1 AA, objetivos ≥ 48 y alternativa de un toque al swipe.

## Infraestructura (`lib/core/adaptativo/`)
- **`ClasePantalla`** por **ancho de la ventana** (no por tipo de dispositivo; sirve en web, split-view y rotación): `movil` (< 600), `tablet` (≥ 600) y, dentro de tablet, `ancho` (≥ 960) para las composiciones de dos columnas de Figma. Entre 600 y 959 (tablet en vertical, ventana angosta) se usa el **riel con una sola columna** de contenido, centrado con ancho máximo (Figma solo dibuja horizontal; esto lo decides tú y lo reportas).
- Un `BuildContext.clasePantalla` (extensión) y un widget **`Adaptativo`** (o `LayoutBuilder` envuelto) que decide con el ancho **disponible**, no con `MediaQuery.size`, para que funcione dentro de paneles.
- Constantes: margen 32, medianil 24, riel 104, columna de formulario 470, hoja lateral 376. Sin números sueltos en las pantallas.
- **Móvil no cambia nada:** a < 600 las pantallas se ven exactamente como hoy. Las 1025 pruebas actuales siguen verdes sin tocar su tamaño.
- Una prueba ayudante `tamanoPantalla(tester, Tamano.tabletHorizontal / tabletVertical / movil)` para T-12b, c y d (1194×834, 834×1194, 390×844).

## Riel de navegación (en `MarcoPrincipal`)
`MarcoPrincipal` es el único lugar que cambia: con `tablet` pinta `Row(riel, cuerpo)` y **sin** la navegación inferior ni `BotonBuzon`; con `movil`, igual que hoy. Todas las pantallas que lo usan (Inicio, Mapa, Buzón, Tienda y Perfil) heredan el riel sin cambios propios.
- **`RielNavegacion`** (Figma `93:525`, instancia `93:331`): ancho **104**, alto todo el espacio, `fondoSuperficie`, borde derecho 1 `bordeDefault`, columna centrada, separación 8, relleno vertical 24.
  1. **Isotipo** 56 (logo, decorativo).
  2. Separador de 24.
  3. **Destinos** Mapa, Buzón, Tienda, Perfil, cada uno de **80 × 72**: indicador de **56 × 32** radio 16 con ícono 24 y etiqueta debajo (separación 4). **Activo:** indicador `fondoDestacado`, etiqueta Inter SemiBold 12 `textoPrimario`; **inactivo:** sin fondo, etiqueta Inter Medium 11 `textoSecundario`. El activo no depende solo del color: etiqueta en negrita y `Semantics(selected: true)`.
  4. **Insignia del Buzón:** círculo 20 `estadoIlegal` con el número en `textoEnPrimario` (Leyenda), a 50 px del borde izquierdo del destino y 8 del superior. Cantidad = `total` del Buzón (la misma que usa el botón flotante); se oculta con 0; con más de 99 muestra "99+".
  5. Espacio flexible.
  6. **Ajustes:** círculo 48, borde 1 `bordeDefault`, ícono `settings` 22 → `/perfil/ajustes`.
  7. **Avatar:** círculo 48 `fondoDestacado`, iniciales Inter SemiBold 14 `textoPrimario` → Perfil.
- Destinos y rutas: los mismos que la navegación inferior (`PestanaApp`); reutiliza su lógica de navegación, no la dupliques.
- **Accesibilidad:** `Semantics` de contenedor "Navegación principal"; cada destino con etiqueta, "seleccionado" y, el Buzón, "N apelaciones pendientes". Orden de foco: **riel primero** (izquierda a derecha, arriba abajo) y luego el contenido; Tab recorre destinos → Ajustes → Avatar. Objetivos ≥ 48 (el destino mide 80×72). Sin animaciones nuevas.
- Se ve igual en claro y oscuro por tokens.

## Acceso y onboarding (T01 a T06)
Misma lógica, estado y validaciones que 01 a 06; solo cambia la composición. Compáralas con el conector: las mediciones de las que no se detallan aquí las tomas tú de Figma y **las dejas en el reporte**.
- **T05 Inicio de sesión (`94:456`) — medidas completas:**
  - **Panel de marca** a la izquierda: **597** de ancho, alto completo, fondo verde bosque (`marca/verde-bosque-gator`, el mismo `#1F4E35` de `accionPrimaria` en claro; **fijo en oscuro también**, como Figma), recortado.
    - Círculo decorativo de 520 en (260, 420) con el color del fondo del panel más claro (toma el color de `94:469`).
    - **Logo horizontal** sobre verde: isotipo 96.97 + marca nominativa 286.87 × 58.18 (separación 16.16) en (98.5, 140 − 32).
    - **Sarko** (pose alegre, recortado como en el resto de la app) de 288 × 360 en (154.5, 290 − 32).
    - Lema "Educación en Legislación y Derecho Informático": Inter SemiBold 14, `#E8D8A8`, centrado, ancho 477, en y = 680 − 32.
  - **Contenido** a la derecha: columna de **470** centrada en la mitad derecha (x ≈ 661), alineada al centro vertical (en Figma queda a y = 168); separación 16. Es el mismo formulario del móvil (título "Bienvenido de vuelta", subtítulo "Continúa tu racha de 7 días", campos, "¿Olvidaste tu contraseña?", botón primario, separador "o", "Crear una cuenta" secundario y la nota de conexión cifrada) con **todos los controles a ancho completo de la columna**.
  - Sin panel de marca en `movil`. En tablet **vertical** (600–959) el panel pasa **arriba** como una franja de 240 con el logo y Sarko y el formulario debajo, centrado en 470.
- **T06 Registro (`94:539`), T01 Splash (`94:26`), T02 (`94:86`), T03 (`94:132`), T03b (`94:252`) y T04 (`94:390`):** léelas con el conector. Lo habitual: el mismo panel de marca o la ilustración a la izquierda y la columna de 470 a la derecha; el Splash centrado. Si alguna no usa ese patrón, impleméntala como Figma y repórtalo. Onboarding conserva "Omitir", el paginador de puntos y el comportamiento de la T-02; Registro conserva los **dos consentimientos separados** y el orden de foco por error de la T-03.
- Teclado en tablet: Tab y Enter envían el formulario como hoy; la columna se desplaza si el teclado o el texto al 200 % no caben.

## Inicio (T07 `96:298`; T07b `96:885` es el mismo en modo oscuro)
Dentro de `MarcoPrincipal` (riel). `ClasePantalla.ancho`: **dos columnas**; entre 600 y 959: **una columna** (la derecha debajo de la izquierda). Posiciones de Figma, con `x` 136 = riel 104 + margen 32 y `y` menos 32:
- **Encabezado** (y 52 − 32): avatar 44 `fondoDestacado` con iniciales Fredoka SemiBold 17 `accionSecundaria` en x 136; "Hola, Ana" (Fredoka SemiBold 17 `textoPrimario`) y "Dev · Nivel 4" (Leyenda `textoSecundario`) a su derecha; a la derecha del todo, **HUD** con tres chips (racha, monedas, vidas) separados 6, terminando en x = 1162 (margen 32).
- **Columna izquierda** (x 136, ancho **620**):
  - **Tarjeta héroe** 620 × 200 (y 120 − 32), radio 24, `accionPrimaria`, sombra de tarjeta; elipse decorativa de 286; "TU STARTUP ESTÁ EN" (Leyenda `textoEnPrimario`), nombre del módulo (Fredoka Bold 26/32, ancho 200), "Sprint 3 de 5 · Protección de datos", botón "Continuar sprint" (`accionAcento`, alto 48, radio 12) y Sarko 150 × 187.5 en (446, 16.5). Es la tarjeta héroe de 04 con ancho 620 (parametriza el ancho, no la dupliques).
  - Título "Ruta de tu Startup" (Fredoka SemiBold 20/26) en y 346 − 32.
  - **Módulos** en **2 columnas** de **300** con separación 20 (ancho total 620), desde y 386 − 32. Es la `TarjetaModulo` de 04 con ancho 300. Los 5 módulos se muestran (Figma dibuja 4; el 5.º sigue la misma regla) y la columna se desplaza con la página.
- **Columna derecha** (x 780, ancho **382**, termina en el margen 32):
  - **Reto diario** (y 120 − 32): `TarjetaRetoDiario` de 04 con ancho 382 ("Reto diario: 3 tarjetas sin fallar", "Mantén tu racha de 7 días · +15 monedas", "1/3").
  - **Tu semana** (nuevo, y 200 − 32): tarjeta `fondoSuperficie`, borde 1 `bordeDefault`, radio 20, padding 20, separación 12; título "Tu semana" (Fredoka SemiBold 17) y **tres estadísticas** iguales (`fondoSuperficieAlt`, radio 14, padding 12, ícono 20, valor Fredoka SemiBold 17, etiqueta Leyenda `textoSecundario`): Racha "7 días" (ícono `flame`), Precisión "82%" (`check`) y Monedas "240" (`coin`). Datos: racha del usuario, precisión de `RepositorioPerfil.obtenerPerfil()` y monedas de la tienda; si el Perfil falla o carga, "—" en Precisión sin romper la pantalla.
  - **Buzón de Apelaciones** (y 380 − 32): `fondoDestacado`, radio 20, padding 20, separación 12; ícono `inbox` 24 + "Buzón de Apelaciones" (Fredoka SemiBold 17), texto "N tarjetas falladas esperan juicio. Gánalas para recuperar vidas." (Cuerpo `textoSecundario`) y botón secundario "Abrir Buzón (N)" a ancho completo → Buzón. Con 0 apelaciones: texto "No tienes apelaciones pendientes." y botón deshabilitado/oculto (decide y reporta). Aquí **sí** se queda el botón porque es una tarjeta, no el botón flotante.
  - **Consejo de Sarko** (y 700 − 32, ancho 252): tarjeta `fondoSuperficie`, borde 1, radio 20, padding 16; "CONSEJO DE SARKO" (Leyenda `textoAcento`) y el consejo (Cuerpo `textoPrimario`): "Termina el Sprint N hoy y desbloquea <nombre del módulo siguiente o del sprint siguiente>." (se arma con el sprint en curso; sin sprint en curso, "¡Tu Startup va por buen camino! Sigue practicando."). A su derecha, **Sarko** 120 × 150 en (1041, 660 − 32) como adorno (decorativo). Si no cabe en alto, el consejo y Sarko fluyen al final de la columna.
- Estados de **carga**, **error con reintento** y **sin datos** del Inicio actual se mantienen (en tablet, a ancho de contenido). Los textos nuevos van a `Textos`.
- **Orden de foco:** riel → encabezado → héroe → módulos → reto → semana → Buzón → consejo. En una columna (600–959) el mismo orden.

## Accesibilidad
- Texto al 200 % sin desbordes en **1194×834, 834×1194 y 600×960**, claro y oscuro: las filas se parten en columna y la pantalla se desplaza; el riel no se desborda (con texto grande las etiquetas pueden ocupar dos líneas, el destino crece en alto).
- Contrastes AA verificados en pruebas: `textoPrimario` y `textoSecundario` sobre `fondoDestacado`, `#E8D8A8` sobre el verde del panel de marca, `textoEnPrimario` sobre `estadoIlegal` (insignia), etiqueta activa e inactiva del riel.
- "Solo botones", "Reducir animaciones", háptica y los demás ajustes de la T-10b se respetan igual.
- Navegación solo con teclado: se puede llegar a todo con Tab, el destino activo se identifica sin color.

## Archivos permitidos
`lib/core/adaptativo/` (nuevo), `lib/app/marco_principal.dart`, `lib/componentes/` (`RielNavegacion`, `TarjetaSemana`, `TarjetaConsejoSarko`, `TarjetaBuzonInicio`, ajustes de ancho en `TarjetaHeroeStartup`, `TarjetaModulo`, `TarjetaRetoDiario`, `LogoApp` y `ChipHud` si hace falta), `lib/funciones/bienvenida/` (Splash y onboarding), `lib/funciones/acceso/` (05 y 06), `lib/funciones/inicio/`, `lib/core/tema/efectos.dart` (verde del panel y círculo si no son tokens), `iconos_app.dart`, `lib/core/textos/textos.dart`, la galería, pruebas y documentación de `ai/` (grafo sección 4, reporte). **No toques** juego, mapa, Tienda, Perfil, Buzón ni examen más allá de lo que hereden de `MarcoPrincipal` (el riel); si algo de eso se rompe con el riel, lo arreglas aquí y lo reportas. **Sin dependencias nuevas.**

## Pruebas
- **ClasePantalla:** 390 → móvil, 599 → móvil, 600 → tablet, 959 → tablet no ancho, 960 → ancho; usa el ancho disponible, no el de la ventana.
- **Riel:** estructura y medidas de Figma, destino activo y semántica, insignia (0, 6, 100 → "99+"), navegación a cada destino, Ajustes y Avatar, no hay botón flotante en tablet y sí en móvil, claro y oscuro, texto al 200 %.
- **MarcoPrincipal:** móvil idéntico al actual (las pruebas existentes siguen verdes sin cambios de tamaño); tablet con riel en Inicio, Mapa, Buzón, Tienda y Perfil.
- **05, 06, 01 a 04 en tablet:** panel de marca y columna de 470 (medidas de T05), formulario funcional (validaciones, errores por campo, consentimientos), Splash y onboarding con "Omitir" y paginador, vertical 834×1194 con franja superior, sin desbordes (1194×834, 834×1194, 600×960 al 100 % y 200 %).
- **Inicio:** 2 columnas a 1194 y 1 columna a 834; posiciones y tamaños de la tabla de arriba; módulos de 300 en 2 columnas; "Tu semana" con datos reales y "—" cuando el Perfil falla; Buzón con N y con 0; consejo con y sin sprint en curso; carga, error y reintento; claro y oscuro (T07b).
- La galería suma el riel y las tarjetas nuevas; `TEST-GALERIA` actualiza su cuenta.
- Las 1025 pruebas previas siguen verdes.

## Criterios de aceptación
- [ ] En móvil la app se ve idéntica a hoy; a ≥ 600 aparece el riel en lugar de la barra inferior y desaparece el botón flotante del Buzón.
- [ ] 01 a 06 e Inicio (claro y oscuro) coinciden con Figma en 1194×834; en 834×1194 y 600×960 se ven bien en una columna sin desbordes.
- [ ] Lo que no viene de Figma (tablet vertical, estados de carga y error, Buzón sin apelaciones, consejo sin sprint, "99+") queda en el reporte, igual que las medidas que tomaste tú del conector.
- [ ] `ClasePantalla` y la prueba ayudante quedan listas para T-12b, c y d.
- [ ] Sin dependencias nuevas; análisis, formato y pruebas en verde; commits sin prefijo y sin menciones a Claude.

## Para el reporte
Dudas numeradas (D1, D2…), decisiones propias, las medidas que tomaste de Figma para T01–T04 y T06, y una nota para T-12b, c y d con lo que `MarcoPrincipal` y los ayudantes ya ofrecen.
