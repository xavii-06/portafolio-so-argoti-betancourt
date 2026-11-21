# =============================================================================
#  Deber 5 · Auditoría de seguridad del equipo (Windows)
#  Sistemas Operativos · EPN · Semana 5
# -----------------------------------------------------------------------------
#  Autores:   <Integrante 1>, <Integrante 2>
#  Fecha:     2026-11-20
#  Uso de IA: Sí, asistencia para completar y depurar las secciones del script.
# -----------------------------------------------------------------------------
#  Qué debe hacer: revisar cinco cosas del equipo y dar un veredicto.
#    1 · Llavero maestro   miembros de Administradores (S-1-5-32-544) y la
#                          cuenta Administrador integrada (SID ...-500)
#    2 · Puertas abiertas  servicios en escucha y puertas riesgosas a la red
#    3 · Portero activo    perfiles de Windows Firewall habilitados
#    4 · Intentos fallidos eventos 4625 por IP (últimas 24 h o una muestra)
#    5 · Veredicto         ALERTA/OK por sección; código 0 (todo OK) o 1
#    Secciones 1 y 2  → en el Taller 2 (parte C).
#    Secciones 3, 4 y 5 → en casa.
#  Uso:       .\auditoria_seguridad.ps1 -Muestra .\muestras_eventos_4625.csv -Umbral 5
#             .\auditoria_seguridad.ps1 -Muestra .\muestras_eventos_4625.csv; $LASTEXITCODE
#             Sin administrador, la sección 4 usa -Muestra (el registro de
#             Seguridad solo lo lee un administrador).
#             Si Windows bloquea el script, una sola vez:
#             Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
#  Entrega:   semana05/auditoria_seguridad.ps1 en el repositorio de la pareja.
# =============================================================================
param(
    [int]$Umbral = 5,
    [string]$Muestra = ""
)

$riesgosas = 21, 23, 3306, 3389, 5900       # puertas que no deberían dar a la red
$estado = [ordered]@{}                       # lo llena Marca
$equipo = $env:COMPUTERNAME
$salida = "auditoria_{0}_{1}.txt" -f $equipo, (Get-Date -Format "yyyyMMdd_HHmm")

function Titulo([string]$t) { ""; "=== $t ===" }
function Marca([int]$n, [string]$v) { $script:estado["$n"] = $v; "→ Sección ${n}: $v" }

# --- 1 · Llavero maestro ------------------------------ (Taller 2) ----------
function Seccion1 {
    Titulo "1 · Llavero maestro"
    $alerta = $false

    try {
        $miembros = Get-LocalGroupMember -SID 'S-1-5-32-544' -ErrorAction Stop
        "Miembros del grupo Administradores (S-1-5-32-544):"
        foreach ($m in $miembros) {
            "  - $($m.Name) ($($m.ObjectClass))"
        }
    }
    catch {
        "  Aviso: no se pudo listar Administradores directamente ($($_.Exception.Message))."
    }

    try {
        $adminIntegrada = Get-LocalUser -ErrorAction Stop | Where-Object { $_.SID.Value -like '*-500' }
        foreach ($u in $adminIntegrada) {
            $estadoCuenta = if ($u.Enabled) { "Habilitada" } else { "Deshabilitada" }
            "Cuenta integrada (-500): $($u.Name) [SID: $($u.SID.Value)] -> $estadoCuenta"
            if ($u.Enabled) {
                $alerta = $true
            }
        }
    }
    catch {
        "  Aviso: no se pudo consultar cuentas locales ($($_.Exception.Message))."
        $alerta = $true
    }

    if ($alerta) {
        Marca 1 "ALERTA"
    }
    else {
        Marca 1 "OK"
    }
}

# --- 2 · Puertas abiertas ----------------------------- (Taller 2) ----------
function Seccion2 {
    Titulo "2 · Puertas abiertas"
    $alerta = $false

    $escuchas = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
        Sort-Object LocalPort, LocalAddress -Unique

    if (-not $escuchas) {
        "No se encontraron puertos TCP en estado Listen."
        Marca 2 "OK"
        return
    }

    foreach ($conn in $escuchas) {
        $esLocal = ($conn.LocalAddress -in @("127.0.0.1", "::1"))
        $alcance = if ($esLocal) { "solo el equipo" } else { "abierta a la red" }
        $esRiesgosa = ($conn.LocalPort -in $riesgosas)
        $etiqueta = if ($esRiesgosa) { " [RIESGOSA]" } else { "" }

        "  Puerto $($conn.LocalPort) en $($conn.LocalAddress) -> $alcance$etiqueta"

        if ($esRiesgosa -and (-not $esLocal)) {
            $alerta = $true
        }
    }

    if ($alerta) {
        Marca 2 "ALERTA"
    }
    else {
        Marca 2 "OK"
    }
}

# --- 3 · Portero activo ------------------------------- (en casa) -----------
function Seccion3 {
    Titulo "3 · Portero activo"
    $alerta = $false

    $perfiles = Get-NetFirewallProfile -ErrorAction SilentlyContinue |
        Select-Object Name, Enabled

    foreach ($p in $perfiles) {
        $estadoPerfil = if ($p.Enabled) { "Habilitado" } else { "Deshabilitado" }
        "  Perfil $($p.Name): $estadoPerfil"
        if (-not $p.Enabled) {
            $alerta = $true
        }
    }

    if ($alerta) {
        Marca 3 "ALERTA"
    }
    else {
        Marca 3 "OK"
    }
}

# --- 4 · Intentos fallidos ---------------------------- (en casa) -----------
function Seccion4 {
    Titulo "4 · Intentos fallidos (umbral: $Umbral por IP)"
    $alerta = $false
    $ips = @()

    if (-not [string]::IsNullOrWhiteSpace($Muestra)) {
        if (-not (Test-Path -Path $Muestra -PathType Leaf)) {
            "  Error: no se encontró el archivo de muestra '$Muestra'."
            Marca 4 "ALERTA"
            return
        }

        "Leyendo muestra desde: $Muestra"
        $eventosCsv = Import-Csv -Path $Muestra | Where-Object { $_.Id -eq '4625' }
        $ips = $eventosCsv |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_.IpAddress) -and $_.IpAddress -ne '-' } |
            Group-Object -Property IpAddress |
            Sort-Object -Property Count -Descending
    }
    else {
        "Consultando registro de Seguridad (últimas 24 horas, Evento 4625)..."
        try {
            $hace24h = (Get-Date).AddHours(-24)
            $eventosLog = Get-WinEvent -FilterHashtable @{
                LogName   = 'Security'
                Id        = 4625
                StartTime = $hace24h
            } -ErrorAction Stop

            $extraidos = foreach ($ev in $eventosLog) {
                $xml = [xml]$ev.ToXml()
                $ipNode = $xml.Event.EventData.Data | Where-Object { $_.Name -eq 'IpAddress' }
                if ($ipNode -and -not [string]::IsNullOrWhiteSpace($ipNode.'#text') -and $ipNode.'#text' -ne '-') {
                    [PSCustomObject]@{ IpAddress = $ipNode.'#text' }
                }
            }

            $ips = $extraidos |
                Group-Object -Property IpAddress |
                Sort-Object -Property Count -Descending
        }
        catch {
            "  No se pudo leer el registro de Seguridad: se requiere administrador."
            "  Sugerencia: ejecute el script con el parámetro -Muestra (por ejemplo: -Muestra .\muestras_eventos_4625.csv)."
            Marca 4 "ALERTA"
            return
        }
    }

    if (-not $ips -or @($ips).Count -eq 0) {
        "  No se registraron intentos fallidos con IP válida."
    }
    else {
        foreach ($g in $ips) {
            $supera = ($g.Count -ge $Umbral)
            $marcaIp = if ($supera) { " -> SUPERA UMBRAL" } else { "" }
            "  IP $($g.Name): $($g.Count) intento(s)$marcaIp"
            if ($supera) {
                $alerta = $true
            }
        }
    }

    if ($alerta) {
        Marca 4 "ALERTA"
    }
    else {
        Marca 4 "OK"
    }
}

# --- 5 · Veredicto ------------------------------------ (en casa) -----------
function Seccion5 {
    Titulo "5 · Veredicto"
    $totalAlertas = 0

    foreach ($n in 1..4) {
        $valor = $script:estado["$n"]
        "  Sección $n : $valor"
        if ($valor -eq "ALERTA") {
            $totalAlertas++
        }
    }

    ""
    if ($totalAlertas -gt 0) {
        $script:codigo = 1
        "Veredicto final: ALERTA ($totalAlertas sección(es) con alerta). Código de salida: 1"
    }
    else {
        $script:codigo = 0
        "Veredicto final: OK (sin alertas). Código de salida: 0"
    }
}

$script:codigo = 0
& {
    "Auditoría de seguridad · $equipo · $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    Seccion1; Seccion2; Seccion3; Seccion4; Seccion5
} | Tee-Object -FilePath $salida
""
"Informe guardado en: $salida"
exit $script:codigo