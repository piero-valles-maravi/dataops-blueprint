#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 02_audit_registro                                                    #
# DETALLE: marca el registro con las dimensiones que le aplican (completitud,  #
#   validez, consistencia, duplicados, atípicos). Acá NO se corrige ni se      #
#   borra nada. EJEMPLO: renombrar o borrar según las fuentes del proyecto.    #
#                                                                              #
# CORRE DESPUES DE: 01_import_registro                                         #
# LEE: data/01_raw/ronda_1/                                                    #
# ESCRIBE: data/02_audit/ronda_1/proyecto_ronda_1_registro_audit.RData         #
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

# el registro tal como llegó
load(ruta_base(
  '01_raw',                                        # la etapa: carpeta en data/
  'registro_raw'                                   # la base que se carga
))                                                 # fin de load()

# el objeto de trabajo: el crudo queda intacto para comparar
registro_auditando <- registro_raw



# Preparar la base -------------------------------------------------------------

# completar columnas, validar tipos y clasificar los registros (es_)



# Alertas por dimensión --------------------------------------------------------

# skill_audit.md, "Adaptar a fuentes que no son encuestas". Acá NO se
# corrige ni se borra nada: se marca



## D1 Completitud --------------------------------------------------------------

# alertas ale_d1_<variable>, luego ale_d1_n_<medida> y ale_d1_<medida>



## D2 Validez ------------------------------------------------------------------

# alertas ale_d2_<variable>, luego ale_d2_n_<medida> y ale_d2_<medida>



## D3 Consistencia -------------------------------------------------------------

# alertas ale_d3_<variable>, luego ale_d3_n_<medida> y ale_d3_<medida>



## D4 Duplicados ---------------------------------------------------------------

# alertas ale_d4_<variable>, luego ale_d4_n_<medida> y ale_d4_<medida>



## D8 Atípicos -----------------------------------------------------------------

# alertas ale_d8_<variable>, luego ale_d8_n_<medida> y ale_d8_<medida>



# Consolidar -------------------------------------------------------------------

# ale_n_total, ale_n_dimensiones y alerta_final (1, 2 o 3)



# Guardar registro_audit -------------------------------------------------------

# la salida del script, con el objeto del mismo nombre que el archivo
registro_audit <- registro_auditando

# en .RData, .sav, .dta, .xlsx, .csv y un Google Sheet, con proyecto y ronda
# en el nombre (src/00_setup/config.R)
guardar_etapa(
  'registro_audit',                                # el objeto, entre comillas
  '02_audit'                                       # la etapa: carpeta en data/
)                                                  # fin de guardar_etapa()

# borra todo: el script siguiente arranca de cero
rm(list = ls())
