#!/usr/bin/env bash
# =============================================================================
#  Deber 3 · Informe de arranque (Linux)             COMPLETADO (Secciones 1-3)
#  Sistemas Operativos · EPN · Semana 3
# -----------------------------------------------------------------------------
#  Autores:   Xavier Argoti, Rodrigo Betancourt
#  Fecha:     2026-10-31
#  Uso de IA: Se usó IA generativa (Gemini) para estructura de comandos de 
#             extracción en bash/powershell y manejo defensivo de fallos.
# -----------------------------------------------------------------------------
#  Qué debe hacer: reunir en un archivo de texto cómo arrancó esta máquina.
#    Secciones 1, 2 y 3  → las empiezan en el Taller 2 (parte D).
#    Secciones 4, 5 y 6  → las terminan en casa.
#  Uso:       chmod +x informe_arranque.sh && ./informe_arranque.sh
#             (no debe necesitar sudo)
#  Entrega:   guárdalo como semana03/informe_arranque.sh en el repositorio
#             de la pareja y súbelo a GitHub (instrucciones al final).
# =============================================================================

set -u

EQUIPO="$(hostname -s 2>/dev/null || echo equipo)"
SALIDA="informe_arranque_${EQUIPO}_$(date +%Y%m%d_%H%M).txt"

titulo() {
    printf '\n=== %s ===\n' "$1"
}

tiene() {
    command -v "$1" >/dev/null 2>&1
}

# --- 1 · SO, versión y núcleo ------------------------- (Taller 2) ----------
seccion1() {
    titulo "1 · Sistema operativo, versión y núcleo"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "Sistema: ${PRETTY_NAME:-Desconocido}"
    else
        echo "Sistema: No se pudo determinar /etc/os-release"
    fi
    echo "Núcleo:  $(uname -r) ($(uname -m))"
}

# --- 2 · Último arranque y uptime --------------------- (Taller 2) ----------
seccion2() {
    titulo "2 · Último arranque y tiempo encendido"
    if tiene uptime; then
        echo "Arrancó:   $(uptime -s 2>/dev/null || echo 'No disponible')"
        echo "Encendida: $(uptime -p 2>/dev/null || echo 'No disponible')"
    else
        echo "Aviso: El comando 'uptime' no está disponible en este sistema."
    fi
}

# --- 3 · Desglose del arranque ------------------------ (Taller 2) ----------
seccion3() {
    titulo "3 · Desglose del arranque (systemd-analyze)"
    if tiene systemd-analyze; then
        systemd-analyze time 2>/dev/null || echo "Aviso: No se pudo obtener el tiempo del arranque."
    else
        echo "Aviso: 'systemd-analyze' no está disponible o no se está ejecutando en este sistema."
    fi
}

# --- 4 · Cinco unidades más lentas -------------------- (en casa) -----------
seccion4() {
    titulo "4 · Las 5 unidades que más tardaron en arrancar"
    # Pista: «systemd-analyze blame --no-pager» ordena las unidades de la más
    #        lenta a la más rápida. Quédate con las 5 primeras (head).
    # TODO
    echo "PENDIENTE: sección 4"
}

# --- 5 · Módulos del núcleo --------------------------- (en casa) -----------
seccion5() {
    titulo "5 · Módulos del núcleo cargados"
    # Pista: «lsmod» lista los módulos; la primera línea es el encabezado.
    #        Cuenta los módulos (tail -n +2, wc -l) y muestra los 5 de mayor
    #        tamaño (columna 2: sort -k2,2 -n -r).
    # TODO
    echo "PENDIENTE: sección 5"
}

# --- 6 · Target por defecto y servicios fallidos ------ (en casa) -----------
seccion6() {
    titulo "6 · Target por defecto y servicios fallidos"
    # Pista: «systemctl get-default» da el target con el que arranca.
    #        «systemctl --failed --no-legend --plain» lista los servicios que
    #        fallaron. Si no hay ninguno, escribe «ninguno».
    # TODO
    echo "PENDIENTE: sección 6"
}

{
    echo "Informe de arranque · $EQUIPO · $(date '+%Y-%m-%d %H:%M')"
    seccion1
    seccion2
    seccion3
    seccion4
    seccion5
    seccion6
} | tee "$SALIDA"

echo
echo "Informe guardado en: $SALIDA"