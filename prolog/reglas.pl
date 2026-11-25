% Reglas del recomendador de canciones por estado de ánimo.
% Se carga con:  ?- [reglas].
%
% Consultas de ejemplo
% ?- clasificacion('Creep', Cuadrante, Energia).
% ?- cuadrante_objetivo(nostalgico, baja, acompanar, Cuadrante).
% ?- recomendar(nostalgico, baja, acompanar, descansar, espanol, rock, Titulos).
% ?- explicacion('Pausa', 0.225, cualquiera, Texto).

:- encoding(utf8).
:- ensure_loaded(canciones).
:- if(exists_source(library(json))).
:- use_module(library(json)).          % SWI-Prolog 9.3 o más nuevo
:- else.
:- use_module(library(http/json)).     % Versiones anteriores
:- endif.
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

% genero_preferido(Opcion): cualquiera o una de las familias de familia/2.
genero_preferido(cualquiera).
genero_preferido(pop).
genero_preferido(rock).
genero_preferido(urbano).
genero_preferido(baile).
genero_preferido(soul_jazz).
genero_preferido(cantautor).

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

% coincide_genero(GeneroPreferido, GeneroDeLaCancion).
% Con "cualquiera" pasan todas; si no, solo las de esa familia.
coincide_genero(cualquiera, _).
coincide_genero(Familia, Genero) :-
    Familia \== cualquiera,
    familia(Genero, Familia).

%------------------
% 5. Recomendación

% recomendar(+Animo, +Energia, +Objetivo, +Actividad, +Idioma, +Genero, -Titulos)
% Devuelve hasta 5 canciones del cuadrante, idioma y género pedidos,
% las de energía más cercana a lo que pide la persona.
% Si hay menos de 5 de ese género, devuelve las que haya (pueden ser 0).
recomendar(Animo, Energia, Objetivo, Actividad, Idioma, Genero, Titulos) :-
    estado(Animo, _, _),
    objetivo(Objetivo),
    idioma(Idioma),
    genero_preferido(Genero),
    cuadrante_objetivo(Animo, Energia, Objetivo, Cuadrante),
    energia_buscada(Energia, Actividad, EnergiaBuscada),
    findall(Distancia-Titulo,
            candidata(Cuadrante, Idioma, Genero, EnergiaBuscada, Titulo, Distancia),
            Candidatas),
    keysort(Candidatas, Ordenadas),
    pairs_values(Ordenadas, TodosLosTitulos),
    primeras(5, TodosLosTitulos, Titulos).

% energia_buscada: promedio de la energía de la persona y la de su actividad.
energia_buscada(Energia, Actividad, EnergiaBuscada) :-
    energia_usuario(Energia, ValorUsuario),
    energia_actividad(Actividad, ValorActividad),
    EnergiaBuscada is (ValorUsuario + ValorActividad) / 2.

% Una canción es candidata si es del cuadrante, idioma y género pedidos.
% Distancia: qué tan lejos está su energía de la que se busca.
candidata(Cuadrante, PrefIdioma, PrefGenero, EnergiaBuscada, Titulo, Distancia) :-
    cancion(Titulo, _, Genero, Idioma),
    coincide_idioma(PrefIdioma, Idioma),
    coincide_genero(PrefGenero, Genero),
    clasificacion(Titulo, Cuadrante, _),
    medida(Titulo, Energia, _),
    Distancia is abs(Energia - EnergiaBuscada).

% primeras(N, Lista, Primeras): los primeros N elementos de la lista
% (o todos, si la lista tiene menos de N).
primeras(0, _, []).
primeras(N, [], []) :-
    N > 0.
primeras(N, [X|Resto], [X|Primeras]) :-
    N > 0,
    N1 is N - 1,
    primeras(N1, Resto, Primeras).

%------------------
% 6. Salida para Python: las mismas 5 canciones con sus datos, en JSON

recomendar_json(Animo, Energia, Objetivo, Actividad, Idioma, Genero, Json) :-
    recomendar(Animo, Energia, Objetivo, Actividad, Idioma, Genero, Titulos),
    cuadrante_objetivo(Animo, Energia, Objetivo, Cuadrante),
    energia_buscada(Energia, Actividad, EnergiaBuscada),
    findall(Ficha,
            ( member(T, Titulos), ficha(T, EnergiaBuscada, Genero, Ficha) ),
            Fichas),
    atom_json_dict(Json, _{cuadrante:Cuadrante, recomendaciones:Fichas}, [width(0)]).

ficha(Titulo, EnergiaBuscada, PrefGenero,
      _{titulo:Titulo, artista:Artista, genero:Genero, idioma:Idioma,
        url:URL, explicacion:Explicacion}) :-
    cancion(Titulo, Artista, Genero, Idioma),
    enlace(Titulo, URL),
    explicacion(Titulo, EnergiaBuscada, PrefGenero, Explicacion).

% enlace(Titulo, URL): búsqueda de YouTube con el título y el artista.
enlace(Titulo, URL) :-
    cancion(Titulo, Artista, _, _),
    atomic_list_concat([Titulo, Artista], ' ', Busqueda),
    uri_encoded(query_value, Busqueda, Codificada),
    atom_concat('https://www.youtube.com/results?search_query=', Codificada, URL).

%------------------
% 7. Explicación: por qué se recomienda cada canción

% explicacion(+Titulo, +EnergiaBuscada, +GeneroPreferido, -Texto)
explicacion(Titulo, EnergiaBuscada, PrefGenero, Texto) :-
    medida(Titulo, Energia, Valencia),
    clasificacion(Titulo, Cuadrante, Nivel),
    nombre_cuadrante(Cuadrante, Nombre),
    valencia(Valencia, TipoValencia),
    como_suena(TipoValencia, Suena),
    como_es(Nivel, Es),
    format(atom(Base),
           "Es ~w porque suena ~w (valencia ~2f) y es ~w (energía ~2f). Buscabas una energía cercana a ~2f.",
           [Nombre, Suena, Valencia, Es, Energia, EnergiaBuscada]),
    cancion(Titulo, _, Genero, _),
    nota_genero(PrefGenero, Genero, Nota),
    atom_concat(Base, Nota, Texto).

nombre_cuadrante(feliz, feliz).
nombre_cuadrante(tranquilo, tranquila).
nombre_cuadrante(melancolico, 'melancólica').
nombre_cuadrante(tenso, tensa).

como_suena(positiva, alegre).
como_suena(negativa, triste).

como_es(alta, intensa).
como_es(baja, calmada).

nota_genero(cualquiera, _, '').
nota_genero(Familia, _, ' Además es del género que elegiste.') :-
    Familia \== cualquiera.

%------------------
% Consultas extra para explorar la base

canciones_del_cuadrante(Cuadrante, Titulo) :-
    clasificacion(Titulo, Cuadrante, _).

canciones_de_familia(Familia, Titulo) :-
    cancion(Titulo, _, Genero, _),
    familia(Genero, Familia).
