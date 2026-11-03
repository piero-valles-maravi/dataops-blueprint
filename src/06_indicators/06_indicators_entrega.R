#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 06_indicators_entrega                                                #
# DETALLE: arma la versión de entrega de la base final: solo registros         #
#   válidos, sin datos personales ni columnas de trabajo, en el orden del      #
#   instrumento. Verifica con stop() que no quede ningún dato personal.        #
#   EJEMPLO: renombrar o borrar según las fuentes del proyecto.                #
#                                                                              #
# CORRE DESPUES DE: 06_indicators_variables                                    #
# LEE: data/06_final/<proyecto>_final.RData                                    #
# ESCRIBE: data/06_final/<proyecto>_entrega.RData                              #
#-----------------------------------------------------------------------------.#

# 0. Setup ---------------------------------------------------------------------

# borra lo que haya en memoria: el script no depende de otro
rm(list = ls())

# los paquetes y las funciones compartidas
source('src/00_setup/packages.R')
source('src/00_setup/functions.R')

# el prefijo de los archivos
proyecto <- env_requerido('NOMBRE_PROYECTO')


# 1. Cargar --------------------------------------------------------------------

load(file.path('data/06_final', paste0(proyecto, '_final.RData')))

entrega <- final


# 2. Dejar solo los registros válidos ------------------------------------------

# según resultado_final de 02_audit


# 3. Quitar datos personales y columnas de trabajo -----------------------------

# los datos personales del proyecto: nombres, documentos, teléfonos, correos,
# direcciones, coordenadas
datos_personales <- c()

# las columnas de trabajo: alertas, validaciones y auxiliares
entrega <- entrega |>
  select(-any_of(datos_personales), -starts_with(c('ale_', 'aux_', 'val_')))


# 4. Ordenar como el instrumento -----------------------------------------------

# el orden de las columnas sigue el de sources/01_instrumento/


# 5. Verificar -----------------------------------------------------------------

# control: no puede quedar ningún dato personal en la entrega
if (any(datos_personales %in% names(entrega))) {
  stop('La entrega todavía tiene datos personales: ',
       paste(intersect(datos_personales, names(entrega)), collapse = ', '))
}


# 6. Guardar en data/06_final --------------------------------------------------

# la carpeta de salida se crea si no existe
carpeta_salida <- 'data/06_final'
dir.create(carpeta_salida, recursive = TRUE, showWarnings = FALSE)

save(
  entrega,
  file = file.path(carpeta_salida, paste0(proyecto, '_entrega.RData'))
)

rm(list = ls())
