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

# 1. Ingesta -------------------------------------------------------------------

source('src/01_import/01_import_scto.R')
source('src/01_import/01_import_registro.R')
source('src/01_import/01_import_validacion.R')


# 2. Procesar ------------------------------------------------------------------

# hasta 03_clean es lo mismo que corren hourly.yml y daily.yml
source('src/02_audit/02_audit_encuesta.R')
source('src/02_audit/02_audit_registro.R')

source('src/03_clean/03_clean_encuesta.R')
source('src/03_clean/03_clean_registro.R')

# desde acá, solo el pipeline completo (completo.yml)
source('src/04_enrich/04_enrich_encuesta.R')
source('src/04_enrich/04_enrich_registro.R')

source('src/05_integrate/05_integrate_1_apilar.R')
source('src/05_integrate/05_integrate_2_entidades.R')

source('src/06_indicators/06_indicators_variables.R')
source('src/06_indicators/06_indicators_entrega.R')


# 3. Producir ------------------------------------------------------------------

# los análisis, un script por producto; el informe va al final porque usa
# las tablas y figuras de los demás
source('src/07_analysis/07_analysis_descriptivos.R')
source('src/07_analysis/07_analysis_modelo.R')
source('src/07_analysis/07_analysis_informe.R')

# el monitoreo es de los workflows hourly.yml y daily.yml; acá se corre para
# probarlo
source('src/08_monitoring/08_monitoring_hourly.R')
source('src/08_monitoring/08_monitoring_daily.R')


# 4. Publicar ------------------------------------------------------------------

source('src/09_publish/09_publish_sheets.R')
source('src/09_publish/09_publish_drive.R')
source('src/09_publish/09_publish_entrega.R')
