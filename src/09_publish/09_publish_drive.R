#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 09_publish_drive                                                     #
# DETALLE: respalda en Google Drive cada carpeta de data/, con la fecha en el  #
#   nombre del archivo: la última foto del día en el monitoreo diario          #
#   (daily.yml) y la del corte en el pipeline completo (completo.yml). No      #
#   modifica nada.                                                             #
#                                                                              #
# CORRE DESPUES DE: 03_clean (diario) u 08_products (completo)                 #
# LEE: data/01_raw a data/06_final                                             #
# ESCRIBE: una carpeta de Drive por etapa (GDRIVE_ID_*)                        #
#-----------------------------------------------------------------------------.#

