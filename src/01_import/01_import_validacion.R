#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 01_import_validacion                                                 #
# DETALLE: descarga las decisiones humanas: la validación de las supervisoras  #
#   y las correcciones que tienen datos personales. Son una fuente más:        #
#   02_audit aplica los veredictos y las correcciones. EJEMPLO: renombrar o    #
#   borrar según las fuentes del proyecto.                                     #
#                                                                              #
# CORRE DESPUES DE: 00_setup                                                   #
# LEE: el Sheet de validación                                                  #
# ESCRIBE: data/01_raw/<ronda>/<proyecto>_validaciones_raw.RData y             #
#   <proyecto>_correcciones_raw.RData                                          #
#-----------------------------------------------------------------------------.#

# 0. Setup ---------------------------------------------------------------------

# borra lo que haya en memoria: el script no depende de otro
rm(list = ls())

# los paquetes, las funciones y las credenciales (.secrets/.Renviron)
source('src/00_setup/packages.R')
source('src/00_setup/functions.R')
source('src/00_setup/auth.R')

# el prefijo de los archivos y la ronda a procesar: la "activa" de
# sources/rondas.csv, o la que diga RONDA en .secrets/.Renviron
proyecto <- env_requerido('NOMBRE_PROYECTO')
ronda    <- ronda_activa()$ronda


# 1. Descargar las decisiones humanas ------------------------------------------

# el Sheet de validación tiene dos pestañas: los veredictos de las
# supervisoras sobre las encuestas con alerta y las correcciones que no
# pueden ir en sources/03_correcciones porque tienen datos personales
id_validacion <- env_requerido('GSHEET_ID_VALIDACION')

validaciones_raw <- googlesheets4::read_sheet(
  id_validacion, sheet = 'validacion', col_types = 'c'
)

correcciones_raw <- googlesheets4::read_sheet(
  id_validacion, sheet = 'correcciones', col_types = 'c'
)


# 2. Guardar en data/01_raw ----------------------------------------------------

# la carpeta de salida se crea si no existe
carpeta_salida <- file.path('data/01_raw', ronda)
dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)

save(
  validaciones_raw,
  file = file.path(carpeta_salida, paste0(proyecto, '_validaciones_raw.RData'))
)
save(
  correcciones_raw,
  file = file.path(carpeta_salida, paste0(proyecto, '_correcciones_raw.RData'))
)

rm(list = ls())
