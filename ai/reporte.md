# Reporte
- **Tarea:** T-15c · Superficies y estados
- **Rama:** `15c-superficies-y-estados`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge.

## Resumen
- **Líneas de `lib/`:** 35 476 → **35 453 (−23)**, en 214 → 218 archivos.
- **Líneas de `test/`:** 19 832 → 20 077 (+245, solo por las pruebas nuevas).
- **Pruebas:** 3034 → **3045**: las 11 nuevas. No cambió ninguna prueba existente.
- **Auditoría** (`test/auditoria/`): verde y sin tocar sus escenas.
- **Cero cambios visibles:** mismas claves, etiquetas, foco inicial, medidas y política de carga, error y datos.
- **El beneficio de este lote son los puntos de cambio:** 63 lugares quedan en 5 componentes. Las líneas casi no bajan (ver D1).

## Ahorro neto y puntos de cambio por patrón
Lo medí aplicando cada patrón solo, sobre el punto de partida.

| Patrón | Usos | Archivos existentes | Componente | Neto | Puntos de cambio |
|---|---|---|---|---|---|
| P-01 `EsqueletoPantalla` + `BloqueEsqueleto` | 9 esqueletos + el bloque del certificado | −130 | +68 | **−62** | 10 → 1 |
| P-04 `CajaSuperficie` | 30 cajas en 23 archivos | −84 | ≈ +60 | **−24** | 30 → 1 |
| P-05 `TarjetaLista` | `MenuAgrupado` (8 usos), Buzón ×2 y notificaciones | −43 | ≈ +38 | **−5** | 4 → 1 |
| P-10 `TituloEnfocado` | 12 títulos | −68 | +49 | **−19** | 12 → 1 |
| P-09 `VistaAsincrona` | 7 pantallas | ≈ −8 | +55 | **≈ +47** | 7 → 1 |
| Galería y textos | — | +38 | — | +38 | — |

`CajaSuperficie` y `TarjetaLista` viven en `caja_superficie.dart` (98 líneas entre las dos).

## Qué se hizo
- **`EsqueletoPantalla` + `BloqueEsqueleto`** (`esqueleto_pantalla.dart`):
  - **Armazón y bloques:** Inicio, Buzón, juicio, juego, intro, Perfil, Tienda y Examen; el Examen pasa su color propio a los bloques.
  - **Solo el armazón:** el mapa, porque sus círculos se calculan por posición.
  - **Solo el bloque:** el certificado, porque su marco es un borde punteado.
  - Conservan la clave `esqueleto-…`, la etiqueta, la región en vivo, el relleno, la alineación y el `SafeArea`.
  - **Medidas que se mantienen a mano:** el radio por defecto cambiaba entre esqueletos (16 o 18), así que donde era 18 lo puse explícito.
- **`VistaAsincrona`** (`vista_asincrona.dart`):
  - Inicio, Buzón, juego, intro y mapa usan el mismo `switch` de antes (`AsyncData`, `AsyncError` y lo demás como carga). Los casos especiales (Buzón vacío, sin vidas, sin tarjetas, módulo no encontrado) van dentro de `datos`.
  - Perfil y Tienda tenían otra política: el valor previo gana al error y a la carga. Para ellas existe `conservarValor: true`.
  - **Quedaron fuera:**
    - el Examen, que tiene un error propio «no disponible»;
    - el juicio, que revisa «sin conexión» antes que los datos y no ofrece «Reintentar».
- **`CajaSuperficie`:** 30 cajas, solo las que coinciden exactamente.
  - Fondo superficie, superficie-alt o destacado; radio; borde de 1 en borde/default o sin borde.
  - Si tenían clave, relleno, ancho, alto, alineación o recorte, se conservan.
  - Las cajas con sombra, degradado, borde de otro color u otro fondo se quedaron como estaban.
- **`TarjetaLista`:**
  - `MenuAgrupado` pasa a ser una envoltura de una línea (radio 18, clave `menu-perfil`).
  - Las dos listas del Buzón usan `alineacion: center`, como antes; la de notificaciones, la alineación por defecto.
- **`TituloEnfocado`:** 12 títulos.
  - Diálogo de confirmación (H2, con su `autofocus` condicional), recuperación, Ajustes, Buzón, Examen (2 y la pausa con `enVivo`), resultado del Examen, pausa del juego (H2), fin de sprint, notificaciones y `TituloPestana`.
  - El legal lo hice a mano, por su estilo H3 de 18.
  - **Quedaron fuera:** los títulos de los paneles del juego (llevan etiqueta propia y excluyen los hijos) y el del resultado del juicio (tiene `nodoFoco`).
- **Galería:** sección nueva «Superficies, lista, esqueleto y título». El título de ejemplo va sin `autofocus`, para no quitarle el foco a la galería.
- **Pruebas nuevas** (`test/componentes/superficies_y_estados_test.dart`, 11):
  - medidas, colores, radios y bordes en claro y oscuro;
  - divisores de la lista;
  - región en vivo del esqueleto;
  - encabezado y foco inicial del título;
  - `VistaAsincrona` con los tres estados, el reintento y las dos políticas.

## Cifras corregidas en `09-duplicacion.md`
Las calculé con el criterio neto y los puntos de cambio:

| Lote | Antes | Ahora |
|---|---|---|
| T-15d (en `test/`) | ≈ 240 | ≈ −150 |
| T-15e | ≈ 310 | ≈ −210 |
| T-15f | ≈ 335 | ≈ −310 |

- **Total corregido:** ≈ −620 en `lib/` (≈ 1,7 %), contando las reales de la T-15b y la T-15c.
- La sección «Resultados por lote» tiene la fila de la T-15c y su desglose por patrón.

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test`: **3045 pruebas**.
```
+3045: All tests passed!
```

## Grafo actualizado
- **`en curso` (38 nodos de los archivos que se tocaron):**
  - CODIGO-PANT-07, 08, 09, 10, 19, 20, 21, 22, 24, 25, 26, 27, 29, 32 y 34;
  - COMP-AVISO, BUZON-INICIO, DIALOGO-CONFIRMACION, ESTADISTICAS, FILA-APELACION, FILA-DETALLE, MODULO, PANEL-ABOGADO, PANEL-LATERAL-JUEGO, PANEL-VEREDICTO, PIEZAS-AJUSTES, PIEZAS-JEFE, PIEZAS-PERFIL, PIEZAS-RESULTADO, PIEZAS-TIENDA, PROGRESO, SEMANA y TARJETA-CASO;
  - MARCO-RECUPERACION, PANT-GALERIA, PIEZAS-FIN-SPRINT, SELECTOR-HORA y TEXTOS.
- **Nuevos:** COMP-CAJA-SUPERFICIE, COMP-ESQUELETO, COMP-VISTA-ASINCRONA, COMP-TITULO-ENFOCADO y TEST-SUPERFICIES.
- **Obsoletos:** ninguno.

## Dudas
- **D1. `VistaAsincrona` suma unas 47 líneas netas.** Cada pantalla ahorra poco: el `switch` ya era compacto. La hice porque baja los puntos de cambio de 7 a 1 (mensaje de error, «Reintentar» y política de carga), como permite la regla del lote. ¿La dejamos, o prefieres revertirla y volver a los `switch`?
- **D2. Encontré un duplicado que no estaba en el catálogo:** `BotonIconoCuadrado` (`piezas_perfil.dart`, 3 usos: Perfil, Ajustes y Examen) es casi igual a `BotonIconoCaja`. No lo toqué porque no estaba en el alcance. ¿Lo paso a envoltura de `BotonIconoCaja` en la T-15e?
- **D3.** El radio por defecto de `BloqueEsqueleto` es 16. En los esqueletos que usaban 18 (Inicio e intro) lo puse explícito. ¿Bien así, o unificamos el radio de los esqueletos? Unificarlo sería un cambio visible.
