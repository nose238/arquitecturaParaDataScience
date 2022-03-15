if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
    echo "Usage:"
    echo "    bash agguser.sh user passwd ramLimit(units in G) cpuLimit(percentage 1-100)"
    echo "Example:"
    echo "    Add user 'eduardo' with password 'root' ram limited '2G' max and '30' % of CPU"
    echo "    bash agguser.sh eduardo root 2G 30" 
else
    # Variables
    username=$1
    password=$2
    ramLimit=$3 # Por ahora solo funciona con unidades en G
    cpuLimit=$4
    # Cambiar a cantidad de procesadores que tiene el host
    noProcesadores=16
    # Agrega usuario
    adduser --gecos "" --disabled-password $username
    if [ $? -eq 0 ]; then
        echo "User OK"
    else
        echo "User creation failed."
        exit 1
    fi
    chpasswd <<<"$username:$password"
    # Agrega confi a archivo users.conf
    echo "$username|$ramLimit|$cpuLimit" >> users.conf
    # Configuraciones de jupyter notebook
    touch /home/$username/jupyter_notebook_config.py
    echo "# IMPORTANTE. Este archivo de configuraciones afecta solo a la visualización de tus recursos, no a los recursos que realmente se te asignan. NO LO MODIFIQUES" >> /home/$username/jupyter_notebook_config.py
    echo "c.ResourceUseDisplay.mem_limit = ${ramLimit::-1} *1024*1024*1024" >> /home/$username/jupyter_notebook_config.py
    echo "c.ResourceUseDisplay.track_cpu_percent = True" >> /home/$username/jupyter_notebook_config.py
    echo "c.ResourceUseDisplay.cpu_limit = $noProcesadores" >> /home/$username/jupyter_notebook_config.py
    chattr +i /home/$username/jupyter_notebook_config.py # Hacer un archivo inmutable
    if [ $? -eq 0 ]; then
        echo "User Ready to use!"
    else
        echo "User Ready to use. "
        echo "!!!!!!!!!!!WARINING!!!!!!!!!!! This user can modify or delete jupyter_notebook_config.py"
    fi
    # Quitar lo comentado para Instalar Julia a este usuario
    echo "Please wait... Julia instalation starts..."
    echo "Instalation in background..."
    su - $username -c "julia -e 'using Pkg; Pkg.add(\"IJulia\")'"
    
fi