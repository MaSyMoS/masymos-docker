#!/usr/bin/env bash

# TODO WIP
while [[ true ]]; do
    sleep 1
done
exit 23

# load source code
mkdir /opt/repos
cd /opt/repos || exit 5
git clone https://github.com/MaSyMoS/masymos-core.git
git clone https://github.com/MaSyMoS/masymos-morre.git

# run maven
cd masymos-core || exit 5
mvn install
cd ../masymos-morre || exit 5
mvn package

# copy libraries
mv /opt/repos/masymos-morre/target/*.jar /opt/output/           # morre plugin
mv /opt/repos/masymos-core/target/lib/*.jar /opt/output/libs    # libs for core
mv /opt/repos/masymos-morre/target/lib/*.jar /opt/output/libs   # libs for morre (incl. core)
