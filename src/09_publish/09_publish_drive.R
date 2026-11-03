#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 09_publish_drive                                                     #
# DETALLE: respalda en Google Drive cada carpeta de data/, con la fecha en el  #
#   nombre del archivo: la última foto del día en el monitoreo diario          #
#   (daily.yml) y la del corte en el pipeline completo (completo.yml). No      #
#   modifica nada.                                                             #
#                                                                              #
# CORRE DESPUES DE: 03_clean (diario) u 08_products (completo)                 #
# LEE: data/01_raw a data/06_final                                             #
# ESCRIBE: una carpeta de Drive por etapa (GDRIVE_ID_*)                        #
#-----------------------------------------------------------------------------.#

# 0. Setup ---------------------------------------------------------------------

# borra lo que haya en memoria: el script no depende de otro
rm(list = ls())

# los paquetes, las funciones y las credenciales (.secrets/.Renviron)
source('src/00_setup/packages.R')
source('src/00_setup/functions.R')
source('src/00_setup/auth.R')

# el prefijo de los archivos
proyecto <- env_requerido('NOMBRE_PROYECTO')


# 1. Las carpetas a respaldar --------------------------------------------------

# cada carpeta de data/ va a su carpeta de Drive (GDRIVE_ID_<ETAPA>). La
# etapa sin id en .secrets/.Renviron no se respalda
carpetas <- c(
  RAW       = 'data/01_raw',
  AUDIT     = 'data/02_audit',
  CLEAN     = 'data/03_clean',
  ENRICH    = 'data/04_enrich',
  INTEGRATE = 'data/05_integrate',
  FINAL     = 'data/06_final'
)


# 2. Subir a Drive -------------------------------------------------------------

# con la fecha en el nombre: cada día deja su foto y no pisa la anterior
fecha <- format(Sys.time(), '%Y-%m-%d')

purrr::iwalk(carpetas, function(carpeta, etapa) {

  id_drive <- env_opcional(paste0('GDRIVE_ID_', etapa))
  if (is.null(id_drive)) return(invisible())

  archivos <- list.files(carpeta, pattern = '\\.RData$',
                         recursive = TRUE, full.names = TRUE)

  purrr::walk(archivos, function(archivo) {
    googledrive::drive_upload(
      archivo,
      path = googledrive::as_id(id_drive),
      name = sub('\\.RData$', paste0('_', fecha, '.RData'), basename(archivo)),
      overwrite = TRUE
    )
  })

})

rm(list = ls())
