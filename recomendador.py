import json
import os
import time
from pathlib import Path

import requests
from dotenv import load_dotenv
from pyswip import Prolog

load_dotenv()

API_KEY = os.getenv("GEMINI_API_KEY")
MODELO = os.getenv("GEMINI_MODEL", "gemini-3.5-flash-lite")
URL = f"https://generativelanguage.googleapis.com/v1beta/models/{MODELO}:generateContent"

# Ruta a las reglas de Prolog, sin importar desde dónde se ejecute el script
REGLAS = Path(__file__).parent / "prolog" / "reglas.pl"

prolog = Prolog()
prolog.consult(REGLAS.as_posix())


def consultar_prolog(respuestas):
    """Pregunta a Prolog y regresa el cuadrante y las 5 canciones."""
    consulta = (
        f"recomendar_json({respuestas['animo']}, {respuestas['energia']}, "
        f"{respuestas['objetivo']}, {respuestas['actividad']}, "
        f"{respuestas['idioma']}, Json)"
    )
    resultado = list(prolog.query(consulta, maxresult=1))
    if not resultado:
        return None
    return json.loads(resultado[0]["Json"])


# Cómo se escribe cada respuesta en el prompt (Prolog no usa acentos)
TEXTOS = {
    "nostalgico": "nostálgico",
    "acompanar": "acompañar",
    "estudio_trabajo": "estudiar o trabajar",
    "ejercicio": "hacer ejercicio",
    "viaje": "viajar",
    "espanol": "español",
    "ingles": "inglés",
    "ambos": "español o inglés",
}


# Mensajes por si Gemini no responde
MENSAJES_RESPALDO = {
    "feliz": "¡Qué bueno que te sientes así! Aquí tienes música para seguir con esa energía.",
    "tranquilo": "Disfruta ese momento de calma, te lo mereces.",
    "triste": "Está bien no estar bien. Date tu tiempo, esto también va a pasar.",
    "nostalgico": "Recordar también es una forma de querer. Deja que la música te acompañe.",
    "estresado": "Respira hondo, una cosa a la vez. Ya estás haciendo lo que puedes.",
    "enojado": "Es válido sentirte así. Saca esa energía y luego date un respiro.",
}


def texto(valor):
    return TEXTOS.get(valor, valor)


def armar_prompt(respuestas, canciones):
    """Arma el mensaje para Gemini con el ánimo y las 5 canciones de Prolog."""
    animo, energia, objetivo, actividad, idioma = (
        texto(respuestas[c]) for c in ("animo", "energia", "objetivo", "actividad", "idioma")
    )
    lista = "\n".join(f"- {c['titulo']} - {c['artista']}" for c in canciones)
    return (
        "Eres un recomendador de música cálido y cercano. Responde en español.\n\n"
        f"La persona se siente {animo}, tiene energía {energia}, "
        f"quiere {objetivo} su ánimo, va a {actividad} "
        f"y prefiere canciones en {idioma}.\n\n"
        f"Ya se le recomendaron estas canciones:\n{lista}\n\n"
        "1. Escribe un mensaje breve (1 o 2 oraciones) para la persona según cómo se siente: "
        "si está mal, dale ánimos; si está bien, celebra con ella. Háblale de tú.\n"
        "2. Sugiere 3 canciones adicionales que encajen con ese estado de ánimo. "
        "Solo canciones reales y muy conocidas, sin repetir las de la lista.\n\n"
        "Responde solo con un JSON con esta forma:\n"
        '{"mensaje": "...", "canciones": [{"titulo": "...", "artista": "...", "razon": "..."}]}'
    )


def consultar_gemini(respuestas, canciones):
    """Pide sugerencias a Gemini y mide cuánto tarda y cuántos tokens gasta."""
    cuerpo = {
        "contents": [{"parts": [{"text": armar_prompt(respuestas, canciones)}]}],
        "generationConfig": {"responseMimeType": "application/json"},  # Pide JSON
    }
    encabezados = {"x-goog-api-key": API_KEY, "Content-Type": "application/json"}

    inicio = time.perf_counter()
    respuesta = requests.post(URL, headers=encabezados, json=cuerpo, timeout=30)
    tiempo = time.perf_counter() - inicio

    respuesta.raise_for_status()  # Lanza un error si Gemini respondió mal (por ejemplo, 429)
    datos = respuesta.json()
    uso = datos.get("usageMetadata", {})
    contenido = json.loads(datos["candidates"][0]["content"]["parts"][0]["text"])

    return {
        "mensaje": contenido["mensaje"],
        "canciones": contenido["canciones"],
        "tiempo": round(tiempo, 2),
        "tokens_entrada": uso.get("promptTokenCount", 0),
        "tokens_salida": uso.get("candidatesTokenCount", 0),
        "tokens_total": uso.get("totalTokenCount", 0),
    }


def recomendar(respuestas):
    """Une Prolog y Gemini. Si Gemini falla, regresa solo las canciones de Prolog."""
    prolog_datos = consultar_prolog(respuestas)
    if prolog_datos is None:
        return None  # Alguna respuesta no es válida

    resultado = {
        "cuadrante": prolog_datos["cuadrante"],
        "canciones": prolog_datos["recomendaciones"],
        "mensaje": MENSAJES_RESPALDO[respuestas["animo"]],
        "sugerencias_ia": None,
        "aviso": None,
        "tiempo_ia": None,
        "tokens": None,
    }

    try:
        ia = consultar_gemini(respuestas, prolog_datos["recomendaciones"])
        resultado["mensaje"] = ia["mensaje"]
        resultado["sugerencias_ia"] = ia["canciones"]
        resultado["tiempo_ia"] = ia["tiempo"]
        resultado["tokens"] = {
            "entrada": ia["tokens_entrada"],
            "salida": ia["tokens_salida"],
            "total": ia["tokens_total"],
        }
    except requests.HTTPError as error:
        if error.response.status_code == 429:
            resultado["aviso"] = "Se alcanzó el límite de la IA. Intenta en un minuto."
        else:
            resultado["aviso"] = "Las sugerencias de la IA no están disponibles."
    except requests.RequestException:
        resultado["aviso"] = "No se pudo conectar con la IA. Revisa tu conexión."
    except (ValueError, KeyError):
        resultado["aviso"] = "La IA respondió en un formato inesperado."

    return resultado


if __name__ == "__main__":
    respuestas = {
        "animo": "nostalgico",
        "energia": "baja",
        "objetivo": "acompanar",
        "actividad": "descansar",
        "idioma": "espanol",
    }
    resultado = recomendar(respuestas)

    print(resultado["mensaje"])
    print("\nCuadrante:", resultado["cuadrante"])
    print("\nDe la base de conocimiento:")
    for cancion in resultado["canciones"]:
        print(f"- {cancion['titulo']} - {cancion['artista']}")

    print("\nSugerencias de la IA:")
    if resultado["aviso"]:
        print(resultado["aviso"])
    else:
        for cancion in resultado["sugerencias_ia"]:
            print(f"- {cancion['titulo']} - {cancion['artista']}: {cancion['razon']}")
        t = resultado["tokens"]
        print(f"\nTiempo: {resultado['tiempo_ia']} s | Tokens: {t['entrada']} de entrada, "
              f"{t['salida']} de salida, {t['total']} en total")