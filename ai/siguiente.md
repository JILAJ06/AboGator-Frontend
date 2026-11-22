# T-15e · Marcos y disposiciones

**Rama:** `15e-marcos-y-disposiciones` (ya creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-15e**).
**Figma:** no hace falta. Lote de **cero cambios visibles**; mandan las reglas de `ai/conocimiento/09-duplicacion.md` y lo aprendido en la T-15b y la T-15c (clave en el mismo `Container`, ahorro neto, puntos de cambio, no forzar lo que no coincide exactamente).

## Objetivo
Cuarto lote de la T-15 (el orden acordado es T-15e, luego T-15f y al final T-15d): unificar la **semántica de botón**, el **desplazable con alto mínimo**, la **hoja o diálogo adaptativo**, las **dos columnas de tablet**, y reducir las **vistas dobles móvil/tablet** de Inicio y Acceso. Aquí está la lógica repetida de verdad; el criterio de éxito es **ahorro neto y puntos de cambio**, no solo líneas.

## Reglas de medición (igual que la T-15c)
- Ahorro neto = líneas quitadas de archivos existentes − líneas del componente nuevo (la galería se anota aparte). En `09-duplicacion.md` («Resultados por lote») anota líneas antes y después de `lib/`, ahorro neto y puntos de cambio por patrón.
- Un patrón sin **3 usos reales**, o con ahorro neto ≤ 0 **y** sin reducir puntos de cambio, **no se hace**: explícalo como D#.
- Lo que no coincide exactamente se deja como está y se anota.

## 1 · P-08 · `AccionEnfocable.boton`
18 usos de `semantica: (hijo) => Semantics(button: true, label: …, onTap: alPresionar, excludeSemantics: true, child: hijo)` (`barra_comodines`, `barra_juego`, `boton_buzon`, `casilla_app` (si lleva `checked`, no entra), `chip_seleccion`, `enlace_texto`, `fila_acordeon`, `fila_apelacion` y los demás del catálogo).
- Propón un constructor con nombre o parámetro: `AccionEnfocable.boton({required String etiqueta, ...})` que arme esa semántica. **No cambies** etiqueta, orden de foco, `onTap`, `excludeSemantics` ni ninguna otra bandera (`selected`, `toggled`, `enabled`, `liveRegion`…): si el sitio usa una distinta, queda fuera.
- La auditoría de etiquetas y de foco debe seguir verde **sin tocar sus escenas**.

## 2 · P-13 · `DesplazableAltoMinimo`
`LayoutBuilder → SingleChildScrollView → ConstrainedBox(minHeight: max(0, restricciones.maxHeight − relleno))` en `disposicion_ilustracion_tablet:72`, `disposicion_resultado_tablet:86`, `riel_navegacion:124`, `panel_marca:381`, `marco_recuperacion:66`, `pantalla_juicio:410`, `bienvenida` y los que encuentres. Un componente con `{relleno, controlador?, fisica?, hijo}`. Exenta de la galería. Conserva claves, `physics` y el controlador de cada sitio.

## 3 · P-12 · `mostrarHojaAdaptativa`
En tablet `showDialog(Dialog(transparente, elevation 0, insetPadding 32, ConstrainedBox(maxWidth)))`; en móvil `showModalBottomSheet(transparente, velo, isScrollControlled)`. Está en `pantalla_ajustes:76`, `selector_hora:57` y `pantalla_juego:206` (esta usa `HojaLateral`: si no coincide, queda fuera). Un ayudante `mostrarHojaAdaptativa(context, {builder, anchoDialogo})`.
- **Conserva** foco de retorno (`FocoRetorno`), Esc, velo (40 %), `barrierDismissible`, claves de la hoja y el diálogo, y la salida al tocar el velo. `ajustes_test` y `notificaciones_test` lo verifican.

## 4 · P-17 · `DosColumnasTablet`
`final Widget cuerpo = dosColumnas ? Row(…) : Column(…)` con el mismo `fromLTRB` en `pantalla_ajustes:401` y `:439`, `pantalla_perfil:325` y `:359`, `pantalla_buzon:205`. `DosColumnasTablet({required List<Widget> izquierda, required List<Widget> derecha, ...})`. Mantén medianil de 24, márgenes de 32 y las proporciones.

## 5 · D2 de la T-15c
`BotonIconoCuadrado` (`piezas_perfil.dart`, 3 usos: Perfil, Ajustes, Examen) pasa a **envoltura de `BotonIconoCaja`** (conserva su nombre y sus claves, porque las pruebas los usan). Si algún detalle visual difiere, `BotonIconoCaja` lo recibe por parámetro; no cambies ningún valor.

## 6 · P-16 y P-19 · vistas dobles (solo si compensan)
- **P-16 Inicio** (`pantalla_inicio:89-128` y `:184-240`): sección del reto, tarjetas de módulo y tramo actual armados igual en `_Contenido` y `_ContenidoTablet`. Extrae widgets privados dentro del archivo que usen las dos vistas.
- **P-19 Acceso** (`pantalla_inicio_sesion:136` y `:227`, `pantalla_registro:159`): una sola lista de campos y botones (`_campos(estado, notifier)`) que usen móvil y tablet; unifica el `Scaffold` repetido solo si queda exactamente igual.
- Son **medio riesgo**: si el cambio no es claramente mejor o mueve el foco, el orden de lectura o una clave, **no lo hagas** y anótalo como D#.

## Reglas del lote
- Cada componente nuevo: comentario de documentación, **pruebas propias** (medidas, semántica, comportamiento en claro y oscuro, teclado y Esc donde aplique) y **entrada en la galería** salvo los exentos (`DesplazableAltoMinimo`, `mostrarHojaAdaptativa`).
- Cero cambios visibles. La auditoría pasa **sin tocar sus escenas**. Las pruebas existentes **no cambian** salvo que un símbolo movido lo exija (anótalo).
- No toques reglas del juego, repositorios ni mocks. Sin dependencias nuevas.
- Grafo: COMP-* nuevos y obsoletos, registro de cambios y «Resultados por lote» en `09`.

## Archivos permitidos
`lib/componentes/`, las pantallas de `lib/funciones/` solo para llamar a los componentes nuevos o reorganizar Inicio y Acceso, la galería, `lib/core/textos/textos.dart` (textos de la galería), `test/` (pruebas nuevas y lo que un símbolo movido exija) y `ai/`.

## Criterios de aceptación
- [ ] P-08, P-13, P-12, P-17 y el cambio de `BotonIconoCuadrado` hechos (o cada omisión justificada como D#); P-16 y P-19 hechos solo si compensan.
- [ ] Mismas claves, etiquetas, foco inicial y de retorno, medidas, Esc y velo.
- [ ] Ahorro neto y puntos de cambio por patrón en `09`.
- [ ] `dart format`, `flutter analyze` limpios; suite completa verde (≥ 3045 pruebas); auditoría sin tocar.
- [ ] Commits sin prefijo y sin menciones a Claude.

## Para el reporte
Líneas de `lib/` antes y después, ahorro neto y puntos de cambio por patrón, lo que quedó fuera y por qué, número de pruebas y dudas numeradas (D1, D2…).
