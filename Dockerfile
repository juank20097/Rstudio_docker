# Imagen base
FROM rocker/rstudio:4.4.1

# Zona horaria y root
ENV TZ=America/Guayaquil
USER root

# Instala dependencias del sistema
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libaio1 \
    unzip \
    curl \
    r-base-dev \
    unixodbc-dev \
    build-essential \
    libpq-dev

# Oracle Instant Client
WORKDIR /opt/oracle
COPY instantclient-basiclite-linux.x64-23.7.0.25.01.zip /opt/oracle/
COPY instantclient-sdk-linux.x64-23.7.0.25.01.zip /opt/oracle/

RUN unzip /opt/oracle/instantclient-basiclite-linux.x64-23.7.0.25.01.zip -d /opt/oracle && \
    unzip -o /opt/oracle/instantclient-sdk-linux.x64-23.7.0.25.01.zip -d /opt/oracle && \
    ln -s /opt/oracle/instantclient_* /opt/oracle/instantclient && \
    echo "/opt/oracle/instantclient" > /etc/ld.so.conf.d/oracle-instantclient.conf && \
    ldconfig

# Variables de entorno
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient
ENV OCI_LIB=/opt/oracle/instantclient
ENV OCI_INC=/opt/oracle/instantclient/sdk/include

# Instalar DBI (en línea separada para asegurar que se instale)
RUN R -e "install.packages('DBI', repos='https://cloud.r-project.org')" && \
    R -e "stopifnot('DBI' %in% rownames(installed.packages()))"

# Instalar ROracle (fuente + Oracle path)
RUN R -e "install.packages('ROracle', repos='https://cloud.r-project.org', type='source', configure.args='--with-oci-lib=/opt/oracle/instantclient --with-oci-inc=/opt/oracle/instantclient/sdk/include')"

# Puerto de RStudio
EXPOSE 8787
CMD ["/init"]
