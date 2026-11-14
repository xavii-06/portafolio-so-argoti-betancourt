#!/usr/bin/env bash
# =============================================================================
#  Deber 4 · Verificador de entorno (Linux)                        COMPLETO
#  Sistemas Operativos · EPN · Semana 4
# -----------------------------------------------------------------------------
#  Autores:   <Argoti Xavier>, <Betancourt Rodrigo>
#  Fecha:     13/11/2026
#  Uso de IA: Sí. Se usó IA generativa (Claude, de Anthropic) para redactar y
#             comentar el script a partir del esqueleto de la cátedra. La pareja
#             lo ejecutó, lo revisó y lo entiende. <Ajusten esta línea a la realidad.>
# -----------------------------------------------------------------------------
#  Qué hace: revisa si este equipo tiene las herramientas que usamos en la
#  materia, de dónde vienen y qué falta instalar. Termina con código de salida
#  0 si está todo y 1 si falta algo.
#
#    1 · Sistema y shell            (/etc/os-release, uname -r, $BASH_VERSION)
#    2 · Herramientas requeridas    (command -v y --version)
#    3 · Paquetes y repositorios    (rpm -qa, dnf repolist, rpm -qf, dnf info)
#    4 · Últimas 5 transacciones    (dnf history list)
#    5 · Qué falta y cómo instalarlo (muestra el comando; NO lo ejecuta)
#    6 · Resultado                  (Herramientas listas X de Y · código 0 / 1)
#
# =============================================================================

set -u
export LC_ALL=C          # salidas de dnf y rpm en inglés: más fáciles de filtrar

EQUIPO="$(hostname -s 2>/dev/null || echo equipo)"
SALIDA="verificador_${EQUIPO}_$(date +%Y%m%d_%H%M).txt"

# Herramientas que pide la materia (comando → paquete de dnf que lo trae).
REQUERIDAS=(git curl python3 jq strace tree)
declare -A PAQUETE=([git]=git [curl]=curl [python3]=python3 [jq]=jq [strace]=strace [tree]=tree)
FALTAN=()                # la sección 2 agrega aquí lo que no encuentre

# --- Funciones de ayuda --------------------------------------------------------
titulo() { printf '\n=== %s ===\n' "$1"; }
tiene()  { command -v "$1" >/dev/null 2>&1; }
aviso()  { printf 'AVISO: %s\n' "$*" >&2; }     # los avisos van a la salida de errores (2)

# --- 1 · Sistema y shell ------------------------------- (Taller 2) ----------
# Muestra distribución, núcleo, versión de bash, usuario y equipo.
# Se carga /etc/os-release dentro de un subshell «( ... )» para que sus
# variables (NAME, VERSION, ID...) no se mezclen con las del script.
seccion1() {
    titulo "1 · Sistema y shell"

    local distro="desconocida"
    if [[ -r /etc/os-release ]]; then
        distro="$( . /etc/os-release; printf '%s' "${PRETTY_NAME:-desconocida}" )"
    else
        aviso "no existe /etc/os-release: no puedo saber la distribución"
    fi

    # Etiquetas sin tildes: con LC_ALL=C printf cuenta bytes y las tildes desalinean.
    printf '%-10s %s\n' "Distro:"  "$distro"
    printf '%-10s %s\n' "Kernel:"  "$(uname -r)"
    printf '%-10s %s\n' "Bash:"    "${BASH_VERSION:-desconocida}"
    printf '%-10s %s\n' "Usuario:" "$(id -un)"
    printf '%-10s %s\n' "Equipo:"  "$EQUIPO"
}

# --- 2 · Herramientas requeridas ----------------------- (Taller 2) ----------
# Recorre REQUERIDAS. Si el comando existe: OK + ruta + primera línea de su
# versión. Si no: FALTA, y lo agrega a FALTAN (lo usan las secciones 5 y 6).
seccion2() {
    titulo "2 · Herramientas requeridas"

    printf '%-9s %-8s %-22s %s\n' "COMANDO" "ESTADO" "RUTA" "VERSION"
    local c ruta version
    for c in "${REQUERIDAS[@]}"; do
        if tiene "$c"; then
            ruta="$(command -v "$c")"
            if [[ "$c" == "strace" ]]; then      # strace no usa --version, usa -V
                version="$("$c" -V 2>&1 | head -n 1)"
            else
                version="$("$c" --version 2>&1 | head -n 1)"
            fi
            version="${version%% (*}"            # curl: quita « (x86_64...) libcurl/...» (línea larguísima)
            printf '%-9s %-8s %-22s %s\n' "$c" "OK" "$ruta" "$version"
        else
            printf '%-9s %-8s %-22s %s\n' "$c" "FALTA" "-" "-"
            FALTAN+=("$c")
        fi
    done
}

# --- 3 · Paquetes instalados y repositorios ------------ (Taller 2) ----------
# a) cuántos paquetes rpm hay instalados, b) qué repositorios están activos,
# c) (reto) de qué paquete y de qué repositorio vino cada herramienta.
# Si rpm o dnf no existen, AVISA en lugar de fallar.
seccion3() {
    titulo "3 · Paquetes instalados y repositorios"

    # a) Paquetes instalados
    if tiene rpm; then
        printf 'Paquetes instalados (rpm -qa): %s\n' "$(rpm -qa 2>/dev/null | wc -l)"
    else
        aviso "rpm no existe: no puedo contar los paquetes instalados"
    fi

    # b) Repositorios habilitados. «-C» usa solo la caché local (no pide sudo ni
    #    descarga nada). Si la caché está vacía, se reintenta sin «-C».
    echo
    echo "Repositorios habilitados:"
    if tiene dnf; then
        local repos
        repos="$(dnf -q -C repolist --enabled 2>/dev/null)"
        if [[ -z "$repos" ]]; then
            repos="$(dnf -q repolist --enabled 2>/dev/null)"
        fi
        if [[ -n "$repos" ]]; then
            printf '%s\n' "$repos"
        else
            aviso "dnf no pudo listar los repositorios (¿sin caché o sin red?)"
        fi
    else
        aviso "dnf no existe: no puedo listar los repositorios"
    fi

    # c) Reto: paquete y repositorio de cada herramienta instalada
    echo
    echo "Origen de cada herramienta instalada:"
    printf '%-9s %-24s %s\n' "COMANDO" "PAQUETE" "REPOSITORIO"
    local c ruta paquete repo info p
    for c in "${REQUERIDAS[@]}"; do
        tiene "$c" || continue                  # solo las que sí están instaladas
        ruta="$(command -v "$c")"
        paquete="-"
        repo="-"

        if tiene rpm && [[ "$ruta" == /* ]]; then
            # rpm -qf: ¿qué paquete instaló este archivo? (falla si no es de ningún paquete)
            if p="$(rpm -qf --qf '%{NAME}\n' "$ruta" 2>/dev/null)"; then
                paquete="${p%%$'\n'*}"          # solo la primera línea
            else
                paquete="(no es de un rpm)"
            fi

            # dnf info --installed: la línea «From repo» dice de qué repositorio vino
            if [[ "$paquete" != "(no es de un rpm)" ]] && tiene dnf; then
                info="$(dnf -q -C info --installed "$paquete" 2>/dev/null)"
                repo="$(printf '%s\n' "$info" | grep -i -m1 '^From repo' | sed 's/^[^:]*:[[:space:]]*//')"
                [[ -n "$repo" ]] || repo="(desconocido)"
            fi
        fi
        printf '%-9s %-24s %s\n' "$c" "$paquete" "$repo"
    done
}

# --- 4 · Últimas 5 transacciones ----------------------- (en casa) -----------
seccion4() {
    titulo "4 · Últimas 5 transacciones de paquetes"
    # Pista: «dnf -q history list» muestra el historial (se lee sin sudo).
    #        Quédate con la cabecera y 5 filas (head -n 7).
    # Si dnf no existe, usa «aviso» en lugar de fallar.
    # TODO
    echo "PENDIENTE: sección 4"
}

# --- 5 · Qué falta y cómo instalarlo ------------------- (en casa) -----------
seccion5() {
    titulo "5 · Qué falta y cómo instalarlo"
    # Pista: si ${#FALTAN[@]} es 0, escribe «No falta nada.».
    #        Si no, para cada c en FALTAN muestra:  sudo dnf install -y ${PAQUETE[$c]}
    # TODO
    echo "PENDIENTE: sección 5"
}

# --- 6 · Resultado ------------------------------------- (en casa) -----------
seccion6() {
    titulo "6 · Resultado"
    # Pista: muestra «Herramientas listas: X de Y».
    #        Termina la función con «return 0» si no falta nada y «return 1» si falta algo.
    # TODO
    echo "PENDIENTE: sección 6"
    return 0
}

principal() {
    echo "Verificador de entorno · $EQUIPO · $(date '+%Y-%m-%d %H:%M')"
    seccion1
    seccion2          # llena FALTAN: debe ir antes de las secciones 5 y 6
    seccion3
    seccion4
    seccion5
    seccion6
}

# principal corre dentro de la tubería; su código de salida queda en PIPESTATUS[0].
principal | tee "$SALIDA"
codigo=${PIPESTATUS[0]}
echo
echo "Informe guardado en: $SALIDA"
exit "$codigo"

# -----------------------------------------------------------------------------
#  Subir al portafolio (GitHub), desde la carpeta del repositorio de la pareja:
#    git pull
#    git add semana04/verificador_entorno.sh semana04/verificador_*.txt
#    git commit -m "Semana 4: verificador de entorno (Linux), secciones 1-3"
#    git push
#  Haz un commit al terminar el taller y otro al terminar en casa.
#  Cada integrante hace al menos un commit con su parte (criterio de la rúbrica).
# -----------------------------------------------------------------------------