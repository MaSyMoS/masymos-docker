#!/usr/bin/env bash
#
# running this file will remove all docker artifacts created by this repository

# jar-builder
readonly DOCKER_IMAGE_NAME="masymos-jar-builder"     # the image name and the folder with the files
readonly MAVEN_VOLUME_NAME="masymos_maven_artifacts" # the volume name to store the maven artifacts

docker image rm -f ${DOCKER_IMAGE_NAME}
docker volume rm -f $MAVEN_VOLUME_NAME
