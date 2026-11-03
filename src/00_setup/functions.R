#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: functions                                                            #
# DETALLE: solo funciones compartidas, numeradas por tema. Cargarlo NO ejecuta #
#   nada ni toca la red. Arma carpetas y nombres con proyecto y ronda de       #
#   config.R (ruta_base) y guarda en todos los formatos (guardar_etapa).       #
#                                                                              #
# CORRE DESPUES DE: packages. Lo usa con config.R cargado                      #
# LEE: nada                                                                    #
# ESCRIBE: nada                                                                #
#-----------------------------------------------------------------------------.#


# 1. Leer una variable de entorno ----------------------------------------------

# Ningún identificador ni credencial se escribe en un script: todo sale de
# .secrets/.Renviron y en GitHub Actions de los secrets del repositorio.
# Sys.getenv() los lee igual en los dos casos, así que hay un solo camino que
# mantener.
#
# R no lee solo el .Renviron de .secrets/: si la variable no está cargada y el
# archivo existe, se carga acá. Así lo tienen también las etapas que no cargan
# auth.R (02_audit en adelante).
cargar_renviron <- function(nombre) {

  if (!nzchar(Sys.getenv(nombre)) && file.exists('.secrets/.Renviron')) {
    readRenviron('.secrets/.Renviron')
  }

}

# Si falta la variable, el error nombra cuál es y dónde ponerla, en vez de
# fallar más adelante con un 404 o un id vacío. Nunca se imprime el valor.
env_requerido <- function(nombre) {

  cargar_renviron(nombre)
  valor <- Sys.getenv(nombre)

  if (!nzchar(valor)) {

    stop(
      'Falta la variable ', nombre, ' en .secrets/.Renviron (en GitHub ',
      'Actions, en los secrets del repositorio). La lista completa está en ',
      '.secrets/.Renviron.example.'
    )

  }

  valor

}

# Para las variables que el proyecto puede no usar: devuelve NULL si está vacía
# y el script decide qué hacer sin ella.
env_opcional <- function(nombre) {

  cargar_renviron(nombre)
  valor <- Sys.getenv(nombre)

  if (nzchar(valor)) valor else NULL

}


# 2. Carpetas y nombres de archivo ---------------------------------------------

# Todo sale de proyecto y ronda, que define src/00_setup/config.R. Las etapas
# 01 a 04 van por ronda; desde 05 se juntan todas las rondas, así que ni la
# carpeta ni el nombre la llevan. Con ronda <- NULL, ninguna la lleva.

# TRUE si la etapa va por ronda: 01_raw a 04_enrich, y solo si hay rondas
va_por_ronda <- function(etapa) {
  !is.null(ronda) && grepl('^0[1-4]_', etapa)
}

# el nombre de un archivo, sin extensión: proyecto, ronda (si va) y base
# nombre_base('03_clean', 'encuesta_clean') -> tigo_ronda_1_encuesta_clean
nombre_base <- function(etapa, base) {
  paste(c(proyecto, if (va_por_ronda(etapa)) ronda, base), collapse = '_')
}

# la carpeta de una etapa en data/
# '03_clean' -> data/03_clean/ronda_1     '06_final' -> data/06_final
carpeta_etapa <- function(etapa) {
  do.call(file.path, as.list(c('data', etapa, if (va_por_ronda(etapa)) ronda)))
}

# la ruta del .RData de una base, para el load()
# ruta_base('02_audit', 'encuesta_audit')
#   -> data/02_audit/ronda_1/tigo_ronda_1_encuesta_audit.RData
ruta_base <- function(etapa, base) {
  file.path(carpeta_etapa(etapa), paste0(nombre_base(etapa, base), '.RData'))
}


# 3. Guardar una base en todos los formatos ------------------------------------

# Toda base que guarda una etapa sale en .RData (la que lee la etapa
# siguiente), .sav, .dta, .xlsx, .csv y un Google Sheet, con el mismo nombre y
# en la carpeta de la etapa. El Sheet va a la carpeta de Drive de la etapa
# (GDRIVE_ID_<ETAPA>: GDRIVE_ID_CLEAN para 03_clean) con la fecha al final del
# nombre; si esa variable está vacía, no se crea.
#
# objeto: el nombre del objeto como texto, p. ej. 'encuesta_clean'
# etapa: la carpeta de la etapa en data/, p. ej. '03_clean'
# carpeta: solo para guardar fuera de data/ (la entrega al cliente)
guardar_etapa <- function(objeto, etapa, carpeta = carpeta_etapa(etapa)) {

  dir.create(carpeta, recursive = TRUE, showWarnings = FALSE)
  base     <- get(objeto, envir = parent.frame())
  nombre   <- nombre_base(etapa, objeto)
  ruta     <- file.path(carpeta, nombre)
  # la carpeta de Drive de la etapa: 03_clean -> GDRIVE_ID_CLEAN
  id_drive <- env_opcional(
    paste0('GDRIVE_ID_', toupper(sub('^[0-9]+_', '', etapa)))
  )

  # Stata y SPSS no aceptan puntos, tildes ni nombres largos: se arreglan
  # solo en la copia de esos dos formatos
  copia <- base
  nombres <- gsub('[^A-Za-z0-9_]', '_', names(copia))
  nombres <- sub('^([0-9_])', 'v\\1', nombres)
  names(copia) <- make.unique(substr(nombres, 1, 32), sep = '_')
  haven::write_sav(copia, paste0(ruta, '.sav'))
  haven::write_dta(copia, paste0(ruta, '.dta'))

  writexl::write_xlsx(base, paste0(ruta, '.xlsx'))
  readr::write_csv(base, paste0(ruta, '.csv'))

  # el .RData va al final, con el nombre original del objeto: es el que lee la
  # etapa siguiente, y si el objeto no es una tabla (una API que respondió con
  # error) los formatos de arriba fallan antes y el anterior queda intacto
  save(list = objeto, file = paste0(ruta, '.RData'), envir = parent.frame())

  if (is.null(id_drive)) return(invisible())

  # con la fecha en el nombre: cada día deja su Sheet y no pisa el de otro día.
  # Si ya hay uno del mismo día (otra corrida), se pisa para no duplicarlo
  nombre_sheet <- paste0(nombre, '_', format(Sys.Date(), '%Y-%m-%d'))
  if (!googledrive::drive_has_token()) source('src/00_setup/auth.R')
  existente <- googledrive::drive_ls(
    googledrive::as_id(id_drive), type = 'spreadsheet'
  )
  existente <- existente[existente$name == nombre_sheet, ]

  if (nrow(existente) == 0) {
    ss <- googlesheets4::gs4_create(nombre_sheet, sheets = list(datos = base))
    googledrive::drive_mv(ss, path = googledrive::as_id(id_drive))
  } else {
    googlesheets4::sheet_write(base, ss = existente$id[1], sheet = 'datos')
  }

}


# 4. Cargar el objeto de un archivo .RData -------------------------------------

# Devuelve el único objeto que guarda el archivo, sin saber su nombre: sirve
# para apilar bases que se llaman distinto (encuesta_enrich, registro_enrich)
cargar_objeto <- function(archivo) {

  entorno <- new.env()
  load(archivo, envir = entorno)
  entorno[[ls(entorno)[1]]]

}
