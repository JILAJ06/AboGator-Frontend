# T-06b · Fin de sprint (pantallas 19 y 19b)

**Rama:** `06b-fin-de-sprint` (creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code.

## Objetivo
Reemplazar los marcadores de **Sprint completado (19)** y **Startup en quiebra (19b)**, guardar el resultado del sprint en los mocks (para que el mapa lo refleje) y completar las tarjetas de los demás sprints del módulo 1 para poder jugar todos.

## Antes de empezar
- `git fetch origin 06b-fin-de-sprint`, `git checkout 06b-fin-de-sprint`, `git pull`. Leer `ai/conocimiento/` (00 a 07), sobre todo `05-reglas-y-seguridad.md`, `03-pantallas.md` (flujo 3) y `07-componentes.md` ("Componentes del fin de sprint").
- Comparar con Figma (`SYNAyUal3xVk4k8SEBEb7f`): 19 = `38:5557` y 19b = `37:4136`. Con el conector verificar lo que no se pudo ver: **qué estrellas van llenas** (Figma pinta las tres), el fondo circular detrás de Sarko, y la caída del confeti.

## Pantalla 19 · Sprint completado (`Rutas.sprintCompletado`)
Estructura en `07-componentes.md`. De arriba abajo: confeti, Sarko alegre sobre su fondo, estrellas, título "¡Sprint completado!", subtítulo, tres estadísticas, "Estado final de tu Startup", indicadores con cambios, aviso del buzón, "Continuar al mapa" y "Repasar mis fallos". Columna desplazable en pantallas bajas o con texto grande; los botones quedan al final del contenido, sin desbordes.
- **Datos que muestra:**
  - Aciertos = tarjetas `correcto` (con o sin bonus) sobre el total. Las parciales no cuentan como acierto y no son falladas.
  - XP y monedas = los del estado del sprint (T-06).
  - Estado final = estado de la Startup al terminar, con el cambio respecto al **inicio del sprint** (el que cargó `datosJuegoProvider`).
  - Subtítulo = campo nuevo `mensajeCompletado` de `Sprint` (para `spr-1-3`: "Tu MVP ya cumple con el aviso de privacidad y la Startup sigue en pie."). Escribir uno corto para cada sprint del módulo 1.
- **Estrellas** (decisión de Chat, ajustable): ≥ 80 % de aciertos = 3; ≥ 60 % = 2; menos = 1 (completar da siempre al menos 1). Función pura en `lib/funciones/juego/`.
- **Aviso del buzón** (falladas = incorrectas y Amparo): "N tarjetas falladas irán a apelación en 3 y 7 días. Resuélvelas para recuperar vidas." Plural y días: 1 fallada → "1 tarjeta fallada irá a apelación en 3 días."; 2 → "en 3 y 7 días" (Figma); 3 o más → "en 3, 7 y 14 días". Con 0 falladas, no se muestran el aviso ni "Repasar mis fallos".
- **Botones:** "Continuar al mapa" → `go` al mapa del módulo (`Rutas.mapaSprintsDe`). "Repasar mis fallos" → `Rutas.buzon` (marcador hasta T-09).
- **Anuncio:** al abrir, el título se anuncia (región en vivo) y recibe el foco sin anillo, como el panel de T-06. Orden de foco: título → estrellas → estadísticas → estado final → aviso → botones. El confeti no se lee.

## Pantalla 19b · Startup en quiebra (`Rutas.startupQuiebra`)
- Indicadores arriba con los valores del momento de la quiebra y su cambio; Sarko triste sobre su fondo; etiqueta "RIESGO LEGAL 100%" (o "PRESUPUESTO 0%" si la causa fue el Presupuesto); título "¡Tu Startup quebró!"; descripción; aviso "El sprint se reinicia con los indicadores al inicio. Las tarjetas falladas ya están en tu Buzón de Apelaciones."; "Reiniciar sprint" y "Ir al Buzón de Apelaciones".
- **Descripción:** campo nuevo `mensajeQuiebra` de `Sprint` (para `spr-1-3`: "Una auditoría encontró la librería GPL-3.0 en tu código cerrado. La demanda se llevó el presupuesto y los inversionistas se fueron."). Si el sprint no lo tiene, texto genérico según la causa, en `Textos`.
- **Reiniciar sprint:** descarta el estado local del sprint y navega a `Rutas.juegoDe(sprintId)` con todo al inicio (indicadores iniciales, tarjeta 1, XP y monedas en 0). Las **vidas perdidas se conservan** (no se restauran).
- **Ir al Buzón:** `Rutas.buzon` (marcador).
- Si llegas a `/juego/:sprintId/quiebra` sin un sprint en curso (recarga o enlace directo), mostrar el mensaje "No hay un resultado que mostrar" con un botón para volver al mapa (igual para `/completado`). Reusar `MensajePantalla`.

## Estado y guardado
- **El estado del sprint debe sobrevivir al cambio de pantalla:** `juegoProvider` hoy es `autoDispose` y se pierde al navegar a 19 o 19b. Mantenerlo vivo mientras exista alguna de las 3 rutas del sprint (juego, completado, quiebra) y reiniciarlo al entrar de nuevo con "Comenzar" desde la intro o el mapa, y con "Reiniciar sprint". Elegir el mecanismo (por ejemplo `keepAlive` e invalidar explícitamente) y dejarlo anotado como decisión.
- **Guardado en los mocks (en memoria):** agregar a las interfaces y a los mocks, con nombres propios de Claude Code:
  - `RepositorioProgreso`: registrar el sprint completado (estrellas, y el estado final de la Startup), que marque el siguiente sprint como en curso y actualice el avance del módulo. Si ya estaba completado, conserva el máximo de estrellas.
  - `RepositorioVidas`: guardar las vidas restantes.
  - `RepositorioTienda`: sumar las monedas ganadas.
  Se guarda al **terminar el sprint (19)** y al **quebrar (19b)** (en la quiebra solo vidas; el progreso no cambia). Con esto, el mapa y el Inicio reflejan el resultado. Lo real lo hará el servidor en T-14; escribir las firmas pensando en eso y anotarlo en el reporte.
- Los mocks deben poder reiniciarse entre pruebas.

## Datos: tarjetas de los demás sprints
- Completar `MockTarjetas` para `spr-1-1`, `spr-1-2` (hoy tiene 2), `spr-1-4` y `spr-1-5`, **cada uno con tantas tarjetas como su `numeroTarjetas`** y la composición de su `Sprint` (normales, con evidencia y dilemas). Tema del módulo 1: Protección de Datos (datos personales vs. sensibles, consentimiento, derechos ARCO, brechas de seguridad; LFPDPPP). Cada tarjeta con personaje, rol, etiqueta del caso, texto breve, respuesta correcta, explicación, los tres impactos y micro-pregunta en 3 o 4 de cada sprint. Las de evidencia y justificación se ven como normales hasta T-07.
- Mover la tarjeta de la GPL-3.0 (hoy en `spr-2-1`) a `spr-1-3` como tarjeta 5, reemplazando la que hoy ocupa ese lugar y respetando la composición del sprint. Dejar `spr-2-1` como está.
- **Contenido legal:** debe ser sencillo y correcto. En el reporte, listar cada tarjeta nueva con la norma o principio en que se basa, para que el usuario (estudiante) pueda verificar el contenido. Si hay duda sobre una respuesta, preferir un caso claro.

## Componentes nuevos (`lib/componentes/`, con pruebas y en la galería)
`ConfetiSprint`, `EstrellasSprint`, `EstadisticasSprint`, `AvisoInformativo` y `EtiquetaQuiebra`, más las dos pantallas en `lib/funciones/juego/`. Medidas y tokens en `07-componentes.md`. Solo tokens del tema; los colores del confeti van en `EfectosApp`. Textos en `Textos`. Íconos: check, star, coin, inbox, info, trending-down (verificar que existan). Agregar a la galería.

## Pruebas
- **Lógica pura:** estrellas por porcentaje (límites 60 % y 80 %), conteo de aciertos y falladas (parcial no cuenta en ninguno), cambios respecto al inicio, texto del aviso para 1, 2 y 3 o más falladas, causa de la quiebra.
- **Componentes** (claro y oscuro): medidas, estrellas llenas y vacías, semántica de estrellas y estadísticas, contraste (≥ 4.5:1) de la etiqueta de quiebra, del aviso y de los textos, confeti quieto con reducir animaciones, sin desbordes con texto al 200 % en 390×844 y 360×640 y a 320 de ancho.
- **Pantallas:** completar un sprint de principio a fin muestra la 19 con los datos correctos y guarda el resultado (el mapa muestra el sprint completado y el siguiente en curso); quiebra por Riesgo y por Presupuesto muestra la 19b, conserva las vidas perdidas y "Reiniciar sprint" empieza desde cero; 0 falladas oculta el aviso y "Repasar"; llegar sin estado muestra el mensaje; el estado sobrevive al cambio de pantalla; botones y navegación; foco y anuncio.
- **Datos:** cada sprint del módulo 1 tiene tantas tarjetas como su `numeroTarjetas` con la composición correcta; la GPL está en `spr-1-3`.
- Actualizar las pruebas de T-04, T-04b, T-05 y T-06 que se vean afectadas (mocks de progreso, vidas y monedas; tarjetas; rutas).

## Archivos permitidos
`lib/funciones/juego/**`, `lib/componentes/**`, `lib/core/**`, `lib/app/**`, `lib/datos/**`, `lib/funciones/bienvenida/galeria_componentes.dart`, `lib/funciones/mapa/**` e `inicio/**` solo si hace falta para reflejar el resultado, `test/**`, los nodos de código de `ai/grafo.md` y `ai/reporte.md`. **No tocar** `ai/siguiente.md` ni `ai/conocimiento/`. Sin dependencias nuevas.

## Criterios de aceptación
- [ ] Las pantallas 19 y 19b coinciden con Figma (medidas, tokens, tipografías, estrellas, confeti), en claro y oscuro.
- [ ] Completar un sprint refleja en el mapa y el Inicio: sprint completado con sus estrellas y el siguiente en curso; vidas y monedas actualizadas.
- [ ] La quiebra conserva las vidas perdidas y "Reiniciar sprint" vuelve a empezar; sin estado, mensaje con botón de regreso.
- [ ] Todos los sprints del módulo 1 se pueden jugar completos; la GPL está en `spr-1-3`.
- [ ] Lector de pantalla: anuncio y foco del título, estrellas y estadísticas legibles, orden de foco; reduce animaciones respetado; sin desbordes a 200 % y 320 dp.
- [ ] `dart format`, `flutter analyze` y `flutter test` limpios; CI en verde.
- [ ] Grafo actualizado (PANT-19 y 19b con su ruta; nodos nuevos de componentes, lógica y pruebas; cambios en MOD, MOCK-*, REPO-*, EST-JUEGO, ENRUTADOR, RUTAS, PANT-PENDIENTE, TEXTOS, TEMA-EFECTOS, PANT-GALERIA) y `reporte.md` con ID **T-06b**, rama `06b-fin-de-sprint`, dudas numeradas (D1, D2…), la lista de tarjetas nuevas con su base legal y los límites conocidos.
- [ ] Commits: una frase en español, sin prefijo y **sin mencionar a Claude** (revisar con `git log -1 --format=%B`). Pull Request hacia `develop`, sin menciones a Claude. No hacer merge.
