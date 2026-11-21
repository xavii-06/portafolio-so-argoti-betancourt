
#!/usr/bin/env bash
# =============================================================================
# Deber 5 - Auditoria de seguridad del equipo (Linux)
# Sistemas Operativos - EPN - Semana 5
# Autores: Argoti Xavier, Betancourt Rodrigo
# Fecha: 2026-11-20
# Uso de IA: Se utilizo IA como apoyo para completar y revisar el script.
# =============================================================================

set -u
export LC_ALL=C

UMBRAL=5
MUESTRA=""
RIESGOSAS=(21 23 3306 3389 5900)
declare -A ESTADO

while getopts "u:m:h" op; do
    case "$op" in
        u) UMBRAL="$OPTARG" ;;
        m) MUESTRA="$OPTARG" ;;
        *) echo "Uso: $0 [-u UMBRAL] [-m ARCHIVO_MUESTRA]"; exit 2 ;;
    esac
done

if ! [[ "$UMBRAL" =~ ^[0-9]+$ ]] || (( UMBRAL < 1 )); then
    echo "Error: el umbral debe ser un numero entero positivo."
    exit 2
fi

EQUIPO="$(hostname -s 2>/dev/null || echo equipo)"
SALIDA="auditoria_${EQUIPO}_$(date +%Y%m%d_%H%M).txt"

titulo() {
    printf '\n=== %s ===\n' "$1"
}

marca() {
    ESTADO[$1]="$2"
    printf '%s\n' "-> Seccion $1: $2"
}

# --- 1. Llavero maestro ---------------------------------
seccion1() {
    titulo "1 - Llavero maestro"

    cuentas_uid0="$(awk -F: '$3==0 {print $1}' /etc/passwd)"
    miembros_wheel="$(getent group wheel | cut -d: -f4)"

    echo "Cuentas con UID 0:"
    echo "$cuentas_uid0"

    echo "Miembros del grupo wheel:"
    echo "${miembros_wheel:-Ninguno}"

    adicionales="$(printf '%s\n' "$cuentas_uid0" |
        awk '$0 != "root" && NF {n++} END {print n+0}')"

    if (( adicionales > 0 )); then
        echo "ALERTA: existen cuentas adicionales con UID 0."
        marca 1 ALERTA
    else
        echo "OK: solo root tiene UID 0."
        marca 1 OK
    fi
}

# --- 2. Puertas abiertas --------------------------------
seccion2() {
    titulo "2 - Puertas abiertas"

    direcciones="$(ss -H -tln | awk '{print $4}' | sort -u)"
    alerta=0

    echo "Servicios TCP en escucha:"

    while IFS= read -r d; do
        [[ -z "$d" ]] && continue

        direccion="${d%:*}"
        puerto="${d##*:}"

        if [[ "$direccion" == 127.* ||
              "$direccion" == "[::1]" ||
              "$direccion" == "::1" ]]; then
            alcance="solo el equipo"
        else
            alcance="abierta a la red"
        fi

        echo "$d -> $alcance"

        if [[ "$alcance" == "abierta a la red" ]]; then
            for riesgo in "${RIESGOSAS[@]}"; do
                if [[ "$puerto" == "$riesgo" ]]; then
                    echo "ALERTA: puerto riesgoso $puerto expuesto."
                    alerta=1
                fi
            done
        fi
    done <<< "$direcciones"

    if (( alerta == 1 )); then
        marca 2 ALERTA
    else
        echo "OK: no se detectaron puertos riesgosos abiertos a la red."
        marca 2 OK
    fi
}

# --- 3. Portero activo -----------------------------------
seccion3() {
    titulo "3 - Portero activo"

    estado_firewall="$(systemctl is-active firewalld 2>/dev/null || true)"

    echo "Estado de firewalld: ${estado_firewall:-desconocido}"

    if [[ "$estado_firewall" == "active" ]]; then
        marca 3 OK
    else
        echo "ALERTA: firewalld no esta activo."
        marca 3 ALERTA
    fi
}

# --- 4. Intentos fallidos --------------------------------
seccion4() {
    titulo "4 - Intentos fallidos (umbral: $UMBRAL por IP)"

    if [[ -n "$MUESTRA" ]]; then
        if [[ -r "$MUESTRA" ]]; then
            fallos="$(grep 'Failed password' "$MUESTRA" || true)"
        else
            echo "ALERTA: no se puede leer el archivo $MUESTRA."
            marca 4 ALERTA
            return
        fi
    else
        fallos="$(journalctl -q -u sshd --since '24 hours ago' 2>/dev/null |
            grep 'Failed password' || true)"
    fi

    conteos="$(printf '%s\n' "$fallos" |
        awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' |
        sort | uniq -c | sort -rn)"

    echo "Intentos fallidos por IP:"
    if [[ -n "$conteos" ]]; then
        echo "$conteos"
    else
        echo "No se encontraron intentos fallidos."
    fi

    alerta=0

    while read -r cantidad ip; do
        [[ -z "${cantidad:-}" ]] && continue

        if (( cantidad >= UMBRAL )); then
            echo "ALERTA: $ip alcanzo $cantidad intentos fallidos."
            alerta=1
        fi
    done <<< "$conteos"

    if (( alerta == 1 )); then
        marca 4 ALERTA
    else
        marca 4 OK
    fi
}

# --- 5. Veredicto ----------------------------------------
seccion5() {
    titulo "5 - Veredicto"

    alertas=0
    pendientes=0

    for n in 1 2 3 4; do
        estado="${ESTADO[$n]:-PENDIENTE}"
        echo "Seccion $n: $estado"

        if [[ "$estado" == "ALERTA" ]]; then
            ((alertas += 1))
        elif [[ "$estado" == "PENDIENTE" ]]; then
            ((pendientes += 1))
        fi
    done

    if (( alertas == 0 && pendientes == 0 )); then
        echo "VEREDICTO GENERAL: OK"
        return 0
    else
        echo "VEREDICTO GENERAL: ALERTA"
        echo "Secciones con alerta: $alertas"
        echo "Secciones pendientes: $pendientes"
        return 1
    fi
}

principal() {
    echo "Auditoria de seguridad - $EQUIPO - $(date '+%Y-%m-%d %H:%M')"
    seccion1
    seccion2
    seccion3
    seccion4
    seccion5
}

exec > >(tee "$SALIDA")
principal
codigo=$?

echo
echo "Informe guardado en: $SALIDA"
exit "$codigo"

