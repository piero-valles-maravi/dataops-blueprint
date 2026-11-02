#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 08_monitoring                                                        #
# DETALLE: tablas de monitoreo de campo (avance, cuotas, alertas por           #
#   encuestador). Es la ÚNICA excepción a la frontera: lee de data/02_audit    #
#   porque mide el proceso de campo, incluidas las encuestas inválidas. Con    #
#   varias tablas: 08_monitoring_<tabla>.R                                     #
#                                                                              #
# CORRE DESPUES DE: 02_audit                                                   #
# LEE: data/02_audit/<ronda>/                                                  #
# ESCRIBE: outputs/08_products/monitoreo/                                      #
#-----------------------------------------------------------------------------.#

