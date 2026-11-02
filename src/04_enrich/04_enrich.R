#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 04_enrich                                                            #
# DETALLE: agrega a UNA fuente información que no trae: clasificación con IA,  #
#   geocodificación, datos de APIs externas. Es idempotente: no vuelve a       #
#   procesar (ni a pagar) lo que no cambió. Etapa opcional. Con varias         #
#   fuentes: 04_enrich_<fuente>.R                                              #
#                                                                              #
# CORRE DESPUES DE: 03_clean                                                   #
# LEE: data/03_clean/<ronda>/                                                  #
# ESCRIBE: data/04_enrich/<ronda>/<proyecto>_<fuente>_enrich.RData             #
#-----------------------------------------------------------------------------.#

