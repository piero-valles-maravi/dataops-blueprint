#-----------------------------------------------------------------------------.#
# PROYECTO: <NOMBRE DEL PROYECTO>                                              #
#                                                                              #
# RESPONSABLES DEL CODIGO:                                                     #
#   <NOMBRE APELLIDO (ROL)> - <correo>                                         #
#                                                                              #
# FECHA DE CREACION: <dd/mm/aaaa>                                              #
# NOMBRE: packages                                                             #
# DETALLE: solo paquetes. Nada de funciones ni credenciales. Las versiones     #
#   exactas quedan en renv.lock (renv::snapshot() después de agregar un        #
#   paquete). Los que el proyecto no use se borran: cada uno suma tiempo de    #
#   instalación en cada corrida de GitHub Actions.                             #
#                                                                              #
# CORRE DESPUES DE: nada                                                       #
# LEE: nada                                                                    #
# ESCRIBE: nada                                                                #
#-----------------------------------------------------------------------------.#

# pacman instala lo que falte y carga todo en una sola llamada
if (!requireNamespace('pacman', quietly = TRUE)) install.packages('pacman')
library(pacman)

p_load(

  # 1. Base de trabajo --------------------------------------------------------
  tidyverse,     # dplyr, tidyr, purrr, stringr, readr, ggplot2, forcats, tibble
  lubridate,     # fechas y horas (submissiondate, duración de la encuesta)
  janitor,       # clean_names() y tabyl() para revisar frecuencias
  rlang,         # programar con dplyr: {{ }}, .data[[ ]], sym()
  stringi,       # texto: quitar tildes, normalizar nombres y transliterar

  # 2. Ingesta: APIs y bases de datos -----------------------------------------
  httr,          # llamadas a APIs (SurveyCTO, registros externos)
  jsonlite,      # leer las respuestas JSON y la clave de la cuenta de servicio
  curl,          # subir y bajar archivos por SFTP o URL firmada (AWS)
  base64enc,     # codificar archivos o credenciales que una API pide en base64
  DBI,           # comandos estándar para hablar con cualquier base de datos
  RPostgres,     # el conector específico para PostgreSQL

  # 3. Google: Drive y Sheets -------------------------------------------------
  googledrive,   # subir, bajar y buscar archivos en Drive (respaldo diario)
  googlesheets4, # leer y escribir Sheets (monitoreo, validación, dashboard)
  httpuv,        # lo pide gargle para autenticar; no se llama directo

  # 4. Leer y escribir archivos -----------------------------------------------
  readxl,        # leer Excel (instrumento, referencias, correcciones)
  writexl,       # escribir Excel simple, rápido y sin Java
  openxlsx,      # escribir Excel con formato: colores, anchos, varias hojas
  haven,         # leer y escribir Stata y SPSS (.dta, .sav)
  labelled,      # etiquetas de variables y valores, como en Stata

  # 5. Tablas e informes ------------------------------------------------------
  gtsummary,     # tablas descriptivas y de regresión listas para publicar
  gt,            # tablas con formato para informes y HTML
  flextable,     # tablas para Word y PowerPoint
  officer,       # armar documentos Word y PowerPoint desde R
  rmarkdown,     # informes en HTML, Word o PDF
  knitr,         # el motor de rmarkdown y quarto
  quarto,        # renderizar informes .qmd desde R

  # 6. Gráficos ---------------------------------------------------------------
  patchwork,     # juntar varios ggplot en una sola figura
  viridis,       # paletas legibles y aptas para daltónicos
  gridExtra,     # acomodar gráficos y tablas en una grilla
  gridtext,      # texto con formato (negritas, colores) dentro de un gráfico
  grid,          # el sistema gráfico base sobre el que se apoya ggplot2
  grDevices,     # exportar a PNG y PDF; viene con R

  # 7. Mapas ------------------------------------------------------------------
  sf,            # datos espaciales: puntos, polígonos y uniones por ubicación
  units,         # unidades de las distancias y áreas que devuelve sf
  terra,         # datos raster (imágenes, grillas)
  tmap,          # mapas temáticos estáticos o interactivos
  ggspatial,     # escala y flecha del norte en mapas de ggplot2
  maptiles,      # mapas base (OpenStreetMap) para el fondo
  ggmap,         # mapas base de Google o Stadia con ggplot2
  osmdata,       # bajar calles y lugares de OpenStreetMap
  tidygeocoder,  # convertir direcciones en coordenadas
  leaflet,       # mapas interactivos en HTML
  mapview,       # mirar rápido un objeto espacial en un mapa interactivo
  igraph,        # redes y grafos (rutas, conexiones entre entidades)

  # 8. HTML y capturas --------------------------------------------------------
  htmltools,     # armar piezas de HTML desde R
  htmlwidgets,   # guardar un mapa o gráfico interactivo como HTML
  webshot2       # capturar un HTML como imagen (necesita Chrome: CHROME_PATH)

)
