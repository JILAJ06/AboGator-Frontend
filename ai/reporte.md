# Reporte
- **Tarea:** T-08 · Sin vidas, sin conexión y cola local (SQLite)
- **Rama:** `08-vidas-y-offline`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11.
- **Dependencias nuevas** (solo las autorizadas, con `flutter pub add`): `sqflite ^2.4.6` y `path ^1.9.1`; en desarrollo, `sqflite_common_ffi ^2.4.7`.
- **Comparé contra Figma** con el conector (solo lectura): capturas de 20 (`17:2072`) y 23 (`41:5976`); las medidas salen de la tarea.
- **Prueba en el navegador:** compilé la app para web en modo depuración (el interruptor solo existe en depuración) y la probé a 390×844.
  - **23:** con "Simular sin conexión", el aviso queda sobre la tarjeta y la barra de comodines cambia por "0 respuestas guardadas…". Tras responder una tarjeta dice "1 respuesta guardada…". Al volver la conexión sale "Conexión restablecida…", el contador vuelve a 0, a los 3 s desaparece el aviso y vuelve la barra.
  - **20:** perdí las 5 vidas en el sprint y la app me llevó a `/sin-vidas?modulo=mod-1`, con la cuenta en `01:59:58`, los 5 corazones vacíos y "6 apelaciones pendientes…".
- **Web:** sqflite no corre en el navegador, así que en web la cola y el onboarding van **en memoria** y se pierden al recargar. Es solo para probar; la app real es móvil y tableta.

## Qué se hizo
1. **Vidas del servidor:**
   - `Vidas.faltaParaProxima` (Duration) reemplaza a `proximaEn`: es lo que falta según el servidor en el momento de la respuesta (`null` con 5).
   - `MockVidas` imita al servidor con reloj inyectable:
     - al bajar de 5 sin regeneración programada, la programa a ahora + 2 h;
     - al pedir las vidas aplica las regeneraciones vencidas (+1 por cada 2 h, sin pasar de 5), y la siguiente se cuenta desde la anterior;
     - con 5 vidas no hay regeneración.
2. **Cuenta regresiva (`CuentaRegresivaVida`):**
   - Descuenta `faltaParaProxima − cronómetro`, con un `Cronometro` monótono (`Stopwatch`; uno falso en las pruebas). **Nunca** usa `DateTime.now()`.
   - Al llegar a 0 avisa una vez y la pantalla vuelve a pedir las vidas. Cada respuesta del servidor empieza una cuenta nueva (`ObjectKey`), aunque traiga el mismo tiempo.
   - Formato `HH:MM:SS`; con texto grande encoge dentro de su caja de 64 (`FittedBox.scaleDown`).
3. **Cola local (offline-first):**
   - `RespuestaPendiente`: UUID v4 del cliente, sprint, tarjeta, veredicto, justificación, evidencia, hora UTC (solo informativa) e intentos.
   - `ColaRespuestas` con dos implementaciones, `ColaRespuestasSqlite` y `ColaRespuestasEnMemoria`. La de SQLite inserta con `ConflictAlgorithm.ignore`, así que el mismo id no se duplica.
   - `BaseLocal` abre `abogator.db` (versión 1, `onCreate`) con las tablas `respuestas_pendientes` y `ajustes`, y solo en la primera operación.
   - `generarUuidV4()` sin paquete, con `Random.secure()` (versión 4 y variante RFC 4122).
4. **Servidor y sincronización:**
   - `RepositorioRespuestas` y `MockRespuestas`: sin duplicar por id, con `recibidas` y con un parámetro para fallar.
   - `SincronizadorRespuestas`: envía, borra solo lo aceptado y, si falla, suma intentos sin perder nada.
   - No corre dos veces a la vez. Si lo llaman mientras corre, no envía en paralelo pero deja pedida **una** pasada más al terminar, para que una respuesta guardada durante el envío no espere al siguiente disparo (ver duda 3).
   - `ServicioConexion` y `ConexionSimulada` (arranca en línea, cambia con `establecer`).
   - `conexionProvider` y `respuestasPendientesProvider`: guarda en la cola y sincroniza al guardar en línea, al volver la conexión y al abrir la app (lo dispara el enrutador al crearse).
5. **Juego:**
   - `responder()` califica en local como antes y además guarda cada respuesta en la cola con un UUID nuevo; la sincronización corre sin bloquear el panel ni el avance.
   - Con 0 vidas, `datosJuegoProvider` no carga tarjetas pero sí resuelve el módulo y el sprint.
   - Quedarse sin vidas lleva a `Rutas.sinVidasDe(modulo)`, después de que `guardarResultado()` guardó las 0 vidas (probado).
   - **Fuera de alcance:** el resultado del sprint (estrellas, vidas, monedas) se sigue guardando con los mocks como antes; cómo se sincroniza con el servidor se define en T-14. Los comodines también siguen en la tienda mock.
6. **Onboarding en SQLite:** `OnboardingSqlite` guarda `onboarding_visto = 1` en `ajustes`, sin cambiar `RepositorioOnboarding`. `usarBaseLocal` elige SQLite en el dispositivo y memoria en web y en `flutter test`; esto último lo detecta con la variable `FLUTTER_TEST` (ver duda 2).
7. **Pantalla 20:** cerrar, 5 corazones, Sarko triste sobre su círculo, título, "Próxima vida en", tiempo, nota del servidor, sugerencia del Buzón y "Volver al mapa".
   - Cerrar y "Volver al mapa" van al mapa del módulo, o al Inicio si no se conoce. El botón del Buzón va a `Rutas.buzon` (todavía un marcador; la pantalla real llega en T-09).
   - **N de apelaciones** sale del repositorio: el mock tiene **6** y Figma muestra 2. Hay singular ("1 apelación pendiente: si la ganas te devuelve 1 vida.") y con 0 no se muestra la tarjeta.
   - **Recuperación de vida (no está en Figma):** cuando la cuenta llega a 0 y el servidor devuelve vidas, los corazones se llenan, el texto cambia a "¡Recuperaste una vida!" y se anuncia al lector. Si faltan más vidas, se ve la cuenta de la siguiente; con 5, no hay cuenta.
   - La ilustración se extrajo a `IlustracionSarko` (`lib/componentes/`); antes era `IlustracionFinSprint`, dentro de las piezas de 19 y 19b, que ahora usan el componente.
8. **23 · Sin conexión (estado de la pantalla 10):**
   - **`AvisoConexion`:** va sobre el borde de la tarjeta, sin empujarla ni bloquear el arrastre.
   - **Mensaje de vuelta (no está en Figma):** al volver la conexión se ve unos 3 s "Conexión restablecida. Se está sincronizando tu progreso."; con "reducir animaciones", sin transición.
   - **`IndicadorPendientes`:** reemplaza a la barra de comodines mientras no hay conexión o hay respuestas en cola.
   - **`InterruptorConexionDebug` (no está en Figma):** solo con `kDebugMode`, abajo de la barra, con alto 48.
9. **Limpieza:** se quitaron `Textos.sinVidasPendiente`, el marcador de la ruta de "Sin vidas" y `Rutas.sinConexion`. No queda nada "pendiente de T-08".
10. **Galería:** sección "Vidas y conexión".

## Accesibilidad
- **20:** el foco empieza en el título. El tiempo visible no se lee; en su lugar el lector dice "Próxima vida en 1 hora y 47 minutos", que cambia por minuto y no se anuncia solo. La recuperación de la vida sí se anuncia.
- **Contraste verificado:** `estado/ilegal` sobre `fondo/app` ≥ 3:1 (texto grande) y `texto/acento` del contador en AA, en claro y oscuro.
- **23:** el aviso y el contador son regiones en vivo y no reciben foco.
- **Sin desbordes:** la 20 en 390×844, 360×640 y 320×640, al 100 % y al 200 %, en claro y oscuro.

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test` (763 pruebas; antes de T-08, 691):
```
+763: All tests passed!
```
- **Pruebas nuevas:**
  - **`base_local_test.dart`:** la misma batería sobre SQLite (con `sqflite_common_ffi`) y sobre memoria: agregar, orden, id duplicado, enviadas, intentos, tablas y persistencia al cerrar y reabrir la base; y el onboarding en SQLite y en memoria.
  - **`vidas_y_sincronizacion_test.dart`:**
    - UUID: formato y 1000 distintos;
    - `MockVidas`: 0, 1 y 2 regeneraciones, nunca pasa de 5, `faltaParaProxima` correcto;
    - `MockRespuestas`: no duplica y puede fallar;
    - sincronizador: envía, falla sin perder, reenvío del mismo UUID, sin correr dos veces a la vez y la pasada extra;
    - conexión simulada.
  - **`sin_vidas_test.dart`:** formato y semántica de la cuenta; cuenta con reloj falso que avisa una vez; llegar a 0 llena los corazones y se anuncia; N de apelaciones 0, 1 y varias; navegación; teclado; sin desbordes.
  - **`conexion_componentes_test.dart`** y **`sin_conexion_test.dart`:**
    - componentes de 23;
    - en línea: cada respuesta sale con UUID y sin duplicar;
    - sin conexión: aviso, contador, sin comodines y 3 respuestas guardadas; al volver, se sincroniza y reaparece la barra;
    - el aviso no bloquea el arrastre; el sprint se completa sin red; un fallo del servidor no pierde nada; el interruptor funciona;
    - perder la última vida y abrir un sprint con 0 vidas llevan a la 20.

## Grafo
- **Actualizados (`en curso`):** ENRUTADOR, RUTAS, PANT-PENDIENTE, TEXTOS, MOD, REPO-VIDAS, REPO-ONBOARDING, PROV-REPO, MOCK-VIDAS, PANT-GALERIA, EST-JUEGO, CODIGO-PANT-10, PIEZAS-FIN-SPRINT, CODIGO-PANT-19, CODIGO-PANT-19b, COMP-CORAZON, CONF y las pruebas TEST-JUEGO, TEST-VEREDICTO, TEST-FIN-SPRINT, TEST-AYUDA, TEST-GALERIA y TEST-DATOS.
- **Nuevos:**
  - datos y lógica: BASE-LOCAL, COLA-RESPUESTAS, ONBOARDING-SQLITE, REPO-RESPUESTAS, SINCRONIZADOR, SERVICIO-CONEXION, EST-SINCRONIZACION, UTIL-UUID, UTIL-CRONOMETRO;
  - pantalla y componentes: CODIGO-PANT-20, COMP-CUENTA-REGRESIVA, COMP-AVISO-CONEXION, COMP-PENDIENTES, COMP-INTERRUPTOR-DEBUG, COMP-ILUSTRACION-SARKO;
  - pruebas: TEST-BASE-LOCAL, TEST-SINCRONIZACION, TEST-SIN-VIDAS, TEST-SIN-CONEXION.
- **Obsoletos:** ninguno. Agregué una línea en el registro de cambios.

## Dudas
1. **SQLite en el CI (Linux):** las pruebas de SQLite pasan aquí en Windows con `sqflite_common_ffi`. En Ubuntu necesitan la biblioteca nativa `libsqlite3`, que los ejecutores de GitHub suelen traer, pero no lo pude comprobar porque el CI corre al abrir el PR. Si falla, el arreglo es instalarla en `ci.yml` (`sudo apt-get install -y libsqlite3-dev`); ese archivo no estaba entre los permitidos y no lo toqué. Las mismas pruebas corren también sobre la implementación en memoria.
2. **Detección de pruebas:** para no abrir SQLite en `flutter test`, `usarBaseLocal` revisa la variable `FLUTTER_TEST`. ¿Prefieres que las pruebas sobrescriban siempre los proveedores y quitar esa revisión?
3. **Sincronizador:** si lo llaman mientras corre, en lugar de ignorar la llamada del todo deja pedida una pasada más al terminar (nunca en paralelo). ¿Está bien?
4. **Corazones de 20:** la tarea pide contorno `borde/control` y así quedaron; en la captura de Figma se ven rellenos en gris. ¿Cuál dejamos?
5. **N de apelaciones:** el mock tiene 6 y Figma muestra 2; uso el dato real.
6. **Interruptor de depuración:** queda abajo de la barra de comodines en depuración; en release no existe.
