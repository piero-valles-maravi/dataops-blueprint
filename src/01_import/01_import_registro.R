#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 01_import_registro                                                   #
# DETALLE: descarga una segunda fuente: un registro administrativo, un padrón  #
#   o un Sheet del cliente, tal cual llega. Acá NO se filtra ni se corrige     #
#   nada. EJEMPLO: renombrar o borrar según las fuentes del proyecto.          #
#                                                                              #
# CORRE DESPUES DE: 00_setup                                                   #
# LEE: el Sheet, la base o el archivo del registro                             #
# ESCRIBE: data/01_raw/ronda_1/proyecto_ronda_1_registro_raw.RData             #
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



# Descargar el registro --------------------------------------------------------

# EJEMPLO con un Sheet del cliente: si viene de una base de datos (DBI) o de
# una API (httr), se cambia esta llamada. Todo como texto: los tipos se
# arreglan en 03_clean
registro_raw <- googlesheets4::read_sheet(
  env_requerido('GSHEET_ID_REGISTRO'),             # el Sheet del registro
  col_types = 'c'                                  # todo como texto
)                                                  # fin de read_sheet()



# Guardar registro_raw ---------------------------------------------------------

# en .RData, .sav, .dta, .xlsx, .csv y un Google Sheet, con proyecto y ronda
# en el nombre (src/00_setup/config.R)
guardar_etapa(
  'registro_raw',                                  # el objeto, entre comillas
  '01_raw'                                         # la etapa: carpeta en data/
)                                                  # fin de guardar_etapa()

# borra todo: el script siguiente arranca de cero
rm(list = ls())
