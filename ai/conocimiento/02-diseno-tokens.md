# 02 · Diseño: colores, tipografía y tokens

Fuente: Figma (páginas "Colores y tipografía" y "Componentes"). Los colores de marca son primitivos; la app usa **tokens de tema** con modo claro y oscuro. El código debe usar los tokens, nunca los hex directos en las pantallas.

## Colores de marca (primitivos)
| Nombre | Hex | Uso |
|---|---|---|
| Verde Bosque Gator | #1F4E35 | Isotipo, acción primaria (claro) |
| Azul Marino Lex | #0F294A | Encabezados, acción secundaria (claro) |
| Ámbar Mazo | #B86B23 | Acentos, monedas; solo texto grande (4.07:1) |
| Verde Circuito TI | #68B678 | Primario en modo oscuro; decorativo en claro |
| Verde Escama Sarko | #506F52 | Piel de Sarko, iconos secundarios |
| Crema Ventral | #E8D8A8 | Vientre de Sarko, tarjetas destacadas (decorativo) |
| Rojo Veredicto | #B52426 | "Ilegal", errores, vidas |
| Azul Sastre Oscuro | #222A35 | Texto principal |
| Blanco Puro | #FFFFFF | Fondo de tarjetas |
| Legal (acierto) | #1E7B4A | Swipe derecha, acierto |
| Ámbar texto | #8A4F17 | Texto de acento con contraste AA |
| Neutro 50 | #F8FAFC | Fondo app (claro) |
| Neutro 500 | #64748B | Texto secundario |
| Fondo oscuro | #0B1220 | Fondo app (oscuro) |
| Superficie oscura | #162030 | Tarjetas en oscuro |

## Colores por módulo
1 Protección de Datos #2B5FA8 · 2 Licencias y Propiedad Intelectual #B86B23 (ámbar, para no confundir con "Ilegal") · 3 Delitos Informáticos #6B4BA1 · 4 Contratos Digitales #1F4E35 · 5 Auditoría y Cumplimiento #1B7F86.

## Tokens de tema (valores exactos de Figma)
| Token | Claro | Oscuro |
|---|---|---|
| fondo/app | #F8FAFC | #0B1220 |
| fondo/superficie | #FFFFFF | #162030 |
| fondo/superficie-alt | #F1F5F9 | #1E2A3C |
| fondo/destacado | #E8D8A8 | #3A3424 |
| texto/primario | #222A35 | #F8FAFC |
| texto/secundario | #475569 | #94A3B8 |
| texto/en-primario | #FFFFFF | #0B1220 |
| texto/acento | #8A4F17 | #E0A060 |
| borde/default | #E2E8F0 | #2A3850 |
| accion/primaria | #1F4E35 | #68B678 |
| accion/secundaria | #0F294A | #E2E8F0 |
| accion/acento | #9A5A1C | #E0A060 |
| estado/legal | #186B40 | #5CC88A |
| estado/ilegal | #B52426 | #F07070 |

## Tipografía
Primaria **Fredoka** (SemiBold/Bold) para logotipo, títulos y botones. Secundaria **Inter** (Regular/Medium/SemiBold). **JetBrains Mono** para código.

| Estilo | Fuente | Tamaño/interlineado |
|---|---|---|
| Display | Fredoka Bold | 34/40 |
| Título/H1 | Fredoka Bold | 26/32 |
| Título/H2 | Fredoka SemiBold | 20/26 |
| Título/H3 | Fredoka SemiBold | 17/22 |
| Cuerpo/Grande | Inter Regular | 16/24 |
| Cuerpo/Base | Inter Regular | 14/20 |
| Cuerpo/Énfasis | Inter SemiBold | 14/20 |
| Etiqueta | Inter SemiBold | 12/16 |
| Leyenda | Inter Medium | 11/14 |
| Botón | Fredoka SemiBold | 16/20 |
| Código | JetBrains Mono Regular | 12/18 |

## Lienzo de referencia
- Móvil: 390 × 844 (barra de estado 48 px arriba, indicador de inicio abajo). Margen lateral habitual 24 px; ancho útil 342 px.
- Botón principal: 342 × 52. Botón secundario/volver: 342 × 48. Zonas táctiles mínimas de 48 dp.
- Barra de navegación inferior: 390 × 84, pestañas Mapa, Buzón, Tienda y Perfil.
- Tablet: frames propios en las páginas "Tablet · …" de Figma (se atienden en la tarea de tablet).

## Tokens adicionales y componentes
Tres tokens más (borde/control, estado/condicional, foco/anillo) y las medidas de cada componente están en `07-componentes.md`.

## Assets
Logos y poses de Sarko: carpeta local `Imegenes/` (entra al repo en T-01 como `assets/imagenes/`). Íconos: paquete Lucide. Fuentes: archivos .ttf en `assets/fuentes/` (T-01).
