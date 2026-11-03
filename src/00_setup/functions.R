#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: functions                                                            #
# DETALLE: solo funciones compartidas, numeradas por tema. Cargarlo NO ejecuta #
#   nada ni toca la red. Las primeras son: env_requerido(), ronda_activa(),    #
#   leer_instrumento(), leer_etapa() y guardar_etapa().                        #
#                                                                              #
# CORRE DESPUES DE: packages                                                   #
# LEE: nada                                                                    #
# ESCRIBE: nada                                                                #
#-----------------------------------------------------------------------------.#


# 1. Leer una variable de entorno ----------------------------------------------

# Ningún identificador ni credencial se escribe en un script: todo sale de
# .secrets/.Renviron (lo carga auth.R) y en GitHub Actions de los secrets del
# repositorio. Sys.getenv() los lee igual en los dos casos, así que hay un solo
# camino que mantener.
#
# Si falta la variable, el error nombra cuál es y dónde ponerla, en vez de
# fallar más adelante con un 404 o un id vacío. Nunca se imprime el valor.
env_requerido <- function(nombre) {

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

  valor <- Sys.getenv(nombre)

  if (nzchar(valor)) valor else NULL

}
