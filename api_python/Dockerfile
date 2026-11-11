# Usa uma imagem oficial do Python que já vem com as ferramentas básicas
FROM python:3.10-slim

# Instala o FFmpeg dentro do servidor do Render
RUN apt-get update && apt-get install -y ffmpeg && apt-get clean

# Define onde o nosso código vai ficar dentro da máquina deles
WORKDIR /app

# Copia todos os nossos arquivos do Python para dentro da máquina
COPY . /app

# Instala o FastAPI, yt-dlp, etc.
RUN pip install --no-cache-dir fastapi uvicorn yt-dlp pydantic

# Libera a porta e liga o Uvicorn
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]