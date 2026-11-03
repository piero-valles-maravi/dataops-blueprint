#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 08_products_entrega                                                  #
# DETALLE: arma la entrega al cliente: la base de entrega en .xlsx, .csv y     #
#   .dta, con su diccionario de variables. No modifica los datos. EJEMPLO:     #
#   renombrar o borrar según las fuentes del proyecto.                         #
#                                                                              #
# CORRE DESPUES DE: 06_indicators_entrega                                      #
# LEE: data/06_final/proyecto_entrega.RData y                                  #
#   sources/01_instrumento/                                                    #
# ESCRIBE: outputs/08_products/entrega/entrega_<aaaa-mm-dd>/                   #
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

# una carpeta por fecha de entrega: las anteriores quedan como estaban
carpeta_salida <- file.path(
  'outputs/08_products/entrega',                   # la carpeta de entregas
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
