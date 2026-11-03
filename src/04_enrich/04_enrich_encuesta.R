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
# LEE: data/03_clean/<ronda>/                                                  #
# ESCRIBE: data/04_enrich/<ronda>/<proyecto>_encuesta_enrich.RData y su _hist  #
#-----------------------------------------------------------------------------.#

# 0. Setup ---------------------------------------------------------------------

# borra lo que haya en memoria: el script no depende de otro
rm(list = ls())

# los paquetes y las funciones compartidas
source('src/00_setup/packages.R')
source('src/00_setup/functions.R')

# el prefijo de los archivos y la ronda a procesar: la "activa" de
# sources/rondas.csv, o la que diga RONDA en .secrets/.Renviron
proyecto <- env_requerido('NOMBRE_PROYECTO')
ronda    <- ronda_activa()$ronda


# 1. Cargar --------------------------------------------------------------------

load(file.path(
  'data/03_clean', ronda, paste0(proyecto, '_encuesta_clean.RData')
))

# copia de trabajo: la base limpia queda intacta para comparar
encuesta <- encuesta_clean


# 2. Separar lo que ya se enriqueció -------------------------------------------

# el historial (_encuesta_enrich_hist.RData) guarda lo ya procesado: solo
# se procesa lo nuevo o lo que cambió, así correr de nuevo no repite (ni
# vuelve a pagar) lo que ya se hizo


# 3. Enriquecer: clasificar con IA las respuestas abiertas ---------------------

# la información que la fuente no trae, para los registros nuevos


# 4. Unir al historial ---------------------------------------------------------

# lo nuevo se suma al historial y se une a la base por su llave

encuesta_enrich      <- encuesta
encuesta_enrich_hist <- encuesta_enrich


# 5. Guardar en data/04_enrich -------------------------------------------------

# la carpeta de salida se crea si no existe
carpeta_salida <- file.path('data/04_enrich', ronda)
dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)

save(
  encuesta_enrich,
  file = file.path(carpeta_salida, paste0(proyecto, '_encuesta_enrich.RData'))
)
save(
  encuesta_enrich_hist,
  file = file.path(
    carpeta_salida,
    paste0(proyecto, '_encuesta_enrich_hist.RData')
  )
)

rm(list = ls())
