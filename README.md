# RecoMusic

Proyecto final de Programación Lógica y Funcional.

Recomendador de canciones según el estado de ánimo. El usuario contesta 6 preguntas, Prolog elige hasta 5 canciones de su base de conocimiento usando el modelo de valencia y energía de Russell, y Gemini da un mensaje según el ánimo y sugiere 3 canciones más.

## Estructura

```
├── app.py                  Interfaz en Streamlit
├── recomendador.py         Conexión con Prolog (vía swipl) y Gemini
├── prolog/
│   ├── canciones.pl        Base de conocimiento (80 canciones)
│   ├── reglas.pl           Reglas de recomendación
│   └── pruebas.pl          Pruebas de la base y las reglas
├── .streamlit/
│   └── config.toml         Colores de la app (modo claro y oscuro)
├── .env.example            Plantilla de credenciales
└── requirements.txt        Librerías de Python
```

## Cómo funciona

1. **Preguntas:** ánimo, energía, objetivo (acompañar o cambiar el ánimo), actividad, idioma y género.
2. **Prolog:** cada canción tiene una energía y una valencia (de 0 a 1) tomadas del [Spotify Tracks Dataset](https://huggingface.co/datasets/maharshipandya/spotify-tracks-dataset). Con ellas, la regla `clasificacion` la ubica en uno de los 4 cuadrantes del modelo de Russell (1980): feliz, tranquilo, melancólico o tenso. Según las respuestas, Prolog decide qué cuadrante buscar, filtra por idioma y género, y ordena por la energía más cercana a la que pide la persona y su actividad.
3. **Gemini:** recibe las respuestas y las canciones de Prolog, y regresa un mensaje según el ánimo y 3 sugerencias más.
4. **La app** muestra el mensaje, una gráfica de valencia contra energía con las canciones recomendadas, y dos pestañas: las canciones de Prolog y las sugerencias de la IA.

Si se elige un género, solo salen canciones de ese género, así que pueden ser menos de 5 o ninguna. Si Gemini no responde, la app sigue mostrando las canciones de Prolog con un aviso.

## Requisitos

- Python 3.10 o superior
- [SWI-Prolog](https://www.swi-prolog.org/download/stable) (en Windows, marcar la opción de agregarlo al PATH)
- Una API key de [Google AI Studio](https://aistudio.google.com/apikey)

Para revisar que estén instalados, abrir una terminal nueva y ejecutar:
```
python --version
swipl --version
```
Si `swipl` marca error, ver [Solución de problemas](#solución-de-problemas).

## Instalación (solo la primera vez)

1. Clonar el repositorio:
   ```
   git clone https://github.com/kr-zvr/musical_reco.git
   cd musical_reco
   ```

2. Crear y activar un entorno virtual:
   ```powershell
   python -m venv venv
   .\venv\Scripts\Activate.ps1
   ```
   Debe aparecer `(venv)` al inicio de la línea.

   Si marca que "la ejecución de scripts está deshabilitada", ejecutar una vez:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
   ```

3. Instalar las librerías (con el venv activo):
   ```
   pip install -r requirements.txt
   ```

4. Crear el `.env` a partir de la plantilla:
   ```powershell
   Copy-Item .env.example .env
   ```
   Abrir `.env` y pegar la API key:
   ```
   GEMINI_API_KEY=tu_clave_aqui
   GEMINI_MODEL=gemini-3.5-flash-lite
   ```

## Cada vez que se trabaje en el proyecto

1. Abrir la terminal en la carpeta del proyecto.
2. Activar el entorno virtual:
   ```powershell
   .\venv\Scripts\Activate.ps1
   ```
3. Al terminar, desactivarlo (o cerrar la terminal):
   ```
   deactivate
   ```

## Uso

Todos los comandos se ejecutan desde la carpeta principal, con el venv activo.

Probar la base de conocimiento (deben pasar las 19 pruebas):
```
swipl -g run_tests -t halt prolog/pruebas.pl
```

Probar el backend (Prolog + Gemini) desde la terminal:
```
python recomendador.py
```

Ejecutar la aplicación:
```
streamlit run app.py
```

### Modo claro y oscuro

En el menú **⋮** de arriba a la derecha se elige entre **System**, **Light** y **Dark**. Los colores de cada modo están en `.streamlit/config.toml`; si se modifican, hay que reiniciar Streamlit.

## Agregar canciones

Cada canción necesita dos líneas en `prolog/canciones.pl`, con el título escrito exactamente igual en las dos:
```prolog
cancion('Título', 'Artista', genero, espanol).
medida('Título', 0.60, 0.80).   % energía, valencia
```
- El género tiene que existir en `familia/2` (al final del mismo archivo).
- El idioma es `espanol` o `ingles`.
- No hace falta reiniciar la app: la canción aparece en la siguiente consulta.
- Actualizar el número de canciones en la prueba `hay_80_canciones_sin_repetir` de `prolog/pruebas.pl`.

## Solución de problemas

### "swipl no se reconoce como nombre de un cmdlet"

SWI-Prolog no está en el PATH. En PowerShell:

1. Revisar si está instalado:
   ```powershell
   Test-Path "C:\Program Files\swipl\bin\swipl.exe"
   ```

2. Si responde `True`, agregarlo al PATH:
   ```powershell
   [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\Program Files\swipl\bin", "User")
   ```
   Cerrar la terminal, abrir una nueva y probar `swipl --version`.

3. Si responde `False`, buscar dónde quedó instalado:
   ```powershell
   Get-ChildItem "C:\Program Files*" -Recurse -Filter swipl.exe -ErrorAction SilentlyContinue | Select-Object FullName
   ```
   Si aparece una ruta, usar esa carpeta (la que termina en `\bin`) en el paso 2. Si no aparece nada, instalar SWI-Prolog y marcar la opción de agregarlo al PATH.

### La app dice "No se encontró swipl"

La terminal se abrió antes de agregar SWI-Prolog al PATH y no ve el cambio. Cerrar VS Code por completo (no solo la terminal), volver a abrirlo y probar `swipl --version` en una terminal nueva.

### La app no se ve con los colores verdes

Revisar que `config.toml` esté dentro de la carpeta `.streamlit` en la raíz del proyecto y reiniciar Streamlit (Ctrl+C y otra vez `streamlit run app.py`).

### Revisar que las librerías estén instaladas

Con el entorno virtual activo:
```
python -c "import streamlit, requests, dotenv; print('Todo instalado')"
```