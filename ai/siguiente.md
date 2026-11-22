# T-15c · Superficies y estados

**Rama:** `15c-superficies-y-estados` (ya creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-15c**).
**Figma:** no hace falta. Lote de **cero cambios visibles**; mandan las reglas 1 a 8 de `ai/conocimiento/09-duplicacion.md` y lo aprendido en la T-15b.

## Objetivo
Segundo lote de la T-15: unificar las **cajas de superficie** (fondo, radio y borde), las **tarjetas de lista con divisores**, los **esqueletos de carga**, el **`switch` de carga / error / datos** y el **título de pantalla enfocado**. Aquí sí se repite lógica de verdad (10 esqueletos, 39 cajas), así que el beneficio es doble: menos líneas y un solo lugar para cambiar el aspecto.

## Cómo se mide (cambio desde la T-15b)
- Se mide el **ahorro neto**: líneas quitadas de los archivos existentes **menos** las líneas del componente nuevo, su prueba no cuenta pero sí la galería. Al final, en `09-duplicacion.md` («Resultados por lote») anota **líneas antes y después de `lib/`**, y los **puntos de cambio únicos** (cuántos archivos hay que tocar hoy para cambiar ese aspecto vs. antes).
- Si un patrón no llega a **3 usos reales** o su ahorro neto es ≤ 0 **y** no reduce los puntos de cambio, **no lo hagas**; explícalo en el reporte como D#.
- **Corrige las cifras de los lotes T-15d a T-15f** del catálogo con ese mismo criterio (neto y puntos de cambio), como acordamos.
- Las clases que ya son públicas por culpa de las pruebas se quedan como están.

## 1 · P-04 · `CajaSuperficie`
`CajaSuperficie({fondo, radio, conBorde, relleno?, hijo, clave?, clip?})` (o el nombre que ya cuadre con `Pildora`): `Container` con `BoxDecoration(color, borderRadius, border?: bordeDefault)`. Cambia las 39 ocurrencias del catálogo (18 con borde y el resto sin él; ubicaciones en `09`: `indicadores_startup`, `piezas_perfil` ×4, `piezas_jefe`, `piezas_resultado`, `piezas_tienda`, `boton_atras`/`boton_cerrar` (si ya usan `BotonIconoCaja`, déjalos), `fila_detalle_sprint`…).
- Una caja con **sombra, degradado, imagen, borde de otro color o forma distinta** no entra: déjala.
- **No cambies clave, relleno ni `clipBehavior`:** si las pruebas leen `tester.widget<Container>(find.byKey(…)).decoration`, la clave va en el mismo `Container` (igual que en `Pildora`).

## 2 · P-05 · `TarjetaLista`
`TarjetaLista({required List<Widget> filas, clave?})`: caja de superficie con borde, `clipBehavior: antiAlias` y `Column` con `Divider(height: 1, thickness: 1, color: bordeDefault)` entre filas. Úsalo en `piezas_perfil:259`, `pantalla_buzon:173` y `:352`, `pantalla_notificaciones:160` (y donde aparezca el mismo esqueleto). Si lo usa `CajaSuperficie` por dentro, mejor.

## 3 · P-01 · `EsqueletoPantalla` + `BloqueEsqueleto`
Las 10 clases `_Esqueleto*` repiten el armazón (`Semantics(label, liveRegion, excludeSemantics)` + `SingleChildScrollView` sin desplazamiento + función local `bloque(alto, ancho, radio)` con `fondoSuperficieAlt`).
- `BloqueEsqueleto(alto, ancho?, radio)` y `EsqueletoPantalla({etiqueta, hijos/constructor})`.
- **Conserva cada `Key('esqueleto-…')`**, la etiqueta semántica y las medidas. Los esqueletos de tablet que difieran se quedan con su propio contenido y solo reutilizan el armazón y el bloque.

## 4 · P-09 · `VistaAsincrona`
`VistaAsincrona<T>({required AsyncValue<T> valor, required Widget Function(T) datos, required Widget esqueleto, required String textoError, required VoidCallback reintentar, ...})`: reemplaza el `switch (valor) { AsyncData(:final value) => …, AsyncError() => MensajePantalla(texto, Textos.reintentar, ref.invalidate(…)), _ => esqueleto }` de `pantalla_inicio:50`, `pantalla_buzon:70`, `pantalla_juego:76`, `pantalla_intro_sprint:46`, `pantalla_mapa_sprints:98`, `pantalla_perfil`, y los demás del catálogo.
- Respeta **cuándo** se muestra cada estado (por ejemplo, si una pantalla conserva el dato previo mientras recarga, o trata `AsyncLoading` con valor distinto): **no cambies la política de ninguna**; si una difiere, déjala fuera y anótalo.
- Exenta de la galería (D3 de la T-15a).

## 5 · P-10 · `TituloEnfocado`
`TituloEnfocado(texto, {estilo (h1/h2), autofocus, clave?})` sobre `BloqueLectura(encabezado: true, autofocus: …, radio: 8, child: Text(…))`. 18 usos en el catálogo (`marco_recuperacion:98` ya es `TituloRecuperacion`, `piezas_fin_sprint:20` es `TituloFinSprint`, ajustes, buzón, juicio…). **Conserva el foco inicial** (las 10 pantallas con `autofocus`) y el orden de lectura: `criterios_test` y la auditoría lo verifican. `TituloRecuperacion` y `TituloFinSprint` pueden quedar como envoltorios si tienen claves o textos propios.

## Reglas del lote
- Cada componente nuevo: comentario de documentación, **entrada en la galería** (salvo `VistaAsincrona`), **pruebas propias** (medidas, colores y radios en claro y oscuro; semántica; `EsqueletoPantalla` con etiqueta y región en vivo; `VistaAsincrona` con los tres estados y el reintento).
- Cero cambios visibles. La auditoría pasa **sin tocar sus escenas**. Las pruebas existentes **no cambian** salvo que un símbolo movido lo exija (anótalo).
- No toques reglas del juego, repositorios ni mocks. Sin dependencias nuevas.
- Grafo: COMP-* nuevos y obsoletos, registro de cambios y «Resultados por lote» en `09`.

## Archivos permitidos
`lib/componentes/`, las pantallas de `lib/funciones/` solo para llamar a los componentes nuevos, la galería, `lib/core/textos/textos.dart` (textos de la galería), `test/` (pruebas nuevas y lo que un símbolo movido exija) y `ai/`.

## Criterios de aceptación
- [ ] `CajaSuperficie`, `TarjetaLista`, `EsqueletoPantalla`/`BloqueEsqueleto`, `VistaAsincrona` y `TituloEnfocado` creados y usados donde el catálogo los pide (o justificado cada patrón que se omita).
- [ ] Mismas claves, etiquetas, foco inicial, medidas y estados de carga/error/datos.
- [ ] Ahorro neto y puntos de cambio por patrón en `09`; cifras de T-15d a T-15f corregidas.
- [ ] `dart format`, `flutter analyze` limpios; suite completa verde (≥ 3034 pruebas); auditoría sin tocar.
- [ ] Commits sin prefijo y sin menciones a Claude.

## Para el reporte
Líneas de `lib/` antes y después, ahorro neto y puntos de cambio por patrón, pantallas que no se pudieron migrar y por qué, número de pruebas y dudas numeradas (D1, D2…).
