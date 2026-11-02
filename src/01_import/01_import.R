#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 01_import                                                            #
# DETALLE: descarga los datos de la fuente tal cual llegan. Acá NO se filtra   #
#   ni se corrige nada. Si la fuente responde con error, corta sin pisar el    #
#   crudo anterior. Con varias fuentes: un script por fuente,                  #
#   01_import_<fuente>.R. Las decisiones humanas que vienen de un Sheet        #
#   (validación de supervisoras, correcciones con datos personales) también    #
#   son una fuente: 01_import_validacion.R                                     #
#                                                                              #
# CORRE DESPUES DE: 00_setup                                                   #
# LEE: la fuente (API, Sheet, base, web) y sources/rondas.csv                  #
# ESCRIBE: data/01_raw/<ronda>/<proyecto>_<fuente>_raw.RData                   #
#-----------------------------------------------------------------------------.#

