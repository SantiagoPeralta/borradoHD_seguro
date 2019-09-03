# Borrado Hard Disk seguro
Borrado de un Disco Duro de forma segura. Borrado con 7 pasadas para evitar que se puedan recuperar datos

### Instrucciones
El script funciona solo para Linux, y tiene 2 comprobaciones. La primera es que recibe por parámetros la ruta a borrar, 
mientras que la segunda comprobación es para verificar que no esta montado el Disco Duro.

### Comportamiento
El Script ejecuta el comando "dd" en segundo plano. Y cada 2 segundo enviá una señal "kill -SIGUSR1" al PID del proceso 
"dd". Mientras vuelca los tiempos que han transcurrido desde el inicio de la ejecución del "dd". Esto va a suceder hasta
 que finalice el proceso "dd", para el cual se comprueba el estado del proceso. 

### Ejecución
Para la ejecución simplemente hay que ejecutar el script con permisos de "sudo" y pasandole por parámetros la ruta 
donde esta el HD a borrar.
Este script realiza las comprobaciones correspondientes y si todo es correcto se ejecutara.
Mientras se ejecuta vuelca el tiempo en un fichero auxiliar para mostrar los tiempos y marca cada hora pasada desde su 
ejecución. En paralelo manda señales para mostrar información del borrado.
