#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 09_publish_sheets                                                    #
# DETALLE: lleva las tablas a los Google Sheets. En el monitoreo por hora      #
#   (hourly.yml): las tablas de 08_monitoring al Sheet que lee Looker Studio,  #
#   y las encuestas nuevas con alerta al Sheet de validación de las            #
#   supervisoras. En el pipeline completo (completo.yml): las tablas del       #
#   dashboard de resultados. Esquema de columnas fijo, para que Looker no se   #
#   rompa. No calcula nada.                                                    #
#                                                                              #
# CORRE DESPUES DE: 08_monitoring (por hora) u 08_products (completo)          #
# LEE: outputs/08_products/                                                    #
# ESCRIBE: GSHEET_ID_MONITOREO, GSHEET_ID_VALIDACION y GSHEET_ID_DASHBOARD     #
#-----------------------------------------------------------------------------.#

