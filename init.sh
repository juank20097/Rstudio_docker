#!/bin/bash

# Crea los usuarios
useradd -m -s /bin/bash user1
useradd -m -s /bin/bash user2

# Establece las contraseñas
echo "user1:password1" | chpasswd
echo "user2:password2" | chpasswd

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
