# 01 · Flujo de trabajo (Claude Chat + Claude Code)

Dos instancias de Claude trabajan con el usuario como intermediario:
- **Claude Chat**: planea, lee el diseño, escribe tareas y revisa Pull Requests.
- **Claude Code**: programa, prueba y reporta.
- El usuario hace los merges.

## Archivos
- `ai/conocimiento/`: esta base de conocimiento (leer `00` a `08` en orden).
- `ai/siguiente.md`: la tarea actual. **Solo la escribe Claude Chat.**
- `ai/reporte.md`: estado, lo hecho y dudas numeradas (D1, D2…). **Solo lo escribe Claude Code** y lo reescribe completo en cada tarea.
- `ai/grafo.md`: **grafo de conocimiento** del proyecto (qué existe, dónde y con qué se relaciona). Lo actualizan las dos instancias; reglas en `06-grafo-de-conocimiento.md`.
- Cada tarea tiene ID (T-00, T-01…). El reporte repite el ID y el nombre de la rama; si no coinciden con `siguiente.md`, el reporte no corresponde.

## Ramas
- `main`: estable. No recibe merge hasta que la aplicación esté terminada.
- `develop`: integración; recibe los merges de las ramas de tareas ya revisadas.
- `NN-nombre-de-la-tarea` (por ejemplo `01-componentes-base`): una rama por bloque de trabajo, creada **desde `develop`**.
- `fix/NN-nombre-de-la-tarea`: arreglos de una tarea ya terminada, también desde `develop`.
- Nombres en minúsculas, sin acentos, sin espacios ni dos puntos.

## Ciclo de una tarea
1. Claude Chat crea la rama desde `develop`, escribe `ai/siguiente.md` en esa rama (y marca la tarea `en curso` en el grafo) y la sube.
2. El usuario le dice a Claude Code: "sigue con siguiente.md en la rama `<rama>`".
3. Claude Code hace checkout de la rama, trabaja con commits pequeños, **actualiza `ai/grafo.md` con lo que crea o cambia**, reescribe `ai/reporte.md` (con su sección "Grafo actualizado") y **sube la rama**. **El Pull Request lo abre el usuario en GitHub** (hacia `develop`); Claude Code no abre PRs.
4. El usuario le dice a Claude Chat "revisa, Claude Code ya terminó". Claude Chat hace pull, lee el reporte y el PR, revisa contra el diseño, responde dudas y, si hay cambios, escribe un nuevo `siguiente.md` en la **misma rama**.
5. Si todo está bien, el usuario hace el merge a `develop` con **merge commit** (no squash ni rebase).
6. Errores posteriores: rama `fix/...` desde `develop` y se repite el ciclo.

## Reglas de commits y Pull Requests
- Mensajes **sin prefijo** (nada de `feat:`, `fix:`, `chore:`): una frase en español que diga qué se hizo. Commits pequeños y graduales.
- Los commits y los PR **no mencionan a Claude**: nada de `Co-Authored-By: Claude`, `Generated with Claude Code` ni `Claude-Session`. El autor es el usuario. Revisar con `git log -1 --format=%B` antes de subir.
- Nunca commit directo a `main` ni a `develop` (salvo documentación que el flujo permita).
- Claude Code nunca hace merge ni abre Pull Requests.
- Título del PR (que escribe el usuario): una frase; descripción corta, sin menciones a Claude.

## Checklist de revisión de un PR
- Coincide con el diseño y con los criterios de aceptación de `siguiente.md`.
- No se tocó nada fuera del alcance; no hay dependencias nuevas sin avisar.
- Se respetan las reglas de `05-reglas-y-seguridad.md`.
- El reporte responde a la tarea, las dudas están numeradas y el build pasó.
- Commits sin prefijo y sin menciones a Claude.
- **El grafo (`ai/grafo.md`) está al día**: nodos nuevos con ruta real, relaciones correctas, estados coherentes y registro de cambios. Si no, el PR no se aprueba.

## Prompt de arranque para Claude Code (primera vez en el repo)
Hacer `git fetch`, leer `ai/conocimiento/` en orden y `ai/grafo.md`, resumir que se entendió el flujo (incluida la regla de actualizar el grafo) y **no tocar código** hasta que el usuario diga "sigue con siguiente.md en la rama `<rama>`".
