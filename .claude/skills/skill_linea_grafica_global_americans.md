---
name: linea-grafica-global-americans
description: >
  Línea gráfica de Global Americans: color, tipografía, formas, gráficos y
  logos. Úsala SIEMPRE que un entregable lleve la marca Global Americans o se
  haga con ellos: un informe, una presentación, un gráfico, una tabla, un
  dashboard o una página web, o cuando se pida "con la línea de Global
  Americans". Incluye cómo pasar un entregable hecho con la línea de
  Equilibrium a esta. Es la línea de la marca, no de un formato. Para
  Equilibrium está skill_linea_grafica_equilibrium.md.
---

# Línea gráfica de Global Americans

Destilada de los *Lineamientos de diseño y formato* de Global Americans
(octubre de 2026), tal como se aplicaron en la versión final del US-PY
Engagement Index (Paraguay Index).

---

## 1. Color

| Nombre | Hex | Uso |
|---|---|---|
| Morado oscuro | `#190e35` | títulos, cifras, bandas y recuadros oscuros |
| Morado profundo | `#100823` | fondos oscuros, barras de navegación, la vista técnica |
| Violeta | `#431c85` | acentos y links sobre fondo claro, hover |
| Cian eléctrico | `#00fdff` | acento **sobre fondo oscuro**: portadas, encabezados |
| Turquesa | `#00c4cc` | segunda serie de los gráficos, resaltados |
| Lavanda | `#e9e3f1` | fondos suaves, selección, etiquetas |
| Lavanda muy clara | `#f4f1f8` | recuadros de lectura |
| Carril | `#eeeaf4` | fondo de las barras |
| Filete | `#e4dfec` | bordes y líneas de grilla |
| Blanco hueso | `#eeebe0` | texto sobre fondo oscuro |
| Gris morado | `#4d4760` | texto secundario |
| Blanco | `#FFFFFF` | **fondo** |
| Negro | `#000000` | texto de cuerpo |

Reglas:

- **Fondo blanco y cuerpo en negro.** El morado lleva los títulos, las cifras y
  los bloques oscuros.
- **El acento depende del fondo**: violeta `#431c85` sobre claro, cian
  `#00fdff` sobre oscuro. Nunca cian sobre blanco: no se lee.
- Portadas y aperturas: degradado `140deg, #190e35 0%, #2b1563 55%, #431c85 100%`.
- **Orden de las series en un gráfico**: morado oscuro, turquesa, violeta,
  lavanda.
- Sombras, cuando las hay, teñidas de morado: `rgba(25,14,53,.06)` y
  `rgba(25,14,53,.12)`.

---

## 2. Tipografía

- **Barlow** para el texto y **Barlow Condensed** para títulos, cifras grandes y
  antetítulos. Las dos están en Google Fonts; en documentos de Office se
  instalan antes de usarlas.
- Títulos: Barlow Condensed, peso 800, espaciado -0,005em.
- Antetítulos en mayúsculas: Barlow Condensed con espaciado 0,08em.
- Cuerpo: Barlow 400; énfasis en 600 o 700; notas en itálica.
- Cifras en tablas técnicas: monoespaciada con números tabulares, para que los
  dígitos se alineen en columna.

---

## 3. Formas y componentes

- **Esquinas redondeadas**: 20 px en tarjetas y bloques, 12–14 px en recuadros y
  tooltips, píldora (999 px) en barras y etiquetas. Es lo contrario de
  Equilibrium, que usa esquinas rectas.
- **Tarjetas**: blancas, con sombra suave morada; encabezado separado con un
  filete `#e4dfec`.
- **Recuadro de lectura**: fondo `#f4f1f8` y un borde izquierdo de 4 px en
  violeta.
- **Tooltip o globo**: fondo `#190e35`, texto blanco, lo resaltado en turquesa.
- **Bloque técnico** (metodología, anexos): fondo `#100823`, texto `#eeebe0`,
  borde interior cian translúcido, encabezados de tabla en cian.
- Bilingüe: los entregables para Global Americans van en español e inglés.

---

## 4. Gráficos y tablas

- **Barras** con extremos redondeados sobre un carril `#eeeaf4`, relleno
  morado oscuro o turquesa.
- Líneas de grilla punteadas en `#e4dfec`; la línea de referencia, punteada en
  morado oscuro.
- La base y la fuente, siempre, en itálica.

---

## 5. Logos

- Los oficiales, en blanco sobre fondos oscuros y en color sobre blanco.
- **Proyecto conjunto**: el de Global Americans (y el de otro aliado, como CAF)
  va **junto** al de la consultora, a la misma altura, en la portada y en el
  encabezado de las páginas internas.

---

## 6. Pasar un entregable de Equilibrium a esta línea

1. Cambiar la tipografía: Geologica por Barlow en el texto y Barlow Condensed en
   títulos y cifras.
2. Cambiar la paleta, color por color:

   | Equilibrium | Global Americans |
   |---|---|
   | navy `#030F50` | morado oscuro `#190e35` |
   | navy profundo `#000031` | morado profundo `#100823` |
   | coral `#F7966B` | violeta `#431c85` sobre claro, cian `#00fdff` sobre oscuro |
   | teal `#7CCCBF` | lavanda `#e9e3f1` |
   | periwinkle `#788EC7` | lavanda muy clara `#f4f1f8` |
   | paper `#F7FAF2` | blanco `#FFFFFF` de fondo; blanco hueso `#eeebe0` para texto sobre oscuro |
   | gris texto `#595959` | gris morado `#4d4760` |

3. Si el entregable usa variables o estilos con nombre (CSS, tema de Office,
   estilos de ggplot), redefinir esas variables en un solo lugar en vez de
   reemplazar hex a mano.
4. Redondear las esquinas (sección 3) y cambiar los logos.
5. Revisar cada página o diapositiva: el cian solo sobre fondo oscuro.

---

## 7. Checklist

- [ ] Barlow en el texto y Barlow Condensed en títulos y cifras.
- [ ] Fondo blanco; violeta como acento sobre claro y cian sobre oscuro.
- [ ] Ningún color de Equilibrium que haya quedado de una versión anterior.
- [ ] Esquinas redondeadas en tarjetas, barras y etiquetas.
- [ ] Base y fuente en cada gráfico.
- [ ] Logos de los aliados junto al de la consultora.
