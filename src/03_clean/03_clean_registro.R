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
# LEE: data/02_audit/ronda_1/ y sources/03_correcciones/                       #
# ESCRIBE: data/03_clean/ronda_1/proyecto_ronda_1_registro_clean.RData         #
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

# la registro auditada, con sus alertas
load(ruta_base(
  '02_audit',                                      # la etapa: carpeta en data/
  'registro_audit'                                 # la base que se carga
))                                                 # fin de load()

# el objeto de trabajo: la base auditada queda intacta para comparar
registro_limpiando <- registro_audit



# Aplicar correcciones ---------------------------------------------------------

# las correcciones de sources/03_correcciones/, cada una con su motivo. El
# valor original queda en <variable>_orig: nunca se pisa la columna original



# Levantar alertas -------------------------------------------------------------

# marca con 0/1 lo que la limpieza tiene que resolver o dejar documentado:
# valores fuera de rango, categorías que no están en el instrumento, campos
# con datos en el lugar equivocado. Acá se marca, no se corrige



# Limpiar los datos ------------------------------------------------------------

# skill_data_cleaning.md. Un paso numerado por tarea, reescribiendo el objeto



## Normalizar ------------------------------------------------------------------

# texto, nombres, teléfonos, documentos y fechas



## Recategorizar ---------------------------------------------------------------

# agrupa categorías y pasa "otro, especifique" a su categoría



## Columnas comunes ------------------------------------------------------------

# las mismas columnas comunes en todas las fuentes, para que 05_integrate
# solo tenga que apilar



# Guardar registro_clean -------------------------------------------------------

# la salida del script, con el objeto del mismo nombre que el archivo
registro_clean <- registro_limpiando

# en .RData, .sav, .dta, .xlsx, .csv y un Google Sheet, con proyecto y ronda
# en el nombre (src/00_setup/config.R)
guardar_etapa(
  'registro_clean',                                # el objeto, entre comillas
  '03_clean'                                       # la etapa: carpeta en data/
)                                                  # fin de guardar_etapa()

# borra todo: el script siguiente arranca de cero
rm(list = ls())
