# 04 · Plan de tareas del frontend

Una rama por tarea, desde `develop`. El orden va de lo que todo necesita a lo que depende de ello. Claude Chat escribe `siguiente.md` de una tarea a la vez.

| ID | Rama | Contenido |
|---|---|---|
| T-00 | `00-base-del-proyecto` | Proyecto Flutter, estructura de carpetas, tema claro/oscuro con los tokens, fuentes, enrutador, capa de repositorios con mocks, pruebas y análisis estático |
| T-01 | `01-componentes-base` | Tokens faltantes, fuentes locales, íconos, imágenes de Sarko y logos, botón, campo de texto, chip HUD, corazón, indicadores de la Startup, navegación inferior, barra de progreso, paginador, anillo de foco, galería de componentes y plataforma web de desarrollo (ver `07-componentes.md`) |
| T-02 | `02-bienvenida` | 01 Splash y 02–04 Onboarding (con "Omitir"), `BotonVeredicto` y token estado/escalar |
| T-03 | `03-acceso` | 05 Inicio de sesión y 06 Registro (validaciones, dos consentimientos separados) |
| T-04 | `04-inicio` | 07/07b Inicio (héroe, reto diario, módulos, Buzón, navegación inferior) |
| T-04b | `04b-mapa-e-intro` | 08 Mapa de sprints, 09 Intro del sprint |
| T-05 | `05-tarjeta-swipe` | 10, 11, 11b, 11c, 13: tarjeta, arrastre en 4 direcciones, sellos, tintes, botones equivalentes |
| T-06 | `06-veredictos` | 12, 12b, 12c, 14, 14b: panel de veredicto, calificación, indicadores, vidas, XP y monedas |
| T-06b | `06b-fin-de-sprint` | 19, 19b: sprint completado y Startup en quiebra, tarjetas de los demás sprints |
| T-07 | `07-evidencia-y-comodines` | 15, 16, 16b, 17, 18: tarjetas con evidencia y de justificación (el nombre de la rama se conserva) |
| T-07b | `07b-comodines` | 10b, 10c y el Amparo (14b activable); cantidades desde la tienda; deshabilitados en el examen |
| T-08 | `08-vidas-y-offline` | 20 Sin vidas, 23 Sin conexión, cola local en SQLite |
| T-09 | `09-apelaciones` | 21 Buzón, 21b notificación (texto y enlace profundo), registro de fallos en el Buzón |
| T-09b | `09b-juicio-apelacion` | 22 Juicio de apelación, 22b Apelación ganada (y la perdida), +1 vida |
| T-10 | `10-tienda-perfil-ajustes` | 24 Tienda (con compra) y 25 Perfil y progreso (el nombre de la rama se conserva) |
| T-10b | `10b-ajustes-accesibilidad` | 26 Ajustes de accesibilidad, modo oscuro forzado y ajustes guardados en SQLite (26b es el orden de foco del juego: se hizo en T-05 y se verifica en T-13) |
| T-11 | `11-nivel-jefe` | Motor del Examen Final y 27 Crisis, 28 Decisión de crisis, 28b Contraargumento del Jefe, 28c Golpe al Jefe |
| T-11b | `11b-resultado-examen` | 29 Auditoría superada (certificado), 30 La Inspectora ganó, registro del resultado y desbloqueo del módulo siguiente |
| T-12 | `12-tablet` | Base de tablet: clases de pantalla, riel de navegación (en `MarcoPrincipal`), acceso y onboarding (T01–T06) e Inicio (T07, T07b) |
| T-12b | `12b-tablet-mapa-y-cuenta` | Mapa de sprints + intro en lista-detalle (T08), Tienda (T24), Perfil (T25) y Ajustes (T26) |
| T-12c | `12c-tablet-juego` | Zona de juego + panel lateral y hojas laterales: T10–T19b, T10b, T10c, T14b |
| T-12d | `12d-tablet-buzon-y-examen` | Sin vidas (T20), Buzón + Juicio en lista-detalle (T21, T21b, T22, T22b), Sin conexión (T23) y Examen Final (T27–T30) |
| T-13 | `13-accesibilidad-y-pulido` | Revisión WCAG 2.1 AA, lector de pantalla, texto dinámico, reducir animaciones |
| T-14 | `14-integracion-api` | Cuando el backend esté listo: reemplazar mocks por llamadas HTTP (contrato lo define el equipo de backend) |

Las tareas pueden reordenarse o dividirse si una resulta demasiado grande para un solo Pull Request.
