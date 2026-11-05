// Las preguntas de control. Las usan la presentación (index.html) y la página
// de voto del celular (votar.html): se escriben una sola vez, acá.
//   correcta     el índice de la opción correcta, o null si no hay una
//   explicacion  lo que se muestra al cerrar la votación, junto a la respuesta
window.ENCUESTAS = {
  p1: {
    pregunta: 'Para ti, un pipeline end to end es…',
    opciones: [
      'Descargar la encuesta y limpiarla',
      'Descargar, auditar, limpiar y subir al dashboard',
      'Todo lo que pasa desde la fuente hasta una decisión',
      'No estoy seguro'
    ],
    correcta: 2,
    explicacion: 'Un pipeline end to end va desde la fuente hasta la decisión. Lo que vemos en el dashboard es solo la última milla: hoy vamos a recorrer todo el camino.'
  },
  p2: {
    pregunta: 'En GitHub Actions el pipeline no puede leer el Sheet: "permiso denegado". ¿Qué falta?',
    opciones: [
      'Escribir la contraseña de Google en el script',
      'Compartir el Sheet con el correo de la cuenta de servicio',
      'Subir el .Renviron al repositorio',
      'Cambiar el proyecto en config.R'
    ],
    correcta: 1,
    explicacion: 'En GitHub nadie inicia sesión: entra la cuenta de servicio, y solo ve lo que se compartió con su correo. Las llaves van como secrets de GitHub, nunca en un script ni en git.'
  },
  p3: {
    pregunta: 'La supervisora confirma que la edad de 150 era 50. ¿Cómo entra esa corrección?',
    opciones: [
      'Se edita la celda en data/01_raw',
      '02 audit apaga la alerta y cambia el valor',
      'Se cambia en el Sheet que lee el dashboard',
      'Se anota en sources/03_correcciones y la aplica 03 clean'
    ],
    correcta: 3,
    explicacion: 'Audit solo marca. La decisión vuelve al pipeline como una fuente más, en sources/03_correcciones/, y 03 clean la aplica en su paso 1. El raw no se toca y el 150 queda en edad_orig.'
  },
  p4: {
    pregunta: 'Son las 15:00 de un día de campo. ¿Qué corre el workflow hourly.yml?',
    opciones: [
      'Todo el pipeline, de 01 a 08',
      '01, 02, 03, el monitoreo y 08',
      'Solo 08 publish, para refrescar el dashboard',
      'De 01 a 06, para tener la base final al día'
    ],
    correcta: 1,
    explicacion: 'Durante el campo el dato toma el atajo: importa, audita, limpia, pasa por el monitoreo y se publica. De 04 a 07 se corre al cierre del campo, con completo.yml.'
  },
  p5: {
    pregunta: '¿Qué tan claro te quedó el proceso?',
    opciones: ['1 · Nada claro', '2', '3', '4', '5 · Muy claro'],
    correcta: null,
    explicacion: ''
  },
  p6: {
    pregunta: '¿Qué etapa te genera más dudas?',
    opciones: ['01 import', '02 audit', '03 clean', '04 enrich', '05 integrate',
               '06 indicators', '07 analysis', '08 publish', 'El monitoreo'],
    correcta: null,
    explicacion: ''
  }
};
