# 05 · Reglas del proyecto y seguridad

## Alcance
- Solo código de frontend. No crear backend, base de datos ni scripts de infraestructura en este repo.
- No agregar dependencias nuevas sin avisarlo en el reporte (con la razón). Preferir paquetes populares y mantenidos.
- No modificar archivos fuera del alcance de la tarea (la lista de "archivos permitidos" está en `siguiente.md`).

## Código
- Los colores, tamaños de letra y espaciados se toman del tema (`02-diseno-tokens.md`); nada de hex sueltos en pantallas.
- Los textos visibles van centralizados (para poder traducir o corregir en un solo lugar).
- La lógica no vive en los widgets: estado y reglas en capas aparte; los widgets solo pintan.
- Cada componente reutilizable tiene prueba de widget; cada regla de juego, prueba unitaria.
- El análisis estático (`flutter analyze`) y las pruebas (`flutter test`) deben pasar antes de subir.

## Accesibilidad (obligatoria, no opcional)
- Toda acción tiene una zona táctil de al menos 48 × 48 dp.
- Todo elemento interactivo y toda imagen informativa lleva etiqueta semántica en español.
- El swipe siempre tiene un equivalente por botones (los 4 veredictos).
- Respetar texto dinámico del sistema y la opción "reducir animaciones".
- Contraste AA: usar los tokens (los primitivos de baja contraste son solo decorativos).
- La información no depende solo del color (los sellos y botones llevan texto e ícono).

## Seguridad y privacidad
- Nunca poner secretos, llaves ni contraseñas en el repo. Configuración sensible por variables de entorno o archivos ignorados por git.
- Tokens de sesión (JWT y refresh) irán en almacenamiento seguro del sistema, nunca en preferencias simples. Mientras no haya backend, solo se simulan.
- No registrar (log) contraseñas, tokens ni datos personales.
- Registro: **dos consentimientos separados** (Aviso de Privacidad y Términos de uso), cada uno con su casilla, sin pre-marcar. El estado de cada uno viaja por separado al backend.
- El tiempo de regeneración de vidas y el temporizador de los exámenes los manda el servidor; la app solo los muestra (no confiar en el reloj del dispositivo para decidir).
- Las respuestas offline se guardan con un UUID de cliente para que el servidor las reciba una sola vez.

## Gestión del repositorio
- Ver `01-flujo-de-trabajo.md`: ramas, commits sin prefijo, sin menciones a Claude, el usuario abre los PR y hace el merge.
