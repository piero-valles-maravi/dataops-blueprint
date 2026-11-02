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

# Flujo de monitoreo (el mismo que corre hourly.yml) ---------------------------

# las tres primeras etapas son comunes a los dos flujos
source('src/01_import/01_import_encuesta.R')
source('src/01_import/01_import_registro.R')
source('src/01_import/01_import_validacion.R')

source('src/02_audit/02_audit_encuesta.R')
source('src/02_audit/02_audit_registro.R')

source('src/03_clean/03_clean_encuesta.R')
source('src/03_clean/03_clean_registro.R')

# tablas del campo, al Sheet que lee Looker
source('src/08_products/08_monitoring.R')
source('src/09_publish/09_publish_sheets.R')


# Flujo completo (el mismo que corre daily.yml, más el análisis) ---------------

# sigue desde 03_clean
source('src/04_enrich/04_enrich_encuesta.R')
source('src/04_enrich/04_enrich_registro.R')

source('src/05_integrate/05_integrate_1_apilar.R')
source('src/05_integrate/05_integrate_2_entidades.R')

source('src/06_wrangle/06_wrangle_indicadores.R')
source('src/06_wrangle/06_wrangle_entrega.R')

# analizar y producir
source('src/07_analysis/07_analysis_descriptivos.R')
source('src/07_analysis/07_analysis_modelo.R')

source('src/08_products/08_products_informe.R')
source('src/08_products/08_products_entrega.R')

# publicar y respaldar
source('src/09_publish/09_publish_sheets.R')
source('src/09_publish/09_publish_drive.R')
