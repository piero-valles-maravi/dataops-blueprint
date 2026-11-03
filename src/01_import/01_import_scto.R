#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 01_import_scto                                                       #
# DETALLE: descarga la encuesta de SurveyCTO por la API, tal cual llega. Acá   #
#   NO se filtra ni se corrige nada. Si la API responde con error, corta sin   #
#   pisar el crudo anterior. El formid de la ronda sale de sources/rondas.csv. #
#                                                                              #
# CORRE DESPUES DE: 00_setup                                                   #
# LEE: la API de SurveyCTO y sources/rondas.csv                                #
# ESCRIBE: data/01_raw/<ronda>/<proyecto>_scto_raw.RData -> scto_raw           #
#-----------------------------------------------------------------------------.#

# 0. Setup ---------------------------------------------------------------------

# borra lo que haya en memoria: el script no depende de otro
rm(list = ls())

# los paquetes, las funciones y las credenciales (.secrets/.Renviron)
source('src/00_setup/packages.R')
source('src/00_setup/functions.R')
source('src/00_setup/auth.R')

# el prefijo de los archivos y las credenciales de SurveyCTO
proyecto <- env_requerido('NOMBRE_PROYECTO')
servidor <- env_requerido('SURVEYCTO_SERVER')   # subdominio de la organización
usuario  <- env_requerido('SURVEYCTO_USERNAME')
clave    <- env_requerido('SURVEYCTO_PASSWORD')


# 1. Elegir la ronda y su formulario -------------------------------------------

# la "activa" de sources/rondas.csv, o la que diga RONDA en .secrets/.Renviron
# para volver a bajar una ronda cerrada. Cada ronda tiene su propio formulario
fila_ronda <- ronda_activa()
ronda      <- fila_ronda$ronda
formid     <- fila_ronda$formid


# 2. Descargar los datos -------------------------------------------------------

# la ruta va partida en dos para no tener que scrollear; ?date=0 pide todas las
# encuestas desde el inicio, no solo las nuevas
api_scto <- paste0(
  'https://', servidor, '.surveycto.com',
  '/api/v2/forms/data/wide/json/', formid, '?date=0'
)

respuesta <- httr::POST(
  url    = api_scto,
  config = httr::authenticate(usuario, clave),
  httr::add_headers('Content-Type: application/json'),
  encode = 'json',
  httr::timeout(300) # un formulario grande tarda: 5 min antes de darlo caído
)

codigo    <- httr::status_code(respuesta)
contenido <- rawToChar(respuesta$content)

# cualquier respuesta que no sea 200 corta sin sobrescribir el crudo anterior.
# 401: usuario o clave; 404: el formid no existe; 417: se pidió la descarga
# completa dos veces en menos de un minuto
if (codigo != 200) {
  stop('SurveyCTO respondió ', codigo, ' para el formulario ', formid, ': ',
       contenido, '\nNo se sobrescribió el crudo de ', ronda, '.')
}

# flatten aplana las columnas anidadas del formulario
scto_raw <- jsonlite::fromJSON(contenido, flatten = TRUE)

# control: tiene que llegar una tabla con filas, no una lista de error
if (!is.data.frame(scto_raw) || nrow(scto_raw) == 0) {
  stop('La respuesta de SurveyCTO no trae encuestas para el formulario ',
       formid, '. No se sobrescribió el crudo de ', ronda, '.')
}


# 3. Guardar en data/01_raw ----------------------------------------------------

# la carpeta de salida se crea si no existe
carpeta_salida <- file.path('data/01_raw', ronda)
dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)

save(
  scto_raw,
  file = file.path(carpeta_salida, paste0(proyecto, '_scto_raw.RData'))
)

cat('SurveyCTO:', nrow(scto_raw), 'encuestas de', ronda, 'guardadas\n')

rm(list = ls())
