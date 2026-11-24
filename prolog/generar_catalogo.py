"""Regenera catalogo.csv y catalogo_hechos.pl desde fuentes identificadas."""

import argparse
import csv
import hashlib
import io
from collections import Counter
from dataclasses import dataclass
from pathlib import Path
from urllib.request import urlopen

CARPETA = Path(__file__).resolve().parent
REVISION = "635b034f69257814eff850a5c2b3346fe458134f"
FUENTE = "https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset"
CSV_URL = f"{FUENTE}/resolve/{REVISION}/dataset.csv"
HUELLA = "b202fa49909b2d5cef71a04b1d21243cfeb36414535f2ca9272aa646721177bd"
CUADRANTES = {
    (True, True): "feliz",
    (True, False): "tranquilo",
    (False, False): "melancolico",
    (False, True): "tenso",
}
IDIOMAS = {"espanol", "ingles"}


@dataclass
class Pista:
    id: str
    titulo: str
    artista: str
    genero: str
    cuadrante: str
    energia: str
    idioma: str
    url: str
    fuente_tipo: str
    fuente_url: str
    energia_spotify: str = ""
    valencia_spotify: str = ""
    popularidad_spotify: str = ""
    genero_dataset: str = ""
    evidencia_lastfm: str = ""
    url_lastfm: str = ""
    nota: str = ""


def leer_csv(nombre):
    with (CARPETA / nombre).open(encoding="utf-8-sig", newline="") as archivo:
        return list(csv.DictReader(archivo))


def leer_snapshot(ruta):
    if ruta:
        datos = ruta.read_bytes()
    else:
        with urlopen(CSV_URL, timeout=90) as respuesta:
            datos = respuesta.read()
    if hashlib.sha256(datos).hexdigest() != HUELLA:
        raise ValueError("El CSV no coincide con la revisión de Hugging Face documentada.")
    return csv.DictReader(io.StringIO(datos.decode("utf-8-sig"), newline=""))


def pistas_spotify(ruta):
    seleccion = leer_csv("seleccion.csv")
    ids = {fila["spotify_id"] for fila in seleccion}
    if len(ids) != len(seleccion):
        raise ValueError("Hay IDs repetidos en seleccion.csv.")
    filas = {}
    for fila in leer_snapshot(ruta):
        ident = fila["track_id"]
        if ident in ids:
            anterior = filas.get(ident)
            if anterior is None or int(fila["popularity"]) > int(anterior["popularity"]):
                filas[ident] = fila
    if faltantes := ids - filas.keys():
        raise ValueError(f"No se encontraron estos IDs: {sorted(faltantes)}")

    for entrada in seleccion:
        ident = entrada["spotify_id"]
        fila = filas[ident]
        alta = float(fila["energy"]) >= 0.5
        positiva = float(fila["valence"]) >= 0.5
        yield Pista(
            ident, fila["track_name"], fila["artists"].replace(";", " / "),
            entrada["genero"] or fila["track_genre"],
            CUADRANTES[positiva, alta], "alta" if alta else "baja",
            entrada["idioma"], f"https://open.spotify.com/track/{ident}",
            "spotify_dataset", f"{FUENTE}/blob/{REVISION}/dataset.csv",
            fila["energy"], fila["valence"], fila["popularity"], fila["track_genre"],
            entrada["evidencia_lastfm"], entrada["url_lastfm"],
        )


def atomo(texto):
    return "'" + texto.replace("\\", "\\\\").replace("'", "\\'") + "'"


def guardar(pistas):
    campos = list(Pista.__dataclass_fields__)
    with (CARPETA / "catalogo.csv").open("w", encoding="utf-8-sig", newline="") as archivo:
        escritor = csv.DictWriter(archivo, fieldnames=campos, lineterminator="\n")
        escritor.writeheader()
        escritor.writerows(vars(pista) for pista in pistas)

    hechos = ["% Generado por generar_catalogo.py.", "% cancion/8, fuente/3, datos_spotify/4 y contraste_lastfm/3."]
    for p in pistas:
        textos = map(atomo, (p.id, p.titulo, p.artista, p.genero))
        hechos.append(f"cancion({', '.join(textos)}, {p.cuadrante}, {p.energia}, {p.idioma}, {atomo(p.url)}).")
    hechos.append("")
    for p in pistas:
        hechos.append(f"fuente({atomo(p.id)}, {p.fuente_tipo}, {atomo(p.fuente_url)}).")
    hechos.append("")
    for p in pistas:
        if p.energia_spotify:
            hechos.append(f"datos_spotify({atomo(p.id)}, {p.energia_spotify}, {p.valencia_spotify}, {p.popularidad_spotify}).")
    hechos.append("")
    for p in pistas:
        if p.url_lastfm:
            hechos.append(f"contraste_lastfm({atomo(p.id)}, {atomo(p.evidencia_lastfm)}, {atomo(p.url_lastfm)}).")
    (CARPETA / "catalogo_hechos.pl").write_text("\n".join(hechos) + "\n", encoding="utf-8", newline="\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dataset", type=Path, help="Ruta al CSV original de Hugging Face")
    argumentos = parser.parse_args()
    spotify = list(pistas_spotify(argumentos.dataset))
    conteos = Counter((p.cuadrante, p.idioma) for p in spotify)
    esperados = {(cuadrante, idioma): 10 for cuadrante in CUADRANTES.values() for idioma in IDIOMAS}
    if conteos != esperados:
        raise ValueError(f"La selección debe reunir 10 canciones por cuadrante e idioma. Actual: {conteos}")
    pistas = spotify + [Pista(**fila, fuente_tipo="ficha_publica") for fila in leer_csv("pistas_locales.csv")]
    if len({p.id for p in pistas}) != len(pistas):
        raise ValueError("Hay IDs repetidos en el catálogo.")
    if len({(p.titulo.casefold(), p.artista.casefold()) for p in pistas}) != len(pistas):
        raise ValueError("Hay canciones repetidas por título y artista.")
    for p in pistas:
        if p.cuadrante not in CUADRANTES.values() or p.idioma not in IDIOMAS or p.energia not in {"baja", "alta"}:
            raise ValueError(f"Clasificación no válida: {p.titulo}")
    pistas.sort(key=lambda p: (p.cuadrante, p.idioma, p.artista.casefold(), p.titulo.casefold()))
    guardar(pistas)
    print(f"{len(pistas)} canciones exportadas, {len(spotify)} del conjunto de Spotify.")


if __name__ == "__main__":
    main()
