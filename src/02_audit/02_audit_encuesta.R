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
# CORRE DESPUES DE: 01_import_encuesta y 01_import_validacion                  #
# LEE: data/01_raw/<ronda>/, sources/01_instrumento/ y sources/02_referencias/ #
# ESCRIBE: data/02_audit/<ronda>/<proyecto>_encuesta_audit.RData               #
#-----------------------------------------------------------------------------.#

