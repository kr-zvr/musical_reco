:- encoding(utf8).
:- use_module(canciones).
:- use_module(library(http/json)).
:- use_module(library(plunit)).
:- use_module(library(pairs)).

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
