% Base de conocimiento musical con 82 canciones.
% Carga directa en SWI-Prolog con [canciones].
%
% Consultas de ejemplo
% ?- cancion(_, Titulo, 'The Bugambilias', Genero, Cuadrante, Energia, Idioma, _).
% ?- recomendar(nostalgico, baja, acompanar, descansar, espanol, Recomendaciones).
% ?- recomendar(enojado, alta, acompanar, viaje, espanol, Recomendaciones).
% ?- run_tests.
%
% Las canciones se clasifican por valencia y activación según Russell.
% Referencia https://doi.org/10.1037/h0077714
% Las dos pistas de The Bugambilias tienen etiquetas editoriales.
% El cuadrante melancólico de Magenta es provisional.

:- encoding(utf8).
:- module(canciones, [
    cancion/8,
    fuente/3,
    datos_spotify/4,
    contraste_lastfm/3,
    perfil_valido/5,
    cuadrante_objetivo/4,
    recomendar/6,
    recomendar_json/6
]).

:- use_module(library(http/json)).
:- use_module(library(pairs)).
:- use_module(library(plunit)).

% cancion(Id, Titulo, Artista, Genero, Cuadrante, Energia, Idioma, URL).
cancion('0EpdLuptraYGFZ6J7HNSLc', 'LAS 12', 'Ana Mena / Belinda', 'pop', feliz, alta, espanol, 'https://open.spotify.com/track/0EpdLuptraYGFZ6J7HNSLc').
cancion('5kVZxyMY1gfdCLiChsfjn1', 'Yo No Soy Celoso', 'Bad Bunny', 'latino', feliz, alta, espanol, 'https://open.spotify.com/track/5kVZxyMY1gfdCLiChsfjn1').
cancion('1ri9ZUkBJVFUdgwzCnfcYs', 'MAMIII', 'Becky G / KAROL G', 'reggae', feliz, alta, espanol, 'https://open.spotify.com/track/1ri9ZUkBJVFUdgwzCnfcYs').
cancion('228BxWXUYQPJrJYHDLOHkj', 'Gasolina', 'Daddy Yankee', 'reggaeton', feliz, alta, espanol, 'https://open.spotify.com/track/228BxWXUYQPJrJYHDLOHkj').
cancion('0zNeZTy7nLEWCRrBgjrBx5', 'Impacto', 'Enjambre', 'alt-rock', feliz, alta, espanol, 'https://open.spotify.com/track/0zNeZTy7nLEWCRrBgjrBx5').
cancion('7dSZ6zGTQx66c2GF91xCrb', 'PROVENZA', 'KAROL G', 'reggae', feliz, alta, espanol, 'https://open.spotify.com/track/7dSZ6zGTQx66c2GF91xCrb').
cancion('5ww2BF9slyYgNOk37BlC4u', 'La Bachata', 'Manuel Turizo', 'bachata', feliz, alta, espanol, 'https://open.spotify.com/track/5ww2BF9slyYgNOk37BlC4u').
cancion('4DVU0z4zLAqPq2ShvB7Hl3', 'Que Pasará', 'Panteon Rococo', 'ska', feliz, alta, espanol, 'https://open.spotify.com/track/4DVU0z4zLAqPq2ShvB7Hl3').
cancion('0Be7sopyKMv8Y8npsUkax2', 'Tacones Rojos', 'Sebastian Yatra', 'pop', feliz, alta, espanol, 'https://open.spotify.com/track/0Be7sopyKMv8Y8npsUkax2').
cancion('2rurDawMfoKP4uHyb2kJBt', 'Te Felicito', 'Shakira / Rauw Alejandro', 'pop-urbano', feliz, alta, espanol, 'https://open.spotify.com/track/2rurDawMfoKP4uHyb2kJBt').
cancion('2WfaOiMkCvy7F5fcp2zZ8L', 'Take on Me', 'a-ha', 'rock', feliz, alta, ingles, 'https://open.spotify.com/track/2WfaOiMkCvy7F5fcp2zZ8L').
cancion('0GjEhVFGZW8afUYGChu3Rr', 'Dancing Queen', 'ABBA', 'disco', feliz, alta, ingles, 'https://open.spotify.com/track/0GjEhVFGZW8afUYGChu3Rr').
cancion('3w3y8KPTfNeOKPiqUTakBh', 'Locked out of Heaven', 'Bruno Mars', 'dance', feliz, alta, ingles, 'https://open.spotify.com/track/3w3y8KPTfNeOKPiqUTakBh').
cancion('2Foc5Q5nqNiosCNqttzHof', 'Get Lucky (feat. Pharrell Williams & Nile Rodgers) - Radio Edit', 'Daft Punk / Pharrell Williams / Nile Rodgers', 'electro', feliz, alta, ingles, 'https://open.spotify.com/track/2Foc5Q5nqNiosCNqttzHof').
cancion('39LLxExYz6ewLAcYrzQQyP', 'Levitating', 'Dua Lipa', 'dance', feliz, alta, ingles, 'https://open.spotify.com/track/39LLxExYz6ewLAcYrzQQyP').
cancion('2grjqo0Frpf2okIBiifQKs', 'September', 'Earth, Wind & Fire', 'disco', feliz, alta, ingles, 'https://open.spotify.com/track/2grjqo0Frpf2okIBiifQKs').
cancion('32OlwWuMpZ6b0aN2RZOeMS', 'Uptown Funk (feat. Bruno Mars)', 'Mark Ronson / Bruno Mars', 'dance', feliz, alta, ingles, 'https://open.spotify.com/track/32OlwWuMpZ6b0aN2RZOeMS').
cancion('7tqhbajSfrz2F7E1Z75ASX', 'Ain\'t No Mountain High Enough', 'Marvin Gaye / Tammi Terrell', 'funk', feliz, alta, ingles, 'https://open.spotify.com/track/7tqhbajSfrz2F7E1Z75ASX').
cancion('4h9wh7iOZ0GGn8QVp4RAOB', 'I Ain\'t Worried', 'OneRepublic', 'pop', feliz, alta, ingles, 'https://open.spotify.com/track/4h9wh7iOZ0GGn8QVp4RAOB').
cancion('5T8EDUDqKcs6OSOwEsfqG7', 'Don\'t Stop Me Now - Remastered 2011', 'Queen', 'rock', feliz, alta, ingles, 'https://open.spotify.com/track/5T8EDUDqKcs6OSOwEsfqG7').
cancion('2QJcrJNa4KGxQ6bw0MH3Zx', 'Con La Miel En Los Labios', 'Aitana', 'pop', melancolico, baja, espanol, 'https://open.spotify.com/track/2QJcrJNa4KGxQ6bw0MH3Zx').
cancion('6mvhi5xZsGJeWyf1uyiW0r', 'Lo siento (feat. Sofía Reyes)', 'Beret / Sofía Reyes', 'pop', melancolico, baja, espanol, 'https://open.spotify.com/track/6mvhi5xZsGJeWyf1uyiW0r').
cancion('7e9ECeswuPlEwVFNiFOXv4', 'La Suerte de Mi Vida - 2021', 'Dani Martín', 'pop', melancolico, baja, espanol, 'https://open.spotify.com/track/7e9ECeswuPlEwVFNiFOXv4').
cancion('5OKrgU6UuGMp4sGRxv1JH2', 'Dígale', 'David Bisbal', 'pop', melancolico, baja, espanol, 'https://open.spotify.com/track/5OKrgU6UuGMp4sGRxv1JH2').
cancion('0eVborSuxUeSg0meWYd9dZ', 'Soldadito marinero', 'Fito y Fitipaldis', 'pop-rock', melancolico, baja, espanol, 'https://open.spotify.com/track/0eVborSuxUeSg0meWYd9dZ').
cancion('2xVrFCODKe7cGjc8nkOINq', 'Pausa', 'IZAL', 'indie-rock', melancolico, baja, espanol, 'https://open.spotify.com/track/2xVrFCODKe7cGjc8nkOINq').
cancion('2KrXkY8yRsncGk2kXPD4Zt', 'Diazepam', 'Leiva / Natalia Lafourcade', 'pop-rock', melancolico, baja, espanol, 'https://open.spotify.com/track/2KrXkY8yRsncGk2kXPD4Zt').
cancion('721Lxh9pNJJhNERON4Zjmw', 'nana triste', 'Natalia Lacunza / Guitarricadelafuente', 'indie-pop', melancolico, baja, espanol, 'https://open.spotify.com/track/721Lxh9pNJJhNERON4Zjmw').
cancion('7sRXhReWmJF5pqyg3uUTES', 'Solamente tú', 'Pablo Alborán', 'pop', melancolico, baja, espanol, 'https://open.spotify.com/track/7sRXhReWmJF5pqyg3uUTES').
cancion('1ZR473PTTSHGcnyRyidBoA', 'Como Antes', 'Rels B', 'pop-urbano', melancolico, baja, espanol, 'https://open.spotify.com/track/1ZR473PTTSHGcnyRyidBoA').
cancion('66tvi7hTsPacfkRCSHK16S', 'Magenta', 'The Bugambilias', 'pop-rock', melancolico, baja, espanol, 'https://open.spotify.com/track/66tvi7hTsPacfkRCSHK16S').
cancion('3bNv3VuUOKgrf5hu3YcuRo', 'Someone Like You', 'Adele', 'british', melancolico, baja, ingles, 'https://open.spotify.com/track/3bNv3VuUOKgrf5hu3YcuRo').
cancion('3FAclTFfvUuQYnEsptbK8w', 'Back To Black', 'Amy Winehouse', 'soul', melancolico, baja, ingles, 'https://open.spotify.com/track/3FAclTFfvUuQYnEsptbK8w').
cancion('3ZCTVFBt2Brf31RLEnCkWJ', 'everything i wanted', 'Billie Eilish', 'electro', melancolico, baja, ingles, 'https://open.spotify.com/track/3ZCTVFBt2Brf31RLEnCkWJ').
cancion('1LzNfuep1bnAUR9skqdHCK', 'Fade Into You', 'Mazzy Star', 'alt-rock', melancolico, baja, ingles, 'https://open.spotify.com/track/1LzNfuep1bnAUR9skqdHCK').
cancion('5wANPM4fQCJwkGd4rN57mH', 'drivers license', 'Olivia Rodrigo', 'pop', melancolico, baja, ingles, 'https://open.spotify.com/track/5wANPM4fQCJwkGd4rN57mH').
cancion('70LcF31zb1H0PyJoS1Sx1r', 'Creep', 'Radiohead', 'alt-rock', melancolico, baja, ingles, 'https://open.spotify.com/track/70LcF31zb1H0PyJoS1Sx1r').
cancion('10nyNJ6zNy2YVYLrcwLccB', 'No Surprises', 'Radiohead', 'alt-rock', melancolico, baja, ingles, 'https://open.spotify.com/track/10nyNJ6zNy2YVYLrcwLccB').
cancion('3d9DChrdc6BOeFsbrZ3Is0', 'Under the Bridge', 'Red Hot Chili Peppers', 'alt-rock', melancolico, baja, ingles, 'https://open.spotify.com/track/3d9DChrdc6BOeFsbrZ3Is0').
cancion('1mXVgsBdtIVeCLJnSnmtdV', 'Too Good At Goodbyes', 'Sam Smith', 'dance', melancolico, baja, ingles, 'https://open.spotify.com/track/1mXVgsBdtIVeCLJnSnmtdV').
cancion('5Qnrgqy1pAm9GyNQOgyVFz', 'Fourth of July', 'Sufjan Stevens', 'singer-songwriter', melancolico, baja, ingles, 'https://open.spotify.com/track/5Qnrgqy1pAm9GyNQOgyVFz').
cancion('6kQYMqjobmB8MkWwa9OUyA', 'Amiga mía', 'Alejandro Sanz', 'pop', tenso, alta, espanol, 'https://open.spotify.com/track/6kQYMqjobmB8MkWwa9OUyA').
cancion('0qgDf2H3HHSfiANtWkZPXh', 'Será por Eso', 'Caifanes', 'alt-rock', tenso, alta, espanol, 'https://open.spotify.com/track/0qgDf2H3HHSfiANtWkZPXh').
cancion('6ifUES3keWjwXgae8pXI3o', 'Me Rehúso', 'Danny Ocean', 'pop-urbano', tenso, alta, espanol, 'https://open.spotify.com/track/6ifUES3keWjwXgae8pXI3o').
cancion('6BttoLTTDMUFbbcFNQw121', 'Rosa Náutica (Del Piso)', 'Enjambre', 'alt-rock', tenso, alta, espanol, 'https://open.spotify.com/track/6BttoLTTDMUFbbcFNQw121').
cancion('0fea68AdmYNygeTGI4RC18', 'LA CANCIÓN', 'J Balvin / Bad Bunny', 'reggaeton', tenso, alta, espanol, 'https://open.spotify.com/track/0fea68AdmYNygeTGI4RC18').
cancion('2DNyZP4Py6f4zMASLBnIu6', 'La Playa', 'La Oreja de Van Gogh', 'pop', tenso, alta, espanol, 'https://open.spotify.com/track/2DNyZP4Py6f4zMASLBnIu6').
cancion('2f0Ft2XdvNSMSY5TUlZgEz', 'Saturno', 'Pablo Alborán', 'pop', tenso, alta, espanol, 'https://open.spotify.com/track/2f0Ft2XdvNSMSY5TUlZgEz').
cancion('7f2Rpazz6GxPwKKGcTK3LA', 'Hasta Que Te Conocí', 'Panteon Rococo / Santa Fe Klan', 'ska', tenso, alta, espanol, 'https://open.spotify.com/track/7f2Rpazz6GxPwKKGcTK3LA').
cancion('2TDyyEBasw10wu5Uh94bR1', 'PUNTO 40', 'Rauw Alejandro / Baby Rasta', 'reggaeton', tenso, alta, espanol, 'https://open.spotify.com/track/2TDyyEBasw10wu5Uh94bR1').
cancion('4gzsuuZypVbxs0Af1LSZyB', 'Lo Siento BB:/ (with Bad Bunny & Julieta Venegas)', 'Tainy / Bad Bunny / Julieta Venegas', 'latino', tenso, alta, espanol, 'https://open.spotify.com/track/4gzsuuZypVbxs0Af1LSZyB').
cancion('1WbCJG77SljxDSXIkd4xCH', 'Escapista de lo evidente', 'The Bugambilias', 'pop-rock', tenso, alta, espanol, 'https://open.spotify.com/track/1WbCJG77SljxDSXIkd4xCH').
cancion('0hVHUbZZNeRWw6a2gT1SvE', 'You Oughta Know', 'Alanis Morissette', 'rock', tenso, alta, ingles, 'https://open.spotify.com/track/0hVHUbZZNeRWw6a2gT1SvE').
cancion('4xkOaSrkexMciUUogZKVTS', 'Till I Collapse', 'Eminem / Nate Dogg', 'hip-hop', tenso, alta, ingles, 'https://open.spotify.com/track/4xkOaSrkexMciUUogZKVTS').
cancion('3dYD57lRAUcMHufyqn9GcI', 'Take Me To Church', 'Hozier', 'singer-songwriter', tenso, alta, ingles, 'https://open.spotify.com/track/3dYD57lRAUcMHufyqn9GcI').
cancion('5qaEfEh1AtSdrdrByCP7qR', 'Demons', 'Imagine Dragons', 'rock', tenso, alta, ingles, 'https://open.spotify.com/track/5qaEfEh1AtSdrdrByCP7qR').
cancion('2nLtzopw4rPReszdYBJU6h', 'Numb', 'Linkin Park', 'alternative', tenso, alta, ingles, 'https://open.spotify.com/track/2nLtzopw4rPReszdYBJU6h').
cancion('6HU7h9RYOaPRFeh0R3UeAr', 'deja vu', 'Olivia Rodrigo', 'pop', tenso, alta, ingles, 'https://open.spotify.com/track/6HU7h9RYOaPRFeh0R3UeAr').
cancion('48UPSzbZjgc449aqz8bxox', 'Californication', 'Red Hot Chili Peppers', 'alt-rock', tenso, alta, ingles, 'https://open.spotify.com/track/48UPSzbZjgc449aqz8bxox').
cancion('2DlHlPMa4M17kufBvI2lEN', 'Chop Suey!', 'System Of A Down', 'alternative', tenso, alta, ingles, 'https://open.spotify.com/track/2DlHlPMa4M17kufBvI2lEN').
cancion('003vvx7Niy0yvhvHt4a68B', 'Mr. Brightside', 'The Killers', 'alt-rock', tenso, alta, ingles, 'https://open.spotify.com/track/003vvx7Niy0yvhvHt4a68B').
cancion('0M955bMOoilikPXwKLYpoi', 'I Hate Everything About You', 'Three Days Grace', 'grunge', tenso, alta, ingles, 'https://open.spotify.com/track/0M955bMOoilikPXwKLYpoi').
cancion('7Dk8r4VR5NoveUvTiCKEXC', 'Pegao', 'Camilo', 'reggaeton', tranquilo, baja, espanol, 'https://open.spotify.com/track/7Dk8r4VR5NoveUvTiCKEXC').
cancion('5omgFpiMt1CGHjQGfkwzvz', 'Agua', 'Jarabe De Palo', 'pop-rock', tranquilo, baja, espanol, 'https://open.spotify.com/track/5omgFpiMt1CGHjQGfkwzvz').
cancion('2LsbizbOeNa4x6qsi2jAMb', 'La flaca', 'Jarabe De Palo', 'pop-rock', tranquilo, baja, espanol, 'https://open.spotify.com/track/2LsbizbOeNa4x6qsi2jAMb').
cancion('4YEU9N2XAE0DfUwxWI5ijA', 'Todo se transforma', 'Jorge Drexler', 'cantautor', tranquilo, baja, espanol, 'https://open.spotify.com/track/4YEU9N2XAE0DfUwxWI5ijA').
cancion('0b7VF2YIpjMOtcTh2NAPX7', 'Histéricos', 'Leiva / Ximena Sariñana', 'pop-rock', tranquilo, baja, espanol, 'https://open.spotify.com/track/0b7VF2YIpjMOtcTh2NAPX7').
cancion('7EzMotErPHP0TJ2Gv987q7', 'FUE', 'Manuel Carrasco', 'pop', tranquilo, baja, espanol, 'https://open.spotify.com/track/7EzMotErPHP0TJ2Gv987q7').
cancion('1msphInQ8bBBQGFZkll7FX', 'En Que Estrella Estara', 'Nena Daconte', 'pop', tranquilo, baja, espanol, 'https://open.spotify.com/track/1msphInQ8bBBQGFZkll7FX').
cancion('2Dl25j4QfSCpyXy7VvnTcz', 'Los Domingos No Se Toman Decisiones', 'Pole. / Pablo Alborán', 'spanish', tranquilo, baja, espanol, 'https://open.spotify.com/track/2Dl25j4QfSCpyXy7VvnTcz').
cancion('3fjN3y5x4hN53rykAN2LHQ', 'cómo dormiste?', 'Rels B', 'pop-urbano', tranquilo, baja, espanol, 'https://open.spotify.com/track/3fjN3y5x4hN53rykAN2LHQ').
cancion('3NolL8Ds5qRrYQSVUBKicn', '23 de Junio', 'Vetusta Morla', 'indie-rock', tranquilo, baja, espanol, 'https://open.spotify.com/track/3NolL8Ds5qRrYQSVUBKicn').
cancion('2JoZzpdeP2G6Csfdq5aLXP', 'How Deep Is Your Love', 'Bee Gees', 'balada-pop', tranquilo, baja, ingles, 'https://open.spotify.com/track/2JoZzpdeP2G6Csfdq5aLXP').
cancion('33jt3kYWjQzqn3xyYQ5ZEh', 'Cheek To Cheek', 'Ella Fitzgerald / Louis Armstrong', 'jazz-vocal', tranquilo, baja, ingles, 'https://open.spotify.com/track/33jt3kYWjQzqn3xyYQ5ZEh').
cancion('6ORqU0bHbVCRjXm9AjyHyZ', 'Good Riddance (Time of Your Life)', 'Green Day', 'punk', tranquilo, baja, ingles, 'https://open.spotify.com/track/6ORqU0bHbVCRjXm9AjyHyZ').
cancion('1EzrEOXmMH3G43AXT1y7pA', 'I\'m Yours', 'Jason Mraz', 'acoustic', tranquilo, baja, ingles, 'https://open.spotify.com/track/1EzrEOXmMH3G43AXT1y7pA').
cancion('4cktbXiXOapiLBMprHFErI', 'Memories', 'Maroon 5', 'pop', tranquilo, baja, ingles, 'https://open.spotify.com/track/4cktbXiXOapiLBMprHFErI').
cancion('1zNXF2svmdlNxfS5XeNUgr', 'Don\'t Know Why', 'Norah Jones', 'jazz', tranquilo, baja, ingles, 'https://open.spotify.com/track/1zNXF2svmdlNxfS5XeNUgr').
cancion('3zBhihYUHBmGd2bcQIobrF', '(Sittin\' On) the Dock of the Bay', 'Otis Redding', 'soul', tranquilo, baja, ingles, 'https://open.spotify.com/track/3zBhihYUHBmGd2bcQIobrF').
cancion('22QiTJqDn1BIRSh4mkNJ5w', 'Cherish the Day', 'Sade', 'soul', tranquilo, baja, ingles, 'https://open.spotify.com/track/22QiTJqDn1BIRSh4mkNJ5w').
cancion('5By7Pzgl6TMuVJG168VWzS', 'Michelle - Remastered 2009', 'The Beatles', 'british', tranquilo, baja, ingles, 'https://open.spotify.com/track/5By7Pzgl6TMuVJG168VWzS').
cancion('745H5CctFr12Mo7cqa1BMH', 'My Girl', 'The Temptations', 'soul', tranquilo, baja, ingles, 'https://open.spotify.com/track/745H5CctFr12Mo7cqa1BMH').

% fuente(Id, Tipo, URL).
fuente('0EpdLuptraYGFZ6J7HNSLc', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('5kVZxyMY1gfdCLiChsfjn1', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('1ri9ZUkBJVFUdgwzCnfcYs', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('228BxWXUYQPJrJYHDLOHkj', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('0zNeZTy7nLEWCRrBgjrBx5', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('7dSZ6zGTQx66c2GF91xCrb', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('5ww2BF9slyYgNOk37BlC4u', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('4DVU0z4zLAqPq2ShvB7Hl3', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('0Be7sopyKMv8Y8npsUkax2', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('2rurDawMfoKP4uHyb2kJBt', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('2WfaOiMkCvy7F5fcp2zZ8L', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('0GjEhVFGZW8afUYGChu3Rr', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('3w3y8KPTfNeOKPiqUTakBh', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('2Foc5Q5nqNiosCNqttzHof', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('39LLxExYz6ewLAcYrzQQyP', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('2grjqo0Frpf2okIBiifQKs', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('32OlwWuMpZ6b0aN2RZOeMS', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('7tqhbajSfrz2F7E1Z75ASX', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('4h9wh7iOZ0GGn8QVp4RAOB', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('5T8EDUDqKcs6OSOwEsfqG7', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('2QJcrJNa4KGxQ6bw0MH3Zx', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('6mvhi5xZsGJeWyf1uyiW0r', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('7e9ECeswuPlEwVFNiFOXv4', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('5OKrgU6UuGMp4sGRxv1JH2', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('0eVborSuxUeSg0meWYd9dZ', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('2xVrFCODKe7cGjc8nkOINq', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('2KrXkY8yRsncGk2kXPD4Zt', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('721Lxh9pNJJhNERON4Zjmw', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('7sRXhReWmJF5pqyg3uUTES', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('1ZR473PTTSHGcnyRyidBoA', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('66tvi7hTsPacfkRCSHK16S', ficha_publica, 'https://open.spotify.com/embed/track/66tvi7hTsPacfkRCSHK16S').
fuente('3bNv3VuUOKgrf5hu3YcuRo', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('3FAclTFfvUuQYnEsptbK8w', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('3ZCTVFBt2Brf31RLEnCkWJ', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('1LzNfuep1bnAUR9skqdHCK', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('5wANPM4fQCJwkGd4rN57mH', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('70LcF31zb1H0PyJoS1Sx1r', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('10nyNJ6zNy2YVYLrcwLccB', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('3d9DChrdc6BOeFsbrZ3Is0', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('1mXVgsBdtIVeCLJnSnmtdV', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('5Qnrgqy1pAm9GyNQOgyVFz', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('6kQYMqjobmB8MkWwa9OUyA', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('0qgDf2H3HHSfiANtWkZPXh', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('6ifUES3keWjwXgae8pXI3o', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('6BttoLTTDMUFbbcFNQw121', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('0fea68AdmYNygeTGI4RC18', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('2DNyZP4Py6f4zMASLBnIu6', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('2f0Ft2XdvNSMSY5TUlZgEz', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('7f2Rpazz6GxPwKKGcTK3LA', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('2TDyyEBasw10wu5Uh94bR1', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('4gzsuuZypVbxs0Af1LSZyB', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('1WbCJG77SljxDSXIkd4xCH', ficha_publica, 'https://open.spotify.com/embed/track/1WbCJG77SljxDSXIkd4xCH').
fuente('0hVHUbZZNeRWw6a2gT1SvE', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('4xkOaSrkexMciUUogZKVTS', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('3dYD57lRAUcMHufyqn9GcI', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('5qaEfEh1AtSdrdrByCP7qR', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('2nLtzopw4rPReszdYBJU6h', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('6HU7h9RYOaPRFeh0R3UeAr', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('48UPSzbZjgc449aqz8bxox', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('2DlHlPMa4M17kufBvI2lEN', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('003vvx7Niy0yvhvHt4a68B', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('0M955bMOoilikPXwKLYpoi', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('7Dk8r4VR5NoveUvTiCKEXC', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('5omgFpiMt1CGHjQGfkwzvz', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('2LsbizbOeNa4x6qsi2jAMb', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('4YEU9N2XAE0DfUwxWI5ijA', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('0b7VF2YIpjMOtcTh2NAPX7', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('7EzMotErPHP0TJ2Gv987q7', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('1msphInQ8bBBQGFZkll7FX', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('2Dl25j4QfSCpyXy7VvnTcz', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('3fjN3y5x4hN53rykAN2LHQ', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('3NolL8Ds5qRrYQSVUBKicn', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('2JoZzpdeP2G6Csfdq5aLXP', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('33jt3kYWjQzqn3xyYQ5ZEh', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('6ORqU0bHbVCRjXm9AjyHyZ', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('1EzrEOXmMH3G43AXT1y7pA', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('4cktbXiXOapiLBMprHFErI', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('1zNXF2svmdlNxfS5XeNUgr', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('3zBhihYUHBmGd2bcQIobrF', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('22QiTJqDn1BIRSh4mkNJ5w', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('5By7Pzgl6TMuVJG168VWzS', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').
fuente('745H5CctFr12Mo7cqa1BMH', spotify_dataset, 'https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset/blob/635b034f69257814eff850a5c2b3346fe458134f/dataset.csv').

% datos_spotify(Id, Energia, Valencia, Popularidad).
datos_spotify('0EpdLuptraYGFZ6J7HNSLc', 0.814, 0.728, 79).
datos_spotify('5kVZxyMY1gfdCLiChsfjn1', 0.588, 0.93, 85).
datos_spotify('1ri9ZUkBJVFUdgwzCnfcYs', 0.7, 0.899, 85).
datos_spotify('228BxWXUYQPJrJYHDLOHkj', 0.797, 0.741, 82).
datos_spotify('0zNeZTy7nLEWCRrBgjrBx5', 0.706, 0.772, 45).
datos_spotify('7dSZ6zGTQx66c2GF91xCrb', 0.516, 0.53, 93).
datos_spotify('5ww2BF9slyYgNOk37BlC4u', 0.679, 0.85, 98).
datos_spotify('4DVU0z4zLAqPq2ShvB7Hl3', 0.878, 0.833, 47).
datos_spotify('0Be7sopyKMv8Y8npsUkax2', 0.856, 0.927, 81).
datos_spotify('2rurDawMfoKP4uHyb2kJBt', 0.636, 0.575, 90).
datos_spotify('2WfaOiMkCvy7F5fcp2zZ8L', 0.902, 0.876, 85).
datos_spotify('0GjEhVFGZW8afUYGChu3Rr', 0.87, 0.754, 83).
datos_spotify('3w3y8KPTfNeOKPiqUTakBh', 0.698, 0.867, 87).
datos_spotify('2Foc5Q5nqNiosCNqttzHof', 0.811, 0.862, 82).
datos_spotify('39LLxExYz6ewLAcYrzQQyP', 0.884, 0.914, 84).
datos_spotify('2grjqo0Frpf2okIBiifQKs', 0.832, 0.979, 83).
datos_spotify('32OlwWuMpZ6b0aN2RZOeMS', 0.609, 0.928, 83).
datos_spotify('7tqhbajSfrz2F7E1Z75ASX', 0.6, 0.8, 82).
datos_spotify('4h9wh7iOZ0GGn8QVp4RAOB', 0.797, 0.825, 96).
datos_spotify('5T8EDUDqKcs6OSOwEsfqG7', 0.868, 0.609, 82).
datos_spotify('2QJcrJNa4KGxQ6bw0MH3Zx', 0.331, 0.432, 64).
datos_spotify('6mvhi5xZsGJeWyf1uyiW0r', 0.463, 0.17, 63).
datos_spotify('7e9ECeswuPlEwVFNiFOXv4', 0.181, 0.0919, 55).
datos_spotify('5OKrgU6UuGMp4sGRxv1JH2', 0.474, 0.299, 73).
datos_spotify('0eVborSuxUeSg0meWYd9dZ', 0.431, 0.324, 68).
datos_spotify('2xVrFCODKe7cGjc8nkOINq', 0.311, 0.0832, 59).
datos_spotify('2KrXkY8yRsncGk2kXPD4Zt', 0.46, 0.384, 58).
datos_spotify('721Lxh9pNJJhNERON4Zjmw', 0.308, 0.418, 62).
datos_spotify('7sRXhReWmJF5pqyg3uUTES', 0.419, 0.266, 71).
datos_spotify('1ZR473PTTSHGcnyRyidBoA', 0.428, 0.281, 73).
datos_spotify('3bNv3VuUOKgrf5hu3YcuRo', 0.319, 0.294, 81).
datos_spotify('3FAclTFfvUuQYnEsptbK8w', 0.422, 0.378, 81).
datos_spotify('3ZCTVFBt2Brf31RLEnCkWJ', 0.225, 0.243, 86).
datos_spotify('1LzNfuep1bnAUR9skqdHCK', 0.33, 0.175, 79).
datos_spotify('5wANPM4fQCJwkGd4rN57mH', 0.431, 0.137, 88).
datos_spotify('70LcF31zb1H0PyJoS1Sx1r', 0.43, 0.104, 85).
datos_spotify('10nyNJ6zNy2YVYLrcwLccB', 0.393, 0.118, 82).
datos_spotify('3d9DChrdc6BOeFsbrZ3Is0', 0.345, 0.458, 82).
datos_spotify('1mXVgsBdtIVeCLJnSnmtdV', 0.372, 0.476, 83).
datos_spotify('5Qnrgqy1pAm9GyNQOgyVFz', 0.104, 0.162, 81).
datos_spotify('6kQYMqjobmB8MkWwa9OUyA', 0.703, 0.402, 73).
datos_spotify('0qgDf2H3HHSfiANtWkZPXh', 0.774, 0.465, 45).
datos_spotify('6ifUES3keWjwXgae8pXI3o', 0.804, 0.426, 80).
datos_spotify('6BttoLTTDMUFbbcFNQw121', 0.849, 0.136, 46).
datos_spotify('0fea68AdmYNygeTGI4RC18', 0.646, 0.429, 88).
datos_spotify('2DNyZP4Py6f4zMASLBnIu6', 0.552, 0.311, 74).
datos_spotify('2f0Ft2XdvNSMSY5TUlZgEz', 0.572, 0.311, 77).
datos_spotify('7f2Rpazz6GxPwKKGcTK3LA', 0.684, 0.328, 46).
datos_spotify('2TDyyEBasw10wu5Uh94bR1', 0.826, 0.201, 85).
datos_spotify('4gzsuuZypVbxs0Af1LSZyB', 0.703, 0.138, 87).
datos_spotify('0hVHUbZZNeRWw6a2gT1SvE', 0.861, 0.473, 1).
datos_spotify('4xkOaSrkexMciUUogZKVTS', 0.847, 0.1, 86).
datos_spotify('3dYD57lRAUcMHufyqn9GcI', 0.664, 0.437, 83).
datos_spotify('5qaEfEh1AtSdrdrByCP7qR', 0.71, 0.428, 84).
datos_spotify('2nLtzopw4rPReszdYBJU6h', 0.863, 0.243, 83).
datos_spotify('6HU7h9RYOaPRFeh0R3UeAr', 0.612, 0.178, 87).
datos_spotify('48UPSzbZjgc449aqz8bxox', 0.767, 0.328, 82).
datos_spotify('2DlHlPMa4M17kufBvI2lEN', 0.934, 0.287, 83).
datos_spotify('003vvx7Niy0yvhvHt4a68B', 0.911, 0.236, 86).
datos_spotify('0M955bMOoilikPXwKLYpoi', 0.83, 0.453, 74).
datos_spotify('7Dk8r4VR5NoveUvTiCKEXC', 0.499, 0.867, 74).
datos_spotify('5omgFpiMt1CGHjQGfkwzvz', 0.358, 0.742, 68).
datos_spotify('2LsbizbOeNa4x6qsi2jAMb', 0.481, 0.664, 76).
datos_spotify('4YEU9N2XAE0DfUwxWI5ijA', 0.488, 0.682, 63).
datos_spotify('0b7VF2YIpjMOtcTh2NAPX7', 0.434, 0.589, 55).
datos_spotify('7EzMotErPHP0TJ2Gv987q7', 0.415, 0.692, 64).
datos_spotify('1msphInQ8bBBQGFZkll7FX', 0.378, 0.697, 60).
datos_spotify('2Dl25j4QfSCpyXy7VvnTcz', 0.364, 0.705, 62).
datos_spotify('3fjN3y5x4hN53rykAN2LHQ', 0.429, 0.565, 89).
datos_spotify('3NolL8Ds5qRrYQSVUBKicn', 0.473, 0.547, 57).
datos_spotify('2JoZzpdeP2G6Csfdq5aLXP', 0.357, 0.674, 74).
datos_spotify('33jt3kYWjQzqn3xyYQ5ZEh', 0.264, 0.657, 67).
datos_spotify('6ORqU0bHbVCRjXm9AjyHyZ', 0.432, 0.648, 77).
datos_spotify('1EzrEOXmMH3G43AXT1y7pA', 0.444, 0.712, 80).
datos_spotify('4cktbXiXOapiLBMprHFErI', 0.327, 0.595, 85).
datos_spotify('1zNXF2svmdlNxfS5XeNUgr', 0.219, 0.635, 76).
datos_spotify('3zBhihYUHBmGd2bcQIobrF', 0.367, 0.535, 76).
datos_spotify('22QiTJqDn1BIRSh4mkNJ5w', 0.389, 0.68, 60).
datos_spotify('5By7Pzgl6TMuVJG168VWzS', 0.29, 0.666, 66).
datos_spotify('745H5CctFr12Mo7cqa1BMH', 0.418, 0.694, 79).

% contraste_lastfm(Id, Evidencia, URL).
contraste_lastfm('228BxWXUYQPJrJYHDLOHkj', 'dance', 'https://www.last.fm/music/Daddy%20Yankee/_/Gasolina').
contraste_lastfm('0GjEhVFGZW8afUYGChu3Rr', 'ficha', 'https://www.last.fm/music/Various%2BArtists/Gl%C3%BCckslieder%2B-%2BSongs%2Bdie%2Bgl%C3%BCcklich%2Bmachen').
contraste_lastfm('721Lxh9pNJJhNERON4Zjmw', 'ficha', 'https://www.last.fm/music/Natalia%2BLacunza%2B%26%2BGuitarricadelafuente').
contraste_lastfm('3bNv3VuUOKgrf5hu3YcuRo', 'ficha', 'https://www.last.fm/music/Adele/_/Someone%20Like%20You').
contraste_lastfm('10nyNJ6zNy2YVYLrcwLccB', 'ficha', 'https://www.last.fm/music/Radiohead/Towering%2BAbove%2BThe%2BRest/No%2BSurprises').
contraste_lastfm('0hVHUbZZNeRWw6a2gT1SvE', 'angry', 'https://www.last.fm/tag/angry/tracks').
contraste_lastfm('0M955bMOoilikPXwKLYpoi', 'angry', 'https://www.last.fm/tag/angry/tracks').
contraste_lastfm('5omgFpiMt1CGHjQGfkwzvz', 'ficha', 'https://www.last.fm/music/Jarabe%2Bde%2BPalo').
contraste_lastfm('22QiTJqDn1BIRSh4mkNJ5w', 'chillout', 'https://www.last.fm/tag/chillout/tracks').

% estado(Ánimo declarado, Valencia, Activación habitual).
estado(feliz, positiva, alta).
estado(tranquilo, positiva, baja).
estado(triste, negativa, baja).
estado(nostalgico, negativa, baja).
estado(estresado, negativa, alta).
estado(enojado, negativa, alta).

cuadrante(positiva, alta, feliz).
cuadrante(positiva, baja, tranquilo).
cuadrante(negativa, baja, melancolico).
cuadrante(negativa, alta, tenso).

cambio(feliz, tranquilo).
cambio(tranquilo, feliz).
cambio(triste, feliz).
cambio(nostalgico, feliz).
cambio(estresado, tranquilo).
cambio(enojado, tranquilo).

energia_usuario(baja, 0.25).
energia_usuario(media, 0.50).
energia_usuario(alta, 0.75).

energia_actividad(estudio_trabajo, 0.30).
energia_actividad(ejercicio, 0.85).
energia_actividad(viaje, 0.55).
energia_actividad(descansar, 0.20).

objetivo(acompanar).
objetivo(cambiar).

preferencia_idioma(espanol).
preferencia_idioma(ingles).
preferencia_idioma(ambos).

% Reglas de recomendación
perfil_valido(Animo, Energia, Objetivo, Actividad, Idioma) :-
    estado(Animo, _, _),
    energia_usuario(Energia, _),
    objetivo(Objetivo),
    energia_actividad(Actividad, _),
    preferencia_idioma(Idioma).

cuadrante_objetivo(Animo, Energia, acompanar, Cuadrante) :-
    estado(Animo, Valencia, Habitual),
    activacion(Energia, Habitual, Activacion),
    cuadrante(Valencia, Activacion, Cuadrante).
cuadrante_objetivo(Animo, Energia, cambiar, Cuadrante) :-
    energia_usuario(Energia, _),
    cambio(Animo, Cuadrante).

activacion(baja, _, baja).
activacion(media, Habitual, Habitual).
activacion(alta, _, alta).

% Las cinco entradas son átomos. El resultado es una lista ordenada de dicts.
recomendar(Animo, Energia, Objetivo, Actividad, Idioma, Resultados) :-
    consulta(Animo, Energia, Objetivo, Actividad, Idioma, _, Resultados).

% Adaptador para clientes que reciben el resultado como un átomo JSON.
recomendar_json(Animo, Energia, Objetivo, Actividad, Idioma, Json) :-
    consulta(Animo, Energia, Objetivo, Actividad, Idioma, Cuadrante, Resultados),
    atom_json_dict(Json, _{cuadrante:Cuadrante, recomendaciones:Resultados}, [width(0)]).

consulta(Animo, Energia, Objetivo, Actividad, Idioma, Cuadrante, Resultados) :-
    ground(perfil(Animo, Energia, Objetivo, Actividad, Idioma)),
    once(perfil_valido(Animo, Energia, Objetivo, Actividad, Idioma)),
    once(cuadrante_objetivo(Animo, Energia, Objetivo, Cuadrante)),
    once(energia_usuario(Energia, EnergiaUsuario)),
    once(energia_actividad(Actividad, EnergiaActividad)),
    EnergiaObjetivo is (EnergiaUsuario + EnergiaActividad) / 2,
    findall(Clave-Cancion,
            candidata(Cuadrante, Idioma, EnergiaObjetivo, Clave, Cancion),
            Candidatas),
    keysort(Candidatas, Ordenadas),
    pairs_values(Ordenadas, Canciones),
    length(Resultados, 5),
    append(Resultados, _, Canciones).

candidata(Cuadrante, Preferencia, EnergiaObjetivo, Distancia-Id, Cancion) :-
    cancion(Id, Titulo, Artista, Genero, Cuadrante, Nivel, Idioma, URL),
    coincide_idioma(Preferencia, Idioma),
    energia_para_orden(Id, Nivel, Energia),
    Distancia is round(abs(Energia - EnergiaObjetivo) * 1000000),
    Cancion = cancion{id:Id, titulo:Titulo, artista:Artista, genero:Genero,
                      cuadrante:Cuadrante, energia:Nivel, idioma:Idioma, url:URL}.

coincide_idioma(ambos, _).
coincide_idioma(espanol, espanol).
coincide_idioma(ingles, ingles).

% Las canciones con ficha pública se ordenan mediante un valor de referencia.
% Sus categorías editoriales se conservan sin métricas de Spotify.
energia_para_orden(Id, Nivel, Energia) :-
    (   datos_spotify(Id, Medida, _, _)
    ->  Energia = Medida
    ;   energia_editorial(Nivel, Energia)
    ).

energia_editorial(baja, 0.25).
energia_editorial(alta, 0.65).

% Pruebas de las consultas
:- begin_tests(base_musical).

test(catalogo_de_82_pistas_sin_duplicados) :-
    findall(Id-(Titulo-Artista), cancion(Id, Titulo, Artista, _, _, _, _, _), Pistas),
    length(Pistas, 82),
    pairs_keys_values(Pistas, Identificadores, TitulosYArtistas),
    sort(Identificadores, IdsUnicos),
    sort(TitulosYArtistas, TitulosUnicos),
    length(IdsUnicos, 82),
    length(TitulosUnicos, 82).

test(cuadrantes_y_cobertura_por_idioma) :-
    forall((member(Cuadrante, [feliz, tranquilo, melancolico, tenso]),
            member(Idioma, [espanol, ingles])),
           (aggregate_all(count, cancion(_, _, _, _, Cuadrante, _, Idioma, _), N),
            assertion(N >= 10))),
    aggregate_all(count, datos_spotify(_, _, _, _), 80).

test(procedencia_y_coherencia_de_metrica) :-
    forall(cancion(Id, _, _, _, Cuadrante, Nivel, _, _),
           verifica_origen(Id, Cuadrante, Nivel)).

test(energia_media_usa_la_activacion_tipica_del_animo) :-
    findall(Animo-Cuadrante,
            cuadrante_objetivo(Animo, media, acompanar, Cuadrante),
            [feliz-feliz, tranquilo-tranquilo, triste-melancolico,
             nostalgico-melancolico, estresado-tenso, enojado-tenso]).

test(acompanar_responde_a_energia_explicita) :-
    cuadrante_objetivo(feliz, baja, acompanar, tranquilo),
    cuadrante_objetivo(triste, alta, acompanar, tenso).

test(cambiar_asciende_o_calma) :-
    cuadrante_objetivo(triste, baja, cambiar, feliz),
    cuadrante_objetivo(estresado, alta, cambiar, tranquilo),
    cuadrante_objetivo(enojado, alta, cambiar, tranquilo).

test(actividad_modifica_el_orden) :-
    recomendar(feliz, media, acompanar, descansar, ingles, [Descanso|_]),
    recomendar(feliz, media, acompanar, ejercicio, ingles, [Ejercicio|_]),
    datos_spotify(Descanso.id, EnergiaDescanso, _, _),
    datos_spotify(Ejercicio.id, EnergiaEjercicio, _, _),
    assertion(EnergiaEjercicio > EnergiaDescanso).

test(idioma_ambos) :-
    recomendar(feliz, alta, acompanar, viaje, ambos, Resultados),
    length(Resultados, 5),
    forall(member(R, Resultados), assertion(memberchk(R.idioma, [espanol, ingles]))).

test(rechaza_animo_ajeno_al_dominio, [fail]) :-
    recomendar(sorprendido, media, acompanar, viaje, ambos, _).

test(rechaza_energia_ajena_al_dominio, [fail]) :-
    recomendar(feliz, maxima, acompanar, viaje, ambos, _).

test(rechaza_objetivo_ajeno_al_dominio, [fail]) :-
    recomendar(feliz, media, inventar, viaje, ambos, _).

test(rechaza_actividad_ajena_al_dominio, [fail]) :-
    recomendar(feliz, media, acompanar, cocinar, ambos, _).

test(rechaza_idioma_ajeno_al_dominio, [fail]) :-
    recomendar(feliz, media, acompanar, viaje, frances, _).

test(entrada_instanciada, [fail]) :-
    recomendar(feliz, media, acompanar, viaje, _, _).

test(recomienda_las_dos_de_the_bugambilias) :-
    aggregate_all(count, cancion(_, _, 'The Bugambilias', _, _, _, espanol, _), 2),
    recomendar(nostalgico, baja, acompanar, descansar, espanol, ParaDescansar),
    recomendar(enojado, alta, acompanar, viaje, espanol, ParaViajar),
    assertion(contiene_titulo(ParaDescansar, 'Magenta')),
    assertion(contiene_titulo(ParaViajar, 'Escapista de lo evidente')).

test(json_con_titulos_y_metadatos) :-
    recomendar_json(enojado, alta, acompanar, viaje, espanol, Json),
    atom_json_dict(Json, Datos, [value_string_as(atom)]),
    assertion(Datos.cuadrante == tenso),
    length(Datos.recomendaciones, 5),
    assertion(contiene_titulo(Datos.recomendaciones, 'Escapista de lo evidente')),
    forall(member(R, Datos.recomendaciones),
           assertion(cancion(R.id, R.titulo, R.artista, R.genero,
                             R.cuadrante, R.energia, R.idioma, R.url))).

test(las_432_combinaciones) :-
    findall(perfil(A, E, O, C, I), perfil_valido(A, E, O, C, I), Perfiles),
    length(Perfiles, 432),
    forall(member(perfil(A, E, O, C, I), Perfiles), verifica_perfil(A, E, O, C, I)).

verifica_origen(Id, Cuadrante, Nivel) :-
    findall(Tipo-URL, fuente(Id, Tipo, URL), [Tipo-URL]),
    assertion(sub_atom(URL, 0, _, _, 'https://')),
    (   Tipo == spotify_dataset
    ->  once(datos_spotify(Id, Energia, Valencia, Popularidad)),
        assertion(between(0, 100, Popularidad)),
        cuadrante_por_valores(Valencia, Energia, Esperado, NivelEsperado),
        assertion(Cuadrante-Nivel == Esperado-NivelEsperado)
    ;   assertion(Tipo == ficha_publica),
        assertion(\+ datos_spotify(Id, _, _, _))
    ).

cuadrante_por_valores(Valencia, Energia, Cuadrante, Nivel) :-
    (Energia < 0.5 -> Nivel = baja ; Nivel = alta),
    (Valencia < 0.5 -> Afinidad = negativa ; Afinidad = positiva),
    once(member(Afinidad-Nivel-Cuadrante,
                [positiva-alta-feliz, positiva-baja-tranquilo,
                 negativa-baja-melancolico, negativa-alta-tenso])).

contiene_titulo(Resultados, Titulo) :-
    once((member(R, Resultados), R.titulo == Titulo)).

verifica_perfil(A, E, O, C, I) :-
    findall(Resultados, recomendar(A, E, O, C, I, Resultados), [Resultados]),
    length(Resultados, 5),
    findall(Id, (member(R, Resultados), Id = R.id), Ids),
    sort(Ids, IdsUnicos),
    length(IdsUnicos, 5),
    cuadrante_objetivo(A, E, O, Cuadrante),
    forall(member(R, Resultados),
           (assertion(R.cuadrante == Cuadrante),
            assertion((I == ambos ; R.idioma == I)))).

:- end_tests(base_musical).
