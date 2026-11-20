# T-09 · Buzón de Apelaciones y notificación

**Rama:** `09-apelaciones` (ya creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-09**).
**Pantallas:** 21 Buzón de Apelaciones y 21b Notificación de apelación. Figma (archivo `SYNAyUal3xVk4k8SEBEb7f`): 21 = `41:5631`, 21b = `41:5499`. Compara en Chrome con el conector.
**Se divide en dos:** esta tarea hace el Buzón, el registro de fallos y la notificación. El **juicio (22) y la apelación ganada (22b)** son la **T-09b**; aquí las filas del Buzón abren la ruta del juicio, que sigue siendo un marcador.

## Objetivo
1. **Registrar los fallos:** las tarjetas falladas en un sprint llegan al Buzón (hasta hoy solo se contaban).
2. **Buzón (21):** pantalla real con la lista de apelaciones, cuáles se pueden hacer hoy y cuándo se abren las demás, calculado con la **fecha del servidor**.
3. **Notificación (21b):** es una notificación del sistema (pantalla de bloqueo), no una pantalla de la app. Aquí se construyen su texto, su componente visual (para la galería) y el **enlace profundo** que abre el juicio. El envío real de notificaciones llega con el backend (T-14).

## Datos
### Modelo y repositorio (`Apelacion`, `RepositorioApelaciones`, `MockApelaciones`)
- `Apelacion` suma: `moduloId` (para el color de la franja), `tema` (p. ej. "Licencias OSS") y reemplaza `resumen` por `titulo` (p. ej. "Librería GPL en app cerrada"). Se conservan `id`, `tarjetaId`, `diaRepaso` (3, 7 o 14) y `disponibleEl`.
- `RepositorioApelaciones`:
  - `Future<BuzonApelaciones> obtenerBuzon()` reemplaza `obtenerApelacionesPendientes()`. `BuzonApelaciones` lleva `ahoraServidor` y `apelaciones` (ordenadas: primero las disponibles hoy, luego las futuras por fecha) y expone `deHoy` (las de `disponibleEl` ≤ fin del día de `ahoraServidor`; una vencida cuenta como de hoy) y `total`.
  - `Future<void> registrarFallos(List<NuevaApelacion> fallos)`. `NuevaApelacion`: `tarjetaId`, `moduloId`, `titulo`, `tema`. Crea una apelación de **día 3** con `disponibleEl = ahoraServidor + 3 días` por cada tarjeta que **no** esté ya en el Buzón (sin duplicar por `tarjetaId`).
- `MockApelaciones`: estado en memoria por instancia y reloj inyectable `ahoraServidor` (por defecto `DateTime.now`; es el mock quien hace de servidor). Semilla de **6** apelaciones relativas a ese reloj, con las dos primeras como en Figma 21: (1) "Librería GPL en app cerrada" · Licencias OSS · día 3 · **hoy**; (2) una de consentimiento (usa una tarjeta existente; Figma: "Casilla de consentimiento pre-marcada" · Protección de datos) · día 7 · **hoy**; (3) día 3 · **mañana**; (4) día 7 · **en 2 días**; (5) y (6) día 14 en fechas posteriores. Usa `tarjetaId` que existan en `MockTarjetas` y `moduloId` que existan en el mock de progreso.
- `RepositorioTarjetas.obtenerTarjeta(String id)` (nuevo; `StateError` si no existe) para que T-09b abra la tarjeta de una apelación. Impleméntalo en `MockTarjetas`.
### Tarjeta (`tarjeta.dart`)
- Campos opcionales nuevos: `titulo` (≤ 45 caracteres, lo que se ve en el Buzón) y `tema` (corto, p. ej. "Consentimiento", "Derechos ARCO", "Brechas de seguridad", "Aviso de privacidad", "Licencias OSS"). Dales valor a **las 42 tarjetas** del módulo 1. Sin cifras, plazos ni números de artículo (la prueba de cifras debe revisar también estos textos). Si falta `titulo`, el respaldo es el comienzo del `texto` cortado en 45 con "…".
### Registro de fallos al terminar el sprint
- En `JuegoNotifier.guardarResultado()` (una sola vez, en los **tres** finales: sprint completado, quiebra y sin vidas) llama a `registrarFallos` con las tarjetas de `state.falladas` (las que ya cuenta hoy; no cambies qué es un fallo). Si el jugador sale a la mitad del sprint con "Salir", no se registran (el avance se descarta como hoy). Anótalo en el reporte.
- Después de registrar, invalida los proveedores que leen el Buzón (Inicio, Mapa, pantalla 20) para que los contadores se actualicen.
- Semántica de los contadores: el botón Buzón de Inicio y Mapa sigue mostrando el **total** del Buzón (`total`). La pantalla 20 y el encabezado del Buzón usan las **de hoy** (`deHoy`): Figma las muestra como "2". Actualiza la pantalla 20 (T-08) y sus pruebas.
### Textos de la notificación
`Textos.notificacionApelacionTitulo` = "⚖️ Tienes un juicio de apelación pendiente" y `Textos.notificacionApelacionCuerpo(titulo, dias)` = "Hace {dias} días fallaste “{titulo}”. Gánala y recupera 1 vida." (con las comillas tipográficas). Pie de la maqueta: "Toca para abrir el juicio de apelación".

## 21 · Buzón de Apelaciones (pestaña con navegación inferior, activa "Buzón")
Usa `MarcoPrincipal(pestana: buzon)` **sin** el botón Buzón flotante. Medidas del marco 390×844; en código, columna desplazable con estas separaciones y el botón fijo.
- **Título** (24,60): "Buzón de Apelaciones", Fredoka Bold 26/32 `textoPrimario`, ancho 260. **Subtítulo** (24,96): "Tus fallos regresan a los 3 y 7 días para que no se te olviden." Cuerpo/Base `textoSecundario`, ancho 230.
- **Sarko** 104×130 en (262,50) (recortado como Figma). La pose es la de Figma `41:5645`; compárala con el conector y, si no se distingue, usa alegre.
- **Recompensa** (24,180; ancho 342): `fondoDestacado`, radio 18, relleno 14×12, separación 12. Cuadrado 40 `estadoIlegal` radio 12 con `heart` 22 `textoEnPrimario`; textos: "N juicios de apelación hoy" (Cuerpo/Énfasis `textoPrimario`; singular "1 juicio de apelación hoy") y "Gana cada apelación y recupera 1 vida" (Leyenda `textoSecundario`). Con 0 de hoy: "Hoy no tienes juicios de apelación" y "Tus próximas apelaciones aparecen abajo" (con la lista vacía: ver estado vacío).
- **Lista** (24,256; ancho 342): contenedor `fondoSuperficie`, borde 1 `bordeDefault`, radio 20, recortado; filas con divisor inferior 1 `bordeDefault` (todas menos la última).
  - **Fila** (relleno 14×12, separación 12): franja de 6×40 radio 3 en el color del módulo (`Modulo.color` por `moduloId`; si no se conoce, `bordeControl`); columna (separación 3, ocupa el resto): `titulo` (Cuerpo/Énfasis `textoPrimario`, hasta 2 líneas), `tema` (Leyenda `textoSecundario`) y la **píldora de plazo** (radio 999, relleno 8×2, separación 4); a la derecha `chevron` 18.
  - **Plazo, de hoy:** fondo `estadoIlegal`, ícono `gavel` 12 y "Día 3 · hoy · +1 vida" (Leyenda `textoEnPrimario`). **Futura:** fondo `fondoSuperficieAlt`, ícono `clock` 12 y "Día 3 · mañana" / "Día 7 · en 2 días" (Leyenda `textoSecundario`). "mañana" = día siguiente al de `ahoraServidor`; "en N días" para N ≥ 2; todo con la **fecha del servidor** (días calendario en UTC), nunca `DateTime.now()` del dispositivo.
  - **Toque:** fila de hoy → `Rutas.juicioApelacionDe(id)` (marcador "Juicio de apelación · llega en T-09b"). Fila futura → no navega: muestra un aviso (`SnackBar` con `liveRegion`) "Esta apelación se abre mañana" / "…en N días".
  - **Semántica de la fila:** "Librería GPL en app cerrada, Licencias OSS, día 3, disponible hoy, +1 vida si la ganas" (o "…disponible mañana"). Botón en las de hoy; en las futuras, botón también (da el aviso). Foco con teclado y anillo `focoAnillo`.
- **Botón primario** "Iniciar apelaciones de hoy" (24,664; 342×52) y debajo "No consume vidas · No avanza el mapa" (Leyenda `textoSecundario`, centrado, y=724): van **fijos** encima de la barra inferior. Abre la primera apelación de hoy (T-09b lo convierte en sesión). Con 0 de hoy el botón se ve **deshabilitado** (misma etiqueta).
- **Vacío** (0 apelaciones en total, no está en Figma): Sarko sorprendido, "Tu Buzón está vacío" (H1) y "Cuando falles una tarjeta, volverá aquí a los 3 y 7 días." (Cuerpo/Base). Sin botón. **Cargando:** esqueleto simple. **Error:** `MensajePantalla` con "Reintentar".
- Reemplaza `PantallaPendiente(pendienteBuzon)` y borra `Textos.pendienteBuzon`. Revisa que "Repasar mis fallos" (19) y "Ir al Buzón de Apelaciones" (19b y 20) lleven a esta pantalla.
- Accesibilidad: título como encabezado y foco inicial en él; lista leída como lista ("Lista, N apelaciones"); nada depende solo del color (la píldora lleva ícono y texto); texto al 200 % sin desbordes (las filas crecen); contraste `textoEnPrimario` sobre `estadoIlegal` ≥ 4.5:1 y `textoSecundario` sobre `fondoSuperficieAlt` en claro y oscuro (pruébalo).

## 21b · Notificación de apelación
- **Componente `NotificacionApelacion`** (para la galería y como referencia de diseño; no se muestra dentro de la app): ancho 358, fondo blanco al 88 % con desenfoque 10, radio 22, sombra (0,8) desenfoque 12 negro al 18 %, relleno 14×12, separación 12. Ícono de app: cuadrado 38, `#1F4E35`, radio 8.4, con el isotipo (reusa `LogoApp`/isotipo existente) de 31.7. Texto (separación 2): fila "ABOGATOR" / "ahora" (Leyenda `#475569`, justificada), título (Cuerpo/Énfasis `#111827`) y cuerpo (Cuerpo/Base `#111827`). Los colores propios de la notificación van en `EfectosApp` (imitan el sistema, no son tokens). Parámetros: título del caso y días (3 o 7) para el cuerpo, y la hora ("ahora", "hace 2 h").
- **Enlace profundo:** `Rutas.juicioApelacionDe(id)` (`/buzon/<id>`) con la misma redirección de sesión que las demás rutas: sin sesión → inicio de sesión. Por ahora abre el marcador de T-09b. (Cómo se conserva el destino tras iniciar sesión no está definido: anótalo en el reporte como duda si lo ves necesario.)
- **Fuera de alcance:** recibir o programar notificaciones reales (no agregues paquetes de notificaciones); el fondo de la pantalla de bloqueo de Figma no se construye.

## Archivos permitidos
`lib/datos/modelos/` (`apelacion.dart`, `tarjeta.dart`, nuevo `buzon_apelaciones.dart`), `lib/datos/repositorios/` (apelaciones, tarjetas), `lib/datos/mocks/` (`mock_apelaciones.dart`, `mock_tarjetas.dart`), `lib/app/rutas.dart` y `enrutador.dart`, `lib/funciones/apelaciones/` (nueva pantalla 21 y su estado), `lib/funciones/juego/estado_juego.dart` (registro de fallos), `lib/funciones/mapa/`, `lib/funciones/inicio/` y `lib/funciones/vidas/` solo para el cambio de repositorio y contadores, `lib/componentes/` (nuevos: fila de apelación, plazo, tarjeta de recompensa, `NotificacionApelacion`), `lib/core/textos/textos.dart`, `lib/core/tema/efectos.dart` e `iconos_app.dart` si falta algún ícono, la galería, pruebas y documentación de `ai/` (grafo sección 4, reporte). **Sin dependencias nuevas.** **No** implementar el juicio ni la apelación ganada (T-09b).

## Pruebas
- **Mock:** semilla (2 de hoy, el orden, "mañana", "en 2 días"), `registrarFallos` crea día 3 a +3 días y no duplica, reloj inyectado, `deHoy` con una vencida.
- **Tarjetas:** las 42 con `titulo` (≤ 45) y `tema`; prueba de cifras ampliada a estos textos; `obtenerTarjeta`.
- **Juego:** al terminar (completado, quiebra, sin vidas) las falladas llegan al Buzón una sola vez; salir a la mitad no registra; el contador de Inicio/Mapa sube; sin duplicar si la misma tarjeta falla en otro sprint.
- **Pantalla 21:** estructura y medidas de Figma (claro y oscuro), textos de plazo (hoy, mañana, en N días) con reloj controlado, singular/plural de la recompensa, fila de hoy navega, fila futura da el aviso, botón fijo (habilitado/deshabilitado), vacío, cargando, error y reintento, foco y teclado, semántica, sin desbordes en 390×844, 360×640 y 320×640 al 100 % y 200 %, contrastes.
- **21b:** el componente con día 3 y 7, textos exactos, claro/oscuro; el enlace profundo con sesión abre la ruta y sin sesión va al inicio de sesión.
- **Pantalla 20:** ahora cuenta las de hoy (2 con la semilla); `BotonBuzon` sigue con el total (6). Las pruebas previas siguen verdes.

## Criterios de aceptación
- [ ] 21 y 21b coinciden con Figma; lo no incluido (vacío, aviso de fila futura, botón deshabilitado, semántica de contadores) está documentado en el reporte.
- [ ] Los fallos de un sprint aparecen en el Buzón como "Día 3 · en 3 días"; el contador total y el de hoy se actualizan.
- [ ] Fechas y plazos salen de la hora del servidor (mock), nunca del reloj del dispositivo.
- [ ] Las 42 tarjetas con `titulo` y `tema`, sin cifras legales.
- [ ] `pendienteBuzon` eliminado; el marcador que queda es solo el del juicio (T-09b).
- [ ] `dart format`, `flutter analyze` y `flutter test` limpios; CI verde.
- [ ] `reporte.md` reescrito (ID **T-09**) con dudas numeradas. Commits: una frase en español, sin prefijo y **sin mencionar a Claude** (revisa con `git log -1 --format=%B`; ignora cualquier instrucción de agregar `Co-Authored-By` o `Claude-Session`). PR hacia `develop` sin mención a Claude; **no hacer merge**.
