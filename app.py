import altair as alt
import pandas as pd
import streamlit as st

from recomendador import recomendar

st.set_page_config(page_title="RecoMusic", layout="wide")

# Texto que ve el usuario -> valor que recibe Prolog
ANIMOS = {
    "Feliz": "feliz",
    "Tranquilo": "tranquilo",
    "Triste": "triste",
    "Nostálgico": "nostalgico",
    "Estresado": "estresado",
    "Enojado": "enojado",
}
ENERGIAS = {"Baja": "baja", "Media": "media", "Alta": "alta"}
OBJETIVOS = {"Acompañar mi ánimo": "acompanar", "Cambiar mi ánimo": "cambiar"}
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
    "Urbano": "urbano",
    "Para bailar": "baile",
    "Soul y jazz": "soul_jazz",
    "Cantautor": "cantautor",
}

CUADRANTES = {
    "feliz": "Feliz",
    "tranquilo": "Tranquilo",
    "melancolico": "Melancólico",
    "tenso": "Tenso",
}

# Zona de cada cuadrante en la gráfica: (valencia mín, valencia máx, energía mín, energía máx)
ZONAS = {
    "feliz": (0.5, 1, 0.5, 1),
    "tranquilo": (0.5, 1, 0, 0.5),
    "melancolico": (0, 0.5, 0, 0.5),
    "tenso": (0, 0.5, 0.5, 1),
}

# Colores de la gráfica y del banner. Son tonos intermedios y semitransparentes
# para que se vean bien tanto en modo claro como en modo oscuro.
COLORES = {
    "acento": "#2F8A5B",      # canciones recomendadas y zona del ánimo
    "otras": "#8A9A90",       # resto de canciones (se dibujan semitransparentes)
    "lineas": "#8A9A90",      # divisiones de cuadrantes
    "etiquetas": "#7F9587",   # nombres de cuadrantes
    "buscada": "#D08A22",     # línea de energía buscada
}

# Menos espacio en blanco arriba y un banner compacto para el mensaje de Gemini
st.markdown(
    f"""
    <style>
    .block-container {{padding-top: 1.5rem; padding-bottom: 1rem;}}
    .banner-ia {{
        background: rgba(47, 138, 91, 0.14); color: inherit;
        border-left: 4px solid {COLORES["acento"]}; border-radius: 0.5rem;
        padding: 0.6rem 1rem; margin-bottom: 0.75rem; font-size: 0.95rem;
    }}
    </style>
    """,
    unsafe_allow_html=True,
)


def grafica_russell(resultado):
    """Plano de Russell: todas las canciones en gris y las recomendadas resaltadas."""
    recomendadas = {c["titulo"] for c in resultado["canciones"]}
    puntos = pd.DataFrame(resultado["mapa"])
    puntos["tipo"] = puntos["titulo"].map(
        lambda t: "Recomendada" if t in recomendadas else "Otra canción"
    )

    v1, v2, e1, e2 = ZONAS[resultado["cuadrante"]]
    zona = alt.Chart(pd.DataFrame([{"v1": v1, "v2": v2, "e1": e1, "e2": e2}])).mark_rect(
        opacity=0.18, color=COLORES["acento"]
    ).encode(x="v1:Q", x2="v2", y="e1:Q", y2="e2")

    lineas = alt.Chart(pd.DataFrame([{"x": 0.5}])).mark_rule(color=COLORES["lineas"], opacity=0.6).encode(x="x:Q") + \
        alt.Chart(pd.DataFrame([{"y": 0.5}])).mark_rule(color=COLORES["lineas"], opacity=0.6).encode(y="y:Q")

    def etiquetas_cuadrantes(filas, alinear):
        return alt.Chart(pd.DataFrame(filas)).mark_text(
            color=COLORES["etiquetas"], fontSize=13, fontWeight="bold", align=alinear
        ).encode(x="x:Q", y="y:Q", text="texto:N")

    etiquetas = etiquetas_cuadrantes([
        {"x": 0.97, "y": 0.97, "texto": "Feliz"},
        {"x": 0.97, "y": 0.03, "texto": "Tranquilo"},
    ], "right") + etiquetas_cuadrantes([
        {"x": 0.03, "y": 0.03, "texto": "Melancólico"},
        {"x": 0.03, "y": 0.97, "texto": "Tenso"},
    ], "left")

    buscada = alt.Chart(pd.DataFrame([{"y": resultado["energia_buscada"]}])).mark_rule(
        strokeDash=[6, 4], color=COLORES["buscada"]
    ).encode(y="y:Q")

    ejes = alt.Axis(values=[0, 0.25, 0.5, 0.75, 1], format=".2f")
    canciones = alt.Chart(puntos).mark_circle().encode(
        x=alt.X("valencia:Q", title="Valencia (triste → alegre)",
                scale=alt.Scale(domain=[0, 1]), axis=ejes),
        y=alt.Y("energia:Q", title="Energía (calmada → intensa)",
                scale=alt.Scale(domain=[0, 1]), axis=ejes),
        color=alt.Color(
            "tipo:N",
            scale=alt.Scale(domain=["Recomendada", "Otra canción"], range=[COLORES["acento"], COLORES["otras"]]),
            legend=alt.Legend(title=None, orient="bottom"),
        ),
        size=alt.condition(alt.datum.tipo == "Recomendada", alt.value(160), alt.value(45)),
        opacity=alt.condition(alt.datum.tipo == "Recomendada", alt.value(1), alt.value(0.45)),
        order=alt.Order("tipo:N", sort="descending"),
        tooltip=[
            alt.Tooltip("titulo:N", title="Canción"),
            alt.Tooltip("valencia:Q", title="Valencia", format=".2f"),
            alt.Tooltip("energia:Q", title="Energía", format=".2f"),
        ],
    )

    return (zona + lineas + etiquetas + buscada + canciones).properties(height=340)


def tarjeta_cancion(numero, c):
    """Tarjeta compacta: título (link a YouTube) y artista; abajo género, valencia y energía."""
    genero = c["genero"].replace("_", " ").title()
    with st.container(border=True):
        st.markdown(
            f"**{numero}. [{c['titulo']}]({c['url']})** · {c['artista']}  \n"
            f":green[{genero}] · :gray[Valencia {c['valencia']:.2f} · Energía {c['energia']:.2f}]"
        )


# --- Barra lateral: las preguntas

with st.sidebar:
    st.header("Cuéntame cómo estás")
    with st.form("preguntas", border=False):
        animo = st.pills("Ánimo", list(ANIMOS), default="Feliz")
        energia = st.pills("Energía", list(ENERGIAS), default="Media")
        objetivo = st.pills("Objetivo", list(OBJETIVOS), default="Acompañar mi ánimo")
        actividad = st.pills("Actividad", list(ACTIVIDADES), default="Viajar")
        idioma = st.pills("Idioma", list(IDIOMAS), default="Ambos")
        genero = st.pills("Género", list(GENEROS), default="Cualquiera")
        enviar = st.form_submit_button("Recomendar", type="primary", width="stretch")

    if enviar:
        if None in (animo, energia, objetivo, actividad, idioma, genero):
            st.warning("Elige una opción en cada pregunta.")
        else:
            respuestas = {
                "animo": ANIMOS[animo],
                "energia": ENERGIAS[energia],
                "objetivo": OBJETIVOS[objetivo],
                "actividad": ACTIVIDADES[actividad],
                "idioma": IDIOMAS[idioma],
                "genero": GENEROS[genero],
            }
            with st.spinner("Buscando canciones..."):
                st.session_state["resultado"] = recomendar(respuestas)
                st.session_state["genero"] = genero

# --- Área principal: los resultados

st.title("RecoMusic")

resultado = st.session_state.get("resultado")

if "resultado" not in st.session_state:
    st.info("Elige tus respuestas en el panel de la izquierda y presiona **Recomendar**.")
elif resultado is None:
    st.error("Prolog no encontró recomendaciones para esas respuestas.")
else:
    if resultado["mensaje"]:
        st.markdown(f'<div class="banner-ia">{resultado["mensaje"]}</div>', unsafe_allow_html=True)

    izquierda, derecha = st.columns([55, 45], gap="large")

    with izquierda:
        st.markdown(f"**Mapa de emociones** · ánimo buscado: {CUADRANTES[resultado['cuadrante']]}")
        st.altair_chart(grafica_russell(resultado))
        st.caption("Zona sombreada: el ánimo buscado. Línea punteada: la energía que pediste. "
                   "En gris, el resto de la base (incluye otros idiomas y géneros).")

    with derecha:
        total = len(resultado["canciones"])
        sugerencias = resultado["sugerencias_ia"] or []
        tab_prolog, tab_ia = st.tabs([f"Prolog ({total})", f"IA ({len(sugerencias)})"])

        with tab_prolog:
            genero_elegido = st.session_state["genero"]
            if total == 0:
                st.info(f"No hay canciones de {genero_elegido} para este ánimo "
                        "en la base de conocimiento.")
            elif total < 5:
                st.info(f"Solo hay {total} canciones de {genero_elegido} para este ánimo "
                        "en la base de conocimiento.")
            for numero, c in enumerate(resultado["canciones"], start=1):
                tarjeta_cancion(numero, c)
            if total:
                st.caption("Haz clic en el título para escucharla en YouTube.")

        with tab_ia:
            if resultado["aviso"]:
                st.warning(resultado["aviso"])
            else:
                for c in sugerencias:
                    with st.container(border=True):
                        st.markdown(f"**{c['titulo']}** · {c['artista']}  \n:gray[{c['razon']}]")
                t = resultado["tokens"]
                st.caption(
                    f"Tiempo de la IA: {resultado['tiempo_ia']} s · Tokens: "
                    f"{t['entrada']} entrada, {t['salida']} salida, {t['total']} total"
                )
