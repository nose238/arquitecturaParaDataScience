FROM ubuntu
# Se posiciona en la carpeta: (como comando cd)
WORKDIR /home/app

RUN apt update -y
# Fija una zona horaria para que la instalacion de R no arroje un prompt
ENV TZ=America/Mexico_City
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# Instalacion  de utilidades y dependencias varias
RUN apt install r-base -y
ARG DEBIAN_FRONTEND=noninteractive
RUN apt install nano -y
RUN apt install libpq-dev python-dev libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev libffi-dev -y
RUN apt install cpulimit -y
RUN apt install openssh-server -y
RUN apt install libcurl4-openssl-dev -y
# Prmite conexiones SSH
RUN echo  "PermitRootLogin yes" >> /etc/ssh/sshd_config
RUN /etc/init.d/ssh start
# Quiza se deba cambiar por java 8 para aumentar compatibilidad con hadoop
RUN apt-get install openjdk-11-jdk -y
# Python y jupyter
RUN apt install python3 python3-pip -y
RUN pip3 install jupyterhub jupyter jupyterlab
RUN pip3 install pandas numpy scikit-learn
# PYTHON HIVE
RUN pip3 install sasl
RUN pip3 install thrift
RUN pip3 install thrift-sasl
RUN pip3 install PyHive 
#Python spark
RUN pip3 install livy
# Sistema de monitoreo de jupyter
RUN pip3 install jupyter-resource-usage jupyterlab-topbar jupyterlab-system-monitor
# NodeJS
RUN apt install nodejs -y
RUN apt install npm -y
RUN npm install -g configurable-http-proxy
# JULIA
RUN apt install julia -y
# Congiguracino de jupyterhub
# Genera directorio y guarda configuracinoes ahi
RUN mkdir -p /etc/jupyterhub/
COPY ./jupyterhub_config.py /etc/jupyterhub/
# Creando certificado para https
RUN openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -keyout jh.key -out jh.crt -subj "/C=MX/ST=CDMX/L=Tlalpan/O=BAZ/OU=BAZ/CN=BAZ"
### Configuraciones de R
RUN R CMD javareconf
COPY ./execHiveQuery.R .
COPY ./rjupyter.r .
RUN mkdir bazR
RUN mkdir /BAZjars/
COPY ./hive-jdbc-3.1.2-standalone.jar /BAZjars/
COPY ./hadoop-common-3.3.1.jar /BAZjars/
RUN Rscript rjupyter.r
# Modificacinoes visuales a jupyter
COPY ./jupyterhub_config.py .
COPY ./monitor.py .
COPY ./adduser.sh .
COPY ./start_container_processes.sh .
COPY ./style.min.css /usr/local/share/jupyterhub/static/css/
COPY ./login.html /usr/local/share/jupyterhub/templates/
COPY ./page.html /usr/local/share/jupyterhub/templates/

# Arranca el servidor jupyterhub
RUN systemctl enable ssh
CMD bash start_container_processes.sh


# Desactivar downloaad de jupyter. https://github.com/jupyterlab/jupyterlab/issues/5274
# Cambiar en ruta: /usr/local/share/jupyter/labextensions/@jupyter-server/resource-usage/package.json
# del contenedor correspondiente