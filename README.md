# 🎤 Transcriptor Local de Audio - whisper.cpp

Transcripción de audio **100% local** en Linux (Ubuntu 24.04), sin enviar datos a ningún lado.

## ✅ Instalación Completada

- ✓ Dependencias del sistema: `ffmpeg`, `git`, `build-essential`, `cmake`
- ✓ Código compilado en: `./whisper.cpp/build/bin/whisper-cli`
- ✓ Modelo GGML (small): `./whisper.cpp/models/ggml-small.bin`
- ✓ Script automatizado: `./transcribir.sh`

## 🚀 Uso Básico

### Transcribir un archivo OGG/MP3/WAV

```bash
./transcribir.sh "/ruta/al/audio.ogg"
```

Genera: `transcripcion.txt`

### Especificar nombre de salida

```bash
./transcribir.sh "/ruta/al/audio.ogg" small mi_texto
```

Genera: `mi_texto.txt`

### Usar modelo diferente

```bash
./transcribir.sh "/ruta/al/audio.ogg" base output_file
```

**Modelos disponibles:**
- `tiny` (~39 MB) - Más rápido, menos preciso
- `base` (~139 MB) - Balance
- `small` (~465 MB) - Recomendado
- `medium` (~1.5 GB) - Más preciso
- `large` (~3 GB) - Máxima calidad

Primero descargalos con:

```bash
cd whisper.cpp
bash ./models/download-ggml-model.sh base   # o medium/large
```

## 📝 Formato de Salida

El script genera un archivo `.txt` con la transcripción y timestamps:

```
[00:00:00.000 --> 00:00:03.000]   [música]
[00:00:03.000 --> 00:00:10.000]   Hola, ¿cómo estás?
[00:00:10.000 --> 00:00:15.000]   Espero estés bien.
```

## 🔄 Automatización: Monitor de Carpeta

Para **transcribir automáticamente** todos los audios nuevos en una carpeta (ej: `~/Descargas/WhatsApp Audio`):

### 1. Crear script monitor

```bash
cat > monitor_transcribir.sh <<'EOF'
#!/usr/bin/env bash

WATCH_DIR="${1:?Usa: ./monitor_transcribir.sh /path/a/carpeta}"
TIMEOUT=5  # segundos sin cambios = procesa

mkdir -p "$WATCH_DIR"
cd "$(dirname "$0")"

echo "[*] Monitoreando: $WATCH_DIR"
echo "[*] (Ctrl+C para detener)"

# Usar inotifywait si está disponible
if command -v inotifywait &> /dev/null; then
    while true; do
        NEW_FILE=$(inotifywait -r -e moved_to "$WATCH_DIR" --format '%w%f' 2>/dev/null | head -1)
        if [ -n "$NEW_FILE" ] && [[ "$NEW_FILE" =~ \.(ogg|mp3|wav|m4a)$ ]]; then
            sleep 1  # Espera a que termine de escribir
            echo "[+] Nuevo audio: $NEW_FILE"
            BASENAME=$(basename "$NEW_FILE" | sed 's/\..*//')
            ./transcribir.sh "$NEW_FILE" small "$BASENAME"
        fi
    done
else
    # Fallback: polling cada TIMEOUT segundos
    LAST_PROCESSED=""
    while true; do
        NEWEST=$(find "$WATCH_DIR" -maxdepth 1 -type f \( -name "*.ogg" -o -name "*.mp3" -o -name "*.wav" -o -name "*.m4a" \) -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
        
        if [ -n "$NEWEST" ] && [ "$NEWEST" != "$LAST_PROCESSED" ]; then
            LAST_PROCESSED="$NEWEST"
            echo "[+] Nuevo audio: $NEWEST"
            BASENAME=$(basename "$NEWEST" | sed 's/\..*//')
            ./transcribir.sh "$NEWEST" small "$BASENAME"
        fi
        sleep $TIMEOUT
    done
fi
EOF

chmod +x monitor_transcribir.sh
```

### 2. Ejecutar monitor

```bash
./monitor_transcribir.sh ~/Descargas/WhatsApp\ Audio
```

Ahora **cualquier audio nuevo** en esa carpeta se transcribe automáticamente.

### 3. Ejecutar en background (opcional)

```bash
nohup ./monitor_transcribir.sh ~/Descargas/WhatsApp\ Audio > monitor.log 2>&1 &
```

Para detener:

```bash
pkill -f "monitor_transcribir.sh"
```

## ⚙️ Opciones Avanzadas

### Cambiar idioma

Edita `transcribir.sh` línea `./build/bin/whisper-cli ... -l es`:

```bash
-l es    # Español
-l en    # Inglés
-l fr    # Francés
-l pt    # Portugués
-l auto  # Detectar automáticamente
```

### Ver todos los idiomas soportados

```bash
cd whisper.cpp
./build/bin/whisper-cli --help | grep -A 30 "language"
```

### Transcribir con timestamps VTT

```bash
cd whisper.cpp/build/bin
./whisper-cli -m models/ggml-small.bin -f /tmp/_whisper_in.wav -l es -ovtt -of mi_salida
# Genera: mi_salida.vtt
```

## 📊 Performance

- **Tiempo de inferencia** (audio 1 min): ~8-10 segundos (CPU)
- **RAM usada**: ~800 MB
- **Disco**: ~465 MB (modelo small)
- **GPU**: Soportado (CUDA, Metal, OpenCL) si tu equipo lo tiene

## 🔧 Solucionar Problemas

### Error: "ffmpeg: comando no encontrado"

```bash
sudo apt install -y ffmpeg
```

### Error: "whisper-cli: No such file or directory"

```bash
cd whisper.cpp
cmake --build build -j
```

### Audio sin transcribir (vacío)

- Verifica que el audio sea válido: `ffprobe archivo.ogg`
- Prueba con: `./transcribir.sh archivo.ogg small debug`

### Modelo no encontrado

```bash
cd whisper.cpp/models
ls ggml-*.bin
# Si no está, descargalo:
bash ../models/download-ggml-model.sh small
```

## 📁 Estructura del Proyecto

```
/home/dario/autotest/
├── transcribir.sh           ← Script principal
├── monitor_transcribir.sh   ← Monitor automático (opcional)
└── whisper.cpp/
    ├── build/
    │   └── bin/
    │       ├── whisper-cli  ← Ejecutable compilado
    │       └── whisper-server
    ├── models/
    │   └── ggml-small.bin   ← Modelo descargado
    └── src/
        └── ...
```

## 🚀 Próximos Pasos

1. **Usar modelo `medium`** para mayor precisión (descargar: ~1.5 GB)
2. **GPU acelerada** (si tienes NVIDIA/AMD): recompilar con CUDA/HIP
3. **API REST**: usar `whisper-server` en lugar de `whisper-cli`
4. **Integración con otros apps**: procesar salidas TXT automáticamente

## 📜 Referencias

- [whisper.cpp GitHub](https://github.com/ggerganov/whisper.cpp)
- [OpenAI Whisper](https://github.com/openai/whisper)
- [GGML Models](https://huggingface.co/ggerganov/whisper.cpp)

---

**Creado:** 17 de diciembre, 2025  
**Sistema:** Ubuntu 24.04 LTS  
**Tecnología:** whisper.cpp + GGML  
**Licencia:** MIT (whisper.cpp)
