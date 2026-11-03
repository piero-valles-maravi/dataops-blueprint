#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 02_audit_encuesta                                                    #
# DETALLE: marca la encuesta con alertas 0/1 en sus dimensiones de calidad     #
#   (skill_audit.md). Acá NO se corrige ni se borra nada: se marca. Aplica las #
#   correcciones y los veredictos humanos de 01_import_validacion. EJEMPLO:    #
#   renombrar o borrar según las fuentes del proyecto.                         #
#                                                                              #
# CORRE DESPUES DE: 01_import_scto y 01_import_validacion                      #
# LEE: data/01_raw/ronda_1/, sources/01_instrumento/ y sources/02_referencias/ #
# ESCRIBE: data/02_audit/ronda_1/proyecto_ronda_1_encuesta_audit.RData         #
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

# la encuesta tal como llegó de SurveyCTO
load(ruta_base(
  '01_raw',                                        # la etapa: carpeta en data/
  'scto_raw'                                       # la base que se carga
))                                                 # fin de load()

# los veredictos de las supervisoras
load(ruta_base(
  '01_raw',                                        # la etapa: carpeta en data/
  'validaciones_raw'                               # la base que se carga
))                                                 # fin de load()

# las correcciones con datos personales
load(ruta_base(
  '01_raw',                                        # la etapa: carpeta en data/
  'correcciones_raw'                               # la base que se carga
))                                                 # fin de load()

# el objeto de trabajo: el crudo queda intacto para comparar
encuesta_auditando <- scto_raw



# Preparar la base -------------------------------------------------------------

# skill_audit.md, sección 3: leer el instrumento, completar columnas, aplicar
# las correcciones humanas (el valor original queda en orig_<variable>),
# validar tipos, quitar los envíos de prueba y clasificar los registros (es_)



# Alertas por dimensión --------------------------------------------------------

# skill_audit.md, sección 4. Acá NO se corrige ni se borra nada: se marca.
# Cada dimensión tiene sus alertas por regla (0/1) y sus medidas agregadas.
# Las que no aplican al proyecto se borran



## D1 Completitud --------------------------------------------------------------

# alertas ale_d1_<variable>, luego ale_d1_n_<medida> y ale_d1_<medida>



## D2 Validez ------------------------------------------------------------------

# alertas ale_d2_<variable>, luego ale_d2_n_<medida> y ale_d2_<medida>



## D3 Consistencia -------------------------------------------------------------

# alertas ale_d3_<variable>, luego ale_d3_n_<medida> y ale_d3_<medida>



## D4 Autenticidad -------------------------------------------------------------

# alertas ale_d4_<variable>, luego ale_d4_n_<medida> y ale_d4_<medida>



## D5 Elegibilidad -------------------------------------------------------------

# alertas ale_d5_<variable>, luego ale_d5_n_<medida> y ale_d5_<medida>



## D6 Protocolo ----------------------------------------------------------------

# alertas ale_d6_<variable>, luego ale_d6_n_<medida> y ale_d6_<medida>



## D7 Calidad por encuestador --------------------------------------------------

# alertas ale_d7_<variable>, luego ale_d7_n_<medida> y ale_d7_<medida>



## D8 Atípicos -----------------------------------------------------------------

# alertas ale_d8_<variable>, luego ale_d8_n_<medida> y ale_d8_<medida>



## D9 No sustantivas -----------------------------------------------------------

# alertas ale_d9_<variable>, luego ale_d9_n_<medida> y ale_d9_<medida>



## D10 Gestión de casos --------------------------------------------------------

# alertas ale_d10_<variable>, luego ale_d10_n_<medida> y ale_d10_<medida>



# Consolidar -------------------------------------------------------------------

# ale_n_total, ale_n_dimensiones y alerta_final (1, 2 o 3)



# Veredicto humano -------------------------------------------------------------

# las decisiones de validaciones_raw en las columnas val_ y resultado_final:
# lo que decidió la supervisora pesa más que la alerta



# Guardar encuesta_audit -------------------------------------------------------

# la salida del script, con el objeto del mismo nombre que el archivo
encuesta_audit <- encuesta_auditando

# en .RData, .sav, .dta, .xlsx, .csv y un Google Sheet, con proyecto y ronda
# en el nombre (src/00_setup/config.R)
guardar_etapa(
  'encuesta_audit',                                # el objeto, entre comillas
  '02_audit'                                       # la etapa: carpeta en data/
)                                                  # fin de guardar_etapa()

# borra todo: el script siguiente arranca de cero
rm(list = ls())
