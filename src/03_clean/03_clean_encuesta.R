#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 03_clean_encuesta                                                    #
# DETALLE: corrige, normaliza y etiqueta la encuesta, UNA fuente a la vez. Acá #
#   NO se cruza con otras fuentes. Las correcciones salen de                   #
#   sources/03_correcciones/. Es la base que lee el flujo de monitoreo.        #
#   EJEMPLO: renombrar o borrar según las fuentes del proyecto.                #
#                                                                              #
# CORRE DESPUES DE: 02_audit_encuesta                                          #
# LEE: data/02_audit/<ronda>/ y sources/03_correcciones/                       #
# ESCRIBE: data/03_clean/<ronda>/<proyecto>_encuesta_clean.RData               #
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
  'data/02_audit', ronda, paste0(proyecto, '_encuesta_audit.RData')
))

# copia de trabajo: la base auditada queda intacta para comparar
encuesta <- encuesta_audit


# 2. Corregir ------------------------------------------------------------------

# las correcciones de sources/03_correcciones/, cada una con su motivo.
# Nunca se corrige a mano un valor suelto en el código


# 3. Normalizar ----------------------------------------------------------------

# skill_data_cleaning.md: texto (tildes, mayúsculas, espacios), nombres,
# teléfonos, documentos, fechas y categorías "otro, especifique"


# 4. Etiquetar -----------------------------------------------------------------

# etiquetas de variables y valores desde el instrumento (labelled)


# 5. Columnas comunes ----------------------------------------------------------

# las mismas columnas comunes que las demás fuentes, para que 05_integrate
# solo tenga que apilar

encuesta_clean <- encuesta


# 6. Guardar en data/03_clean --------------------------------------------------

# la carpeta de salida se crea si no existe
carpeta_salida <- file.path('data/03_clean', ronda)
dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)

save(
  encuesta_clean,
  file = file.path(carpeta_salida, paste0(proyecto, '_encuesta_clean.RData'))
)

rm(list = ls())
