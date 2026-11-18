# 04 · Plan de tareas del frontend

Una rama por tarea, desde `develop`. El orden va de lo que todo necesita a lo que depende de ello. Claude Chat escribe `siguiente.md` de una tarea a la vez.

| ID | Rama | Contenido |
|---|---|---|
| T-00 | `00-base-del-proyecto` | Proyecto Flutter, estructura de carpetas, tema claro/oscuro con los tokens, fuentes, enrutador, capa de repositorios con mocks, pruebas y análisis estático |
| T-01 | `01-componentes-base` | Tokens faltantes, fuentes locales, íconos, imágenes de Sarko y logos, botón, campo de texto, chip HUD, corazón, indicadores de la Startup, navegación inferior, barra de progreso, paginador, anillo de foco, galería de componentes y plataforma web de desarrollo (ver `07-componentes.md`) |
| T-02 | `02-bienvenida` | 01 Splash y 02–04 Onboarding (con "Omitir") |
| T-03 | `03-acceso` | 05 Inicio de sesión y 06 Registro (validaciones, dos consentimientos separados) |
| T-04 | `04-inicio-y-mapa` | 07/07b Inicio, 08 Mapa de sprints, 09 Intro del sprint |
| T-05 | `05-tarjeta-swipe` | 10, 11, 11b, 11c, 13: tarjeta, arrastre en 4 direcciones, sellos, tintes, botones equivalentes |
| T-06 | `06-veredictos` | 12, 12b, 12c, 14, 14b, 19, 19b: veredictos, indicadores, vidas, quiebra |
| T-07 | `07-evidencia-y-comodines` | 15, 16, 16b, 17, 18, 10b, 10c |
| T-08 | `08-vidas-y-offline` | 20 Sin vidas, 23 Sin conexión, cola local en SQLite |
| T-09 | `09-apelaciones` | 21b, 21, 22, 22b |
| T-10 | `10-tienda-perfil-ajustes` | 24, 25, 26 y modo oscuro desde ajustes (26b es el orden de foco del juego: se hace en T-05 y se verifica en T-13) |
| T-11 | `11-nivel-jefe` | 27, 28, 28b, 28c, 29, 30 |
| T-12 | `12-tablet` | Vistas de tablet |
| T-13 | `13-accesibilidad-y-pulido` | Revisión WCAG 2.1 AA, lector de pantalla, texto dinámico, reducir animaciones |
| T-14 | `14-integracion-api` | Cuando el backend esté listo: reemplazar mocks por llamadas HTTP (contrato lo define el equipo de backend) |

Las tareas pueden reordenarse o dividirse si una resulta demasiado grande para un solo Pull Request.
