#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 07_analysis_modelo                                                   #
# DETALLE: estima el modelo o el índice del proyecto (regresión, conjoint, Van #
#   Westendorp, índice compuesto). Lee SOLO de data/06_final. Guarda           #
#   estimaciones y figuras. Etapa opcional. EJEMPLO: renombrar o borrar según  #
#   las fuentes del proyecto.                                                  #
#                                                                              #
# CORRE DESPUES DE: 06_indicators                                              #
# LEE: data/06_final/                                                          #
# ESCRIBE: outputs/07_analysis/tablas/ y figuras/, con el prefijo modelo_      #
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

# las tablas y las figuras van en carpetas separadas
carpeta_tablas  <- 'outputs/07_analysis/tablas'    # Output
carpeta_figuras <- 'outputs/07_analysis/figuras'   # Output

# crea las dos carpetas de salida si no existen
walk(
  c(carpeta_tablas, carpeta_figuras),              # las dos carpetas
  dir.create,                                      # las crea
  recursive    = TRUE,                             # con las carpetas de arriba
  showWarnings = FALSE                             # sin aviso si ya existen
)                                                  # fin de walk()



# Cargar datos -----------------------------------------------------------------

# la base final analítica
load(ruta_base(
  '06_final',                                      # la etapa: carpeta en data/
  'final'                                          # la base que se carga
))                                                 # fin de load()



# Estimar ----------------------------------------------------------------------

# el modelo o el índice del proyecto: regresión, conjoint, Van Westendorp,
# índice compuesto. Las estimaciones van a la lista de tablas
tablas <- list()



# Figuras ----------------------------------------------------------------------

# lista nombrada de ggplot: el nombre es el del archivo
figuras <- list()



# Guardar modelo ---------------------------------------------------------------

# todas las tablas en un Excel, una pestaña por tabla
writexl::write_xlsx(
  tablas,                                          # la lista de tablas
  # el archivo
  file.path(carpeta_tablas, paste0(proyecto, '_modelo_tablas.xlsx'))
)                                                  # fin de write_xlsx()

# cada figura en su PNG, con el nombre de la lista
iwalk(
  figuras,                                         # la lista de figuras
  ~ ggsave(                                        # guarda una figura
    file.path(                                     # el archivo
      carpeta_figuras,                             # en la carpeta de figuras
      paste0(proyecto, '_modelo_', .y, '.png')     # con el nombre de la lista
    ),                                             # fin de file.path()
    .x,                                            # la figura
    width  = 8,                                    # ancho en pulgadas
    height = 5,                                    # alto en pulgadas
    dpi    = 300                                   # resolución para imprimir
  )                                                # fin de ggsave()
)                                                  # fin de iwalk()

# borra todo: el script siguiente arranca de cero
rm(list = ls())
