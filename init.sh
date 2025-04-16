#!/bin/bash

# Crea los usuarios
useradd -m -s /bin/bash oscar.carate
useradd -m -s /bin/bash wilson.arroyo
useradd -m -s /bin/bash rolando.mantilla
useradd -m -s /bin/bash danilo.criollo

# Establece las contraseñas
echo "oscar.carate:XD7GqYDyIubdQjW" | chpasswd
echo "wilson.arroyo:i53QuSLvaj6OlBb" | chpasswd
echo "rolando.mantilla:kY9THFEmDR6XIwU" | chpasswd
echo "danilo.criollo:SErvUr0d7eusZlh" | chpasswd

# Inicia RStudio Server
/usr/lib/rstudio-server/bin/rserver --server-daemonize 0

# Actualizar e instalar las dependencias necesarias
apt-get update && apt-get install -y --no-install-recommends \
    libaio1 \
    curl \
    build-essential \
    unixodbc-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Iniciar RStudio Server
exec /init
