#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 04_enrich_registro                                                   #
# DETALLE: agrega al registro columnas nuevas a partir de lo que ya trae: una  #
#   variable derivada o lo que la IA lee de un documento. Idempotente. EJEMPLO:#
#   renombrar o borrar según las fuentes del proyecto.                         #
#                                                                              #
# CORRE DESPUES DE: 03_clean_registro                                          #
# LEE: data/03_clean/ronda_1/                                                  #
# ESCRIBE: data/04_enrich/ronda_1/proyecto_ronda_1_registro_enrich.RData y     #
#   su _hist                                                                   #
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



# Cargar datos -----------------------------------------------------------------

# la registro limpia
load(ruta_base(
  '03_clean',                                      # la etapa: carpeta en data/
  'registro_clean'                                 # la base que se carga
))                                                 # fin de load()

# el objeto de trabajo: la base limpia queda intacta para comparar
registro_enriqueciendo <- registro_clean



# Separar lo que ya se enriqueció ----------------------------------------------

# el historial (registro_enrich_hist) guarda lo ya procesado: solo se
# procesa lo nuevo o lo que cambió, así correr de nuevo no repite (ni vuelve
# a pagar) lo que ya se hizo



# Enriquecer: geocodificar o sumar datos de una API ----------------------------

# la información que la fuente no trae, solo para los registros nuevos



# Unir al historial ------------------------------------------------------------

# lo nuevo se suma al historial y se une a la base por su llave

# el historial actualizado
registro_enrich_hist <- registro_enriqueciendo



# Guardar registro_enrich ------------------------------------------------------

# la salida del script, con el objeto del mismo nombre que el archivo
registro_enrich <- registro_enriqueciendo

# en .RData, .sav, .dta, .xlsx, .csv y un Google Sheet, con proyecto y ronda
# en el nombre (src/00_setup/config.R)
guardar_etapa(
  'registro_enrich',                               # el objeto, entre comillas
  '04_enrich'                                      # la etapa: carpeta en data/
)                                                  # fin de guardar_etapa()



# Guardar registro_enrich_hist -------------------------------------------------

# en .RData, .sav, .dta, .xlsx, .csv y un Google Sheet, con proyecto y ronda
# en el nombre (src/00_setup/config.R)
guardar_etapa(
  'registro_enrich_hist',                          # el objeto, entre comillas
  '04_enrich'                                      # la etapa: carpeta en data/
)                                                  # fin de guardar_etapa()

# borra todo: el script siguiente arranca de cero
rm(list = ls())
