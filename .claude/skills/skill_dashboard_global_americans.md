---
name: dashboard-global-americans
description: >
  Línea gráfica de Global Americans para dashboards y páginas web de datos en
  tools/dashboard/. Úsala SIEMPRE que haya que armar, rediseñar o revisar un
  dashboard para Global Americans, o cuando se pida "con la línea de Global
  Americans" o "como el dashboard final de Paraguay Index". Cubre paleta,
  tipografía, portada, tarjetas, gráficos, la vista técnica, logos y cómo pasar
  un dashboard hecho con la línea de Equilibrium a esta. Para la línea de
  Equilibrium está skill_dashboard_equilibrium.md.
---

# Dashboard con la línea gráfica de Global Americans

Destilada del dashboard final del US-PY Engagement Index (Paraguay Index), que
se rehízo sobre los *Lineamientos de diseño y formato* de Global Americans
(octubre de 2026). La estructura de carpetas es la misma que en
`skill_dashboard_equilibrium.md`: lo que cambia son los tokens.

---

## 1. Cómo se aplica

**Solo cambia el estilo: paleta y tipografía.** El dashboard se arma con los
tokens del sistema de diseño (`var(--eq-navy)`, `var(--eq-coral)`...) y la línea
de Global Americans **redefine esos mismos tokens** en un bloque `:root`. Así
el mismo HTML sirve para las dos marcas y nada se reescribe a mano.

```css
/* ===== Identidad visual de Global Americans ===== */
:root{
  --eq-navy:#190e35; --eq-navy-deep:#100823;  /* morado oscuro: bandas, títulos, recuadros */
  --eq-coral:#431c85;                         /* violeta: acentos sobre fondo claro */
  --eq-blue:#431c85;
  --eq-teal:#e9e3f1;                          /* lavanda: fondos suaves */
  --eq-periwinkle:#f4f1f8;
  --eq-paper:#eeebe0;                         /* blanco hueso: texto sobre fondo oscuro */
  --eq-gray-600:#4d4760; --eq-gray-300:#cfc7dc; --eq-gray-100:#efebf5;
  --font-sans:"Barlow",system-ui,sans-serif;
  --font-display:"Barlow Condensed","Barlow",system-ui,sans-serif;
}
```

---

## 2. Color

| Color | Hex | Uso |
|---|---|---|
| Morado oscuro | `#190e35` | títulos, cifras, bandas y recuadros oscuros |
| Morado profundo | `#100823` | fondo de la vista técnica y de las barras de navegación |
| Violeta | `#431c85` | acentos y links sobre fondo claro, hover |
| Cian eléctrico | `#00fdff` | acento **sobre fondo oscuro**: portada, encabezados, vista técnica |
| Turquesa | `#00c4cc` | segunda serie de los gráficos, resaltados en tooltips |
| Lavanda | `#e9e3f1` | fondos suaves, selección en un gráfico, etiquetas |
| Lavanda muy clara | `#f4f1f8` | recuadros de lectura |
| Carril | `#eeeaf4` | fondo de las barras |
| Filete | `#e4dfec` | bordes y líneas de grilla |
| Blanco hueso | `#eeebe0` | texto sobre fondo oscuro |
| Gris morado | `#4d4760` | texto secundario |
| Blanco | `#FFFFFF` | **fondo de página** (no el paper de Equilibrium) |

Reglas:

- **Fondo de página blanco**; el texto de cuerpo en negro `#000000`.
- **El acento depende del fondo**: violeta `#431c85` sobre claro, cian
  `#00fdff` sobre oscuro. Nunca el cian sobre blanco.
- La portada lleva un degradado `140deg, #190e35 0%, #2b1563 55%, #431c85 100%`.
- Series de los gráficos: morado oscuro `#190e35`, luego turquesa `#00c4cc`.
- Sombras teñidas del morado: `rgba(25,14,53,.06)` y `rgba(25,14,53,.12)`.

---

## 3. Tipografía

- **Barlow** para el texto y **Barlow Condensed** para títulos, cifras grandes y
  kickers, desde Google Fonts:

  ```html
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Barlow:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500&family=Barlow+Condensed:wght@600;700;800&display=swap">
  ```

- `h1`, `h2`, `h3`: Barlow Condensed, peso 800, espaciado -0,005em.
- Kickers en mayúsculas: Barlow Condensed con espaciado 0,08em.
- Cifras de tablas técnicas: monoespaciada (`ui-monospace, Consolas`) con
  `font-variant-numeric: tabular-nums`, para que los dígitos se alineen.

---

## 4. Componentes

- **Tarjetas**: blancas, esquinas de 20 px, sombra suave morada; encabezado con
  un filete `#e4dfec` debajo.
- **Recuadro de lectura**: fondo `#f4f1f8`, esquinas de 14 px y un borde
  izquierdo de 4 px en violeta.
- **Tooltip**: fondo `#190e35`, texto blanco, esquinas de 12 px; lo resaltado en
  turquesa `#00c4cc`.
- **Barras**: carril `#eeeaf4` redondeado (999 px), relleno morado oscuro o
  turquesa.
- **Vista técnica** (el modo avanzado): fondo `#100823`, texto `#eeebe0`, borde
  interior cian `rgba(0,253,255,.45)`, encabezados de tabla en cian y etiquetas
  con fondo cian y texto `#100823`.
- **Botón ES/EN**: todo el dashboard en los dos idiomas.

---

## 5. Logos

- Los de `assets/logos/`, en blanco sobre la portada y la barra superior.
- Si el proyecto es conjunto, los logos de los aliados (Global Americans, CAF)
  van **junto** al de la consultora, en la portada y en la barra superior de las
  páginas internas, a la misma altura.

---

## 6. Pasar un dashboard de Equilibrium a esta línea

1. Agregar el `<link>` de Barlow y Barlow Condensed.
2. Pegar el bloque `:root` de la sección 1 **después** de los tokens de
   Equilibrium, para que los pise.
3. Fondo de página a blanco y cuerpo en negro.
4. Buscar los hex que quedaron escritos a mano (`#030F50`, `#F7966B`,
   `#E6E8EE`, `#F0F1F4`) y cambiarlos por los de la sección 2.
5. El cian `#00fdff` como acento en la portada, los encabezados y la vista
   técnica.
6. Cambiar los logos y revisar cada pantalla en el navegador.

---

## 7. Checklist

- [ ] Los tokens de Equilibrium redefinidos con el bloque de la sección 1.
- [ ] Barlow en el texto y Barlow Condensed en títulos y cifras.
- [ ] Fondo blanco; violeta como acento sobre claro y cian sobre oscuro.
- [ ] Ningún hex de Equilibrium escrito a mano.
- [ ] Cifras técnicas con números tabulares.
- [ ] Logos de los aliados junto al de la consultora.
