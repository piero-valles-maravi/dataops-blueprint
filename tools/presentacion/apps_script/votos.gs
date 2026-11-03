/**
 * Votos de la presentación: recibe los votos del celular y entrega los
 * resultados a la diapositiva.
 *
 * Instalación (una sola vez):
 *   1. Crear un Google Sheet vacío y abrir Extensiones → Apps Script.
 *   2. Pegar este archivo y guardar.
 *   3. Implementar → Nueva implementación → Aplicación web.
 *      Ejecutar como: yo. Quién tiene acceso: cualquier usuario.
 *   4. Copiar la URL que termina en /exec y pegarla en
 *      tools/presentacion/config.js (APPS_SCRIPT_URL).
 *
 * Guarda dos pestañas en el Sheet:
 *   votos   fecha, encuesta, opción, votante (un id al azar de cada celular)
 *   estado  la encuesta activa, que el celular sigue sin volver a escanear
 *
 * Si un celular vota dos veces la misma encuesta, cuenta solo su último voto.
 */

// la pestaña de los votos, creada con su encabezado si no existe
function hojaVotos_() {
  const libro = SpreadsheetApp.getActive();
  let hoja = libro.getSheetByName('votos');
  if (!hoja) {
    hoja = libro.insertSheet('votos');
    hoja.appendRow(['fecha', 'encuesta', 'opcion', 'votante']);
  }
  return hoja;
}

// la pestaña del estado, con la encuesta activa en B1
function hojaEstado_() {
  const libro = SpreadsheetApp.getActive();
  let hoja = libro.getSheetByName('estado');
  if (!hoja) {
    hoja = libro.insertSheet('estado');
    hoja.getRange('A1:B1').setValues([['activa', '']]);
  }
  return hoja;
}

// responde JSON
function json_(datos) {
  return ContentService
    .createTextOutput(JSON.stringify(datos))
    .setMimeType(ContentService.MimeType.JSON);
}

// GET ?accion=resultados&p=p1,p2  → conteo por opción de cada encuesta
// GET ?accion=activa              → la encuesta activa
function doGet(e) {
  const accion = (e.parameter.accion || 'resultados');

  if (accion === 'activa') {
    return json_({ activa: hojaEstado_().getRange('B1').getValue() });
  }

  const pedidas = (e.parameter.p || '').split(',').filter(String);
  const filas = hojaVotos_().getDataRange().getValues().slice(1);

  // el último voto de cada votante en cada encuesta
  const ultimo = {};
  filas.forEach(function (f) {
    const encuesta = String(f[1]);
    if (pedidas.indexOf(encuesta) < 0) return;
    ultimo[encuesta + '|' + f[3]] = { encuesta: encuesta, opcion: String(f[2]) };
  });

  // cuántos votos tiene cada opción
  const conteo = {};
  pedidas.forEach(function (p) { conteo[p] = {}; });
  Object.keys(ultimo).forEach(function (k) {
    const v = ultimo[k];
    conteo[v.encuesta][v.opcion] = (conteo[v.encuesta][v.opcion] || 0) + 1;
  });

  return json_({ conteo: conteo });
}

// POST {accion: 'votar', p, opcion, votante}  → guarda un voto
// POST {accion: 'activar', p}                 → cambia la encuesta activa
function doPost(e) {
  const datos = JSON.parse(e.postData.contents);
  const candado = LockService.getScriptLock();
  candado.waitLock(10000);

  try {
    if (datos.accion === 'votar') {
      hojaVotos_().appendRow([new Date(), datos.p, datos.opcion, datos.votante]);
    }
    if (datos.accion === 'activar') {
      hojaEstado_().getRange('B1').setValue(datos.p);
    }
  } finally {
    candado.releaseLock();
  }

  return json_({ ok: true });
}
