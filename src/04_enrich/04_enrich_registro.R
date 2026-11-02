#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 04_enrich_registro                                                   #
# DETALLE: agrega al registro información externa: geocodificación de          #
#   direcciones o datos de una API. Idempotente. Etapa opcional. EJEMPLO:      #
#   renombrar o borrar según las fuentes del proyecto.                         #
#                                                                              #
# CORRE DESPUES DE: 03_clean_registro                                          #
# LEE: data/03_clean/<ronda>/                                                  #
# ESCRIBE: data/04_enrich/<ronda>/<proyecto>_registro_enrich.RData y su _hist  #
#-----------------------------------------------------------------------------.#

