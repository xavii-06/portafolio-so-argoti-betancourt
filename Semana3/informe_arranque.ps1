# =============================================================================
#  Deber 3 · Informe de arranque (Windows)           COMPLETADO (Secciones 1-3)
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
#  Uso:       .\informe_arranque.ps1
#             Si Windows bloquea el script, una sola vez:
#             Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
#  Entrega:   guárdalo como semana03/informe_arranque.ps1 en el repositorio
#             de la pareja y súbelo a GitHub (instrucciones al final).
# =============================================================================

$equipo = $env:COMPUTERNAME
$salida = "informe_arranque_{0}_{1}.txt" -f $equipo, (Get-Date -Format "yyyyMMdd_HHmm")
$power  = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power'
$logDiag = 'Microsoft-Windows-Diagnostics-Performance/Operational'

function Titulo([string]$texto) {
    ""
    "=== $texto ==="
}

# Devuelve $true si la PowerShell se abrió como administrador.
function EsAdministrador {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Lee un dato con nombre (por ejemplo 'BootTime') de un evento del registro.
function DatoEvento($evento, [string]$nombre) {
    $xml = [xml]$evento.ToXml()
    ($xml.Event.EventData.Data | Where-Object { $_.Name -eq $nombre }).'#text'
}

# --- 1 · SO, versión y compilación -------------------- (Taller 2) ----------
function Seccion1 {
    Titulo "1 · Sistema operativo, versión y compilación"
    $os = Get-CimInstance Win32_OperatingSystem
    "Sistema:       {0}" -f $os.Caption
    "Versión:       {0}" -f $os.Version
    "Compilación:   {0}" -f $os.BuildNumber
    "Arquitectura:  {0}" -f $os.OSArchitecture
}

# --- 2 · Último arranque y uptime --------------------- (Taller 2) ----------
function Seccion2 {
    Titulo "2 · Último arranque y tiempo encendido"
    $os = Get-CimInstance Win32_OperatingSystem
    $lastBoot = $os.LastBootUpTime
    $uptime = (Get-Date) - $lastBoot
    "Último arranque: {0:yyyy-MM-dd HH:mm:ss}" -f $lastBoot
    "Tiempo activo:   {0} días, {1} horas, {2} minutos" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
}

# --- 3 · Desglose del arranque ------------------------ (Taller 2) ----------
function Seccion3 {
    Titulo "3 · Desglose del arranque"
    
    # Tiempo de Firmware (POST)
    try {
        $fwTimeMs = (Get-ItemProperty -Path $power -Name FwPOSTTime -ErrorAction Stop).FwPOSTTime
        "Tiempo de Firmware (POST): {0} ms ({1:N2} s)" -f $fwTimeMs, ($fwTimeMs / 1000)
    } catch {
        "Tiempo de Firmware (POST): No disponible"
    }

    # Desglose del SO (Evento 100) - Requiere Privilegios de Administrador
    if (EsAdministrador) {
        try {
            $e = Get-WinEvent -FilterHashtable @{ LogName = $logDiag; Id = 100 } -MaxEvents 1 -ErrorAction Stop
            $bootTime = DatoEvento $e 'BootTime'
            $mainPath = DatoEvento $e 'MainPathBootTime'
            $postBoot = DatoEvento $e 'BootPostBootTime'

            "Tiempo total de arranque (BootTime):         {0} ms ({1:N2} s)" -f $bootTime, ([double]$bootTime / 1000)
            "  - Ruta principal (MainPathBootTime):      {0} ms ({1:N2} s)" -f $mainPath, ([double]$mainPath / 1000)
            "  - Posarranque (BootPostBootTime):         {0} ms ({1:N2} s)" -f $postBoot, ([double]$postBoot / 1000)
        } catch {
            "Aviso: No se encontraron registros de eventos de arranque (Evento 100)."
        }
    } else {
        "Aviso: Para ver el desglose detallado del SO (evento 100), ejecuta PowerShell como Administrador."
    }
}

# --- 4 · Servicios y demoras -------------------------- (en casa) -----------
function Seccion4 {
    Titulo "4 · Servicios y demoras del arranque"
    # Pista: Get-CimInstance Win32_Service da todos los servicios.
    #        Cuenta los que tienen State 'Running' y lista hasta 5 que tengan
    #        StartMode 'Auto' pero no estén en ejecución.
    # Opcional (administrador): los eventos 101, 102 y 103 de $logDiag dicen
    #        qué componentes demoraron el arranque ('FriendlyName', 'TotalTime').
    # TODO
    "PENDIENTE: sección 4"
}

# --- 5 · Controladores -------------------------------- (en casa) -----------
function Seccion5 {
    Titulo "5 · Controladores (drivers)"
    # Pista: driverquery /fo csv | ConvertFrom-Csv  → cuenta los controladores.
    #        Get-CimInstance Win32_SystemDriver → cuenta los que están 'Running'.
    # TODO
    "PENDIENTE: sección 5"
}

# --- 6 · Inicio rápido -------------------------------- (en casa) -----------
function Seccion6 {
    Titulo "6 · Inicio rápido"
    # Pista: (Get-ItemProperty -Path $power -Name HiberbootEnabled).HiberbootEnabled
    #        vale 1 si el inicio rápido está activado y 0 si no.
    # TODO
    "PENDIENTE: sección 6"
}

$informe = & {
    "Informe de arranque · $equipo · $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    Seccion1
    Seccion2
    Seccion3
    Seccion4
    Seccion5
    Seccion6
}
$informe | Tee-Object -FilePath $salida
""
"Informe guardado en: $salida"