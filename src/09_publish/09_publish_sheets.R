#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 09_publish_sheets                                                    #
# DETALLE: lleva las tablas a los Google Sheets. En el monitoreo por hora      #
#   (hourly.yml): las tablas de 08_monitoring al Sheet que lee Looker Studio,  #
#   y las encuestas nuevas con alerta al Sheet de validación de las            #
#   supervisoras. En el pipeline completo (completo.yml): las tablas del       #
#   dashboard de resultados. Esquema de columnas fijo, para que Looker no se   #
#   rompa. No calcula nada.                                                    #
#                                                                              #
# CORRE DESPUES DE: 08_monitoring (por hora) u 08_products (completo)          #
# LEE: outputs/08_products/                                                    #
# ESCRIBE: GSHEET_ID_MONITOREO, GSHEET_ID_VALIDACION y GSHEET_ID_DASHBOARD     #
#-----------------------------------------------------------------------------.#

# 0. Setup ---------------------------------------------------------------------

# borra lo que haya en memoria: el script no depende de otro
rm(list = ls())

# los paquetes, las funciones y las credenciales (.secrets/.Renviron)
source('src/00_setup/packages.R')
source('src/00_setup/functions.R')
source('src/00_setup/auth.R')

# el prefijo de los archivos
proyecto <- env_requerido('NOMBRE_PROYECTO')


# 1. Monitoreo: el Sheet que lee Looker ----------------------------------------

# solo si 08_monitoring dejó sus tablas (monitoreo por hora). Cada tabla pisa
# su pestaña con el mismo esquema de columnas, para que Looker no se rompa
archivo_monitoreo <- file.path('outputs/08_products/monitoreo',
                               paste0(proyecto, '_monitoreo.RData'))

if (file.exists(archivo_monitoreo)) {

  load(archivo_monitoreo)

  purrr::iwalk(monitoreo, function(tabla, pestana) {
    googlesheets4::sheet_write(
      tabla, ss = env_requerido('GSHEET_ID_MONITOREO'), sheet = pestana
    )
  })

}


# 2. Validación: las encuestas nuevas con alerta -------------------------------

# se AGREGAN al Sheet de validación, nunca se pisa: ahí están las decisiones
# de las supervisoras. Solo las que todavía no están en el Sheet


# 3. Dashboard de resultados ---------------------------------------------------

# solo en el pipeline completo, si el proyecto tiene dashboard de resultados
id_dashboard <- env_opcional('GSHEET_ID_DASHBOARD')


rm(list = ls())
