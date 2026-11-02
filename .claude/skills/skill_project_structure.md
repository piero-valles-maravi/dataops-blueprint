---
name: estructura-proyecto-datos
description: >
  Estructura de carpetas y orden de scripts de los proyectos de datos de Piero
  Valles (Equilibrium BDC): pipeline numerado en R con setup, import, audit,
  clean y salidas, datos por etapa, insumos en sources/, credenciales en
  .secrets/ y automatización en GitHub Actions. Úsala SIEMPRE que haya que
  arrancar un proyecto nuevo, armar o "scaffoldear" un repositorio, decidir
  dónde va un script, una carpeta o un archivo, crear un script nuevo del
  pipeline, agregar una etapa, ordenar un repo desordenado, o cuando pida
  "la misma estructura que el proyecto de MANN" o "como venimos trabajando".
  No cubre el contenido de los scripts (para eso está
  estilo-programacion-piero-valles) ni el README (readme-proyecto-datos).
---

# Estructura de un proyecto de datos

Esta skill describe **dónde va cada cosa**, no qué hace cada script por dentro.
Está destilada del repositorio `pipeline-mann-pricing-rgm` (encuesta en
SurveyCTO, auditoría, limpieza, dashboard en Looker Studio y respaldo en Google
Drive), pero sirve para cualquier proyecto que tome datos de una fuente, los
revise, los limpie y los entregue.

La idea que ordena todo: **el número de la etapa es el mismo en el script y en
la carpeta de datos que produce.** `src/02_audit.R` lee `data/01_raw/` y
escribe `data/02_audit/`. Quien abre el repo entiende el flujo sin leer código.

---

## 1. El árbol

```
<proyecto>/
├── .github/workflows/
│   ├── workflow_<proyecto>_hourly.yml   corrida frecuente: actualiza el dashboard
│   └── workflow_<proyecto>_daily.yml    corrida de cierre: respalda cada etapa
├── .secrets/                            credenciales (nada se sube, salvo .gitkeep)
│   ├── .gitkeep
│   ├── .Renviron                        variables de entorno
│   └── *.json                           claves que son archivo (cuenta de servicio)
├── data/                                datos (en git van solo las carpetas)
│   ├── 01_raw/                          lo que llega de la fuente, tal cual
│   ├── 02_audit/                        la base con las alertas marcadas
│   ├── 03_clean/                        la base corregida y etiquetada
│   └── 04_final/                        los productos finales
├── sources/                             insumos que el pipeline NO produce
│   ├── 01_instrumento/                  cuestionario programado (XLS), diccionarios
│   └── 02_images/                       imágenes del README (banner.svg)
├── src/
│   ├── 00_setup/
│   │   ├── packages.R                   solo paquetes
│   │   ├── functions.R                  solo funciones
│   │   └── auth.R                       solo autenticación de servicios de red
│   ├── 00_master.R                      corre todo en orden, para probar en local
│   ├── 01_import.R
│   ├── 02_audit.R
│   ├── 03_clean.R
│   ├── 04_1_<salida_frecuente>.R        ej: 04_1_monitoring_perhour.R
│   ├── 04_2_<salida_diaria>.R           ej: 04_2_monitoring_daily_export.R
│   └── scripts borrador <etapa>/        versiones viejas (piloto); no corren
├── .gitignore
├── <proyecto>.Rproj
└── README.md
```

Cada carpeta de `data/` y de `sources/` lleva un `.gitkeep` para que la
estructura exista al clonar, aunque los datos no se suban.

---

## 2. Las reglas que no se negocian

### 2.1 Numeración

- **Los scripts del pipeline empiezan con dos dígitos** y corren en ese orden:
  `01_import`, `02_audit`, `03_clean`, `04_...`.
- **La carpeta de datos lleva el mismo número que el script que la escribe.**
  Si se agrega una etapa, se agregan los dos a la vez.
- **Una etapa con varias salidas se numera con subíndice**: `04_1_`, `04_2_`.
  Así siguen ordenándose juntas y se ve que son hermanas. En MANN: `04_1` escribe
  el Sheet del dashboard cada hora y `04_2` sube los `.RData` a Drive una vez al
  día.
- **`00_` es lo que no es una etapa**: el setup y el master.
- **Las subcarpetas de `sources/` también se numeran**, por orden de
  importancia, no alfabético.
- Nombres de archivo en **inglés y snake_case** (`01_import.R`, `02_audit.R`);
  todo el contenido, en español.

### 2.2 Cada etapa lee la anterior y escribe la suya

- Un script carga **solo** la salida de la etapa anterior (`load()` del
  `.RData`) y guarda **un objeto** en su propia carpeta.
- El objeto se llama `<proyecto>_<etapa>` y el archivo igual:
  `mann_rgm_raw` → `data/01_raw/mann_rgm_raw.RData`,
  `mann_rgm_audit` → `data/02_audit/mann_rgm_audit.RData`.
- Ningún script escribe en la carpeta de otro. Así cualquier etapa se puede
  volver a correr sola, y si algo falla se sabe exactamente dónde.
- Cada script abre con `rm(list = ls())` y los `source()` del setup, y cierra
  con `rm(list = ls())`. No depende de lo que dejó otro en memoria.

### 2.3 El setup son tres archivos, cada uno con una sola responsabilidad

| Archivo | Qué tiene | Qué NO tiene |
|---|---|---|
| `packages.R` | `library(pacman)` y un `p_load()` | funciones, credenciales |
| `functions.R` | solo funciones compartidas, numeradas por tema | código que se ejecute al cargarlo |
| `auth.R` | la autenticación con Google u otros servicios | nada más |

`auth.R` se separa porque **golpea la red**: solo lo cargan los scripts que lo
necesitan (`01_import`, `04_*`), no la auditoría ni la limpieza.

Las funciones que usan dos scripts van en `functions.R`, nunca copiadas.

### 2.4 `sources/` es lo que entra de afuera

- El cuestionario programado, diccionarios, listas de códigos, imágenes.
- **Nada que produzca el pipeline va en `sources/`**: eso va en `data/`.
- Si hay versiones (piloto y campo), conviven las dos en la misma carpeta y la
  ruta va **arriba del script**, en la sección de rutas, para cambiarla en un
  solo lugar.

### 2.5 Credenciales

- Todo identificador y credencial vive en `.secrets/.Renviron` y se lee con una
  función `env_requerido('NOMBRE')` de `functions.R`, que corta con el nombre de
  la variable que falta y nunca imprime su valor.
- `.secrets/` está entera en `.gitignore`, salvo el `.gitkeep`.
- En GitHub Actions las mismas variables llegan como **secrets con el mismo
  nombre**, así el código es uno solo. La clave que es archivo (cuenta de
  servicio) se escribe a un archivo temporal al empezar y se borra al terminar
  con `if: always()`.

### 2.6 Borradores

- Las versiones viejas que se quieren conservar (las del piloto, por ejemplo) van
  en `src/scripts borrador <etapa>/` con el sufijo `_borrador`:
  `01_import_borrador.R`.
- No forman parte del pipeline y ningún workflow las llama. El README lo dice.

### 2.7 El master

`src/00_master.R` es solo una lista de `source()` en orden, para probar el
pipeline completo en local. **No es lo que corre en producción**: eso lo hacen
los workflows, paso por paso, para que el log de GitHub muestre en qué etapa
falló.

```r
source('src/01_import.R')
source('src/02_audit.R')
source('src/03_clean.R')
source('src/04_1_monitoring_perhour.R')
```

---

## 3. Automatización

Dos workflows, uno por frecuencia, en `.github/workflows/`:

| Workflow | Corre | Pasos |
|---|---|---|
| `workflow_<proyecto>_hourly.yml` | cada hora en la jornada | `01` → `02` → `03` → `04_1` |
| `workflow_<proyecto>_daily.yml` | una vez, al cierre del día | `01` → `02` → `03` → `04_2` |

Lo que llevan los dos, siempre:

- **`TZ` con la zona horaria local** (`America/Asuncion`), para que las fechas de
  los archivos y la hora de actualización sean las del país.
- **El mismo grupo de concurrencia** (`concurrency: group: pipeline`,
  `cancel-in-progress: false`): nunca corren a la vez. Una API que limita las
  descargas completas (SurveyCTO) rechaza la segunda.
- **El cron fuera del minuto 0** (por ejemplo `17 11-21 * * *`): al inicio de
  cada hora GitHub atrasa o descarta las corridas programadas. En MANN, con
  `0 11-21` no se disparó ninguna en un día entero.
- **Un paso por script** (`Rscript src/01_import.R`...), no el master.
- **`workflow_dispatch`**, para poder lanzarlo a mano.
- El cron va en UTC, con un comentario arriba que diga la hora local.

---

## 4. `.gitignore` base

```gitignore
# Archivos y sesiones de R
.Rproj.user/
.Rhistory
.RData
.RDataTmp*
.RData.tmp
.Ruserdata

# el .Renviron va en .secrets/; esto es por si alguien vuelve a crear uno en la raíz
.Renviron

# Editores
.posit/
.positai

# Sistema operativo
.DS_Store
Thumbs.db
desktop.ini

# el archivo temporal que deja Excel mientras está abierto un .xlsx de sources/
~$*

# Datos: se ignora el contenido, pero se conserva la estructura de carpetas
data/**
!data/**/
!data/**/.gitkeep

# Credenciales: nada de .secrets/ se sube, salvo el archivo que conserva la carpeta
.secrets/*
!.secrets/.gitkeep
```

---

## 5. Arrancar un proyecto nuevo

1. Crear el árbol de la sección 1 con sus `.gitkeep`. En R, desde la raíz:

   ```r
   # las carpetas del proyecto, cada una con su .gitkeep
   carpetas <- c(
     '.github/workflows',
     '.secrets',
     'data/01_raw',
     'data/02_audit',
     'data/03_clean',
     'data/04_final',
     'sources/01_instrumento',
     'sources/02_images',
     'src/00_setup'
   )

   walk(carpetas, ~ dir.create(.x, recursive = TRUE, showWarnings = FALSE))
   walk(setdiff(carpetas, '.github/workflows'), ~ file.create(file.path(.x, '.gitkeep')))
   ```

2. Copiar el `.gitignore` de la sección 4 **antes** del primer commit, para que
   no se suba ni un dato ni una credencial.
3. Crear los tres archivos de `src/00_setup/`, con `env_requerido()` como primera
   función de `functions.R`.
4. Crear `.secrets/.Renviron` con las variables, y los mismos nombres como
   secrets del repositorio en GitHub.
5. Escribir los scripts en orden, uno por etapa, cada uno con su carpeta de
   `data/`.
6. Los workflows al final, cuando el pipeline ya corre completo en local con
   `00_master.R`.
7. El README con la skill `readme-proyecto-datos`.

---

## 6. Adaptar a otro proyecto

Lo que se mantiene siempre: la numeración compartida entre scripts y carpetas,
el setup en tres archivos, `sources/` para lo que entra de afuera, `.secrets/`
con `env_requerido()`, y los dos workflows con concurrencia compartida.

Lo que cambia según el proyecto, **sin romper la numeración**:

| Situación | Cómo se resuelve |
|---|---|
| La fuente no es una encuesta (padrón, API, CSV de un cliente) | `01_import.R` igual; lo que cambia es adentro |
| No hace falta auditoría | se pasa de `01_raw` a `02_clean`, renumerando el resto. No se deja un hueco |
| Hay varias fuentes | un script por fuente en la misma etapa: `02_clean_<fuente>.R`, todos escriben en `data/02_clean/` |
| Hay que juntar fuentes | una etapa propia: `03_integration.R` → `data/03_integration/` |
| Varias salidas | `04_1_`, `04_2_`... una por destino o por frecuencia |
| No hay dashboard ni corrida por hora | un solo workflow, el diario |

---

## 7. Checklist

- [ ] Cada script del pipeline empieza con dos dígitos y tiene su carpeta en
      `data/` con el mismo número.
- [ ] Cada etapa lee solo la anterior y guarda un objeto con el nombre del
      archivo.
- [ ] El setup son tres archivos y `auth.R` solo lo cargan los que usan la red.
- [ ] Ningún archivo que produce el pipeline está en `sources/`.
- [ ] `.secrets/` y `data/**` están en `.gitignore`, con sus `.gitkeep`.
- [ ] Ninguna credencial ni id escrito en un script: todo con `env_requerido()`.
- [ ] Los borradores están en su carpeta y ningún workflow los llama.
- [ ] Los workflows tienen `TZ`, concurrencia compartida, un paso por script y
      el cron fuera del minuto 0.
