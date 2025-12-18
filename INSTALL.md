# 📥 Guía de Instalación

## Requisitos Previos

- **SO:** Ubuntu 22.04+ / Debian 11+
- **RAM:** Mínimo 2GB (4GB recomendado)
- **Espacio:** 2GB libres
- **Conexión:** Internet para descargar modelos

---

## 🚀 Instalación Rápida (Recomendada)

```bash
# 1. Clonar el repositorio CON submódulos
git clone --recursive https://github.com/TU_USUARIO/transcriptor.git
cd transcriptor

# 2. Ejecutar instalador automático
./SETUP.sh

# 3. Probar el sistema
./demo.sh
```

**Tiempo estimado:** 5-10 minutos

---

## 🔧 Instalación Manual (Avanzada)

### Paso 1: Clonar Repositorio
```bash
git clone https://github.com/TU_USUARIO/transcriptor.git
cd transcriptor
```

### Paso 2: Inicializar Submódulos
```bash
git submodule init
git submodule update --recursive
```

### Paso 3: Instalar Dependencias
```bash
sudo apt update
sudo apt install -y ffmpeg build-essential cmake git wget
```

### Paso 4: Compilar whisper.cpp
```bash
cd whisper.cpp
make clean
make -j$(nproc)
cd ..
```

### Paso 5: Descargar Modelos
```bash
mkdir -p models
bash whisper.cpp/models/download-ggml-model.sh small
mv whisper.cpp/models/ggml-small.bin models/
```

### Paso 6: Dar Permisos
```bash
chmod +x *.sh
```

---

## 🔍 Verificación de Instalación

```bash
# Verificar FFmpeg
ffmpeg -version | head -n1

# Verificar compilación
ls -lh whisper.cpp/main

# Verificar modelos
ls -lh models/*.bin

# Ejecutar demo
./demo.sh
```

**Salida esperada:**
```
[✓] FFmpeg version 4.4.2
[✓] whisper.cpp/main (ejecutable compilado)
[✓] models/ggml-small.bin (466 MB)
[✓] Demo completado sin errores
```

---

## 🌐 Instalación en Máquina Nueva

Si clonaste el repo en otra máquina:

```bash
# Opción A: Con submódulos automáticos
git clone --recursive https://github.com/TU_USUARIO/transcriptor.git
cd transcriptor
./SETUP.sh

# Opción B: Sin flag --recursive
git clone https://github.com/TU_USUARIO/transcriptor.git
cd transcriptor
git submodule update --init --recursive
./SETUP.sh
```

---

## ❌ Troubleshooting

### Error: "whisper.cpp/main no encontrado"
```bash
cd whisper.cpp
make clean && make
```

### Error: "No such file: models/ggml-small.bin"
```bash
bash whisper.cpp/models/download-ggml-model.sh small
mv whisper.cpp/models/ggml-small.bin models/
```

### Error: "Permission denied"
```bash
chmod +x *.sh
```

### Actualizar whisper.cpp a última versión
```bash
cd whisper.cpp
git pull origin master
make clean && make
cd ..
```

---

## 📦 Estructura Post-Instalación

```
transcriptor/
├── whisper.cpp/          # Submódulo Git (compilado localmente)
│   ├── main             # ✓ Binario ejecutable
│   └── models/          # (vacío, modelos están en ../models/)
├── models/
│   └── ggml-small.bin   # ✓ Modelo descargado (466 MB)
├── transcribir.sh       # ✓ Script principal
├── demo.sh              # ✓ Demo de prueba
├── monitor_transcribir.sh  # ✓ Daemon de monitoreo
└── SETUP.sh             # ✓ Instalador
```

---

## 🔄 Actualización del Proyecto

```bash
# Actualizar código
git pull origin main

# Actualizar whisper.cpp
git submodule update --remote

# Recompilar
cd whisper.cpp && make clean && make && cd ..
```