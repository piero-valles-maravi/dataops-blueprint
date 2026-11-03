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
# LEE: data/05_integrate/<proyecto>_apilada.RData                              #
# ESCRIBE: data/05_integrate/<proyecto>_integrate.RData                        #
#-----------------------------------------------------------------------------.#

# 0. Setup ---------------------------------------------------------------------

# borra lo que haya en memoria: el script no depende de otro
rm(list = ls())

# los paquetes y las funciones compartidas
source('src/00_setup/packages.R')
source('src/00_setup/functions.R')

# el prefijo de los archivos
proyecto <- env_requerido('NOMBRE_PROYECTO')


# 1. Cargar --------------------------------------------------------------------

load(file.path('data/05_integrate', paste0(proyecto, '_apilada.RData')))


# 2. Resolver entidades --------------------------------------------------------

# une los registros de la misma persona, hogar o entidad entre fuentes y
# rondas (documento, teléfono, nombre normalizado) y deja una llave única

integrate <- apilada


# 3. Validar -------------------------------------------------------------------

# los contratos de la base: la llave es única y no se perdieron registros


# 4. Guardar en data/05_integrate ----------------------------------------------

# la carpeta de salida se crea si no existe
carpeta_salida <- 'data/05_integrate'
dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)

save(
  integrate,
  file = file.path(carpeta_salida, paste0(proyecto, '_integrate.RData'))
)

rm(list = ls())
