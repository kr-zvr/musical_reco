# Base de conocimiento musical

El catálogo contiene 82 canciones, 42 en español y 40 en inglés. Incluye «Escapista de lo evidente» y «Magenta» de The Bugambilias. Carga el módulo en [SWI-Prolog](https://www.swi-prolog.org/download/stable) desde esta carpeta.

~~~powershell
swipl -s canciones.pl
~~~

~~~prolog
?- recomendar(nostalgico, baja, acompanar, descansar, espanol, R).
?- recomendar(enojado, alta, acompanar, viaje, espanol, R).
?- cancion(Id, Titulo, 'The Bugambilias', Genero, Cuadrante, Energia, Idioma, URL).
?- recomendar_json(triste, media, cambiar, ejercicio, ambos, Json).
~~~

## Entradas para la integración

| Posición | Campo | Átomos |
| --- | --- | --- |
| 1 | Estado de ánimo | feliz, tranquilo, triste, nostalgico, estresado, enojado |
| 2 | Energía declarada | baja, media, alta |
| 3 | Objetivo | acompanar, cambiar |
| 4 | Actividad | estudio_trabajo, ejercicio, viaje, descansar |
| 5 | Idioma | espanol, ingles, ambos |

`recomendar/6` recibe los cinco átomos y unifica el sexto argumento con cinco registros ordenados. Cada registro contiene `id`, `titulo`, `artista`, `genero`, `cuadrante`, `energia`, `idioma` y `url`. `recomendar_json/6` entrega un átomo JSON con las claves `cuadrante` y `recomendaciones`. Una entrada fuera del dominio hace fallar la consulta. `ambos` admite cualquiera de los dos idiomas.

Persona 2 puede consultar el módulo desde PySwip. Las opciones de la aplicación deben mapearse a los átomos de la tabla.

~~~python
import json
from pyswip import Prolog

Prolog.consult("canciones.pl")
consulta = "canciones:recomendar_json(nostalgico,baja,acompanar,descansar,espanol,Json)"
filas = list(Prolog.query(consulta, maxresult=1))
if filas:
    resultado = json.loads(filas[0]["Json"])
    print(resultado["recomendaciones"])
~~~

## Pruebas

~~~powershell
swipl -q -s pruebas.pl -g run_tests -t halt
~~~

Se ejecutaron 17 pruebas en SWI-Prolog 11.0.0 para Windows. Una prueba recorre los 432 perfiles válidos y verifica cinco canciones únicas del cuadrante e idioma esperados. También se prueban las reglas de cambio, el orden según la actividad, las entradas inválidas, el JSON y consultas que recuperan ambos sencillos de The Bugambilias.

## Archivos y generación del catálogo

- `canciones.pl` contiene las reglas y carga `catalogo_hechos.pl`. Mantén ambos en la misma carpeta.
- `catalogo.csv` reúne las fichas de las 82 canciones, las métricas originales disponibles y sus referencias. En `evidencia_lastfm`, `ficha` indica contraste de identidad y los demás valores son etiquetas observadas.
- `seleccion.csv` fija los 80 IDs elegidos, sus idiomas y los ajustes editoriales de género. `pistas_locales.csv` contiene los dos sencillos y sus fichas públicas.
- `generar_catalogo.py` descarga la revisión fijada de [Spotify Tracks Dataset](https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset), comprueba su huella SHA-256, calcula los cuadrantes y reconstruye los dos archivos generados.

~~~powershell
python generar_catalogo.py
python generar_catalogo.py --dataset C:\ruta\dataset.csv
~~~

Los cuadrantes del conjunto de Spotify usan el umbral 0.50 para valencia y energía. La popularidad sirvió para seleccionar pistas junto con el idioma y la variedad musical. Para nueve pistas se registró un contraste puntual en Last.fm. En los sencillos de The Bugambilias, el cuadrante y la energía se guardan como categorías editoriales. La categoría de «Magenta» es provisional. [Ficha de la banda](https://music.amazon.com.au/artists/B0FGZ7ZTF8/the-bugambilias)
