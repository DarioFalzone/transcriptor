#!/usr/bin/env bash
set -euo pipefail

IN="${1:?Pasame un audio, ej: ./transcribir.sh archivo.ogg}"
MODEL="${2:-small}"
OUT="${3:-transcripcion}"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR/whisper.cpp"

echo "[*] Convirtiendo audio a WAV 16kHz mono..."
ffmpeg -y -i "$IN" -ar 16000 -ac 1 /tmp/_whisper_in.wav >/dev/null 2>&1

echo "[*] Transcribiendo con whisper.cpp (modelo: $MODEL, idioma: es)..."
./build/bin/whisper-cli -m "models/ggml-${MODEL}.bin" -f /tmp/_whisper_in.wav -l es -otxt -of "$OUT"

echo "✅ OK -> ${OUT}.txt"
echo ""
echo "Contenido:"
cat "${OUT}.txt"
