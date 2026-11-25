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
    recomendar(feliz, media, acompanar, descansar, ingles, cualquiera, [Descanso|_]),
    recomendar(feliz, media, acompanar, ejercicio, ingles, cualquiera, [Ejercicio|_]),
    medida(Descanso, EnergiaDescanso, _),
    medida(Ejercicio, EnergiaEjercicio, _),
    assertion(EnergiaEjercicio > EnergiaDescanso).

% --- Respuestas inválidas

test(rechaza_animo_desconocido, [fail]) :-
    recomendar(sorprendido, media, acompanar, viaje, ambos, cualquiera, _).

test(rechaza_idioma_desconocido, [fail]) :-
    recomendar(feliz, media, acompanar, viaje, frances, cualquiera, _).

test(rechaza_actividad_desconocida, [fail]) :-
    recomendar(feliz, media, acompanar, cocinar, ambos, cualquiera, _).

test(rechaza_genero_desconocido, [fail]) :-
    recomendar(feliz, media, acompanar, viaje, ambos, polka, _).

% --- Género

test(con_genero_solo_salen_de_ese_genero) :-
    recomendar(feliz, media, acompanar, viaje, ambos, baile, Titulos),
    Titulos \== [],
    forall(member(T, Titulos),
           ( cancion(T, _, Genero, _), assertion(familia(Genero, baile)) )).

test(si_hay_pocas_del_genero_salen_menos_de_5) :-
    recomendar(feliz, media, acompanar, viaje, espanol, rock, Titulos),
    assertion(Titulos == ['Impacto', 'Que Pasará']).

test(si_no_hay_del_genero_sale_vacio) :-
    recomendar(enojado, alta, acompanar, viaje, espanol, soul_jazz, Titulos),
    assertion(Titulos == []).

% --- Explicación

test(explica_por_que_se_recomienda, [nondet]) :-
    explicacion('Pausa', 0.225, cualquiera, Texto),
    assertion(sub_atom(Texto, 0, _, _, 'Es melancólica porque suena triste')).

test(explicacion_menciona_el_genero, [nondet]) :-
    explicacion('Pausa', 0.225, rock, Si),
    assertion(sub_atom(Si, _, _, _, 'Además es del género que elegiste.')),
    explicacion('Pausa', 0.225, cualquiera, Sin),
    assertion(\+ sub_atom(Sin, _, _, _, 'género')).

% --- Salida para Python

test(json_para_python, [nondet]) :-
    recomendar_json(enojado, alta, acompanar, viaje, espanol, cualquiera, Json),
    atom_json_dict(Json, Datos, [value_string_as(atom)]),
    assertion(Datos.cuadrante == tenso),
    length(Datos.recomendaciones, 5),
    forall(member(R, Datos.recomendaciones), assertion(atom(R.explicacion))).

% --- Todas las combinaciones de respuestas

test(todas_las_combinaciones_dan_canciones_correctas) :-
    forall(( estado(A, _, _), energia_usuario(E, _), objetivo(O),
             energia_actividad(C, _), idioma(I), genero_preferido(G) ),
           ( findall(R, recomendar(A, E, O, C, I, G, R), [Titulos]),
             length(Titulos, N),
             ( G == cualquiera -> assertion(N == 5) ; assertion(N =< 5) ),
             sort(Titulos, Unicos), length(Unicos, N),
             cuadrante_objetivo(A, E, O, Cuadrante),
             forall(member(T, Titulos),
                    ( assertion(clasificacion(T, Cuadrante, _)),
                      cancion(T, _, Genero, Idioma),
                      assertion(coincide_idioma(I, Idioma)),
                      assertion(coincide_genero(G, Genero)) )) )).

:- end_tests(recomendador).
