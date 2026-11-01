# Lista de Comandos básicos

## S.O. Windows con PowerShell
* **Get-CimInstance Win32_CacheMemory**: Consulta información mediante WMI/CIM sobre la memoria caché del sistema.
* **Get-Date -f d**: Obtiene la fecha actual formateada.
* **Get-PhysicalDisk**: Lista los discos físicos conectados al equipo.
* **Win32_OperatingSystem**: Clase WMI utilizada como referencia para consultar el estado del sistema operativo y la memoria RAM.
* **Get-ChildItem**: Lista los archivos y directorios en la ubicación actual.
* **Get-Location**: Muestra la ruta del directorio de trabajo actual.
* **Set-Location <ruta>**: Cambia el directorio de trabajo a la ruta especificada.
* **Clear-Host**: Limpia el contenido visible de la consola.
* **New-Item -ItemType Directory <nombre>**: Crea un nuevo directorio en la ruta actual.
* **New-Item <archivo>**: Crea un archivo vacío en el directorio especificado.
* **Copy-Item <origen> <destino>**: Copia archivos o directorios de una ubicación a otra.
* **Move-Item <origen> <destino>**: Mueve o renombra archivos y directorios.
* **Remove-Item <ruta>**: Elimina archivos o directorios especificados.
* **Get-Content <archivo>**: Muestra el contenido del archivo de texto.
* **Select-String -Path <archivo> -Pattern "<texto>"**: Busca patrones de texto dentro de un archivo.
* **Get-Process**: Muestra la lista de todos los procesos activos en el sistema.
* **Stop-Process -Id <PID>**: Finaliza un proceso según su identificador único.
* **Get-NetIPAddress**: Obtiene la configuración de direcciones IP de las interfaces de red.
* **Test-Connection <host>**: Envía paquetes ICMP a un host distante para verificar conectividad.

## S.O. Linux con Bash
* **lscpu --caches**: Muestra información detallada sobre los niveles y características de las cachés de la CPU.
* **getconf LEVEL1_DCACHE_LINESIZE**: Consulta el tamaño de línea de la caché de datos de primer nivel.
* **free -h**: Muestra de forma legible el uso de la memoria RAM y el espacio de intercambio (swap).
* **hostname**: Devuelve el nombre del equipo actual.
* **date +%F**: Muestra la fecha actual en formato estándar.
* **uname -m**: Muestra la arquitectura del sistema.
* **lsblk -do NAME,ROTA,SIZE**: Lista los discos y dispositivos de almacenamiento indicando su nombre, si son mecánicos/rotacionales y su tamaño.
* **ls -la**: Lista todos los archivos y directorios, incluidos los ocultos, con detalles de permisos y tamaño.
* **pwd**: Muestra la ruta del directorio de trabajo actual.
* **cd <ruta>**: Cambia el directorio de trabajo actual a la ruta especificada.
* **clear**: Limpia la pantalla de la terminal.
* **mkdir <nombre>**: Crea un nuevo directorio.
* **touch <archivo>**: Crea un archivo vacío o actualiza la marca de tiempo de uno existente.
* **cp -r <origen> <destino>**: Copia archivos o directorios de forma recursiva.
* **mv <origen> <destino>**: Mueve o renombra archivos y directorios.
* **rm -rf <ruta>**: Elimina archivos o directorios de forma recursiva y forzada.
* **cat <archivo>**: Muestra el contenido de un archivo en la terminal.
* **grep "<texto>" <archivo>**: Busca líneas que coincidan con un patrón dentro de un archivo.
* **ps aux**: Muestra una lista detallada de todos los procesos en ejecución.
* **kill -9 <PID>**: Fuerza la finalización de un proceso mediante su PID.
* **ip a**: Muestra las interfaces de red y sus direcciones IP asociadas.
* **ping -c 4 <host>**: Envía una cantidad determinada de paquetes ICMP a un host para comprobar conexión.