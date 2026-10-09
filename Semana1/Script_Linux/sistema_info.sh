#!/bin/bash

# Registrar el tiempo de inicio para medir la ejecución del script
TIEMPO_INICIO=$(date +%s.%N)

# Definir la ruta de la carpeta de destino para el resumen (puedes cambiarla según prefieras)
# Usaremos una carpeta llamada 'resumen_sistema' en el directorio actual del usuario
DIRECTORIO_DESTINO="$HOME/resumen_sistema"
ARCHIVO_SALIDA="$DIRECTORIO_DESTINO/reporte_sistema.txt"

# Crear el directorio de destino si no existe
mkdir -p "$DIRECTORIO_DESTINO"

# Iniciar la captura de información hacia el archivo de texto
{
    echo "===================================================="
    echo "       REPORTE DE RENDIMIENTO Y HARDWARE LINUX      "
    echo "===================================================="
    echo "Fecha y hora de ejecución: $(date)"
    echo "----------------------------------------------------"
    echo ""

    echo "[+] INFORMACIÓN DE ARQUITECTURA Y CPU (lscpu):"
    lscpu
    echo ""

    echo "----------------------------------------------------"
    echo "[+] ESTADO DE LA MEMORIA RAM (free -h):"
    free -h
    echo ""

    echo "----------------------------------------------------"
    echo "[+] INFORMACIÓN DETALLADA DE CPU (/proc/cpuinfo - núcleos/hilos):"
    grep -E "model name|cpu cores|siblings" /proc/cpuinfo | head -n 4
    echo ""

    # Medir tiempo de ejecución del script
    TIEMOP_FIN=$(date +%s.%N)
    TIEMPO_TOTAL=$(echo "$TIEMOP_FIN - $TIEMPO_INICIO" | bc)
    
    echo "----------------------------------------------------"
    echo "El script se ejecutó exitosamente en: ${TIEMPO_TOTAL} segundos."
    echo "===================================================="

} > "$ARCHIVO_SALIDA"

# Mensaje en la terminal indicando que finalizó y la ubicación del archivo
echo "¡Proceso finalizado con éxito!"
echo "El resumen automático se ha guardado en:"
cd "$DIRECTORIO_DESTINO" && pwd
echo "Archivo generado: $ARCHIVO_SALIDA"
