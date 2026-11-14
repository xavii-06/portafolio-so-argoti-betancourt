# Lista de Comandos básicos - Semana 4

## S.O. Windows con PowerShell
* **Get-Command <comando>**: Muestra el tipo (Alias, Cmdlet, Application) y la ruta de origen de un comando o programa.
* **(Get-Process -Id $PID).Modules**: Lista las bibliotecas compartidas (DLL) cargadas por el proceso actual de PowerShell.
* **Get-Process | Sort-Object WS -Descending | Select-Object -First 3 Name, Id, WS**: Obtiene los objetos de los procesos activos, los ordena numéricamente por uso de memoria (Working Set) de mayor a menor y selecciona los 3 primeros.
* **Get-Member**: Inspecciona y muestra las propiedades y métodos de los objetos que viajan a través de la tubería.
* **Get-ChildItem <ruta> -Recurse -File -ErrorAction SilentlyContinue**: Busca archivos de forma recursiva ignorando errores de acceso denegado en subcarpetas.
* **Set-ExecutionPolicy -Scope CurrentUser RemoteSigned**: Configura la política de seguridad para permitir la ejecución de scripts locales creados por el usuario actual.
* **$?**: Variable automática que devuelve `True` o `False` indicando si la última operación tuvo éxito o falló.
* **$LASTEXITCODE**: Almacena el código de salida numérico devuelto por el último programa externo o ejecutable basado en Win32.
* **$Error[0]**: Muestra el detalle del error más reciente registrado en la sesión de PowerShell.
* **winget source list**: Lista los repositorios o fuentes de software configurados en el gestor de paquetes de Windows.
* **winget search <paquete>**: Busca una aplicación disponible en los repositorios configurados.
* **winget show <id_paquete>**: Muestra la ficha técnica, versión, origen y huella SHA256 del instalador de un paquete.
* **winget install --id <id_paquete> -e**: Descarga, verifica la huella SHA256 e instala un paquete de forma exacta.
* **winget list**: Muestra el inventario de aplicaciones instaladas actualmente en el equipo.

## S.O. Linux con Bash
* **strace <comando>**: Intercepta y muestra en tiempo real todas las llamadas al sistema (syscalls), sus argumentos y valores de retorno que realiza un programa.
* **strace -e trace=openat,read,write,close <comando>**: Filtra la traza de ejecución para mostrar únicamente las llamadas al sistema especificadas.
* **strace -c <comando>**: Genera un resumen estadístico contando el total de llamadas por tipo, el tiempo consumido y los errores ocurridos.
* **ldd <ruta_binario>**: Muestra las bibliotecas compartidas (`.so`) de las que depende un programa ejecutable.
* **tty**: Imprime el nombre del archivo de terminal o pseudoterminal conectada a la entrada estándar.
* **ps -o comm= -p $PPID**: Muestra el nombre del proceso padre del shell actual.
* **dd if=<origen> of=<destino> bs=<bytes> count=<bloques>**: Copia bloques de datos permitiendo configurar el tamaño del búfer (`bs`) para medir el rendimiento de las llamadas al sistema.
* **time <comando>**: Mide el tiempo real, de usuario y de sistema (núcleo) que tarda en ejecutarse un comando.
* **echo $?**: Muestra el código de salida del último comando ejecutado (`0` indica éxito, cualquier otro valor indica error).
* **type <comando>**: Indica cómo interpreta el shell un comando (interno/builtin, alias o ruta de programa externo en disco).
* **ps -eo pid,comm,rss --sort=-rss | head -n 4**: Lista los procesos mostrando PID, nombre y memoria residente (RSS), ordenados de mayor a menor y filtrando las primeras líneas.
* **find <ruta> -type f -printf '%s %p\n' | sort -rn | head -n 5**: Busca archivos, imprime su tamaño en bytes junto a su ruta, los ordena numéricamente de forma inversa y muestra los 5 más grandes.
* **chmod +x <script.sh>**: Otorga permisos de ejecución a un archivo de script.
* **dnf repolist**: Muestra los repositorios de paquetes habilitados en el sistema (como `baseos`, `appstream` y `extras`).
* **dnf search <paquete>**: Busca paquetes disponibles en los metadatos de los repositorios.
* **dnf info <paquete>**: Muestra la descripción, versión, tamaño y repositorio de origen de un paquete.
* **sudo dnf install <paquete>**: Descarga, verifica la firma GPG, resuelve dependencias e instala un paquete en el sistema.
* **dnf history**: Muestra el historial de transacciones (instalaciones, actualizaciones y eliminaciones) realizadas con `dnf`.
* **rpm -qa**: Lista todos los paquetes `.rpm` instalados actualmente en la base de datos local del sistema.
* **rpm -qi <paquete>**: Consulta la información detallada y metadatos de un paquete ya instalado.
* **rpm -qR <paquete>**: Lista las dependencias (bibliotecas y otros paquetes) que requiere un paquete instalado para funcionar.