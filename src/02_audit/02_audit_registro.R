#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 02_audit_registro                                                    #
# DETALLE: marca el registro con las dimensiones que le aplican (completitud,  #
#   validez, consistencia, duplicados, atípicos). Acá NO se corrige ni se      #
#   borra nada. EJEMPLO: renombrar o borrar según las fuentes del proyecto.    #
#                                                                              #
# CORRE DESPUES DE: 01_import_registro                                         #
# LEE: data/01_raw/<ronda>/                                                    #
# ESCRIBE: data/02_audit/<ronda>/<proyecto>_registro_audit.RData               #
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

load(file.path('data/01_raw', ronda, paste0(proyecto, '_registro_raw.RData')))

# copia de trabajo: el crudo queda intacto para comparar
registro <- registro_raw


# 2. Preparar la base ----------------------------------------------------------

# completar columnas, validar tipos y clasificar los registros (es_)


# 3. Alertas por dimensión -----------------------------------------------------

# skill_audit.md, "Adaptar a fuentes que no son encuestas". Acá NO se
# corrige ni se borra nada: se marca. Cada dimensión con sus alertas por
# regla (0/1), sus medidas agregadas y sus consultas de validación

# 3.1 D1 Completitud -----------------------------------------------------------

# alertas ale_d1_<variable>, luego ale_d1_n_<medida> y ale_d1_<medida>


# 3.2 D2 Validez ---------------------------------------------------------------

# alertas ale_d2_<variable>, luego ale_d2_n_<medida> y ale_d2_<medida>


# 3.3 D3 Consistencia ----------------------------------------------------------

# alertas ale_d3_<variable>, luego ale_d3_n_<medida> y ale_d3_<medida>


# 3.4 D4 Duplicados ------------------------------------------------------------

# alertas ale_d4_<variable>, luego ale_d4_n_<medida> y ale_d4_<medida>


# 3.5 D8 Atípicos --------------------------------------------------------------

# alertas ale_d8_<variable>, luego ale_d8_n_<medida> y ale_d8_<medida>


# 4. Consolidar ----------------------------------------------------------------

# ale_n_total, ale_n_dimensiones y alerta_final (1, 2 o 3)

registro_audit <- registro


# 5. Guardar en data/02_audit --------------------------------------------------

# la carpeta de salida se crea si no existe
carpeta_salida <- file.path('data/02_audit', ronda)
dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)

save(
  registro_audit,
  file = file.path(carpeta_salida, paste0(proyecto, '_registro_audit.RData'))
)

rm(list = ls())
