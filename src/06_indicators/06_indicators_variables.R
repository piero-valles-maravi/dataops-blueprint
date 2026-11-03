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
# LEE: data/05_integrate/<proyecto>_integrate.RData                            #
# ESCRIBE: data/06_final/<proyecto>_final.RData                                #
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

load(file.path('data/05_integrate', paste0(proyecto, '_integrate.RData')))

# copia de trabajo: la base integrada queda intacta para comparar
final <- integrate


# 2. Variables derivadas -------------------------------------------------------

# recodificaciones y variables que se calculan a partir de otras


# 3. Indicadores y scores ------------------------------------------------------

# los indicadores del proyecto, cada uno con su definición en un comentario


# 4. Ponderadores --------------------------------------------------------------

# si el diseño muestral los tiene


# 5. Guardar en data/06_final --------------------------------------------------

# la carpeta de salida se crea si no existe
carpeta_salida <- 'data/06_final'
dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)

save(
  final,
  file = file.path(carpeta_salida, paste0(proyecto, '_final.RData'))
)

rm(list = ls())
