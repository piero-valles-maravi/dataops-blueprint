#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 06_indicators_variables                                              #
# DETALLE: crea las variables derivadas, indicadores y scores sobre la base    #
#   integrada. Deja la base final analítica: la que leen el análisis y los     #
#   productos. EJEMPLO: renombrar o borrar según las fuentes del proyecto.     #
#                                                                              #
# CORRE DESPUES DE: 05_integrate (o la última etapa que exista)                #
# LEE: data/05_integrate/proyecto_integrate.RData                              #
# ESCRIBE: data/06_final/proyecto_final.RData                                  #
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



# Cargar datos -----------------------------------------------------------------

# la base integrada, con su llave única
load(ruta_base(
  '05_integrate',                                  # la etapa: carpeta en data/
  'integrate'                                      # la base que se carga
))                                                 # fin de load()

# el objeto de trabajo: la base integrada queda intacta para comparar
final_calculando <- integrate



# Variables derivadas ----------------------------------------------------------

# recodificaciones y variables que se calculan a partir de otras



# Indicadores y scores ---------------------------------------------------------

# los indicadores del proyecto, cada uno con su definición en un comentario



# Ponderadores -----------------------------------------------------------------

# si el diseño muestral los tiene



# Guardar final ----------------------------------------------------------------

# la salida del script, con el objeto del mismo nombre que el archivo
final <- final_calculando

# en .RData, .sav, .dta, .xlsx, .csv y un Google Sheet, con proyecto y ronda
# en el nombre (src/00_setup/config.R)
guardar_etapa(
  'final',                                         # el objeto, entre comillas
  '06_final'                                       # la etapa: carpeta en data/
)                                                  # fin de guardar_etapa()

# borra todo: el script siguiente arranca de cero
rm(list = ls())
