#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 01_import_registro                                                   #
# DETALLE: descarga una segunda fuente: un registro administrativo, un padrón  #
#   o un Sheet del cliente, tal cual llega. Acá NO se filtra ni se corrige     #
#   nada. EJEMPLO: renombrar o borrar según las fuentes del proyecto.          #
#                                                                              #
# CORRE DESPUES DE: 00_setup                                                   #
# LEE: el Sheet, la base o el archivo del registro                             #
# ESCRIBE: data/01_raw/<ronda>/<proyecto>_registro_raw.RData                   #
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


# 1. Descargar el registro -----------------------------------------------------

# EJEMPLO con un Sheet del cliente. Si el registro viene de una base de datos
# (DBI + RPostgres, con DB_HOST, DB_NAME...) o de una API (httr, con
# REGISTRO_API_URL y REGISTRO_API_KEY), se reemplaza esta llamada. Todo como
# texto: los tipos se arreglan en 03_clean, no acá
registro_raw <- googlesheets4::read_sheet(
  env_requerido('GSHEET_ID_REGISTRO'),
  col_types = 'c'
)

# control: tiene que llegar una tabla con filas
if (nrow(registro_raw) == 0) {
  stop('El registro llegó vacío. No se sobrescribió el crudo de ', ronda, '.')
}


# 2. Guardar en data/01_raw ----------------------------------------------------

# la carpeta de salida se crea si no existe
carpeta_salida <- file.path('data/01_raw', ronda)
dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)

save(
  registro_raw,
  file = file.path(carpeta_salida, paste0(proyecto, '_registro_raw.RData'))
)

rm(list = ls())
