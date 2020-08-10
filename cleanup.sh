#!/usr/bin/env bash
#
# running this file will remove all docker artefacts created by this repository

# jar-builder
readonly DOCKER_IMAGE_NAME_JARS="masymos-jar-builder"     # the image name and the folder with the files
readonly DOCKER_IMAGE_NAME_NEO4J="masymos_neo4j"           # the image name and the folder with the files
readonly MAVEN_VOLUME_NAME="masymos_maven_artifacts" # the volume name to store the maven artifacts
readonly NEO4J_VOLUME_NAME="masymos_neo4j_database"  # the volume name to store the neo4j database

docker image rm -f ${DOCKER_IMAGE_NAME_JARS}
docker image rm -f ${DOCKER_IMAGE_NAME_NEO4J}
docker volume rm -f $MAVEN_VOLUME_NAME
docker volume rm -f $NEO4J_VOLUME_NAME
