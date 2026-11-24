# Base de conocimiento musical

La base de conocimiento reúne 82 canciones y usa cinco respuestas para recomendar cinco pistas. El catálogo contiene 42 canciones en español, incluidas dos de The Bugambilias, y 40 en inglés. Se implementó en SWI-Prolog con hechos consultables y reglas que ordenan las recomendaciones.

## Clasificación de las canciones

El modelo circumplejo de Russell representa el afecto mediante la valencia y la activación. El proyecto aproxima esos ejes con la valencia y la energía del audio. Para las pistas del conjunto de Spotify, cada medida se considera alta desde 0.50 inclusive y baja por debajo de ese umbral [1].

| Cuadrante | Valencia | Energía | Español | Inglés | Total |
| --- | --- | --- | ---: | ---: | ---: |
| Feliz | Alta | Alta | 10 | 10 | 20 |
| Tranquilo | Alta | Baja | 10 | 10 | 20 |
| Melancólico | Baja | Baja | 11 | 10 | 21 |
| Tenso | Baja | Alta | 11 | 10 | 21 |

## Hechos y reglas

El hecho `cancion/8` registra el ID, título, artista, género, cuadrante, nivel de energía, idioma y enlace. Los predicados `fuente/3` y `datos_spotify/4` permiten rastrear la procedencia y consultar las métricas disponibles.

Para acompañar el ánimo, Prolog conserva su valencia y usa la energía declarada para elegir el cuadrante. Con energía media toma la activación habitual del estado. Feliz suele corresponder a activación alta. Tranquilo, triste y nostálgico usan activación baja. Estresado y enojado usan activación alta.

Para cambiar el ánimo, triste, nostálgico y tranquilo conducen a feliz. Feliz, estresado y enojado conducen a tranquilo. Dentro del cuadrante objetivo, se aplica el filtro de idioma y se ordenan las pistas por cercanía al promedio entre la energía declarada y la de la actividad. El ID de la canción resuelve empates. Ambas canciones locales usan valores de referencia para ordenar su categoría editorial.

El predicado `recomendar/6` devuelve la lista ordenada. `recomendar_json/6` expone el cuadrante y las cinco fichas en JSON para la integración con Python.

## Fuentes de datos

Del CSV de Spotify Tracks Dataset se seleccionaron 80 pistas, diez de cada idioma por cuadrante. Se consideraron la popularidad, el género y la variedad de artistas. El idioma se asignó por curación y el script de generación reconstruye los hechos a partir de los IDs seleccionados y de una revisión fija del CSV [2].

Last.fm se utilizó para contrastar nueve pistas mediante fichas de canción, artista o listas por etiquetas. Por ejemplo, «Cherish the Day» figura en `chillout` e «I Hate Everything About You» figura en `angry`. `catalogo.csv` conserva el enlace y el tipo de evidencia de cada contraste [3].

En 2025, The Bugambilias publicó «Escapista de lo evidente» y «Magenta». El primero se ubicó en el cuadrante tenso por el tema de desamor y la intensidad del arreglo descritos en la cobertura del lanzamiento. La etiqueta melancólica de «Magenta» es editorial y provisional [4].

La valencia y la energía de Spotify describen el sonido mediante estimaciones algorítmicas. La popularidad sintetiza el volumen y la actualidad de las reproducciones en el momento de la recopilación. Las etiquetas de Last.fm proceden de su comunidad y las percepciones pueden variar entre oyentes. MERGE aporta una referencia académica para el uso de los cuatro cuadrantes [5].

## Pruebas de las consultas

En SWI-Prolog 11.0.0 pasaron 17 pruebas PlUnit. Una prueba recorrió las 432 combinaciones de entradas válidas. Cada combinación produjo cinco canciones distintas del cuadrante e idioma esperados. Las demás pruebas comprobaron la procedencia de los datos, el orden por actividad, los rechazos de entradas inválidas, la salida JSON y la aparición de los dos sencillos.

```prolog
?- recomendar(nostalgico, baja, acompanar, descansar, espanol, R).
```

La consulta devuelve cinco canciones en español del cuadrante melancólico. «Magenta» encabeza el resultado.

## Referencias

1. Russell, J. A. (1980). *A circumplex model of affect*. Journal of Personality and Social Psychology, 39(6), 1161–1178. [DOI](https://doi.org/10.1037/h0077714)
2. Maharshi Pandya. *Spotify Tracks Dataset*. Revisión `635b034`. [Hugging Face](https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/tree/635b034f69257814eff850a5c2b3346fe458134f)
3. Last.fm. Etiquetas comunitarias de canciones. [Chillout](https://www.last.fm/tag/chillout/tracks) · [Angry](https://www.last.fm/tag/angry/tracks)
4. The Bugambilias. [Amazon Music](https://music.amazon.com.au/artists/B0FGZ7ZTF8/the-bugambilias) · [Spotify · Escapista de lo evidente](https://open.spotify.com/embed/track/1WbCJG77SljxDSXIkd4xCH) · [Spotify · Magenta](https://open.spotify.com/embed/track/66tvi7hTsPacfkRCSHK16S) · [Metro News Mx](https://www.metronewsmx.com/search/label/The%20Bugambilias)
5. Lima Louro, P. y colaboradores (2024). *MERGE Dataset v1.1.0*. [Zenodo](https://zenodo.org/records/13939205)
