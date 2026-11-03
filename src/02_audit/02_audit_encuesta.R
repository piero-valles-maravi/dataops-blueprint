#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 02_audit_encuesta                                                    #
# DETALLE: marca la encuesta con alertas 0/1 en sus dimensiones de calidad     #
#   (skill_audit.md). Acá NO se corrige ni se borra nada: se marca. Aplica las #
#   correcciones y los veredictos humanos de 01_import_validacion. EJEMPLO:    #
#   renombrar o borrar según las fuentes del proyecto.                         #
#                                                                              #
# CORRE DESPUES DE: 01_import_scto y 01_import_validacion                      #
# LEE: data/01_raw/<ronda>/, sources/01_instrumento/ y sources/02_referencias/ #
# ESCRIBE: data/02_audit/<ronda>/<proyecto>_encuesta_audit.RData               #
#-----------------------------------------------------------------------------.#

# 0. Setup ---------------------------------------------------------------------

# borra lo que haya en memoria: el script no depende de otro
rm(list = ls())

# los paquetes y las funciones compartidas
source('src/00_setup/packages.R')
source('src/00_setup/functions.R')

# el prefijo de los archivos y la ronda a procesar: la "activa" de
# sources/rondas.csv, o la que diga RONDA en .secrets/.Renviron
proyecto <- env_requerido('NOMBRE_PROYECTO')
ronda    <- ronda_activa()$ronda


# 1. Cargar --------------------------------------------------------------------

# el crudo de SurveyCTO y las decisiones humanas de 01_import_validacion
load(file.path('data/01_raw', ronda, paste0(proyecto, '_scto_raw.RData')))
load(file.path(
  'data/01_raw', ronda, paste0(proyecto, '_validaciones_raw.RData')
))
load(file.path(
  'data/01_raw', ronda, paste0(proyecto, '_correcciones_raw.RData')
))

# copia de trabajo: el crudo queda intacto para comparar
encuesta <- scto_raw


# 2. Preparar la base ----------------------------------------------------------

# skill_audit.md, sección 3: leer el instrumento, completar columnas, aplicar
# las correcciones humanas (guardando el valor original en orig_<variable>),
# validar tipos, quitar los envíos de prueba y clasificar los registros (es_)


# 3. Alertas por dimensión -----------------------------------------------------

# skill_audit.md, sección 4. Acá NO se corrige ni se borra nada: se marca.
# Cada dimensión tiene tres partes: las alertas por regla (0/1), las medidas
# agregadas y las consultas de validación que se miran al correr el script a
# mano. Las dimensiones que no aplican al proyecto se borran

# 3.1 D1 Completitud -----------------------------------------------------------

# alertas ale_d1_<variable>, luego ale_d1_n_<medida> y ale_d1_<medida>


# 3.2 D2 Validez ---------------------------------------------------------------

# alertas ale_d2_<variable>, luego ale_d2_n_<medida> y ale_d2_<medida>


# 3.3 D3 Consistencia ----------------------------------------------------------

# alertas ale_d3_<variable>, luego ale_d3_n_<medida> y ale_d3_<medida>


# 3.4 D4 Autenticidad ----------------------------------------------------------

# alertas ale_d4_<variable>, luego ale_d4_n_<medida> y ale_d4_<medida>


# 3.5 D5 Elegibilidad ----------------------------------------------------------

# alertas ale_d5_<variable>, luego ale_d5_n_<medida> y ale_d5_<medida>


# 3.6 D6 Protocolo -------------------------------------------------------------

# alertas ale_d6_<variable>, luego ale_d6_n_<medida> y ale_d6_<medida>


# 3.7 D7 Calidad por encuestador -----------------------------------------------

# alertas ale_d7_<variable>, luego ale_d7_n_<medida> y ale_d7_<medida>


# 3.8 D8 Atípicos --------------------------------------------------------------

# alertas ale_d8_<variable>, luego ale_d8_n_<medida> y ale_d8_<medida>


# 3.9 D9 No sustantivas --------------------------------------------------------

# alertas ale_d9_<variable>, luego ale_d9_n_<medida> y ale_d9_<medida>


# 3.10 D10 Gestión de casos ----------------------------------------------------

# alertas ale_d10_<variable>, luego ale_d10_n_<medida> y ale_d10_<medida>


# 4. Consolidar ----------------------------------------------------------------

# ale_n_total, ale_n_dimensiones y alerta_final (1, 2 o 3)


# 5. Veredicto humano ----------------------------------------------------------

# une las decisiones de validaciones_raw en las columnas val_ y deja
# resultado_final: lo que decidió la supervisora pesa más que la alerta

encuesta_audit <- encuesta


# 6. Guardar en data/02_audit --------------------------------------------------

# la carpeta de salida se crea si no existe
carpeta_salida <- file.path('data/02_audit', ronda)
dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)

save(
  encuesta_audit,
  file = file.path(carpeta_salida, paste0(proyecto, '_encuesta_audit.RData'))
)

rm(list = ls())
