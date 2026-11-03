#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 08_monitoring_daily                                                  #
# DETALLE: el resumen del día (daily.yml): encuestas del día por encuestador   #
#   y por zona, y las alertas que quedaron abiertas, para el cierre de la      #
#   jornada. Como el monitoreo por hora, lee de data/03_clean porque mide el   #
#   campo mientras ocurre.                                                     #
#                                                                              #
# CORRE DESPUES DE: 03_clean                                                   #
# LEE: data/03_clean/ronda_1/                                                  #
# ESCRIBE: outputs/08_monitoring/daily/                                        #
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



# Rutas y carpetas -------------------------------------------------------------

# dónde escribe
carpeta_salida <- 'outputs/08_monitoring/daily'    # Output

# crea la carpeta de salida si no existe
dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)



# Cargar datos -----------------------------------------------------------------

# como el monitoreo por hora, lee la base limpia sin filtrar: mide el campo
load(ruta_base(
  '03_clean',                                      # la etapa: carpeta en data/
  'encuesta_clean'                                 # la base que se carga
))                                                 # fin de load()



# Encuestas del día ------------------------------------------------------------

# cuántas encuestas se hicieron hoy, por encuestador y por zona



# Alertas abiertas -------------------------------------------------------------

# las alertas que quedaron sin veredicto al cierre de la jornada

# lista nombrada: el resumen del día, una tabla por elemento
monitoreo <- list()



# Guardar monitoreo ------------------------------------------------------------

# el nombre con proyecto y ronda, igual que la base limpia que lee
archivo_monitoreo <- paste0(
  nombre_base('03_clean', 'monitoreo_daily'),      # proyecto, ronda y nombre
  '.RData'                                         # la extensión
)                                                  # fin de paste0()

# la lista de tablas en un solo archivo: la sube 09_publish_drive
save(
  monitoreo,                                       # el resumen del día
  # el archivo
  file = file.path(carpeta_salida, archivo_monitoreo)
)                                                  # fin de save()

# borra todo: el script siguiente arranca de cero
rm(list = ls())
