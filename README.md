# Proyecto final - Programación Lógica y Funcional

Recomendador de canciones según el estado de ánimo. El usuario contesta unas preguntas, Prolog elige 5 canciones de su base de conocimiento y Gemini sugiere canciones adicionales.

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

Para revisar que SWI-Prolog esté en el PATH, abrir una terminal nueva y ejecutar:
```
swipl --version
```
Si marca error, ver [Solución de problemas](#solución-de-problemas).

## Instalación

1. Clonar el repositorio:
   ```
   git clone https://github.com/SebasR0R/prolog_proyecto.git
   cd prolog_proyecto
   ```

2. Instalar las librerías:
   ```
   pip install -r requirements.txt
   ```

3. Copiar `.env.example`, renombrarlo a `.env` y pegar la API key:
   ```
   GEMINI_API_KEY=tu_clave_aqui
   ```

## Uso

Probar la base de conocimiento:
```
cd prolog
swipl -g run_tests -t halt pruebas.pl
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

### Revisar que Python encuentre Prolog

```
python -c "from pyswip import Prolog; print('pyswip OK')"
```