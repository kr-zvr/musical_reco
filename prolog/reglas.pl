% Reglas del recomendador de canciones por estado de ánimo.
% Se carga con:  ?- [reglas].
%
% Consultas de ejemplo
% ?- recomendar(nostalgico, baja, acompanar, descansar, espanol, R).
% ?- recomendar(feliz, media, acompanar, ejercicio, ambos, rock, R).
% ?- canciones_de_familia(soul_jazz, Titulo).
% ?- clasificacion('Gasolina', Cuadrante, Energia).

:- encoding(utf8).
:- ensure_loaded(canciones).
:- use_module(library(http/json)).
:- use_module(library(uri)).
:- use_module(library(pairs)).

%------------------
% Opciones de cada pregunta

% estado(Animo, Valencia, ActivacionHabitual).
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

preferencia_idioma(espanol).
preferencia_idioma(ingles).
preferencia_idioma(ambos).

% preferencia_genero(Opcion): cualquiera o una familia de familia/2.
preferencia_genero(cualquiera).
preferencia_genero(Familia) :-
    setof(F, G^familia(G, F), Familias),
    member(Familia, Familias).

%------------------
% Modelo de Russell: valencia x activación = cuadrante

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
% Clasificación de cada canción

valencia(Valor, negativa) :- Valor < 0.5.
valencia(Valor, positiva) :- Valor >= 0.5.

nivel(Valor, baja) :- Valor < 0.5.
nivel(Valor, alta) :- Valor >= 0.5.

% clasificacion(Titulo, Cuadrante, Energia).
% Con medida se calcula; sin medida se usa la clasificación editorial.
clasificacion(Titulo, Cuadrante, Energia) :-
    medida(Titulo, ValorEnergia, ValorValencia),
    valencia(ValorValencia, Valencia),
    nivel(ValorEnergia, Energia),
    cuadrante(Valencia, Energia, Cuadrante).
clasificacion(Titulo, Cuadrante, Energia) :-
    clasificacion_editorial(Titulo, Cuadrante, Energia).

% energia_numerica(Titulo, Valor): la usada para ordenar.
% Las canciones editoriales toman un valor de referencia según su nivel.
energia_numerica(Titulo, Valor) :-
    medida(Titulo, Valor, _).
energia_numerica(Titulo, Valor) :-
    clasificacion_editorial(Titulo, _, Nivel),
    valor_editorial(Nivel, Valor).

valor_editorial(baja, 0.25).
valor_editorial(alta, 0.65).

%------------------
% Consultas sencillas sobre la base

canciones_de_familia(Familia, Titulo) :-
    cancion(Titulo, _, Genero, _),
    familia(Genero, Familia).

canciones_del_cuadrante(Cuadrante, Titulo) :-
    cancion(Titulo, _, _, _),
    clasificacion(Titulo, Cuadrante, _).

canciones_de_artista(Artista, Titulo) :-
    cancion(Titulo, Nombre, _, _),
    sub_atom(Nombre, _, _, _, Artista).

coincide_idioma(ambos, _).
coincide_idioma(espanol, espanol).
coincide_idioma(ingles, ingles).

% coincide_genero(Preferencia, Genero): 0 si coincide, 1 si no.
coincide_genero(cualquiera, _, 0) :- !.
coincide_genero(Familia, Genero, 0) :- familia(Genero, Familia), !.
coincide_genero(_, _, 1).

% enlace(Titulo, URL): búsqueda de YouTube armada con el título y el artista.
enlace(Titulo, URL) :-
    cancion(Titulo, Artista, _, _),
    atomic_list_concat([Titulo, Artista], ' ', Busqueda),
    uri_encoded(query_value, Busqueda, Codificada),
    atom_concat('https://www.youtube.com/results?search_query=', Codificada, URL).

%------------------
% Recomendación

perfil_valido(Animo, Energia, Objetivo, Actividad, Idioma, Genero) :-
    estado(Animo, _, _),
    energia_usuario(Energia, _),
    objetivo(Objetivo),
    energia_actividad(Actividad, _),
    preferencia_idioma(Idioma),
    preferencia_genero(Genero).

cuadrante_objetivo(Animo, Energia, acompanar, Cuadrante) :-
    estado(Animo, Valencia, Habitual),
    activacion(Energia, Habitual, Activacion),
    cuadrante(Valencia, Activacion, Cuadrante).
cuadrante_objetivo(Animo, Energia, cambiar, Cuadrante) :-
    energia_usuario(Energia, _),
    cambio(Animo, Cuadrante).

% Con energía media se respeta la activación típica del ánimo.
activacion(baja, _, baja).
activacion(media, Habitual, Habitual).
activacion(alta, _, alta).

% recomendar(+Animo, +Energia, +Objetivo, +Actividad, +Idioma, -Resultados)
% recomendar(+Animo, +Energia, +Objetivo, +Actividad, +Idioma, +Genero, -Resultados)
% Devuelve 5 canciones del cuadrante objetivo, en el idioma pedido.
% Primero van las del género preferido y, dentro de cada grupo,
% las de energía más cercana a la que pide la persona y su actividad.
recomendar(Animo, Energia, Objetivo, Actividad, Idioma, Resultados) :-
    recomendar(Animo, Energia, Objetivo, Actividad, Idioma, cualquiera, Resultados).

recomendar(Animo, Energia, Objetivo, Actividad, Idioma, Genero, Resultados) :-
    consulta(Animo, Energia, Objetivo, Actividad, Idioma, Genero, _, Resultados).

% Versión para la aplicación web: devuelve un átomo JSON.
recomendar_json(Animo, Energia, Objetivo, Actividad, Idioma, Json) :-
    recomendar_json(Animo, Energia, Objetivo, Actividad, Idioma, cualquiera, Json).

recomendar_json(Animo, Energia, Objetivo, Actividad, Idioma, Genero, Json) :-
    consulta(Animo, Energia, Objetivo, Actividad, Idioma, Genero, Cuadrante, Resultados),
    atom_json_dict(Json, _{cuadrante:Cuadrante, recomendaciones:Resultados}, [width(0)]).

consulta(Animo, Energia, Objetivo, Actividad, Idioma, Genero, Cuadrante, Resultados) :-
    ground(perfil(Animo, Energia, Objetivo, Actividad, Idioma, Genero)),
    once(perfil_valido(Animo, Energia, Objetivo, Actividad, Idioma, Genero)),
    once(cuadrante_objetivo(Animo, Energia, Objetivo, Cuadrante)),
    energia_usuario(Energia, ValorUsuario),
    energia_actividad(Actividad, ValorActividad),
    EnergiaBuscada is (ValorUsuario + ValorActividad) / 2,
    findall(Orden-Cancion,
            candidata(Cuadrante, Idioma, Genero, EnergiaBuscada, Orden, Cancion),
            Candidatas),
    keysort(Candidatas, Ordenadas),
    pairs_values(Ordenadas, Canciones),
    length(Resultados, 5),
    append(Resultados, _, Canciones).

candidata(Cuadrante, PrefIdioma, PrefGenero, EnergiaBuscada, Penal-Distancia, Cancion) :-
    cancion(Titulo, Artista, Genero, Idioma),
    clasificacion(Titulo, Cuadrante, Nivel),
    coincide_idioma(PrefIdioma, Idioma),
    coincide_genero(PrefGenero, Genero, Penal),
    energia_numerica(Titulo, Valor),
    % En milésimas, para que los empates se resuelvan por orden del archivo.
    Distancia is round(abs(Valor - EnergiaBuscada) * 1000),
    enlace(Titulo, URL),
    Cancion = cancion{titulo:Titulo, artista:Artista, genero:Genero,
                      cuadrante:Cuadrante, energia:Nivel, idioma:Idioma, url:URL}.
