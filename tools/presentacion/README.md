# Presentación: del formulario a la decisión

La presentación del pipeline de datos end to end para el equipo: 24 diapositivas
en HTML, con la línea gráfica de Equilibrium y preguntas de control que se
responden con el celular escaneando un QR.

| Archivo | Qué es |
|---|---|
| `index.html` | la presentación |
| `votar.html` | la página que abre el QR en el celular |
| `encuestas.js` | las preguntas de control, escritas una sola vez |
| `config.js` | la URL del Apps Script de los votos |
| `apps_script/votos.gs` | recibe los votos y entrega los resultados (no se publica) |
| `assets/` | los logos |

## Cómo se publica

`.github/workflows/dashboard.yml` la publica en GitHub Pages cada vez que cambia
algo en esta carpeta: `https://<usuario>.github.io/<repo>/presentacion/`.
Requiere Pages activado en *Settings → Pages → Source: GitHub Actions*.

## Cómo se activan los votos en vivo

Sin configurar, la presentación corre en **modo demostración**: los votos se
simulan y lo dice arriba de cada pregunta. Para usar votos reales:

1. Crear un Google Sheet vacío y abrir *Extensiones → Apps Script*.
2. Pegar `apps_script/votos.gs` y guardar.
3. *Implementar → Nueva implementación → Aplicación web*. Ejecutar como: yo.
   Quién tiene acceso: cualquier usuario.
4. Copiar la URL que termina en `/exec` y pegarla en `config.js`
   (`APPS_SCRIPT_URL`).
5. Hacer push: Pages se actualiza solo.

Para empezar de cero antes de presentar, borrar las filas de la pestaña `votos`
del Sheet (dejando el encabezado).

## Cómo se presenta

| Tecla | Hace |
|---|---|
| → · espacio · Enter | siguiente |
| ← | anterior |
| F | pantalla completa |
| R | en una pregunta de control, revela la respuesta correcta |
| Inicio · Fin | primera · última |

Escribir `#7` al final de la dirección lleva a la diapositiva 7.

El QR de la portada sirve para toda la presentación: el celular muestra sola la
pregunta que está en pantalla. Cada pregunta trae además su propio QR.
