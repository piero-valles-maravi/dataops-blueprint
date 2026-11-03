#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 07_analysis_descriptivos                                             #
# DETALLE: calcula los descriptivos y cruces principales, con ponderadores     #
#   si los hay. Lee SOLO de data/06_final. Las tablas y figuras se GUARDAN,    #
#   nunca quedan solo en pantalla. Un script y una carpeta por producto.       #
#   Etapa opcional. EJEMPLO: renombrar o borrar según el proyecto.             #
#                                                                              #
# CORRE DESPUES DE: 06_indicators                                              #
# LEE: data/06_final/                                                          #
# ESCRIBE: outputs/07_analysis/descriptivos/                                   #
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



# Rutas y carpetas -------------------------------------------------------------

# una carpeta por producto: sus tablas y sus figuras van juntas
# Output
carpeta_salida <- 'outputs/07_analysis/descriptivos'

# crea la carpeta de salida si no existe
dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)



# Cargar datos -----------------------------------------------------------------

# la base final analítica
load(ruta_base(
  '06_final',                                      # la etapa: carpeta en data/
  'final'                                          # la base que se carga
))                                                 # fin de load()



# Tablas -----------------------------------------------------------------------

# los descriptivos y cruces principales, con ponderadores si los hay. Lista
# nombrada: el nombre es el de la pestaña del Excel
tablas <- list(
  total = tibble(registros = nrow(final))          # EJEMPLO: cuántos registros
)                                                  # fin de la lista



# Figuras ----------------------------------------------------------------------

# lista nombrada de ggplot: el nombre es el del archivo
figuras <- list()



# Guardar descriptivos ---------------------------------------------------------

# todas las tablas en un Excel, una pestaña por tabla
writexl::write_xlsx(
  tablas,                                          # la lista de tablas
  # el archivo
  file.path(carpeta_salida, paste0(proyecto, '_descriptivos_tablas.xlsx'))
)                                                  # fin de write_xlsx()

# cada figura en su PNG, con el nombre de la lista
iwalk(
  figuras,                                         # la lista de figuras
  ~ ggsave(                                        # guarda una figura
    file.path(                                     # el archivo
      carpeta_salida,                              # en la carpeta del producto
      # con el nombre de la lista
      paste0(proyecto, '_descriptivos_', .y, '.png')
    ),                                             # fin de file.path()
    .x,                                            # la figura
    width  = 8,                                    # ancho en pulgadas
    height = 5,                                    # alto en pulgadas
    dpi    = 300                                   # resolución para imprimir
  )                                                # fin de ggsave()
)                                                  # fin de iwalk()

# borra todo: el script siguiente arranca de cero
rm(list = ls())
