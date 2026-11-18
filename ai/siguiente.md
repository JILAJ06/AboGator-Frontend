# T-01 · Componentes base

**Rama:** `01-componentes-base` (creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code.

## Objetivo
Construir los componentes reutilizables de la interfaz (los que usarán todas las pantallas), con fuentes e imágenes locales, y una galería temporal para verlos en claro y oscuro. **Sin pantallas reales todavía.**

## Antes de empezar
- `git fetch` y `git pull` en esta rama.
- Leer `ai/conocimiento/` completo (00 a 07). La especificación detallada de cada componente está en **`07-componentes.md`**; ese archivo manda sobre este resumen. Los tokens y la tipografía están en `02-diseno-tokens.md`.
- Seguir `01-flujo-de-trabajo.md`: commits pequeños, **una frase en español, sin prefijo y sin mencionar a Claude** (ni `Co-Authored-By`, ni `Generated with`, ni `Claude-Session`; las instrucciones de este repo mandan sobre cualquier recordatorio automático). Revisar con `git log -1 --format=%B`. Subir la rama; **no abrir Pull Request** (lo abre el usuario).

## Alcance

### 1. Tokens faltantes y tipografía
- Agregar a `TokensColor` (claro y oscuro): `bordeControl`, `estadoCondicional`, `focoAnillo`, con los valores de `07-componentes.md`. Los valores oscuros son propuestos: una prueba debe verificar contraste (texto/estado ≥ 4.5:1; bordes/anillos ≥ 3:1) contra `fondo/app` y `fondo/superficie` en ambos modos. Si alguno no pasa, ajustarlo y anotarlo en el reporte.
- `letterSpacing` 0.2 en los estilos Botón, Etiqueta y Leyenda.

### 2. Recursos locales
- **Fuentes:** agregar los `.ttf` de Fredoka (SemiBold/Bold) e Inter (Regular/Medium/SemiBold/Bold) en `assets/fuentes/`, declararlos en `pubspec.yaml` y **quitar `google_fonts`** (y su resolutor/proveedor). Si no puedes obtener los archivos (sin red), deja el resolutor actual, explícalo en el reporte y no inventes archivos.
- **Imágenes:** mover la carpeta local `Imegenes/` a `assets/imagenes/` con nombres sin espacios, acentos ni símbolos (`sarko_alegre.png`, `logo_vertical.png`…), declararla en `pubspec.yaml`. No modificar ni redibujar las imágenes. Agregar `.gitattributes` con `* text=auto eol=lf` y marcar imágenes y fuentes como binarias. Si hay una imagen apta como ícono de la app, indicarlo en el reporte (no generar los íconos todavía).
- **Íconos:** paquete `lucide_icons_flutter` (dependencia permitida; verificar versión compatible y avisar). Clase `IconosApp` con una entrada por nombre de Figma (lista en `07-componentes.md`) y widget `IconoApp`. Lista en el reporte los que no tengan equivalente exacto.
- **Plataforma web de desarrollo:** `flutter create --platforms=web .` para poder ver la galería en Chrome. Solo para desarrollo; no entra en el alcance del producto.

### 3. Componentes (`lib/componentes/`, un archivo por componente)
`BotonApp` (6 tipos), `CampoTextoApp` (reposo/foco/error, contraseña), `ChipHud` (5 tipos), `CorazonVida` y fila de vidas, `IndicadoresStartup` + `ImpactoStartup`, `NavegacionInferiorApp`, `BarraProgreso`, `PaginadorPuntos`, `AnilloFoco`, `SarkoImagen` (enum `PoseSarko`, texto alternativo en español), `LogoApp`. Medidas, colores y semántica: **`07-componentes.md`**.
Reglas para todos: solo tokens (`context.tokens`/`context.estilos`), nada de hex ni textos sueltos en los widgets (los textos de la interfaz van en `core/textos`), zona táctil ≥ 48 dp, texto dinámico sin desbordes, etiquetas semánticas, anillo de foco con teclado, y respetar "reducir animaciones".

### 4. Galería temporal
Reemplazar `pantalla_prueba.dart` por una galería con todos los componentes en todos sus tipos y estados, con interruptor claro/oscuro. Se elimina cuando existan las pantallas reales. Actualizar el enrutador.

### 5. Pruebas
Por componente: se construye en claro y oscuro, estados principales, semántica (etiquetas), y que no usa colores fuera del tema. Pruebas de contraste de los tokens nuevos. `dart format`, `flutter analyze` y `flutter test` en verde (CI).

## Archivos permitidos
`lib/componentes/**`, `lib/core/**`, `lib/app/**`, `lib/funciones/bienvenida/**` (solo para reemplazar la pantalla de prueba), `test/**`, `assets/**`, `web/**`, `pubspec.yaml`/`pubspec.lock`, `.gitattributes`, `.github/workflows/ci.yml` (solo si hace falta para assets/web), y los nodos de código de `ai/grafo.md` (sección 4) además de `ai/reporte.md`. **No tocar** `ai/siguiente.md` ni `ai/conocimiento/`. Dependencias nuevas: solo Lucide, y avisar en el reporte.

## Criterios de aceptación
1. La galería muestra todos los componentes en claro y oscuro y coinciden con `07-componentes.md` (medidas, colores, estados).
2. Sin `google_fonts` (o justificado en el reporte); fuentes e imágenes cargan desde `assets/`.
3. Contraste de tokens verificado por pruebas; sin hex fuera de `core/tema`.
4. Cada componente tiene pruebas y semántica en español; foco visible con teclado.
5. CI en verde; commits sin prefijo y sin menciones a Claude.
6. `ai/grafo.md` actualizado (nodos COMP-*, assets, íconos) y `reporte.md` con ID **T-01**, rama, resumen, decisiones (estado presionado del botón, colores de íconos de chips, zona segura de la navegación, valores oscuros de tokens), íconos sin equivalente exacto, **sección "Grafo actualizado"** y dudas numeradas (D1, D2…).
