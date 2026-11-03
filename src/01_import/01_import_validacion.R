#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 01_import_validacion                                                 #
# DETALLE: descarga las decisiones humanas: la validación de las supervisoras  #
#   y las correcciones que tienen datos personales. Son una fuente más:        #
#   02_audit aplica los veredictos y las correcciones. EJEMPLO: renombrar o    #
#   borrar según las fuentes del proyecto.                                     #
#                                                                              #
# CORRE DESPUES DE: 00_setup                                                   #
# LEE: el Sheet de validación                                                  #
# ESCRIBE: data/01_raw/ronda_1/proyecto_ronda_1_validaciones_raw.RData y       #
#   proyecto_ronda_1_correcciones_raw.RData                                    #
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



# Descargar las decisiones humanas ---------------------------------------------

# el Sheet de validación de las supervisoras
id_validacion <- env_requerido('GSHEET_ID_VALIDACION')

# los veredictos sobre las encuestas con alerta
validaciones_raw <- googlesheets4::read_sheet(
  id_validacion,                                   # el Sheet de validación
  sheet     = 'validacion',                        # la pestaña de veredictos
  col_types = 'c'                                  # todo como texto
)                                                  # fin de read_sheet()

# las correcciones que no van en sources/ porque tienen datos personales
correcciones_raw <- googlesheets4::read_sheet(
  id_validacion,                                   # el Sheet de validación
  sheet     = 'correcciones',                      # la pestaña de correcciones
  col_types = 'c'                                  # todo como texto
)                                                  # fin de read_sheet()



# Guardar validaciones_raw -----------------------------------------------------

# en .RData, .sav, .dta, .xlsx, .csv y un Google Sheet, con proyecto y ronda
# en el nombre (src/00_setup/config.R)
guardar_etapa(
  'validaciones_raw',                              # el objeto, entre comillas
  '01_raw'                                         # la etapa: carpeta en data/
)                                                  # fin de guardar_etapa()



# Guardar correcciones_raw -----------------------------------------------------

# en .RData, .sav, .dta, .xlsx, .csv y un Google Sheet, con proyecto y ronda
# en el nombre (src/00_setup/config.R)
guardar_etapa(
  'correcciones_raw',                              # el objeto, entre comillas
  '01_raw'                                         # la etapa: carpeta en data/
)                                                  # fin de guardar_etapa()

# borra todo: el script siguiente arranca de cero
rm(list = ls())
