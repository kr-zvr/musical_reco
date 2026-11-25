import json
import os
import subprocess
import time
from pathlib import Path

import requests
from dotenv import load_dotenv

load_dotenv()

modelo = os.getenv("GEMINI_MODEL", "gemini-3.5-flash-lite")
key = os.getenv("GEMINI_API_KEY")
URL = f"https://generativelanguage.googleapis.com/v1beta/models/{modelo}:generateContent"

# Ruta a las reglas de Prolog, sin importar desde dónde se ejecute el script
REGLAS = Path(__file__).parent / "prolog" / "reglas.pl"



def consultar_prolog(respuestas):
    """Pregunta a Prolog (llamando a swipl) y regresa el cuadrante y las 5 canciones."""
    meta = (
        "set_stream(user_output, encoding(utf8)), "  # Para que los acentos lleguen bien
        f"consult('{REGLAS.as_posix()}'), "
        f"recomendar_json({respuestas['animo']}, {respuestas['energia']}, "
        f"{respuestas['objetivo']}, {respuestas['actividad']}, "
        f"{respuestas['idioma']}, {respuestas['genero']}, Json), "
        "write(Json), nl"
    )
    try:
        proceso = subprocess.run(
            ["swipl", "-q", "-g", meta, "-t", "halt"],
            capture_output=True, text=True, encoding="utf-8", timeout=30,
        )
    except FileNotFoundError:
        raise RuntimeError("No se encontró swipl. Instala SWI-Prolog y agrégalo al PATH.")
    salida = proceso.stdout.strip()
    if proceso.returncode != 0 or not salida:
        return None
    return json.loads(salida)


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
    "urbano": "urbano (reggaetón, hip hop)",
    "baile": "bailable (disco, funk)",
    "soul_jazz": "soul o jazz",
}


def texto(valor):
    return TEXTOS.get(valor, valor)


def armar_prompt(respuestas, canciones):
    """Arma el mensaje para Gemini con el ánimo y las canciones de Prolog."""
    animo, energia, objetivo, actividad, idioma = (
        texto(respuestas[c]) for c in ("animo", "energia", "objetivo", "actividad", "idioma")
    )
    lista = "\n".join(f"- {c['titulo']} - {c['artista']}" for c in canciones)
    if not lista:
        lista = "(ninguna, no hubo canciones de la base para este caso)"
    genero = ""
    del_genero = ""
    if respuestas["genero"] != "cualquiera":
        genero = f" Le gusta el género {texto(respuestas['genero'])}."
        del_genero = f" del género {texto(respuestas['genero'])}"
    return (
        "Eres un recomendador de música cálido y cercano. Responde en español.\n\n"
        f"La persona se siente {animo}, tiene energía {energia}, "
        f"quiere {objetivo} su ánimo, va a {actividad} "
        f"y prefiere canciones en {idioma}.{genero}\n\n"
        f"Ya se le recomendaron estas canciones:\n{lista}\n\n"
        "1. Escribe un mensaje breve (1 o 2 oraciones) para la persona según cómo se siente: "
        "si está mal, dale ánimos; si está bien, celebra con ella. Háblale de tú.\n"
        f"2. Sugiere 3 canciones adicionales{del_genero} que encajen con ese estado de ánimo. "
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
    encabezados = {"x-goog-api-key": key, "Content-Type": "application/json"}

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
        "energia_buscada": prolog_datos["energia_buscada"],
        "canciones": prolog_datos["recomendaciones"],
        "mapa": prolog_datos["mapa"],
        "mensaje": None,
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
        "genero": "rock",
    }
    resultado = recomendar(respuestas)

    if resultado["mensaje"]:
        print(resultado["mensaje"] + "\n")
    print("Cuadrante:", resultado["cuadrante"])
    print("\nDe la base de conocimiento:")
    for cancion in resultado["canciones"]:
        print(f"- {cancion['titulo']} - {cancion['artista']}")
        print(f"  {cancion['explicacion']}")

    print("\nSugerencias de la IA:")
    if resultado["aviso"]:
        print(resultado["aviso"])
    else:
        for cancion in resultado["sugerencias_ia"]:
            print(f"- {cancion['titulo']} - {cancion['artista']}: {cancion['razon']}")
        t = resultado["tokens"]
        print(f"\nTiempo: {resultado['tiempo_ia']} s | Tokens: {t['entrada']} de entrada, "
              f"{t['salida']} de salida, {t['total']} en total")