/**
 * Disparador de los workflows de GitHub Actions.
 *
 * Por qué existe: el "schedule" de GitHub no se dispara de forma confiable en
 * repos con poca actividad. Este Apps Script corre con un activador de tiempo
 * de Google y llama a workflow_dispatch.
 *
 * Instalación (una vez por proyecto):
 *   1. script.google.com → Nuevo proyecto → pegar este archivo.
 *   2. Configuración del proyecto → Propiedades del script → agregar:
 *        GITHUB_TOKEN  token fine-grained con permiso "Actions: read and write"
 *                      SOLO sobre este repositorio.
 *        GITHUB_REPO   <usuario>/<repositorio>
 *   3. Completar HORARIO más abajo.
 *   4. Activadores → Agregar → disparar → "Basado en tiempo" → cada hora.
 *
 * Al cerrar el campo: borrar el activador. El token nunca va en este archivo.
 */

// Zona horaria del proyecto (la misma que TZ en los workflows)
const ZONA_HORARIA = 'America/Lima';

// Qué workflow corre a qué hora (0-23, hora local)
const HORARIO = {
  'hourly.yml': [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
  'daily.yml': [21],
};

function disparar() {
  const props = PropertiesService.getScriptProperties();
  const token = props.getProperty('GITHUB_TOKEN');
  const repo = props.getProperty('GITHUB_REPO');
  if (!token || !repo) {
    throw new Error('Faltan GITHUB_TOKEN o GITHUB_REPO en las propiedades del script.');
  }

  const hora = Number(Utilities.formatDate(new Date(), ZONA_HORARIA, 'H'));

  Object.keys(HORARIO).forEach(function (workflow) {
    if (HORARIO[workflow].indexOf(hora) === -1) return;

    const respuesta = UrlFetchApp.fetch(
      'https://api.github.com/repos/' + repo + '/actions/workflows/' + workflow + '/dispatches',
      {
        method: 'post',
        contentType: 'application/json',
        headers: {
          Authorization: 'Bearer ' + token,
          Accept: 'application/vnd.github+json',
        },
        payload: JSON.stringify({ ref: 'main' }),
        muteHttpExceptions: true,
      }
    );

    // GitHub responde 204 cuando acepta el disparo
    if (respuesta.getResponseCode() !== 204) {
      throw new Error(workflow + ': GitHub respondió ' + respuesta.getResponseCode() +
        ' — ' + respuesta.getContentText());
    }
    console.log(workflow + ' disparado a las ' + hora + ':00');
  });
}
