#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: 07_analysis_modelo                                                   #
# DETALLE: estima el modelo o el índice del proyecto (regresión, conjoint, Van #
#   Westendorp, índice compuesto). Lee SOLO de data/06_final. Guarda           #
#   estimaciones y figuras. Etapa opcional. EJEMPLO: renombrar o borrar según  #
#   las fuentes del proyecto.                                                  #
#                                                                              #
# CORRE DESPUES DE: 06_indicators                                              #
# LEE: data/06_final/                                                          #
# ESCRIBE: outputs/07_analysis/tablas/ y figuras/, con el prefijo modelo_      #
#-----------------------------------------------------------------------------.#

# 0. Setup ---------------------------------------------------------------------

# borra lo que haya en memoria: el script no depende de otro
rm(list = ls())

# los paquetes y las funciones compartidas
source('src/00_setup/packages.R')
source('src/00_setup/functions.R')

# el prefijo de los archivos
proyecto <- env_requerido('NOMBRE_PROYECTO')


# 1. Cargar --------------------------------------------------------------------

# lee SOLO de data/06_final
load(file.path('data/06_final', paste0(proyecto, '_final.RData')))


# 2. Estimar -------------------------------------------------------------------

# el modelo o el índice del proyecto: regresión, conjoint, Van Westendorp,
# índice compuesto. Las estimaciones van a la lista de tablas
tablas <- list()


# 3. Figuras -------------------------------------------------------------------

# lista nombrada de ggplot: el nombre es el del archivo
figuras <- list()


# 4. Guardar en outputs/07_analysis --------------------------------------------

# las tablas y figuras se guardan, nunca quedan solo en pantalla
for (carpeta in file.path('outputs/07_analysis', c('tablas', 'figuras'))) {
  dir.create(carpeta, recursive = TRUE, showWarnings = FALSE)
}

# todas las tablas en un Excel, una pestaña por tabla
writexl::write_xlsx(
  tablas,
  file.path('outputs/07_analysis/tablas', 'modelo_tablas.xlsx')
)

# cada figura en su PNG, con el nombre de la lista
purrr::iwalk(figuras, function(figura, nombre) {
  ggsave(
    file.path('outputs/07_analysis/figuras',
              paste0('modelo_', nombre, '.png')),
    figura, width = 8, height = 5, dpi = 300
  )
})

rm(list = ls())
