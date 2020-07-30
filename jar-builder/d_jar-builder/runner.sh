#!/usr/bin/env bash

# uncomment to work manually in the container
# while [[ true ]]; do echo "runner disabled"; sleep 60; done; exit 23

# check
if [[ ! -d /opt/source/masymos-core ]]; then
    echo "Repository masymos-core does not exist! Please clone the repositories to directory masymos-source."
    exit 7
fi
if [[ ! -d /opt/source/masymos-cli ]]; then
    echo "Repository masymos-cli does not exist! Please clone the repositories to directory masymos-source."
    exit 7
fi
if [[ ! -d /opt/source/masymos-morre ]]; then
    echo "Repository masymos-morre does not exist! Please clone the repositories to directory masymos-source."
    exit 7
fi

# maven load dependencies and build
cd /opt/source/masymos-core || exit 5
mvn dependency:go-offline
mvn clean install

cd /opt/source/masymos-cli || exit 5
mvn dependency:go-offline
mvn clean package

cd /opt/source/masymos-morre || exit 5
mvn dependency:go-offline
mvn clean package

# copy libraries
mkdir /opt/output/libs
cp /opt/source/masymos-cli/target/*.jar /opt/output/             # cli program
cp /opt/source/masymos-morre/target/*.jar /opt/output/           # morre plugin
cp /opt/source/masymos-core/target/lib/*.jar /opt/output/libs    # libs for core
cp /opt/source/masymos-morre/target/lib/*.jar /opt/output/libs   # libs for morre (incl. core)

# set right persmission for all mounted volumes
source /opt/source/user_group_numbers.sh
chown -R ${HOST_UID}:${HOST_GID} /opt/source/
chown -R ${HOST_UID}:${HOST_GID} /opt/output/
