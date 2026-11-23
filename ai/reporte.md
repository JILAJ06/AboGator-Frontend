# Reporte
- **Tarea:** T-15d · Ayudantes de pruebas y auditoría de acciones de tocar
- **Rama:** `15d-ayudantes-de-pruebas`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge a `develop`. Con esta tarea, la T-15 queda completa.

## Resumen
- **Ayudantes nuevos** (solo `test/`; `lib/` sin cambios):
  - **T-01:** `probarSinDesbordes`, en `test/ayudantes/sin_desbordes.dart`.
  - **T-03:** `probarSinDesbordesTablet`, en `test/ayudantes/tamano_pantalla.dart`.
  - **T-02:** los falsos comunes, en `test/ayudantes/falsos.dart`, y `tocar`, en `test/ayudantes/montar.dart`.
- **Mismas pruebas:** cada archivo tocado tiene el mismo número de pruebas **y los mismos nombres** que antes. Lo comprobé comparando los nombres de las 3324 pruebas, archivo por archivo, con el reportador JSON antes y después.
- **Auditoría ampliada:** `acciones_de_tocar_test.dart` también revisa casillas (`checked`) e interruptores (`toggled`). Pasa: no falta ningún control, así que no hay ningún D# de controles sin la acción de tocar.
- **Líneas de `test/`:** 20 629 → **20 297 (−332)**. Los ayudantes ahorran −385; la prueba nueva de los ayudantes suma +48 y la auditoría, +5.
- **Pruebas:** 3324 → **3350**. Las 26 nuevas son de la prueba de los ayudantes.

## Qué quedó en cada ayudante
- **`probarSinDesbordes(cuerpo, {grupo, casos, ambosBrillos, prefijo, texto})`:**
  - Registra una prueba por caso, y por brillo si se pide `ambosBrillos`.
  - Fija la escala del texto y el brillo con `fijarTextoYBrillo`, que los restaura al terminar.
  - Luego llama a `cuerpo(tester, tamano, escala)`.
- **Casos de móvil:**
  - `casosMovil`: las 6 combinaciones.
  - `casosMovilCinco`: sin 360×640 a 1.0.
  - `casosTextoGrande`: 4 casos.
- **Nombres:** `prefijo` y `texto` sirven para conservar los nombres que ya tenían las pruebas. `grupo: null` deja la matriz en el grupo actual; se usa cuando hay varias matrices por archivo o cuando la matriz vive dentro de otro grupo.
- **`probarSinDesbordesTablet(cuerpo, {grupo, ambosBrillos, prefijo})`:** recorre los 3 tamaños de tablet (`tamanosTablet`, que antes vivía en `cuenta_tablet_test`), a 100 % y 200 %.
- **`falsos.dart`:**
  - `ana`.
  - `ProgresoFalso`.
  - `ApelacionesFalsas([cantidad = 6])` y `ApelacionesFalsas.conDias(dias, ahora:, fallar:)`, con `bloqueo`.
  - `HapticaFalsa`.
  - `CronometroFalso`.
- **Copias que no eran idénticas:**
  - El buzón del Buzón (`BuzonFijo`) tenía días, otra hora del servidor, fallo y bloqueo. Pasa esas diferencias por `conDias`.
  - `BuzonFalso(n)` de Sin vidas era igual que `ApelacionesFalsas(n)`.
- **`tocar`:** había 17 copias idénticas: 11 llamadas `tocar` y 6 llamadas `pulsar`. Las 6 de `pulsar` (recuperación, Buzón de tablet, evidencia, juego de tablet, legal y notificaciones) ahora llaman a `tocar`.

## Pruebas por archivo tocado (antes = después)
| Archivo | Pruebas | Qué cambió |
|---|---|---|
| `perfil_test` | 25 | matriz y `tocar` |
| `ajustes_test` | 47 | matriz, `HapticaFalsa` y `tocar` |
| `buzon_test` | 28 | matriz, `ApelacionesFalsas.conDias` y `tocar` |
| `juicio_test` | 40 | matriz y `tocar` |
| `inicio_test` | 24 | matriz, `ana`, `ProgresoFalso`, `ApelacionesFalsas` y `tocar` |
| `comodines_test` | 27 | matriz y `tocar` |
| `fin_sprint_test` | 38 | matriz (19 y 19b) |
| `tienda_test` | 28 | matriz y `tocar` |
| `juego_test` | 41 | matriz |
| `evidencia_justificacion_test` | 52 | matriz (evidencia y dilema) y `tocar` |
| `mapa_test` | 48 | matriz (mapa e intro), `ana`, `ProgresoFalso`, `ApelacionesFalsas` y `tocar` |
| `sin_vidas_test` | 26 | matriz, `CronometroFalso`, `ApelacionesFalsas` y `tocar` |
| `veredicto_test` | 25 | matriz |
| `jefe_test` | 47 | matriz, `HapticaFalsa` y `tocar` |
| `resultado_test` | 40 | matriz (29 y 30) |
| `buzon_tablet_test` | 23 | matriz de tablet y `tocar` |
| `examen_tablet_test` | 19 | matriz de tablet |
| `juego_tablet_test` | 31 | matriz de tablet y `tocar` |
| `resultados_tablet_test` | 20 | matriz de tablet |
| `bienvenida_tablet_test` | 14 | matriz de tablet |
| `acceso_tablet_test` | 22 | matriz de tablet (una por ruta) |
| `cuenta_tablet_test` | 50 | matriz de tablet (una por pantalla) y `tocar` |
| `recuperacion_test`, `legal_test`, `notificaciones_test` | 14, 11, 20 | `tocar` |
| `inicio_tablet_test`, `pulido_test` | 27, 38 | solo importaciones |
| `acciones_de_tocar_test` | 252 | auditoría ampliada |
| `sin_desbordes_test` (nuevo) | 0 → 26 | prueba de los ayudantes |

## Medición
| Pieza | Copias quitadas | Ayudante | Neto | Puntos de cambio |
|---|---|---|---|---|
| Falsos y `ana` (T-02) | −254 | +122 | **−132** | `ana` 3 → 1, `ProgresoFalso` 2 → 1, buzón falso 4 → 1, `HapticaFalsa` 2 → 1 |
| `tocar` (T-02) | −119 | +8 | **−111** | 17 → 1 |
| Matrices (T-01 y T-03), con las importaciones | 15 archivos de móvil y 7 de tablet | +116 | **≈ −142** | 22 archivos con su propia matriz → 2 ayudantes |
| **Total** | | | **−385** | |

- **Estimado en `09`: ≈ −150.** Salió más porque había más matrices que las 9 del catálogo (también estaban en juego, mapa, sin vidas, veredicto, Examen, resultado y evidencia, más las de tablet) y más copias de `tocar`.

## Qué quedó fuera y por qué
- **`inicio_tablet_test`:** su `abrirInicioTablet` recibe la escala y el tema por parámetro, no por el sistema. Pasarlo al ayudante cambiaría cómo se prueba.
- **Matrices de `test/componentes/`:** montan con `montar(escalaTexto:)` y no tocan la escala del sistema.
- **`pulsar` de `test/auditoria/catalogo.dart`:** toca `f.first`, así que no es una copia de `tocar`. Lo usan la auditoría y `criterios_test`.
- **`tocar(tester, String texto)` de `fin_sprint_test`:** tiene otra firma; recibe el texto del botón.
- **`RelojFalso` y su cronómetro (`jefe_test`):** el cronómetro lee un reloj que comparte con el servidor del Examen. Es otro falso, no una copia de `CronometroFalso`. Lo usan `resultado_test` y la auditoría.
- **`BuzonQueFalla` (`juicio_test`):** envuelve el mock real para fallar al resolver.
- **`usuarioPrueba` (acceso):** es otro usuario, el de los flujos de acceso.
- **`lib/`:** no necesité cambiarlo.

## Auditoría ampliada
- **Qué revisa ahora:** además de botones y enlaces, cuenta como control todo nodo con `isChecked` distinto de `CheckedState.none` o con `isToggled` distinto de `Tristate.none`. Como antes, solo si está habilitado, visible y tiene etiqueta.
- **Qué encontró.** Con una prueba temporal, que no subí, confirmé que la auditoría sí recorre esos nodos:
  - **Casillas:** las 2 de Registro.
  - **Opciones:** las de micro-pregunta (12), justificación (18) y contraargumento (28b).
  - **Selector de tamaño de texto:** los 4 tamaños (26).
  - **Interruptores:** los 5 de Ajustes, los 3 de Notificaciones y «Simular sin conexión» en el juego.
- **Resultado:** todos tienen `SemanticsAction.tap`, y las 252 pruebas pasan.
- **`08-accesibilidad.md`:** actualicé la línea de la regla.

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test`: **3350 pruebas** en verde.
  - Las 3324 de antes tienen los mismos nombres en cada archivo.
  - Las 26 nuevas son de `sin_desbordes_test`.
```
3350 {'success': 3350} success True
```
- `lib/` sin cambios: `git diff develop -- lib` está vacío.

## Documentación y grafo
- **`09-duplicacion.md`:**
  - T-01, T-02 y T-03 marcados como hechos.
  - La fila del lote T-15d, hecha, con el resultado real.
  - En «Resultados por lote»: la fila de la T-15d y el desglose por pieza, con lo que quedó fuera, la D1 de la T-15a resuelta y la auditoría.
- **`04-plan-de-tareas.md`:** la fila de la T-15 dice que está hecha, con sus totales.
- **`08-accesibilidad.md`:** la regla de acciones de tocar incluye casillas e interruptores.
- **`grafo.md`:**
  - T-15d y T-15 pasan a `hecho`; se cierran con el merge.
  - `en curso`: TEST-AYUDA, TEST-ACCIONES-TOCAR, DOC-04, DOC-08 y DOC-09.
  - **Nodos nuevos:** TEST-SIN-DESBORDES y TEST-FALSOS. **Obsoletos:** ninguno.
  - Entrada nueva en el registro de cambios.

## Dudas
- **D1. La D1 del catálogo para T-01: resuelta.** Conservé todas las pruebas de las matrices en el ayudante común y no borré ninguna por redundante con la auditoría. Si prefieres quitarlas, bajaría el número de pruebas; no lo hice porque `siguiente.md` pide el mismo número.
- **D2. Dónde viven `ana` y `tocar`.** `siguiente.md` los ponía en `falsos.dart`, y el catálogo ponía `ana` en `datos.dart` y `tocar` en `montar.dart`. Decidí así:
  - `ana`, en `falsos.dart`, como pide `siguiente.md`.
  - `tocar`, en `montar.dart`, porque es una acción sobre widgets y no un falso.

  ¿Te parece bien?
- **D3. `pulsar` pasa a `tocar` en 6 archivos.** Las llamadas cambiaron de nombre, pero hacen lo mismo. ¿Prefieres que `montar.dart` también exporte `pulsar`, para no tocar esas llamadas?
- **D4. La prueba de los ayudantes suma 26 pruebas.** 24 son los casos que registran los dos ayudantes, y 2 comprueban esos registros. Para comprobar lo que registra un ayudante hay que dejar que lo registre, así que no se puede bajar de ahí sin quitar la prueba. Si te parecen pruebas por pruebas, la quito.
- **D5. T-15 completa:** `lib/` −326 líneas (T-15b −76, T-15c −23, T-15e −80, corrección −18, T-15f −92 y T-15g −37) y `test/` −385 con los ayudantes. La fila de la T-15 en el plan y en el grafo queda como hecha, para que la cierres con el merge.
