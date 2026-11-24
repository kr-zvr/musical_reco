% Pruebas del recomendador.
% Se corren con:  swipl pruebas.pl   y luego   ?- run_tests.

:- encoding(utf8).
:- ensure_loaded(reglas).
:- use_module(library(plunit)).

:- begin_tests(recomendador).

test(catalogo_de_82_canciones_sin_repetir) :-
    findall(T, cancion(T, _, _, _), Titulos),
    length(Titulos, 82),
    sort(Titulos, Unicos),
    length(Unicos, 82).

test(cada_cancion_tiene_una_sola_clasificacion) :-
    forall(cancion(T, _, _, _),
           ( findall(C-N, clasificacion(T, C, N), [_]),
             assertion(once(energia_numerica(T, _))) )).

test(solo_the_bugambilias_es_editorial) :-
    aggregate_all(count, medida(_, _, _), 80),
    forall(clasificacion_editorial(T, _, _),
           ( assertion(cancion(T, 'The Bugambilias', _, _)),
             assertion(\+ medida(T, _, _)) )).

test(cada_cancion_tiene_enlace) :-
    forall(cancion(T, _, _, _), assertion(once(enlace(T, _)))).

test(cada_genero_tiene_familia) :-
    forall(cancion(T, _, G, _), assertion((familia(G, _), T \== ''))).

test(datos_auxiliares_apuntan_a_canciones) :-
    forall(medida(T, _, _), assertion(cancion(T, _, _, _))),
    forall(contrastada_lastfm(T), assertion(cancion(T, _, _, _))).

test(al_menos_10_por_cuadrante_e_idioma) :-
    forall(( member(C, [feliz, tranquilo, melancolico, tenso]),
             member(I, [espanol, ingles]) ),
           ( aggregate_all(count,
                           (cancion(T, _, _, I), clasificacion(T, C, _)), N),
             assertion(N >= 10) )).

test(energia_media_usa_la_activacion_tipica_del_animo) :-
    findall(A-C, cuadrante_objetivo(A, media, acompanar, C),
            [feliz-feliz, tranquilo-tranquilo, triste-melancolico,
             nostalgico-melancolico, estresado-tenso, enojado-tenso]).

test(acompanar_responde_a_energia_explicita, [nondet]) :-
    cuadrante_objetivo(feliz, baja, acompanar, tranquilo),
    cuadrante_objetivo(triste, alta, acompanar, tenso).

test(cambiar_sube_el_animo_o_calma) :-
    cuadrante_objetivo(triste, baja, cambiar, feliz),
    cuadrante_objetivo(estresado, alta, cambiar, tranquilo),
    cuadrante_objetivo(enojado, alta, cambiar, tranquilo).

test(la_actividad_cambia_el_orden) :-
    recomendar(feliz, media, acompanar, descansar, ingles, [Descanso|_]),
    recomendar(feliz, media, acompanar, ejercicio, ingles, [Ejercicio|_]),
    medida(Descanso.titulo, EnergiaDescanso, _),
    medida(Ejercicio.titulo, EnergiaEjercicio, _),
    assertion(EnergiaEjercicio > EnergiaDescanso).

test(idioma_ambos) :-
    recomendar(feliz, alta, acompanar, viaje, ambos, Resultados),
    length(Resultados, 5).

test(el_genero_preferido_va_primero) :-
    recomendar(feliz, media, acompanar, viaje, ambos, baile, [Primera|_]),
    assertion(familia(Primera.genero, baile)).

test(genero_sin_coincidencias_aun_da_5) :-
    \+ ( cancion(T, _, G, espanol), clasificacion(T, tenso, _), familia(G, soul_jazz) ),
    recomendar(enojado, alta, acompanar, viaje, espanol, soul_jazz, Resultados),
    length(Resultados, 5).

test(rechaza_animo_desconocido, [fail]) :-
    recomendar(sorprendido, media, acompanar, viaje, ambos, _).

test(rechaza_energia_desconocida, [fail]) :-
    recomendar(feliz, maxima, acompanar, viaje, ambos, _).

test(rechaza_objetivo_desconocido, [fail]) :-
    recomendar(feliz, media, inventar, viaje, ambos, _).

test(rechaza_actividad_desconocida, [fail]) :-
    recomendar(feliz, media, acompanar, cocinar, ambos, _).

test(rechaza_idioma_desconocido, [fail]) :-
    recomendar(feliz, media, acompanar, viaje, frances, _).

test(rechaza_genero_desconocido, [fail]) :-
    recomendar(feliz, media, acompanar, viaje, ambos, polka, _).

test(pide_todas_las_respuestas, [fail]) :-
    recomendar(feliz, media, acompanar, viaje, _, _).

test(recomienda_las_dos_de_the_bugambilias) :-
    recomendar(nostalgico, baja, acompanar, descansar, espanol, ParaDescansar),
    recomendar(enojado, alta, acompanar, viaje, espanol, ParaViajar),
    assertion(contiene_titulo(ParaDescansar, 'Magenta')),
    assertion(contiene_titulo(ParaViajar, 'Escapista de lo evidente')).

test(json_con_titulos_y_datos) :-
    recomendar_json(enojado, alta, acompanar, viaje, espanol, rock, Json),
    atom_json_dict(Json, Datos, [value_string_as(atom)]),
    assertion(Datos.cuadrante == tenso),
    length(Datos.recomendaciones, 5),
    forall(member(R, Datos.recomendaciones),
           ( atom_string(G, R.genero), atom_string(I, R.idioma),
             assertion(cancion(R.titulo, R.artista, G, I)) )).

test(todas_las_combinaciones) :-
    findall(p(A, E, O, C, I, G), perfil_valido(A, E, O, C, I, G), Perfiles),
    length(Perfiles, 3024),
    forall(member(p(A, E, O, C, I, G), Perfiles), verifica_perfil(A, E, O, C, I, G)).

contiene_titulo(Resultados, Titulo) :-
    once((member(R, Resultados), R.titulo == Titulo)).

verifica_perfil(A, E, O, C, I, G) :-
    findall(R, recomendar(A, E, O, C, I, G, R), [Resultados]),
    length(Resultados, 5),
    findall(T, (member(X, Resultados), T = X.titulo), Titulos),
    sort(Titulos, Unicos),
    length(Unicos, 5),
    once(cuadrante_objetivo(A, E, O, Cuadrante)),
    forall(member(X, Resultados),
           ( assertion(X.cuadrante == Cuadrante),
             assertion((I == ambos ; X.idioma == I)) )).

:- end_tests(recomendador).
