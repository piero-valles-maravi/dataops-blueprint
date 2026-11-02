#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 01_import_validacion                                                 #
# DETALLE: descarga las decisiones humanas: la validación de las supervisoras  #
#   y las correcciones que tienen datos personales. Son una fuente más:        #
#   02_audit aplica los veredictos y las correcciones. EJEMPLO: renombrar o    #
#   borrar según las fuentes del proyecto.                                     #
#                                                                              #
# CORRE DESPUES DE: 00_setup                                                   #
# LEE: el Sheet de validación                                                  #
# ESCRIBE: data/01_raw/<ronda>/<proyecto>_validaciones_raw.RData y             #
#   <proyecto>_correcciones_raw.RData                                          #
#-----------------------------------------------------------------------------.#

