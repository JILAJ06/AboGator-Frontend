# T-15a · Auditoría de duplicación (solo análisis, sin cambiar la app)

**Rama:** `15a-auditoria-de-duplicacion` (ya creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-15a**).
**Figma:** no hace falta.

## Contexto: qué es la T-15
Hoy `lib/` tiene ~35 500 líneas (77 archivos solo en `lib/componentes/`) y `test/` ~19 700. Muchas pantallas repiten los mismos bloques (botones con sus estados, campos, filas, encabezados, estados de carga/vacío/error, hojas y diálogos, versiones móvil y tablet casi iguales, textos con el mismo estilo, sombras, espaciados). El objetivo de la T-15 es **pasar todo lo que se repita a componentes globales** que se llamen con parámetros (`BotonApp(tipo:, etiqueta:)`), de modo que cambiar algo en un solo lugar cambie toda la app, con **menos líneas** y **sin cambiar nada de lo que ve o hace el usuario**.

Es una tarea grande y delicada (la app tiene 3025 pruebas que la protegen), así que se hace **por lotes**. Esta T-15a es el primer paso: **solo mirar y medir**. No cambies ningún archivo de `lib/` ni de `test/`.

## Qué hacer
1. **Mide el punto de partida:** líneas por carpeta de `lib/` (`componentes`, `funciones/<área>`, `core`, `datos`), los 20 archivos más largos y el número de pruebas.
2. **Busca duplicación** en `lib/funciones/` y `lib/componentes/`, con estas lupas (agrega las que descubras):
   - Botones, campos, casillas, enlaces, chips y filas **construidos a mano** en vez de usar `BotonApp`, `CampoTextoApp`, etc.; variantes que podrían ser un parámetro.
   - **Marcos de pantalla** repetidos (Scaffold, SafeArea, padding de 24/32, columna máxima 470/640, botón atrás o cerrar, título con foco, pie fijo con botones).
   - Pares **móvil/tablet** con el mismo contenido copiado (`_XxxTablet` vs móvil).
   - **Estados de carga, vacío y error** repetidos (esqueletos, mensajes con reintento).
   - **Hojas y diálogos** (`showModalBottomSheet`, `showGeneralDialog`, `HojaLateral`, confirmaciones) con el mismo esqueleto.
   - **Tarjetas, filas e insignias** (borde, radio, relleno, sombra) con valores copiados; colores, radios, espacios y `TextStyle` escritos a mano en vez de tokens.
   - **Semántica y foco** repetidos (anuncios, `FocoRetorno`, `Semantics` con el mismo patrón).
   - Funciones o clases **casi idénticas** (misma estructura, cambian 2–3 valores).
   - **Código muerto:** archivos, clases o métodos sin uso (p. ej. `PantallaPendiente`), textos sin referencias, imports que sobran.
   - Pruebas con **ayudantes repetidos** (pumps, tamaños, repositorios falsos) que puedan ir a un ayudante común.
3. **Entrega un catálogo** en un archivo nuevo `ai/conocimiento/09-duplicacion.md` (una fila por patrón): *patrón · dónde está (archivo:línea, mínimo 3 ocurrencias) · líneas aproximadas repetidas · componente propuesto y su API (parámetros) · riesgo (bajo, medio, alto) y por qué · pruebas que lo cubren*. Ordena por **ahorro de líneas ÷ riesgo**.
4. **Propón los lotes** de la T-15b en adelante (cada lote = una rama, un PR, de 3 a 8 patrones afines, con el orden: primero lo seguro y compartido, al final lo delicado, como el mazo de tarjetas, el Examen y el juego). Cada lote con su ahorro estimado de líneas y qué pruebas lo protegen.
5. **Reglas que debe cumplir toda la T-15** (déjalas escritas en `09-duplicacion.md`):
   - Cero cambios visibles: mismas medidas, textos, colores, foco, semántica y animaciones (la auditoría de `test/auditoria/` debe seguir verde sin tocar sus escenas).
   - Los componentes viven en `lib/componentes/`, con nombre en español, documentados con un comentario breve y una entrada en la galería.
   - Un componente nuevo solo se crea si se usa **3 veces o más**; si no, se deja donde está.
   - Se borra lo que quede sin uso; se actualiza el grafo en cada lote.
   - Las reglas del juego, los repositorios y los mocks no se tocan.

## Archivos permitidos
Solo crear `ai/conocimiento/09-duplicacion.md` y reescribir `ai/reporte.md`; agregar `09` al índice de conocimiento y al grafo (`DOC-09`). **No modifiques `lib/` ni `test/`.** Sin dependencias nuevas.

## Criterios de aceptación
- [ ] Medición inicial de líneas y pruebas.
- [ ] Catálogo con al menos 15 patrones (o todos los que haya), cada uno con 3+ ocurrencias ubicadas, ahorro estimado, API propuesta y riesgo.
- [ ] Lotes propuestos con orden, ahorro y pruebas que los protegen.
- [ ] Lista de código muerto.
- [ ] Reglas de la T-15 escritas en `09-duplicacion.md`.
- [ ] Ningún cambio en `lib/` ni `test/`; commits sin prefijo y sin menciones a Claude.

## Para el reporte
Resumen de hallazgos (los 5 patrones que más líneas ahorrarían), dudas numeradas (D1, D2…) y el plan de lotes para que yo lo revise y escriba la T-15b.
