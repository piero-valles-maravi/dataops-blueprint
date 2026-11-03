#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 03_clean_registro                                                    #
# DETALLE: corrige y normaliza el registro, UNA fuente a la vez, y lo deja con #
#   las mismas columnas comunes que la encuesta para que integrar sea apilar.  #
#   EJEMPLO: renombrar o borrar según las fuentes del proyecto.                #
#                                                                              #
# CORRE DESPUES DE: 02_audit_registro                                          #
# LEE: data/02_audit/<ronda>/ y sources/03_correcciones/                       #
# ESCRIBE: data/03_clean/<ronda>/<proyecto>_registro_clean.RData               #
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
  'data/02_audit', ronda, paste0(proyecto, '_registro_audit.RData')
))

# copia de trabajo: la base auditada queda intacta para comparar
registro <- registro_audit


# 2. Corregir ------------------------------------------------------------------

# las correcciones de sources/03_correcciones/, cada una con su motivo


# 3. Normalizar ----------------------------------------------------------------

# skill_data_cleaning.md: texto, nombres, teléfonos, documentos y fechas


# 4. Columnas comunes ----------------------------------------------------------

# las mismas columnas comunes que la encuesta, para que 05_integrate solo
# tenga que apilar

registro_clean <- registro


# 5. Guardar en data/03_clean --------------------------------------------------

# la carpeta de salida se crea si no existe
carpeta_salida <- file.path('data/03_clean', ronda)
dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)

save(
  registro_clean,
  file = file.path(carpeta_salida, paste0(proyecto, '_registro_clean.RData'))
)

rm(list = ls())
