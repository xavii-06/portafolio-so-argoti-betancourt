
# Archivo de salida
$Archivo = "$PSScriptRoot\resumen_diagnostico.txt"

# Capturar toda la informacion del diagnostico
$Resumen = @(
    "=========================================="
    "       RESUMEN DE DIAGNOSTICO DEL PC"
    "=========================================="
    ""

    "1. FECHA ACTUAL"
    (Get-Date -f d).ToString()
    ""

    "2. SISTEMA OPERATIVO"
)

# Obtener informacion del sistema operativo
$SO = Get-CimInstance Win32_OperatingSystem

$Resumen += "Nombre: $($SO.Caption)"
$Resumen += "Version: $($SO.Version)"
$Resumen += "Arquitectura: $($SO.OSArchitecture)"
$Resumen += "Equipo: $($SO.CSName)"
$Resumen += "Memoria fisica total: $([math]::Round($SO.TotalVisibleMemorySize / 1MB, 2)) GB"
$Resumen += "Memoria fisica libre: $([math]::Round($SO.FreePhysicalMemory / 1MB, 2)) GB"
$Resumen += ""

# Informacion de la cache
$Resumen += "3. MEMORIA CACHE"
$Cache = Get-CimInstance Win32_CacheMemory

if ($Cache) {
    foreach ($C in $Cache) {
        $Resumen += "Nivel: $($C.Level)"
        $Resumen += "Ubicacion: $($C.Location)"
        $Resumen += "Tamano: $($C.InstalledSize) KB"
        $Resumen += "Tipo: $($C.CacheType)"
        $Resumen += "------------------------------"
    }
} else {
    $Resumen += "No se encontro informacion de cache."
}

$Resumen += ""

# Informacion de los discos
$Resumen += "4. UNIDADES DE ALMACENAMIENTO"
$Discos = Get-PhysicalDisk

if ($Discos) {
    foreach ($Disco in $Discos) {
        $Resumen += "Nombre: $($Disco.FriendlyName)"
        $Resumen += "Tipo: $($Disco.MediaType)"
        $Resumen += "Tamano: $([math]::Round($Disco.Size / 1GB, 2)) GB"
        $Resumen += "Estado: $($Disco.HealthStatus)"
        $Resumen += "------------------------------"
    }
} else {
    $Resumen += "No se encontraron discos fisicos."
}

$Resumen += ""
$Resumen += "=========================================="
$Resumen += "       DIAGNOSTICO FINALIZADO"
$Resumen += "=========================================="

# Mostrar en pantalla y guardar en TXT
$Resumen | Tee-Object -FilePath $Archivo

Write-Host ""
Write-Host "Resumen guardado en: $Archivo" -ForegroundColor Green
