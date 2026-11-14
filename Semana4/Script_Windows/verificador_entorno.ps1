# =============================================================================
#  Deber 4 · Verificador de entorno (Windows)            ESQUELETO PARA COMPLETAR
#  Sistemas Operativos · EPN · Semana 4
# -----------------------------------------------------------------------------
#  Autores:   Argoti Xavier, Betancourt Rodrigo
#  Fecha:     2026-11-13
#  Uso de IA: Sí, apoyo para completar y revisar las secciones 1, 2 y 3.
# -----------------------------------------------------------------------------
#  Qué debe hacer: revisar si este equipo tiene las herramientas que usamos en
#  la materia, de dónde vienen y qué falta instalar. Termina con código de
#  salida 0 si está todo y 1 si falta algo.
#    Secciones 1, 2 y 3  → las empiezan en el Taller 2 (parte C).
#    Secciones 4, 5 y 6  → las terminan en casa.
#  Uso:       .\verificador_entorno.ps1
#             .\verificador_entorno.ps1; $LASTEXITCODE    (debe mostrar 0 o 1)
#             No necesita administrador: solo consulta.
#             Si Windows bloquea el script, una sola vez:
#             Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
#  Entrega:   semana04/verificador_entorno.ps1 en el repositorio de la pareja
#             (instrucciones al final).
#
#  Cómo completar: reemplaza cada línea «"PENDIENTE ..."» por los comandos que
#  piden las pistas. Ejecuta el script después de cada sección.
# =============================================================================

$equipo = $env:COMPUTERNAME
$salida = "verificador_{0}_{1}.txt" -f $equipo, (Get-Date -Format "yyyyMMdd_HHmm")

# Herramientas que pide la materia (comando → identificador de winget).
# Ojo: en Windows PowerShell 5.1, «curl» es un alias de Invoke-WebRequest;
# el programa real es curl.exe.
$requeridas = [ordered]@{
    'git'      = 'Git.Git'
    'curl.exe' = 'cURL.cURL'
    'python'   = 'Python.Python.3.12'
    'jq'       = 'jqlang.jq'
    'winget'   = 'Microsoft.AppInstaller (desde Microsoft Store)'
}
$script:faltan = @()      # la sección 2 agrega aquí lo que no encuentre

function Titulo([string]$texto) { ""; "=== $texto ===" }

# Busca un programa real (no alias ni función) y descarta el atajo de la Store
# que abre la tienda en lugar de ejecutar Python.
function Buscar([string]$nombre) {
    $c = Get-Command $nombre -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($c -and $c.Source -like '*\WindowsApps\python*.exe' -and (Get-Item $c.Source).Length -eq 0) { return $null }
    $c
}

# Programas instalados según el registro (lo que muestra «Aplicaciones instaladas»).
function ProgramasInstalados {
    $claves = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
              'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
              'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    Get-ItemProperty $claves -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName }
}

# --- 1 · Sistema y shell ------------------------------- (Taller 2) ----------
function Seccion1 {
    Titulo "1 · Sistema y shell"

    $os = Get-CimInstance Win32_OperatingSystem

    "Sistema operativo: $($os.Caption)"
    "Versión: $($os.Version)"
    "Compilación: $($os.BuildNumber)"
    "PowerShell: $($PSVersionTable.PSVersion)"
    "Edición: $($PSVersionTable.PSEdition)"
    "Usuario: $env:USERNAME"
}

# --- 2 · Herramientas requeridas ----------------------- (Taller 2) ----------
function Seccion2 {
    Titulo "2 · Herramientas requeridas"

    $resultados = foreach ($nombre in $requeridas.Keys) {
        $c = Buscar $nombre

        if ($null -ne $c) {
            $version = "No disponible"

            try {
                $linea = & $c.Source --version 2>&1 |
                    Select-Object -First 1

                if ($null -ne $linea) {
                    $version = [string]$linea
                }
            }
            catch {
                $version = "No se pudo consultar"
            }

            [pscustomobject]@{
                Comando = $nombre
                Estado  = "OK"
                Ruta    = $c.Source
                Version = $version
            }
        }
        else {
            $script:faltan += $nombre

            [pscustomobject]@{
                Comando = $nombre
                Estado  = "FALTA"
                Ruta    = "-"
                Version = "-"
            }
        }
    }

    $resultados
}

# --- 3 · Paquetes instalados y repositorios ------------ (Taller 2) ----------
function Seccion3 {
    Titulo "3 · Programas instalados y orígenes de winget"

    $programas = @(ProgramasInstalados)

    "Cantidad de programas registrados: $($programas.Count)"

    $w = Buscar 'winget'

    if ($null -ne $w) {
        "Orígenes configurados en winget:"
        & $w.Source source list
    }
    else {
        "AVISO: winget no está disponible."
    }
}

# --- 4 · Últimas 5 instalaciones ----------------------- (en casa) -----------
function Seccion4 {
    Titulo "4 · Últimas 5 instalaciones"

    $ultimas = @(
        foreach ($p in (ProgramasInstalados)) {
            $fecha = [datetime]::MinValue
            $textoFecha = [string]$p.InstallDate

            $valida = [datetime]::TryParseExact(
                $textoFecha,
                'yyyyMMdd',
                [Globalization.CultureInfo]::InvariantCulture,
                [Globalization.DateTimeStyles]::None,
                [ref]$fecha
            )

            if ($valida) {
                [pscustomobject]@{
                    Fecha = $fecha.ToString('yyyyMMdd')
                    FechaOrden = $fecha
                    DisplayName = $p.DisplayName
                    DisplayVersion = $p.DisplayVersion
                }
            }
        }
    )

    if ($ultimas.Count -gt 0) {
        $ultimas |
            Sort-Object FechaOrden -Descending |
            Select-Object -First 5 Fecha, DisplayName, DisplayVersion
    }
    else {
        "No se encontraron fechas de instalación válidas."
    }
}
# --- 5 · Qué falta y cómo instalarlo ------------------- (en casa) -----------
function Seccion5 {
    Titulo "5 · Qué falta y cómo instalarlo"

    if ($script:faltan.Count -eq 0) {
        "No falta nada."
    }
    else {
        "Herramientas que faltan y comandos para instalarlas:"

        foreach ($f in $script:faltan) {
            if ($f -eq 'winget') {
                "Instalar App Installer desde Microsoft Store para disponer de winget."
            }
            else {
                "winget install --id {0} -e" -f $requeridas[$f]
            }
        }
    }
}

# --- 6 · Resultado ------------------------------------- (en casa) -----------
function Seccion6 {
    Titulo "6 · Resultado"

    $listas = $requeridas.Count - $script:faltan.Count

    "Herramientas listas: $listas de $($requeridas.Count)"

    if ($script:faltan.Count -eq 0) {
        $script:codigoSalida = 0
        "Código de salida: 0 (todas las herramientas están disponibles)"
    }
    else {
        $script:codigoSalida = 1
        "Código de salida: 1 (faltan herramientas)"
    }
}

$script:codigoSalida = 1
# Format-Table | Out-String convierte los objetos en texto para el informe.
$informe = & {
    "Verificador de entorno · $equipo · $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    Seccion1
    Seccion2 | Format-Table -AutoSize | Out-String -Width 200
    Seccion3
    Seccion4 | Format-Table -AutoSize | Out-String -Width 200
    Seccion5
    Seccion6
}
$informe | Tee-Object -FilePath $salida
""
"Informe guardado en: $salida"
# Pista (sección 6): cambia la línea siguiente para salir con 1 si falta algo.
exit $script:codigoSalida

# -----------------------------------------------------------------------------
#  Subir al portafolio (GitHub), desde la carpeta del repositorio de la pareja:
#    git pull
#    git add semana04/verificador_entorno.ps1 semana04/verificador_*.txt
#    git commit -m "Semana 4: verificador de entorno (Windows), secciones 1-3"
#    git push
#  Haz un commit al terminar el taller y otro al terminar en casa.
#  Cada integrante hace al menos un commit con su parte (criterio de la rúbrica).
# -----------------------------------------------------------------------------
