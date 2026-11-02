---
name: code-style
description: >
  Estilo, orden y convenciones de código R de este proyecto. Úsalo SIEMPRE que
  escribas, edites o revises código R: scripts de ingesta, limpieza,
  integración o productos.
  Actívalo también cuando el pedido sea escribir un script nuevo, refactorizar
  uno existente, agregar un bloque a uno que ya está, revisar código, o cuando
  el usuario diga que algo "no está en su estilo", pida "ordenar" un script o
  mencione sus convenciones. Cubre estructura del archivo, encabezados de
  sección, el patrón de un mutate por paso, la densidad y la forma de los
  comentarios, el vocabulario de sufijos, los nombres de objetos, qué
  construcciones están prohibidas y dónde vive cada columna derivada. No cubre
  las reglas de limpieza de datos: para eso está la skill limpieza-de-datos.
---

# Estilo de programación en R

Estas convenciones están extraídas de los scripts `02_clean_*`,
`03_base_maestra.R` y `01_import_*` del proyecto Tigo-Dataflow. El objetivo
declarado del estilo es que **cualquiera pueda leer el script de arriba abajo y
entender no solo qué hace sino por qué**, y que un cambio de seis meses después
no rompa nada silenciosamente.

Idioma: **nombres de archivo en inglés, todo el contenido en español.**
Variables, objetos, comentarios y mensajes van en español.

Al citar una parte de `CLAUDE.md` o de una skill, se escribe **"sección 7.2"**, no
`§7.2`. El signo `§` se usa en textos legales y acá no lo entiende nadie: si hay
que explicar el símbolo, el atajo no sirvió. Y cuando el comentario apunta a otro
documento, decir **qué** se va a encontrar ahí y no solo el número.

---

## 1. Estructura del archivo

### 1.1 Encabezado

Los scripts nuevos o importantes abren con un bloque de cabecera enmarcado. La
línea de cierre lleva `.#` al final:

```r
#-----------------------------------------------------------------------------.#
# PROYECTO: TIGO - JÓVENES CONECTADOS                                          #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   PIERO VALLES-MARAVI (ESPECIALISTA) - pvalles@equilibriumbdc.com            #
#   MARIA JOSE MESIAS SEVILLA (ASISTENTE)                                      #
#   DIEGO OLIVARES (ASISTENTE) - dolivares@equilibriumbdc.com                  #
#                                                                              #
# FECHA DE CREACION: 02/09/2026                                                #
# NOMBRE: 03_base_maestra                                                      #
# DETALLE: <qué hace, y sobre todo qué NO hace acá>                            #
#                                                                              #
# CORRE DESPUES DE: <los scripts de los que depende>                           #
# SALIDA: <cada objeto, con una línea de qué es>                               #
#-----------------------------------------------------------------------------.#
```

El campo `DETALLE` dice también **lo que el script no hace**: *"Acá NO se limpia
nada: las seis llegan con el mismo vocabulario y las llaves ya normalizadas."*
Esa frase evita que alguien agregue limpieza donde no va.

**El bloque se queda en 11-18 líneas y ahí termina.** Es una tarjeta de
identificación, no la documentación del script. El 2026-09-08 hubo que recortar
cinco encabezados que habían crecido a 45 y 80 líneas con secciones de INPUT,
OUTPUT, SETUP y USO: eso no se lee, se desactualiza, y lo que explica el diseño
va en `CLAUDE.md`. Si una instrucción operativa hace falta —cómo correr el
login, por ejemplo— va como comentario **arriba del código que la necesita**, que
es donde alguien la va a buscar.

### 1.2 Encabezados de sección

Comentario con el título y **guiones hasta el margen**:

```r
# Normalizar correo ----------------------------------------------------------
```

Los guiones al final son lo que hace que RStudio y Positron los muestren en el
índice del documento. **Siempre van.**

Subsecciones con `##` y el mismo formato:

```r
## Program Activity -------------------------------------------------------
```

Las secciones canónicas de un script, en orden:

```
Setup
Rutas y carpetas
Cargar datos
<las secciones propias del script>
Validación
Selección de variables
Guardar
```

Para las secciones mayores de un script largo, el marco de iguales:

```r
#=============================================================================.#
# 1. DESCARGA API -----
#=============================================================================.#
```

Y para separar dos poblaciones dentro del mismo archivo, el título en mayúsculas
con iguales hasta el margen:

```r
# ALUMNOS ======================================================================
```

### 1.3 Separación vertical

- **Dos líneas en blanco** entre pasos numerados.
- **Tres o cuatro** antes de un encabezado de sección.
- Una línea en blanco después de la apertura de un `mutate(` largo, y entre cada
  asignación comentada dentro de él.

El aire es parte del estilo: los bloques densos no se leen.

---

## 2. La regla central: un `mutate()` numerado por paso

**Nunca un pipe largo encadenado.** Cada paso es un `mutate()` que **reescribe el
objeto** y lleva su número:

```r
# 3. Extrae los números escritos en el campo de nombre

# reescribe el objeto de trabajo con las dos columnas nuevas
rce_limpiando <- rce_limpiando %>%
  mutate(                                          # agrega columnas

    # todos los dígitos del campo, como respaldo
    nombre_numero = map_chr(
      str_extract_all(nombre_limpio, "[0-9]+"),    # los grupos de dígitos
      ~ paste(.x, collapse = " ")                  # unidos con un espacio
    ),                                             # fin de nombre_numero

    # si no había ningún dígito, NA en vez de ""
    nombre_numero = na_if(nombre_numero, ""),

    # separa el campo en grupos de dígitos, por si hay más de un número
    nombre_grupos = str_extract_all(nombre_limpio, "[0-9]+")
  )                                                # fin del mutate
```

Por qué reescribir el objeto en vez de encadenar:

- **Se puede parar en cualquier paso** y mirar el estado en la consola.
- El diff de git muestra **qué paso cambió**, no un pipe de 200 líneas movido.
- Un error apunta al paso, no al final de la cadena.

La numeración es **por sección, empezando en 1**. Si se inserta un paso entre el
4 y el 5, se llama `4b`, no se renumera todo:

```r
# 4b. Correcciones revisadas una a una
# 5b. Rescata el nombre escondido en el correo que traía el campo
```

Cuando se insertan pasos al principio de una sección y hay que renumerar, se
renumera **toda la sección** para que quede consecutiva.

---

## 3. Comentarios

Es la parte más distintiva del estilo. La densidad es alta a propósito.

### 3.1 **Toda línea física** de código lleva comentario

Sin excepción: no solo las asignaciones, también `library()`, `source()`,
`dir.create()`, `save()`, `rm()` y cada línea de una llamada partida en varias.
En minúscula, sin punto final, describiendo **qué hace esa línea**.

- La instrucción lleva su comentario **arriba**.
- Cada línea de continuación (un argumento, el paréntesis que cierra) lleva el
  suyo **al margen**, alineado en columna (sección 3.6).

```r
    # colapsa espacios múltiples y recorta los extremos
    nombre_limpio = str_squish(nombre_limpio),

    # si no quedó nada después de quitar el correo, NA
    nombre_limpio = na_if(nombre_limpio, "")
```

```r
# los archivos .RData de la carpeta del corte
archivos_corte <- list.files(
  carpeta_corte,                       # dónde buscar
  pattern    = "^corte_1_.*\\.RData$", # solo los cortes
  full.names = TRUE                    # con la ruta, para el load()
)                                      # fin de list.files()
```

### 3.2 Con ejemplo concreto cuando aclara

El ejemplo va con la flecha `->`:

```r
    # @@GMAIL.COM -> @GMAIL.COM
    # 15/03/2009 00:00:00 -> 2009-03-15
    # ANGEL DAVID + ACOSTA PEREIRA -> ANGEL DAVID ACOSTA PEREIRA
    # 2026-08-24T09:27:02.620Z -> 2026-08-24
```

Un ejemplo real de los datos vale más que una descripción abstracta.

### 3.3 Los comentarios de bloque explican el **por qué**, con números

Arriba de un paso o de una sección, en prosa, con las mediciones que sostienen
la decisión. Este es el rasgo que más define el estilo:

```r
# El selector de fechas es react-dates. Tipear en el campo NO registra la fecha
# en el estado del formulario (Coursera la toma como vacía y "Generar" no hace
# nada); hay que ELEGIR EL DÍA en el calendario.
```

```r
# correo_nombre NO entra acá. Se midió sobre el ROF, que tiene 23.419 registros
# con nombre propio y además un nombre sacado del local del correo: el 93% es
# ruido o redundancia y solo el 7% son variantes reales.
#
# Una llave de nombre que en realidad es de otra persona fusiona a dos personas
# al deduplicar, y esa fusión no se puede deshacer.
```

Reglas de estos comentarios:

- **Llevan el número medido.** `son 31 filas`, `13 valores únicos`, `1.809 de los
  1.819`. Nunca "algunos casos" ni "varios registros".
- **Explican la alternativa descartada y por qué.** No solo qué se hizo.
- **Nombran el caso testigo** con datos reales: `ISAACLOPEZ`, `Miguel Troche,
  cédula 6883026`, `LIZ MARIEL ZARZA CASTILLO`.
- **Usan MAYÚSCULAS para el énfasis** de lo que no se puede olvidar: `NO`,
  `SIEMPRE`, `imprescindible`.
- Van separados por `#` sola cuando tienen más de un párrafo.

### 3.4 Comentarios dentro de `case_when`

Comentario, condición en su línea, y `~ "valor"` en la línea siguiente. Como
toda línea física lleva comentario (sección 3.1), el comentario de arriba agrupa
las ramas relacionadas y cada condición y cada valor llevan el suyo al margen:

```r
    # el rango de la cuota, con cortes distintos por rol
    rango_edad = case_when(

      # estudiantes
      rol == "ESTUDIANTE" & edad < 14                  # menor de 14
      ~ "1. Menores de 14 anios",                      # primer rango

      rol == "ESTUDIANTE" & edad >= 14 & edad <= 16    # de 14 a 16
      ~ "2. 14 a 16 anios",                            # segundo rango

      # docentes
      rol == "DOCENTE" & edad < 25                     # menor de 25
      ~ "1. Menores de 25 anios",                      # primer rango

      .default = "5. Sin dato"                         # sin edad o sin rol
    )                                                  # fin de rango_edad
```

### 3.5 Comentarios dentro de `select`

En un `select` largo, cada bloque de columnas lleva su comentario arriba, y cada
columna el suyo al margen:

```r
  select(                       # las columnas del contrato, en orden

    # identificación de la fila
    fuente,                     # de qué base salió
    fila_origen,                # su número de fila en esa base

    # el formulario del que salió esta fila; se repite entre las expandidas
    id_origen,

    # las cuatro llaves, ya normalizadas y expandidas
    cedula,                     # documento
    nombre,                     # nombre y apellido
    correo,                     # correo completo
    celular,                    # celular con código de país

    # atributos de la persona
    sexo,                       # como lo declaró
    fecha_nacimiento,           # en formato fecha
    ...
  )                             # fin del select
```

Y una columna con una particularidad lleva su explicación propia, aunque sean
tres líneas:

```r
    # el id que devuelve la API, para volver al registro en el sistema. Está
    # repetido en 91 filas de docentes, así que no identifica la fila
    id_api,
```

### 3.6 Comentarios al margen, alineados

En bloques de asignaciones cortas y paralelas, el comentario va al margen
derecho y **alineado en columna**:

```r
load(file.path(carpeta_clean, "mec2026_clean.RData"))  # 43.613 filas / 43.602 registros
load(file.path(carpeta_clean, "mec2025_clean.RData"))  # 50.254 filas / 50.253 registros
load(file.path(carpeta_clean, "rof_clean.RData"))      # 30.263 filas / 28.819 registros
```

```r
carpeta_clean <- "data/02_clean/" # Input
carpeta_final <- "data/03_final/" # Output
```

### 3.7 Notas de trabajo en mayúsculas

Los pendientes y las advertencias van en mayúsculas, en su propia línea:

```r
#NOTA: PENDIENTE MODIFICAR LOGICA DE DEDUPLICACION CON EL NUEVO CRITERIO!
# SOLO PARA MANTENER FLUJO ANTIGUO:
load(...)  # la base vieja; borrar luego
```

---

## 4. Formato de las llamadas

### 4.1 Un argumento por línea, sin scroll horizontal

```r
    # la coma antes del dominio pasa a punto: GMAIL,COM -> GMAIL.COM
    correo_limpio = str_replace(
      correo_limpio,                     # el correo de trabajo
      "(?i),(COM|NET|ORG|EDU|PY)$",      # una coma antes del final
      ".\\1"                             # se cambia por un punto
    ),                                   # fin de str_replace()
```

Nunca hay que desplazarse a la derecha para leer una línea. **Las regex largas sí
van en una sola línea**, porque partirlas las vuelve ilegibles y frágiles. Es la
única excepción al ancho y al comentario al margen: el comentario va arriba.

```r
      # los restos de dominio que no son parte de un nombre
      "\\b(G?MAIL|GMAI|GMIAL|HOTMAIL|YAHOO|OUTLOOK|ICLOUD|LIVE|COM|NET|ORG|EDU|PY|CORREO)\\b"
```

### 4.2 Alineación de `=` en bloques paralelos

Cuando varias asignaciones son de la misma naturaleza, los `=` se alinean:

```r
  rename(                                                # al vocabulario común
    fecha            = created_at,                       # fecha del registro
    nombre           = datos_personales_nombres_apellidos, # nombre completo
    cedula           = datos_personales_documento_identidad, # documento
    correo           = datos_contacto_correo_electronico, # correo
    celular          = datos_contacto_numero_telefono,   # celular
    fecha_nacimiento = datos_personales_fecha_nacimiento, # nacimiento
    sexo             = datos_personales_sexo             # sexo declarado
  )                                                      # fin del rename
```

```r
  summarise(                              # una fila con los conteos
    filas       = n(),                    # registros
    con_nombre  = sum(!is.na(nombre)),    # con nombre
    con_cedula  = sum(!is.na(cedula)),    # con documento
    con_correo  = sum(!is.na(correo)),    # con correo
    con_celular = sum(!is.na(celular)),   # con celular
    .groups     = "drop"                  # sin agrupamiento al salir
  )                                       # fin del summarise
```

### 4.3 `group_by` y `summarise`

`group_by` con una columna por línea. `summarise` **siempre** con
`.groups = "drop"` explícito, al final:

```r
  group_by(                       # un grupo por llave
    tipo_llave,                   # documento, celular, correo o nombre
    valor                         # el valor de la llave
  ) %>%                           # fin del group_by
  summarise(                      # una fila por grupo

    # cuántos nombres distintos comparten la llave
    nombres_distintos = n_distinct(nombre[!is.na(nombre)]),

    .groups = "drop"              # sin agrupamiento al salir
  )                               # fin del summarise
```

### 4.4 Joins

Con `by` explícito y, cuando el join tiene un cardinal esperado,
`relationship` declarado. Es una validación gratis: si el join no cumple, aborta.

```r
  left_join(                      # trae el nombre de la base maestra
    base_maestra %>%              # la tabla de la derecha
      select(                     # solo las columnas que hacen falta
        registro_id,              # la llave del cruce
        nombre                    # lo que se trae
      ),                          # fin del select
    by           = "registro_id", # cruza por el id del registro
    relationship = "many-to-one"  # aborta si la derecha repite el id
  )                               # fin del left_join
```

### 4.5 El pipe

**`%>%` es el pipe de la casa** (7 de los 8 scripts de limpieza lo usan). Un
script usa `|>` de punta a punta; los nuevos van con `%>%`.

**Nunca mezclar los dos en el mismo script.**

---

## 5. Vocabulario de sufijos

Los sufijos son un lenguaje: el nombre de la columna dice en qué etapa está.

| Sufijo | Qué es |
|---|---|
| `_orig` | la columna original, renombrada al final para liberar el nombre limpio |
| `_limpio` | intermedio, después de la limpieza base |
| `_norm` | **final, la llave**. Es la que se usa para cruzar |
| `_tipo` | la clasificación de qué contenía realmente el campo |
| `_digitos` | todos los dígitos del campo, juntos |
| `_grupos` | los dígitos separados en grupos (list-column) |
| `_candidato` | el grupo elegido, antes de reconstruir |
| `_cuerpo` | el número sin el prefijo, listo para reconstruir |
| `_partes` | el resultado de un split (list-column) |
| `_fila` | el valor de trabajo de esta fila después del desdoble |
| `_separado` | lógica: si la fila nació de un desdoble |
| `_multiple` | lógica: si la celda traía más de un valor |
| `_manual` | el valor que vino de la tabla de correcciones |
| `_regla` | `"Cumple reglas"` / `"No cumple reglas"` |
| `_modificado` | `"Modificado"` / `"No modificado"` |
| `_validez` | `"Numero falso"` / `"Numero verdadero"` |
| `_llave2` | llave secundaria |
| `_norm_9` | llave secundaria por longitud |
| `_local`, `_dominio` | las dos partes de un correo |

**Prefijo completo del campo, sin abreviar**: `rce_celular_norm`, nunca
`rce_cel_norm`. Y las columnas cruzadas se nombran `<campo>_<entidad>`:
`celular_cedula` es *la cédula que estaba escrita en el campo de celular*.

**Regla absoluta: nunca modificar la columna original.** Se trabaja siempre sobre
una columna nueva, y al final la original se renombra a `_orig`.

---

## 6. Nombres de objetos

La progresión de un script de limpieza:

```
<fuente>_raw              el crudo tal como llegó
<fuente>_limpiando        el objeto de trabajo, que se reescribe paso a paso
<fuente>_limpiando_final  después de expandir las llaves
<fuente>_clean            la salida que cumple el contrato
```

Cuando hay que mantener un flujo viejo, el objeto con el vocabulario antiguo se
llama `<fuente>_limpio`.

Otras convenciones:

- **Carpetas**: `carpeta_<fuente>_raw` y `carpeta_<fuente>_clean`, con el
  comentario `# Input` / `# Output` al margen.
- **Tablas de llaves**: `<fuente>_llaves_<entidad>`, `<fuente>_llaves`,
  `<fuente>_llaves_lista`.
- **Correcciones manuales**: `correcciones_<campo>`.
- **Objetos de validación**: `validacion_<qué_valida>`.
- Todo en `snake_case`, minúsculas, en español.

---

## 7. Construcciones prohibidas y permitidas

### Prohibido

- **`for`** — se usa `map`, `map_chr`, `map2`.
- **`sapply`** en código nuevo — se usa `map_chr` o `map_lgl`, que son de tipo
  seguro. (`sapply(df, function(x) class(x)[1])` en la validación es la única
  excepción tolerada.)
- **`transmute`** — se usa `mutate` + `select`.
- **Definir funciones en cualquier script del pipeline** (`nombre <-
  function(...)`). Las funciones compartidas viven en el archivo de funciones
  del setup. Un script no define funciones: define pasos.
- **`if` / `else` como control de flujo**, ni sueltos ni dentro de una función
  anónima. Una decisión por fila va con `ifelse()`, `if_else()` o `case_when()`.
- **`stop()` y `stopifnot()`**: el script no corta a mano. Los contratos se
  calculan en un objeto de validación (sección 8.5).
- **`cat()` y `message()`**: el script no imprime texto armado a mano. Lo que hay
  que mirar al correr queda como consulta activa (sección 8.1).
- **Pipes largos encadenados** (sección 2).
- **Modificar la columna original** (sección 5).
- **`attach`**, `<<-`, `setwd()`.

### Permitido

- **Funciones anónimas dentro de `map_chr`**, con la forma `function(g)` cuando
  el cuerpo tiene varias líneas, y sin `if`:
  ```r
  # el grupo de dígitos con forma de celular
  map_chr(celular_grupos, function(g) {
    todo <- paste(g, collapse = "")          # todos los dígitos juntos
    g    <- g[grepl("^0\\d{7,10}$", g)]      # los grupos sueltos que calzan
    case_when(                               # el primero que calce
      grepl("^0\\d{7,10}$", todo) ~ todo,    # primero, todo junto
      length(g) > 0               ~ g[1],    # después, el primer grupo
      .default                    = NA_character_ # ninguno calza
    )                                        # fin de case_when()
  })                                         # fin de la función
  ```
- **La forma `~ .x`** para cuerpos de una sola expresión:
  ```r
  # saca de cada fila los grupos de un solo dígito repetido: 0000000 -> fuera
  map(celular_grupos, ~ .x[!str_detect(.x, "^(\\d)\\1*$")])
  ```
- **`tribble`** para las tablas de correcciones y los casos de prueba.
- **`tibble`** para el objeto `validacion_<qué_valida>` de cada contrato.

---

## 8. Validaciones

**Todo bloque termina con su bloque de validación.** No es opcional.

### 8.1 Las consultas activas no se comentan con `#`

Las que devuelven una tabla chica y se leen de un vistazo quedan **activas** (no
desactivadas con `#`), sin asignar a nada, para que impriman al correr. Como
cualquier línea, llevan su comentario:

```r
# 3. Cuántos quedaron en cada tipo

# los registros por tipo de nombre, de más a menos
rce_limpiando %>%
  count(nombre_tipo, sort = TRUE)   # uno por tipo
```

### 8.2 Las exploratorias van comentadas, **con la conclusión escrita abajo**

Las que abren un `View()` o devuelven cientos de filas quedan comentadas, y
**debajo va la conclusión en prosa**. Esto es esencial del estilo: el script
guarda el hallazgo, no solo el código que lo produjo.

```r
# 2. Cuánta información perdimos o no capturamos en las cuatro variables

# rce_limpiando %>%
#   filter(
#     is.na(celular_norm) & is.na(celular_correo) &
#       is.na(celular_nombre) & is.na(celular_cedula)
#   ) %>%
#   select(celular) %>%
#   filter(celular != 'NULL') %>%
#   View()

# Solo 6 registros poco relevantes.
```

```r
# Estos 20 casos realmente no hay forma de saber si son números de celular o no
# Los dejaremos y se descartarán luego de detectar duplicados.
```

```r
# Nada preocupante. Todo es plausible
```

**Un `View()` comentado sin conclusión abajo está incompleto.**

### 8.3 La vista de inspección lleva `select` documentado columna por columna

La consulta 1 de cada bloque es siempre la misma forma: el original, el
`_limpio`, el `_norm`, el `_tipo` y **todas** las extracciones, cada una con su
comentario, ordenada por tipo:

```r
# rce_limpiando %>%
#   filter(!is.na(celular)) %>%
#   select(
#     celular,                 # original, sin tocar
#     celular_norm,            # llave final
#     celular_correo,          # correo escondido en el campo
#     celular_nombre,          # nombre escondido en el campo
#     celular_cedula,          # cédula escondida en el campo
#     celular_limpio,          # texto limpio
#     celular_tipo,            # qué contenía el campo
#     celular_digitos,         # dígitos antes de reconstruir
#     celular_con_cero,        # si venía con la convención del 0
#     celular_regla,           # si cumple el patrón
#     celular_validez          # si es número falso
#   ) %>%
#   arrange(celular_tipo, celular_norm) %>%
#   View()
```

### 8.4 `names()` después de cada limpieza de columnas

Al terminar de quitar las columnas de trabajo de un bloque:

```r
# las columnas que quedaron
names(rce_limpiando)
```

### 8.5 Cuando la validación es un contrato, queda en un objeto

El script **no corta a mano**: sin `if`, `stop()` ni `stopifnot()`. Cada
contrato se calcula como una columna de un `tibble` llamado
`validacion_<qué_valida>`, con el valor que **tiene que dar** escrito en el
comentario, y el objeto queda como consulta activa (sección 8.1):

```r
# los contratos de la base: todos tienen que dar 0
validacion_join <- tibble(
  filas_de_mas = nrow(x) - nrow(y)     # 0 = el join no duplicó filas
)                                      # fin de los contratos

# imprime los contratos al correr en la consola
validacion_join
```

El comentario de cada columna dice **qué revisar** si no da lo esperado. Ojo:
con `source()` o `Rscript` las consultas activas **no imprimen**. El objeto se
mira en el entorno de RStudio al correr el script a mano; en la corrida
programada la validación no corta nada. Lo único que corta es el error propio
de una función (un `load()` sin archivo, un `drive_auth()` sin credencial).

---

## 9. Setup y entorno

### 9.1 Apertura de un script

```r
# borra lo que haya en memoria: el script no depende de otro
rm(list = ls())

# los paquetes del proyecto
source('src/00_setup/00_packages.R')

# las funciones compartidas
source('src/00_setup/00_functions.R')
```

Los paquetes y las funciones van **en dos archivos separados**, y la
autenticación de servicios de red en un tercero. Un `source()` no debe golpear la
red.

Para limpiar datos **conservando las funciones**:

```r
# borra todo menos las funciones cargadas
rm(list = setdiff(ls(), as.character(lsf.str())))
```

### 9.2 Rutas

Relativas a la raíz del proyecto, siempre. Nunca `setwd()`. Nunca una ruta
absoluta con el nombre de un usuario dentro del script.

Asimetría deliberada: **la carpeta de entrada no se crea** (si no existe queremos
que falle) y **la de salida sí**.

### 9.3 Credenciales

**Nunca en el script.** Salen de `Sys.getenv()`, que lee del `.Renviron` en local
y de los secrets en CI, con el mismo código. Lo que no es secreto (un subdominio,
un endpoint público, el id de una hoja) sí puede quedar en el script, con un
default.

Si falta una credencial, el script falla en la función que la usa (por ejemplo
`drive_auth()`), sin imprimir nunca un valor.

### 9.4 Parámetros configurables

Arriba, juntos, cada uno con su comentario de qué pasa si se cambia. Los que
pueden venir del entorno, con `Sys.getenv(..., unset = <default>)`.

---

## 10. Dónde vive cada columna derivada

Es una regla de arquitectura, no de formato, y decide en qué script va un
cálculo nuevo:

| La columna es… | Va en |
|---|---|
| una llave, necesaria para poder cruzar | `02_cleaning` |
| un indicador que **todos** los productos usan | `03_integration`, después de integrar |
| un indicador de **un solo** entregable | `04_products`, junto al script que lo usa |

Corolarios:

- **En `02_cleaning` se limpia una sola fuente y no se carga ninguna otra.** Si un
  cálculo necesita dos fuentes, no va acá. El comentario lo dice explícitamente:
  *"La comparación en sí no se hace acá: este script limpia un solo archivo y no
  carga ninguno de los otros dos."*
- **En `03_integration` no se limpia.** Las fuentes llegan con el mismo
  vocabulario y las llaves normalizadas; ahí se apila, se enlaza y se marca.
- **Las funciones de llave de la integración validan, no limpian.** Son
  idempotentes y nunca reconstruyen un valor. Si un campo trae algo irrecuperable,
  la columna lo conserva y la llave queda en `NA`. Reconstruir es trabajo de
  `02_cleaning`.

---

## 11. Guardado

Al final, en su propia sección, y con el nombre del objeto igual al del archivo:

```r
# Guardar rce_clean ------------------------------------------------

# la salida del script, con el objeto del mismo nombre que el archivo
save(rce_clean, file = file.path(carpeta_rce_clean, "rce_clean.RData"))
```

Cuando se guardan varios objetos, van en un `save()` con uno por línea y cada
uno con su comentario al margen:

```r
# los tres objetos de la integración, en un solo archivo
save(
  base_maestra_desagregado,     # una fila por registro de origen
  base_maestra_final,           # una fila por persona, la que se usa para contar
  llaves,                       # la tabla de enlaces, para auditar un cruce
  file = file.path(carpeta_final, "base_maestra.RData") # el archivo
)                               # fin de save()
```

Si el archivo lleva fecha en el nombre, **el objeto adentro no**: siempre se
llama igual, para que el script que lo carga no tenga que adivinar.

---

## 12. Checklist de revisión

- [ ] Encabezado de sección con guiones hasta el margen.
- [ ] Un `mutate()` numerado por paso, reescribiendo el objeto.
- [ ] Ningún pipe largo encadenado.
- [ ] Comentario en minúscula en **toda línea física**: arriba de cada
      instrucción y al margen en cada línea de continuación.
- [ ] Ejemplo concreto con `->` donde aclara.
- [ ] Los comentarios de bloque explican el por qué **con el número medido**.
- [ ] `case_when` con la condición y el `~ valor` en líneas separadas.
- [ ] `select` largo con comentario por bloque y al margen de cada columna.
- [ ] Un argumento por línea; sin scroll horizontal; regex en una sola línea.
- [ ] `=` alineados en bloques paralelos.
- [ ] `.groups = "drop"` explícito en cada `summarise`.
- [ ] `by` explícito en cada join, y `relationship` cuando corresponde.
- [ ] Un solo estilo de pipe en todo el script (`%>%` en los nuevos).
- [ ] Sufijos del vocabulario de la sección 5, con el prefijo completo del campo.
- [ ] La columna original intacta, renombrada a `_orig` al final.
- [ ] Sin `for`, sin `sapply`, sin `transmute`, sin definir funciones.
- [ ] Sin `if` / `else`, sin `stop()` ni `stopifnot()`, sin `cat()` ni
      `message()`.
- [ ] Cada bloque termina con su validación numerada.
- [ ] Las consultas exploratorias comentadas **tienen la conclusión escrita
      abajo**.
- [ ] `names()` después de quitar las columnas de trabajo.
- [ ] Los contratos van en un `validacion_<qué_valida>`, con el valor esperado
      y qué revisar en el comentario de cada columna.
- [ ] Sin credenciales en el script; sin `setwd()`; sin rutas absolutas.
- [ ] La columna derivada está en la capa que le corresponde (sección 10).
