#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 04_enrich_registro                                                   #
# DETALLE: agrega al registro información externa: geocodificación de          #
#   direcciones o datos de una API. Idempotente. Etapa opcional. EJEMPLO:      #
#   renombrar o borrar según las fuentes del proyecto.                         #
#                                                                              #
# CORRE DESPUES DE: 03_clean_registro                                          #
# LEE: data/03_clean/<ronda>/                                                  #
# ESCRIBE: data/04_enrich/<ronda>/<proyecto>_registro_enrich.RData y su _hist  #
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
  'data/03_clean', ronda, paste0(proyecto, '_registro_clean.RData')
))

# copia de trabajo: la base limpia queda intacta para comparar
registro <- registro_clean


# 2. Separar lo que ya se enriqueció -------------------------------------------

# el historial (_registro_enrich_hist.RData) guarda lo ya procesado: solo
# se procesa lo nuevo o lo que cambió, así correr de nuevo no repite (ni
# vuelve a pagar) lo que ya se hizo


# 3. Enriquecer: geocodificar direcciones o sumar datos de una API -------------

# la información que la fuente no trae, para los registros nuevos


# 4. Unir al historial ---------------------------------------------------------

# lo nuevo se suma al historial y se une a la base por su llave

registro_enrich      <- registro
registro_enrich_hist <- registro_enrich


# 5. Guardar en data/04_enrich -------------------------------------------------

# la carpeta de salida se crea si no existe
carpeta_salida <- file.path('data/04_enrich', ronda)
dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)

save(
  registro_enrich,
  file = file.path(carpeta_salida, paste0(proyecto, '_registro_enrich.RData'))
)
save(
  registro_enrich_hist,
  file = file.path(
    carpeta_salida,
    paste0(proyecto, '_registro_enrich_hist.RData')
  )
)

rm(list = ls())
