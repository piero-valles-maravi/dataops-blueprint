#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 04_enrich_encuesta                                                   #
# DETALLE: agrega a la encuesta información que no trae: clasificación con IA  #
#   de las respuestas abiertas. Es idempotente: no vuelve a procesar (ni a     #
#   pagar) lo que no cambió. Etapa opcional. EJEMPLO: renombrar o borrar según #
#   las fuentes del proyecto.                                                  #
#                                                                              #
# CORRE DESPUES DE: 03_clean_encuesta                                          #
# LEE: data/03_clean/ronda_1/                                                  #
# ESCRIBE: data/04_enrich/ronda_1/proyecto_ronda_1_encuesta_enrich.RData y     #
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

# la encuesta limpia
load(ruta_base(
  '03_clean',                                      # la etapa: carpeta en data/
  'encuesta_clean'                                 # la base que se carga
))                                                 # fin de load()

# el objeto de trabajo: la base limpia queda intacta para comparar
encuesta_enriqueciendo <- encuesta_clean



# Separar lo que ya se enriqueció ----------------------------------------------

# el historial (encuesta_enrich_hist) guarda lo ya procesado: solo se
# procesa lo nuevo o lo que cambió, así correr de nuevo no repite (ni vuelve
# a pagar) lo que ya se hizo



# Enriquecer: IA en las respuestas abiertas ------------------------------------

# la información que la fuente no trae, solo para los registros nuevos



# Unir al historial ------------------------------------------------------------

# lo nuevo se suma al historial y se une a la base por su llave

# el historial actualizado
encuesta_enrich_hist <- encuesta_enriqueciendo



# Guardar encuesta_enrich ------------------------------------------------------

# la salida del script, con el objeto del mismo nombre que el archivo
encuesta_enrich <- encuesta_enriqueciendo

# en .RData, .sav, .dta, .xlsx, .csv y un Google Sheet, con proyecto y ronda
# en el nombre (src/00_setup/config.R)
guardar_etapa(
  'encuesta_enrich',                               # el objeto, entre comillas
  '04_enrich'                                      # la etapa: carpeta en data/
)                                                  # fin de guardar_etapa()



# Guardar encuesta_enrich_hist -------------------------------------------------

# en .RData, .sav, .dta, .xlsx, .csv y un Google Sheet, con proyecto y ronda
# en el nombre (src/00_setup/config.R)
guardar_etapa(
  'encuesta_enrich_hist',                          # el objeto, entre comillas
  '04_enrich'                                      # la etapa: carpeta en data/
)                                                  # fin de guardar_etapa()

# borra todo: el script siguiente arranca de cero
rm(list = ls())
