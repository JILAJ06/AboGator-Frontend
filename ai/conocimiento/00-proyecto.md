# 00 · Proyecto AboGator (frontend)

## Qué es
AboGator (motor técnico: LawSwipe) es una app móvil educativa y gamificada para enseñar Derecho Informático, normativa de TI y cumplimiento legal a desarrolladores y estudiantes de TI. El usuario lee casos prácticos en tarjetas y desliza para decidir. La mascota es Sarko, un cocodrilo vestido de juez.

## Alcance de este repositorio
- **Solo frontend** (Flutter, móvil y tablet).
- El backend (Python/FastAPI) y la base de datos (PostgreSQL) los hacen otras dos personas en repositorios aparte. **No se crean aquí.**
- Mientras el backend no exista, la app trabaja con **datos simulados (mocks)** detrás de interfaces de repositorio, de modo que luego solo se cambie la implementación por llamadas HTTP.

## Stack del frontend
- Flutter (iOS, Android, tablet). Modo claro y oscuro desde el inicio.
- Persistencia local con SQLite (offline-first): las respuestas se guardan en el dispositivo y se sincronizan después, con un UUID generado por el cliente por cada respuesta (idempotencia).
- Fuentes: Fredoka (títulos, botones), Inter (cuerpo), JetBrains Mono (código en evidencias).
- Accesibilidad WCAG 2.1 AA: lector de pantalla (TalkBack/VoiceOver), alternativa de toque al swipe, texto dinámico, reducir animaciones, navegación por teclado.

## Mecánica del juego (resumen)
- **Swipe en 4 direcciones**: → Legal · ← Ilegal · ↑ Legal con condiciones · ↓ Escalar al área jurídica. Cada dirección tiene su botón equivalente (accesibilidad).
- **Indicadores de la Startup**: Presupuesto, Reputación, Velocidad y Riesgo legal. Si el Riesgo legal llega a 100% o el presupuesto se agota, la Startup quiebra.
- **Vidas**: máximo 5; cada error resta una; se regenera 1 cada 2 horas (tiempo controlado por el servidor).
- **Tipos de tarjeta**: normal (≈60%), con evidencia (≈30%, se inspecciona un snippet/cláusula y se puede subrayar) y de justificación (≈10%, tras decidir se pide el porqué; acertar da recompensa doble).
- **Comodines** (tienda): Lupa de Auditor, Abogado Senior, Amparo. No funcionan en el Examen Final (regla RN03).
- **Apelaciones (Buzón)**: los fallos regresan a los 3 y 7 días (y 14 al ganar); ganar una apelación devuelve 1 vida; no avanzan el mapa.
- **Nivel Jefe / Examen Final**: crisis de 72 horas (ransomware), 10 decisiones de 15 s cada una (22 s con tiempo extendido), contraargumentos de la Inspectora Vega, HP del Jefe. Al aprobar: certificado del módulo.
- **Módulos** (color propio), **orden definitivo decidido por el usuario el 2026-11-21** (de lo básico a lo complejo para un ingeniero de software principiante): 1 Licencias y Propiedad Intelectual, 2 Protección de Datos, 3 Delitos Informáticos, 4 Contratos Digitales, 5 Auditoría y Cumplimiento.
  - **Pendiente de aplicar en el código:** hoy el mock tiene Protección de Datos como módulo 1 (`mod-1`) y es el único con tarjetas y el Examen del ransomware; Licencias aún no tiene contenido. El orden real lo traerá el servidor (`numero`) en la T-14. Los ids no cambian; el color sigue a cada módulo, no a su posición.

## Idioma
Toda la interfaz y los textos están en **español (México)**. El código (nombres de clases y variables) puede estar en inglés o español, pero debe ser consistente con la convención que fije la tarea T-00.

## Fuente de verdad del diseño
Archivo de Figma, fileKey `SYNAyUal3xVk4k8SEBEb7f`. Claude Chat lee Figma y traduce cada pantalla a medidas, colores, textos y estructura dentro de `ai/siguiente.md`; Claude Code no depende del conector de Figma.
