#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 05_integrate_1_apilar                                                #
# DETALLE: apila las fuentes y las rondas en una sola base, con _fuente y      #
#   _ronda. Funciona porque en 03_clean todas salen con las mismas columnas    #
#   comunes. Acá NO se crean indicadores. Con una sola fuente y una ronda, la  #
#   etapa 05 no existe. EJEMPLO: renombrar o borrar según las fuentes del      #
#   proyecto.                                                                  #
#                                                                              #
# CORRE DESPUES DE: 04_enrich (o 03_clean)                                     #
# LEE: data/04_enrich/ o data/03_clean/, todas las rondas                      #
# ESCRIBE: data/05_integrate/proyecto_apilada.RData                            #
#-----------------------------------------------------------------------------.#

# Setup ------------------------------------------------------------------------

# borra lo que haya en memoria: el script no depende de otro
rm(list = ls())

# los paquetes del proyecto
source('src/00_setup/packages.R')

# las funciones compartidas
source('src/00_setup/functions.R')

# el proyecto y la ronda: arman la carpeta y el nombre de cada archivo
source('src/00_setup/config.R')



# Cargar datos -----------------------------------------------------------------

# todas las bases de 04_enrich, de todas las rondas, sin los historiales. Si
# el proyecto no tiene 04_enrich, se cambia por data/03_clean y _clean
archivos <- list.files(
  'data/04_enrich',                                # dónde buscar
  pattern    = '_enrich\\.RData$',                 # sin los _hist
  recursive  = TRUE,                               # en todas las rondas
  full.names = TRUE                                # con la ruta, para cargarlas
)                                                  # fin de list.files()

# lo que se quita del nombre del archivo para quedarse con la fuente
patron_fuente <- paste0('^', proyecto, '_((piloto|ronda_[0-9]+)_)?|_enrich\\.RData$')



# Apilar -----------------------------------------------------------------------

# una base debajo de otra. Funciona porque en 03_clean todas las fuentes
# salen con las mismas columnas comunes
apilada <- map_dfr(
  archivos,                                        # cada base de 04_enrich
  ~ cargar_objeto(.x) %>%                          # la base del archivo
    mutate(                                        # agrega de dónde salió
      `_ronda`  = basename(dirname(.x)),           # la carpeta: ronda_1
      # encuesta, registro
      `_fuente` = gsub(patron_fuente, '', basename(.x))
    )                                              # fin del mutate
)                                                  # fin de map_dfr()



# Guardar apilada --------------------------------------------------------------

# en .RData, .sav, .dta, .xlsx, .csv y un Google Sheet, con proyecto y ronda
# en el nombre (src/00_setup/config.R)
guardar_etapa(
  'apilada',                                       # el objeto, entre comillas
  '05_integrate'                                   # la etapa: carpeta en data/
)                                                  # fin de guardar_etapa()

# borra todo: el script siguiente arranca de cero
rm(list = ls())
