#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 01_import_encuesta                                                   #
# DETALLE: descarga la encuesta (SurveyCTO, Kobo) tal cual llega. Acá NO se    #
#   filtra ni se corrige nada. Si la API responde con error, corta sin pisar   #
#   el crudo anterior. El formid de la ronda sale de sources/rondas.csv.       #
#   EJEMPLO: renombrar o borrar según las fuentes del proyecto.                #
#                                                                              #
# CORRE DESPUES DE: 00_setup                                                   #
# LEE: la API de la encuesta y sources/rondas.csv                              #
# ESCRIBE: data/01_raw/<ronda>/<proyecto>_encuesta_raw.RData                   #
#-----------------------------------------------------------------------------.#

