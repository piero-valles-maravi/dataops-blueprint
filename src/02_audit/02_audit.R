#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 02_audit                                                             #
# DETALLE: revisa lo que llegó y marca alertas en columnas nuevas              #
#   (ale_<dimension>_<variable>, 0/1). Acá NO se corrige ni se borra nada: se  #
#   marca. Al final clasifica cada registro y aplica los veredictos humanos    #
#   importados en 01. Etapa opcional.                                          #
#                                                                              #
# CORRE DESPUES DE: 01_import                                                  #
# LEE: data/01_raw/<ronda>/, sources/01_instrumento/ y sources/02_referencias/ #
# ESCRIBE: data/02_audit/<ronda>/<proyecto>_<fuente>_audit.RData               #
#-----------------------------------------------------------------------------.#

