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