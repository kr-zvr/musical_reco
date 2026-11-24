# Proyecto final - Programación Lógica y Funcional

Recomendador de canciones según el estado de ánimo. El usuario contesta unas preguntas, Prolog elige 5 canciones de su base de conocimiento y Gemini da un mensaje según el ánimo y sugiere canciones adicionales.

## Estructura

```
├── app.py              Interfaz en Streamlit
├── recomendador.py     Conexión con Prolog y Gemini
├── prolog/
│   ├── canciones.pl    Base de conocimiento (82 canciones)
│   ├── reglas.pl       Reglas de recomendación
│   └── pruebas.pl      Pruebas de la base
├── .env.example        Plantilla de credenciales
└── requirements.txt    Librerías de Python
```

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

Probar la base de conocimiento:
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

### Revisar que las librerías estén instaladas

Con el entorno virtual activo:
```
python -c "import streamlit, pyswip, requests, dotenv; print('Todo instalado')"
python -c "from pyswip import Prolog; print('pyswip OK')"
```