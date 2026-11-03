#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: config                                                               #
# DETALLE: lo único que se edita al empezar un proyecto o al cambiar de ronda. #
#   Con esto functions.R arma la carpeta y el nombre de cada archivo. Acá NO   #
#   van credenciales ni ids: esos van en .secrets/.Renviron.                   #
#                                                                              #
# CORRE DESPUES DE: functions                                                  #
# LEE: nada                                                                    #
# ESCRIBE: nada                                                                #
#-----------------------------------------------------------------------------.#

# el nombre del proyecto, en snake_case: va al inicio de todos los archivos
# ej.: con proyecto <- 'tigo' y ronda <- 'ronda_1', la encuesta limpia se guarda
#      en data/03_clean/ronda_1/tigo_ronda_1_encuesta_clean.RData
proyecto <- 'proyecto'

# la ronda que se procesa: piloto, ronda_1, ronda_2... Con NULL el proyecto no
# tiene rondas: las bases van directo en la carpeta de la etapa y el nombre no
# lleva ronda
# ej.: con proyecto <- 'tigo' y ronda <- NULL, la encuesta limpia se guarda en
#      data/03_clean/tigo_encuesta_clean.RData
ronda <- 'ronda_1'
