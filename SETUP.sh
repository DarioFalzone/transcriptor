#!/usr/bin/env bash
set -euo pipefail

cat << 'EOF'

╔════════════════════════════════════════════════════════════════╗
║  🎤 TRANSCRIPTOR LOCAL - RESUMEN DE INSTALACIÓN              ║
╚════════════════════════════════════════════════════════════════╝

✅ TODO LISTO

  1. Dependencias:       ✓ ffmpeg, git, build-essential, cmake
  2. Compilación:        ✓ whisper.cpp/build/bin/whisper-cli
  3. Modelo:             ✓ ggml-small.bin (465 MB)
  4. Script principal:   ✓ ./transcribir.sh
  5. Monitor automático: ✓ ./monitor_transcribir.sh
  6. Documentación:      ✓ README.md

╔════════════════════════════════════════════════════════════════╗
║  🚀 GUÍA RÁPIDA DE USO                                        ║
╚════════════════════════════════════════════════════════════════╝

1️⃣  TRANSCRIBIR UN ARCHIVO:

    ./transcribir.sh "/ruta/al/audio.ogg"

    Genera: transcripcion.txt

2️⃣  ESPECIFICAR NOMBRE DE SALIDA:

    ./transcribir.sh "/ruta/al/audio.ogg" small mi_texto

    Genera: mi_texto.txt

3️⃣  MONITOREO AUTOMÁTICO (NUEVA CARPETA):

    mkdir -p ~/Descargas/WhatsApp\ Audio
    ./monitor_transcribir.sh ~/Descargas/WhatsApp\ Audio

    Cualquier audio nuevo se transcribe automáticamente 🤖

4️⃣  MODELOS DISPONIBLES:

    tiny (39 MB)      - Rápido, menos preciso
    base (139 MB)     - Balance
    small (465 MB)    - ⭐ Recomendado (ya instalado)
    medium (1.5 GB)   - Más preciso
    large (3 GB)      - Máxima calidad

    Para usar otro modelo:
    ./transcribir.sh audio.ogg base output

╔════════════════════════════════════════════════════════════════╗
║  📝 ARCHIVOS IMPORTANTES                                      ║
╚════════════════════════════════════════════════════════════════╝

/home/dario/autotest/
├── transcribir.sh            ← Transcribir archivos individuales
├── monitor_transcribir.sh    ← Monitoreo automático
├── README.md                 ← Documentación completa
└── whisper.cpp/
    ├── build/bin/whisper-cli ← Motor de transcripción
    └── models/ggml-small.bin ← Modelo de IA

╔════════════════════════════════════════════════════════════════╗
║  ⚡ PERFORMANCE                                               ║
╚════════════════════════════════════════════════════════════════╝

Tiempo de transcripción (aprox):
  - Audio 1 min:  ~8-10 segundos
  - Audio 10 min: ~90-120 segundos

Recursos:
  - RAM: ~800 MB
  - CPU: 4 threads (configuración actual)
  - Disco: ~465 MB (modelo small)

╔════════════════════════════════════════════════════════════════╗
║  📚 PRÓXIMOS PASOS                                            ║
╚════════════════════════════════════════════════════════════════╝

1. Descarga modelo más preciso (opcional):
   cd whisper.cpp
   bash ./models/download-ggml-model.sh medium

2. Para GPU acelerada (NVIDIA/AMD):
   Recompila whisper.cpp con CUDA/HIP

3. Para API REST:
   cd whisper.cpp/build
   ./bin/whisper-server

4. Para más idiomas:
   Edita transcribir.sh y cambia "-l es" por otro código

╔════════════════════════════════════════════════════════════════╗
║  ✨ ¡LISTO! Empeza a usar:                                   ║
║                                                              ║
║  ./transcribir.sh tu_audio.ogg                              ║
║                                                              ║
║  100% local • 100% privado • Sin conexión a internet        ║
╚════════════════════════════════════════════════════════════════╝

EOF
