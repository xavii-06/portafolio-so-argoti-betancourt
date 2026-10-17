
#!/bin/bash

# Archivo donde se guardara el resumen
ARCHIVO="resumen_diagnostico.txt"

{
    echo "======================================"
    echo "     RESUMEN DE DIAGNOSTICO DEL PC"
    echo "======================================"

    echo ""
    echo "1. NOMBRE DEL EQUIPO"
    hostname

    echo ""
    echo "2. FECHA ACTUAL"
    date +%F

    echo ""
    echo "3. ARQUITECTURA DEL SISTEMA"
    uname -m

    echo ""
    echo "4. MEMORIA RAM"
    free -h | awk '/^Mem:/ {
        printf "Total: %s | Usada: %s | Disponible: %s\n",
        $2, $3, $7
    }'

    echo ""
    echo "5. CACHE DEL PROCESADOR"
    lscpu --caches | head -n 6

    echo ""
    echo "6. TAMANO DE LINEA DE CACHE L1"
    getconf LEVEL1_DCACHE_LINESIZE | awk '{
        printf "%s bytes\n", $1
    }'

    echo ""
    echo "7. UNIDADES DE ALMACENAMIENTO"
    lsblk -do NAME,ROTA,SIZE | awk '
    NR == 1 { print; next }
    {
        tipo = ($2 == 0) ? "SSD" : "HDD"
        printf "%-8s %-8s %s\n", $1, tipo, $3
    }'

    echo ""
    echo "======================================"
    echo "       DIAGNOSTICO FINALIZADO"
    echo "======================================"

} | tee "$ARCHIVO"

echo ""
echo "Resumen guardado en: $ARCHIVO"
