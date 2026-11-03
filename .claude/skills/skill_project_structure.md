---
name: estructura-proyecto-datos
description: >
  Estructura de carpetas y orden de scripts de los proyectos de datos que nacen
  de dataops-blueprint: nueve etapas numeradas en R (import, audit, clean,
  enrich, integrate, indicators, analysis, monitoring, publish), datos por etapa
  y por ronda, insumos en sources/, credenciales en .secrets/, proyecto y ronda
  en config.R y automatización en GitHub Actions. Úsala SIEMPRE que haya que
  arrancar un proyecto nuevo, decidir dónde va un script, una carpeta o un
  archivo, crear un script nuevo del pipeline, agregar o quitar una etapa, o
  cambiar de ronda. No cubre el contenido de los scripts (skill_code_style.md)
  ni el README (skill_readme.md).
---

# Estructura de un proyecto de datos

Esta skill describe **dónde va cada cosa**, no qué hace cada script por dentro.
El árbol completo, con la descripción de cada carpeta, está en la sección 5 del
README.

La idea que ordena todo: **el número de la etapa es el mismo en el script y en
la carpeta que escribe.** `src/02_audit/` lee `data/01_raw/` y escribe
`data/02_audit/`. Quien abre el repo entiende el flujo sin leer código.

---

## 1. Las nueve etapas

| Bloque | Etapa | Script | Escribe en |
|---|---|---|---|
| Ingesta | `01` | `src/01_import/01_import_<fuente>.R` | `data/01_raw/<ronda>/` |
| Procesar | `02` | `src/02_audit/02_audit_<fuente>.R` | `data/02_audit/<ronda>/` |
| | `03` | `src/03_clean/03_clean_<fuente>.R` | `data/03_clean/<ronda>/` |
| | `04` | `src/04_enrich/04_enrich_<fuente>.R` | `data/04_enrich/<ronda>/` |
| | `05` | `src/05_integrate/05_integrate_<n>_<paso>.R` | `data/05_integrate/` |
| | `06` | `src/06_indicators/06_indicators_<paso>.R` | `data/06_final/` |
| Producir | `07` | `src/07_analysis/07_analysis_<producto>.R` | `outputs/07_analysis/<producto>/` |
| | `08` | `src/08_monitoring/08_monitoring_<frecuencia>.R` | `outputs/08_monitoring/<frecuencia>/` |
| Publicar | `09` | `src/09_publish/09_publish_<destino>.R` | Sheets, Drive |

- **`data/` tiene solo bases.** Tablas, figuras, informes y entregas van en
  `outputs/`.
- **`data/06_final/` es la frontera**: de ahí en adelante nadie lee otra carpeta
  de `data/`. La única excepción es `08_monitoring`, que lee `data/03_clean/`
  porque mide el campo mientras ocurre.
- **04 contra 06.** `04_enrich` trae información de afuera, fuente por fuente,
  antes de integrar. `06_indicators` calcula sobre la base integrada.

---

## 2. Las reglas que no se negocian

### 2.1 Numeración

- **El número de una etapa no cambia nunca.** Si el proyecto no usa una etapa,
  se borran su carpeta de `src/` y la de `data/` o `outputs/`, y las demás
  conservan su número. No se renumera para tapar el hueco.
- **Varias fuentes en una etapa: un script por fuente**, con la fuente al final:
  `03_clean_encuesta.R`, `03_clean_registro.R`. Todos escriben en la misma
  carpeta.
- **Varios pasos en una etapa: subíndice**, cuando uno depende del otro:
  `05_integrate_1_apilar.R`, `05_integrate_2_entidades.R`.
- **`00_` es lo que no es una etapa**: `src/00_setup/` y `src/00_master.R`.
- **Las subcarpetas de `sources/` también se numeran**, por orden de
  importancia, no alfabético.
- Nombres de archivo en **inglés y snake_case**; todo el contenido, en español.

### 2.2 Proyecto, ronda y nombres de archivo

- **`src/00_setup/config.R` define `proyecto` y `ronda`**, y es lo único que se
  edita al empezar un proyecto o al cambiar de ronda. Con `ronda <- NULL` el
  proyecto no tiene rondas.
- **Las etapas `01` a `04` van por ronda**: carpeta `data/<etapa>/<ronda>/` y
  nombre `<proyecto>_<ronda>_<base>_<etapa>`. Desde `05` se juntan todas las
  rondas: carpeta `data/<etapa>/` y nombre `<proyecto>_<base>`.
- **Nadie escribe una ruta a mano.** Se carga con `load(ruta_base(etapa, base))`
  y se guarda con `guardar_etapa(objeto, etapa)`, las dos de `functions.R`.
- **El objeto dentro del `.RData` se llama corto** (`encuesta_clean`), sin
  proyecto ni ronda, para que el script que lo carga no tenga que adivinarlo.
- **Lo que va a Drive lleva la fecha** al final del nombre:
  `tigo_ronda_1_encuesta_clean_2026-11-02`.

| `config.R` | Etapa `03` | Etapa `06` |
|---|---|---|
| `ronda <- 'ronda_1'` | `data/03_clean/ronda_1/tigo_ronda_1_encuesta_clean.RData` | `data/06_final/tigo_final.RData` |
| `ronda <- NULL` | `data/03_clean/tigo_encuesta_clean.RData` | `data/06_final/tigo_final.RData` |

### 2.3 Cada etapa lee la anterior y escribe la suya

- Un script carga **solo** la salida de la etapa anterior y guarda en su propia
  carpeta. Ningún script escribe en la carpeta de otro: así cualquier etapa se
  puede volver a correr sola, y si algo falla se sabe dónde.
- **Toda base sale en seis formatos**: `.RData` (la que lee la etapa siguiente),
  `.sav`, `.dta`, `.xlsx`, `.csv` y un Google Sheet en la carpeta de Drive de la
  etapa (`GDRIVE_ID_<ETAPA>`). Lo hace `guardar_etapa()`.
- Cada script abre con `rm(list = ls())` y los `source()` del setup, y cierra
  con `rm(list = ls())`. No depende de lo que dejó otro en memoria.

### 2.4 El setup son cuatro archivos, cada uno con una sola responsabilidad

| Archivo | Qué tiene | Qué NO tiene |
|---|---|---|
| `packages.R` | `library(pacman)` y un `p_load()` comentado | funciones, credenciales |
| `functions.R` | solo funciones compartidas, numeradas por tema | código que se ejecute al cargarlo |
| `config.R` | `proyecto` y `ronda` | credenciales, ids |
| `auth.R` | carga `.secrets/.Renviron` y autentica Google | nada más |

`auth.R` se separa porque **golpea la red**: solo lo cargan los scripts que lo
necesitan (`01_import` y `09_publish`). Las funciones que usan dos scripts van
en `functions.R`, nunca copiadas.

### 2.5 `sources/` es lo que entra de afuera

- `01_instrumento/` el cuestionario programado, `02_referencias/` catálogos y
  listas, `03_correcciones/` las correcciones revisadas a mano.
- **Nada que produzca el pipeline va en `sources/`**: eso va en `data/` u
  `outputs/`.

### 2.6 Credenciales

- Todo identificador y credencial vive en `.secrets/.Renviron` y se lee con
  `env_requerido('NOMBRE')`, que corta con el nombre de la variable que falta y
  nunca imprime su valor. La plantilla es `.secrets/.Renviron.example`.
- `.secrets/` está entera en `.gitignore`, salvo `.gitkeep` y
  `.Renviron.example`.
- En GitHub Actions las mismas variables llegan como **secrets con el mismo
  nombre**. La clave de la cuenta de servicio se escribe a un archivo al empezar
  y se borra al terminar con `if: always()`.

### 2.7 Borradores

- Las versiones viejas que se quieren conservar van en `src/borradores/`, que
  está en `.gitignore`. Ningún workflow las llama.

### 2.8 El master

`src/00_master.R` es solo una lista de `source()` en orden, agrupada por los
cuatro bloques, para probar el pipeline completo en local. **No es lo que corre
en producción**: eso lo hacen los workflows, un paso por script, para que el log
de GitHub muestre en qué etapa falló.

---

## 3. Automatización

| Workflow | Cuándo | Pasos |
|---|---|---|
| `hourly.yml` | cada hora, en la jornada de campo | `01` → `02` → `03` → `08_monitoring_hourly` → `09_publish_sheets` |
| `daily.yml` | una vez, al cierre del día | `01` → `02` → `03` → `08_monitoring_daily` → `09_publish_drive` |
| `completo.yml` | a mano, al hacer un corte o cerrar el campo | `01` a `09` |
| `dashboard.yml` | al cambiar `tools/dashboard/` | publica el explorador en Pages |

Lo que llevan todos:

- **Sin `schedule`.** Los dispara `tools/apps_script/disparador.gs` con
  `workflow_dispatch`, porque el cron de GitHub no es confiable en repos con poca
  actividad.
- **`TZ` con la zona horaria local**, para que las fechas de los archivos sean
  las del país.
- **El mismo grupo de concurrencia** (`group: pipeline`,
  `cancel-in-progress: false`): nunca corren a la vez. Una API que limita las
  descargas completas (SurveyCTO) rechaza la segunda.
- **Un paso por script** (`Rscript src/01_import/01_import_scto.R`...), no el
  master.

---

## 4. Arrancar un proyecto nuevo

1. Crear el repo desde la plantilla (*Use this template*).
2. Editar `src/00_setup/config.R`: `proyecto` y `ronda`.
3. Borrar las etapas que el proyecto no usa: su carpeta de `src/`, la de `data/`
   o `outputs/`, su línea en `00_master.R` y sus pasos en los workflows. Sin
   rondas, borrar también las subcarpetas de ronda de `data/01_raw` a
   `data/04_enrich`.
4. Copiar `.secrets/.Renviron.example` como `.secrets/.Renviron` y completarlo;
   cargar los mismos nombres como secrets del repositorio en GitHub.
5. Renombrar los scripts de ejemplo según las fuentes del proyecto
   (`_encuesta`, `_registro`) y escribirlos en orden.
6. Los workflows y el disparador al final, cuando el pipeline ya corre completo
   en local con `00_master.R`.
7. El README con `skill_readme.md`.

---

## 5. Adaptar a otro proyecto

| Situación | Cómo se resuelve |
|---|---|
| La fuente no es una encuesta (padrón, API, CSV de un cliente) | `01_import_<fuente>.R` igual; lo que cambia es adentro |
| Una sola fuente y una sola ronda | la etapa `05` no existe: se borra |
| No hace falta enriquecer | se borra `04_enrich`; `05` lee de `03_clean` |
| Sin rondas | `ronda <- NULL` en `config.R` |
| Una ronda nueva | se cambia `ronda` en `config.R` y el `formid` en `01_import_scto.R` |
| No hay dashboard ni corrida por hora | se borran `hourly.yml` y `08_monitoring_hourly.R` |
| Un pedido nuevo (tablas, un informe, una lista) | un `07_analysis_<producto>.R` con su carpeta en `outputs/07_analysis/`; si además hay que enviarlo, un `09_publish_<destino>.R` |

---

## 6. Checklist

- [ ] Cada script empieza con el número de su etapa y escribe solo en la carpeta
      con ese número.
- [ ] Ninguna ruta escrita a mano: `ruta_base()` para cargar y
      `guardar_etapa()` para guardar.
- [ ] `proyecto` y `ronda` están solo en `config.R`.
- [ ] Ningún archivo que produce el pipeline está en `sources/`.
- [ ] `.secrets/`, `data/**` y `outputs/**` están en `.gitignore`, con sus
      `.gitkeep`.
- [ ] Ninguna credencial ni id escrito en un script: todo con `env_requerido()`.
- [ ] Los workflows tienen `TZ`, concurrencia compartida y un paso por script.
