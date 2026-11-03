---
name: dashboard-equilibrium
description: >
  Línea gráfica de Equilibrium (Business, Data & Communities) para dashboards
  y páginas web de datos en tools/dashboard/. Úsala SIEMPRE que haya que armar,
  rediseñar o revisar un dashboard, una página de resultados o una
  visualización con la marca Equilibrium, o cuando se pida "con los colores de
  Equilibrium", "con nuestra marca" o "como el primer dashboard de Paraguay
  Index". Cubre paleta, tipografía, espaciado, formas, gráficos, logos, tono
  del texto y estructura de carpetas. Para la línea de Global Americans está
  skill_dashboard_global_americans.md.
---

# Dashboard con la línea gráfica de Equilibrium

Destilada del sistema de diseño de Equilibrium (Manual de Marca, Identidad 2025)
y del primer dashboard del US-PY Engagement Index (Paraguay Index). La página
tiene que leerse **rigurosa, clara, confiable, especializada y contemporánea**:
jerarquía, lectura y aire antes que decoración.

---

## 1. Carpetas

```
tools/dashboard/
├── index.html                la página
├── _ds/                      el sistema de diseño
│   ├── fonts/                Geologica 100–900 con itálicas (.ttf)
│   └── tokens/               colors.css, typography.css, spacing.css,
│                             effects.css, base.css, fonts.css
├── assets/logos/             los logos oficiales, sin redibujar
└── datos/                    los CSV que exporta el pipeline
```

- **La página no calcula nada.** Lee los CSV de `datos/`, que exporta el
  pipeline (`08_products` o `09_publish`).
- **Los tokens se usan siempre por variable** (`var(--eq-navy)`), nunca con el
  hex escrito en el componente. Así cambiar de marca es cambiar los tokens.

---

## 2. Color

| Token | Hex | Uso |
|---|---|---|
| `--eq-navy` | `#030F50` | **la marca**: logo, títulos, cifras clave, fondos oscuros |
| `--eq-navy-deep` | `#000031` | sombras de duotono, capas sobre navy |
| `--eq-paper` | `#F7FAF2` | **fondo de página**: blanco cálido, nunca blanco puro |
| `--eq-white` | `#FFFFFF` | tarjetas |
| `--eq-coral` | `#F7966B` | el acento más usado |
| `--eq-teal` | `#7CCCBF` | segundo acento, paneles |
| `--eq-yellow` | `#F4B21B` | tercer acento |
| `--eq-periwinkle` | `#788EC7` | duotonos, bandas |
| `--eq-blue` | `#1A55A6` | links, hover |
| `--eq-cyan` | `#14B1E7` | solo en gráficos y en el anillo de foco |
| `--eq-peach` | `#F6C8AE` | tinte de coral sobre fondos claros |
| `--eq-gray-600` | `#595959` | texto de cuerpo sobre paper |
| `--eq-gray-300` | `#C9CBD1` | bordes suaves |
| `--eq-gray-100` | `#EEEEEE` | carril de las barras, filas de tabla |

Reglas:

- **Navy y paper ocupan casi toda la superficie.** Un solo acento por sección.
- **No hay rojo de error en la marca**: un error se marca con subrayado coral y
  el mensaje en navy, en negrita.
- **Orden de las series en un gráfico**: navy, coral, teal, blue, yellow,
  periwinkle.
- Degradados solo con colores de la paleta: `#030F50 → #1A55A6` (navy),
  `#F7966B → #F6C8AE` (coral), `#030F50 → #788EC7 → #F7966B` (atardecer).

---

## 3. Tipografía

- **Geologica, y solo Geologica**, servida desde `_ds/fonts/`.
- Bold 700 para títulos y cifras (interlineado 1,05–1,2); Medium 500 para
  subtítulos y frases grandes; Regular 400 para el cuerpo (interlineado 1,5);
  Italic para citas y notas de base (*n = 1.200 encuestas*).
- Escala web: display 72, h1 52, h2 38, h3 28, h4 22, lead 20, cuerpo 17,
  pequeño 14, micro 12 px.
- Kicker: 14 px, bold, mayúsculas, espaciado 0,12em, en navy.

---

## 4. Forma, espacio y movimiento

- **Esquinas rectas por defecto.** El redondeo es un acento en **una** esquina o
  un borde (16, 32 o 64 px): el pie de la portada, la pestaña de una sección.
  Nunca todas las esquinas de todas las tarjetas.
- **Líneas**: 2 px navy continuas para subrayar títulos y separar cifras; 2 px
  navy **punteadas** entre filas de una lista.
- **Tarjetas**: planas, blancas con un filete de 1 px; sin sombra en reposo,
  sombra suave solo al pasar el mouse si se puede hacer clic.
- **Espaciado** en múltiplos de 4: 4, 8, 12, 16, 24, 32, 48, 64, 96, 128 px.
  Contenedor de 1200 px, canal de 24 px.
- **Movimiento mínimo**: transiciones de color de 120–220 ms con `ease-out`;
  sin rebotes.
- Textura opcional de grano o trama de puntos sobre fotos y degradados.

---

## 5. Gráficos

- **Barras horizontales** con extremos rectos sobre un carril gris
  `#EEEEEE`, ordenadas de mayor a menor, con la etiqueta y el valor dentro o a la
  derecha.
- Una sola serie va en coral o navy.
- **La base n va en itálica debajo, y la fuente siempre.**
- Nunca un número aislado: siempre con su base, su año o su comparación.
  *"73,5 % reside en áreas urbanas (3,7 M)"*.

---

## 6. Logos

- Solo los oficiales de `assets/logos/`: principal, con tagline e isotipo, en
  azul y en blanco. El blanco sobre fondo navy; el azul sobre paper.
- La versión con tagline va en la portada y el cierre; el isotipo, en la barra
  superior.
- **El isotipo no se redibuja**: solo cambia de tamaño, color (coral, peach,
  teal, navy, paper), posición y recorte. Nunca se rota, se estira ni se
  contornea. Uno por pantalla.

---

## 7. El texto

- Español neutro de Latinoamérica. *Business, Data & Communities* es lo único en
  inglés.
- **Primero la idea principal**, después el contexto. Oraciones directas, verbos
  activos.
- Separar lo que sabemos de lo que interpretamos; nunca afirmar causalidad que
  los datos no sostienen. Sin superlativos.
- Títulos en tipo oración (*Principales hallazgos*). Mayúsculas solo en kickers y
  separadores de sección.
- Sin emojis ni signos de exclamación. Decimales con coma (71,8 %).

---

## 8. Checklist

- [ ] Fondo paper `#F7FAF2`, no blanco puro; navy en títulos y cifras.
- [ ] Un solo acento por sección; series en el orden de la sección 2.
- [ ] Geologica en toda la página, desde `_ds/fonts/`.
- [ ] Esquinas rectas, con redondeo solo como acento.
- [ ] Cada gráfico con base n en itálica y fuente.
- [ ] Logos oficiales sin modificar.
- [ ] Ningún hex escrito en un componente: todo por variable.
