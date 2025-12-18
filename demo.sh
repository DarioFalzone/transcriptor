#!/usr/bin/env bash

# Ejemplo de uso completo del transcriptor

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "╔════════════════════════════════════════════════════════╗"
echo "║  EJEMPLO: Transcribiendo audio de prueba               ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# 1. Crear audio de prueba (3 segundos de tono)
echo "[1/4] Creando audio de prueba..."
ffmpeg -f lavfi -i "sine=frequency=1000:duration=3" \
        -f lavfi -i "sine=frequency=500:duration=3" \
        -filter_complex "amix=inputs=2:duration=first" \
        -c:a libopus /tmp/demo.ogg -y >/dev/null 2>&1

echo "[✓] Archivo creado: /tmp/demo.ogg"
echo ""

# 2. Transcribir
echo "[2/4] Transcribiendo (esto puede tomar 5-10 segundos)..."
cd "$DIR"
./transcribir.sh /tmp/demo.ogg small demo_resultado 2>/dev/null

echo ""
echo "[3/4] Resultado:"
if [ -f demo_resultado.txt ]; then
    echo "───────────────────────────────────────────────────────"
    cat demo_resultado.txt
    echo "───────────────────────────────────────────────────────"
else
    echo "[!] Archivo de salida no encontrado"
fi

echo ""
echo "[4/4] Limpiando..."
rm -f /tmp/demo.ogg demo_resultado.txt

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║  ✅ DEMO COMPLETADO                                   ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Próximos pasos:"
echo "  1. Coloca tu archivo OGG/MP3/WAV en una carpeta"
echo "  2. Ejecuta: ./transcribir.sh /ruta/al/archivo.ogg"
echo "  3. ¡Listo! Tendrás el resultado en transcripcion.txt"
echo ""
echo "Para monitoreo automático:"
echo "  ./monitor_transcribir.sh ~/Descargas/WhatsApp\\ Audio"
echo ""
