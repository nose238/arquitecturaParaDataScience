python3 monitor.py &
service ssh start
jupyterhub -f /etc/jupyterhub/jupyterhub_config.py --ssl-key jh.key --ssl-cert jh.crt