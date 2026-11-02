#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 05_integrate_1_apilar                                                #
# DETALLE: apila las fuentes y las rondas en una sola base, con _fuente y      #
#   _ronda. Funciona porque en 03_clean todas salen con las mismas columnas    #
#   comunes. Acá NO se crean indicadores. Con una sola fuente y una ronda, la  #
#   etapa 05 no existe. EJEMPLO: renombrar o borrar según las fuentes del      #
#   proyecto.                                                                  #
#                                                                              #
# CORRE DESPUES DE: 04_enrich (o 03_clean)                                     #
# LEE: data/04_enrich/ o data/03_clean/, todas las rondas                      #
# ESCRIBE: data/05_integrate/<proyecto>_apilada.RData                          #
#-----------------------------------------------------------------------------.#

