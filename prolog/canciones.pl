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
:- include(catalogo_hechos).

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
