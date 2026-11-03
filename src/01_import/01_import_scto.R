#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 01_import_scto                                                       #
# DETALLE: descarga la encuesta de SurveyCTO por la API, tal cual llega. Acá   #
#   NO se filtra ni se corrige nada.                                           #
#                                                                              #
# CORRE DESPUES DE: 00_setup                                                   #
# LEE: la API de SurveyCTO                                                     #
# ESCRIBE: data/01_raw/ronda_1/proyecto_ronda_1_scto_raw.RData                 #
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

# el formulario de la ronda en SurveyCTO; cambia en cada ronda
formid <- '<formid_ronda_1>'

# el subdominio de la organización: <servidor>.surveycto.com
servidor <- env_requerido('SURVEYCTO_SERVER')

# el usuario de SurveyCTO
usuario <- env_requerido('SURVEYCTO_USERNAME')

# la contraseña de SurveyCTO
clave <- env_requerido('SURVEYCTO_PASSWORD')




# Descargar los datos ----------------------------------------------------------

# la ruta de la API; ?date=0 pide todas las encuestas desde el inicio
api_scto <- paste0(
  'https://', servidor, '.surveycto.com',          # el servidor
  '/api/v2/forms/data/wide/json/', formid,         # el formulario, en JSON
  '?date=0'                                        # desde el inicio
)                                                  # fin de paste0()

# pide los datos con el usuario y la contraseña
respuesta <- httr::POST(
  url    = api_scto,                               # la ruta de la API
  config = httr::authenticate(usuario, clave),     # las credenciales
  httr::add_headers('Content-Type: application/json'), # pide JSON
  encode = 'json',                                 # el cuerpo va en JSON
  httr::timeout(300)                               # 5 min antes de darlo caído
)                                                  # fin de POST()

# el texto de la respuesta
contenido <- rawToChar(respuesta$content)

# flatten aplana las columnas anidadas del formulario
scto_raw <- jsonlite::fromJSON(contenido, flatten = TRUE)




# Guardar scto_raw -------------------------------------------------------------

# en .RData, .sav, .dta, .xlsx, .csv y un Google Sheet, con proyecto y ronda
# en el nombre (src/00_setup/config.R)
guardar_etapa(
  'scto_raw',                                      # el objeto que se guarda, entre comillas
  '01_raw'                                         # la etapa: su carpeta en data/
)                                                  # fin de guardar_etapa()

# borra todo: el script siguiente arranca de cero
rm(list = ls())
