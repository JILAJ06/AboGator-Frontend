# 06 · Grafo de conocimiento: reglas de uso y mantenimiento

El grafo (`ai/grafo.md`) es el mapa del proyecto: qué existe, dónde está y con qué se relaciona. Sirve para encontrar cosas rápido sin recorrer todo el repositorio. **Solo sirve si está al día.**

## Regla principal
> **Cada vez que se cree, mueva, renombre, elimine o cambie de estado algo, se actualiza el grafo en la misma tarea y en el mismo Pull Request.** Un cambio sin su actualización del grafo se considera incompleto.

## Qué es un nodo
Todo lo que alguien podría necesitar encontrar: documentos, tareas, pantallas, carpetas y módulos de código, componentes reutilizables, repositorios y mocks, pruebas, flujos de CI, decisiones importantes, conceptos del juego y dependencias externas. Cada nodo tiene un ID único, ruta real, estado y relaciones.

## Cuándo se actualiza (disparadores)
- Se crea, renombra, mueve o elimina un archivo o carpeta con significado propio (no hace falta uno por cada archivo auxiliar).
- Se termina una pantalla o componente: poner su ruta real y el estado `en curso` o `hecho`.
- Cambia la navegación entre pantallas, una dependencia entre nodos o el alcance de una tarea.
- Se agrega, quita o cambia una dependencia (paquete) o una decisión relevante: nodo de tipo decisión con su porqué.
- Se actualiza el diseño en Figma: Claude Chat revisa los nodos de pantallas y tokens afectados.
- Se hace merge de una tarea: su estado pasa a `hecho` y se confirman las rutas de sus nodos.

## Quién actualiza qué
- **Claude Chat**: documentos (DOC-*), tareas (T-*), pantallas y navegación (PANT-*), conceptos (CON-*) y externos (EXT-*). Lo hace al planear una tarea y al revisarla.
- **Claude Code**: nodos de código (APP, RUTAS, TEMA, MOD, REPO-*, MOCK-*, COMP-*, pruebas, CI): rutas reales, estado y relaciones de lo que crea o cambia. Cuando termine una pantalla, también anota su ruta en la fila de esa pantalla.
- Ninguno borra filas de nodos que no le tocan; si algo parece mal, lo anota como duda.
- Lo que ya no exista se marca `obsoleto` (no se borra de inmediato) y se menciona en el reporte.

## Cómo se actualiza
1. Editar `ai/grafo.md` junto con el cambio de código, en el mismo commit cuando sea posible, o en un commit propio de la misma tarea ("Actualiza el grafo con los componentes base").
2. Poner la ruta real, el estado y las relaciones (`→ usa`, `→ navega a`, etc.).
3. Actualizar la línea "Última actualización" (fecha, quién, tarea) y agregar una línea en el "Registro de cambios del grafo".
4. Al reportar, Claude Code incluye en `ai/reporte.md` una sección **Grafo actualizado** con la lista de nodos creados, cambiados u obsoletos (o "sin cambios" con la razón).

## Cómo se revisa
Claude Chat comprueba, al revisar un PR, que:
- Cada archivo o carpeta importante nuevo tiene su nodo y su ruta es real.
- Las relaciones son correctas y no quedaron nodos huérfanos ni rutas que ya no existen.
- El estado de la tarea y de las pantallas coincide con lo entregado.
Si falta o está mal, el PR no se aprueba hasta corregir el grafo.

## Formato
Se mantiene en Markdown (tablas y un diagrama Mermaid) para que cualquiera lo lea en GitHub y las dos instancias de Claude lo editen sin herramientas especiales. No cambiar el formato de las columnas sin avisar; si hace falta, es una tarea aparte.
