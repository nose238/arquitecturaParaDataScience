# Inicia SSH
/usr/sbin/sshd -D & 

# Verifica si se creo una llave previamente (solo debe pasar la primera vez que se enciende el contenedor)
SSH_KEY_FILE=/home/hadoop/.ssh/id_rsa.pub
if [ -f "$SSH_KEY_FILE" ]; 
then
    echo "Las llaves ya habian sido generadas"
    if [[ $(hostname) == namenode ]]
    then
        # Arranca cluster
        #######################
        # La primera vez que esto se corrio se ejecutaron los comandos comentados
        #####################
        # ***** Buscar como hacer que este comando se ejecute solo una vez, si no esta formateado.
        #chown hadoop -R /data/
        #su - hadoop -c "hdfs namenode -format" 
        su - hadoop -c "start-dfs.sh"
        su - hadoop -c "start-yarn.sh"
        #su - hadoop -c "hdfs dfs -mkdir -p /user/hive/warehouse"
        #su - hadoop -c "hdfs dfs -mkdir -p /tmp"

        #Arranca servicio de livy (para spark desde hue)
        su - hadoop -c "/opt/hadoop/livy/bin/livy-server start"
        echo "Listo para arrancar el cluster."
    else
        if [[ $(hostname) =~ hiveServer ]]
        then
            # Arranca cluster
            #######################
            # La primera vez que esto se corrio se ejecutaron los comandos comentados
            #####################
            # ***** Buscar como hacer que este comando se ejecute solo una vez, si no esta formateado.
            #su - hadoop -c "schematool -dbType mysql --initSchema"
            su - hadoop -c "hiveserver2"
            echo "Listo para arrancar hive."
        fi
        trap : TERM INT; sleep infinity & wait
    fi
else
    su - hadoop -c "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa"
    if [[ $(hostname) == namenode ]]
    then 
        #################################################################################################
        #                                                                                               #
        #                              SECCION DE INTERCAMBIO DE LLAVES SSH                             #
        #                                                                                               #
        #################################################################################################
        # Quitar los comentarios de los sshpass si se quiere agregar un 2do servidor hive o un 2do datanode según corresponda.
        # Creando las llaves en namenode
        sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@namenode
        sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode
        sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@hiveServer
        # sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@hiveServer2
        sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode2
        sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode3
        sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode4

        ####################### Empieza seccion de datanodes #################
        # Creando las llaves en datanode
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@namenode 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@namenode'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@namenode 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@namenode 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@hiveServer'
        #sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@namenode 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@hiveServer2'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@namenode 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode2'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@namenode 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode3'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@namenode 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode4'

        # Creando las llaves en datanode2
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode2 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@namenode'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode2 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode2 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@hiveServer'
        #sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode2 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@hiveServer2'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode2 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode2'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode2 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode3'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode2 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode4'

        # Creando las llaves en datanode3
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode3 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@namenode'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode3 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode3 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@hiveServer'
        #sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode3 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@hiveServer2'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode3 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode2'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode3 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode3'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode3 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode4'

        # Creando las llaves en datanode4
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode4 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@namenode'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode4 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode4 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@hiveServer'
        #sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode4 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@hiveServer2'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode4 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode2'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode4 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode3'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@datanode4 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode4'

        
        ####################### Empieza seccion de datanodes #################

        # Creando las llaves en HiveServer
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@hiveServer 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@namenode'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@hiveServer 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@hiveServer 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@hiveServer'
        #sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@hiveServer 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@hiveServer2'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@hiveServer 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode2'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@hiveServer 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode3'
        sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@hiveServer 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode4'

        # Creando las llaves en HiveServer2
        #sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@hiveServer2 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@namenode'
        #sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@hiveServer2 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@datanode'
        #sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@hiveServer2 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@hiveServer'
        #sshpass -p "hadoopTmpPasswd" ssh -o StrictHostKeyChecking=no hadoop@hiveServer2 'sshpass -p "hadoopTmpPasswd" ssh-copy-id -o StrictHostKeyChecking=no hadoop@hiveServer2'


        # Arranca cluster
        #######################
        # La primera vez que esto se corrio se ejecutaron los comandos comentados
        #####################
        # ***** Buscar como hacer que este comando se ejecute solo una vez, si no esta formateado.
        #chown hadoop -R /data/
        #su - hadoop -c "hdfs namenode -format" 
        su - hadoop -c "start-dfs.sh"
        su - hadoop -c "start-yarn.sh"
        #su - hadoop -c "hdfs dfs -mkdir -p /user/hive/warehouse"
        #su - hadoop -c "hdfs dfs -mkdir -p /tmp"

        #Arranca servicio de livy (para spark desde hue)
        su - hadoop -c "/opt/hadoop/livy/bin/livy-server start"
        echo "Listo para arrancar el cluster."
    else
        if [[ $(hostname) =~ hiveServer ]]
        then
            # Arranca cluster
            #######################
            # La primera vez que esto se corrio se ejecutaron los comandos comentados
            #####################
            # ***** Buscar como hacer que este comando se ejecute solo una vez, si no esta formateado.
            #su - hadoop -c "schematool -dbType mysql --initSchema"
            su - hadoop -c "hiveserver2"
            echo "Listo para arrancar hive."
        fi
        trap : TERM INT; sleep infinity & wait
    fi
fi
trap : TERM INT; sleep infinity & wait