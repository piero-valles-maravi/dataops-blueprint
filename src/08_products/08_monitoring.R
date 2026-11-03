#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 08_monitoring                                                        #
# DETALLE: tablas del flujo de monitoreo por hora (hourly.yml): avance, cuotas #
#   y alertas por encuestador para Looker, y la lista de encuestas con alerta  #
#   para la validación de las supervisoras. Es la ÚNICA excepción a la         #
#   frontera: lee de data/03_clean porque mide el campo mientras ocurre, con   #
#   todos los intentos y sus alertas. Con varias tablas:                       #
#   08_monitoring_<tabla>.R                                                    #
#                                                                              #
# CORRE DESPUES DE: 03_clean                                                   #
# LEE: data/03_clean/<ronda>/                                                  #
# ESCRIBE: outputs/08_products/monitoreo/                                      #
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

# la ÚNICA excepción a la frontera: lee la base limpia sin filtrar, con todos
# los intentos y sus alertas, porque mide el campo mientras ocurre
load(file.path(
  'data/03_clean', ronda, paste0(proyecto, '_encuesta_clean.RData')
))


# 2. Avance y cuotas -----------------------------------------------------------

# encuestas completas por día, por zona y contra la meta de cada cuota


# 3. Alertas por encuestador ---------------------------------------------------

# cuántas alertas tiene cada encuestador, por dimensión


# 4. Encuestas para validar ----------------------------------------------------

# las encuestas con alerta que todavía no tienen veredicto: van al Sheet de
# validación de las supervisoras

# lista nombrada: el nombre de cada tabla es el de su pestaña en el Sheet que
# lee Looker, así que no se cambia sin cambiar el Looker
monitoreo <- list()


# 5. Guardar en outputs/08_products/monitoreo ----------------------------------

carpeta_salida <- 'outputs/08_products/monitoreo'
dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)

save(
  monitoreo,
  file = file.path(carpeta_salida, paste0(proyecto, '_monitoreo.RData'))
)

rm(list = ls())
