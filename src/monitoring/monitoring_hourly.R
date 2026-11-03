#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: monitoring_hourly                                                    #
# DETALLE: las tablas del monitoreo por hora (hourly.yml): avance, cuotas y    #
#   alertas por encuestador para Looker, y la lista de encuestas con alerta    #
#   para la validación de las supervisoras. Es la ÚNICA excepción a la         #
#   frontera: lee de data/03_clean porque mide el campo mientras ocurre.       #
#                                                                              #
# CORRE DESPUES DE: 03_clean                                                   #
# LEE: data/03_clean/ronda_1/                                                  #
# ESCRIBE: outputs/monitoring/hourly/                                          #
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
carpeta_salida <- 'outputs/monitoring/hourly'   # Output

# crea la carpeta de salida si no existe
dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)



# Cargar datos -----------------------------------------------------------------

# la ÚNICA excepción a la frontera: lee la base limpia sin filtrar, con todos
# los intentos y sus alertas, porque mide el campo mientras ocurre
load(ruta_base(
  '03_clean',                                      # la etapa: carpeta en data/
  'encuesta_clean'                                 # la base que se carga
))                                                 # fin de load()



# Avance y cuotas --------------------------------------------------------------

# encuestas completas por día, por zona y contra la meta de cada cuota



# Alertas por encuestador ------------------------------------------------------

# cuántas alertas tiene cada encuestador, por dimensión



# Encuestas para validar -------------------------------------------------------

# las encuestas con alerta que todavía no tienen veredicto: van al Sheet de
# validación de las supervisoras

# lista nombrada: el nombre de cada tabla es el de su pestaña en el Sheet que
# lee Looker, así que no se cambia sin cambiar el Looker
monitoreo <- list()



# Guardar monitoreo ------------------------------------------------------------

# el nombre con proyecto y ronda, igual que la base limpia que lee
archivo_monitoreo <- paste0(
  nombre_base('03_clean', 'monitoreo_hourly'),     # proyecto, ronda y nombre
  '.RData'                                         # la extensión
)                                                  # fin de paste0()

# la lista de tablas en un solo archivo: la lee 08_publish_sheets
save(
  monitoreo,                                       # las tablas del monitoreo
  # el archivo
  file = file.path(carpeta_salida, archivo_monitoreo)
)                                                  # fin de save()

# borra todo: el script siguiente arranca de cero
rm(list = ls())
