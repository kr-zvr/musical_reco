from concurrent.futures import ThreadPoolExecutor

import streamlit as st

st.set_page_config(page_title="Recomendador musical")


@st.cache_resource
def get_executor():
    return ThreadPoolExecutor(max_workers=1)


def _recomendar(respuestas):
    import recomendador  

    return recomendador.recomendar(respuestas)


def recomendar(respuestas):
    return get_executor().submit(_recomendar, respuestas).result()


ANIMOS = {
    "Feliz": "feliz",
    "Tranquilo": "tranquilo",
    "Triste": "triste",
    "Nostálgico": "nostalgico",
    "Estresado": "estresado",
    "Enojado": "enojado",
}
ENERGIAS = {"Baja": "baja", "Media": "media", "Alta": "alta"}
OBJETIVOS = {
    "Acompañar mi ánimo": "acompanar",
    "Cambiar mi ánimo": "cambiar",
}
ACTIVIDADES = {
    "Estudiar o trabajar": "estudio_trabajo",
    "Hacer ejercicio": "ejercicio",
    "Viajar": "viaje",
    "Descansar": "descansar",
}
IDIOMAS = {"Español": "espanol", "Inglés": "ingles", "Ambos": "ambos"}
GENEROS = {
    "Cualquiera": "cualquiera",
    "Pop": "pop",
    "Rock": "rock",
    "Urbano (reggaetón, hip hop)": "urbano",
    "Para bailar (disco, funk)": "baile",
    "Soul y jazz": "soul_jazz",
    "Cantautor": "cantautor",
}

CUADRANTES = {
    "feliz": "Feliz y enérgico",
    "tranquilo": "Tranquilo y relajado",
    "melancolico": "Melancólico",
    "tenso": "Tenso e intenso",
}

st.title("Recomendador de música")
st.caption(
    "Cuéntame cómo te sientes. Prolog elige 5 canciones de su base de "
    "conocimiento y Gemini te da un mensaje y 3 sugerencias más."
)

with st.form("preguntas"):
    animo = st.selectbox("¿Cómo te sientes hoy?", list(ANIMOS))
    energia = st.radio("¿Cuánta energía tienes?", list(ENERGIAS), horizontal=True, index=1)
    objetivo = st.radio("¿Qué quieres que haga la música?", list(OBJETIVOS))
    actividad = st.selectbox("¿Qué vas a hacer?", list(ACTIVIDADES))
    idioma = st.radio("¿En qué idioma?", list(IDIOMAS), horizontal=True)
    genero = st.selectbox("¿Qué tipo de música prefieres?", list(GENEROS))
    enviar = st.form_submit_button("Recomiéndame música", type="primary")

if enviar:
    respuestas = {
        "animo": ANIMOS[animo],
        "energia": ENERGIAS[energia],
        "objetivo": OBJETIVOS[objetivo],
        "actividad": ACTIVIDADES[actividad],
        "idioma": IDIOMAS[idioma],
        "genero": GENEROS[genero],
    }

    with st.spinner("Buscando canciones para ti..."):
        resultado = recomendar(respuestas)

    if resultado is None:
        st.error("Prolog no encontró recomendaciones para esas respuestas.")
        st.stop()

    if resultado["mensaje"]:
        st.info(resultado["mensaje"])

    st.subheader("Canciones para ti")
    st.caption(f"Cuadrante: {CUADRANTES.get(resultado['cuadrante'], resultado['cuadrante'])}")
    total = len(resultado["canciones"])
    if total == 0:
        st.info(f"No hay canciones de {genero} para este ánimo en la base de conocimiento.")
    elif total < 5:
        st.info(f"Solo hay {total} canciones de {genero} para este ánimo en la base de conocimiento.")
    for i, c in enumerate(resultado["canciones"], start=1):
        with st.container(border=True):
            st.markdown(f"**{i}. {c['titulo']}**  \n{c['artista']}")
            st.caption(f"{c['genero'].replace('_', ' ').title()} · {c['idioma']}")
            st.write(c["explicacion"])
            st.link_button("▶ Escuchar en YouTube", c["url"])

    st.subheader("Sugerencias de la IA")
    if resultado["aviso"]:
        st.warning(resultado["aviso"])
    else:
        for c in resultado["sugerencias_ia"]:
            with st.container(border=True):
                st.markdown(f"**{c['titulo']}** — {c['artista']}")
                st.write(c["razon"])
        t = resultado["tokens"]
        st.caption(
            f"Tiempo de la IA: {resultado['tiempo_ia']} s · Tokens: "
            f"{t['entrada']} entrada, {t['salida']} salida, {t['total']} total"
        )
