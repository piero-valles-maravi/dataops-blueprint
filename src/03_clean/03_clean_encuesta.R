#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 03_clean_encuesta                                                    #
# DETALLE: corrige, normaliza y etiqueta la encuesta, UNA fuente a la vez. Acá #
#   NO se cruza con otras fuentes. Las correcciones salen de                   #
#   sources/03_correcciones/. Es la base que lee el flujo de monitoreo.        #
#   EJEMPLO: renombrar o borrar según las fuentes del proyecto.                #
#                                                                              #
# CORRE DESPUES DE: 02_audit_encuesta                                          #
# LEE: data/02_audit/<ronda>/ y sources/03_correcciones/                       #
# ESCRIBE: data/03_clean/<ronda>/<proyecto>_encuesta_clean.RData               #
#-----------------------------------------------------------------------------.#

