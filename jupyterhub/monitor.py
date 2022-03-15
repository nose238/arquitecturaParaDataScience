import os
import re
import threading
import time
import datetime

# Instalar cpulimit en ditro de linux antes de ejecutar este 
"""
    Falta agregar:
        * Validar nombres de usuarios y memoria
        * Agregarlo a un hilo
"""
currentPIDs = []

# PATHS
basepath = r"/home/app/"
confFilepath = basepath + r"users.conf" # usuarios y limites correspondientes.
logfile = basepath + r"mataproceso.log" 

def inspectMemoryByUser():
    # Si el archivo users.conf no existe, lo crea con los comentarios iniciales.
    if not os.path.exists(confFilepath):
        command = "touch "+ confFilepath 
        os.system(command)
        os.system("echo '# user|ram limit (KB)|cpu (percent 1 - 100)' >> " + confFilepath)
        os.system("echo '# Examples: ' >> " + confFilepath)
        os.system("echo '# lalo|1G|20' >> " + confFilepath)
        os.system("echo '# brian|500M|20' >> " + confFilepath)
        os.system("echo '# esteban|50000000|cpu' >> " + confFilepath)
        # print("users.conf did not exist. One has been created")
    with open(confFilepath) as users:
        for line in users:
            if line.strip() != "" and line.strip()[0] != "#":
                user = line.split("|")[0].strip()
                ramLimit = line.split("|")[1].strip()
                # Convierte unidades en KB
                if ramLimit[-1].upper() == "G":
                    ramLimit = float(ramLimit[0:-1]) * 1024 * 1024
                elif ramLimit[-1].upper() == "M":
                    ramLimit = float(ramLimit[0:-1]) * 1024
                cpuLimit = line.split("|")[2].strip()
                list_of_ps = basepath+"ps_"+user+"_ram.tmp"
                command = "top -b -n 1 -o VIRT -u "+user+" | tail -n +8  >" +list_of_ps
                os.system(command)
                with open(list_of_ps) as procss:
                    for ps in procss:
                        ram_exceeded_flag = 0
                        PID = re.sub("\s\s+" , " ", ps).strip().split(" ")[0]
                        # VIRT = re.sub("\s\s+" , " ", ps).strip().split(" ")[4] # Toda la memoria
                        RES = re.sub("\s\s+" , " ", ps).strip().split(" ")[5] # Solo RAM
                        CPU_perc = re.sub("\s\s+" , " ", ps).strip().split(" ")[8] # Porcentaje CPU
                        if PID not in currentPIDs:
                            currentPIDs.append(PID)
                            command = "cpulimit -qzp "+ PID + " -l " + str(cpuLimit)
                            os.system(command)
                        COMMAND = re.sub("\s\s+" , " ", ps).strip().split(" ")[11]
                        # Convierte RES en las mismas unidades con las que se va a comparar (KB)
                        if RES[-1] == "g":
                            RES = float(RES[0:-1]) * 1024 * 1024
                        elif RES[-1] == "m":
                            RES = float(RES[0:-1]) * 1024
                        if float(RES) > float(ramLimit): # Mata el proceso si excede el limite de memoria RAM por usuario
                            command = "kill "+ PID
                            os.system(command)
                            ram_exceeded_flag = 1
                        if not os.path.exists(logfile):
                            command = "touch "+ logfile 
                            os.system(command)
                        if os.stat(logfile).st_size == 0:
                            with open(logfile, "w") as log:
                                log.write("dateTime|user|ramLimit|ramByProccess|ram_exceeded_flag|CPU_percent_limit|CPU_percent|PID|command\n")
                        with open(logfile, "a") as log:
                            log.write(str(datetime.datetime.now()) + "|" + user + "|"+ str(ramLimit).strip() + "|" 
                            + str(RES).strip() + "|" + str(ram_exceeded_flag) + "|"+ str(cpuLimit) + "|" + str(CPU_perc) 
                            + "|" +PID + "|" + COMMAND + "\n")
                command = "rm -f "+list_of_ps # Elimina el archivo temporal generado anteriormente.
                os.system(command)

# print("Inicia monitoreo: " + str(datetime.datetime.now()))
while True:
    thread_kill_process_by_memory = threading.Thread(target=inspectMemoryByUser)
    thread_kill_process_by_memory.start()
    time.sleep(5)
