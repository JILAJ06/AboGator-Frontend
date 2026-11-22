# Reporte
- **Tarea:** T-15b · Limpieza y piezas pequeñas
- **Rama:** `15b-limpieza-y-piezas-pequenas`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge.

## Resumen
- **Líneas de `lib/`:** 35 552 → **35 476 (−76)**, en 211 → 214 archivos.
- **Líneas de `test/`:** 19 673 → 19 832 (+159, solo por las pruebas nuevas).
- **Pruebas:** 3025 → **3034**: las 9 nuevas de las piezas. No cambió ninguna prueba existente.
- **Auditoría** (`test/auditoria/`): verde y sin tocar sus escenas.
- **Cero cambios visibles:** mismas medidas, colores, claves, semántica y foco.
- **El ahorro quedó muy por debajo del estimado** (≈ 280; ver D1).

## 1 · Código muerto
- **Borrados:**
  - `lib/app/pantalla_pendiente.dart` (49 líneas);
  - `mostrarAvisoBreve` (`aviso_error.dart`);
  - `Textos.veredictoAnuncio` y `Textos.notificacionApelacionPie`;
  - `MedidasAdaptativas.lienzoTablet`;
  - `Rutas.juicioApelacion`, cuyo patrón `/buzon/:apelacionId` queda en el comentario de `juicioApelacionDe`.
- **No se borraron 5 textos:** `buzonApelaciones`, `sinCambios`, `noSeleccionada`, `noMarcada` y `lineaClave`.
  - En la T-15a los marqué como sin uso por error: los usan otras funciones de `textos.dart` sin el prefijo `Textos.`, por ejemplo `buzonSemantica` e `impactoSemantica`.
  - Ninguna prueba los usa. Lo corregí en la tabla de `09-duplicacion.md`.
- **Clases que pasaron a privadas (6):** `_PildoraPlazo`, `_AvatarJefe`, `_PintorAnillo`, `_TarjetaResumenExamen`, `_PistaGesto` y, al principio, `PiezaConfeti`.
- **Clases que siguen públicas (15), por la regla de D4:**
  - **`PiezaConfeti`:** forma parte de la API pública de `ConfetiSprint` (sus listas estáticas). Como privada, `flutter analyze` daba `library_private_types_in_public_api`.
  - **Las usan las pruebas** (`find.byType`, `is` o `as`): `PildoraComodin`, `PintorCamino`, `PintorCorazon`, `EstrellasNodo`, `ChipBonusEvidencia`, `PildoraRepaso`, `PintorBordePunteado`, `BotonPrecio`, `TextoConTrampas`, `PintorTrampas`, `ChipTipoTarjeta`, `BotonEvidencia` y `AvisoDilema`.
  - **Las usa la galería:** `NotificacionApelacion` y `NotificacionSistema`.

## 2 · Componentes nuevos (`lib/componentes/`)
| Componente | API | Dónde se usa |
|---|---|---|
| `mostrarAviso` / `mostrarAvisoEn` (`aviso_snack.dart`) | `(context o mensajero, texto, {clave})`: `SnackBar` del tema, quita el anterior y anuncia en región en vivo | 9 avisos: Ajustes, Buzón, juicio, Examen (2), resultado del Examen, notificaciones, Perfil y Tienda. Sin galería (D3) |
| `AgarreHoja` | sin parámetros; 40 × 5, radio 3, `bordeDefault`, `ExcludeSemantics` y clave `agarre` | `panel_evidencia`, `panel_veredicto`, `piezas_jefe` y `selector_hora` |
| `BotonIconoCaja` | `etiqueta`, `alPresionar`, `icono` o `hijo`, `claveCaja`, `fondo`, `conBorde`, `colorIcono` | `BotonAtras` y `BotonCerrar` (envolturas con sus claves `caja-atras` y `caja-cerrar`), el atrás de `EncabezadoModulo` (fondo al 18 %, sin borde y blanco) y los + y − del selector de hora (`hijo`) |
| `Pildora` | `fondo`, `relleno`, `child` y, opcionales, `borde`, `sombra`, `altoMinimo` y `clave` (la clave va en la caja) | **22 píldoras** en 15 archivos: las 6 del catálogo y además comodines, chip HUD, etiqueta de la lupa, quiebra, impacto, interruptor de conexión, chip de justificación, plazo, repasos, golpe, comodines bloqueados, inventario, etiqueta del caso, chip de tipo y la del onboarding |

- **Galería:** sección nueva «Piezas pequeñas (agarre, botón de caja y píldora)», con tres textos nuevos en `Textos`.
- **Pruebas nuevas:** `test/componentes/piezas_pequenas_test.dart`, con 9 pruebas.
  - Medidas, colores y radios de cada pieza en claro y oscuro.
  - Semántica de botón y teclado de `BotonIconoCaja`.
  - Sombra y alto mínimo de `Pildora`.
  - `mostrarAviso`: clave, región en vivo y que reemplaza el aviso anterior.

### Para no cambiar nada visible
- **Claves en la misma caja:** `Pildora.clave` y `BotonIconoCaja.claveCaja` ponen la clave en el mismo `Container`, porque las pruebas leen la decoración con `tester.widget<Container>(find.byKey(…))`.
- **Agarres de `piezas_jefe` y `selector_hora`:** antes no tenían `ExcludeSemantics` ni clave. Un `Container` decorado no aporta semántica, así que el árbol que lee el lector es el mismo.
- **Botones + y − del selector:** la clave `mas-…` o `menos-…` pasa de `AccionEnfocable` a `BotonIconoCaja`. El ancestro es el mismo y las pruebas lo encuentran igual. `alignment: center` pasó a `Center`, con el mismo resultado.
- **Fuera del lote:** P-03 (color redundante), por la decisión D6.

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test`: **3034 pruebas**.
```
+3034: All tests passed!
```

## Grafo actualizado
- **`en curso`:** COMP-ATRAS, COMP-CERRAR, COMP-ENCABEZADO-MODULO, SELECTOR-HORA, COMP-PANEL-VEREDICTO, COMP-PANEL-EVIDENCIA, COMP-PIEZAS-JEFE, COMP-FILA-APELACION, COMP-TARJETA-CASO, COMP-PIEZAS-RESULTADO, TEXTOS, RUTAS, ADAPTATIVO y PANT-GALERIA.
- **Nuevos:** COMP-AGARRE-HOJA, COMP-BOTON-ICONO-CAJA, COMP-PILDORA, COMP-AVISO-SNACK y TEST-PIEZAS-PEQUENAS.
- **Obsoleto:** PANT-PENDIENTE sigue `obsoleto`, con la nota «archivo borrado» (según `06`, no se borra la fila).
- `09-duplicacion.md`:
  - sección nueva «Resultados por lote», con las líneas antes y después;
  - corrección de los 5 textos que no eran código muerto.

## Dudas
- **D1. El ahorro neto fue de −76 líneas, no de −200 a −280.**
  - En los archivos existentes se fueron 237 líneas; los 4 componentes nuevos, documentados, suman 161, y la galería, 24.
  - Las píldoras ahorran poco cada una: cambian 5 líneas de `padding` y `decoration` por 3.
  - Mi estimación de la T-15a no restaba bien el costo de los componentes.
  - Propongo que en los lotes siguientes la T-15 se mida por **ahorro neto** y por **puntos de cambio únicos**: hoy un cambio de píldora, agarre o botón de caja se hace en 1 archivo y no en 22, 4 o 4. ¿Ajusto las cifras de los lotes T-15c a T-15f en `09` con ese criterio?
- **D2.** ¿Hay que tratar `PildoraComodin`, `PildoraRepaso` y las demás clases que las pruebas buscan por tipo?
  - Para volverlas privadas habría que cambiar esas pruebas a buscar por clave, y eso queda fuera de la regla de este lote.
  - Propongo dejarlas públicas, o tratarlas en la T-15d, que es solo de pruebas.
- **D3.** `PiezaConfeti` se queda pública porque `ConfetiSprint` la expone en sus listas estáticas, que ve la prueba de confeti. ¿Bien así?
