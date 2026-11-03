#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 08_publish_drive                                                     #
# DETALLE: respalda en Google Drive cada carpeta de data/, con la fecha en     #
#   el nombre del archivo: la última foto del día en el monitoreo diario       #
#   (daily.yml) y la del corte en el pipeline completo (completo.yml). No      #
#   modifica nada.                                                             #
#                                                                              #
# CORRE DESPUES DE: monitoring_daily (diario) u 07_analysis (completo)         #
# LEE: data/01_raw a data/06_final                                             #
# ESCRIBE: una carpeta de Drive por etapa (GDRIVE_ID_*)                        #
#-----------------------------------------------------------------------------.#

# Setup ------------------------------------------------------------------------

# borra lo que haya en memoria: el script no depende de otro
rm(list = ls())

# los paquetes del proyecto
source('src/00_setup/packages.R')

# las funciones compartidas
source('src/00_setup/functions.R')

# el proyecto y la ronda: arman la carpeta y el nombre de cada archivo
source('src/00_setup/config.R')

# las credenciales: .secrets/.Renviron y la cuenta de servicio de Google
source('src/00_setup/auth.R')



# Rutas y carpetas -------------------------------------------------------------

# cada carpeta de data/ y el resumen del día van a su carpeta de Drive
# (GDRIVE_ID_<ETAPA>)
carpetas <- c(
  RAW       = 'data/01_raw',                       # los crudos
  AUDIT     = 'data/02_audit',                     # las auditadas
  CLEAN     = 'data/03_clean',                     # las limpias
  ENRICH    = 'data/04_enrich',                    # las enriquecidas
  INTEGRATE = 'data/05_integrate',                 # la integrada
  FINAL     = 'data/06_final',                     # la final
  MONITOREO = 'outputs/monitoring/daily'        # el resumen del día
)                                                  # fin de las carpetas

# la carpeta de Drive de cada etapa; vacía si no está en .secrets/.Renviron
ids_drive <- Sys.getenv(paste0('GDRIVE_ID_', names(carpetas)))

# solo las etapas que tienen carpeta de Drive
carpetas <- carpetas[nzchar(ids_drive)]

# y sus ids, en el mismo orden
ids_drive <- ids_drive[nzchar(ids_drive)]



# Cargar datos -----------------------------------------------------------------

# los .RData de cada etapa, con el id de Drive al que van
archivos <- map2_dfr(
  carpetas,                                        # cada carpeta de data/
  ids_drive,                                       # su carpeta de Drive
  ~ tibble(                                        # una fila por archivo
    # el archivo
    archivo  = list.files(.x, '\\.RData$', recursive = TRUE, full.names = TRUE),
    id_drive = .y                                  # a dónde va
  )                                                # fin del tibble
)                                                  # fin de map2_dfr()



# Subir a Drive ----------------------------------------------------------------

# con la fecha en el nombre: cada día deja su foto y no pisa la anterior
fecha <- format(Sys.time(), '%Y-%m-%d')

# sube cada archivo a la carpeta de su etapa
walk2(
  archivos$archivo,                                # el archivo local
  archivos$id_drive,                               # la carpeta de Drive
  ~ googledrive::drive_upload(                     # sube un archivo
    .x,                                            # el archivo
    path      = googledrive::as_id(.y),            # la carpeta
    # con la fecha
    name      = sub('\\.RData$', paste0('_', fecha, '.RData'), basename(.x)),
    overwrite = TRUE                               # pisa la foto del mismo día
  )                                                # fin de drive_upload()
)                                                  # fin de walk2()

# borra todo: el script siguiente arranca de cero
rm(list = ls())
