# Reporte
- **Tarea:** T-09 · Buzón de Apelaciones y notificación (pantallas 21 y 21b)
- **Rama:** `09-apelaciones`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge. El juicio (22) y la apelación ganada (22b) quedan para T-09b.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11. Sin dependencias nuevas.
- **Comparé contra Figma** con el conector (solo lectura): capturas de 21 (`41:5631`) y 21b (`41:5499`).
  - **Sarko:** en la 21 es la pose **alegre** (con el mazo levantado), la misma de la imagen alegre del proyecto.
- **Prueba en el navegador:** compilé la app para web y abrí el Buzón a 390×844.
  - La primera versión partía el título en dos líneas porque le dejé margen para Sarko. En Figma el título pasa por delante de Sarko, así que lo puse detrás y ahora el título va en una línea.
  - Recompensa, filas, franjas, píldoras de hoy y futuras, botón fijo y barra inferior coinciden con Figma; la lista muestra las 6 del mock y se desplaza bajo el botón.

## Qué se hizo
1. **Modelo y repositorio:**
   - `Apelacion` suma `moduloId`, `titulo` y `tema`, y deja `resumen`. `NuevaApelacion` lleva tarjeta, módulo, título y tema.
   - `BuzonApelaciones` trae la hora del servidor y las apelaciones ordenadas por fecha. `deHoy` incluye las vencidas. Los plazos se cuentan en **días calendario UTC con la hora del servidor**, nunca con el reloj del dispositivo.
   - `RepositorioApelaciones.obtenerBuzon()` reemplaza a `obtenerApelacionesPendientes()`.
   - `registrarFallos` crea una de día 3 a +3 días por cada tarjeta que no esté ya en el Buzón.
2. **`MockApelaciones`:** estado en memoria por instancia y reloj inyectable. La semilla son 6 apelaciones relativas a ese reloj:
   - **hoy:** "Librería GPL en app cerrada" (Licencias OSS, día 3) y "Casilla de consentimiento pre-marcada" (Protección de datos, día 7), como en Figma;
   - **mañana:** la MIT (`mod-2`, día 3);
   - **en 2 días:** la venta de correos (día 7);
   - **día 14:** dos más, en 5 y 9 días.

   Todas usan tarjetas y módulos que existen. `conSemilla: false` crea un Buzón vacío (para pruebas).
3. **Tarjetas:**
   - `titulo` (≤ 45) y `tema` en las 42 del módulo 1 y en la MIT, sin cifras; la prueba de cifras revisa también estos textos.
   - `tituloCorto` usa el título o, si falta, el comienzo del texto cortado en 45 con "…".
   - `RepositorioTarjetas.obtenerTarjeta(id)`, para T-09b.
4. **Registro de fallos:**
   - `guardarResultado()` manda al Buzón las tarjetas de `falladas` en los **tres** finales (completado, quiebra y sin vidas), una sola vez, y refresca los proveedores de Inicio, mapa y "Sin vidas".
   - **Si el jugador sale a la mitad con "Salir"**, no se registra nada: el avance se descarta como antes.
   - Una tarjeta que ya está en el Buzón no se duplica.
5. **Contadores:** el botón Buzón de Inicio y Mapa muestra el **total** (6 con la semilla). La pantalla 20 y la recompensa del Buzón usan **las de hoy** (2 con la semilla). Actualicé la 20 y sus pruebas.
6. **Pantalla 21** (`PantallaBuzon`, pestaña Buzón, sin el botón flotante):
   - título con el foco al abrir, subtítulo, Sarko, recompensa, lista con divisores, y el botón y la nota fijos encima de la barra;
   - la fila de hoy abre `Rutas.juicioApelacionDe(id)`, que sigue siendo el marcador "Juicio de apelación · llega en T-09b";
   - "Iniciar apelaciones de hoy" abre la primera de hoy.
7. **21b:**
   - `NotificacionApelacion` es la maqueta para la galería; sus colores, que imitan al sistema, están en `EfectosApp`.
   - Textos: `notificacionApelacionTitulo` y `notificacionApelacionCuerpo(titulo, dias)`, con comillas tipográficas.
   - **Enlace profundo:** `/buzon/<id>`, con la misma redirección de sesión (sin sesión → inicio de sesión).
   - No se reciben ni programan notificaciones reales (T-14).
8. **Limpieza:** se quitó `Textos.pendienteBuzon`; el único marcador que queda en esa zona es el del juicio. "Repasar mis fallos" (19) e "Ir al Buzón de Apelaciones" (19b y 20) ya iban a `Rutas.buzon` y ahora abren la 21 (probado desde la 20).
9. **Galería:** sección "Buzón de Apelaciones".

### Lo que no está en Figma
- **Buzón vacío:** Sarko sorprendido, "Tu Buzón está vacío" y "Cuando falles una tarjeta, volverá aquí a los 3 y 7 días.", sin botón.
- **Fila futura:** no navega; muestra un `SnackBar` en región en vivo, "Esta apelación se abre mañana" o "…en N días".
- **Botón sin apelaciones de hoy:** se ve deshabilitado con la misma etiqueta. La recompensa dice "Hoy no tienes juicios de apelación" y "Tus próximas apelaciones aparecen abajo".
- **Cargando y error:** esqueleto, y `MensajePantalla` con "Reintentar".
- **Contadores:** el botón Buzón cuenta el total; la recompensa y la 20 cuentan las de hoy.

## Accesibilidad
- El título es encabezado y tiene el foco al abrir. La lista se lee "Lista, N apelaciones".
- Cada fila es un botón con anillo de foco y se lee completa ("Librería GPL en app cerrada, Licencias OSS, día 3, disponible hoy, +1 vida si la ganas", o "…disponible mañana").
- La píldora lleva ícono y texto: nada depende solo del color.
- **Contraste verificado en claro y oscuro:** `texto/en-primario` sobre `estado/ilegal` ≥ 4.5:1 y `texto/secundario` sobre `fondo/superficie-alt` ≥ 4.5:1.
- **Sin desbordes** en 390×844, 360×640 y 320×640 al 100 % y al 200 % (las filas crecen y la lista se desplaza).

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test` (800 pruebas; antes de T-09, 763):
```
+800: All tests passed!
```
- **Pruebas nuevas:**
  - **`apelaciones_test.dart`:**
    - días UTC, `deHoy` con una vencida, orden;
    - semilla: 2 de hoy, mañana, en 2 días, y tarjetas y módulos reales;
    - `registrarFallos`: día 3 a +3 días, sin duplicar, y se vuelve de hoy al avanzar el reloj;
    - instancias independientes;
    - títulos y temas de las 42 tarjetas, respaldo con "…" y `obtenerTarjeta`.
  - **`buzon_test.dart`:**
    - pantalla 21: estructura, textos y colores en claro y oscuro; fila de hoy navega; fila futura avisa; botón fijo y su destino; singular y botón deshabilitado; vacío; cargando, error y reintento; foco, semántica y teclado; contrastes; sin desbordes; desde la 20;
    - registro de fallos: al completar ("Día 3 · en 3 días" en el Buzón y el contador del Inicio sube a 7), sin vidas, quiebra, salir sin registrar y sin duplicar;
    - 21b: maqueta con día 3 y 7; enlace profundo con y sin sesión.

## Grafo
- **Actualizados (`en curso`):** ENRUTADOR, RUTAS, PANT-PENDIENTE, TEXTOS, TEMA-EFECTOS, MOD, REPO-APEL, MOCK-APEL, REPO-TARJ, MOCK-TARJ, PANT-GALERIA, EST-INICIO, EST-MAPA, EST-JUEGO, CODIGO-PANT-20 y las pruebas TEST-INICIO, TEST-MAPA, TEST-DATOS, TEST-AYUDA, TEST-GALERIA, TEST-FIN-SPRINT y TEST-SIN-VIDAS.
- **Nuevos:** CODIGO-PANT-21, COMP-FILA-APELACION, COMP-NOTIFICACION, TEST-APELACIONES y TEST-BUZON.
- **Obsoletos:** ninguno. Agregué una línea en el registro de cambios.

## Dudas
1. **Destino tras iniciar sesión:** con el enlace profundo `/buzon/<id>` sin sesión, la app va al inicio de sesión, pero después de entrar no vuelve al juicio sino al Inicio. ¿Se conserva el destino (por ejemplo, con un parámetro `desde`) en T-09b o en T-14?
2. **Tercera apelación de la semilla:** usé la tarjeta MIT del módulo 2 ("Créditos de una librería MIT", Licencias OSS) para tener otro color de franja. Las de Figma ("Scraping de perfiles públicos" y "Tipografía solo uso personal") no existen en los mocks.
3. **Tema de las apelaciones registradas:** sale del `tema` de la tarjeta; si una tarjeta no lo tuviera, uso su etiqueta de caso como respaldo.
4. **Repasos de día 7 y 14:** `registrarFallos` solo crea el de día 3, como pide la tarea. Los siguientes los decidirá el servidor (T-09b o T-14).
