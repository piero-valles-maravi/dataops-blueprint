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
# ESCRIBE: outputs/08_products/informe/                                        #
#   proyecto_informe_<aaaa-mm-dd>.docx                                         #
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

# dónde escribe
carpeta_salida <- 'outputs/08_products/informe'    # Output

# crea la carpeta de salida si no existe
dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)



# Cargar datos -----------------------------------------------------------------

# la base final analítica
load(ruta_base(
  '06_final',                                      # la etapa: carpeta en data/
  'final'                                          # la base que se carga
))                                                 # fin de load()

# las figuras ya guardadas por 07_analysis: acá no se recalculan
figuras <- list.files('outputs/07_analysis/figuras', full.names = TRUE)



# Armar el informe -------------------------------------------------------------

# un Word con officer: título, indicadores principales, tablas y figuras
informe <- officer::read_docx() %>%
  officer::body_add_par(                           # agrega el título
    'Informe',                                     # el texto
    style = 'heading 1'                            # con estilo de título
  )                                                # fin de body_add_par()



# Guardar informe --------------------------------------------------------------

# con la fecha en el nombre: cada informe queda y no pisa el anterior
print(
  informe,                                         # el documento
  target = file.path(                              # el archivo
    carpeta_salida,                                # en la carpeta del informe
    # con la fecha
    paste0(proyecto, '_informe_', Sys.Date(), '.docx')
  )                                                # fin de file.path()
)                                                  # fin de print()

# borra todo: el script siguiente arranca de cero
rm(list = ls())
