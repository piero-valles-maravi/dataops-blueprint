// Las preguntas de control. Las usan la presentación (index.html) y la página
// de voto del celular (votar.html): se escriben una sola vez, acá.
// correcta: el índice de la opción correcta, o null si no hay una.
window.ENCUESTAS = {
  p1: {
    pregunta: 'Para ti, un pipeline end to end es…',
    opciones: [
      'Descargar la encuesta y limpiarla',
      'Descargar, auditar, limpiar y subir a Looker',
      'Todo lo que pasa desde la fuente hasta una decisión',
      'No estoy seguro'
    ],
    correcta: null
  },
  p2: {
    pregunta: 'Llega un DNI con una letra en medio. ¿Lo corregimos al importar?',
    opciones: [
      'Sí, cuanto antes mejor',
      'No: se marca y se corrige más adelante',
      'Se borra el registro'
    ],
    correcta: 1
  },
  p3: {
    pregunta: 'Una encuestada declara 150 años. ¿Qué pasa con ese dato?',
    opciones: [
      'Audit lo marca y clean lo corrige',
      'Se borra al importar',
      'Se filtra en Looker',
      'Se deja así'
    ],
    correcta: 0
  },
  p4: {
    pregunta: 'Son las 15:00 de un día de campo. ¿Qué está pasando?',
    opciones: [
      'Corre el flujo por hora y se actualiza Looker',
      'Se arma la base final',
      'Se respalda en Drive',
      'No corre nada hasta la noche'
    ],
    correcta: 0
  },
  p5: {
    pregunta: '¿Qué tan claro te quedó el proceso?',
    opciones: ['1 · Nada claro', '2', '3', '4', '5 · Muy claro'],
    correcta: null
  },
  p6: {
    pregunta: '¿Qué etapa te genera más dudas?',
    opciones: ['01 import', '02 audit', '03 clean', '04 enrich', '05 integrate',
               '06 indicators', '07 analysis', '08 monitoring', '09 publish'],
    correcta: null
  }
};
