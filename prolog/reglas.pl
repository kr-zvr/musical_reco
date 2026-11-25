:- encoding(utf8).
:- ensure_loaded(canciones).
:- use_module(library(json)).
:- use_module(library(uri)).
:- use_module(library(pairs)).

%------------------
% 1. Opciones de cada pregunta

% estado(Animo, Valencia, EnergiaHabitual).
estado(feliz, positiva, alta).
estado(tranquilo, positiva, baja).
estado(triste, negativa, baja).
estado(nostalgico, negativa, baja).
estado(estresado, negativa, alta).
estado(enojado, negativa, alta).

% energia_usuario(Nivel, Valor).
energia_usuario(baja, 0.25).
energia_usuario(media, 0.50).
energia_usuario(alta, 0.75).

% energia_actividad(Actividad, Valor).
energia_actividad(estudio_trabajo, 0.30).
energia_actividad(ejercicio, 0.85).
energia_actividad(viaje, 0.55).
energia_actividad(descansar, 0.20).

objetivo(acompanar).
objetivo(cambiar).

idioma(espanol).
idioma(ingles).
idioma(ambos).

%------------------
% 2. Modelo de Russell: valencia + energía = cuadrante

cuadrante(positiva, alta, feliz).
cuadrante(positiva, baja, tranquilo).
cuadrante(negativa, baja, melancolico).
cuadrante(negativa, alta, tenso).

% cambio(Animo, CuadranteAlQueSeQuiereLlegar).
cambio(feliz, tranquilo).
cambio(tranquilo, feliz).
cambio(triste, feliz).
cambio(nostalgico, feliz).
cambio(estresado, tranquilo).
cambio(enojado, tranquilo).

%------------------
% 3. Clasificación de cada canción

valencia(Valor, negativa) :- Valor < 0.5.
valencia(Valor, positiva) :- Valor >= 0.5.

nivel(Valor, baja) :- Valor < 0.5.
nivel(Valor, alta) :- Valor >= 0.5.

% clasificacion(Titulo, Cuadrante, Nivel).
clasificacion(Titulo, Cuadrante, Nivel) :-
    medida(Titulo, Energia, Valencia),
    valencia(Valencia, TipoValencia),
    nivel(Energia, Nivel),
    cuadrante(TipoValencia, Nivel, Cuadrante).

%------------------
% 4. Qué cuadrante buscar según las respuestas

% Acompañar: el cuadrante del propio ánimo.
% Con energía media se usa la energía habitual del ánimo.
cuadrante_objetivo(Animo, Energia, acompanar, Cuadrante) :-
    estado(Animo, Valencia, Habitual),
    energia_final(Energia, Habitual, Nivel),
    cuadrante(Valencia, Nivel, Cuadrante).

% Cambiar: el cuadrante al que se quiere llegar.
cuadrante_objetivo(Animo, _, cambiar, Cuadrante) :-
    cambio(Animo, Cuadrante).

energia_final(baja, _, baja).
energia_final(media, Habitual, Habitual).
energia_final(alta, _, alta).

coincide_idioma(ambos, _).
coincide_idioma(espanol, espanol).
coincide_idioma(ingles, ingles).

%------------------
% 5. Recomendación

% recomendar(+Animo, +Energia, +Objetivo, +Actividad, +Idioma, -Titulos)
% Devuelve los títulos de las 5 canciones del cuadrante buscado
% cuya energía está más cerca de lo que pide la persona.
recomendar(Animo, Energia, Objetivo, Actividad, Idioma, Titulos) :-
    estado(Animo, _, _),
    energia_usuario(Energia, ValorUsuario),
    objetivo(Objetivo),
    energia_actividad(Actividad, ValorActividad),
    idioma(Idioma),
    cuadrante_objetivo(Animo, Energia, Objetivo, Cuadrante),
    EnergiaBuscada is (ValorUsuario + ValorActividad) / 2,
    findall(Distancia-Titulo,
            candidata(Cuadrante, Idioma, EnergiaBuscada, Titulo, Distancia),
            Candidatas),
    keysort(Candidatas, Ordenadas),
    pairs_values(Ordenadas, TodosLosTitulos),
    primeras(5, TodosLosTitulos, Titulos).

% Una canción es candidata si es del cuadrante y del idioma pedidos.
% Distancia: qué tan lejos está su energía de la que se busca.
candidata(Cuadrante, PrefIdioma, EnergiaBuscada, Titulo, Distancia) :-
    cancion(Titulo, _, _, Idioma),
    coincide_idioma(PrefIdioma, Idioma),
    clasificacion(Titulo, Cuadrante, _),
    medida(Titulo, Energia, _),
    Distancia is abs(Energia - EnergiaBuscada).

% primeras(N, Lista, Primeras): los primeros N elementos de la lista.
primeras(0, _, []).
primeras(N, [X|Resto], [X|Primeras]) :-
    N > 0,
    N1 is N - 1,
    primeras(N1, Resto, Primeras).

%------------------
% 6. Salida para Python: las mismas 5 canciones con sus datos, en JSON

recomendar_json(Animo, Energia, Objetivo, Actividad, Idioma, Json) :-
    recomendar(Animo, Energia, Objetivo, Actividad, Idioma, Titulos),
    cuadrante_objetivo(Animo, Energia, Objetivo, Cuadrante),
    findall(Ficha, (member(T, Titulos), ficha(T, Ficha)), Fichas),
    atom_json_dict(Json, _{cuadrante:Cuadrante, recomendaciones:Fichas}, [width(0)]).

ficha(Titulo, _{titulo:Titulo, artista:Artista, genero:Genero, idioma:Idioma, url:URL}) :-
    cancion(Titulo, Artista, Genero, Idioma),
    enlace(Titulo, URL).

% enlace(Titulo, URL): búsqueda de YouTube con el título y el artista.
enlace(Titulo, URL) :-
    cancion(Titulo, Artista, _, _),
    atomic_list_concat([Titulo, Artista], ' ', Busqueda),
    uri_encoded(query_value, Busqueda, Codificada),
    atom_concat('https://www.youtube.com/results?search_query=', Codificada, URL).

%------------------
% Consultas extra para explorar la base

canciones_del_cuadrante(Cuadrante, Titulo) :-
    clasificacion(Titulo, Cuadrante, _).

canciones_de_familia(Familia, Titulo) :-
    cancion(Titulo, _, Genero, _),
    familia(Genero, Familia).
