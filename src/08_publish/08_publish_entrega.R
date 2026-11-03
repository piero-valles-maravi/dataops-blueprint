#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 08_publish_entrega                                                   #
# DETALLE: lleva al cliente la base de entrega en .xlsx, .csv, .dta y .sav,    #
#   con su diccionario de variables, en una carpeta con la fecha y en la       #
#   carpeta de Drive de entregas. No modifica los datos: la base sin datos     #
#   personales la arma 06_indicators_entrega.                                  #
#                                                                              #
# CORRE DESPUES DE: 06_indicators_entrega                                      #
# LEE: data/06_final/proyecto_entrega.RData                                    #
# ESCRIBE: outputs/08_publish/entrega/entrega_<aaaa-mm-dd>/ y                  #
#   GDRIVE_ID_ENTREGAS                                                         #
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

# una carpeta por fecha de entrega: las anteriores quedan como estaban
carpeta_salida <- file.path(
  'outputs/08_publish/entrega',                    # la carpeta de entregas
  paste0('entrega_', Sys.Date())                   # entrega_2026-11-02
)                                                  # Output



# Cargar datos -----------------------------------------------------------------

# la base de entrega, sin datos personales
load(ruta_base(
  '06_final',                                      # la etapa: carpeta en data/
  'entrega'                                        # la base que se carga
))                                                 # fin de load()



# Diccionario de variables -----------------------------------------------------

# nombre y etiqueta de cada variable, desde las etiquetas de 03_clean
diccionario <- tibble(
  variable = names(entrega),                       # el nombre de la variable
  # su etiqueta
  etiqueta = unlist(labelled::var_label(entrega, unlist = TRUE))
)                                                  # fin del tibble



# Guardar entrega --------------------------------------------------------------

# en .RData, .sav, .dta, .xlsx, .csv y un Google Sheet, con proyecto y ronda
# en el nombre (src/00_setup/config.R)
guardar_etapa(
  'entrega',                                       # el objeto, entre comillas
  'entregas',                                      # la etapa: carpeta de Drive
  carpeta_salida                                   # carpeta fuera de data/
)                                                  # fin de guardar_etapa()



# Guardar diccionario ----------------------------------------------------------

# en .RData, .sav, .dta, .xlsx, .csv y un Google Sheet, con proyecto y ronda
# en el nombre (src/00_setup/config.R)
guardar_etapa(
  'diccionario',                                   # el objeto, entre comillas
  'entregas',                                      # la etapa: carpeta de Drive
  carpeta_salida                                   # carpeta fuera de data/
)                                                  # fin de guardar_etapa()

# borra todo: el script siguiente arranca de cero
rm(list = ls())
