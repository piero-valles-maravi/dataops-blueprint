---
name: auditoria-de-datos
description: >
  Procedimiento para escribir el script 02_audit de cualquier proyecto: revisar
  lo que llegó de la fuente y marcar cada registro con alertas 0/1 agrupadas en
  dimensiones de calidad, sin corregir ni borrar nada. Úsala SIEMPRE que haya
  que crear, extender o revisar una auditoría: alertas de completitud,
  validez, consistencia, duración, duplicados, elegibilidad, protocolo,
  calidad por encuestador, valores atípicos, NS/NR o gestión de casos; cuando
  pida "auditar la base", "marcar alertas", "revisar la calidad del campo",
  "qué encuestas hay que revisar" o "agregar una alerta"; o cuando haya que
  conectar la auditoría con la validación de supervisoras. Sirve para
  encuestas (SurveyCTO, Kobo, ODK) y, adaptando las dimensiones, para
  registros administrativos o datos de scraping. No cubre la corrección de
  datos: eso es 03_clean y la skill data-cleaning.
---

# Auditoría de datos (02_audit)

La auditoría responde **una sola pregunta: ¿está bien lo que llegó?** No
corrige, no borra, no imputa: **marca**. Cada problema queda como una columna
0/1, y al final cada registro recibe una clase que dice si se puede usar, si hay
que revisarlo o si no aplica.

Lo que sale de esta etapa lo leen tres consumidores distintos:

| Consumidor | Qué lee |
|---|---|
| `03_clean` | las alertas, para decidir qué corregir y qué registros entran a la base final |
| `monitoring` | a través de `03_clean`: los agregados por dimensión, por encuestador y por día, para el dashboard de campo (flujo de monitoreo) |
| las supervisoras | los registros con `alerta_final = 2`, para validarlos a mano |

---

## 0. Las reglas que no se negocian

1. **Se marca, no se corrige.** La corrección va en `03_clean`. La única
   excepción son las correcciones humanas ya decididas (sección 3.3), que se
   aplican antes de auditar para que la alerta desaparezca sola.
2. **Filas que entran = filas que salen.** Lo único que se separa son los
   envíos de prueba, y se guardan aparte para poder revisarlos.
3. **Toda alerta es 0 o 1, nunca NA.** Un NA hace que los totales cuenten mal
   sin avisar. Por eso las condiciones se escriben con `%in%`, que no da NA
   cuando el campo está vacío: `c2_resultado %in% 1`, nunca `c2_resultado == 1`.
4. **Cada problema vive en una sola dimensión.** Un valor imposible es validez
   (D2); el mismo valor posible pero raro es atípico (D8); dos valores posibles
   que juntos no pueden ser ciertos es consistencia (D3). Cada dimensión dice
   al inicio qué **no** marca y a qué dimensión le toca.
5. **Ningún número suelto.** Todo umbral va en la sección 1.2, con el porqué y,
   si se calibró con datos, la fecha y lo que se midió.
6. **La auditoría es reproducible.** Correrla dos veces da lo mismo: los
   agregados se excluyen a sí mismos y las columnas auxiliares se borran.
7. **La decisión humana no pisa la automática.** `alerta_final` es siempre el
   resultado de las reglas; la validación de la supervisora va en otra columna
   (`resultado_final`).

---

## 1. Vocabulario de columnas

| Prefijo | Qué es | Suma en las alertas | Ejemplo |
|---|---|---|---|
| `ale_d<N>_<variable>` | una alerta de la dimensión N sobre esa variable | sí | `ale_d1_r8_anio_nac` |
| `ale_d<N>_n_<medida>` | cuántas alertas de la dimensión tiene el registro | — | `ale_d1_n_missing` |
| `ale_d<N>_<medida>` | 1 si tiene al menos una alerta de la dimensión | — | `ale_d1_missing` |
| `aud_` | alertas que ya calcula el formulario; se conservan tal cual | no | `aud_dur_corta` |
| `es_` | clasificación 0/1 del registro (no es una alerta) | no | `es_completa`, `es_encuesta_definitiva` |
| `historial_` | lugar del registro en la historia de su caso | no | `historial_n_intento` |
| `orig_<variable>` | valor antes de una corrección humana | no | `orig_e33_ingreso` |
| `<variable>_<fuente>` | valor original antes de completarlo con otra fuente | no | `rds3_grado_encuesta` |
| `val_` | decisión de la supervisora | no | `val_decision` |
| `aux_d<N>_` | columna de trabajo; se borra al terminar la dimensión | no | `aux_d7_duracion` |
| `d<N>_<medida>` | dato informativo para el dashboard, sin prefijo `ale_` a propósito | no | `d7_otro_encuestador` |

La `<variable>` del nombre de la alerta es **la pregunta que hay que mirar
cuando la alerta se enciende**, no necesariamente la única que usa la regla.

---

## 2. Las etapas del script

```
1.  Setup                        rutas · umbrales · cargar datos
2.  Preparación de la base       instrumento · columnas · correcciones · tipos ·
                                 pruebas · clasificación
3.  D1  Completitud              ┐
4.  D2  Validez                  │
5.  D3  Consistencia             │  cada una con dos partes:
6.  D4  Autenticidad             │    N.1 alertas por regla
7.  D5  Elegibilidad             │    N.2 medidas agregadas
8.  D6  Protocolo                │
9.  D7  Calidad por encuestador  │
10. D8  Valores atípicos         │
11. D9  Respuestas no sustantivas│
12. D10 Gestión de casos         ┘
13. Consolidar                   ale_n_total · ale_n_dimensiones · alerta_final
14. Veredicto humano             val_ · resultado_final
15. Guardar
```

Si el script pasa de ~1.500 líneas, se divide por etapas con subíndice y cada
parte guarda su salida para la siguiente:
`02_audit_1_preparacion.R`, `02_audit_2_dimensiones.R`,
`02_audit_3_consolidar.R`.

---

## 3. Preparación de la base

Antes de la primera alerta, la base tiene que estar completa, con los tipos
correctos y sin pruebas. Una alerta calculada sobre una columna mal tipada da
falsos positivos en masa.

### 3.1 Leer el instrumento

Del XLSForm se leen las hojas `survey` y `choices` **como texto**
(`col_types = 'text'`: `'01'` no pasa a `1`) y se arman dos tablas:

- `instrumento_variables`: nombre, tipo (`word(type, 1)`), lista
  (`word(type, 2)`), obligatoriedad y relevancia de cada campo. Sin grupos ni
  notas.
- `instrumento_opciones`: lista, código, etiqueta y filtro de cada opción.

La ruta del instrumento sale de `leer_instrumento(ronda)`, nunca escrita en el
script: si cambia la versión, cambia en un solo lugar.

### 3.2 Completar columnas

La fuente no exporta un campo que nadie respondió todavía, y una
`select_multiple` llega como una columna por opción, solo de las opciones que
alguien marcó. Se crean vacías todas las columnas que el instrumento puede
generar y no llegaron. Sin esto, la primera regla sobre una columna que no
existe rompe el script.

Ojo con los códigos negativos: `e9_fam_aqui` + `'-777'` se exporta como
`e9_fam_aqui__777` (el guion pasa a guion bajo).

### 3.3 Aplicar correcciones humanas

Si las supervisoras o el equipo corrigen datos desde un Sheet (importado en
`01_import`), se aplican **acá, con la base todavía en texto y antes de las
alertas**: así la auditoría vuelve a correr con el dato corregido y la alerta
desaparece sola.

1. Solo se corrigen preguntas de una columna con un tipo controlable
   (`select_one`, `integer`, `decimal`, `text`, `date`). Las `select_multiple`
   van por coordinación.
2. Cada corrección pasa por controles y recibe un estado:

   | Estado | Cuándo |
   |---|---|
   | `Pendiente: falta la variable o el valor nuevo` | fila incompleta |
   | `Rechazada: el registro no está en la base` | id inexistente |
   | `Rechazada: la variable no existe o no se puede corregir` | fuera del instrumento |
   | `Rechazada: el valor nuevo no es una opción de la pregunta` | código fuera de la lista |
   | `Rechazada: el valor nuevo no es un dato de tipo <tipo>` | `'abc'` en un integer |
   | `Rechazada: hay otra corrección para el mismo dato` | duplicada |
   | `Rechazada: falta el motivo` | sin justificación |
   | `Aplicada` | pasó todos los controles |

3. Las aplicadas guardan el valor anterior en `orig_<variable>` y marcan
   `es_corregida = 1`.
4. El registro de correcciones con su estado se guarda aparte
   (`<proyecto>_correcciones.RData`) para devolverlo al Sheet: la supervisora
   ve por qué se rechazó la suya.

### 3.4 Validar tipos

En este orden:

1. **Blancos a NA**: `''` y `' '` pasan a NA; `' Lima'` se queda igual.
2. **Copia en texto** de la base (`data_texto`), para comparar al final.
3. **Números**: `integer`, `decimal` y los `calculate` cuyos valores son
   **todos** número. Patrón: signo opcional, sin cero a la izquierda, hasta 15
   dígitos. `'01'` y un identificador de 36 dígitos **no** se convierten.
4. **Fechas y horas**: a la zona horaria del proyecto, una sola vez. La API
   suele entregar UTC.
5. **Opciones**:
   - `select_one` de listas cuyos códigos son todos enteros sin cero a la
     izquierda → número. Las de texto (`'CO'`) o con ceros (`'01'`) quedan
     texto.
   - `select_multiple` → 0/1 con esta regla: si marcó al menos una opción, las
     no marcadas son 0; si no marcó ninguna, la pregunta no se hizo y **todas
     quedan NA**. Se hace con una función que recorre las listas del
     instrumento, no un bloque escrito a mano por pregunta.
6. **Validar la conversión** (contrato):

   ```r
   # datos que tenía cada columna antes y después de convertir
   perdidas <- colSums(!is.na(data_texto[convertidas])) -
     colSums(!is.na(data_audit[convertidas]))

   stopifnot(
     'La conversión perdió datos. Revisá perdidas_conversion.' =
       all(perdidas == 0)
   )
   ```

   Seguir con datos perdidos daría alertas falsas de respuesta faltante.

### 3.5 Quitar los envíos de prueba

Son pruebas: los que empezaron antes del inicio del campo, los del usuario de
prueba y los marcados a mano. **Se guardan aparte** (`envios_prueba`) y se
listan por usuario y versión. La lista de usuarios e identificadores de prueba
va en `sources/02_referencias/`, no en el script.

Un envío sin fecha de inicio **se conserva**: sacarlo sin revisar es perder
una encuesta.

### 3.6 Completar desde otra fuente (opcional)

Si otra fuente tiene un dato que la principal dejó en NS/NR (la red que una
semilla dio en su registro), se completa **solo cuando la principal es
negativa** (-777/-888), nunca se cambia una respuesta real. El valor original
queda en `<variable>_<fuente>` y una marca `es_<variable>_desde_<fuente>`.

### 3.7 Clasificación e historial

Cuando cada registro es un intento sobre un caso (llamadas, visitas, rondas
de un panel), se agregan columnas que **no son alertas**:

- `es_`: el resultado del intento (`es_completa`, `es_rechazo`, `es_cita`,
  `es_contactado`, `es_cerrado`, `es_abierto`...).
- `historial_`: el lugar del intento en su caso, ordenado por inicio, llegada y
  `KEY` para que el orden sea estable: número de intento, intentos fallidos
  previos, días distintos con intentos fallidos, estado anterior, fin del
  intento anterior, si un intento previo ya cerró el caso.
- `es_encuesta_definitiva`: el registro que representa al caso (la primera
  completa; si no hay, el último intento).

Contrato: todo caso tiene **exactamente una** encuesta definitiva y ningún
intento queda a la vez abierto y cerrado.

---

## 4. Las diez dimensiones

| # | Dimensión | Pregunta | Mira | Medidas agregadas | Aplica a |
|---|---|---|---|---|---|
| D1 | Completitud | ¿Falta algo que debía estar? | todo registro donde la pregunta correspondía | `ale_d1_n_missing`, `ale_d1_missing` | todos |
| D2 | Validez | ¿El valor es posible? | todo valor no vacío | `ale_d2_n_invalido`, `ale_d2_invalido` | todos |
| D3 | Consistencia | ¿Dos valores posibles se contradicen? | pares o grupos de variables con dato | `ale_d3_n_inconsistente`, `ale_d3_inconsistente` | todos |
| D4 | Autenticidad | ¿Es real y de una sola persona? | solo completos | `ale_d4_n_autenticidad`, `ale_d4_autenticidad` | encuestas, registros |
| D5 | Elegibilidad | ¿Debía estar en la base? | solo completos | `ale_d5_n_elegibilidad`, `ale_d5_elegibilidad` | encuestas con filtros |
| D6 | Protocolo | ¿Se siguió el procedimiento? | todos los registros | `ale_d6_n_protocolo`, `ale_d6_protocolo` | trabajo de campo |
| D7 | Calidad por encuestador | ¿Quién se aparta del resto? | completos, heredado del encuestador | `ale_d7_n_encuestador`, `ale_d7_encuestador` | campo con ≥ 4 encuestadores |
| D8 | Atípicos | ¿Es posible pero muy improbable? | solo completos | `ale_d8_n_atipico`, `ale_d8_atipico` | todos |
| D9 | No sustantivas | ¿Eludió responder? | solo completos | `ale_d9_n_no_sustantiva`, `ale_d9_no_sustantiva` | encuestas |
| D10 | Gestión de casos | ¿Se manejó bien el caso? | todos los intentos | `ale_d10_n_gestion`, `ale_d10_gestion` | casos con varios intentos |

Una dimensión que no aplica **no se crea**, y las demás conservan su número:
D7 es siempre calidad por encuestador. En la consolidación, la dimensión que
falta simplemente no suma.

### Adaptar a fuentes que no son encuestas

| Dimensión | Registro administrativo / padrón | Scraping / API |
|---|---|---|
| D1 | campos obligatorios vacíos | campos que el portal debía traer |
| D2 | formato de documento, correo, teléfono, fechas | fechas, montos, códigos del portal |
| D3 | fecha de alta posterior a la de baja | plazo vencido antes de publicarse |
| D4 | la misma persona con dos ids; ids repetidos | el mismo registro con dos ids; cambios por hash |
| D5 | fuera del universo del programa | fuera del alcance de la búsqueda |
| D6 | carga fuera de plazo | descarga incompleta, documento ilegible |
| D7 | calidad por operador o sede de carga | calidad por fuente o portal |
| D8 | edades o montos improbables | presupuestos improbables |
| D9–D10 | no aplican | no aplican |

### 4.1 La estructura de cada dimensión

Las dos partes se repiten igual en las diez. Quien conoce una, las conoce
todas.

**N.1 Alertas por regla.** Un comentario de bloque que dice qué marca, qué
**no** marca y de dónde salen las reglas; después una alerta por regla, cada
una con su comentario y un ejemplo:

```r
# alerta si año de salida (e5_anio_salida) es anterior al año de nacimiento
# (r8_anio_nac).
# Ej.: r8_anio_nac = 1995 y e5_anio_salida = 1990 -> 1
ale_d3_e5_anio_salida = if_else(
  !is.na(e5_anio_salida) & e5_anio_salida >= 0 &      # -777/-888 no se comparan
  !is.na(r8_anio_nac)    & r8_anio_nac    >= 0 &
  e5_anio_salida < r8_anio_nac,
  1,
  0
),
```

Las reglas se agrupan por módulo del cuestionario, en el orden del
instrumento.

**N.2 Medidas agregadas.** Se calculan excluyendo las propias medidas, para
que correr el paso dos veces no las sume a sí mismas:

```r
ale_d3_n_inconsistente = rowSums(
  across(
    starts_with('ale_d3_') &
      !any_of(c('ale_d3_n_inconsistente', 'ale_d3_inconsistente'))
  )
),
ale_d3_inconsistente = if_else(ale_d3_n_inconsistente > 0, 1, 0)
```

### 4.2 Qué marca cada dimensión

**D1 Completitud.** Una alerta por pregunta obligatoria:
`<le correspondía> & <quedó vacía>`.

- "Le correspondía" es la relevancia del instrumento: la de la pregunta **más
  la de cada grupo que la contiene**.
- Traducción de SurveyCTO/ODK a R:

  | XLSForm | R |
  |---|---|
  | `${x} = 1` | `x %in% 1` |
  | `${x} != '996'` | `!(x %in% '996')` |
  | `${x} != ''` | `!is.na(x)` |
  | `${x} >= 0` | `x >= 0 & !is.na(x)` |
  | `selected(${x}, '1')` | `x_1 %in% 1` |
  | `count-selected(${x}) > 0` | `if_any(starts_with('x_'), ~ .x %in% 1)` |

- En una `select_multiple`, "quedó vacía" es que **todas** sus opciones están
  en NA: `if_all(starts_with('x_'), is.na)`.
- **Preguntas nuevas solo desde su versión**: si una pregunta se agregó en la
  versión V, la alerta pide `formdef_version >= V`. Sin ese corte, todas las
  encuestas anteriores aparecen incompletas.
- Las opcionales y las que nunca se pueden responder no llevan alerta.
- Siempre que se pueda, la relevancia se traduce con una función a partir del
  instrumento (`traducir_relevancia()`), no a mano. Si se escribe a mano, el
  bloque lo dice: "si cambia el XLS, hay que actualizar la condición".

**D2 Validez.** Una alerta por pregunta con regla:
`!is.na(x) & !(<regla>)`.

| Tipo | Regla |
|---|---|
| `select_one` | el código está en su lista (de `instrumento_opciones`) |
| `select_multiple` | una opción excluyente («No», «Ninguna», «Prefiere no responder») no va junto a otra |
| `integer` / `decimal` | el rango de la `constraint`, más los códigos especiales (-777, -888) |
| teléfono | `^\+[1-9][0-9]{7,14}$` |
| correo | `^[^@ A-Z]+@[^@ A-Z]+\.[^@ A-Z]+$`, o -777 |
| texto «Otro» | al menos 4 caracteres y alguna letra, o -777 |
| nota del encuestador | al menos 3 palabras |
| montos | sin `777`, `888`, `999` ni sus repeticiones |

Una regla que compara con otra pregunta (la cita no puede ser anterior a la
llamada) **no** es validez: es D3.

**D3 Consistencia.** Respuestas posibles por separado que juntas no pueden
ser ciertas. Las reglas salen de cuatro fuentes, y el bloque lo dice:

1. las `constraint` que comparan con otra pregunta;
2. los `choice_filter` (la región corresponde al país, el detalle a la
   categoría);
3. las alertas de consistencia que ya calcula el formulario, reescritas para
   verlas junto a las demás;
4. reglas nuevas que el formulario no controla: un dato "corregido" igual al
   que ya estaba, el país actual marcado como país de tránsito, un permiso
   temporal que "no vence".

Toda comparación numérica pide `>= 0` antes de comparar: un negativo es un
código de NS/NR.

**D4 Autenticidad.** Señales de que la entrevista no es real o no es de una
sola persona. Solo en registros completos.

- **Duración**: menos del mínimo para leer el cuestionario. El mínimo se
  calcula: palabras leídas ÷ 2,5 palabras por segundo + respuestas × 3
  segundos.
- **Pausa**: el reloj (fin − inicio) supera en más de N horas al tiempo que el
  formulario estuvo abierto: se cerró y se retomó.
- **Línea recta**: la misma respuesta en todos los ítems de una batería **y**
  el bloque respondido en menos del mínimo. La línea recta sola puede ser
  sincera.
- **Repetidos**: el mismo `KEY` dos veces; el mismo caso con dos completas; la
  misma persona (teléfono, documento) en dos casos; respuestas idénticas a otra
  encuesta.

No marca valores raros (D8) ni contradicciones (D3): eso no prueba que la
entrevista sea falsa.

**D5 Elegibilidad.** Un registro completo de alguien que no aceptó o no pasaba
un filtro. Todas deberían dar 0: si una se enciende, el error está en el
formulario o en los datos.

**D6 Protocolo.** El procedimiento de campo: la cadena de reclutamiento que no
se puede reconstruir, una versión vieja del formulario usada **después** de
publicada la nueva, un envío que llegó más de N horas después, un
consentimiento que duró menos de lo que toma leerlo.

**D7 Calidad por encuestador.** Encuestadores que se apartan del resto en
duración, NS/NR, «Otro» o rechazos.

- "Se aparta" = está a más de `factor_mad` (3) desviaciones absolutas medianas
  de la mediana de todos.
- Solo se aplica si el encuestador tiene al menos `encuestas_minimas_d7` (10),
  si hay al menos `encuestadores_minimos_d7` (4) así, y si la MAD no es 0. Con
  menos, cualquier diferencia parece atípica.
- Cada encuesta completa hereda la alerta de su encuestador. Si marcar todas
  sus encuestas no tiene sentido (nada que subsanar en una encuesta con 0 %),
  la medida queda como dato informativo `d7_` para retroalimentar al
  encuestador, sin prefijo `ale_`.
- Se calcula con columnas `aux_d7_` que se borran al terminar, después de
  mostrar la tabla por encuestador frente al típico.

**D8 Atípicos.** Valores posibles y válidos pero muy improbables, que hay que
confirmar antes de usar porque mueven un promedio: edad mayor a 85, montos
mayores a X dólares (convertidos con tasas fijas de la sección 1.2), ingresos
fuera de 0,25–7,5 salarios mínimos del país. **Un atípico no es un error.**

**D9 No sustantivas.** Más de N preguntas con NS/NR o más del P % de las
respondidas, o una variable clave para el análisis (el grado de red, el
ingreso) sin respuesta.

**D10 Gestión de casos.** Usa el historial de 3.7. Llamada sin caso, a un caso
que no existe, encimada con la anterior; caso cerrado que se volvió a llamar;
cierre por "no localizable" sin los N días de intentos; caso abierto tras N
intentos; lo que el formulario leyó del dataset de casos (`pre_`) no coincide
con lo que dejó el intento anterior.

---

## 5. Consolidar

```r
ale_n_total       = ale_d1_n_missing + ale_d2_n_invalido + ... + ale_d10_n_gestion,
ale_n_dimensiones = ale_d1_missing   + ale_d2_invalido   + ... + ale_d10_gestion,

alerta_final = case_when(
  !(estado %in% estados_completa) ~ 1,   # no es completo: no hay nada que revisar
  ale_n_total > 0                 ~ 2,   # completo con alertas: revisar
  .default                        = 3    # completo sin alertas: válido
)
```

Un registro que no es completo queda en 1 aunque tenga alertas (de protocolo,
de gestión): su detalle sigue en las columnas `ale_`.

---

## 6. Veredicto humano

Los registros con `alerta_final = 2` van a la validación (un Sheet por país o
supervisora). La decisión vuelve como fuente en `01_import` y se suma acá:

| Columna | Qué es |
|---|---|
| `val_revisada` | 1 si marcó la casilla |
| `val_decision` | `Validada`, `Se mantiene la alerta` o `Pendiente de llamada` |
| `val_motivo` | por qué; **obligatorio para validar** |
| `val_comentario`, `val_por`, `val_fecha` | texto libre, quién, cuándo |
| `es_validada_manual` | 1 si `alerta_final = 2`, casilla, `Validada` y motivo |
| `resultado_final` | `3` si se validó; si no, igual a `alerta_final` |

Contratos: todo registro tiene `resultado_final`, y la validación **solo
mueve registros de la clase 2**. Una decisión sobre un registro que ya no tiene
alertas no cambia nada.

---

## 7. Mantener la auditoría

- **Una regla que se quita no se borra en silencio**: queda un comentario con
  la fecha, quién lo pidió y por qué. Ej.: "se quitó el 20/10: el formulario ya
  exige que la cita sea futura y la alerta marcaba citas bien anotadas".
- **Un umbral que se cambia** se recalibra con datos y el comentario dice qué
  se midió: "el 18/10 una encuesta sincera en 41 s marcaba con 45 s; las
  falsas, en 25 y 6 s, marcan igual con 30".
- **Si el formulario ya calcula la alerta** (`aud_`), se reescribe con **los
  mismos umbrales** para que R y el formulario marquen lo mismo, y se documenta
  cuándo y por qué se aparta.
- **Cada nueva versión del instrumento**: revisar columnas fuera del
  instrumento (3.6), preguntas nuevas con su corte de versión (D1) y listas de
  códigos que cambiaron (D2).

---

## 8. Checklist

- [ ] Las filas que salen son las que entran, menos las pruebas, que se
      guardaron aparte.
- [ ] La conversión de tipos no perdió ningún dato (`stopifnot`).
- [ ] Toda alerta es 0/1 sin NA y usa `%in%` en las condiciones.
- [ ] Cada dimensión dice qué no marca y a quién le toca.
- [ ] Cada regla tiene comentario y ejemplo (`Ej.: ... -> 1`).
- [ ] Los umbrales están en la sección 1.2, con el porqué.
- [ ] Las preguntas nuevas solo se exigen desde su versión.
- [ ] Las medidas agregadas se excluyen a sí mismas.
- [ ] Las columnas `aux_` se borraron.
- [ ] `alerta_final` y `resultado_final` existen para todos los registros, con
      sus contratos.
- [ ] Ninguna lista de ids, encuestadores ni fechas escrita en el script: va en
      `sources/` o llega como fuente.
- [ ] Se guardó un solo objeto en `data/02_audit/`.
