#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 05_integrate_1_apilar                                                #
# DETALLE: apila las fuentes y las rondas en una sola base, con _fuente y      #
#   _ronda. Funciona porque en 03_clean todas salen con las mismas columnas    #
#   comunes. Acá NO se crean indicadores. Con una sola fuente y una ronda, la  #
#   etapa 05 no existe. EJEMPLO: renombrar o borrar según las fuentes del      #
#   proyecto.                                                                  #
#                                                                              #
# CORRE DESPUES DE: 04_enrich (o 03_clean)                                     #
# LEE: data/04_enrich/ o data/03_clean/, todas las rondas                      #
# ESCRIBE: data/05_integrate/<proyecto>_apilada.RData                          #
#-----------------------------------------------------------------------------.#

# 0. Setup ---------------------------------------------------------------------

# borra lo que haya en memoria: el script no depende de otro
rm(list = ls())

# los paquetes y las funciones compartidas
source('src/00_setup/packages.R')
source('src/00_setup/functions.R')

# el prefijo de los archivos
proyecto <- env_requerido('NOMBRE_PROYECTO')


# 1. Cargar todas las fuentes y rondas -----------------------------------------

# todas las bases de 04_enrich (sin los historiales); si el proyecto no tiene
# 04_enrich, se cambia por data/03_clean y el patrón _clean
archivos <- list.files(
  'data/04_enrich', pattern = '_enrich\\.RData$',
  recursive = TRUE, full.names = TRUE
)

# cada archivo trae un solo objeto: se lee sin saber su nombre
leer_base <- function(archivo) {
  entorno <- new.env()
  load(archivo, envir = entorno)
  entorno[[ls(entorno)[1]]]
}


# 2. Apilar --------------------------------------------------------------------

# _ronda sale de la carpeta y _fuente del nombre del archivo. Funciona porque
# en 03_clean todas las fuentes salen con las mismas columnas comunes
apilada <- purrr::map_dfr(archivos, function(archivo) {
  leer_base(archivo) |>
    mutate(
      `_ronda`  = basename(dirname(archivo)),
      `_fuente` = gsub(paste0('^', proyecto, '_|_enrich\\.RData$'), '',
                       basename(archivo))
    )
})


# 3. Guardar en data/05_integrate ----------------------------------------------

# la carpeta de salida se crea si no existe
carpeta_salida <- 'data/05_integrate'
dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)

save(
  apilada,
  file = file.path(carpeta_salida, paste0(proyecto, '_apilada.RData'))
)

rm(list = ls())
