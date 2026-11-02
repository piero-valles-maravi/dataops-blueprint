#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 01_import_registro                                                   #
# DETALLE: descarga una segunda fuente: un registro administrativo, un padrón  #
#   o un Sheet del cliente, tal cual llega. Acá NO se filtra ni se corrige     #
#   nada. EJEMPLO: renombrar o borrar según las fuentes del proyecto.          #
#                                                                              #
# CORRE DESPUES DE: 00_setup                                                   #
# LEE: el Sheet, la base o el archivo del registro                             #
# ESCRIBE: data/01_raw/<ronda>/<proyecto>_registro_raw.RData                   #
#-----------------------------------------------------------------------------.#

