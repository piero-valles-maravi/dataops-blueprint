#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 08_monitoring                                                        #
# DETALLE: tablas del flujo de monitoreo (avance, cuotas, alertas por          #
#   encuestador), que corre cada hora con hourly.yml. Es la ÚNICA excepción a  #
#   la frontera: lee de data/03_clean porque mide el proceso de campo mientras #
#   ocurre, con todos los intentos y sus alertas. Con varias tablas:           #
#   08_monitoring_<tabla>.R                                                    #
#                                                                              #
# CORRE DESPUES DE: 03_clean                                                   #
# LEE: data/03_clean/<ronda>/                                                  #
# ESCRIBE: outputs/08_products/monitoreo/                                      #
#-----------------------------------------------------------------------------.#

