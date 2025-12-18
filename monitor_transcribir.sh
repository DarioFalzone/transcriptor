#!/usr/bin/env bash

WATCH_DIR="${1:?Usa: ./monitor_transcribir.sh /path/a/carpeta}"
TIMEOUT=5  # segundos sin cambios = procesa

mkdir -p "$WATCH_DIR"
cd "$(dirname "$0")"

echo "[*] Monitoreando: $WATCH_DIR"
echo "[*] (Ctrl+C para detener)"

# Usar inotifywait si está disponible (mejor rendimiento)
if command -v inotifywait &> /dev/null; then
    echo "[✓] Usando inotifywait para detección en tiempo real"
    while true; do
        NEW_FILE=$(inotifywait -r -e moved_to "$WATCH_DIR" --format '%w%f' 2>/dev/null | head -1)
        if [ -n "$NEW_FILE" ] && [[ "$NEW_FILE" =~ \.(ogg|mp3|wav|m4a)$ ]]; then
            sleep 1  # Espera a que termine de escribir
            echo "[+] Nuevo audio detectado: $NEW_FILE"
            BASENAME=$(basename "$NEW_FILE" | sed 's/\..*//')
            ./transcribir.sh "$NEW_FILE" small "$BASENAME"
            echo ""
        fi
    done
else
    # Fallback: polling cada TIMEOUT segundos
    echo "[!] inotifywait no disponible, usando polling (menos eficiente)"
    echo "    Instala con: sudo apt install -y inotify-tools"
    LAST_PROCESSED=""
    while true; do
        NEWEST=$(find "$WATCH_DIR" -maxdepth 1 -type f \( -name "*.ogg" -o -name "*.mp3" -o -name "*.wav" -o -name "*.m4a" \) -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
        
        if [ -n "$NEWEST" ] && [ "$NEWEST" != "$LAST_PROCESSED" ]; then
            LAST_PROCESSED="$NEWEST"
            echo "[+] Nuevo audio detectado: $NEWEST"
            BASENAME=$(basename "$NEWEST" | sed 's/\..*//')
            ./transcribir.sh "$NEWEST" small "$BASENAME"
            echo ""
        fi
        sleep $TIMEOUT
    done
fi
