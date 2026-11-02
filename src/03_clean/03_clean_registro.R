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
# LEE: data/02_audit/<ronda>/ y sources/03_correcciones/                       #
# ESCRIBE: data/03_clean/<ronda>/<proyecto>_registro_clean.RData               #
#-----------------------------------------------------------------------------.#

