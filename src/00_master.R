#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 00_master                                                            #
# DETALLE: corre todo el pipeline en orden, para probar en local. NO es lo     #
#   que corre en producción: eso lo hacen los workflows, un paso por script.   #
#   Las etapas que el proyecto no usa se borran de esta lista (y su carpeta    #
#   de src/), sin cambiar el número de las demás.                              #
#                                                                              #
# CORRE DESPUES DE: nada                                                       #
# LEE: nada                                                                    #
# ESCRIBE: nada                                                                #
#-----------------------------------------------------------------------------.#

# Preparar los datos
source('src/01_import/01_import.R')
source('src/02_audit/02_audit.R')
source('src/03_clean/03_clean.R')
source('src/04_enrich/04_enrich.R')
source('src/05_integrate/05_integrate.R')
source('src/06_wrangle/06_wrangle.R')

# Analizar y producir
source('src/07_analysis/07_analysis.R')
source('src/08_products/08_monitoring.R')
source('src/08_products/08_products.R')

# Publicar
source('src/09_publish/09_publish_sheets.R')
source('src/09_publish/09_publish_drive.R')
