# Reporte
- **Tarea:** T-15e · Marcos y disposiciones
- **Rama:** `15e-marcos-y-disposiciones`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge.

## Resumen
- **Líneas de `lib/`:** 35 453 → **35 373 (−80)**, en 218 → 219 archivos.
- **Líneas de `test/`:** 20 077 → 20 253 (+176, solo por las pruebas nuevas).
- **Pruebas:** 3045 → **3052**: las 7 nuevas. No cambió ninguna prueba existente.
- **Auditoría** (`test/auditoria/`): verde y sin tocar sus escenas.
- **Cero cambios visibles:** mismas claves, etiquetas, banderas semánticas, foco y desplazamiento.
- **Se hicieron 4 de los 7 puntos.** P-12, P-17 y el cambio de `BotonIconoCuadrado` no coincidían exactamente; se explican abajo.

## Ahorro neto y puntos de cambio
| Patrón | Usos | Archivos existentes | Componente | Neto | Puntos de cambio |
|---|---|---|---|---|---|
| P-08 `AccionEnfocable.boton` | 13 controles | −78 | +43 | **−35** | 13 → 1 |
| P-13 `DesplazableAltoMinimo` | 10 desplazables | −60 | +48 | **−12** | 10 → 1 |
| P-16 Inicio (piezas privadas) | 4 piezas | −23 | — | **−23** | 2 → 1 |
| P-19 Acceso (piezas privadas) | 4 piezas | −10 | — | **−10** | 2 → 1 |

## Qué se hizo
- **P-08 · `AccionEnfocable.boton`:**
  - Un constructor con nombre arma `Semantics(button: true, label, onTap: alPresionar, excludeSemantics: true)`.
  - Las banderas opcionales `habilitado`, `seleccionado`, `enlace` y `expandido` pasan tal cual; si no se dan, quedan nulas, igual que antes.
  - **7 sitios iguales:** barra de juego, botón del Buzón, `BotonIconoCaja`, campo de texto, riel, héroe y la fila del recordatorio.
  - **6 con banderas opcionales:** enlace, acordeón, fila de apelación, tarjeta del caso, tarjeta de módulo y otro del riel.
  - **Fuera:** los que usan `checked`, `toggled`, grupo excluyente o `container`, o no tienen `onTap`. Son la casilla, el chip, la opción de justificación, los comodines, 3 de Ajustes, 2 del Perfil y 1 de la Tienda.
- **P-13 · `DesplazableAltoMinimo`:**
  - El alto mínimo es el alto disponible menos el relleno vertical. Vale 0 si el alto no tiene límite (como hacía el riel) o con `conAltoMinimo: false` (la franja vertical de la ilustración).
  - Conserva las claves de desplazamiento, el controlador y la física.
  - **10 sitios:** disposiciones de ilustración y de resultado, riel, panel de marca, recuperación, onboarding, juego, Examen, juicio y detalle del mapa.
  - **Fuera:** notificaciones, porque pone el `Center` antes del alto mínimo y no es el mismo árbol.
- **P-16 · Inicio:**
  - Funciones y widgets privados que usan las dos vistas: `_tarjetaHeroe` (con `medidas`), `_retoDiario`, `_tarjetaModulo` y `_TituloRuta`.
  - El orden de foco de tablet (`ordenado`) sigue por fuera, igual que antes.
- **P-19 · Acceso:**
  - Métodos privados para el enlace «¿Olvidaste…?» con el error general, el botón de entrar y el de crear cuenta.
  - Los espacios entre piezas siguen siendo los de cada vista.
  - `_campos` ya era compartido. No toqué el Registro: solo coincide en 2 lugares.
- **Pruebas nuevas** (`test/componentes/marcos_y_disposiciones_test.dart`, 7):
  - **`AccionEnfocable.boton`:** semántica, toque y Enter en claro y oscuro; las banderas opcionales; y que deshabilitado no tenga acción de tocar.
  - **`DesplazableAltoMinimo`:** el alto mínimo con el pie abajo; que se desplaza si no cabe; sin alto mínimo; sin límite de alto; y que conserva controlador y física.
- **Galería:** sin cambios. `AccionEnfocable.boton` y `DesplazableAltoMinimo` no tienen vista propia.

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test`: **3052 pruebas**.
```
+3052: All tests passed!
```

## Grafo actualizado
- **`en curso` (24 nodos):**
  - CODIGO-PANT-02..04, 05, 07, 08, 10, 22, 27 y 34;
  - COMP-ACCION (ahora con `.boton`), BARRA-JUEGO, BOTON-ICONO-CAJA, BUZON, CAMPO, DISPOSICION-ILUSTRACION, ENLACE, FILA-ACORDEON, FILA-APELACION, HEROE, MODULO, RESULTADO-TABLET, RIEL y TARJETA-CASO;
  - MARCO-RECUPERACION y PANEL-MARCA.
- **Nuevos:** COMP-DESPLAZABLE y TEST-MARCOS.
- **Obsoletos:** ninguno.
- **`09-duplicacion.md`:** fila de la T-15e en «Resultados por lote», su tabla por patrón y lo que no se hizo.

## Dudas
- **D1. `BotonIconoCuadrado` no lo pasé a `BotonIconoCaja`.**
  - Su `Semantics` no tiene `onTap`, y con `excludeSemantics` el lector de pantalla no recibe la acción de tocar. Afecta al botón de Ajustes del Perfil, al atrás de Ajustes y a la pausa del Examen.
  - Hay 3 piezas más con el mismo hueco: `piezas_perfil.dart:220` y `:273`, y `piezas_tienda.dart:158`.
  - Parece un fallo de accesibilidad. Si lo confirmas, en un lote aparte agrego el `onTap` (es un cambio para el lector) y luego el botón pasa a ser envoltura de `BotonIconoCaja`.
- **D2. P-12 (hoja adaptativa) no se hizo:** solo hay 2 usos iguales (Ajustes y el selector de hora). ¿Lo dejamos así, o lo hacemos si aparece un tercer selector?
- **D3. P-17 (dos columnas) no se hizo:** solo Ajustes y Perfil coinciden.
  - Ajustes, Perfil e Inicio sí repiten el marco que lo envuelve: desplazable con margen de 32, `Center` y ancho máximo de 640 en una columna.
  - ¿Lo cuento como patrón nuevo para la T-15f o para un lote aparte?
