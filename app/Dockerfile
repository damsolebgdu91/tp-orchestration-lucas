FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Bonne pratique sécurité : ne pas tourner en root dans le conteneur.
RUN useradd --create-home appuser
USER appuser

EXPOSE 8080

CMD ["python", "app.py"]
