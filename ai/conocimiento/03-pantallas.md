# 03 · Inventario de pantallas (Figma → app)

Numeración tal como aparece en Figma (página "Vistas", móvil 390×844). Cada tarea de `siguiente.md` detalla medidas, textos y estados de las pantallas que le tocan.

## Flujo 1 · Bienvenida y acceso
01 Splash (logo, 3 puntos de carga, "Powered by LawSwipe", pasa solo a los 2 s) · 02 Onboarding 1 (Sarko se presenta) · 03 Onboarding 2 (swipe en 4 direcciones) · 03b Onboarding 3 (indicadores de la Startup) · 04 Onboarding 4 (vidas y apelaciones) · 05 Inicio de sesión (correo + contraseña) · 06 Registro (perfil Estudiante/Desarrollador/Legal, nombre, correo, contraseña, dos casillas separadas: Aviso de Privacidad y Términos de uso).

## Flujo 2 · Navegación principal (barra inferior)
07 Inicio (mapa de módulos, HUD, reto diario) · 07b Inicio modo oscuro · 08 Mapa de sprints del módulo · 09 Intro del sprint · 21 Buzón de Apelaciones (pestaña) · 24 Tienda (pestaña) · 25 Perfil y progreso (pestaña) · 26 Ajustes de accesibilidad · 26b Navegación por teclado y foco.

## Flujo 3 · Swipe en 4 direcciones y consecuencias
10 Tarjeta normal · 11 Arrastrando a Ilegal (←) · 11b Arrastrando a Condicional (↑) · 11c Arrastrando a Escalar (↓) · 13 Arrastrando a Legal (→) · 12 Veredicto correcto (micro-pregunta "¿Por qué?") · 12b Bonus ganado (+5 XP por justificar) · 12c Respuesta parcial (sin perder vida) · 14 Veredicto incorrecto (−1 vida, el Riesgo sube) · 14b Amparo activado (el error no quita vida) · 19 Sprint completado · 19b Startup en quiebra (Riesgo legal 100%).

## Flujo 3b/3c · Evidencia, justificación y comodines
15 Tarjeta con evidencia · 16 Inspeccionar evidencia · 16b Línea subrayada · 17 Tarjeta de justificación (dilema clave ×2) · 18 Justificar veredicto (opciones rápidas) · 10b Comodín Lupa de Auditor · 10c Comodín Abogado Senior.

## Flujo 4 · Vidas y apelaciones
20 Sin vidas (cuenta regresiva del servidor) · 21b Notificación de apelación (día 3 / 7) · 21 Buzón · 22 Juicio de apelación · 22b Apelación ganada (+1 vida) · 23 Sin conexión (offline-first, respuestas guardadas en SQLite).

## Flujo 5 · Nivel Jefe: crisis de 72 horas
27 Crisis: ransomware · 28 Decisión de crisis (temporizador 15 s + barra del Jefe) · 28b Contraargumento del Jefe · 28c Golpe al Jefe (−20 HP) · 29 Auditoría superada (certificado) · 30 La Inspectora ganó (se reinicia).

## Mapa de navegación (resumen)
- 01 → 02 → 03 → 03b → 04 → 05 (cada paso "Siguiente"; "Omitir" salta a 05; 01 pasa a 02 a los 2 s). 05 ⇄ 06. Iniciar sesión → 07.
- 07 → 08 (tocar módulo) → 09 (nodo actual) → 10 (Comenzar sprint). Desde 08 el nodo Examen final lleva a 27. Pestañas: Inicio (07), Buzón (21), Tienda (24), Perfil (25); Perfil → Ajustes (26).
- 10: swipe ← 11, → 13, ↑ 11b, ↓ 11c. Acierto → 12 (→ 12b si se justifica bien) ; error → 14 (14b si hay Amparo; 12c si es parcial). Riesgo 100% → 19b. Vidas = 0 → 20. Fin de tarjetas → 19 → 08.
- 20 → 21 (repasar). 21 → 22 → 22b → 21. 21b abre 22.
- 27 → 28 → (28b contraargumento) → 28c golpe. HP del Jefe = 0 → 29 → 07 (Módulo 2). 0 vidas o tiempo → 30 → 21 (repasar).
