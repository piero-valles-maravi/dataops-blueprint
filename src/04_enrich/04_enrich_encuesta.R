#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 04_enrich_encuesta                                                   #
# DETALLE: agrega a la encuesta información que no trae: clasificación con IA  #
#   de las respuestas abiertas. Es idempotente: no vuelve a procesar (ni a     #
#   pagar) lo que no cambió. Etapa opcional. EJEMPLO: renombrar o borrar según #
#   las fuentes del proyecto.                                                  #
#                                                                              #
# CORRE DESPUES DE: 03_clean_encuesta                                          #
# LEE: data/03_clean/<ronda>/                                                  #
# ESCRIBE: data/04_enrich/<ronda>/<proyecto>_encuesta_enrich.RData y su _hist  #
#-----------------------------------------------------------------------------.#

