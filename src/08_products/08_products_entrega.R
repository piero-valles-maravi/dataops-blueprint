#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 08_products_entrega                                                  #
# DETALLE: arma la entrega al cliente: la base de entrega en .xlsx, .csv y     #
#   .dta, con su diccionario de variables. No modifica los datos. EJEMPLO:     #
#   renombrar o borrar según las fuentes del proyecto.                         #
#                                                                              #
# CORRE DESPUES DE: 06_indicators_entrega                                      #
# LEE: data/06_final/<proyecto>_entrega.RData y sources/01_instrumento/        #
# ESCRIBE: outputs/08_products/entrega/entrega_<aaaa-mm-dd>/                   #
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

load(file.path('data/06_final', paste0(proyecto, '_entrega.RData')))


# 2. Diccionario de variables --------------------------------------------------

# nombre, etiqueta y valores de cada variable, desde las etiquetas de
# 03_clean y sources/01_instrumento/
diccionario <- tibble(
  variable = names(entrega),
  etiqueta = unlist(labelled::var_label(entrega, unlist = TRUE))
)


# 3. Guardar en outputs/08_products/entrega ------------------------------------

# una carpeta por fecha de entrega: las anteriores quedan como estaban
carpeta_salida <- file.path('outputs/08_products/entrega',
                            paste0('entrega_', Sys.Date()))
dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)

# la misma base en los tres formatos que suele pedir un cliente
writexl::write_xlsx(
  list(datos = entrega, diccionario = diccionario),
  file.path(carpeta_salida, paste0(proyecto, '.xlsx'))
)
readr::write_csv(entrega, file.path(carpeta_salida, paste0(proyecto, '.csv')))
haven::write_dta(entrega, file.path(carpeta_salida, paste0(proyecto, '.dta')))

rm(list = ls())
