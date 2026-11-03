#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 08_products_informe                                                  #
# DETALLE: arma el informe de avance o de resultados para una persona: tablas  #
#   y figuras de outputs/07_analysis más los indicadores de la base final. No  #
#   calcula modelos. EJEMPLO: renombrar o borrar según las fuentes del         #
#   proyecto.                                                                  #
#                                                                              #
# CORRE DESPUES DE: 07_analysis (o 06_indicators)                              #
# LEE: data/06_final/ y outputs/07_analysis/                                   #
# ESCRIBE: outputs/08_products/informe/informe_<aaaa-mm-dd>.docx               #
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

load(file.path('data/06_final', paste0(proyecto, '_final.RData')))

# las tablas y figuras ya guardadas por 07_analysis: acá no se recalculan
figuras <- list.files('outputs/07_analysis/figuras', full.names = TRUE)


# 2. Armar el informe ----------------------------------------------------------

# un Word con officer: título, indicadores principales, tablas y figuras
informe <- officer::read_docx() |>
  officer::body_add_par(paste('Informe', proyecto), style = 'heading 1')


# 3. Guardar en outputs/08_products/informe ------------------------------------

carpeta_salida <- 'outputs/08_products/informe'
dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)

print(
  informe,
  target = file.path(carpeta_salida, paste0('informe_', Sys.Date(), '.docx'))
)

rm(list = ls())
