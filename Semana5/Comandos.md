# Lista de Comandos básicos - Semana 5

## S.O. Windows con PowerShell
* **Get-NetTCPConnection -State Listen**: Lista todos los puertos TCP que se encuentran actualmente en estado de escucha (`Listen`) y sus direcciones IP asociadas (`0.0.0.0` o `127.0.0.1`).
* **Test-NetConnection -ComputerName <host> -Port <puerto>**: Comprueba la conectividad de red hacia un equipo y puerto específico (equivalente a probar una puerta individual).
* **Get-NetFirewallProfile**: Muestra el estado (habilitado/deshabilitado) y la configuración de los perfiles del cortafuegos de Windows Defender.
* **Get-NetFirewallRule**: Lista las reglas configuradas actualmente en el cortafuegos de Windows.
* **New-NetFirewallRule -DisplayName '<nombre>' -Direction Inbound -Protocol TCP -LocalPort <puerto> -RemoteAddress <ip_o_red> -Action Allow**: Crea una nueva regla de entrada en el motor WFP permitiendo el tráfico TCP hacia un puerto desde una IP o subred específica.
* **Get-Service mpssvc, BFE**: Verifica el estado de los servicios esenciales del cortafuegos de Windows (`mpssvc` y *Base Filtering Engine*).
* **whoami /user**: Muestra el nombre de usuario actual junto con su Identificador de Seguridad (SID) único.
* **whoami /groups**: Lista los grupos a los que pertenece la cuenta actual y muestra el nivel de integridad obligatorio de la sesión (ej. nivel Medio o Alto por UAC).
* **whoami /priv**: Muestra los privilegios de seguridad asignados al token de acceso del usuario actual.
* **Get-LocalGroupMember -SID S-1-5-32-544**: Lista los miembros que pertenecen al grupo local de Administradores utilizando su SID universal (`S-1-5-32-544`).
* **icacls <ruta_archivo>**: Muestra o modifica las listas de control de acceso (permisos NTFS) de un archivo o directorio del sistema (como `\config\SAM`).
* **Start-Process <programa> -Verb RunAs**: Ejecuta un programa o terminal solicitando elevación de privilegios mediante el Control de Cuentas de Usuario (UAC) para pasar a nivel Alto.
* **Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625}**: Consulta el Visor de eventos de Seguridad (requiere privilegios de administrador) filtrando por ID de evento (`4624` inicio correcto, `4625` inicio fallido, `4672` privilegios especiales, `1102` registro borrado).

## S.O. Linux con Bash
* **ss -tln**: Lista todos los puertos TCP (`-t`) en estado de escucha (`-l`) mostrando direcciones y números de puerto en formato numérico (`-n`).
* **python3 -m http.server <puerto>**: Levanta un servidor web HTTP temporal en el puerto indicado para realizar pruebas de escucha y conectividad.
* **nmap -F <host>**: Realiza un escaneo rápido de los puertos más comunes en un equipo destino para identificar si están abiertos (`open`), cerrados (`closed`) o filtrados (`filtered`).
* **curl -m <segundos> <url>**: Realiza una petición a un servidor estableciendo un tiempo máximo de espera (`-m`) para distinguir entre un bloqueo silencioso (`DROP` / tiempo agotado) y un rechazo inmediato (`REJECT`).
* **systemctl disable --now <servicio>**: Detiene un servicio de forma inmediata y lo deshabilita para que no vuelva a arrancar con el sistema (cerrar la puerta por dentro).
* **firewall-cmd --list-all**: Muestra toda la configuración activa de `firewalld` para la zona por defecto (interfaces, servicios y puertos permitidos).
* **firewall-cmd --add-rich-rule='rule family=ipv4 source address=<red> service name=ssh accept'**: Añade una regla enriquecida en `firewalld` para permitir un servicio únicamente desde una dirección o red de origen específica.
* **nft list tables**: Lista las tablas activas actualmente en el motor del cortafuegos `nftables`.
* **nft add rule inet filter input ip saddr <red> tcp dport <puerto> accept**: Añade directamente una regla en `nftables` para aceptar tráfico TCP hacia un puerto desde una IP o red determinada.
* **sudo nft delete table inet <tabla>**: Elimina una tabla completa de reglas en `nftables` para limpiar configuraciones temporales.
* **iptables -A INPUT -p tcp -s <red> --dport <puerto> -j ACCEPT**: Añade una regla al final de la cadena `INPUT` (sintaxis clásica traducida a `nftables`) para aceptar tráfico TCP desde un origen hacia un puerto destino.
* **iptables -P INPUT DROP**: Establece la política por defecto de la cadena de entrada en `DROP` (denegar todo lo que no coincida con una regla previa).
* **id [usuario]**: Muestra la identidad numérica del usuario actual o especificado: su UID, su grupo principal (GID) y los grupos secundarios a los que pertenece (como `wheel`).
* **getent passwd <usuario>**: Consulta la entrada de un usuario en la base de datos del sistema (`/etc/passwd`) mostrando su nombre, UID, GID, directorio personal y shell.
* **getent group wheel**: Lista los usuarios que pertenecen al grupo `wheel` (autorizados para usar `sudo`).
* **awk -F: '$3==0' /etc/passwd**: Filtra el archivo `/etc/passwd` usando `:` como delimitador para detectar todas las cuentas que tienen el UID `0` (llavero maestro).
* **ps -eo user,pid,comm**: Lista los procesos en ejecución mostrando el usuario dueño efectivo bajo el cual corre cada proceso, su PID y el comando.
* **ls -ln /etc/shadow**: Muestra los permisos y los propietarios en formato numérico (`-n`) del archivo que almacena los *hashes* de las contraseñas.
* **sudo -l**: Lista los comandos y privilegios que el usuario actual tiene autorizados ejecutar mediante `sudo` según `/etc/sudoers`.
* **sudo useradd <usuario>**: Crea una nueva cuenta de usuario en el sistema.
* **sudo userdel -r <usuario>**: Elimina una cuenta de usuario del sistema junto con su directorio personal y archivos asociados (`-r`).
* **journalctl -u sshd | grep Failed**: Consulta la bitácora del servicio SSH (`sshd`) y filtra los intentos de autenticación fallidos.
* **journalctl -t sudo -n <cantidad> --no-pager**: Muestra las últimas entradas registradas en la bitácora relacionadas con el uso de `sudo` (tanto préstamos concedidos como denegados).
* **sudo tail -n <lineas> /var/log/secure**: Muestra las últimas líneas del archivo de registro de seguridad y autenticación en sistemas basados en Red Hat/AlmaLinux.
* **getenforce**: Muestra el modo de operación actual de SELinux (*Enforcing*, *Permissive* o *Disabled*).
* **ls -Z**: Muestra el contexto y las etiquetas de seguridad de SELinux asociadas a los archivos o directorios.
* **ssh-keygen**: Genera un par de claves criptográficas (pública y privada) para autenticación sin contraseña mediante llaves SSH.