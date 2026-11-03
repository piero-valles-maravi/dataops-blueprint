#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: functions                                                            #
# DETALLE: solo funciones compartidas, numeradas por tema. Cargarlo NO ejecuta #
#   nada ni toca la red. Las primeras son: env_requerido(), env_opcional() y   #
#   ronda_activa().                                                            #
#                                                                              #
# CORRE DESPUES DE: packages                                                   #
# LEE: nada                                                                    #
# ESCRIBE: nada                                                                #
#-----------------------------------------------------------------------------.#


# 1. Leer una variable de entorno ----------------------------------------------

# Ningún identificador ni credencial se escribe en un script: todo sale de
# .secrets/.Renviron y en GitHub Actions de los secrets del repositorio.
# Sys.getenv() los lee igual en los dos casos, así que hay un solo camino que
# mantener.
#
# R no lee solo el .Renviron de .secrets/: si la variable no está cargada y el
# archivo existe, se carga acá. Así lo tienen también las etapas que no cargan
# auth.R (02_audit en adelante).
cargar_renviron <- function(nombre) {

  if (!nzchar(Sys.getenv(nombre)) && file.exists('.secrets/.Renviron')) {
    readRenviron('.secrets/.Renviron')
  }

}

# Si falta la variable, el error nombra cuál es y dónde ponerla, en vez de
# fallar más adelante con un 404 o un id vacío. Nunca se imprime el valor.
env_requerido <- function(nombre) {

  cargar_renviron(nombre)
  valor <- Sys.getenv(nombre)

  if (!nzchar(valor)) {

    stop(
      'Falta la variable ', nombre, ' en .secrets/.Renviron (en GitHub ',
      'Actions, en los secrets del repositorio). La lista completa está en ',
      '.secrets/.Renviron.example.'
    )

  }

  valor

}

# Para las variables que el proyecto puede no usar: devuelve NULL si está vacía
# y el script decide qué hacer sin ella.
env_opcional <- function(nombre) {

  cargar_renviron(nombre)
  valor <- Sys.getenv(nombre)

  if (nzchar(valor)) valor else NULL

}


# 2. Elegir la ronda -----------------------------------------------------------

# Devuelve la fila de sources/rondas.csv de la ronda a procesar: la que diga
# RONDA en .secrets/.Renviron (para volver a procesar una ronda cerrada) o, si
# está vacía, la única que figura como "activa". Con la fila completa el script
# tiene a mano el formid y el instrumento de esa ronda.
ronda_activa <- function() {

  rondas <- read.csv('sources/rondas.csv', stringsAsFactors = FALSE)

  ronda <- env_opcional('RONDA')
  if (is.null(ronda)) ronda <- rondas$ronda[rondas$estado == 'activa']

  # control: tiene que quedar una sola ronda y existir en rondas.csv
  if (length(ronda) != 1 || !ronda %in% rondas$ronda) {
    stop('No hay una única ronda para procesar. Revisar la columna estado de ',
         'sources/rondas.csv (una sola "activa") o la variable RONDA.')
  }

  rondas[rondas$ronda == ronda, ]

}
