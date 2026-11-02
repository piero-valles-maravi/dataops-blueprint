---
name: data-cleaning
description: >
  Procedimiento canónico para limpiar una fuente de datos sucia y dejarla lista
  para cruzar con otras. Úsalo SIEMPRE que haya que limpiar, normalizar o
  estandarizar una base: registros de formularios, padrones, exports de
  plataformas, encuestas, CSV de un cliente. Actívalo cuando el pedido mencione
  limpiar una base, normalizar cédulas / documentos / correos / teléfonos /
  nombres, deduplicar personas, armar llaves de cruce, escribir un script
  02_clean_*, extraer datos escritos en el campo equivocado, o preparar una
  fuente para una base maestra. También cuando el usuario comparta una base
  cruda y pregunte cómo limpiarla, o pida revisar un script de limpieza que ya
  existe. El resultado es un script con la estructura, el orden y las
  validaciones de los 02_clean_* de este repositorio, sea cual sea la fuente.
---

# Limpieza de una fuente de datos

Este procedimiento es el destilado de ocho scripts `02_clean_*` que limpian
cinco fuentes distintas (dos padrones oficiales, dos formularios web y tres
exports de una plataforma de cursos). Está escrito para que se pueda aplicar a
cualquier base sucia, no solo a las de este proyecto.

Lo que se limpia acá **no** es "dejar la tabla linda". Es dejar cada registro
con **llaves de identidad confiables**, para que después se pueda decir si dos
filas de dos fuentes distintas son la misma persona. Todo lo demás es
secundario.

---

## 0. Las cinco reglas que no se negocian

Estas mandan sobre cualquier decisión técnica. Si una regla de limpieza choca
con una de estas, se cambia la regla.

1. **No inventar datos.** Si un valor admite más de una reconstrucción posible,
   se conserva tal cual y se marca. Adivinar un dígito es peor que dejar el
   campo sucio: el dato sucio se ve, el inventado no.

2. **No vaciar la llave.** De la llave final solo sale (a) lo que ya se
   identificó como otra cosa (un teléfono escrito en el campo de documento) y
   (b) lo que no identifica a nadie (menos de N caracteres, un dígito repetido).
   **Lo desconocido se conserva y se marca.** Un valor raro que quizá sea
   válido vale más que un `NA`.

3. **Medir antes de proponer una regla.** Nunca escribir una regla sin haber
   contado cuántos casos hay en los datos reales y sin mirar ejemplos. El
   comentario de la regla lleva ese número: `# son 31 filas`, `# 13 valores
   únicos`. Si no se midió, no se escribe.

4. **Distinguir deducción de suposición.** Si una regla se apoya en un
   supuesto, se dice en el comentario y se marcan las filas afectadas con una
   columna de diagnóstico.

5. **Los casos únicos van en una tabla de correcciones**, versionada dentro del
   script con `tribble()` + `left_join()`. Nunca como una rama especial dentro
   de la lógica general: la lógica general se lee, las ramas especiales se
   acumulan.

Corolario de la 1 y la 2: **el script marca, no descarta.** Las filas de prueba,
los números falsos, las cuentas duplicadas se etiquetan con una columna lógica
(`es_prueba`, `_validez`, `cuenta_principal`) y siguen viajando. Quien las
necesite fuera las saca con un `filter()` explícito, que se ve y se puede
contar. Descartar en la limpieza rompe la reconciliación: el crudo y la salida
dejan de cuadrar y no hay forma de saber de dónde salió la diferencia.

---

## 1. Identificar el arquetipo de la fuente

Antes de escribir una línea, decidir cuál de los tres es. Determina todo lo
que sigue.

| Arquetipo | Grano | Aporta llaves | Procedimiento |
|---|---|---|---|
| **A. Fuente de personas** | Una fila = un registro de una persona | Sí, 2 a 4 | Completo (sección 2 a la sección 8) |
| **B. Tabla de detalle o evento** | Una fila = una persona × un ítem | No, ya están en A | Reducido (sección 9) |
| **C. Tabla de dimensión** | Una fila = un objeto, no una persona | No tiene | Mínimo (sección 10) |

Cómo decidirlo, con los datos en la mano:

- ¿La fila describe a una persona o un hecho de esa persona? Si una misma
  persona aparece muchas veces por tener muchos ítems, es **B**.
- ¿Los identificadores de esta fuente ya están todos en otra? Si sí, es **B**:
  no aporta llaves nuevas, aporta atributos. (Se mide: en el caso testigo,
  26.940 de 26.941 correos del detalle ya estaban en el padrón.)
- ¿La fila no tiene ninguna persona? Es **C**.

Solo el arquetipo A pasa por los bloques de llave y entra al apilado de la base
maestra. B y C se cruzan por una sola llave ya limpia.

---

## 2. Preámbulo del script (arquetipo A)

En este orden exacto.

### 2.1 Setup

Cargar el entorno del proyecto (paquetes y funciones auxiliares) en dos
llamadas separadas. Nunca autenticar servicios de red acá: eso golpea la red en
cada `source()`.

### 2.2 Rutas

Dos variables, una de entrada y una de salida. Asimetría deliberada:

- **La carpeta de entrada NO se crea.** Si no existe, queremos que falle: una
  carpeta de entrada vacía significa que la ingesta no corrió, y crearla
  esconde el problema.
- **La carpeta de salida SÍ se crea**, con `dir.create(..., recursive = TRUE,
  showWarnings = FALSE)`, porque el script va a escribir ahí.

### 2.3 Cargar el crudo

Con un comentario que diga **cuántas filas trae**. Ese número es el punto de
partida de todas las validaciones y el detector de regresiones: si en la próxima
corrida cambia mucho, la ingesta se cortó.

### 2.4 Descartar lo que está roto (no lo que está sucio)

Se descarta solo lo que **no es un registro**. Tres casos, y cada uno con su
medición en el comentario:

- **Columnas rotas en origen.** Fórmulas del Sheet que llegan como el texto
  literal de un error. No se intentan arreglar: `select(-esa_columna)`.
- **Filas sin marca temporal**, o sin el campo que el formulario siempre
  completa. Son filas fantasma de la herramienta.
- **Bloques de arrastre.** El caso real: 2.958 filas con las cuatro llaves
  vacías, 2.957 de ellas contiguas al final del archivo, con rol y estado pero
  sin institución. Es el arrastre de dos columnas más abajo que los datos, no
  registros de nadie.

La prueba de que el filtro de arrastre está bien puesto: después de aplicarlo,
`nrow(crudo)` es el número real de registros. Si estas filas sobreviven, llegan
hasta el final del script y las descarta el filtro de llaves del cierre, y hasta
entonces todos los conteos intermedios mienten.

Un formulario web validado no necesita nada de esto. Se comprueba y se escribe
en el comentario: *"created_at nunca es NA, acepta_terminos es TRUE en todas y
ninguna fila tiene las cuatro llaves vacías"*.

### 2.5 Marcar las filas de prueba

**Marcar, no filtrar** (regla 0). Y la marca va por el **valor completo**, nunca
por subcadena:

```r
# MAL: grepl("PRUEBA|TEST", toupper(nombre))
#      se lleva puestas a tres personas reales: SautesTEBAN, malaTESta, nicoDEMO
# BIEN:
es_prueba =
  toupper(trimws(nombre)) %in% c("PRUEBA DOCENTE", "PRUEBA JOVENES", "TEST") |
  grepl("^example[0-9]*@example\\.com$", tolower(trimws(correo))) |
  grepl("@cloud\\.plataforma\\.org$", tolower(trimws(correo)))
```

Y por el **local del correo, no por el dominio entero**: `@example.com` lo
escribieron además dos personas reales, invitadas a una institución de verdad.

Excepción: cuando son pocas y el crudo no se va a reconciliar con nada (el caso
de las 31 filas de prueba de un formulario), filtrar directamente es aceptable
si el comentario dice cuántas se van.

### 2.6 Renombrar al vocabulario común

Todas las fuentes salen con **los mismos nombres de columna**. Es un contrato
(sección 8.5). Los nombres del crudo son intratables (`nombre_completo_tal_como_
aparece_en_la_cedula_de_identidad`) y cada fuente los escribe distinto.

- Nombres cortos, en minúscula, en el idioma del contenido.
- **Sin prefijo de fuente.** La columna `fuente` ya dice de dónde viene cada
  fila; un `rce_` adelante no agrega nada y obliga a renombrar en la
  integración.

  > **Esto cambió a propósito.** La primera versión del procedimiento sí usaba
  > el prefijo de la fuente en cada columna (`rce_nombre_norm`,
  > `mec2026_cedula_norm`). Se abandonó cuando quedó claro que obligaba a
  > renombrar las 22 columnas de cada fuente en la integración, y que ese
  > renombre es exactamente el trabajo que el contrato existe para evitar. Si
  > encontrás un script viejo con prefijos, es de antes del cambio: no es el
  > modelo a seguir. El prefijo del campo sí se conserva
  > (`celular_norm`, `celular_documento`), porque distingue el campo de origen.
- Si el crudo ya usa un nombre que se necesita para otra cosa, desambiguar en
  el comentario: `fecha_formulario = marca_temporal  # no se llama fecha porque
  el crudo ya trae una columna con ese nombre`.

Cuando una fuente entrega **dos poblaciones en dos archivos** con nombres de
columna completamente distintos (alumnos y docentes, por ejemplo), el script
tiene **una sección por población**, cada una con sus pasos y su validación, y
recién al final se apilan (sección 2.7).

### 2.7 Apilar poblaciones, si hay más de una

Tres pasos, y el del medio es el que evita el error silencioso:

1. **Igualar el tipo de las columnas comunes.** Un código que viene numérico en
   un archivo y texto en otro hace abortar el `bind_rows`, o peor, lo pasa y
   rompe el cruce después.
2. **Revisar que las columnas calcen**, con tres consultas:
   ```r
   intersect(names(poblacion_a), names(poblacion_b))
   setdiff(names(poblacion_a), names(poblacion_b))
   setdiff(names(poblacion_b), names(poblacion_a))
   ```
   Una columna que debería ser común y aparece como exclusiva es un renombre mal
   escrito, y `bind_rows` la dejaría **duplicada con la mitad de los valores en
   `NA`**, sin avisar.
3. **Apilar** con `bind_rows`, que completa con `NA` lo que una población no
   tiene. Eso es correcto: si el padrón de alumnos no pregunta correo, los
   alumnos tienen que quedar con correo en `NA`.

Validación obligatoria: el total tiene que ser la suma de las partes, y un
`group_by(poblacion)` tiene que mostrar a las dos con sus llaves.

### 2.8 Normalización general

Las columnas que **no** son llave, todas en un solo `mutate`. Un tratamiento por
tipo de contenido, y el mismo en todas las fuentes:

| Tipo de columna | Tratamiento |
|---|---|
| Categóricas de persona (rol, sexo) | `normalizar_texto()` |
| Geográficas (departamento, distrito) | `normalizar_geografia()` |
| Institución | `normalizar_texto()` |
| Atributos de forma libre (modalidad, turno, énfasis) | `stri_trans_general(toupper(trimws(x)), "Latin-ASCII")` |
| Texto largo (el problema declarado) | `normalizar_texto()` y el vacío a un valor explícito |
| Códigos | `trimws(as.character(x))` — siempre texto, nunca numérico |

Dos reglas más:

- **Los `'NULL'` de texto pasan a `NA`.** Llegan como la cadena literal, no como
  `NA`, y sobreviven a todo si no se los saca acá.
- **Los estados vacíos van a un valor explícito**, no a `NA`: `"Sin revisar"`,
  `"SIN SUPERVISION EDUCATIVA"`. Un tablero cuenta categorías, y `NA` no es una
  categoría.
- **Las columnas que un tablero ya lee se dejan con su caja original.** Si el
  estado en el crudo es `"Resuelto"` / `"En revisión"`, no se pasa a mayúsculas:
  solo se completan los `NA`.

### 2.9 Fechas y edad

- Cada fecha se deriva a una columna nueva, con el formato explícito. El
  comentario lleva el ejemplo de la transformación: `# 15/03/2009 00:00:00 ->
  2009-03-15`.
- La edad se calcula contra `Sys.Date()`, y el comentario **avisa que cambia
  entre corridas**. Es una fuente de diferencias que después nadie encuentra.
- El rango de edad va en un `case_when` con **cortes distintos por rol**, y los
  cortes tienen que ser **idénticos en todas las fuentes**: si una fuente usa
  otros, los conteos de la base maestra no cuadran.
- Las etiquetas van numeradas (`"1. Menores de 14 anios"`, `"2. 14 a 16
  anios"`), para que ordenen solas en cualquier tablero.
- El `.default` es una categoría explícita (`"5. Sin dato"`), nunca `NA`.

### 2.10 Crear vacías las columnas del contrato que la fuente no tiene

Con el tipo correcto:

```r
fecha_registro = as.Date(NA),
participo_2025 = NA_character_
```

Si no, el `bind_rows` de la integración las inventa como lógicas y el contrato
de tipos se rompe. `NA` pelado es lógico.

---

## 3. Los bloques de llave: el orden y por qué

El corazón del script. **Un bloque por llave**, y el orden no es negociable:

```
nombre  ->  correo  ->  celular  ->  documento
```

**El motivo es el nombre.** El bloque de nombre produce la columna normalizada
de nombres, y esa columna es el **vocabulario** que usan los otros tres para
separar palabras pegadas. Si se invierte el orden, los otros tres se quedan sin
diccionario y la separación falla.

Regla general: **de la llave más limpia a la más sucia**, porque cada bloque
aprovecha la salida de los anteriores.

### 3.1 La idea central: la gente escribe los datos en el campo equivocado

Esto es lo que distingue este procedimiento de una limpieza normal. **Cada campo
puede contener cualquiera de las cuatro entidades.** Alguien escribe su correo
en el campo de nombre, su cédula en el de celular, su nombre en el de cédula.

Entonces cada bloque extrae **las cuatro entidades**, no solo la propia. La
matriz completa, con 4 campos × 4 entidades = 16 columnas de salida:

|  | de nombre | de correo | de celular | de documento |
|---|---|---|---|---|
| **nombre** | `nombre_norm` | `correo_nombre` | `celular_nombre` | `documento_nombre` |
| **documento** | `nombre_documento` | `correo_documento` | `celular_documento` | `documento_norm` |
| **celular** | `nombre_celular` | `correo_celular` | `documento_celular` | `celular_norm` |
| **correo** | `nombre_correo` | `documento_correo` | `celular_correo` | `correo_norm` |

La convención de nombres es `<campo>_<entidad>`: `celular_documento` es *el
documento que estaba escrito en el campo de celular*. La diagonal es la entidad
propia del campo y se llama `<campo>_norm`.

### 3.2 Los 14 pasos de un bloque

No todos aplican a todos los campos. La columna dice a cuáles.

| # | Paso | Aplica a |
|---|---|---|
| 1 | **Desdoblar filas** cuando la celda trae dos valores | correo, documento |
| 2 | **Extraer el correo**, antes de limpiar | nombre, celular, documento |
| 3 | **Limpieza base → `_limpio`** | los cuatro |
| 4 | **Extraer el nombre** escondido | correo, celular, documento |
| 5 | **Extraer los dígitos**: `_digitos` y `_grupos` | celular, documento |
| 5b | **Correcciones manuales** (`tribble` + `left_join`) | donde haga falta |
| 6 | **Extraer el documento** escondido | nombre, correo, celular |
| 7 | **Extraer el celular** escondido | nombre, correo, documento |
| 8 | **Reconstruir / normalizar** el valor propio | los cuatro |
| 9 | **Clasificar → `_tipo`** | los cuatro |
| 10 | **Armar la llave `_norm`** según el tipo | los cuatro |
| 11 | **Diagnóstico**: `_regla`, `_modificado`, `_validez`, `_norm_9` | celular, documento |
| 12 | **Quitar auxiliares** (las list-columns siempre) | los cuatro |
| 13 | **Validación** numerada | los cuatro |
| 14 | **Quitar columnas de trabajo** + `names()` | los cuatro |

El paso 2 va **antes** del 3 a propósito: si se limpia primero, el correo se
destruye y ya no se puede extraer. Y el paso 3 quita el correo del texto para
que no contamine los dígitos ni el nombre.

---

## 4. Paso 1 — Desdoblar filas

Cuando una celda trae dos valores, la fila se **duplica**: una por valor. Esto
va antes que todo lo demás, porque limpiar una celda con dos valores adentro
produce un valor inventado.

El patrón, idéntico en los dos campos que lo necesitan:

```r
x <- x %>%
  mutate(

    # marca el corte entre dos valores
    campo_partes = <inserta un separador o extrae todos los valores>,

    # marca las filas que traían 2+
    campo_separado = lengths(campo_partes) > 1,

    # valor de trabajo de esta fila (la columna original queda intacta)
    campo_fila = campo_partes
  ) %>%

  # duplica la fila: una por cada valor encontrado
  unnest(campo_fila, keep_empty = TRUE) %>%

  # quita la auxiliar (es list-column)
  select(-campo_partes)
```

Tres detalles que importan:

- **`keep_empty = TRUE`**, o las filas sin ningún valor se pierden.
- **La columna original nunca se toca.** Se trabaja sobre `campo_fila`.
- **Si hay un solo valor, se conserva el original tal cual**, no el extraído:
  ```r
  campo_fila = map2(campo_partes, campo, ~ if (length(.x) > 1) .x else .y)
  ```
  Porque el extractor está calibrado para separar, no para limpiar, y con un
  solo valor recortaría de más.

Cómo cortar, por tipo de campo:

- **Correo**: donde un dominio es seguido de otro `local@`. Se inserta un
  marcador y se parte por él:
  `(?i)(\.[A-Za-z]{2,4})[-/;,]+(?=[A-Za-z0-9._%+-]+@)` → `\1|`.
  Cortar por cualquier separador partiría `juan-perez@hotmail.com`.
- **Documento**: `\b[0-9]{6,8}\b`, **delimitado**. Sin los `\b` se parten los
  números largos y el dígito verificador.

---

## 5. Paso 3 — Limpieza base, en este orden exacto

El orden importa: cada paso depende del anterior.

1. **`stri_trans_nfkc()` primero.** Es **imprescindible** y es lo único que
   convierte el Unicode decorativo: 𝕘𝕞𝕒𝕚𝕝, 𝑔𝑚𝑎𝑖𝑙, 𝐠𝐦𝐚𝐢𝐥, 𝟎𝟗𝟖𝟏.
   **`Latin-ASCII` NO lo hace.** Si esto no va primero, esos valores se pierden.
2. **Quitar el correo completo del texto**, para que no contamine ni los dígitos
   ni el nombre.
3. **`stri_trans_general(..., "Latin-ASCII")`** — Ñ y tildes.
4. **Quitar el decimal que agrega la hoja de cálculo**: `sub("\\.0+$", "", x)`.
   `7796884.0` → `7796884`. Solo en campos numéricos.
5. **Quitar caracteres especiales.** Acá hay que decidir qué se conserva, y la
   decisión es distinta por campo:
   - **En el correo se conservan `. _ % + - @`**, que son válidos.
   - **En los demás campos, todo lo que no es letra, dígito o espacio pasa a
     espacio**, no se borra. Es clave: borrarlo pegaría dos números distintos en
     uno inventado (`123-456` no puede volverse `123456`).
6. **`str_squish()`** para colapsar espacios y recortar extremos.
7. **Los textos que significan "sin dato" pasan a `NA`**, con la **lista literal
   de cada campo**. No una regex genérica: la lista se construye mirando los
   datos y crece con cada corrida. `"NULL"`, `"NA"`, `"NO"`, `"NOTENGO"`,
   `"NINGUNO"`, `"SIN CEDULA"`, `"SIN NUMERO"`, y las respuestas que son
   comentarios (`"SIESTABIENESCRITO"`, `"YAESTA"`, `"LELELELE"`).

En el correo se agregan además, después del punto 5, las reparaciones de forma:
`@@` → `@`, quitar `@` inicial, quitar terminación vacía (`@`, `@.`, `@.com`),
y la coma por punto en el dominio (`GMAIL,COM` → `GMAIL.COM`).

---

## 5b. Paso 4 — Extraer el nombre escondido en cualquier campo

Este paso es **idéntico en los tres campos que no son el de nombre** (correo,
celular y documento), y siempre en esta secuencia:

```r
# 1. deja solo letras y espacios, en mayúsculas
campo_nombre = str_squish(gsub("[^A-Z ]", " ", toupper(campo_limpio))),

# 2. quita los restos de dominio, por si el campo traía un correo
campo_nombre = str_remove_all(
  campo_nombre,
  "\\b(G?MAIL|GMAI|GMIAL|HOTMAIL|YAHOO|OUTLOOK|ICLOUD|LIVE|COM|NET|ORG|EDU|PY|CORREO)\\b"
),

# 3. colapsa los espacios que dejó la línea anterior
campo_nombre = str_squish(campo_nombre),

# 4. separa los nombres escritos todo junto
campo_nombre = separar_nombres_pegados(
  campo_nombre,
  vocabulario = nombre_norm,
  min_largo   = <8 o 12, ver abajo>
),

# 5. exige 2+ palabras reales: descarta letras sueltas y palabras únicas
campo_nombre = ifelse(
  str_count(campo_nombre, "\\b[A-Z]{2,}\\b") < 2,
  NA,
  campo_nombre
)
```

**El umbral `min_largo` cambia según el campo, y no es arbitrario:**

| Campo de origen | `min_largo` | Por qué |
|---|---|---|
| **nombre** (el propio) | **8**, y **sin** `vocabulario` | la columna es el mejor diccionario que hay; con el 12 por defecto quedaban pegados `ISAACLOPEZ`, `MARIOMOREL`, `ADRIANARMOA` |
| **correo** | **8** | el local de un correo es corto y suele traer el nombre completo pegado |
| **celular** | **12** | acá el texto es residual: un umbral bajo produce falsos positivos a partir de basura |
| **documento** | **12** | igual que celular |

El paso 2 (quitar los restos de dominio) es imprescindible en el campo de correo
y barato en los otros dos: si el campo traía un correo, sin esta línea `GMAIL` y
`COM` entran al nombre y lo convierten en una llave falsa que machea con
cualquiera.

---

## 6. Reglas por entidad

Acá está el conocimiento específico. Las formas de documento y teléfono son de
Paraguay; sección 11 dice cómo adaptarlas.

### 6.1 Nombre

**Normalizar** con la función de nombre (mayúsculas, sin tildes, sin caracteres
raros). Después:

- **Los textos "sin dato" a `NA`**, incluida la etiqueta que produce la propia
  función de normalización cuando el valor entra vacío.
- **Separar palabras pegadas** con segmentación por diccionario y programación
  dinámica. `ALANMATIASBENITEZ` → `ALAN MATIAS BENITEZ`. Separó 109 de 113 casos
  en la base testigo. Dos parámetros:
  - `min_largo`: umbral de longitud para ser candidato. **Usar 8, no el 12 por
    defecto.** Con 12 no se toca nada de 9 a 11 letras, y `ISAACLOPEZ`,
    `MARIOMOREL` y `ADRIANARMOA` se quedaban pegados: esa persona perdía su
    llave de nombre.
  - `pen`: cuán agresiva es la penalización de los pedazos desconocidos.
  - **En el bloque de nombre se llama SIN vocabulario**: la propia columna es el
    mejor diccionario. En los otros tres se le pasa la columna de nombre ya
    normalizada.
- **Exigir 2 o más palabras de 2 o más letras**:
  ```r
  ifelse(str_count(x, "\\b[A-Z]{2,}\\b") < 2, NA, x)
  ```
  Descarta `AB`, `CR`, `D B`, `APALACIO`, `CEFERINA`. Una sola palabra no
  identifica a nadie y fusiona personas al deduplicar.
- **Descartar las respuestas que son comentarios**, con la lista literal:
  `"NO ME LLEGO EL CORREO POR QUE ESTABA BLOQUEADA MI GMAIL"`.

**Paso 5b — rescatar el nombre escondido en el correo del propio campo.** Es el
gemelo del rescate de documento. Cuando alguien escribe su correo donde iba el
nombre, la normalización no deja nada, y el local de ese correo sí dice quién es:
`Mirtasoledadramirezferreira@gmail.com` es `MIRTA SOLEDAD RAMIREZ FERREIRA`.

Se toma lo que va antes del arroba, se deja solo letras, se quitan los restos de
dominio, se separan las palabras pegadas, se exige 2+ palabras, y **se vuelca
con `coalesce(nombre_norm, nombre_del_correo)`**: el nombre del propio campo
manda siempre, este solo llena el hueco.

No alcanza con que lo resuelva el bloque de correo: eso solo funciona cuando el
correo del campo de nombre es el mismo que el del campo de correo, y no siempre
lo es.

**Clasificación `nombre_tipo`**, en orden de evaluación:

| Valor | Condición |
|---|---|
| `nombre` | quedó un nombre utilizable en `_norm` |
| `correo` | no era nombre, pero el campo traía un correo |
| `numero` | no era nombre, pero traía un documento o un teléfono |
| `vacio_o_basura` | `NULL`, un comentario, o texto sin sentido |

Es la más corta de las cuatro, porque el campo de nombre es el que menos
sorpresas trae.

**La llave de nombre es `nombre_norm` directo**: no hay filtro por tipo como en
las otras tres. Lo que sobrevivió a los cinco filtros del paso 5 ya es una llave
válida, y lo que no, quedó en `NA` ahí mismo.

### 6.2 Correo

Cuatro subpasos, en orden:

**a) Reponer el `@` faltante**, insertándolo antes del dominio conocido:

```r
correo_limpio = if_else(
  str_detect(correo_limpio, "@"),
  correo_limpio,
  str_replace(correo_limpio, "(?i)(?=(g?mail|gmai|gmal|gmial|gnail|gamil|gemail|hotmail|hotmal|yahoo|outlook|live|icloud|email|mec\\.|tigo\\.|copaco|personal))", "@")
)
```

**b) Normalizar los dominios mal escritos**, de la variante específica al
fallback amplio. El orden importa: el fallback se llevaría los específicos.

```r
"(?i)@(HOTMAIL|HOTMAL|HOTMIAL|HOMAIL|HOTMAI|OTMAIL|HOMTAIL)[^@]*$"  -> "@HOTMAIL.COM"
"(?i)@(YAHOO|YAHO|YAOO|YHAOO)[^@]*$"                                -> "@YAHOO.COM"
"(?i)@(OUTLOOK|OUTLOK|OUTLOCK|OUTLOOCK)[^@]*$"                      -> "@OUTLOOK.COM"
"(?i)@(ICLOUD|ICLOD|ICLOUND)[^@]*$"                                 -> "@ICLOUD.COM"
"(?i)@(LIVE|LIV)[.,_-][^@]*$"                                       -> "@LIVE.COM"
"(?i)@(GMIAL|GNAIL|GAMIL|GMAIK|GMAUL|GMEIL|GMIL|GMAI)[^@]*$"        -> "@GMAIL.COM"
"(?i)@G?[AEIM]*MA?I?L+L?[^@]*$"                                     -> "@GMAIL.COM"  # fallback amplio
"(?i)@GM?A?I?L?$"                                                   -> "@GMAIL.COM"  # truncados
```

El `[^@]*$` de cada patrón es lo que ancla al último arroba y evita tocar el
local.

**c) Validar el formato** con `str_extract` del patrón completo:
`[A-Za-z0-9][A-Za-z0-9._%+-]*@[A-Za-z0-9.-]+\.[A-Za-z]{2,}`.

**d) Separar en `_local` y `_dominio`.** **El local sobrevive aunque el dominio
se pierda** y sirve como llave secundaria:

```r
correo_local = coalesce(
  str_remove(correo_norm, "@.*$"),      # del correo válido
  str_remove(correo_limpio, "@.*$")     # o, si falta, del texto limpio
)
```

**Clasificación `_tipo`**, en este orden de evaluación:

| Valor | Condición |
|---|---|
| `institucional` | válido y el dominio es educativo o de gobierno |
| `correo` | válido, dominio común |
| `vacio` | el campo venía vacío o sin dato |
| `celular` | cero letras y tiene forma de teléfono |
| `cedula` | cero letras y tiene forma de documento |
| `numero` | cero letras, sin forma conocida |
| `incompleto` | 4+ letras y el local **tiene sustancia** |
| `insuficiente` | 1+ letras, local sin sustancia |
| `basura` | nada usable |

**"Local con sustancia"** es la definición que decide si un correo roto sirve
como llave:

```r
correo_util = !is.na(correo_nombre) | nchar(correo_local) >= 10
```

O sea: es un nombre compuesto reconocido, o una cadena de 10+ caracteres. Los de
una palabra corta (`RUIZ`, `VIVIAN`, `TIKYM80`) quedan `insuficiente` y **no
entran a la llave**: son demasiado comunes y fusionarían personas.

**Llaves**: entran `correo` e `institucional` con el correo completo, y
`incompleto` con el local. La llave secundaria `_llave2` es el local, para la
segunda pasada del cruce.

### 6.3 Celular

**La convención local, confirmada con el equipo de campo: el `0` inicial
sustituye al código de país.** Es el hecho del que se derivan todas las reglas:

- `0` + 9 dígitos → `595` + esos 9
- `0` + 8 dígitos → `5959` + esos 8

Medido en los datos: 10.576 valores con cero inicial tienen cuerpo de 9 dígitos
y 86 de 8 dígitos. Ningún `21` ni `61`, así que no hay teléfonos fijos
mezclados.

**Paso 5 — extraer los dígitos.** Dos columnas: todos los dígitos juntos
(`_digitos`) y los grupos separados (`_grupos`). Y sacar de las dos los valores
de un solo dígito repetido (`0`, `00000000000`), que no son números reales.

**Paso 6 — elegir el grupo con forma de teléfono. El orden importa mucho:**

```r
celular_candidato = map_chr(celular_grupos, function(g) {

  # PRIMERO todos los dígitos juntos
  todo <- paste(g, collapse = "")
  if (<alguno de los patrones>) return(todo)

  # DESPUÉS los grupos sueltos
  g <- g[<alguno de los patrones>]
  if (length(g)) g[1] else NA_character_
})
```

Probar primero el pegado y después los sueltos **no es un detalle**: una fuente
escribe el celular como `(0985) 839-942`, el paso 3 convierte el paréntesis y el
guion en espacio, y el número queda partido en `0985`, `839` y `942`, y ninguno
de los tres calza. Sin esa línea se perdieron los 1.372 celulares de una
población entera.

**Paso 8 — reconstruir.** Un `case_when` de once ramas, **de la más específica a
la más general**:

```r
is.na(cuerpo)                                    ~ NA_character_
"^595\\d{9}$"                                    ~ cuerpo                      # ya completo
"^5950\\d{9}$"                                   ~ sub("^5950", "595", cuerpo) # país + 0 local
"^59590\\d{9}$"                                  ~ sub("^59590", "595", cuerpo)
con_cero & "^\\d{9}$"                            ~ paste0("595", cuerpo)
con_cero & "^\\d{8}$"                            ~ paste0("5959", cuerpo)
"^99\\d{8}$"                                     ~ paste0("595", sub("^9", "", cuerpo))  # un 9 de más
"^9\\d{8}$"                                      ~ paste0("595", cuerpo)
PREFIJOS_CELULAR_CUERPO8                         ~ paste0("5959", cuerpo)      # le falta el 9
"^9\\d{8}0$"                                     ~ paste0("595", sub("0$", "", cuerpo))  # 0 de más
TRUE                                             ~ cuerpo                      # se conserva tal cual
```

**La rama final conserva el valor.** Es la regla 2 en acción: lo que no calza no
se descarta.

Dos precisiones:

- **La lista blanca de prefijos solo aplica a los números SIN cero inicial.** Con
  cero, la convención ya lo resuelve y la lista no interviene.
- La marca `_con_cero` se calcula **antes** de quitar los ceros, y se usa en el
  `case_when`. Sin ella no se distingue `0981...` de `981...`.

**La lista blanca es UNA, y vive en `src/00_setup/00_functions.R`.** Se usa así
y no se vuelve a escribir a mano en ningún script:

```r
PREFIJOS_CELULAR          # el vector de 21 prefijos
PREFIJOS_CELULAR_INICIO   # "^(71|72|...|99)"        selección del candidato
PREFIJOS_CELULAR_CUERPO8  # "^(71|72|...|99)\\d{6}$" rama "le falta el 9"
```

Los 21 prefijos son `71`–`76`, `81`–`86` y `91`–`99`, **medidos en los datos y no
declarados de memoria**. Sobre el crudo del RCE: los cuerpos de 8 dígitos
arrancan en `71`, `73`, `74`, `76`, `81`–`86` y `91`–`99`, y los dígitos 2-3 de
los 11.729 celulares bien escritos cubren además `72` y `75`. Los que arrancan en
`13`, `35`, `48`, `49` y `53` quedan afuera.

**Recordar de dónde sale cada prefijo, no qué operador es.** Qué rango pertenece
a qué compañía no se puede deducir de estos datos, y no hace falta para nada: lo
que decide es la convención de escritura, que ya está confirmada por el equipo.

> **Historia, porque el error es fácil de repetir.** Hasta el 2026-09-08
> convivían **dos listas distintas**: una de 11 prefijos para elegir el candidato
> y otra de 16 para reconstruirlo. Los cinco extra de la larga (`91` a `95`) eran
> **código muerto**: la selección usaba la corta, así que un número de 8 dígitos
> que arrancaba en `91` nunca llegaba a ser candidato y la rama que lo aceptaba
> no lo veía jamás. Y `71`, `73`, `74` y `76`, medidos en los datos, no estaban en
> ninguna de las dos. Entre el código muerto y los faltantes eran **35 celulares
> paraguayos reales sin normalizar** solo en el RCE.

Al escribir una fuente nueva: usar las constantes, y si aparece un prefijo nuevo
en los datos, agregarlo **en `00_functions.R`**, medido, no de memoria.

**Clasificación `_tipo`**: `celular` · `cedula` · `correo` · `nombre` ·
`vacio_o_basura` · `muy_corto` (menos de 6 dígitos) · `revisar` (hay dígitos que
no calzan).

**Llave**: entra `celular`, y **también `revisar`, con los dígitos crudos**. Lo
desconocido entra.

**Paso 11 — los tres diagnósticos.** Son la columna vertebral de la
trazabilidad:

- **`_regla`**: `"Cumple reglas"` si quedó con la forma completa,
  `"No cumple reglas"` si no. `NA` si no hay valor.
- **`_modificado`**: `"Modificado"` / `"No modificado"`, comparando la llave
  contra los dígitos originales.
- **`_validez`**: `"Numero falso"` / `"Numero verdadero"`. **Se evalúa solo
  sobre los bien formados** y solo sobre el cuerpo, sin el código de país:
  ```r
  "^(\\d)\\1{8}$"      # todos iguales
  "(\\d)\\1{5}"        # seis o más repetidos seguidos
  %in% c("012345678", "123456789", "987654321", "876543210")  # secuencias
  ```

Los números falsos **se marcan y se sacan de la llave** en un paso aparte y
explícito, no dentro de la reconstrucción.

### 6.4 Documento

La clasificación más rica del procedimiento, y la que más aprendizaje acumula.
Este es el `case_when` completo, en el orden exacto de evaluación:

| # | `_tipo` | Condición | Por qué |
|---|---|---|---|
| 1 | `documento_extranjero` | letra y dígito pegados en el mismo token | `1007266A`, `E2147408`, `K647472`. Son 31 filas |
| 2 | `basura` | dígitos repetidos o secuencia | `123456`, `999999` pasan el filtro de forma y **después fusionan personas distintas** |
| 3 | `multiple` | 2+ números con forma de documento | hay que decidir a mano |
| 4 | `documento_largo` | 10-11 dígitos **que no arrancan con `09`** | CPF brasileño con separador (`062068141-14`) y sin él. **Va acá arriba**: si no, los dos ramales de celular se lo llevaban y la fila terminaba con la llave en `NA` |
| 5 | `celular` | tiene patrón de celular | por definición no es documento |
| 6 | `celular` | arranca en `09` | convención local: es teléfono |
| 7 | `cedula` | arranca en `0` pero **no** en `09` | **no existe celular local con esa forma**: es un documento con cero de relleno. Recupera 6 documentos del padrón, 4 de ellos escritos igual en otra fuente y que antes no cruzaban porque las dos los tiraban |
| 8 | `cedula` | 6-8 dígitos sin cero inicial | **empiece con el dígito que empiece** |
| 9 | `cedula_9` | 9 dígitos | documento con verificador, o con un dígito de más |
| 10 | `documento_largo` | 10-11 dígitos | el resto |
| 11 | `revisar_largo` | 12 o más | número imposible |
| 12 | `cedula` | 5 dígitos | documentos viejos. Son 11 valores, ninguno compartido por dos personas, y 3 cruzan con otra fuente |
| 13 | `muy_corto` | menos de 5 dígitos | no identifica a nadie |
| 14 | `nombre` | solo texto con forma de nombre | |
| 15 | `vacio_o_basura` | `TRUE` | |

**El aprendizaje más importante de todo el procedimiento está en la fila 8:
el documento NO se identifica por el primer dígito.** Medido en la base: los
documentos de 6-8 dígitos empiezan con 1 (151 casos), 2 (336), 3 (435), 4 (704),
5 (263), 6 (4.319), 7 (4.636), 8 (1.427), 9 (264) y **ninguno con 0**. La regla
correcta es **6-8 dígitos sin cero inicial y sin patrón de teléfono**, nunca una
lista de primeros dígitos permitidos.

**Paso 7 — extraer el documento**, con el mismo criterio "pegado primero" del
celular:

```r
documento_numero = map_chr(documento_grupos, function(g) {
  todo <- paste(g, collapse = "")
  if (nchar(todo) %in% 6:8 && !grepl("^0", todo)) return(todo)
  g <- g[nchar(g) %in% 6:8 & !grepl("^0", g)]
  if (length(g)) g[1] else NA_character_
})
```

Resuelve `49 256 195` → `49256195` y `14888040-9` → `14888040`.

Además: **si no hubo documento en el texto, se rescata del correo
institucional** con `str_extract(correo, "^[0-9]{6,8}(?=@)")`.
`2224483@mec.edu.py` → `2224483`.

**Cuando el documento se extrae del campo de celular, hay una exclusión extra.**
El criterio base (6-8 dígitos sin cero inicial) no alcanza ahí, porque un celular
escrito sin el cero troncal tiene 8 dígitos y pasaría como documento. Se le
agrega la lista blanca de prefijos de operador, negada:

```r
celular_documento = map_chr(celular_grupos, function(g) {
  g <- g[
    nchar(g) %in% 6:8 &
      !grepl("^0", g) &
      !(nchar(g) == 8 & grepl(PREFIJOS_CELULAR_INICIO, g))
  ]
  if (length(g)) g[1] else NA_character_
})
```

Esta exclusión **solo va en el campo de celular**. En los campos de nombre y de
correo no se pone: ahí un grupo de 8 dígitos que arranca en 98 es casi siempre
un documento, y negarlo perdería llaves buenas.

**Paso 10 — armar la llave**, en este orden:

```r
documento_norm = documento_digitos                                  # todos los dígitos
documento_norm = coalesce(documento_norm, documento_numero)          # o el rescatado del correo
documento_norm = ifelse(nchar(.) <= 8, sub("^0+", "", .), .)         # ceros a la izquierda SOLO en los cortos
documento_norm = ifelse(tipo %in% c(...), ., NA)                     # filtra por tipo
documento_norm = ifelse(tipo == "documento_extranjero",              # el extranjero conserva letras
                        toupper(str_remove_all(limpio, " ")), .)
documento_norm = ifelse(nchar(.) < 6, NA, .)                         # lo que no identifica a nadie
```

Entran a la llave: `cedula`, `cedula_9`, `documento_extranjero`,
`documento_largo`, `revisar_largo` y `multiple`. **El extranjero conserva letras
y dígitos**, solo se pasa a mayúsculas: borrarle las letras convierte `XDE459953`
en `459953`, que es el documento de otra persona.

**Llave secundaria `_norm_9`**: para los de 9 dígitos, los primeros 8 (el
posible verificador afuera).

### 6.5 Las extracciones cruzadas: una asimetría deliberada

Cuando se extrae un celular **de otro campo**, la reconstrucción tiene solo
cuatro ramas y **la última NO conserva el valor**:

```r
.default = NA_character_
```

Esto es distinto del campo propio de celular, y es a propósito. En el campo de
celular la persona **quiso** escribir un teléfono, así que lo dudoso se conserva.
Pero un grupo de dígitos encontrado dentro de otro campo **solo es un teléfono si
tiene forma de teléfono**. Medido: los 45 valores que esa rama conservaba eran
**fechas de nacimiento comprimidas** (`1082008` es 1/08/2008, `2022009` es
2/02/2009) y ninguno coincidía con un celular real del campo de celular.

Regla general: **los 7 dígitos en un campo de teléfono son fechas de
nacimiento**, no documentos ni teléfonos.

> **Esto cambió a propósito.** La primera versión conservaba el valor tal cual
> también en las extracciones cruzadas, con la misma rama final que el campo
> propio. Se midió y se revirtió: los 45 valores que esa rama conservaba en una
> fuente eran todos fechas de nacimiento, y ninguno coincidía con un celular
> real. Si encontrás un `.default` que conserva en una extracción cruzada, es de
> antes del cambio.

**La asimetría en una tabla**, para no confundirse:

| Dónde | Rama final | Por qué |
|---|---|---|
| Campo **propio** de celular | conserva el valor | la persona quiso escribir un teléfono; lo dudoso se marca, no se tira |
| Celular extraído de **otro** campo | `NA_character_` | un grupo de dígitos solo es un teléfono si tiene forma de teléfono |

La misma lógica aplica a las otras entidades: en su campo propio se es
permisivo, en los campos ajenos se es estricto.

---

## 6b. Paso 13 — La validación de un bloque: siempre las mismas cuatro consultas

Cada bloque de llave cierra con estas cuatro, en este orden y numeradas. No son
opcionales y no cambian de bloque a bloque: son las que hacen que la próxima
corrida encuentre los casos nuevos.

**1. Vista general.** Un `select()` comentado columna por columna: el original,
el `_limpio`, el `_norm`, el `_tipo` y **todas** las extracciones, ordenado por
tipo. Sirve para descubrir patrones que ninguna regla cubre todavía.

```r
# x %>%
#   filter(!is.na(campo)) %>%
#   select(
#     campo,           # original, sin tocar
#     campo_limpio,    # texto limpio
#     campo_norm,      # llave final
#     campo_tipo,      # qué contenía el campo
#     campo_correo,    # correo escondido
#     campo_nombre,    # nombre escondido
#     campo_cedula,    # documento escondido
#     campo_celular,   # celular escondido
#     campo_digitos    # dígitos antes de reconstruir
#   ) %>%
#   arrange(campo_tipo, campo_norm) %>%
#   View()
```

**2. Qué se perdió.** Las filas donde el original **tenía dato** y ninguna de las
cuatro columnas de salida lo capturó, excluyendo los `"NULL"`:

```r
# x %>%
#   filter(
#     is.na(campo_norm) & is.na(campo_correo) &
#       is.na(campo_nombre) & is.na(campo_cedula)
#   ) %>%
#   filter(campo != "NULL") %>%
#   select(campo, campo_limpio, campo_tipo) %>%
#   View()
```

Es la consulta más importante de las cuatro: mide la pérdida real, que es lo
único que no se ve en un conteo por tipo.

**3. Conteo por tipo**, cruzado con `_regla` cuando esa columna existe:

```r
x %>%
  count(campo_tipo, sort = TRUE)

x %>%
  count(campo_tipo, campo_regla, sort = TRUE)
```

**4. Los casos límite.** Los que **entraron a la llave pero no cumplen el
patrón**. Ahí aparecen los patrones nuevos:

```r
# x %>%
#   filter(campo_regla == "No cumple reglas") %>%
#   select(campo, campo_digitos, campo_norm, campo_tipo) %>%
#   View()
```

**Cuáles quedan activas y cuáles comentadas:**

| Consulta | Estado en el script |
|---|---|
| 1. Vista general | **comentada**, con la conclusión escrita abajo |
| 2. Qué se perdió | **comentada**, con la conclusión escrita abajo |
| 3. Conteo por tipo | **activa**, imprime en cada corrida |
| 4. Casos límite | **comentada**, con la conclusión escrita abajo |

La 3 queda activa porque es chica y se lee de un vistazo. Las otras tres abren
un `View()` o devuelven cientos de filas, así que quedan comentadas — pero
**siempre con la conclusión en prosa debajo**:

```r
# Solo 6 registros poco relevantes.
# 11 registros que realmente no aportan nada
# Nada preocupante. Todo es plausible
# Estos 20 casos realmente no hay forma de saber si son números de celular o no
# Los dejaremos y se descartarán luego de detectar duplicados.
```

**Una consulta comentada sin conclusión abajo está incompleta.** El script tiene
que guardar el hallazgo, no solo el código que lo produjo: el que lo lea en seis
meses necesita saber que eso ya se revisó y qué se decidió.

---

## 7. Paso 5b — La tabla de correcciones manuales

Los casos que ninguna regla resuelve van acá, versionados en el script:

```r
correcciones_celular <- tribble(
  ~celular_digitos,      ~celular_corregido,  ~cedula_corregida,
  "09727883106928311",   "0972788310",        "6928311",
  "65885820983535122",   "0983535122",        "6588582"
)

x <- x %>%
  left_join(correcciones_celular, by = "celular_digitos") %>%
  mutate(
    celular_digitos = coalesce(celular_corregido, celular_digitos),
    celular_grupos  = map2(celular_grupos, celular_corregido,
                           ~ if (is.na(.y)) .x else .y),
    celular_cedula_manual = cedula_corregida
  ) %>%
  select(-celular_corregido, -cedula_corregida)
```

**La corrección tiene que pisar TODAS las columnas que alimentan los pasos
siguientes, no solo la primera.** Acá pisa `_digitos` **y** `_grupos`, porque los
pasos 5, 6 y 7 leen los grupos. Pisar solo la primera es un error que no se ve:
la corrección aparece en la vista de validación y no llega a la llave.

---

## 8. Cierre de la fuente

### 8.1 Renombrar los originales a `_orig`

```r
rename(nombre_orig = nombre, cedula_orig = cedula,
       celular_orig = celular, correo_orig = correo)
```

Libera los nombres limpios para las llaves finales y deja el original
rastreable.

### 8.2 El identificador de fila

```r
id_origen = row_number()
```

**Sin esto no se puede volver del formato largo al ancho** ni rastrear qué filas
eran hermanas al deduplicar. Va antes de armar las tablas de llaves.

### 8.3 Las cuatro tablas de llaves en formato largo

Una por entidad. Cada una junta **los cuatro orígenes posibles** de esa entidad
(la fila correspondiente de la matriz de la sección 3.1):

```r
llaves_documento <- x %>%
  select(id_origen,
         documento_norm,      # del campo propio
         nombre_documento,    # escrito en el campo de nombre
         celular_documento,   # escrito en el campo de celular
         correo_documento) %>%  # escondido en el correo
  pivot_longer(cols = -id_origen, names_to = "origen", values_to = "valor") %>%
  filter(!is.na(valor)) %>%

  # la misma regla de basura del bloque de documento, otra vez
  filter(!grepl("^([0-9])\\1+$", valor),
         !stri_detect_fixed("0123456789", valor),
         !stri_detect_fixed("9876543210", valor)) %>%

  mutate(tipo_llave = "documento")
```

**El filtro de basura hay que repetirlo acá.** La rama `basura` del bloque de
documento mira **solo el campo propio**, así que un `123456` escondido adentro de
un correo (`NOMBREAPELLIDO123456@`) entra a la tabla de llaves sin pasar por
ella, y la deduplicación fusiona en una sola persona a todas las que usaron ese
sufijo. La regla es la misma: un dígito repetido, o un tramo de la secuencia
ascendente o descendente.

**Excepción medida: el nombre sacado del local del correo NO entra a la tabla de
nombres.** Se midió sobre 23.419 registros que tenían nombre propio y además
nombre derivado del correo: **el 93% es ruido o redundancia** (las mismas
palabras en otro orden, truncamientos que machean con cualquiera, y correos de
un familiar) y solo el 7% son variantes reales. Una llave de nombre que en
realidad es de otra persona **fusiona a dos personas al deduplicar, y esa fusión
no se puede deshacer.** El único caso donde hace falta ya lo resuelve el paso 5b,
volcándolo dentro de la llave de nombre.

### 8.4 Apilar y colapsar — nunca con `distinct()`

```r
llaves <- bind_rows(llaves_nombre, llaves_documento,
                    llaves_celular, llaves_correo) %>%
  group_by(id_origen, tipo_llave, valor) %>%
  summarise(
    origen     = paste(sort(unique(origen)), collapse = " | "),
    n_origenes = n(),
    .groups    = "drop"
  ) %>%
  arrange(id_origen, tipo_llave, valor)
```

**`distinct()` acá pierde el origen de los valores repetidos.** El `group_by` +
`summarise` conserva de qué campos vino cada valor y agrega `n_origenes`, que es
una **señal de confianza**: un valor que apareció en dos campos distintos es más
confiable que uno que apareció en uno.

Después se agrega la **llave derivada de nombre con las palabras ordenadas**
alfabéticamente, para que `JUAN PEREZ` y `PEREZ JUAN` sean el mismo valor:

```r
valor = map_chr(str_split(valor, " "), ~ paste(sort(.x), collapse = " ")),
tipo_llave = "nombre_ordenado"
```

Es una **llave para cruzar, no un nombre para mostrar**, y no va al dataset
final: solo a la tabla de llaves.

### 8.5 Volver a ancho y expandir

```r
llaves_lista <- llaves %>%
  filter(tipo_llave != "nombre_ordenado") %>%
  group_by(id_origen, tipo_llave) %>%
  summarise(valores = list(unique(valor)), .groups = "drop") %>%
  pivot_wider(id_cols = id_origen, names_from = tipo_llave,
              values_from = valores)

# crea vacías las columnas de llave que esta fuente no tiene
faltantes <- setdiff(c("nombre", "documento", "celular", "correo"),
                     names(llaves_lista))
llaves_lista[faltantes] <- list(list(NA_character_))

x_final <- x %>%
  left_join(llaves_lista, by = "id_origen") %>%
  unnest(nombre,    keep_empty = TRUE) %>%
  unnest(documento, keep_empty = TRUE) %>%
  unnest(celular,   keep_empty = TRUE) %>%
  unnest(correo,    keep_empty = TRUE)
```

**El bloque `faltantes` es obligatorio.** `pivot_wider` solo crea columnas para
los tipos que existen en la tabla larga. Si una fuente no tiene ni un valor de
alguna llave (un padrón que no pregunta correo ni celular), esa columna no sale y
el `unnest` encadenado **aborta**. Se crean vacías y de tipo texto, para que
todas las fuentes pasen por el mismo camino y los tipos del contrato coincidan.

El `unnest` encadenado produce **una fila por combinación de valores**: un
registro con dos correos y un documento sale como dos filas.

### 8.6 Filtrar y deduplicar

```r
x_final <- x_final %>%
  filter(!is.na(nombre) | !is.na(documento) |
         !is.na(celular) | !is.na(correo)) %>%
  distinct(id_origen, nombre, documento, celular, correo, .keep_all = TRUE)
```

**`id_origen` DENTRO del `distinct` es imprescindible.** Sin él se colapsan dos
registros distintos que comparten las cuatro llaves, y en la base testigo eso
dejaba afuera **3.818 de 12.673 registros: el 30%**, con su institución, su
fecha y su problema. El caso típico: la misma persona registrada en dos turnos y
dos secciones. **Esas filas no se eliminan acá**: no se sabe a cuál pertenece, y
solo el cruce con las otras fuentes lo dirá.

### 8.7 Las validaciones finales

Siempre las mismas cinco:

1. **No se perdió ninguna llave**: `n_distinct` de cada tipo en la tabla larga
   tiene que coincidir con el `n_distinct` de la columna en el dataset final.
2. **Filas crudas vs. intermedias vs. finales**, las tres impresas.
3. **No quedan combinaciones repetidas** dentro de un mismo registro:
   `count(id_origen, ...) %>% filter(n > 1) %>% nrow()` tiene que dar 0.
4. **Ningún registro se perdió**: `n_distinct(final$id_origen)` == `nrow(intermedio)`.
5. **Cobertura de cada llave**, con `sin_ninguna` incluido.

Y dos de diagnóstico que **no descartan nada, solo miden para poder reclamar en
la fuente**:

- **Llaves compartidas entre personas distintas.** Contando `n_distinct(id_origen)`
  y **no filas**, porque el `unnest` dejó varias filas por registro y contar
  filas mediría la expansión, no el problema.
- La vista final de las cuatro llaves, comentada.

### 8.8 La selección final: el contrato

**Las columnas de salida son un contrato entre todas las fuentes.** Mismos
nombres, mismo orden, mismos tipos, para que la integración sea un `bind_rows()`
y nada más: ahí no se renombra, no se limpia y no se ordena.

El contrato, en bloques comentados:

```r
x_clean <- x_final %>%
  select(
    # identificación de la fila
    fuente,
    fila_origen,      # único en este archivo
    id_origen,        # el registro; se repite entre las filas expandidas

    # el rol declarado; la base maestra lo corrige con la fuente autoritativa
    rol_declarado = rol,

    # las cuatro llaves, ya normalizadas y expandidas
    documento, nombre, correo, celular,

    # atributos de la persona
    sexo, fecha_nacimiento, edad, rango_edad, fecha_registro, participo_2025,

    # atributos de la institución
    departamento, distrito, codigo_institucion, nombre_institucion,
    modalidad, enfasis, turno, seccion
  )
```

Reglas del contrato:

- **`fila_origen` es único; `id_origen` se repite.** Son las filas que salieron
  del mismo registro al expandir las llaves.
- **`fuente` viaja con cada fila** hasta la integración.
- **El rol se llama `rol_declarado`**, porque es lo que dijo el formulario y
  puede estar mal. La corrección es trabajo de la integración.
- Las columnas propias de una fuente (el problema declarado, el estado de la
  licencia) van **al final**, después del contrato común.
- Una columna que solo aporta una fuente queda en `NA` en las demás, y eso está
  bien y se documenta.

Validación del contrato, tres consultas:

```r
names(x_clean)
sapply(x_clean, function(x) class(x)[1])
nrow(x_clean); n_distinct(x_clean$fila_origen); n_distinct(x_clean$id_origen)
x_clean %>% summarise(sin_fuente = sum(is.na(fuente)), ...)
```

Si hay que mantener un flujo viejo, se guardan **dos objetos con los mismos
datos y distinto vocabulario**, y el comentario dice quién consume cada uno.

**Dos formas de escribir la selección**, y cuándo usar cada una:

- **Enumerar las columnas una por una**, como arriba. Es la forma preferida para
  el objeto que cumple el contrato: el `select` explícito **es** la declaración
  del contrato, y si una fuente deja de traer una columna, falla acá y no tres
  scripts después.
- **Descartar por patrón**, cuando lo que sobra son decenas de columnas de
  trabajo y enumerar las buenas sería más largo:
  ```r
  select(
    starts_with('xxx_'),
    -ends_with('_orig'),
    -starts_with('xxx_nombre_')
  )
  ```
  Sirve para el objeto del vocabulario viejo o para un dataset intermedio. **No
  para el objeto del contrato**: un `starts_with` acepta en silencio una columna
  nueva que nadie esperaba.

---

## 9. Arquetipo B — Tabla de detalle o evento

Mucho más corto. No tiene bloques de llave: la llave **ya viene limpia de la
plataforma** y solo hay que emparejar el formato.

1. **Setup y rutas**, igual que A.
2. **Cargar**, con un comentario que diga el grano y **por qué esta fuente no
   entra al apilado**: no aporta llaves nuevas (medirlo) y una persona aparece
   tantas veces como ítems tenga.
3. **Marcar las filas de prueba**, igual que A (sección 2.5).
4. **Renombrar** al vocabulario común.
5. **La llave de cruce**, y acá va la justificación de por qué no hace falta el
   bloque entero:
   ```r
   # Adentro de la plataforma el correo es el identificador de la cuenta y no un
   # dato escrito a mano: los 26.941 vienen en minúscula, sin espacios y todos
   # con arroba. Alcanza con emparejar el formato para que el cruce sea exacto.
   correo_llave = tolower(trimws(correo))
   ```
   **Verificarlo antes de asumirlo.** Si la plataforma dejó entrar correos
   escritos a mano, hay que aplicar la sección 6.2.
6. **Atributos de texto**, fechas y booleanos. Los `"Yes"`/`"No"` a `TRUE`/`FALSE`
   para poder sumarlos.
7. **Numerar la fila** (`fila_origen`).
8. **El resumen por persona**: `group_by(correo_llave)` + `summarise`.
   **Contar ítems distintos y no filas**, porque una persona puede tener el
   mismo ítem repetido si se reinscribió: `n_distinct(item_id)`, no `n()`.
9. **Validación**: el grano (filas, personas, ítems, pares persona-ítem), que el
   resumen tenga **una fila por persona y ni una más**, la distribución del
   avance, y los ítems más frecuentes.
10. **Salida: dos objetos.** El detalle (una fila por persona e ítem) y el
    resumen (una fila por persona). El comentario aclara que **este archivo no
    sigue el contrato de las fuentes de personas**: su grano es distinto, así que
    no tiene `id_origen` ni llaves, y se cruza por la llave única.

---

## 10. Arquetipo C — Tabla de dimensión

El más corto. No tiene personas.

1. **Setup y rutas.**
2. **Cargar**, con un comentario que explique **para qué sirve el catálogo** y
   con la medición que lo respalda. Ejemplo real: *"su columna de nombre es
   exactamente la cadena que la plataforma usa como nombre de programa: 1.809 de
   los 1.819 distintos están acá con el texto idéntico, y eso cubre 31.013 de las
   36.439 filas. Con este catálogo, el script de la plataforma no tiene que
   adivinar el departamento ni la modalidad: los pide acá."*
3. **Renombrar** al vocabulario común.
4. **Normalización general**, con **el mismo tratamiento que las otras fuentes**:
   un catálogo cuyos valores no coinciden con los de la fuente de personas no
   sirve para cruzar.
5. **Validación**, y acá es más exigente que en A:
   - **Las llaves del catálogo son únicas** (una fila por objeto).
   - **Ninguna columna puede venir vacía**: es una tabla de dimensión, si le
     falta un valor no cumple su función.
   - **El vocabulario de cada atributo**, para comprobar que quedó igual al de
     las otras fuentes.
   - **Un total de control** contra otra fuente: la matrícula del catálogo tiene
     que dar las mismas filas que el padrón de personas.
6. **Salida**: las columnas del catálogo y nada más. Sin `fuente`, sin
   `fila_origen`, sin `id_origen`.

---

## 11. Adaptar esto a otro país o dominio

Lo que es **universal** (no tocar):

- Las cinco reglas de la sección 0.
- Los tres arquetipos y cómo distinguirlos.
- El orden de los bloques de llave, y el motivo (el nombre es el vocabulario).
- Los 14 pasos y el orden interno de la limpieza base (sección 5), sobre todo NFKC
  primero.
- La matriz de extracción cruzada (sección 3.1) y la asimetría de la sección 6.5.
- Todo el cierre: `_orig`, `id_origen`, tablas largas, `group_by` en vez de
  `distinct`, `faltantes`, `unnest` encadenado, `id_origen` dentro del
  `distinct`, las cinco validaciones, el contrato.
- Las reglas del correo (sección 6.2) son casi universales; solo cambian los dominios
  locales de la lista.

Lo que hay que **volver a medir** en la fuente nueva:

- **La forma del documento.** Cuántos dígitos, si admite letras, si hay
  verificador. Y **medir la distribución del primer dígito antes de escribir
  cualquier regla que dependa de él** (sección 6.4).
- **La convención telefónica.** ¿Hay un prefijo troncal que sustituye al código
  de país? ¿Cuántos dígitos tiene el cuerpo? ¿Qué prefijos de operador existen?
  ¿Hay teléfonos fijos mezclados (medirlo: buscar los prefijos de fijo)?
- **La lista de textos que significan "sin dato"**, que es idiomática.
- **Los cortes de rango de edad**, que son del proyecto.
- **Los umbrales**: `min_largo` de la separación de palabras, el mínimo de
  caracteres de la llave, el mínimo de palabras del nombre.

El método para medir es siempre el mismo: **contar y mirar ejemplos antes de
escribir la regla**, y dejar el número en el comentario.

---

## 12. Las trampas que ya costaron caro

Todas son errores reales que llegaron a producción en este proyecto.

1. **`nchar(NA_character_)` devuelve `NA`, no 2.** Y `str_count(NA, ...)`
   también. Con una columna enteramente `NA` (la llave que una fuente no tiene),
   el vector de validez queda en `NA`, `ifelse()` devuelve un vector **lógico**
   en vez de texto, y `na_if()` aborta con un error de `vec_cast`.
   **Toda validación abre con `!is.na(x) &` y cierra con
   `na_if(as.character(y), "")`.**

2. **Comparar texto contra un número.** `documento <= 9999` sobre una columna de
   texto compara **cadenas**: `"4512345" <= 9999` es `TRUE` porque `"4"` va
   antes que `"9"`. Ese `ifelse` **borró casi todos los documentos de una fuente**
   y nadie lo notó hasta que el cruce por documento dio cero matches. El bloque
   lo compensaba con 4.045 matches por nombre único, la llave más frágil.

3. **`summarise(valor = paste(...), n = n_distinct(valor))`.** La segunda
   expresión ve el `valor` **ya colapsado** y devuelve siempre 1. El conteo se
   calcula **primero**.

4. **`coalesce` en las llaves pierde información.** Si el correo de una fuente
   pisa al de otra, la cuenta de la plataforma que usaba el segundo queda
   huérfana y aparece como una persona nueva. **Las llaves se acumulan en formato
   largo, nunca se colapsan a un valor por persona.**

5. **La corrección manual tiene que pisar todas las columnas** que alimentan los
   pasos siguientes, no solo la primera (sección 7).

6. **Las list-columns se borran siempre** antes de terminar el bloque: rompen
   `View()` y la escritura del `.RData`. Lo mismo con las **columnas matriz** que
   devuelve `str_match`.

7. **Documentos basura** (`123456`, `999999`) pasan todos los filtros de forma y
   después **fusionan personas distintas** al deduplicar. Hay que clasificarlos
   como `basura` en el `_tipo`.

8. **Los 7 dígitos en un campo de teléfono son fechas de nacimiento**
   (`1082008` = 1/08/2008), no documentos ni teléfonos.

9. **`Latin-ASCII` no convierte el Unicode decorativo.** Solo NFKC. Y va
   primero.

10. **`pivot_wider` no crea las columnas que no existen en la tabla larga**, y el
    `unnest` encadenado aborta. De ahí el bloque `faltantes` (sección 8.5).

11. **`distinct()` sin `id_origen`** colapsa registros distintos que comparten
    llaves: el 30% de una fuente (sección 8.6).

12. **Una función de normalización con un bug se usa en varias fuentes.** El caso
    real: la función de teléfono quitaba **un solo** cero inicial y no reintentaba
    la regla de 8 dígitos, así que `083859706` y `00982620172` quedaban sin
    normalizar. La usaban tres fuentes. Cuando un bloque no puede usar la función
    compartida, **reconstruye a mano y reproduce sus columnas de diagnóstico**, y
    el comentario dice por qué no la usa.

13. **La función que limpia el Unicode decorativo aborta con `NA` o con texto que
    no sea UTF-8 válido.** `utf8ToInt` devuelve `NA` y el `if` de adentro no lo
    puede evaluar. Hoy no explota porque los datos llegan en ASCII, pero **un solo
    byte latin1 corta el pipeline entero**. Al usar una función que recorre
    codepoints, protegerla con `!is.na(x) &` antes de llamarla, o preferir
    `stri_trans_nfkc()`, que maneja `NA` sin quejarse.

14. **Una función que borra las letras de un documento lo convierte en el
    documento de otra persona.** El caso real: la función de normalización del
    universo dejaba `XDE459953` como `459953`. Cualquier función que "limpie" un
    identificador tiene que preservar los caracteres que forman parte de él.

15. **`ifelse()` con condición `NA` devuelve `NA`.** No devuelve la rama del
    `FALSE`: devuelve `NA`, y ahí se pierde el valor. El caso real: el paso que
    saca de la llave los teléfonos falsos preguntaba
    `validez == "Numero falso"`, pero esa columna queda en `NA` en todo número
    que no cumple la regla del país. En una fuente sin un solo número falso, ese
    paso borró de la llave decenas de números extranjeros bien identificados.
    **Toda condición de un `ifelse` que mire una columna con `NA` lleva el
    `!is.na()` explícito delante**, o se escribe con `%in%`, que no evalúa el
    `NA`.

16. **La regla de "un solo dígito repetido" es del campo completo, no de cada
    grupo de dígitos.** Cuando alguien escribe el teléfono separado —
    `(0985) 107-111`— los grupos son `0985`, `107` y `111`, y `111` es **parte
    del número**. Descartarlo por repetido dejaba el candidato incompleto: la
    reconstrucción no disparaba, el número caía en `revisar` y entraba a la llave
    con el cero inicial, fuera del formato del contrato. Al filtrar grupos, el
    descarte pide **seis o más** dígitos iguales; el campo completo sigue
    descartándose con uno.

17. **Si dos fuentes traen la misma variable, el bloque tiene que ser el mismo
    texto.** No parecido: el mismo. El caso real: el bloque de documento de una
    fuente se quedó con cuatro ramas menos que el de las otras cinco —le faltaba
    la de basura, la de documento largo, el corte del cero inicial y la cédula
    corta— y esas diferencias solo se vieron cuando la basura apareció en la base
    maestra, semanas después. **La forma de comprobarlo es un diff normalizado**:
    quitar comentarios y líneas vacías, reemplazar el prefijo del objeto y la
    tubería, y diferenciar bloque contra bloque. Tiene que dar cero.

---

## 13. Checklist antes de dar el script por terminado

- [ ] El arquetipo está identificado y el procedimiento es el que corresponde.
- [ ] La carpeta de entrada **no** se crea; la de salida sí.
- [ ] El comentario de carga dice cuántas filas trae el crudo.
- [ ] Las filas rotas se descartan y las de prueba se **marcan**, con su conteo.
- [ ] Si hay dos poblaciones, están las tres consultas de `intersect`/`setdiff`.
- [ ] Los bloques van en el orden nombre → correo → celular → documento.
- [ ] El bloque de nombre llama a la separación de palabras **sin** vocabulario;
      los otros tres **con** la columna de nombre ya normalizada.
- [ ] `min_largo` es 8 en nombre y correo, y 12 en celular y documento.
- [ ] El paso 4 quita los restos de dominio antes de separar las palabras.
- [ ] La extracción de documento desde el campo de celular niega los prefijos
      de operador.
- [ ] NFKC es lo primero de cada limpieza base.
- [ ] Cada campo extrae **las cuatro** entidades.
- [ ] Las extracciones cruzadas de celular terminan en `NA`, no conservan.
- [ ] Cada llave tiene su `_tipo`, y el `_tipo` decide qué entra a `_norm`.
- [ ] Lo desconocido entra a la llave; solo sale lo identificado como otra cosa.
- [ ] Celular y documento tienen sus columnas de diagnóstico.
- [ ] Las list-columns y las columnas matriz están borradas.
- [ ] Cada bloque termina con **las cuatro** consultas de validación, con la 3
      activa y las otras tres comentadas **y con su conclusión escrita abajo**.
- [ ] Está el `id_origen` antes de las tablas de llaves.
- [ ] Las llaves se colapsan con `group_by` + `summarise`, no con `distinct`.
- [ ] Está el bloque `faltantes` antes del `unnest` encadenado.
- [ ] El `distinct` final incluye `id_origen`.
- [ ] Están las cinco validaciones finales y las dos de diagnóstico.
- [ ] La salida cumple el contrato: mismos nombres, orden y tipos.
- [ ] Cada regla no obvia tiene su número medido en el comentario.
