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
#   instrumento. La validación verifica que no quede ningún dato personal.     #
#   EJEMPLO: renombrar o borrar según las fuentes del proyecto.                #
#                                                                              #
# CORRE DESPUES DE: 06_indicators_variables                                    #
# LEE: data/06_final/proyecto_final.RData                                      #
# ESCRIBE: data/06_final/proyecto_entrega.RData                                #
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

# la base final analítica
load(ruta_base(
  '06_final',                                      # la etapa: carpeta en data/
  'final'                                          # la base que se carga
))                                                 # fin de load()

# el objeto de trabajo: la base final queda intacta para comparar
entrega_preparando <- final



# Dejar solo los registros válidos ---------------------------------------------

# según resultado_final de 02_audit



# Quitar datos personales y columnas de trabajo --------------------------------

# los datos personales del proyecto: nombres, documentos, teléfonos, correos,
# direcciones, coordenadas
datos_personales <- c()

# sin datos personales ni alertas, validaciones y auxiliares
entrega_preparando <- entrega_preparando %>%
  select(                                          # lo que se entrega
    -any_of(datos_personales),                     # fuera los datos personales
    -starts_with(c('ale_', 'aux_', 'val_'))        # fuera las de trabajo
  )                                                # fin del select



# Ordenar como el instrumento --------------------------------------------------

# el orden de las columnas sigue el de sources/01_instrumento/



# Guardar entrega --------------------------------------------------------------

# la salida del script, con el objeto del mismo nombre que el archivo
entrega <- entrega_preparando

# en .RData, .sav, .dta, .xlsx, .csv y un Google Sheet, con proyecto y ronda
# en el nombre (src/00_setup/config.R)
guardar_etapa(
  'entrega',                                       # el objeto, entre comillas
  '06_final'                                       # la etapa: carpeta en data/
)                                                  # fin de guardar_etapa()

# borra todo: el script siguiente arranca de cero
rm(list = ls())
