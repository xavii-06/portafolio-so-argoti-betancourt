# Lista de Comandos básicos
## S.O. Windows con PoweShell
* **Get-CimInstance Win32_CacheMemory**: Consulta información mediante WMI/CIM sobre la memoria caché del sistema
* **Get-Date -f d**: Obtiene la fecha actual formateada.
* **Get-PhysicalDisk**: Lista los discos físicos conectados al equipo.
* **Win32_OperatingSystem**: Clase WMI utilizada como referencia para consultar el estado del sistema operativo y la memoria RAM.

## S.O. Linux con Bash
* **lscpu --caches**: Muestra información detallada sobre los niveles y características de las cachés de la CPU.
* **getconf LEVEL1_DCACHE_LINESIZE**: Consulta el tamaño de línea de la caché de datos de primer nivel.
* **free -h**: Muestra de forma legible el uso de la memoria RAM y el espacio de intercambio (swap).
* **hostname**: Devuelve el nombre del equipo actual.
* **date +%F**: Muestra la fecha actual en formato estándar
* **uname -m**: Muestra la arquitectura del sistema
* **lsblk -do NAME,ROTA,SIZE**: Lista los discos y dispositivos de almacenamiento indicando su nombre, si son mecánicos/rotacionales y su tamaño.