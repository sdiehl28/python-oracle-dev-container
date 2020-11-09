# ubuntu images on Docker Hub are minimal
# https://wiki.ubuntu.com/Minimal
FROM ubuntu:latest

LABEL version="0.94"

# install tools
RUN apt update && apt install -y --no-install-recommends \
    sudo \
    vim \
    nano \
    unzip \
    wget \   
    python3 \
    python3-venv \
    libaio1 \
    && rm -rf /var/lib/apt/lists/*

# create user: dev
RUN useradd --create-home --shell /bin/bash -G sudo dev \
    && echo 'dev:dev' | chpasswd \
    && mkdir -p /opt/oracle \
    && mkdir -p /home/dev/projects/cx_oracle

# install oracle instant client
WORKDIR /opt/oracle    
RUN wget https://download.oracle.com/otn_software/linux/instantclient/199000/instantclient-basiclite-linux.x64-19.9.0.0.0dbru.zip \
    && unzip instantclient-basiclite-linux.x64-19.9.0.0.0dbru.zip \
    && rm instantclient-basiclite-linux.x64-19.9.0.0.0dbru.zip \
    && wget https://download.oracle.com/otn_software/linux/instantclient/199000/instantclient-sqlplus-linux.x64-19.9.0.0.0dbru.zip \
    && unzip instantclient-sqlplus-linux.x64-19.9.0.0.0dbru.zip \
    && rm instantclient-sqlplus-linux.x64-19.9.0.0.0dbru.zip

# copy files to container and chown/chgrp to dev
WORKDIR /home/dev/projects/cx_oracle
COPY . .
RUN chown -R dev /home/dev/projects \
    && chgrp -R dev /home/dev/projects \
    && chmod +x init_sakila

ENV PATH="/opt/oracle/instantclient_19_9:${PATH}"
ENV LD_LIBRARY_PATH="/opt/oracle/instantclient_19_9:${LD_LIBRARY_PATH}"

# create Python virtual environment with cx_Oracle
USER dev
RUN python3 -m venv venv \
    && . venv/bin/activate \
    && pip install cx_Oracle

# allow container to run detached
CMD sleep infinity
