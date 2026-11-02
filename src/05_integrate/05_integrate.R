#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 05_integrate                                                         #
# DETALLE: une fuentes y rondas en una sola base: apila, cruza, deduplica y    #
#   resuelve quién es quién entre fuentes. Acá NO se crean indicadores. Etapa  #
#   opcional: con una sola fuente y una sola ronda no existe.                  #
#                                                                              #
# CORRE DESPUES DE: 04_enrich (o 03_clean si no hay enriquecimiento)           #
# LEE: data/04_enrich/ o data/03_clean/, todas las rondas                      #
# ESCRIBE: data/05_integrate/<proyecto>_integrate.RData                        #
#-----------------------------------------------------------------------------.#

