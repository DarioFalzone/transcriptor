# 💼 Casos de Uso Reales - Ejemplos Prácticos

## 📱 Caso 1: WhatsApp Voice Notes Automático

### Escenario
Quieres que cada nota de voz que descargas de WhatsApp se transcriba automáticamente.

### Setup

```bash
#!/bin/bash
# setup_whatsapp_monitor.sh

# 1. Detectar carpeta de descargas de WhatsApp
WHATSAPP_DIR="$HOME/.local/share/evolution/drive/SMB/1/Desktop/WhatsApp Documents"
TRANSCRIPT_DIR="$HOME/Documentos/Transcripciones"

# 2. Crear directorio
mkdir -p "$TRANSCRIPT_DIR"

# 3. Symlink para facilitar acceso
ln -sf "$WHATSAPP_DIR" ~/Descargas/WhatsApp_Audio

# 4. Iniciar monitor en background
nohup /home/dario/autotest/monitor_transcribir.sh \
  "$WHATSAPP_DIR" > "$TRANSCRIPT_DIR/monitor.log" 2>&1 &

echo "✅ Monitor iniciado (PID: $!)"
```

### Uso Real

```bash
# Usuario baja nota de voz: "hola buenos días"
# Automáticamente se crea:
# → transcripcion.txt con "Hola buenos días"

# Ver historial
ls -lh ~/Documentos/Transcripciones/*.txt | tail -10

# Buscar transcripción
grep -r "reunión" ~/Documentos/Transcripciones/
```

### Mejora: Integración con Notificaciones

```bash
# Scripts/monitor_con_notificaciones.sh
#!/bin/bash

WATCH_DIR="$1"
cd /home/dario/autotest

./monitor_transcribir.sh "$WATCH_DIR" | while read -r line; do
  if [[ $line =~ "OK ->" ]]; then
    FILE=$(echo "$line" | sed 's/OK -> //')
    notify-send "Transcripción lista" "Archivo: $FILE"
  fi
done
```

---

## 📝 Caso 2: Podcast Batch Processing

### Escenario
Tienes 50 episodios de podcast (MP3) y necesitas crear un índice searchable.

### Script Automatizado

```bash
#!/bin/bash
# Scripts/podcast_pipeline.sh

PODCAST_DIR="$1"
OUTPUT_DIR="${2:-.}/transcripciones"
MODEL="${3:-small}"

mkdir -p "$OUTPUT_DIR"
cd /home/dario/autotest

echo "[*] Iniciando batch processing de podcasts..."
echo "[*] Directorio: $PODCAST_DIR"
echo "[*] Modelo: $MODEL"
echo ""

# Contar archivos
TOTAL=$(find "$PODCAST_DIR" -name "*.mp3" -o -name "*.m4a" | wc -l)
CURRENT=0

find "$PODCAST_DIR" -type f \( -name "*.mp3" -o -name "*.m4a" \) | sort | while read -r podcast; do
  CURRENT=$((CURRENT + 1))
  BASENAME=$(basename "$podcast" | sed 's/\..*//')
  
  echo "[$CURRENT/$TOTAL] Procesando: $BASENAME"
  
  # Transcribir
  time ./transcribir.sh "$podcast" "$MODEL" "$OUTPUT_DIR/$BASENAME" 2>&1 | \
    tail -20
  
  echo ""
done

# Crear índice
echo "[*] Creando índice de búsqueda..."
cat "$OUTPUT_DIR"/*.txt > "$OUTPUT_DIR/INDICE_COMPLETO.txt"
echo "[✓] Índice creado en: $OUTPUT_DIR/INDICE_COMPLETO.txt"

# Estadísticas
TOTAL_LINES=$(wc -l < "$OUTPUT_DIR/INDICE_COMPLETO.txt")
TOTAL_WORDS=$(wc -w < "$OUTPUT_DIR/INDICE_COMPLETO.txt")
echo ""
echo "ESTADÍSTICAS:"
echo "  Líneas: $TOTAL_LINES"
echo "  Palabras: $TOTAL_WORDS"
```

### Uso

```bash
./podcast_pipeline.sh ~/Podcasts/MiPodcast/ ~/Transcripciones/ small

# Buscar en índice
grep -i "machine learning" ~/Transcripciones/INDICE_COMPLETO.txt

# Ver en qué episodio aparece
grep -n "machine learning" ~/Transcripciones/*.txt
```

---

## 🎤 Caso 3: Meetings & Conferencias con Timestamps

### Escenario
Grabas una reunión de 1 hora y necesitas transcripción con timestamps para referencia rápida.

### Script con Timestamps Mejorados

```bash
#!/bin/bash
# Scripts/meeting_transcription.sh

set -euo pipefail

AUDIO_FILE="$1"
MEETING_NAME="${2:-meeting_$(date +%Y%m%d_%H%M%S)}"
OUTPUT_DIR="./meeting_transcriptions"

mkdir -p "$OUTPUT_DIR"
cd /home/dario/autotest

echo "╔════════════════════════════════════════════╗"
echo "║  MEETING TRANSCRIPTION PROCESSOR           ║"
echo "╚════════════════════════════════════════════╝"
echo ""
echo "Input: $AUDIO_FILE"
echo "Name: $MEETING_NAME"
echo ""

# 1. Verificar duración
DURATION=$(ffprobe -v error -show_entries format=duration \
  -of default=noprint_wrappers=1:nokey=1 "$AUDIO_FILE")
MINUTES=$(echo "$DURATION / 60" | bc)

echo "[*] Duración: $MINUTES minutos (~$((MINUTES * 10))s de procesamiento)"
echo ""

# 2. Transcribir con modelo preciso
echo "[*] Transcribiendo con modelo 'medium' (precisión máxima)..."
./transcribir.sh "$AUDIO_FILE" medium "$OUTPUT_DIR/$MEETING_NAME" 2>&1 | \
  tail -5

# 3. Procesar archivo VTT para mejorar legibilidad
echo ""
echo "[*] Procesando timestamps..."

python3 << 'PYTHON'
import re
import sys

vtt_file = f"$OUTPUT_DIR/$MEETING_NAME.vtt"

# Leer archivo VTT
with open(vtt_file, 'r') as f:
    content = f.read()

# Mejorar formato
lines = content.split('\n')
output = []

for line in lines:
    # Convertir timestamps a formato más legible
    if ' --> ' in line:
        start, end = line.split(' --> ')
        start = start.strip()
        end = end.strip()
        
        # Remover ms para versión corta
        start_short = start.split('.')[0]
        end_short = end.split('.')[0]
        
        output.append(f"{start_short} → {end_short}")
    else:
        output.append(line)

# Guardar versión mejorada
with open(f"$OUTPUT_DIR/$MEETING_NAME_readable.vtt", 'w') as f:
    f.write('\n'.join(output))

print("[✓] Versión mejorada guardada")
PYTHON

# 4. Crear resumen ejecutivo
echo ""
echo "[*] Extrayendo puntos clave..."

# Los primeros 5 párrafos como resumen
head -50 "$OUTPUT_DIR/$MEETING_NAME.txt" > \
  "$OUTPUT_DIR/${MEETING_NAME}_RESUMEN.txt"

# 5. Estadísticas
echo ""
echo "═══════════════════════════════════════════════"
echo "✅ TRANSCRIPCIÓN COMPLETADA"
echo "═══════════════════════════════════════════════"
echo ""
echo "Archivos generados:"
ls -lh "$OUTPUT_DIR/$MEETING_NAME"* | awk '{print "  " $9 " (" $5 ")"}'
echo ""
echo "Contenido:"
wc -w "$OUTPUT_DIR/$MEETING_NAME.txt" | awk '{print "  Palabras: " $1}'
wc -l "$OUTPUT_DIR/$MEETING_NAME.txt" | awk '{print "  Líneas: " $1}'
```

### Uso

```bash
./meeting_transcription.sh reunion_importante.mp4 "Reunion_Junta_2025-12-17"

# Resultado:
# → reunion_importante_Resumen.txt (puntos clave)
# → reunion_importante.txt (transcripción completa)
# → reunion_importante_readable.vtt (con timestamps legibles)
```

---

## 🔍 Caso 4: Análisis de Sentimiento + Transcripción

### Escenario
Transcribildes audios de soporte al cliente y necesitas detectar automáticamente sentimiento (satisfecho/insatisfecho/neutral).

### Pipeline Completo

```bash
#!/bin/bash
# Scripts/sentiment_analysis_pipeline.sh

AUDIO_FILE="$1"
OUTPUT_PREFIX="$(basename $AUDIO_FILE .mp3)"

cd /home/dario/autotest

# 1. Transcribir
./transcribir.sh "$AUDIO_FILE" small "$OUTPUT_PREFIX" 2>/dev/null

# 2. Análisis de sentimiento con Python
python3 << 'PYTHON'
import json
from pathlib import Path
import re

# Instala: pip install textblob
from textblob import TextBlob

txt_file = f"${OUTPUT_PREFIX}.txt"

with open(txt_file, 'r') as f:
    transcript = f.read()

# Análisis básico
blob = TextBlob(transcript)
polarity = blob.sentiment.polarity  # -1 (negativo) a 1 (positivo)
subjectivity = blob.sentiment.subjectivity  # 0 (objetivo) a 1 (subjetivo)

# Clasificar
if polarity > 0.3:
    sentiment = "SATISFIED ✅"
    color = "green"
elif polarity < -0.3:
    sentiment = "UNSATISFIED ❌"
    color = "red"
else:
    sentiment = "NEUTRAL ➖"
    color = "yellow"

# Palabras clave negativas/positivas
negative_words = ['problema', 'mal', 'decepción', 'error', 'fallo']
positive_words = ['excelente', 'perfecto', 'gracias', 'satisfecho', 'genial']

neg_count = sum(1 for word in negative_words if word in transcript.lower())
pos_count = sum(1 for word in positive_words if word in transcript.lower())

# Guardar análisis
result = {
    "file": "${OUTPUT_PREFIX}",
    "transcript": transcript[:200] + "...",
    "sentiment": sentiment,
    "polarity": round(polarity, 3),
    "subjectivity": round(subjectivity, 3),
    "negative_indicators": neg_count,
    "positive_indicators": pos_count,
    "length_words": len(transcript.split())
}

output_file = f"${OUTPUT_PREFIX}_sentiment.json"
with open(output_file, 'w') as f:
    json.dump(result, f, indent=2, ensure_ascii=False)

print(f"✅ Análisis guardado en: {output_file}")
PYTHON

# 3. Mostrar resultado
echo ""
echo "═══════════════════════════════════════════"
echo "ANÁLISIS COMPLETADO"
echo "═══════════════════════════════════════════"
cat "${OUTPUT_PREFIX}_sentiment.json" | python3 -m json.tool
```

### Resultado Esperado

```json
{
  "file": "support_call_001",
  "sentiment": "SATISFIED ✅",
  "polarity": 0.65,
  "subjectivity": 0.42,
  "negative_indicators": 1,
  "positive_indicators": 4,
  "length_words": 287
}
```

---

## 📊 Caso 5: Dashboard Web en Tiempo Real

### Escenario
Crear dashboard web que muestre transcripciones en tiempo real mientras los audios se procesan.

### Stack Simplificado

```bash
# Scripts/setup_web_dashboard.sh

#!/bin/bash

cat > web_server.py << 'PYTHON'
from flask import Flask, render_template, jsonify, request
from pathlib import Path
import json
import subprocess
from datetime import datetime
import threading
import os

app = Flask(__name__)
TRANSCRIPTIONS_DIR = Path("./transcriptions")
TRANSCRIPTIONS_DIR.mkdir(exist_ok=True)

# Almacenar estado de procesos
processes = {}

@app.route('/')
def index():
    """Página principal"""
    transcriptions = [
        {
            'name': f.stem,
            'size': f.stat().st_size,
            'date': datetime.fromtimestamp(f.stat().st_mtime).isoformat(),
            'preview': open(f).read()[:200] if f.exists() else ''
        }
        for f in TRANSCRIPTIONS_DIR.glob('*.txt')
    ]
    return render_template('index.html', transcriptions=transcriptions)

@app.route('/api/transcriptions')
def get_transcriptions():
    """API: Listar transcripciones"""
    items = []
    for f in TRANSCRIPTIONS_DIR.glob('*.txt'):
        items.append({
            'name': f.stem,
            'size_bytes': f.stat().st_size,
            'timestamp': datetime.fromtimestamp(f.stat().st_mtime).isoformat(),
        })
    return jsonify(items)

@app.route('/api/transcribe', methods=['POST'])
def transcribe():
    """API: Crear nueva transcripción"""
    if 'file' not in request.files:
        return {'error': 'No file provided'}, 400
    
    file = request.files['file']
    if file.filename == '':
        return {'error': 'No file selected'}, 400
    
    # Guardar archivo
    filepath = f'/tmp/{file.filename}'
    file.save(filepath)
    
    # Procesar en background
    def process():
        output_name = Path(file.filename).stem
        subprocess.run([
            '/home/dario/autotest/transcribir.sh',
            filepath, 'small', 
            str(TRANSCRIPTIONS_DIR / output_name)
        ])
        processes[output_name] = 'completed'
    
    output_name = Path(file.filename).stem
    processes[output_name] = 'processing'
    
    thread = threading.Thread(target=process)
    thread.daemon = True
    thread.start()
    
    return {'status': 'processing', 'job_id': output_name}, 202

@app.route('/api/status/<job_id>')
def get_status(job_id):
    """API: Estado de procesamiento"""
    status = processes.get(job_id, 'unknown')
    return jsonify({'job_id': job_id, 'status': status})

if __name__ == '__main__':
    app.run(debug=True, port=5000)
PYTHON

# Crear template HTML
mkdir -p templates
cat > templates/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Whisper Transcriber Dashboard</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        header { background: #2c3e50; color: white; padding: 20px; border-radius: 8px; margin-bottom: 30px; }
        h1 { font-size: 28px; margin-bottom: 10px; }
        .upload-area { background: white; border: 2px dashed #3498db; border-radius: 8px; 
                       padding: 40px; text-align: center; cursor: pointer; margin-bottom: 30px; }
        .upload-area:hover { background: #ecf0f1; }
        .transcriptions-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; }
        .card { background: white; border-radius: 8px; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .card h3 { color: #2c3e50; margin-bottom: 10px; }
        .card p { color: #7f8c8d; font-size: 14px; margin: 5px 0; }
        .status { display: inline-block; padding: 4px 8px; border-radius: 4px; background: #27ae60; 
                  color: white; font-size: 12px; }
        .status.processing { background: #f39c12; }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🎤 Whisper Transcriber Dashboard</h1>
            <p>100% Local • 100% Private • No Cloud</p>
        </header>
        
        <div class="upload-area" onclick="document.getElementById('file-input').click()">
            <p>📁 Click aquí o arrastra archivo para transcribir</p>
            <input type="file" id="file-input" style="display: none" accept="audio/*">
        </div>
        
        <h2 style="margin-bottom: 20px;">Recent Transcriptions</h2>
        <div class="transcriptions-grid" id="transcriptions-grid">
            <p>Cargando...</p>
        </div>
    </div>
    
    <script>
        // Cargar transcripciones
        async function loadTranscriptions() {
            const resp = await fetch('/api/transcriptions');
            const data = await resp.json();
            const grid = document.getElementById('transcriptions-grid');
            grid.innerHTML = data.map(item => `
                <div class="card">
                    <h3>${item.name}</h3>
                    <p>Size: ${(item.size_bytes / 1024).toFixed(2)} KB</p>
                    <p>Date: ${new Date(item.timestamp).toLocaleDateString()}</p>
                    <span class="status">✓ Done</span>
                </div>
            `).join('');
        }
        
        // Upload listener
        document.getElementById('file-input').addEventListener('change', async (e) => {
            const file = e.target.files[0];
            if (!file) return;
            
            const formData = new FormData();
            formData.append('file', file);
            
            const resp = await fetch('/api/transcribe', { method: 'POST', body: formData });
            const data = await resp.json();
            
            console.log('Processing:', data.job_id);
            loadTranscriptions();
        });
        
        loadTranscriptions();
        setInterval(loadTranscriptions, 5000);
    </script>
</body>
</html>
HTML

echo "✅ Web dashboard setup completado"
echo ""
echo "Para iniciar:"
echo "  pip install flask"
echo "  python3 web_server.py"
echo ""
echo "Accede a: http://localhost:5000"
```

---

## 🎯 Caso 6: Integración CI/CD (Transcribir en Deployment)

### Escenario
Tu aplicación necesita transcribir audios como parte del pipeline de CI/CD.

### GitHub Actions

```yaml
# .github/workflows/transcribe.yml

name: Audio Transcription Pipeline

on:
  push:
    paths:
      - 'audio/**'
  workflow_dispatch:

jobs:
  transcribe:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y ffmpeg cmake build-essential git
      
      - name: Build whisper.cpp
        run: |
          git clone https://github.com/ggerganov/whisper.cpp
          cd whisper.cpp
          cmake -B build && cmake --build build -j
          bash ./models/download-ggml-model.sh small
          cd ..
      
      - name: Transcribe audio files
        run: |
          mkdir -p transcriptions
          for audio in audio/*.{ogg,mp3,wav}; do
            [ -f "$audio" ] && ./transcribir.sh "$audio" small "transcriptions/$(basename $audio)"
          done
      
      - name: Upload transcriptions
        uses: actions/upload-artifact@v3
        with:
          name: transcriptions
          path: transcriptions/
      
      - name: Commit results
        run: |
          git config user.name "Transcriber Bot"
          git config user.email "bot@example.com"
          git add transcriptions/
          git commit -m "Auto: Transcribe audio files" || true
          git push
```

---

## 🚀 Caso 7: Producción - API REST con Escalabilidad

### Escenario
Necesitas una API REST que maneje múltiples transcripciones concurrentes en servidor.

### Architecture

```python
# api_server.py (Production-grade)

from fastapi import FastAPI, UploadFile, File, BackgroundTasks
from fastapi.responses import JSONResponse, FileResponse
from pathlib import Path
import asyncio
import subprocess
import uuid
from datetime import datetime
from sqlalchemy import create_engine, Column, String, DateTime, Integer
from sqlalchemy.orm import declarative_base, Session
import logging

# Setup
DB_URL = "sqlite:///./transcriptions.db"
engine = create_engine(DB_URL)
Base = declarative_base()

logger = logging.getLogger(__name__)
app = FastAPI(title="Whisper API", version="1.0")

# Database Model
class TranscriptionJob(Base):
    __tablename__ = "jobs"
    
    id = Column(String, primary_key=True)
    filename = Column(String)
    status = Column(String)  # queued, processing, completed, failed
    created_at = Column(DateTime)
    completed_at = Column(DateTime, nullable=True)
    output_file = Column(String, nullable=True)
    error_message = Column(String, nullable=True)

Base.metadata.create_all(bind=engine)

# Queue de procesamiento
MAX_CONCURRENT = 4
processing_semaphore = asyncio.Semaphore(MAX_CONCURRENT)

async def process_transcription(job_id: str, file_path: Path):
    """Procesar audio en background"""
    async with processing_semaphore:
        try:
            db = Session(bind=engine)
            job = db.query(TranscriptionJob).filter_by(id=job_id).first()
            job.status = "processing"
            db.commit()
            
            output_file = Path("/tmp") / job_id / job.filename.replace(Path(job.filename).suffix, "")
            output_file.parent.mkdir(exist_ok=True)
            
            # Llamar whisper.cpp
            result = subprocess.run([
                '/home/dario/autotest/transcribir.sh',
                str(file_path), 'small', str(output_file)
            ], capture_output=True, timeout=600)
            
            if result.returncode == 0:
                job.status = "completed"
                job.output_file = str(output_file) + ".txt"
            else:
                job.status = "failed"
                job.error_message = result.stderr.decode()
            
            job.completed_at = datetime.now()
            db.commit()
            db.close()
            
        except Exception as e:
            logger.error(f"Job {job_id} failed: {str(e)}")
            db.query(TranscriptionJob).filter_by(id=job_id).first().status = "failed"
            db.commit()

@app.post("/v1/audio/transcriptions")
async def create_transcription(file: UploadFile, background_tasks: BackgroundTasks):
    """Crear nueva transcripción"""
    job_id = str(uuid.uuid4())
    
    # Guardar archivo
    temp_path = Path(f"/tmp/{job_id}/{file.filename}")
    temp_path.parent.mkdir(exist_ok=True)
    
    with open(temp_path, "wb") as f:
        f.write(await file.read())
    
    # Crear registro en BD
    db = Session(bind=engine)
    job = TranscriptionJob(
        id=job_id,
        filename=file.filename,
        status="queued",
        created_at=datetime.now()
    )
    db.add(job)
    db.commit()
    db.close()
    
    # Encolar procesamiento
    background_tasks.add_task(process_transcription, job_id, temp_path)
    
    return {
        "job_id": job_id,
        "status": "queued",
        "message": "Audio queued for transcription"
    }

@app.get("/v1/audio/transcriptions/{job_id}")
async def get_transcription(job_id: str):
    """Obtener estado/resultado"""
    db = Session(bind=engine)
    job = db.query(TranscriptionJob).filter_by(id=job_id).first()
    db.close()
    
    if not job:
        return {"error": "Job not found"}, 404
    
    response = {
        "job_id": job_id,
        "status": job.status,
        "created_at": job.created_at.isoformat(),
    }
    
    if job.status == "completed":
        response["output_url"] = f"/v1/audio/transcriptions/{job_id}/download"
    elif job.status == "failed":
        response["error"] = job.error_message
    
    return response

@app.get("/v1/audio/transcriptions/{job_id}/download")
async def download_transcription(job_id: str):
    """Descargar resultado"""
    db = Session(bind=engine)
    job = db.query(TranscriptionJob).filter_by(id=job_id).first()
    db.close()
    
    if not job or job.status != "completed":
        return {"error": "Not available"}, 404
    
    return FileResponse(job.output_file)

# Dockerize
# Dockerfile
"""
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \\
    ffmpeg cmake build-essential git python3-pip

WORKDIR /app

RUN git clone https://github.com/ggerganov/whisper.cpp && \\
    cd whisper.cpp && \\
    cmake -B build && cmake --build build -j && \\
    bash ./models/download-ggml-model.sh small

COPY . .
RUN pip install -r requirements.txt

EXPOSE 8000

CMD ["uvicorn", "api_server:app", "--host", "0.0.0.0", "--port", "8000"]
"""
```

---

## 📚 Tabla Comparativa de Casos

| Caso | Complejidad | Tiempo Setup | Mantenimiento | ROI |
|------|------------|-------------|---------------|-----|
| WhatsApp Monitor | ⭐ | 15 min | Mínimo | Alto |
| Podcast Batch | ⭐⭐ | 30 min | Bajo | Alto |
| Meetings | ⭐⭐ | 1 hora | Bajo | Muy Alto |
| Sentiment Analysis | ⭐⭐⭐ | 2 horas | Medio | Alto |
| Web Dashboard | ⭐⭐⭐ | 3 horas | Medio | Medio |
| CI/CD | ⭐⭐⭐ | 2 horas | Bajo | Muy Alto |
| API Production | ⭐⭐⭐⭐ | 1 día | Alto | Muy Alto |

---

**Última actualización:** 17 de Diciembre, 2025  
**Casos Documentados:** 7  
**Listo para Producción:** ✅
