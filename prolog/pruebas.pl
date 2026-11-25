% Pruebas del recomendador.
% Se corren con:  swipl -g run_tests -t halt prolog/pruebas.pl

:- encoding(utf8).
:- ensure_loaded(reglas).
:- use_module(library(plunit)).

:- begin_tests(recomendador).

% --- La base de conocimiento

test(hay_80_canciones_sin_repetir) :-
    findall(T, cancion(T, _, _, _), Titulos),
    length(Titulos, 80),
    sort(Titulos, Unicos),
    length(Unicos, 80).

test(cada_cancion_tiene_medida_y_familia) :-
    forall(cancion(T, _, G, _),
           ( assertion(medida(T, _, _)),
             assertion(familia(G, _)) )).

test(al_menos_10_por_cuadrante_e_idioma) :-
    forall(( member(C, [feliz, tranquilo, melancolico, tenso]),
             member(I, [espanol, ingles]) ),
           ( aggregate_all(count, (cancion(T, _, _, I), clasificacion(T, C, _)), N),
             assertion(N >= 10) )).

% --- Las reglas

test(clasifica_por_energia_y_valencia, [nondet]) :-
    clasificacion('Creep', melancolico, baja),
    clasificacion('Gasolina', feliz, alta).

test(acompanar_con_energia_media_usa_la_habitual, [nondet]) :-
    cuadrante_objetivo(nostalgico, media, acompanar, melancolico),
    cuadrante_objetivo(enojado, media, acompanar, tenso).

test(acompanar_respeta_la_energia_que_dice_la_persona, [nondet]) :-
    cuadrante_objetivo(feliz, baja, acompanar, tranquilo),
    cuadrante_objetivo(triste, alta, acompanar, tenso).

test(cambiar_sube_el_animo_o_calma) :-
    cuadrante_objetivo(triste, baja, cambiar, feliz),
    cuadrante_objetivo(estresado, alta, cambiar, tranquilo).

test(la_actividad_cambia_el_orden, [nondet]) :-
    recomendar(feliz, media, acompanar, descansar, ingles, [Descanso|_]),
    recomendar(feliz, media, acompanar, ejercicio, ingles, [Ejercicio|_]),
    medida(Descanso, EnergiaDescanso, _),
    medida(Ejercicio, EnergiaEjercicio, _),
    assertion(EnergiaEjercicio > EnergiaDescanso).

% --- Respuestas inválidas

test(rechaza_animo_desconocido, [fail]) :-
    recomendar(sorprendido, media, acompanar, viaje, ambos, _).

test(rechaza_idioma_desconocido, [fail]) :-
    recomendar(feliz, media, acompanar, viaje, frances, _).

test(rechaza_actividad_desconocida, [fail]) :-
    recomendar(feliz, media, acompanar, cocinar, ambos, _).

% --- Salida para Python

test(json_para_python, [nondet]) :-
    recomendar_json(enojado, alta, acompanar, viaje, espanol, Json),
    atom_json_dict(Json, Datos, [value_string_as(atom)]),
    assertion(Datos.cuadrante == tenso),
    length(Datos.recomendaciones, 5).

% --- Todas las combinaciones de respuestas

test(todas_las_combinaciones_dan_5_canciones_correctas) :-
    forall(( estado(A, _, _), energia_usuario(E, _), objetivo(O),
             energia_actividad(C, _), idioma(I) ),
           ( findall(R, recomendar(A, E, O, C, I, R), [Titulos]),
             length(Titulos, 5),
             sort(Titulos, Unicos), length(Unicos, 5),
             cuadrante_objetivo(A, E, O, Cuadrante),
             forall(member(T, Titulos),
                    ( assertion(clasificacion(T, Cuadrante, _)),
                      cancion(T, _, _, Idioma),
                      assertion(coincide_idioma(I, Idioma)) )) )).

:- end_tests(recomendador).
