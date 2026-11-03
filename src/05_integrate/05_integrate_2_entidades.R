#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 05_integrate_2_entidades                                             #
# DETALLE: resuelve quién es quién: une los registros de la misma persona,     #
#   hogar o entidad entre fuentes y rondas, y deja una llave única. Acá NO se  #
#   crean indicadores. EJEMPLO: renombrar o borrar según las fuentes del       #
#   proyecto.                                                                  #
#                                                                              #
# CORRE DESPUES DE: 05_integrate_1_apilar                                      #
# LEE: data/05_integrate/proyecto_apilada.RData                                #
# ESCRIBE: data/05_integrate/proyecto_integrate.RData                          #
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

# todas las fuentes y rondas, una debajo de otra
load(ruta_base(
  '05_integrate',                                  # la etapa: carpeta en data/
  'apilada'                                        # la base que se carga
))                                                 # fin de load()

# el objeto de trabajo: la base apilada queda intacta para comparar
integrando <- apilada



# Resolver entidades -----------------------------------------------------------

# une los registros de la misma persona, hogar o entidad entre fuentes y
# rondas (documento, teléfono, nombre normalizado) y deja una llave única



# Guardar integrate ------------------------------------------------------------

# la salida del script, con el objeto del mismo nombre que el archivo
integrate <- integrando

# en .RData, .sav, .dta, .xlsx, .csv y un Google Sheet, con proyecto y ronda
# en el nombre (src/00_setup/config.R)
guardar_etapa(
  'integrate',                                     # el objeto, entre comillas
  '05_integrate'                                   # la etapa: carpeta en data/
)                                                  # fin de guardar_etapa()

# borra todo: el script siguiente arranca de cero
rm(list = ls())
