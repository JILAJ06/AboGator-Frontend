# Grafo de conocimiento · AboGator Frontend

Mapa navegable del proyecto: qué existe, dónde está y con qué se relaciona. **Se actualiza cada vez que se crea, mueve, renombra o elimina algo** (reglas en `ai/conocimiento/06-grafo-de-conocimiento.md`). Si algo de aquí no coincide con la realidad, el grafo está mal y hay que corregirlo.

Última actualización: 2026-11-18 · por Claude Chat · tarea: documentación inicial

## Cómo leerlo
- Cada fila es un **nodo** con un ID único. La columna **Relaciones** son las **aristas**: `→` apunta a otro nodo, con un verbo corto (`usa`, `muestra`, `navega a`, `implementa`, `depende de`, `define`).
- **Estado**: `planeado` · `en curso` · `hecho` (ya mergeado a `develop`) · `obsoleto`.
- **Ruta**: ruta real en el repo. `—` si aún no existe.
- Para encontrar algo: buscar su ID o nombre en este archivo y seguir las aristas.

## Vista general
```mermaid
flowchart LR
  FIGMA[Figma: diseño] --> DOC[ai/conocimiento]
  DOC --> TAREAS[Tareas T-00..T-14]
  TAREAS --> CODIGO[lib/: tema, datos, funciones, componentes]
  CODIGO --> MOCKS[Repositorios mock]
  MOCKS -.T-14.-> API[Backend: otro equipo]
  TAREAS --> PANT[46 pantallas]
```

## 1 · Documentos del flujo (los mantiene Claude Chat)
| ID | Nombre | Ruta | Estado | Relaciones |
|---|---|---|---|---|
| DOC-00 | Proyecto | ai/conocimiento/00-proyecto.md | hecho | → define alcance; → EXT-FIGMA |
| DOC-01 | Flujo de trabajo | ai/conocimiento/01-flujo-de-trabajo.md | hecho | → define ramas y ciclo; → GRAFO |
| DOC-02 | Diseño: tokens | ai/conocimiento/02-diseno-tokens.md | hecho | → define TEMA |
| DOC-03 | Pantallas | ai/conocimiento/03-pantallas.md | hecho | → lista PANT-* |
| DOC-04 | Plan de tareas | ai/conocimiento/04-plan-de-tareas.md | hecho | → lista T-* |
| DOC-05 | Reglas y seguridad | ai/conocimiento/05-reglas-y-seguridad.md | hecho | → aplica a todo el código |
| DOC-06 | Reglas del grafo | ai/conocimiento/06-grafo-de-conocimiento.md | hecho | → define GRAFO |
| GRAFO | Este archivo | ai/grafo.md | hecho | ← lo actualizan Claude Chat y Claude Code |
| SIG | Tarea actual | ai/siguiente.md | en curso | → apunta a la tarea T-* vigente |
| REP | Reporte | ai/reporte.md | en curso | ← lo escribe Claude Code; → responde a SIG |

## 2 · Externos
| ID | Nombre | Dónde | Relaciones |
|---|---|---|---|
| EXT-FIGMA | Diseño de Figma | fileKey SYNAyUal3xVk4k8SEBEb7f | → fuente de PANT-*, TEMA, COMP-* |
| EXT-BACK | Backend (FastAPI) | repositorio de otros compañeros | ← lo consume REPO-* en T-14 |
| EXT-BD | Base de datos (PostgreSQL) | repositorio de otros compañeros | ← la usa EXT-BACK |
| EXT-ASSETS | Logos, Sarko, íconos, fuentes | por exportar de Figma | → los usan COMP-SARKO y TEMA |

## 3 · Tareas
| ID | Rama | Estado | Pantallas / áreas | Depende de |
|---|---|---|---|---|
| T-00 | 00-base-del-proyecto | en curso | proyecto Flutter, TEMA, DATOS, RUTAS | — |
| T-01 | 01-componentes-base | planeado | COMP-* | T-00 |
| T-02 | 02-bienvenida | planeado | PANT-01..04 | T-01 |
| T-03 | 03-acceso | planeado | PANT-05, PANT-06 | T-01 |
| T-04 | 04-inicio-y-mapa | planeado | PANT-07, 07b, 08, 09 | T-01 |
| T-05 | 05-tarjeta-swipe | planeado | PANT-10, 11, 11b, 11c, 13 | T-01 |
| T-06 | 06-veredictos | planeado | PANT-12, 12b, 12c, 14, 14b, 19, 19b | T-05 |
| T-07 | 07-evidencia-y-comodines | planeado | PANT-15, 16, 16b, 17, 18, 10b, 10c | T-05 |
| T-08 | 08-vidas-y-offline | planeado | PANT-20, 23 | T-06 |
| T-09 | 09-apelaciones | planeado | PANT-21b, 21, 22, 22b | T-06 |
| T-10 | 10-tienda-perfil-ajustes | planeado | PANT-24, 25, 26, 26b | T-01 |
| T-11 | 11-nivel-jefe | planeado | PANT-27, 28, 28b, 28c, 29, 30 | T-05 |
| T-12 | 12-tablet | planeado | variantes de tablet | T-02..T-11 |
| T-13 | 13-accesibilidad-y-pulido | planeado | todas | T-12 |
| T-14 | 14-integracion-api | planeado | REPO-* → HTTP | EXT-BACK listo |

## 4 · Código (lo mantiene Claude Code; todo `—` hasta que exista)
| ID | Nombre | Ruta | Estado | Relaciones |
|---|---|---|---|---|
| APP | App y configuración | lib/app/ | — | → usa RUTAS, TEMA |
| RUTAS | Enrutador y constantes de rutas | lib/app/rutas.dart | — | → navega a PANT-* |
| TEMA | Tema claro/oscuro y tokens | lib/core/tema/ | — | ← define DOC-02; → lo usan todos los COMP-* y PANT-* |
| TEXTOS | Textos centralizados | lib/core/textos/ | — | → los usan las pantallas |
| MOD | Modelos de datos | lib/datos/modelos/ | — | → los usan REPO-* |
| REPO-* | Interfaces de repositorio (auth, progreso, tarjetas, vidas, apelaciones, tienda) | lib/datos/repositorios/ | — | → implementan MOCK-*; en T-14 → HTTP |
| MOCK-* | Repositorios simulados | lib/datos/mocks/ | — | → implementan REPO-* |
| COMP-* | Componentes reutilizables (botones, campos, chips HUD, corazones, indicadores, navegación inferior, Sarko, paginador) | lib/componentes/ | — | → los usan PANT-*; → usan TEMA |
| COMP-SARKO | Sarko (marcador hasta tener imágenes) | lib/componentes/ | — | ← EXT-ASSETS |
| TEST-TEMA | Pruebas del tema | test/ | — | → verifican TEMA |
| CI | Flujo de integración continua | .github/workflows/ci.yml | — | → ejecuta análisis y pruebas |

## 5 · Pantallas (46, según Figma) y a dónde llevan
Código de cada pantalla: `lib/funciones/<área>/` (— hasta que exista).

| ID | Pantalla | Tarea | Navega a |
|---|---|---|---|
| PANT-01 | Splash | T-02 | 02 (a los 2 s) |
| PANT-02 | Onboarding 1: Sarko se presenta | T-02 | 03 · Omitir → 05 |
| PANT-03 | Onboarding 2: swipe en 4 direcciones | T-02 | 03b · Omitir → 05 |
| PANT-03b | Onboarding 3: indicadores de la Startup | T-02 | 04 · Omitir → 05 |
| PANT-04 | Onboarding 4: vidas y apelaciones | T-02 | 05 |
| PANT-05 | Inicio de sesión | T-03 | 07 · Crear cuenta → 06 |
| PANT-06 | Registro (dos consentimientos separados) | T-03 | 07 · Iniciar sesión → 05 |
| PANT-07 | Inicio: mapa de módulos | T-04 | 08 · pestañas 21, 24, 25 |
| PANT-07b | Inicio en modo oscuro | T-04 | igual que 07 |
| PANT-08 | Mapa de sprints | T-04 | 09 · nodo Examen final → 27 |
| PANT-09 | Intro del sprint | T-04 | 10 |
| PANT-10 | Tarjeta normal | T-05 | 11, 13, 11b, 11c |
| PANT-11 | Arrastrando a Ilegal (←) | T-05 | 12 o 14 |
| PANT-11b | Arrastrando a Condicional (↑) | T-05 | 12, 12c o 14 |
| PANT-11c | Arrastrando a Escalar (↓) | T-05 | 12, 12c o 14 |
| PANT-13 | Arrastrando a Legal (→) | T-05 | 12 o 14 |
| PANT-12 | Veredicto correcto (¿Por qué?) | T-06 | 12b o siguiente tarjeta |
| PANT-12b | Bonus ganado (+5 XP) | T-06 | siguiente tarjeta |
| PANT-12c | Respuesta parcial | T-06 | siguiente tarjeta |
| PANT-14 | Veredicto incorrecto (−1 vida) | T-06 | siguiente · Riesgo 100% → 19b · vidas 0 → 20 |
| PANT-14b | Amparo activado | T-06 | siguiente tarjeta |
| PANT-19 | Sprint completado | T-06 | 08 · Repasar fallos → 21 |
| PANT-19b | Startup en quiebra | T-06 | 09 · buzón → 21 |
| PANT-15 | Tarjeta con evidencia | T-07 | 16 |
| PANT-16 | Inspeccionar evidencia | T-07 | 16b · volver a 15 |
| PANT-16b | Línea subrayada | T-07 | volver y decidir (15) |
| PANT-17 | Tarjeta de justificación | T-07 | 18 |
| PANT-18 | Justificar veredicto | T-07 | 12b |
| PANT-10b | Comodín Lupa de Auditor | T-07 | 10 |
| PANT-10c | Comodín Abogado Senior | T-07 | 10 |
| PANT-20 | Sin vidas (cuenta regresiva del servidor) | T-08 | 21 · volver |
| PANT-23 | Sin conexión (offline-first) | T-08 | tarjeta normal |
| PANT-21b | Notificación de apelación | T-09 | 22 |
| PANT-21 | Buzón de Apelaciones | T-09 | 22 |
| PANT-22 | Juicio de apelación | T-09 | 22b |
| PANT-22b | Apelación ganada (+1 vida) | T-09 | 21 |
| PANT-24 | Tienda | T-10 | pestañas |
| PANT-25 | Perfil y progreso | T-10 | 26 |
| PANT-26 | Ajustes de accesibilidad | T-10 | 25 |
| PANT-26b | Navegación por teclado y foco | T-10 | — |
| PANT-27 | Crisis: ransomware | T-11 | 28 · ahora no → 08 |
| PANT-28 | Decisión de crisis | T-11 | 28b |
| PANT-28b | Contraargumento del Jefe | T-11 | 28c |
| PANT-28c | Golpe al Jefe (−20 HP) | T-11 | 28 · HP 0 → 29 · 0 vidas o tiempo → 30 |
| PANT-29 | Auditoría superada (certificado) | T-11 | 07 (Módulo 2) |
| PANT-30 | La Inspectora ganó | T-11 | 21 |

## 6 · Conceptos del juego (para saber qué pantallas los tocan)
| ID | Concepto | Pantallas que lo muestran | Reglas |
|---|---|---|---|
| CON-SWIPE | Swipe en 4 direcciones | 03, 10, 11*, 13, 22, 28 | → Legal, ← Ilegal, ↑ Condicional, ↓ Escalar; siempre con botón equivalente |
| CON-VIDAS | Vidas (máx. 5, +1 cada 2 h, tiempo del servidor) | 04, 14, 20, 22b, 30 | — |
| CON-STARTUP | Indicadores (Presupuesto, Reputación, Velocidad, Riesgo legal) | 03b, 10, 12, 14, 19b | Riesgo 100% o sin presupuesto → quiebra |
| CON-APELA | Apelaciones (día 3, 7 y 14) | 21, 21b, 22, 22b | +1 vida al ganar; no avanzan el mapa |
| CON-COMODIN | Comodines (Lupa, Abogado, Amparo) | 10b, 10c, 14b, 24 | Desactivados en el Examen Final (RN03) |
| CON-JEFE | Nivel Jefe de 72 h | 27, 28, 28b, 28c, 29, 30 | 10 decisiones de 15 s (22 s con tiempo extendido) |
| CON-OFFLINE | Modo sin conexión | 23 | Respuestas en SQLite con UUID de cliente |

## Registro de cambios del grafo
- 2026-11-18 · Claude Chat · creación del grafo con documentos, tareas, pantallas y conceptos; código aún sin nodos reales.
