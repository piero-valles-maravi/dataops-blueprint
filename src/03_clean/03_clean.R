#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 03_clean                                                             #
# DETALLE: corrige, normaliza y etiqueta UNA fuente a la vez. Acá NO se cruza  #
#   con otras fuentes. Las correcciones se leen de sources/03_correcciones/    #
#   (nunca escritas en el código). Con varias fuentes: 03_clean_<fuente>.R     #
#                                                                              #
# CORRE DESPUES DE: 02_audit (o 01_import si no hay auditoría)                 #
# LEE: data/02_audit/<ronda>/ y sources/03_correcciones/                       #
# ESCRIBE: data/03_clean/<ronda>/<proyecto>_<fuente>_clean.RData               #
#-----------------------------------------------------------------------------.#

