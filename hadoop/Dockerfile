# Dockerfile de la imagen de centos con configuraciones iniciales de hadoop
FROM centos:centos7

# ============================================
# Instalar utilidades varias necesarias
# ============================================
RUN yum update -y
RUN yum update -y && yum -y install openssh openssh-server openssh-clients sudo initscripts
RUN yum install java-1.8.0-openjdk-devel -y
RUN yum install sshpass -y 
RUN yum install python3 -y
RUN yum install unzip -y

# ============================================
# Hadoop
# ============================================
RUN adduser hadoop -m -s /bin/bash
RUN (echo hadoopTmpPasswd; echo hadoopTmpPasswd) | passwd hadoop
RUN mkdir -p /data
RUN mkdir -p /data/datanode/
RUN mkdir /opt/hadoop
COPY ./hadoop-3.3.1.tar.gz /

RUN chown hadoop -R /data/datanode/
RUN chown hadoop -R /data/
RUN chown hadoop -R /opt/hadoop
RUN chown hadoop ./hadoop-3.3.1.tar.gz
RUN tar -zxvf hadoop-3.3.1.tar.gz -C /opt/hadoop  --strip-components=1
RUN rm -rf ./hadoop-3.3.1.tar.gz

# Archivos de configuracion de hadoop
COPY ./core-site.xml /opt/hadoop/etc/hadoop/
COPY ./yarn-site.xml /opt/hadoop/etc/hadoop/
COPY ./workers /opt/hadoop/etc/hadoop/
RUN sed -i 's/\r$//' /opt/hadoop/etc/hadoop/workers
COPY ./hdfs-site.xml /opt/hadoop/etc/hadoop/
COPY ./mapred-site.xml /opt/hadoop/etc/hadoop/
COPY ./capacity-scheduler.xml /opt/hadoop/etc/hadoop/
RUN chown hadoop -R /opt/hadoop/etc/hadoop/
# Variables de entorno HADOOP
RUN echo 'export HADOOP_HOME=/opt/hadoop' >> /home/hadoop/.bashrc
#RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.312.b07-1.el7_9.x86_64/' >> /home/hadoop/.bashrc
RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0/' >> /home/hadoop/.bashrc
RUN echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' >> /home/hadoop/.bashrc

# ============================================
# Hive
# ============================================
RUN mkdir /opt/hadoop/hive
COPY ./apache-hive-3.1.2-bin.tar.gz ./
RUN chown hadoop -R /opt/hadoop/hive
RUN chown hadoop apache-hive-3.1.2-bin.tar.gz
RUN tar -zxvf apache-hive-3.1.2-bin.tar.gz -C /opt/hadoop/hive  --strip-components=1
RUN rm -rf apache-hive-3.1.2-bin.tar.gz
# Se eliminan para no tener problemas con la integracion a hadoop
RUN rm -rf /opt/hadoop/hive/lib/hive-jdbc-2.0.0-standalone.jar
RUN rm -rf /opt/hadoop/hive/lib/log4j-slf4j-*
COPY ./mysql-connector-java-8.0.15.jar /opt/hadoop/hive/lib/
RUN chown hadoop /opt/hadoop/hive/lib/mysql-connector-java-8.0.15.jar
COPY ./hive-site.xml /opt/hadoop/hive/conf
# Variables de entorno Hive
RUN echo 'export HIVE_HOME=/opt/hadoop/hive' >> /home/hadoop/.bashrc
RUN echo 'export PATH=$PATH:$HIVE_HOME/bin' >> /home/hadoop/.bashrc
RUN echo 'export HADOOP_CLIENT_OPTS=" -Xmx256000m"' >> /home/hadoop/.bashrc

# ============================================
# Spark
# ============================================
RUN mkdir /opt/hadoop/spark
COPY ./spark-2.1.0-bin-without-hadoop.tgz ./
RUN chown hadoop -R /opt/hadoop/spark
RUN chown hadoop spark-2.1.0-bin-without-hadoop.tgz
RUN tar -xvf spark-2.1.0-bin-without-hadoop.tgz -C /opt/hadoop/spark/  --strip-components=1
# Variables de entorno
RUN echo 'export SPARK_HOME=$HADOOP_HOME/spark' >> /home/hadoop/.bashrc
RUN echo 'export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin' >> /home/hadoop/.bashrc
RUN echo 'export SPARK_DIST_CLASSPATH=$(hadoop classpath)' >> /home/hadoop/.bashrc
RUN echo 'export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop' >> /home/hadoop/.bashrc
RUN echo 'export PYTHONPATH=$SPARK_HOME/python/lib/py4j-0.10.4-src.zip:$SPARK_HOME/python:/:/usr/lib64/python2.7.zip:/usr/lib64/python2.7:/usr/lib64/python2.7/lib-dynload:/usr/local/lib/python2.7/site-packages:/usr/lib64/python2.7/site-packages:/usr/lib/python2.7/site-packages' >> /home/hadoop/.bashrc
RUN echo 'export PYSPARK_PYTHON=/usr/bin/python2' >> /home/hadoop/.bashrc
RUN echo 'export PYSPARK_DRIVER_PYTHON=/usr/bin/python2' >> /home/hadoop/.bashrc
# Configuracion de spark-env
RUN chown hadoop -R /opt/hadoop/spark/
RUN cp /opt/hadoop/spark/conf/spark-env.sh.template /opt/hadoop/spark/conf/spark-env.sh
RUN echo 'export SPARK_DIST_CLASSPATH=$(hadoop classpath)' >> /opt/hadoop/spark/conf/spark-env.sh

# ============================================
# Apache Livy (REST para Spark)
# ============================================
COPY ./livy-0.4.0-incubating-bin.zip ./
RUN mkdir /opt/hadoop/livy/
RUN chown hadoop ./livy-0.4.0-incubating-bin.zip
RUN chown hadoop /opt/hadoop/livy/
RUN unzip -d /home/hadoop/dirtmp/ livy-0.4.0-incubating-bin.zip
RUN mv /home/hadoop/dirtmp/livy-0.4.0-incubating-bin/* /opt/hadoop/livy/
RUN rm -rf /home/hadoop/dirtmp/
RUN rm -rf ./livy-0.4.0-incubating-bin.zip

# ============================================
# Permite activar SSH
RUN ssh-keygen -A
RUN ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
EXPOSE 22
# ============================================

# Script de arranque del cluster
COPY ./cluster_start.sh /
RUN sed -i 's/\r$//' cluster_start.sh
CMD bash cluster_start.sh
