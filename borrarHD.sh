#!/bin/bash

#Constatntes
HORA_SEG=3600 # 1 hora en segundos
SEG_WAIT=2  # Tiempo de espera en el bucle, se usa para calcular las horas
EN_EJECUCION=2 # Valor que se le asigna si el proceso esta en ejecucion
PASADAS_SEGURAS=7 # Numero de pasadas para asegurar que no se puede recuperar informacion
# Fichero que muestra la informacion de como va todo
fichero=infoBorrado.txt

# Variable con la ruta del HD a borrar
rutaHD=$1

if [[ -z ${rutaHD} ]];   # Comprobamos si el parametro viene vacio
then
    echo "++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "+++              Sin parametros              +++"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++"
    echo " "
    echo "Por favor indique la ruta donde esta el disco que se desea limpiar"
else
    # Comprobaciones [VERSION BONITA]
    echo -ne 'Comprobando ..      \r'
    sleep 1
    echo -ne 'Comprobando ...     \r'
    sleep 1
    echo -ne 'Comprobando ....    \r'
    sleep 1
    echo -ne 'Comprobando .....   \r'
    sleep 1

    isMounted=`mount | grep ${rutaHD}`
    # Comprueba que no esta montada la ruta a borrar
    if [ -n "$isMounted" ] ; then
        # La unidad esta montada y hay que desmontarla
        echo "Comprobaciones fallidas";
        echo "Por favor, desmonte la unidad ${rutaHD} antes de empezar a borrar";
        exit;
    else
        # La unidad esta desmontada y se va a proceder a borrar
        echo "Comprobaciones correctas";
        echo "Se procede a borrar ${rutaHD}";
    fi

    echo "--------       Borrado del HD ${rutaHD}       --------" >> ${fichero}
    for n in `seq ${PASADAS_SEGURAS}`;
    do
        let inicio=`date +%s`
        trap 'kill $pid; exit' INT # Captura la señal y mata el proceso en segundo plano
        ## dd if=/dev/urandom of=${rutaHD} bs=8b conv=notrunc &
        dd if=/dev/urandom of=${rutaHD} bs=1024 conv=notrunc &
        pid=$!
        RUNNING=$(ps -p ${pid} | wc -l) # '2' el proceso esta corriendo. '1' el proceso finalizado
        # Muestra la informacion del proceso
        echo "Borrando........"
        echo "*** Inicio: ${inicio} ***" >> ${fichero} # Se indica la hora de inicio, para mayor exactitud
        echo -e "PID dd => ${pid} \nEjecucion => ${RUNNING}"
        echo -e "** El PID(dd): ${pid}, usar 'kill -SIGUSR1 ${pid}' para informacion en tiempo real **\n" >> ${fichero}
        horas=0     # Variable que marca las horas transcurridas
        tiempo=0    #Variable que marca el tiempo transcurrido
        while [ ${RUNNING} -ge ${EN_EJECUCION} ]; 
        do
            kill -SIGUSR1 ${pid} # MAnda señal al proceso dd, para ver informacion de como va
            sleep 2
            
            # Vuelca la ultima hora de refresco en el fichero
            sed -i '$d' "$fichero"   # Borra la ultima linea del fichero
            echo -n "<> `date +"%m/%d/%Y %H:%M:%S"`" >> ${fichero}
            # Incrementa el contador
            tiempo=$((tiempo + SEG_WAIT)) 

            # Comprueba si el proceso, dd, sigue en ejecucion
            RUNNING=$(ps -p ${pid} | wc -l) 

            # Comprueba si lleva una hora de ejecucion
            if [[ ${tiempo} -ge ${HORA_SEG} ]];
            then
                horas=$((horas + 1)) # Incrementa el contador de horas en una
                echo -e "\n-> Lleva ${horas} horas de borrado\n" >> ${fichero}
                tiempo=0
            fi 
        done
    
        let fin=`date +%s`
        let total=$fin-$inicio
        
        ## Mostra inforacion del resultado de la it. bucle
        echo "********************************************"
        echo "*** Borrado ${n}º, tiempo: ${total} segundos"
        echo "********************************************"

        ## Guarda la informacion del borrado en un fichero 
        echo -e "\n********************************************" >> ${fichero}
        echo "*** Borrado ${n}º, tiempo: ${total} segundos" >> ${fichero}
        echo "********************************************" >> ${fichero}
    done
        echo "---------------------------------------------------" >> ${fichero}
fi
        
    #### Progres bar
        echo -ne '|   \r'
        sleep 1
        echo -ne '/   \r'
        sleep 1
        echo -ne '-   \r'
        sleep 1
        echo -ne '\   \r'
        sleep 1
        echo -ne '☻   \n'
    ##### Progres bar
    