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

# Copiar el paquete al contenedor
COPY DBI_1.2.3.tar.gz /tmp/DBI_1.2.3.tar.gz
COPY ROracle_1.3-1.1.tar.gz /tmp/ROracle_1.3-1.1.tar.gz

# Instalar DBI (en línea separada para asegurar que se instale)
# Instalar el paquete sin usar internet
RUN R CMD INSTALL /tmp/DBI_1.2.3.tar.gz && \
    R -e "stopifnot('DBI' %in% rownames(installed.packages()))"

# Instalar ROracle (fuente + Oracle path)
ENV R_MAKEVARS_SITE=/etc/R/Makevars
RUN echo "CFLAGS=-Wno-error=format-security" >> /etc/R/Makevars && \
    echo "CXXFLAGS=-Wno-error=format-security" >> /etc/R/Makevars

# Instalar ROracle offline usando rutas del Oracle Instant Client
RUN R CMD INSTALL /tmp/ROracle_1.3-1.1.tar.gz \
    --configure-args="--with-oci-lib=/opt/oracle/instantclient --with-oci-inc=/opt/oracle/instantclient/sdk/include" && \
    R -e "stopifnot('ROracle' %in% rownames(installed.packages()))"

# Puerto de RStudio
EXPOSE 8787
CMD ["/init"]
