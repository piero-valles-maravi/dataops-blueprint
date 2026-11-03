#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 09_publish_sheets                                                    #
# DETALLE: lleva las tablas a los Google Sheets. En el monitoreo por hora      #
#   (hourly.yml): las tablas de 08_monitoring_hourly al Sheet que lee Looker   #
#   Studio, y las encuestas nuevas con alerta al Sheet de validación de las    #
#   supervisoras. En el pipeline completo (completo.yml): las tablas de        #
#   07_analysis al Sheet del dashboard. Esquema de columnas fijo, para que     #
#   Looker no se rompa. No calcula nada.                                       #
#                                                                              #
# CORRE DESPUES DE: 08_monitoring_hourly (por hora) u 07_analysis (completo)   #
# LEE: outputs/08_monitoring/hourly/ y outputs/07_analysis/                    #
# ESCRIBE: GSHEET_ID_MONITOREO, GSHEET_ID_VALIDACION y GSHEET_ID_DASHBOARD     #
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

# las credenciales: .secrets/.Renviron y la cuenta de servicio de Google
source('src/00_setup/auth.R')



# Rutas y carpetas -------------------------------------------------------------

# las tablas del monitoreo que deja 08_monitoring
# Input
carpeta_monitoreo <- 'outputs/08_monitoring/hourly'



# Cargar datos -----------------------------------------------------------------

# sin tablas por defecto: el pipeline completo no corre 08_monitoring_hourly
monitoreo <- list()

# el archivo del monitoreo, si 08_monitoring_hourly lo dejó
archivos_monitoreo <- list.files(
  carpeta_monitoreo,                               # dónde buscar
  pattern    = '_monitoreo_hourly\\.RData$',       # solo el del monitoreo
  full.names = TRUE                                # con la ruta, para cargarlo
)                                                  # fin de list.files()

# carga las tablas: si no hay archivo, monitoreo sigue vacío
walk(archivos_monitoreo, ~ load(.x, envir = globalenv()))



# Monitoreo: el Sheet que lee Looker -------------------------------------------

# cada tabla pisa su pestaña con el mismo esquema de columnas, para que
# Looker no se rompa. Si monitoreo está vacío, no hace nada
iwalk(
  monitoreo,                                       # las tablas del monitoreo
  ~ googlesheets4::sheet_write(                    # escribe una tabla
    .x,                                            # la tabla
    ss    = env_requerido('GSHEET_ID_MONITOREO'),  # el Sheet de Looker
    sheet = .y                                     # la pestaña con su nombre
  )                                                # fin de sheet_write()
)                                                  # fin de iwalk()



# Validación: las encuestas nuevas con alerta ----------------------------------

# se AGREGAN al Sheet de validación, nunca se pisa: ahí están las decisiones
# de las supervisoras. Solo las que todavía no están en el Sheet



# Dashboard de resultados ------------------------------------------------------

# solo en el pipeline completo, si el proyecto tiene dashboard de resultados

# borra todo: el script siguiente arranca de cero
rm(list = ls())
