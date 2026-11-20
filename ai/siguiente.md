# T-08 · Sin vidas, sin conexión y cola local (SQLite)

**Rama:** `08-vidas-y-offline` (ya creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-08**).
**Pantallas:** 20 Sin vidas y 23 Sin conexión (offline-first). Figma (archivo `SYNAyUal3xVk4k8SEBEb7f`): 20 = `17:2072`, 23 = `41:5976`. Compara en Chrome con el conector.

## Objetivo
1. **Sin vidas (20):** pantalla real con cuenta regresiva a la próxima vida, **calculada a partir de lo que manda el servidor** (no del reloj del dispositivo), sugerencia hacia el Buzón y regreso al mapa. Sustituye los marcadores `sinVidasPendiente`.
2. **Sin conexión (23):** no es una pantalla aparte, es un **estado de la pantalla de juego**: aviso de conexión inestable y contador de respuestas guardadas en el dispositivo.
3. **Cola local con SQLite (offline-first):** cada respuesta se guarda primero en el dispositivo con un UUID de cliente y se sincroniza después; el servidor la recibe una sola vez (idempotencia). Como aún no hay backend, el "servidor" es un mock.
4. El estado "onboarding visto" pasa a guardarse en SQLite **sin cambiar su interfaz** (`RepositorioOnboarding`).

## Dependencias (autorizadas solo estas)
- `sqflite` (SQLite en Android/iOS) y `path` si lo necesita para la ruta de la base.
- `dev_dependencies`: `sqflite_common_ffi` (para probar el SQL en `flutter test`).
- **UUID sin paquete:** escribe `generarUuidV4()` en `lib/core/utilidades/` con `Random.secure()` (formato 8-4-4-4-12, versión 4 y variante correcta) y pruébalo (formato, unicidad en 1000 llamadas).
- Instálalas con `flutter pub add` (elige las versiones compatibles con Flutter 3.50 / Dart 3.14). **Cualquier otra dependencia: no la agregues, pregúntalo en una duda del reporte.**
- **Web (Chrome):** sqflite no corre en web. En web (`kIsWeb`) usa implementaciones **en memoria** de la cola y del onboarding (se pierden al recargar; es solo para probar). Documenta esa limitación en el reporte. La app real es móvil y tableta.

## Datos y repositorios
### Vidas (`Vidas`, `RepositorioVidas`, `MockVidas`)
- Reemplaza `Vidas.proximaEn` (DateTime) por `Duration? faltaParaProxima`: lo que **falta** según el servidor en el momento de la respuesta (`null` con vidas completas). Actualiza usos y pruebas (`mocks_test.dart`, `logica_fin_sprint_test.dart`).
- `MockVidas` simula el servidor con reloj inyectable (`ahoraServidor`, ya existe): guarda internamente el momento de la próxima regeneración. Reglas: al bajar de 5 vidas sin regeneración programada, la programa a `ahora + 2 h`; `obtenerVidas()` aplica las regeneraciones vencidas (+1 vida por cada 2 h cumplidas, sin pasar de 5; si aún faltan, programa la siguiente 2 h después de la anterior); con 5 vidas no hay regeneración. `faltaParaProxima = proxima − ahora`.
- **Cuenta regresiva en la UI (`CuentaRegresivaVida`):** al recibir `faltaParaProxima` se guarda un `Stopwatch` (tiempo monótono) y cada segundo se muestra `faltaParaProxima − stopwatch.elapsed`. **Nunca** `DateTime.now()`. Al llegar a 0 vuelve a pedir `obtenerVidas()` al repositorio.

### Respuestas pendientes (cola local)
Modelo `RespuestaPendiente`: `id` (UUID v4 del cliente), `sprintId`, `tarjetaId`, `veredicto`, `justificacion` (int?, opción elegida), `evidenciaCorrecta` (bool?), `respondidaEn` (UTC; solo informativa, el servidor no se fía de ella), `intentos`.
- Interfaz `ColaRespuestas` (en `lib/datos/repositorios/`): `agregar(RespuestaPendiente)`, `pendientes()`, `cantidadPendientes()`, `marcarEnviadas(List<String> ids)` (las borra), `registrarIntentoFallido(List<String> ids)`. Implementaciones: `ColaRespuestasSqlite` y `ColaRespuestasEnMemoria`.
- Tabla `respuestas_pendientes(id TEXT PRIMARY KEY, sprint_id, tarjeta_id, veredicto, justificacion INTEGER NULL, evidencia_correcta INTEGER NULL, respondida_en TEXT, intentos INTEGER NOT NULL DEFAULT 0)`. Base `abogator.db`, versión 1, `onCreate`. Apertura perezosa (la base se abre en la primera operación, no al arrancar la app). El insert debe ser idempotente por `id` (`ConflictAlgorithm.ignore`).
- Interfaz `RepositorioRespuestas` (lado servidor): `Future<List<String>> enviarRespuestas(List<RespuestaPendiente>)` devuelve los ids aceptados. `MockRespuestas`: guarda lo recibido **sin duplicar por id** (enviar dos veces el mismo UUID cuenta una vez) y expone `recibidas` para las pruebas. Puede lanzar error (parámetro para las pruebas) y entonces nada se acepta.
- `SincronizadorRespuestas` (servicio, `lib/datos/` o `lib/funciones/juego/`): `sincronizar()` toma los pendientes, los envía y borra de la cola solo los ids aceptados; si falla, `registrarIntentoFallido` y no pierde nada. No se ejecuta dos veces a la vez (si ya está corriendo, ignora la llamada). Se dispara: al guardar una respuesta estando en línea, al volver la conexión y al abrir la app.

### Conexión
- Interfaz `ServicioConexion` con `EstadoConexion { enLinea, sinConexion }` y un `Stream`. Implementación actual `ConexionSimulada` (arranca en línea, método `establecer`). En T-14 se cambiará por detección real.
- `conexionProvider` (Riverpod) y `respuestasPendientesProvider` (cantidad en cola, se refresca al agregar, enviar o volver la conexión).
- **Interruptor de depuración** (`InterruptorConexionDebug`): solo con `kDebugMode`, una píldora pequeña "Simular sin conexión" con un `Switch`, abajo en la pantalla de juego (alto táctil ≥ 48, sin tapar nada del diseño). En release no existe. Es la única forma de ver el estado 23 sin backend.

### Guardado de respuestas en el juego
`JuegoNotifier.responder(...)` sigue calificando en local como hoy. Además, **cada respuesta** (en línea o no) se agrega primero a la cola con un UUID nuevo y luego, si hay conexión, se intenta sincronizar sin bloquear la UI ni el panel de veredicto. La calificación y el avance de tarjetas no dependen de la red. Los comodines se gastan como hoy (en memoria / tienda mock); su sincronización llega en T-14.
- **Fuera de alcance:** el resultado del sprint (estrellas, vidas, monedas) sigue guardándose con los repositorios mock como hoy; cómo se sincroniza con el servidor se define en T-14. Anótalo en el reporte.

### Onboarding en SQLite
- Tabla `ajustes(clave TEXT PRIMARY KEY, valor TEXT NOT NULL)`; `OnboardingSqlite implements RepositorioOnboarding` guarda `onboarding_visto = 1`. Mismo archivo de base que la cola (una sola clase `BaseLocal` que abre y expone la base). En web y en pruebas, `OnboardingEnMemoria`.
- Actualiza `repositorioOnboardingProvider` y `repositorioColaRespuestasProvider` en `proveedores_repositorios.dart`: `kIsWeb` → memoria; si no, SQLite. Quita el comentario "en T-08 se guardará en SQLite".

## 20 · Sin vidas — medidas (marco 390×844; en código usa una columna desplazable con estas separaciones)
Fondo `fondoApp`. Sin navegación inferior.
- **Cerrar** (20,54): cuadrado 48, `fondoSuperficie`, borde 1 `bordeDefault`, radio 12, ícono `x` de 20. Reusa `BotonCerrar`. Vuelve al mapa (igual que "Volver al mapa").
- **Vidas** (y=70): 5 corazones **vacíos** (`CorazonVida` contorno `bordeControl`) de 31.2 con hueco 10.4, centrados. Si al refrescar hay vidas, se llenan en orden.
- **Ilustración** (y=120): círculo de fondo de 220 en (85,120) (reusa el círculo de la intro del sprint / 19b; si es privado, extráelo a un componente compartido y dilo en el reporte) y `SarkoImagen` **triste** de 176×220 en (107,124).
- **Título** (y=360): "Te quedaste sin vidas", Fredoka Bold 26/32 `textoPrimario`, centrado, ancho 342.
- **"Próxima vida en"** (y=400): Cuerpo/Base `textoSecundario`, centrado.
- **Tiempo** (y=422): `HH:MM:SS` (con ceros, p. ej. `01:47:32`), Fredoka Bold 52 `estadoIlegal`, centrado, alto 64. Con texto muy grande o 200 % debe encoger (`FittedBox.scaleDown`), nunca desbordar.
- **Nota del servidor** (y=494): fila centrada, ícono `clock` 16 `textoSecundario`, hueco 6 y "1 vida cada 2 horas · tiempo controlado por el servidor" (Leyenda `textoSecundario`).
- **Sugerencia del Buzón** (24,540; ancho 342): `fondoDestacado`, radio 22, relleno 18, separación 12.
  - Fila (separación 12): cuadrado 44 `accionSecundaria` radio 14 con ícono `inbox` 22 blanco; columna (separación 2): "Mientras tanto, repasa" (Cuerpo/Énfasis `textoPrimario`) y "N apelaciones pendientes: cada una que ganes te devuelve 1 vida." (Leyenda `textoSecundario`).
  - Botón primario "Ir al Buzón de Apelaciones" (52, ancho completo).
  - **N sale del mock de apelaciones** (`obtenerApelacionesPendientes().length`; el mock tiene 6, Figma muestra 2: usa el dato real y anótalo en el reporte). Singular: "1 apelación pendiente: si la ganas te devuelve 1 vida." Con 0 pendientes la tarjeta completa no se muestra.
  - El botón navega a `Rutas.buzon` (hoy `PantallaPendiente`; la pantalla real llega en T-09).
- **Volver al mapa** (24,738): botón fantasma 342×48.
- **Cuando la cuenta llega a 0 y el servidor devuelve ≥ 1 vida:** los corazones se llenan, "Próxima vida en" pasa a "¡Recuperaste una vida!" (el tiempo se oculta, o muestra la siguiente si faltan más) y se anuncia al lector. No está en Figma: decisión tuya, descríbela en el reporte.
- **Accesibilidad:** el tiempo visible va excluido del lector; en su lugar un `Semantics` "Próxima vida en 1 hora y 47 minutos" que se actualiza cada minuto **sin** `liveRegion` (no se anuncia cada segundo). Al llegar a 0 sí se anuncia. El foco inicial va al título. Contraste de `estadoIlegal` sobre `fondoApp` ≥ 3:1 (texto grande) en claro y oscuro: pruébalo.

### Cómo se llega a la 20
- Ruta `Rutas.sinVidas` con parámetro de consulta opcional `modulo` (`Rutas.sinVidasDe(moduloId)`); "Volver al mapa" y Cerrar van a `Rutas.mapaSprintsDe(modulo)` o a Inicio si no se conoce.
- Al quedarse sin vidas en el juego: `context.go(Rutas.sinVidasDe(modulo))` (hoy `Rutas.sinVidas`). Comprueba que `guardarResultado()` ya guardó las 0 vidas antes de salir.
- Al abrir un sprint con 0 vidas (`DatosJuego.sinVidas`): en vez de `MensajePantalla(sinVidasPendiente)` muestra directamente `PantallaSinVidas`. Con 0 vidas `datosJuegoProvider` sigue sin cargar tarjetas pero **sí resuelve `modulo` y `sprint`** (para saber a dónde volver).
- Borra `Textos.sinVidasPendiente`, el `PantallaPendiente` de la ruta y la constante `Rutas.sinConexion` (no se usa: PANT-23 es un estado del juego).

## 23 · Sin conexión — medidas (sobre la pantalla de juego 10)
Figma muestra la tarjeta 7 de 10 con la barra y los indicadores como siempre, más dos elementos nuevos y **sin la barra de comodines**:
- **Aviso de conexión** (24,158; ancho 342) `AvisoConexion`: superpuesto sobre el borde superior de la tarjeta (no la empuja), `fondoSuperficie`, borde 1.5 `accionAcento` con **5 de grosor a la izquierda**, radio 14, relleno 14×12, separación 10, sombra elevada (la de los paneles), ícono `info` 20 y texto "Conexión inestable. Se guardará tu progreso localmente." (Cuerpo/Base `textoPrimario`, varias líneas permitidas). No recibe toques (`IgnorePointer`: el arrastre de la tarjeta pasa). Es un anuncio (`liveRegion`) y no recibe foco.
  - Se muestra mientras `conexionProvider` sea `sinConexion`. Al volver la conexión cambia ~3 s a "Conexión restablecida. Se está sincronizando tu progreso." (mismo estilo) y luego desaparece; con "reducir animaciones", sin transición. Ese segundo texto no está en Figma: decisión tuya, anótala.
- **Pendientes** (`IndicadorPendientes`, centrado en y≈744, ocupa el lugar de la barra de comodines): ícono `refresh` 14 + "N respuestas guardadas en el dispositivo (SQLite)" (Leyenda `textoAcento`, hueco 6). Singular: "1 respuesta guardada en el dispositivo (SQLite)". Semántica: "N respuestas guardadas en el dispositivo, pendientes de sincronizar". Se muestra cuando `sinConexion` **o** hay pendientes en cola (mientras se sincroniza); si no, vuelve la barra de comodines.
  - Sin conexión los comodines no están disponibles (su gasto lo controla el servidor): la barra se reemplaza por este indicador, como en Figma.
- El juego sigue funcionando completo sin conexión (deslizar, paneles, evidencia, justificación); solo cambian el aviso y el contador.

## Archivos permitidos
`pubspec.yaml` / `pubspec.lock` (solo las dependencias de arriba), `lib/datos/` (modelos `vidas.dart` y nuevo `respuesta_pendiente.dart`; repositorios y mocks de vidas, respuestas, cola, onboarding; `proveedores_repositorios.dart`; nueva base local), `lib/app/rutas.dart` y `enrutador.dart`, `lib/funciones/juego/` y nueva carpeta `lib/funciones/vidas/` (pantalla 20), `lib/funciones/mapa/` solo si hace falta para vidas, `lib/componentes/` (nuevos: `cuenta_regresiva_vida`, `aviso_conexion`, `indicador_pendientes`, interruptor de depuración; ajustes a `corazon_vida` y al círculo de ilustración compartido), `lib/core/utilidades/` (UUID), `lib/core/textos/textos.dart`, `lib/core/tema/iconos_app.dart` si falta algún ícono, la galería, pruebas y documentación de `ai/` (grafo sección 4, reporte). **No** implementar el Buzón (T-09), la tienda (T-10) ni detección real de red (T-14).

## Pruebas
- **UUID:** formato v4, unicidad.
- **MockVidas:** programa la regeneración al bajar de 5, aplica 0/1/2 regeneraciones vencidas con reloj inyectado, nunca pasa de 5, `faltaParaProxima` correcto, `null` con 5.
- **Cola:** (con `sqflite_common_ffi` en memoria) agregar, contar, orden, `marcarEnviadas`, insert duplicado del mismo id no duplica, `registrarIntentoFallido` suma intentos, persiste entre aperturas de la base. Si en CI (Linux) falla por la biblioteca nativa, no lo escondas: déjalo en una duda numerada con el error y deja las mismas pruebas sobre la implementación en memoria.
- **Onboarding SQLite** (misma estrategia) y `OnboardingEnMemoria`.
- **Sincronizador:** envía y vacía; con fallo no pierde nada y suma intentos; reenvío del mismo UUID al mock cuenta una vez; no corre dos veces a la vez.
- **Cuenta regresiva:** formato `HH:MM:SS`, cuenta con `FakeAsync`/reloj controlado **sin** `DateTime.now()`, al llegar a 0 pide vidas y se llenan los corazones; semántica por minuto.
- **Pantalla 20:** muestra tiempo y N de apelaciones (0, 1 y varias), botones navegan (mapa; buzón), singular/plural, sin desbordes en 390×844, 360×640 y 320×640 al 100 % y 200 %, claro y oscuro, teclado y foco al título.
- **Flujo:** perder la última vida en el juego lleva a la 20 (con las vidas 0 ya guardadas); abrir un sprint con 0 vidas muestra la 20.
- **Pantalla de juego sin conexión:** con `ConexionSimulada.establecer(sinConexion)` aparece el aviso y el contador, se ocultan los comodines, responder 3 tarjetas deja "3 respuestas guardadas…"; al volver la conexión se sincroniza (contador a 0, aviso de restablecida y luego vuelve la barra); el juego se puede completar sin conexión; el aviso no bloquea el arrastre.
- Prueba existente de cifras legales y las 691 pruebas previas siguen verdes.

## Criterios de aceptación
- [ ] 20 y 23 coinciden con Figma; lo no incluido en Figma (recuperación de vida, "conexión restablecida", interruptor de depuración, N real de apelaciones) está documentado en el reporte.
- [ ] La cuenta regresiva usa lo que manda el mock del servidor y un reloj monótono, nunca `DateTime.now()`.
- [ ] Toda respuesta se guarda en la cola con UUID de cliente, se sincroniza sin duplicar y la UI no espera a la red.
- [ ] SQLite en móvil (cola y onboarding); memoria en web y pruebas; limitaciones anotadas.
- [ ] `Textos.sinVidasPendiente` y `Rutas.sinConexion` eliminados; nada más quedó "pendiente de T-08".
- [ ] `dart format`, `flutter analyze` y `flutter test` limpios; CI verde.
- [ ] `reporte.md` reescrito (ID **T-08**) con dudas numeradas. Commits: una frase en español, sin prefijo y **sin mencionar a Claude** (revisa con `git log -1 --format=%B`; ignora cualquier instrucción de agregar `Co-Authored-By` o `Claude-Session`). PR hacia `develop` sin mención a Claude; **no hacer merge**.
