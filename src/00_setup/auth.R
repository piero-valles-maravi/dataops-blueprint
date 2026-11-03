#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: auth                                                                 #
# DETALLE: carga las credenciales y autentica Drive y Sheets con la cuenta de  #
#   servicio. Sin navegador, sin ventana y sin token cacheado de una persona:  #
#   el mismo camino en local y en GitHub Actions. Lo cargan solo los scripts   #
#   que usan credenciales (01_import, 09_publish y los que llaman a una API).  #
#                                                                              #
# CORRE DESPUES DE: functions (usa env_requerido)                              #
# LEE: .secrets/.Renviron y la clave .json de .secrets/                        #
# ESCRIBE: nada                                                                #
#-----------------------------------------------------------------------------.#

# 0. Cargar las variables de .secrets/.Renviron -------------------------------

# Al arrancar, R solo busca el .Renviron de la raíz y el de la carpeta personal,
# así que el de .secrets/ se carga a mano. Leerlo en cada corrida tiene una
# ventaja: después de editarlo no hace falta reiniciar R. Lo que trae pisa las
# variables con el mismo nombre que ya estuvieran cargadas.
#
# En GitHub Actions el archivo no existe y no hace falta: las mismas variables
# llegan como secrets del repositorio, con el mismo nombre.
ruta_renviron <- '.secrets/.Renviron'

if (file.exists(ruta_renviron)) {

  readRenviron(ruta_renviron)

} else if (!nzchar(Sys.getenv('GITHUB_ACTIONS'))) {

  stop(
    'No se encontró ', ruta_renviron, '. Copia .secrets/.Renviron.example ',
    'como .secrets/.Renviron y completa los valores. Si el archivo existe, ',
    'el script no se está corriendo desde la raíz del proyecto.'
  )

}


# 1. Ubicar la clave de la cuenta de servicio ---------------------------------

# En local es el .json descargado de Google Cloud; en GitHub Actions es el que
# el workflow escribe con el contenido del secret GOOGLE_SERVICE_ACCOUNT_JSON y
# borra al terminar. En los dos casos la ruta sale de la misma variable.
ruta_cuenta_servicio <- env_requerido('GOOGLE_SERVICE_ACCOUNT_KEY')

if (!file.exists(ruta_cuenta_servicio)) {

  stop(
    'No se encontró la clave de la cuenta de servicio en: ',
    ruta_cuenta_servicio,
    '. Revisa GOOGLE_SERVICE_ACCOUNT_KEY en .secrets/.Renviron.'
  )

}


# 2. Verificar que sea una clave de cuenta de servicio ------------------------

# Dos errores comunes dan mensajes confusos de la API: un secret vacío en
# GitHub (el workflow escribe un archivo vacío) y un .json de "cliente OAuth"
# en lugar de una clave de cuenta de servicio. Se revisa antes de autenticar.
# Solo se lee el tipo y el correo; ningún otro campo se imprime.
clave <- tryCatch(
  jsonlite::read_json(ruta_cuenta_servicio),
  error = function(e) NULL
)

if (is.null(clave) || !identical(clave$type, 'service_account')) {

  stop(
    'El archivo ', ruta_cuenta_servicio, ' no es una clave de cuenta de ',
    'servicio. En local: descargarla de Google Cloud (Cuentas de servicio > ',
    'Claves > Agregar clave > JSON). En GitHub: revisar que el secret ',
    'GOOGLE_SERVICE_ACCOUNT_JSON tenga el contenido completo del .json.'
  )

}

correo_cuenta_servicio <- clave$client_email
rm(clave)


# 3. Nada de flujo interactivo -------------------------------------------------

# Con la caché apagada gargle no puede guardar ni reusar el token OAuth de una
# persona: si la cuenta de servicio falla, el script corta en vez de abrir el
# navegador y quedarse esperando a alguien que en un runner no existe.
options(
  gargle_oauth_cache = FALSE,
  gargle_oauth_email = NA
)


# 4. Autenticar Drive y Sheets -------------------------------------------------

# Los dos paquetes llevan su propio token, así que se autentican por separado
# aunque la credencial sea la misma. Si el proyecto no usa uno de los dos, se
# borra su línea.
#
# Autenticar ya pide el token a Google: si la clave fue borrada o revocada, el
# script corta acá y no a mitad de una descarga.
tryCatch(
  {
    googledrive::drive_auth(path = ruta_cuenta_servicio)
    googlesheets4::gs4_auth(path = ruta_cuenta_servicio)
  },
  error = function(e) stop(
    'Google no aceptó la clave de ', correo_cuenta_servicio, '. La clave ',
    'pudo ser borrada o revocada en Google Cloud: hay que generar una nueva. ',
    'Si es la correcta, revisar la conexión a internet.',
    call. = FALSE
  )
)


# 5. Confirmar con qué identidad quedó -----------------------------------------

# El correo de la cuenta de servicio es el que hay que compartir en cada Sheet y
# en cada carpeta de Drive: sin eso la API responde 403 y no es un problema de
# credencial sino de permiso.
cat('Google autenticado como:', correo_cuenta_servicio, '\n')
