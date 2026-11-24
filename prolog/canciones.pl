% Base de conocimiento: 82 canciones clasificadas por estado de ánimo.
%
% Fuentes
%   - Energía y valencia: Spotify Tracks Dataset (Hugging Face),
%     https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset
%   - Contraste puntual de etiquetas: Last.fm, https://www.last.fm
%   - Las dos canciones de The Bugambilias no están en el dataset;
%     se clasificaron a criterio del equipo (ver clasificacion_editorial/3).
%
% El cuadrante de cada canción NO se escribe a mano: lo calcula la regla
% clasificacion/3 (en reglas.pl) a partir de su energía y valencia,
% siguiendo el modelo circumplejo de Russell (1980).

:- encoding(utf8).

% cancion(Titulo, Artista, Genero, Idioma).

% Felices en español
cancion('LAS 12', 'Ana Mena / Belinda', pop_latino, espanol).
cancion('Yo No Soy Celoso', 'Bad Bunny', reggaeton, espanol).
cancion('MAMIII', 'Becky G / KAROL G', reggaeton, espanol).
cancion('Gasolina', 'Daddy Yankee', reggaeton, espanol).
cancion('Impacto', 'Enjambre', rock_alternativo, espanol).
cancion('PROVENZA', 'KAROL G', reggaeton, espanol).
cancion('La Bachata', 'Manuel Turizo', bachata, espanol).
cancion('Que Pasará', 'Panteón Rococó', ska, espanol).
cancion('Tacones Rojos', 'Sebastian Yatra', pop_latino, espanol).
cancion('Te Felicito', 'Shakira / Rauw Alejandro', pop_urbano, espanol).

% Felices en inglés
cancion('Take on Me', 'a-ha', pop, ingles).
cancion('Dancing Queen', 'ABBA', disco, ingles).
cancion('Locked out of Heaven', 'Bruno Mars', pop, ingles).
cancion('Get Lucky', 'Daft Punk / Pharrell Williams / Nile Rodgers', disco, ingles).
cancion('Levitating', 'Dua Lipa', pop, ingles).
cancion('September', 'Earth, Wind & Fire', disco, ingles).
cancion('Uptown Funk', 'Mark Ronson / Bruno Mars', funk, ingles).
cancion('Ain\'t No Mountain High Enough', 'Marvin Gaye / Tammi Terrell', soul, ingles).
cancion('I Ain\'t Worried', 'OneRepublic', pop, ingles).
cancion('Don\'t Stop Me Now', 'Queen', rock, ingles).

% Melancólicas en español
cancion('Con La Miel En Los Labios', 'Aitana', pop, espanol).
cancion('Lo siento', 'Beret / Sofía Reyes', pop, espanol).
cancion('La Suerte de Mi Vida', 'Dani Martín', pop_rock, espanol).
cancion('Dígale', 'David Bisbal', pop, espanol).
cancion('Soldadito marinero', 'Fito y Fitipaldis', rock, espanol).
cancion('Pausa', 'IZAL', indie, espanol).
cancion('Diazepam', 'Leiva / Natalia Lafourcade', pop_rock, espanol).
cancion('nana triste', 'Natalia Lacunza / Guitarricadelafuente', indie, espanol).
cancion('Solamente tú', 'Pablo Alborán', pop, espanol).
cancion('Como Antes', 'Rels B', pop_urbano, espanol).
cancion('Magenta', 'The Bugambilias', pop_rock, espanol).

% Melancólicas en inglés
cancion('Someone Like You', 'Adele', pop, ingles).
cancion('Back To Black', 'Amy Winehouse', soul, ingles).
cancion('everything i wanted', 'Billie Eilish', pop, ingles).
cancion('Fade Into You', 'Mazzy Star', rock_alternativo, ingles).
cancion('drivers license', 'Olivia Rodrigo', pop, ingles).
cancion('Creep', 'Radiohead', rock_alternativo, ingles).
cancion('No Surprises', 'Radiohead', rock_alternativo, ingles).
cancion('Under the Bridge', 'Red Hot Chili Peppers', rock_alternativo, ingles).
cancion('Too Good At Goodbyes', 'Sam Smith', pop, ingles).
cancion('Fourth of July', 'Sufjan Stevens', cantautor, ingles).

% Tensas en español
cancion('Amiga mía', 'Alejandro Sanz', pop, espanol).
cancion('Será por Eso', 'Caifanes', rock, espanol).
cancion('Me Rehúso', 'Danny Ocean', pop_urbano, espanol).
cancion('Rosa Náutica (Del Piso)', 'Enjambre', rock_alternativo, espanol).
cancion('LA CANCIÓN', 'J Balvin / Bad Bunny', reggaeton, espanol).
cancion('La Playa', 'La Oreja de Van Gogh', pop, espanol).
cancion('Saturno', 'Pablo Alborán', pop, espanol).
cancion('Hasta Que Te Conocí', 'Panteón Rococó / Santa Fe Klan', ska, espanol).
cancion('PUNTO 40', 'Rauw Alejandro / Baby Rasta', reggaeton, espanol).
cancion('Lo Siento BB:/', 'Tainy / Bad Bunny / Julieta Venegas', reggaeton, espanol).
cancion('Escapista de lo evidente', 'The Bugambilias', pop_rock, espanol).

% Tensas en inglés
cancion('You Oughta Know', 'Alanis Morissette', rock_alternativo, ingles).
cancion('Till I Collapse', 'Eminem / Nate Dogg', hip_hop, ingles).
cancion('Take Me To Church', 'Hozier', indie, ingles).
cancion('Demons', 'Imagine Dragons', pop_rock, ingles).
cancion('Numb', 'Linkin Park', rock_alternativo, ingles).
cancion('deja vu', 'Olivia Rodrigo', pop, ingles).
cancion('Californication', 'Red Hot Chili Peppers', rock_alternativo, ingles).
cancion('Chop Suey!', 'System Of A Down', metal, ingles).
cancion('Mr. Brightside', 'The Killers', rock_alternativo, ingles).
cancion('I Hate Everything About You', 'Three Days Grace', rock_alternativo, ingles).

% Tranquilas en español
cancion('Pegao', 'Camilo', pop_latino, espanol).
cancion('Agua', 'Jarabe De Palo', pop_rock, espanol).
cancion('La flaca', 'Jarabe De Palo', pop_rock, espanol).
cancion('Todo se transforma', 'Jorge Drexler', cantautor, espanol).
cancion('Histéricos', 'Leiva / Ximena Sariñana', pop_rock, espanol).
cancion('FUE', 'Manuel Carrasco', pop, espanol).
cancion('En Qué Estrella Estará', 'Nena Daconte', pop, espanol).
cancion('Los Domingos No Se Toman Decisiones', 'Pole. / Pablo Alborán', indie, espanol).
cancion('cómo dormiste?', 'Rels B', pop_urbano, espanol).
cancion('23 de Junio', 'Vetusta Morla', indie, espanol).

% Tranquilas en inglés
cancion('How Deep Is Your Love', 'Bee Gees', pop, ingles).
cancion('Cheek To Cheek', 'Ella Fitzgerald / Louis Armstrong', jazz, ingles).
cancion('Good Riddance (Time of Your Life)', 'Green Day', rock, ingles).
cancion('I\'m Yours', 'Jason Mraz', pop, ingles).
cancion('Memories', 'Maroon 5', pop, ingles).
cancion('Don\'t Know Why', 'Norah Jones', jazz, ingles).
cancion('(Sittin\' On) the Dock of the Bay', 'Otis Redding', soul, ingles).
cancion('Cherish the Day', 'Sade', soul, ingles).
cancion('Michelle', 'The Beatles', rock, ingles).
cancion('My Girl', 'The Temptations', soul, ingles).

% medida(Titulo, Energia, Valencia).
% Valores de 0 a 1 tomados del Spotify Tracks Dataset.
medida('LAS 12', 0.814, 0.728).
medida('Yo No Soy Celoso', 0.588, 0.93).
medida('MAMIII', 0.7, 0.899).
medida('Gasolina', 0.797, 0.741).
medida('Impacto', 0.706, 0.772).
medida('PROVENZA', 0.516, 0.53).
medida('La Bachata', 0.679, 0.85).
medida('Que Pasará', 0.878, 0.833).
medida('Tacones Rojos', 0.856, 0.927).
medida('Te Felicito', 0.636, 0.575).
medida('Take on Me', 0.902, 0.876).
medida('Dancing Queen', 0.87, 0.754).
medida('Locked out of Heaven', 0.698, 0.867).
medida('Get Lucky', 0.811, 0.862).
medida('Levitating', 0.884, 0.914).
medida('September', 0.832, 0.979).
medida('Uptown Funk', 0.609, 0.928).
medida('Ain\'t No Mountain High Enough', 0.6, 0.8).
medida('I Ain\'t Worried', 0.797, 0.825).
medida('Don\'t Stop Me Now', 0.868, 0.609).
medida('Con La Miel En Los Labios', 0.331, 0.432).
medida('Lo siento', 0.463, 0.17).
medida('La Suerte de Mi Vida', 0.181, 0.0919).
medida('Dígale', 0.474, 0.299).
medida('Soldadito marinero', 0.431, 0.324).
medida('Pausa', 0.311, 0.0832).
medida('Diazepam', 0.46, 0.384).
medida('nana triste', 0.308, 0.418).
medida('Solamente tú', 0.419, 0.266).
medida('Como Antes', 0.428, 0.281).
medida('Someone Like You', 0.319, 0.294).
medida('Back To Black', 0.422, 0.378).
medida('everything i wanted', 0.225, 0.243).
medida('Fade Into You', 0.33, 0.175).
medida('drivers license', 0.431, 0.137).
medida('Creep', 0.43, 0.104).
medida('No Surprises', 0.393, 0.118).
medida('Under the Bridge', 0.345, 0.458).
medida('Too Good At Goodbyes', 0.372, 0.476).
medida('Fourth of July', 0.104, 0.162).
medida('Amiga mía', 0.703, 0.402).
medida('Será por Eso', 0.774, 0.465).
medida('Me Rehúso', 0.804, 0.426).
medida('Rosa Náutica (Del Piso)', 0.849, 0.136).
medida('LA CANCIÓN', 0.646, 0.429).
medida('La Playa', 0.552, 0.311).
medida('Saturno', 0.572, 0.311).
medida('Hasta Que Te Conocí', 0.684, 0.328).
medida('PUNTO 40', 0.826, 0.201).
medida('Lo Siento BB:/', 0.703, 0.138).
medida('You Oughta Know', 0.861, 0.473).
medida('Till I Collapse', 0.847, 0.1).
medida('Take Me To Church', 0.664, 0.437).
medida('Demons', 0.71, 0.428).
medida('Numb', 0.863, 0.243).
medida('deja vu', 0.612, 0.178).
medida('Californication', 0.767, 0.328).
medida('Chop Suey!', 0.934, 0.287).
medida('Mr. Brightside', 0.911, 0.236).
medida('I Hate Everything About You', 0.83, 0.453).
medida('Pegao', 0.499, 0.867).
medida('Agua', 0.358, 0.742).
medida('La flaca', 0.481, 0.664).
medida('Todo se transforma', 0.488, 0.682).
medida('Histéricos', 0.434, 0.589).
medida('FUE', 0.415, 0.692).
medida('En Qué Estrella Estará', 0.378, 0.697).
medida('Los Domingos No Se Toman Decisiones', 0.364, 0.705).
medida('cómo dormiste?', 0.429, 0.565).
medida('23 de Junio', 0.473, 0.547).
medida('How Deep Is Your Love', 0.357, 0.674).
medida('Cheek To Cheek', 0.264, 0.657).
medida('Good Riddance (Time of Your Life)', 0.432, 0.648).
medida('I\'m Yours', 0.444, 0.712).
medida('Memories', 0.327, 0.595).
medida('Don\'t Know Why', 0.219, 0.635).
medida('(Sittin\' On) the Dock of the Bay', 0.367, 0.535).
medida('Cherish the Day', 0.389, 0.68).
medida('Michelle', 0.29, 0.666).
medida('My Girl', 0.418, 0.694).

% clasificacion_editorial(Titulo, Cuadrante, Energia).
% Canciones sin medida en el dataset, clasificadas por el equipo.
% El cuadrante de Magenta es provisional.
clasificacion_editorial('Magenta', melancolico, baja).
clasificacion_editorial('Escapista de lo evidente', tenso, alta).

% familia(Genero, Familia).
% Agrupa los géneros en las familias que se le ofrecen al usuario.
% Un género puede pertenecer a dos familias (por ejemplo, pop_rock).
familia(pop, pop).
familia(pop_latino, pop).
familia(pop_urbano, pop).
familia(pop_rock, pop).
familia(pop_rock, rock).
familia(rock, rock).
familia(rock_alternativo, rock).
familia(indie, rock).
familia(metal, rock).
familia(ska, rock).
familia(reggaeton, urbano).
familia(pop_urbano, urbano).
familia(hip_hop, urbano).
familia(bachata, baile).
familia(disco, baile).
familia(funk, baile).
familia(soul, soul_jazz).
familia(jazz, soul_jazz).
familia(cantautor, cantautor).

% contrastada_lastfm(Titulo).
% Canciones cuya clasificación se revisó contra su ficha o etiquetas en Last.fm.
contrastada_lastfm('Gasolina').
contrastada_lastfm('Dancing Queen').
contrastada_lastfm('nana triste').
contrastada_lastfm('Someone Like You').
contrastada_lastfm('No Surprises').
contrastada_lastfm('You Oughta Know').
contrastada_lastfm('I Hate Everything About You').
contrastada_lastfm('Agua').
contrastada_lastfm('Cherish the Day').
