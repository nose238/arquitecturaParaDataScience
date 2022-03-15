 ##############################################################################
# Contacto:                                                                   #
#    - Esteban Eduardo Márquez Fuentes                                        #
#    - esteban.marquez.fuentes@gmail.com                                      #
###############################################################################

Estos archivos contienen todo lo necesario para crear el ambiente de laboratorio de CYC, incluyendo
el ecosistema de hadoop, el laboratorio de jupyter, hue y las bases de datos necesarias.

Está dividido en las carpetas hadoop, jupyter, documentación y el docker-compose.yml:
....................................................................................................... 
    Documentación: Contiene los archivos explicativos de lo desarrollado
        - Entorno completo v1: Guía con los pasos para la creación de todo el entorno
        - Entorno Hadoop: Todos los detalles del ecosistema hadoop
        - Entorno Jupyter: Todos los detalles del ecosistema jupyter
        - Cambios frecuentes: Los cambios que más probablemente se tenvan que hacer
        - Agregar librería..: Como poner internet para descargar una librería al
                contenedor de deep dive y luego quitarlo
        - Ambiente del no..: Presentación gráfica de lo que contienen los ecosistemas
....................................................................................................... 
    Hadoop: Todos los archivos necesarios para la construcción del ecosistema de hadoop
        - Ejemplos para agr..: Archivos modificados como ejemplo, en caso de querer agregar 
                un nuevo datanode (ver documentación de cambios frecuentes para más info)
        - Descargas externas: 
            - apache-hive-3.1.2-bin.tar: https://downloads.apache.org/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz
            - hadoop-3.3.1.tar: https://archive.apache.org/dist/hadoop/common/hadoop-3.3.1/hadoop-3.3.1.tar.gz
            - livy-0.4.0-incubating-bin: https://downloads.apache.org/incubator/livy/0.4.0-incubating/livy-0.4.0-incubating-bin.zip
            - mysql-connector-java-8.0.15: https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.15/mysql-connector-java-8.0.15.jar
            - spark-2.1.0-bin-without-hadoop: https://archive.apache.org/dist/spark/spark-2.1.0/spark-2.1.0-bin-without-hadoop.tgz
        - Archivos que se pueden extraer de rutas específicas dentro del ecosistema:
            - Contenedores hadoop
                - capacity-scheduler: /opt/hadoop/etc/hadoop/
                - core-site: /opt/hadoop/etc/hadoop/
                - hdfs-site: /opt/hadoop/etc/hadoop/
                - hive-site: /opt/hadoop/hive/conf
                - mapred-site: /opt/hadoop/etc/hadoop/
                - yarn-site: /opt/hadoop/etc/hadoop/
                - workers: /opt/hadoop/etc/hadoop/
            - Contenedor de Hue
                - hue: /usr/share/hue/desktop/conf/
            - Archivos y scripts desarrollados
                - cluster_start: Inicia los servicios del cluster
                - Dockerfile: Se especifican los detalles de construcción de la imagen
....................................................................................................... 
    Jupyter: Todos los archivos necesarios para la construcción del ecosistema de jupyter
        - Descargas externas: 
            - bazteca: Imagen de bazteca (se puede sustituir sin problema por cualquier en una URL, 
                    no se copian a la imagen, solo están porque fueron utilizadas en formato de base64)
            - jupyter: Imagen de jupyter (se puede sustituir sin problema por cualquier en una URL, 
                    no se copian a la imagen, solo están porque fueron utilizadas en formato de base64)
        - Archivos que se pueden extraer de rutas específicas dentro del ecosistema:
            - jupyter_notebook_config.py: no se copia, pero sirvió de plantilla, se escribe lo equivalente 
                    en el script adduser.sh
            - jupyterhub_config.py: /etc/jupyterhub/
            - login: /usr/local/share/jupyterhub/templates/
            - page: /usr/local/share/jupyterhub/templates/
            - style.min: /usr/local/share/jupyterhub/static/css/
        - Archivos y scripts desarrollados:
            - adduser: Agrega usuarios y configura los límites de memoria y cpu
            - Dockerfile: Se especifican los detalles de construcción de la imagen
            - execHiveQuery.R: Librería propia. Ayuda a conectar jupyter al ecosistema de hadoop
            - monitor.py: Monitorea los recuersos por usuario (cpu y ram)
            - rjupyter.r: Instala las librerías que se especifican para R
            - start_container_processes: Inicia los servicios de jupyter con https
            - users.conf: Contiene las configuraciones de los límites de los recursos por usuario
....................................................................................................... 
    docker-compose.yml: Especifica las características con las que se iniciarán los contenedores:
        - del ecosistema hadoop: 
            - namenode: master de hadoop
            - datanode: worker de hadoop
            - datanode2: worker de hadoop
            - datanode3: worker de hadoop
            - hiveServer: Servidor de hive2
        - del ecosistema jupyter:
            - jupyterlab: laboratorio
        - imagenes externas:
            - mysql-general: base de datos mysql de uso general
            - metastore: base de datos mysql para metastore
            - hue: Servidor de hue