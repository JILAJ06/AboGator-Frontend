# Reporte

- **Tarea:** FIX-02 · Imágenes de logos y Sarko según Figma
- **Rama:** `fix/02-imagenes-figma`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11.
- Revisé en Chrome (web en modo debug, 390×844): el Splash en modo oscuro, la página 1 del onboarding, y en la galería los 20 logos y las 4 poses en modo claro.

## Qué se hizo
1. **Imágenes:**
   - Copié 30 archivos desde `Imegenes/Logo-Isotipo/` a `assets/imagenes/`, en subcarpetas y con nombres en `snake_case`. Los originales se quedaron donde estaban.
   - Comprobé cada copia: el SHA-256 es idéntico al original y las medidas coinciden con las de la tarea. Ver la tabla.
   - No copié ninguna lámina de presentación (los archivos sin "Versión=" ni `Ícono App v2`).
   - Borré con `git rm` los 7 provisionales de T-01: `logo_isotipo.png`, `logo_marca_nominativa.png`, `icono_app.png` y los 4 `sarko_*.png`.
   - En `pubspec.yaml` declaré las 7 subcarpetas una por una (`logos/base`, `logos/isotipo`, `logos/vertical`, `logos/horizontal`, `logos/extendido`, `sarko` e `icono_app`).
   - Agregué `/Imegenes/` a `.gitignore`.
2. **`ImagenesApp`:**
   - Dos enums nuevos: `FormaLogo` (isotipo, vertical, horizontal, extendido), que guarda las medidas en px del archivo y su proporción, y `TonoLogo` (color, negro, negativo, sobreAzul, sobreVerde).
   - `ImagenesApp.logo(forma, tono)` arma la ruta del logo.
   - Hay constantes para las piezas base, las 4 poses y los 4 íconos de app, y `todas` lista las 30 rutas.
3. **`LogoApp`:**
   - Usa los PNG ya armados; quité el armado por código del isotipo más la marca.
   - Parámetros: `forma`, `tono`, `ancho` y `decorativo`. El alto sale de la proporción del archivo.
   - Sin `tono`, el logo es color en modo claro y negativo en oscuro.
   - Mantiene la etiqueta semántica "AboGator", salvo si es decorativo.
4. **Splash:**
   - Usa `logo_vertical_sobre_verde.png` a 323.7×187.9, sin la tarjeta marcador.
   - Ahora es pantalla de marca: siempre usa el verde bosque `TokensColor.claro.accionPrimaria` de fondo, puntos en blanco (`texto/en-primario` claro) y lema y "Powered by" en `fondo/destacado` claro, también en modo oscuro. La barra de estado queda clara. La excepción al tema está documentada en el código.
   - El logo es decorativo, porque la etiqueta única del Splash ya dice "AboGator".
5. **`SarkoImagen`:** mantiene la caja 4:5 y `BoxFit.contain`, ahora con alineación **abajo al centro** (`Alignment.bottomCenter`).
6. **Galería:**
   - Muestra los 20 logos (5 tonos × 4 formas), cada uno sobre su fondo:
     - Color y negro sobre `fondo/app`.
     - Negativo sobre la superficie oscura.
     - SobreAzul sobre `accion/secundaria` claro.
     - SobreVerde sobre verde bosque.
   - Los fondos de marca son fijos, porque en modo oscuro `accion/secundaria` es claro y no serviría.
   - Las 4 poses de Sarko siguen en su sección.

## Archivo original → nombre nuevo
Todas las medidas se verificaron en la copia.

| Original (`Imegenes/Logo-Isotipo/`) | Nuevo (`assets/imagenes/`) | Medidas |
|---|---|---|
| Base · Isotipo.png | logos/base/logo_base_isotipo.png | 1068×973 |
| Base · Marca nominativa.png | logos/base/logo_base_marca_nominativa.png | 1312×266 |
| Versión=color.png | logos/isotipo/logo_isotipo_color.png | 200×200 |
| Versión=negro.png | logos/isotipo/logo_isotipo_negro.png | 200×200 |
| Versión=negativo.png | logos/isotipo/logo_isotipo_negativo.png | 200×200 |
| Versión=sobreAzul.png | logos/isotipo/logo_isotipo_sobre_azul.png | 200×200 |
| Versión=sobreVerde.png | logos/isotipo/logo_isotipo_sobre_verde.png | 200×200 |
| Versión=color Vertical.png | logos/vertical/logo_vertical_color.png | 355×206 |
| Versión=negro Vertical.png | logos/vertical/logo_vertical_negro.png | 355×206 |
| Versión=negativo Vertical.png | logos/vertical/logo_vertical_negativo.png | 355×206 |
| Versión=sobreAzul Vertical.png | logos/vertical/logo_vertical_sobre_azul.png | 355×206 |
| Versión=sobreVerde Vertical.png | logos/vertical/logo_vertical_sobre_verde.png | 355×206 |
| Versión=color 2.png | logos/horizontal/logo_horizontal_color.png | 495×120 |
| Versión=negro Horizontal.png | logos/horizontal/logo_horizontal_negro.png | 495×120 |
| Versión=negativo Horizontal.png | logos/horizontal/logo_horizontal_negativo.png | 495×120 |
| Versión=sobreAzul Horizontal.png | logos/horizontal/logo_horizontal_sobre_azul.png | 495×120 |
| Versión=sobreVerde Horizontal.png | logos/horizontal/logo_horizontal_sobre_verde.png | 495×120 |
| Versión=color Extendido.png | logos/extendido/logo_extendido_color.png | 495×120 |
| Versión=negro Extendido.png | logos/extendido/logo_extendido_negro.png | 495×120 |
| Versión=negativo Extendido.png | logos/extendido/logo_extendido_negativo.png | 495×120 |
| Versión=sobreAzul Extendido.png | logos/extendido/logo_extendido_sobre_azul.png | 495×120 |
| Versión=sobreVerde Extendido.png | logos/extendido/logo_extendido_sobre_verde.png | 495×120 |
| Sarko · Alegre (original).png | sarko/sarko_alegre.png | 432×432 |
| Sarko · Enojado.png | sarko/sarko_enojado.png | 269×312 |
| Sarko · Sorprendido.png | sarko/sarko_sorprendido.png | 256×283 |
| Sarko · Triste.png | sarko/sarko_triste.png | 216×283 |
| Ícono App.png | icono_app/icono_app_180.png | 180×180 |
| Ícono App v3.png | icono_app/icono_app_120.png | 120×120 |
| Ícono App v4.png | icono_app/icono_app_64.png | 64×64 |
| Ícono App v5.png | icono_app/icono_app_40.png | 40×40 |

Confirmaciones:
- `Versión=color 2.png` es el **Horizontal en color**: lo abrí y muestra el isotipo a la izquierda y "ABOGATOR" a la derecha.
- `Versión=sobreAzul.png` y `Versión=sobreVerde.png` son idénticos byte a byte, y también sus `Vertical`. Los copié con los dos nombres, como pide la tarea.
- En cambio, los `Horizontal` y `Extendido` de sobreAzul y sobreVerde **sí son distintos** entre sí.
- Las 4 poses de Sarko tienen fondo transparente (alfa 0 en las esquinas) y ya no traen texto incrustado.

## Resolución (≈ 1x)
Las exportaciones están a ~1x. Por ejemplo, el vertical mide 355×206 px y en el Splash se usa a 323.7×187.9 dp, así que en un teléfono de densidad 3 se ve unas 2.7 veces ampliado. Los usé tal cual; **hay que reexportar a 3x**. Basta con reemplazar los archivos manteniendo los nombres.

## Sarko: tamaño y alineación (medidas, sin escalar)
Con caja 4:5 de ancho W, `contain` y alineación abajo:

| Pose | Escala aplicada | Alto visible del personaje | Margen bajo los pies |
|---|---|---|---|
| alegre (1:1) | W / 432 | ≈ 0.73 W | ≈ 0.097 W |
| enojado (0.86) | W / 269 | ≈ 1.02 W | ≈ 0.108 W |
| sorprendido (0.90) | W / 256 | ≈ 0.95 W | ≈ 0.117 W |
| triste (0.76) | 1.25 W / 283 | ≈ 1.05 W | ≈ 0.128 W |

- **Alegre se ve claramente más chica.** A 264 de ancho mide ≈ 193 dp de alto, contra ≈ 250–277 de las demás. Se debe a que su archivo tiene más margen transparente: contenido en y = 73…389 de 432. **No la escalé** (ver D1).
- Los pies quedan casi en la misma línea: la diferencia máxima es ≈ 0.03 W, unos 8 dp a 264 de ancho, por el margen transparente distinto de cada archivo. En la galería se ven alineados.
- El onboarding solo usa la pose alegre (264×330, 160×200 y 208×260). En Chrome se ve bien, solo que más chica que la versión anterior.

## Resultados
`dart format --set-exit-if-changed lib test`: sin cambios.

`flutter analyze`:
```
No issues found!
```
`flutter test` (135 pruebas):
```
+135: All tests passed!
```
- Imágenes:
  - `ImagenesApp.todas` tiene 30 rutas únicas.
  - Cada ruta **existe en disco**, su carpeta está **declarada en `pubspec.yaml`** y carga desde el bundle.
  - Las medidas en px de los 20 logos coinciden con `FormaLogo`.
- `LogoApp`:
  - El tono automático es color en claro y negativo en oscuro; un tono fijo se respeta en cualquier modo.
  - El alto sale de la proporción de cada forma.
  - Tiene la etiqueta "AboGator", o ninguna si es decorativo.
- `SarkoImagen`: las 4 poses en caja 4:5, con `contain` y `bottomCenter`.
- Splash:
  - Logo sobre verde a 323.7×187.8, sin la tarjeta marcador.
  - En modo oscuro conserva el fondo verde bosque, el lema y "Powered by" en `fondo/destacado` claro, y los puntos en blanco.
- Galería: 20 logos y sin desbordes con texto al 200 %.

## Decisiones
- **Splash con colores de marca fijos** (decisión de Chat sobre D2 de T-02). En el código se usa `TokensColor.claro` directamente: no hay hex sueltos, sigue siendo un token.
- **Fondos fijos en la galería** para negativo, sobreAzul y sobreVerde, porque los tokens del modo oscuro no sirven de fondo de marca.
- **Logo del Splash decorativo:** la etiqueta única del Splash ya incluye "AboGator".
- **`LogoApp`** recibe `ancho` en lugar de `alto`: la proporción sale del archivo, y la tarea da el ancho (323.7).
- **Carpetas `Imegenes/` sin borrar:** solo las ignoro en git; los originales y las láminas siguen en tu computadora.

## Grafo actualizado
Toqué la sección 4 (Código), la línea "Última actualización" y el registro de cambios. Comprobé con `ls` que todas las rutas de la sección 4 existen.
- **Cambiados (`en curso`):** RECURSOS (forma × tono), COMP-LOGO (PNG de Figma y tono automático), COMP-SARKO (alineado abajo), CODIGO-PANT-01 (logo real y verde fijo), PANT-GALERIA, ASSETS-IMG, CONF (`.gitignore`), TEST-COMP, TEST-BIENVENIDA y TEST-GALERIA.
- **Nuevos:** ASSETS-LOGOS, ASSETS-SARKO, ASSETS-ICONO-APP y DEC-SPLASH-MARCA.
- **Obsoletos:** ninguno. Los PNG provisionales de T-01 no tenían nodo propio.
- La fila PANT-01 (sección 5) ya tenía la ruta del código; no cambió.

## Dudas
- **D1 · Sarko alegre más chica.** Su archivo tiene más margen transparente que las otras poses, así que en la misma caja el personaje se ve ≈ 27 % más chico. ¿Se reexporta recortada como las demás, o se acepta así? No la escalé por mi cuenta.
- **D2 · Resolución 3x.** Todos los logos, poses e íconos están a ~1x; quedo pendiente de la reexportación. Para las tiendas también falta el ícono de la app a 1024×1024.
- **D3 · sobreAzul y sobreVerde.** Isotipo y vertical son idénticos en los dos tonos, pero horizontal y extendido no. ¿Es intencional en Figma o falta diferenciar el isotipo y el vertical?
- **D4 · Grafo, estados de T-02.** Algunos nodos de T-02 (por ejemplo PANT-GALERIA o TEST-BIENVENIDA) seguían en `en curso` aunque T-02 ya está mergeada. Los dejé en `en curso` porque FIX-02 los vuelve a tocar; Chat decidirá al cerrar.
