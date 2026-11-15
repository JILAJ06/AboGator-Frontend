# T-00 · Base del proyecto

**Rama:** `00-base-del-proyecto` (creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code.

## Objetivo
Dejar el proyecto Flutter listo para que las siguientes tareas solo agreguen pantallas: estructura de carpetas, tema claro/oscuro con los tokens del diseño, fuentes, enrutador, capa de datos con mocks y una pantalla temporal que demuestre que el tema funciona. **Sin pantallas reales todavía.**

## Antes de empezar
Leer `ai/conocimiento/` completo, en orden (00 a 05). Seguir `01-flujo-de-trabajo.md`: commits pequeños, sin prefijo, sin mencionar a Claude; subir la rama; **no abrir Pull Request** (lo abre el usuario).

## Especificaciones

### 1. Proyecto Flutter
- Crear el proyecto en la raíz del repo (no en una subcarpeta) con `flutter create`, nombre de paquete `abogator`, organización `mx.abogator` (confirmar en el reporte si algo no se pudo), plataformas **android e ios**.
- Conservar `README.md` y `ai/`. Agregar `.gitignore` estándar de Flutter.
- Orientación: vertical en móvil (la tablet se atiende en T-12).
- Idioma de la app: español de México (`es_MX`); configurar localizaciones.

### 2. Estructura de carpetas (`lib/`)
```
lib/
  main.dart
  app/            (MaterialApp, enrutador, configuración)
  core/
    tema/         (colores, tokens, tipografía, tema claro y oscuro)
    textos/       (textos de la interfaz centralizados)
    utilidades/
  datos/
    modelos/      (clases de datos: usuario, módulo, sprint, tarjeta, etc.)
    repositorios/ (interfaces abstractas)
    mocks/        (implementaciones simuladas con datos de ejemplo)
  funciones/      (una carpeta por área: bienvenida, acceso, inicio, juego, apelaciones, tienda, perfil, jefe)
  componentes/    (widgets reutilizables; vacío por ahora)
```
Gestor de estado: usar **Riverpod** (`flutter_riverpod`). Enrutador: **go_router**. Justificar en el reporte si se propone otra cosa.

### 3. Tema (la parte más importante de esta tarea)
Crear los tokens de `ai/conocimiento/02-diseno-tokens.md` como una extensión de tema (`ThemeExtension`) con **dos instancias: claro y oscuro**. Nombres sugeridos: `fondoApp`, `fondoSuperficie`, `fondoSuperficieAlt`, `fondoDestacado`, `textoPrimario`, `textoSecundario`, `textoEnPrimario`, `textoAcento`, `bordeDefault`, `accionPrimaria`, `accionSecundaria`, `accionAcento`, `estadoLegal`, `estadoIlegal`. Valores **exactos** de la tabla (claro y oscuro).
- Agregar también los colores por módulo (5) y los de marca como constantes, para usos decorativos.
- Tipografía con los 11 estilos de la tabla (Display, H1, H2, H3, Cuerpo Grande/Base/Énfasis, Etiqueta, Leyenda, Botón, Código), con tamaño e interlineado exactos.
- Fuentes **Fredoka, Inter y JetBrains Mono**: usar el paquete `google_fonts` para el desarrollo, **o** incluirlas como archivos en `assets/fuentes/` (preferible a futuro, porque la app debe funcionar sin internet). Elegir una y anotar la decisión como duda D1 en el reporte.
- El modo (claro/oscuro) sigue al sistema por defecto y se podrá forzar desde ajustes (T-10): dejar un proveedor de estado para ello.
- Respetar texto dinámico del sistema (no fijar escala).

### 4. Capa de datos con mocks
- Definir en `datos/modelos/` clases simples e inmutables: `Usuario` (nombre, perfil: estudiante/desarrollador/legal, nivel, XP, racha), `Modulo` (id, nombre, color, sprints), `Sprint` (id, título, número de tarjetas, estado), `Tarjeta` (id, tipo: normal/evidencia/justificacion, texto, respuesta correcta entre `legal/ilegal/condicional/escalar`, explicación), `EstadoStartup` (presupuesto, reputación, velocidad, riesgoLegal), `Vidas` (cantidad máxima 5, próxima en).
- Definir interfaces abstractas en `datos/repositorios/` (autenticación, progreso/módulos, tarjetas, vidas, apelaciones, tienda) y sus implementaciones simuladas en `datos/mocks/` con un par de datos de ejemplo realistas en español (por ejemplo la tarjeta "Librería GPL en app cerrada").
- Los repositorios devuelven `Future` y simulan una pequeña espera. **Ninguna pantalla depende de una implementación concreta**, solo de la interfaz (a través de Riverpod), para cambiarla luego por HTTP en T-14.
- No crear código de red todavía.

### 5. Enrutador y pantalla de prueba
- `go_router` con una sola ruta `/` que muestre una pantalla temporal **"Tema de prueba"** (`funciones/…/pantalla_prueba.dart`): lista de cuadros con los 14 tokens de color con su nombre, los 11 estilos de texto con un texto de ejemplo, y un interruptor para alternar claro/oscuro. Se eliminará en T-02.
- Declarar ya las constantes de las rutas futuras (nombres en `app/rutas.dart`) según el inventario de `03-pantallas.md`, sin implementarlas.

### 6. Calidad
- `analysis_options.yaml` con `flutter_lints` y reglas razonables (comillas simples, `prefer_const_constructors`, etc.).
- Pruebas: (a) prueba unitaria que verifica los valores hex de los tokens claro y oscuro contra la tabla; (b) prueba de widget que monta la pantalla de prueba en ambos modos sin errores.
- `flutter analyze` sin avisos y `flutter test` en verde.
- GitHub Actions (`.github/workflows/ci.yml`): en cada push y Pull Request a `develop`, ejecutar `flutter pub get`, `flutter analyze` y `flutter test`.

## Archivos permitidos
Todo lo del proyecto Flutter nuevo, `.gitignore`, `.github/workflows/ci.yml`, `pubspec.yaml`, `analysis_options.yaml`, `assets/fuentes/` (si aplica) y `ai/reporte.md`. **No tocar** `ai/conocimiento/` ni `ai/siguiente.md`.

## Dependencias permitidas (sin aviso previo)
`flutter_riverpod`, `go_router`, `google_fonts` (o fuentes locales), `flutter_localizations`/`intl`, `flutter_lints`. Cualquier otra se avisa en el reporte con su razón.

## Criterios de aceptación
1. `flutter analyze` sin avisos; `flutter test` en verde; el CI definido.
2. La app abre en la pantalla de prueba y muestra los 14 tokens, los 11 estilos y alterna entre claro y oscuro con los valores exactos de la tabla.
3. Estructura de carpetas tal como se describe; sin lógica de pantalla en widgets de la capa de datos.
4. Los repositorios son interfaces con implementaciones mock; no hay llamadas de red.
5. Ningún color en hex fuera de `core/tema/`.
6. Commits sin prefijo, sin mención a Claude; rama subida; `reporte.md` reescrito con ID **T-00** y rama `00-base-del-proyecto`.

## Qué reportar (`ai/reporte.md`)
ID y rama, resumen de lo hecho, versión de Flutter usada, salida de `flutter analyze` y `flutter test`, decisiones (D1 fuentes, y cualquier otra) y dudas numeradas. Si el entorno no tiene Flutter instalado o no pudo ejecutar algo, decirlo claramente.
