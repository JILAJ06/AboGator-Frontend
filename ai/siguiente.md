# T-15f · Fin de sprint, Examen y resúmenes

**Rama:** `15f-fin-de-sprint-examen-y-resumenes` (ya creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-15f**).
**Figma:** no hace falta. Lote de **cero cambios visibles**; mandan las reglas de `ai/conocimiento/09-duplicacion.md` y lo aprendido en la T-15b, T-15c, T-15e y la corrección de accesibilidad (ahorro neto, puntos de cambio, nada de forzar lo que no coincide exactamente, controles con acción de tocar).

## Objetivo
Quinto lote de la T-15: la duplicación **móvil/tablet** de las pantallas de fin de sprint, el Examen y unos repetidos dentro de un mismo archivo. Es riesgo **medio-alto** por el foco y el cronómetro del Examen.

**Decisión de alcance:** el **P-14 (`MarcoMazo`, el teclado del mazo copiado en juego, Examen y juicio)** es el patrón más delicado y el catálogo pide que vaya **solo y al final**. Lo dejo para un lote propio, **T-15g**. **No lo hagas aquí.**

## Reglas de medición (igual que antes)
Ahorro neto = líneas quitadas − líneas del componente nuevo; en «Resultados por lote» de `09` anota líneas antes y después de `lib/`, ahorro neto y puntos de cambio. Un patrón sin 3 usos reales, o con ahorro ≤ 0 y sin reducir puntos de cambio, **no se hace** (D#). Lo que no coincide exactamente se deja y se anota.

## 1 · P-11 · Contenido doble en `ColumnaFinSprint`
`pantalla_sprint_completado.dart:112-207`, `pantalla_startup_quiebra.dart:97` y `pantalla_juicio.dart:581-651` arman las mismas piezas (`IlustracionSarko`, `ElementoOrdenado`, estrellas, vidas, títulos) **dos veces**: en `contenido` y en `contenidoTablet` o `ilustracionTablet`.
- Armado único: cada pantalla crea sus piezas **una vez** (variables locales o métodos privados) y las pasa a las dos listas. Opcional: que `ColumnaFinSprint` reciba `ilustracion` + `cuerpo` y reparta ella las piezas, **solo si** el orden de foco y las escalas de tablet quedan idénticos.
- **Conserva** el orden de foco (`ElementoOrdenado`), las escalas del Sarko en tablet, las claves y las etiquetas.

## 2 · P-15 · Examen móvil y tablet
`pantalla_jefe.dart:353-417` y `:1118-1174` (pie «Enfrentar auditoría», aviso sin conexión, «Ahora no», la alerta del jefe), `:235` y `:298`, y `piezas_jefe.dart:216`.
- Piezas **privadas** en `pantalla_jefe.dart` (`_PieEnfrentar`, `_AlertaJefe`) que usen la vista móvil y `_CrisisTablet`.
- **No crees `BotonTextoApp`:** «Ahora no» tiene 2 usos (D5 de la T-15a).
- **No toques** el cronómetro, el foco propio del Examen, la tecla P, ni las políticas de error/sin conexión (la T-15c ya dejó el Examen fuera de `VistaAsincrona` a propósito).
- `jefe_test`, `examen_tablet_test` y la auditoría del Examen deben pasar **sin cambios**.

## 3 · P-20 · Repetidos dentro de un mismo archivo
`FilaVidas` (`pantalla_sin_vidas.dart:149` y `:182`), las piezas de `PanelMarca` (`panel_marca.dart:182` y `:251`), los parámetros de `BarraJuego` contra `BarraJuegoTablet` (`barra_juego.dart:39` y `:122`) y el confeti (`confeti_sprint.dart:52` y `:88`). Variables locales, una clase de parámetros compartida o un método privado; **sin componente global** (menos de 3 usos). Si alguno no mejora claramente, déjalo (D#).

## Reglas del lote
- **Cero cambios visibles:** medidas, colores, textos, claves, foco, orden de lectura, semántica, tecla P, animaciones y política de errores iguales. La auditoría (incluida `acciones_de_tocar_test.dart`) pasa **sin tocar sus escenas**; las pruebas existentes **no cambian** salvo que un símbolo movido lo exija (anótalo).
- No toques reglas del juego, repositorios ni mocks. Sin dependencias nuevas.
- Los controles que armes o muevas deben seguir exponiendo la **acción de tocar** (regla de `08`).
- Grafo: COMP-* nuevos y obsoletos, registro de cambios y «Resultados por lote» en `09` (y actualiza la fila del T-15g si el catálogo lo pide).

## Archivos permitidos
`lib/funciones/juego/`, `lib/funciones/jefe/`, `lib/funciones/apelaciones/pantalla_juicio.dart`, `lib/funciones/vidas/`, `lib/funciones/acceso/panel_marca.dart`, `lib/componentes/` (`barra_juego`, `confeti_sprint`, `piezas_jefe`, `ColumnaFinSprint`…), `test/` (solo si un símbolo movido lo exige) y `ai/`. **No modifiques** `mazo_swipe.dart` ni el teclado del mazo (T-15g).

## Criterios de aceptación
- [ ] P-11, P-15 y P-20 hechos o cada omisión justificada (D#), con ahorro neto y puntos de cambio por patrón en `09`.
- [ ] Mismo orden de foco, escalas de tablet, claves y etiquetas; Examen con cronómetro, foco y tecla P intactos.
- [ ] `dart format`, `flutter analyze` limpios; suite completa verde (≥ 3309 pruebas); auditoría sin tocar.
- [ ] Commits sin prefijo y sin menciones a Claude.

## Para el reporte
Líneas de `lib/` antes y después, ahorro neto y puntos de cambio por patrón, lo que quedó fuera y por qué, número de pruebas y dudas numeradas (D1, D2…).
