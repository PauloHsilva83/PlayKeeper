from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from pydantic import BaseModel
import yt_dlp
import os
import datetime

app = FastAPI(title="PlayKeeper API")

app.add_middleware(
    CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"],
)

TEMP_FOLDER = "downloads_temporarios"
os.makedirs(TEMP_FOLDER, exist_ok=True)

class DownloadRequest(BaseModel):
    url: str
    media_type: str 

@app.post("/api/extract")
async def extract_media(request: DownloadRequest):
    agora = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    nome_base = f"PlayKeeper_{agora}"
    caminho_saida = f"{TEMP_FOLDER}/{nome_base}.%(ext)s"

    ydl_opts = {
        'noplaylist': True, 
        'quiet': False, 
        'outtmpl': caminho_saida,
    }

    if request.media_type == "audio":
        ydl_opts['format'] = 'bestaudio/best'
        ydl_opts['postprocessors'] = [{'key': 'FFmpegExtractAudio', 'preferredcodec': 'mp3'}]
        nome_arquivo_real = f"{nome_base}.mp3"
    else:
        # A MÁGICA: O yt-dlp pega vídeo e áudio e chama o FFmpeg 8.1 do seu Windows para juntar!
        ydl_opts['format'] = 'bestvideo+bestaudio/best'
        ydl_opts['merge_output_format'] = 'mp4'
        nome_arquivo_real = f"{nome_base}.mp4"

    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            # download=True: O servidor baixa e processa!
            ydl.extract_info(request.url, download=True)
            
            # Devolvemos a URL interna para o aplicativo baixar o arquivo finalizado
            url_interna = f"http://10.0.2.2:8000/download_pronto/{nome_arquivo_real}"

            return {
                "sucesso": True,
                "titulo": nome_base,
                "url_direta": url_interna, 
                "tipo": request.media_type
            }
    except Exception as e:
        raise HTTPException(status_code=400, detail="Erro ao baixar ou converter o vídeo.")

@app.get("/download_pronto/{filename}")
async def serve_file(filename: str):
    file_path = os.path.join(TEMP_FOLDER, filename)
    if os.path.exists(file_path):
        return FileResponse(file_path)
    raise HTTPException(status_code=404, detail="Arquivo não encontrado.")