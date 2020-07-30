#!/usr/bin/env bash

# uncomment to work manually in the container
# while [[ true ]]; do sleep 1; done; exit 23

# maven load dependencies and build
cd /opt/source/masymos-core || exit 5
mvn dependency:go-offline
mvn clean install
cd /opt/source/masymos-morre || exit 5
mvn dependency:go-offline
mvn clean package

# copy libraries
mkdir /opt/output/libs
cp /opt/source/masymos-morre/target/*.jar /opt/output/           # morre plugin
cp /opt/source/masymos-core/target/lib/*.jar /opt/output/libs    # libs for core
cp /opt/source/masymos-morre/target/lib/*.jar /opt/output/libs   # libs for morre (incl. core)
