
# ==================================================
# DIAGNOSTICO DE WINDOWS 10 + NOTIFICACION TELEGRAM
# Ejecucion manual - PowerShell 5.1 compatible
# ==================================================

$ErrorActionPreference = "Stop"

# -------- CONFIGURACION DE TELEGRAM ---------------
$BotToken = "8680016227:AAHfDplsVFamMgHx_w-c5rnrxxG9AwgvTiY"
$ChatID   = "1300717936"

# -------- CARPETA DE INFORMES --------------------
$Carpeta = Join-Path $env:USERPROFILE "Desktop\DiagnosticoWindows"
New-Item -Path $Carpeta -ItemType Directory -Force |
    Out-Null

$Fecha = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$Correctos = 0
$Fallidos = [System.Collections.Generic.List[string]]::new()

# -------- FUNCION PARA EJECUTAR CONSULTAS --------
function Guardar-Consulta {
    param(
        [string]$Nombre,
        [scriptblock]$Comando
    )

    $Ruta = Join-Path $Carpeta "$Nombre.txt"

    try {
        $Datos = @(& $Comando)

        if ($Datos.Count -eq 0) {
            "La consulta no devolvio resultados." |
                Set-Content -Path $Ruta -Encoding UTF8
        }
        else {
            $Datos | Out-String -Width 240 |
                Set-Content -Path $Ruta -Encoding UTF8
        }

        $script:Correctos++
        Write-Host "[OK] $Nombre" -ForegroundColor Green
        return $true
    }
    catch {
        $Mensaje = "ERROR: $($_.Exception.Message)"
        $Mensaje | Set-Content -Path $Ruta -Encoding UTF8
        $script:Fallidos.Add($Nombre)

        Write-Host "[ERROR] $Nombre" -ForegroundColor Red
        return $false
    }
}

Write-Host "Iniciando diagnostico de Windows..." `
    -ForegroundColor Cyan

# 1. Procesador
Guardar-Consulta "01_Procesador" {
    Get-CimInstance Win32_Processor |
        Select-Object Name, Manufacturer, NumberOfCores,
            NumberOfLogicalProcessors, MaxClockSpeed
} | Out-Null

# 2. Memoria RAM
Guardar-Consulta "02_MemoriaRAM" {
    Get-CimInstance Win32_PhysicalMemory |
        Select-Object Manufacturer, Capacity, Speed,
            PartNumber, DeviceLocator
} | Out-Null

# 3. Discos fisicos
Guardar-Consulta "03_DiscosFisicos" {
    Get-PhysicalDisk |
        Select-Object FriendlyName, MediaType, BusType,
            HealthStatus, OperationalStatus, Size
} | Out-Null

# 4. Volumenes
Guardar-Consulta "04_Volumenes" {
    Get-Volume |
        Select-Object DriveLetter, FileSystemLabel,
            FileSystem, HealthStatus, Size, SizeRemaining
} | Out-Null

# 5. Dispositivos Plug and Play presentes
Guardar-Consulta "05_DispositivosPnP" {
    Get-PnpDevice -PresentOnly |
        Select-Object Status, Class, FriendlyName, InstanceId
} | Out-Null

# 6. Informacion general del sistema
Guardar-Consulta "06_SystemInfo" {
    $Salida = & "$env:windir\System32\systeminfo.exe" 2>&1

    if ($LASTEXITCODE -ne 0) {
        throw "systeminfo termino con codigo $LASTEXITCODE"
    }

    $Salida
} | Out-Null

# 7. Informe de MSINFO32
try {
    $RutaMSInfo = Join-Path $Carpeta "07_MSInfo32.txt"

    $Proceso = Start-Process `
        -FilePath "$env:windir\System32\msinfo32.exe" `
        -ArgumentList "/report `"$RutaMSInfo`"" `
        -Wait -PassThru

    if ((Test-Path $RutaMSInfo) -and
        (Get-Item $RutaMSInfo).Length -gt 0) {

        $Correctos++
        Write-Host "[OK] MSInfo32" -ForegroundColor Green
    }
    else {
        throw "No se genero el informe MSInfo32."
    }
}
catch {
    $Fallidos.Add("MSInfo32")
    Write-Host "[ERROR] MSInfo32" -ForegroundColor Red
}

# -------- RESUMEN DEL HARDWARE -------------------
$CPU = "No disponible"
$RAM = "No disponible"
$Discos = "No disponibles"

try {
    $Procesador = Get-CimInstance Win32_Processor |
        Select-Object -First 1

    if ($Procesador.Name) {
        $CPU = $Procesador.Name.Trim()
    }
}
catch {}

try {
    $BytesRAM = (Get-CimInstance Win32_PhysicalMemory |
        Measure-Object -Property Capacity -Sum).Sum

    if ($BytesRAM -gt 0) {
        $RAM = "{0:N2} GB" -f ($BytesRAM / 1GB)
    }
}
catch {}

try {
    $ListaDiscos = @(Get-PhysicalDisk)

    if ($ListaDiscos.Count -gt 0) {
        $Lineas = foreach ($Disco in $ListaDiscos) {
            $Tamano = "{0:N0} GB" -f ($Disco.Size / 1GB)
            "$($Disco.FriendlyName): $Tamano - Estado: $($Disco.HealthStatus)"
        }

        $Discos = $Lineas -join "`n"
    }
}
catch {}

# -------- CREAR MENSAJE --------------------------
$Total = 7
$FallidosTexto = if ($Fallidos.Count -gt 0) {
    $Fallidos -join ", "
} else {
    "Ninguno"
}

$Estado = if ($Fallidos.Count -eq 0 -and
    $Correctos -eq $Total) {
    "TODAS LAS CONSULTAS FINALIZARON"
} else {
    "DIAGNOSTICO CON INCIDENCIAS"
}

$Resumen = @"
DIAGNOSTICO DE WINDOWS

Equipo: $env:COMPUTERNAME
Usuario: $env:USERNAME
Fecha: $Fecha

Estado: $Estado
Consultas completadas: $Correctos de $Total
Consultas con error: $($Fallidos.Count)
Consultas fallidas: $FallidosTexto

RESUMEN DEL HARDWARE
Procesador: $CPU
Memoria RAM: $RAM

Discos fisicos:
$Discos

Informe completo guardado en:
$Carpeta
"@

$Resumen | Set-Content `
    -Path (Join-Path $Carpeta "00_Resumen.txt") `
    -Encoding UTF8

Write-Host "`n$Resumen" -ForegroundColor Cyan

# -------- ENVIAR MENSAJE POR TELEGRAM ------------
if ($BotToken -eq "COLOCA_AQUI_TU_TOKEN" -or
    $ChatID -eq "COLOCA_AQUI_TU_CHAT_ID" -or
    [string]::IsNullOrWhiteSpace($BotToken) -or
    [string]::IsNullOrWhiteSpace($ChatID)) {

    Write-Host "`nFalta configurar Telegram." `
        -ForegroundColor Yellow
}
else {
    try {
        $URL = "https://api.telegram.org/bot$BotToken/sendMessage"

        $Respuesta = Invoke-RestMethod `
            -Uri $URL `
            -Method Post `
            -Body @{
                chat_id = $ChatID
                text = $Resumen
            } `
            -ErrorAction Stop

        if ($Respuesta.ok) {
            Write-Host "`nMensaje enviado a Telegram." `
                -ForegroundColor Green
        }
        else {
            Write-Host "`nTelegram no confirmo el envio." `
                -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "`nError al enviar a Telegram: $($_.Exception.Message)" `
            -ForegroundColor Red
    }
}

Write-Host "`nDiagnostico finalizado." -ForegroundColor Cyan
Read-Host "Presiona Enter para cerrar"
