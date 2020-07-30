#!/usr/bin/env bash
# builds masymos core and masymos morre
# with the same java as used in the neo4j container
#
# paramter
#   rebuild    OPTIONAL: docker image will be created again

DOCKER_IMAGE_NAME="masymos-jar-builder" # the image name and the folder with the files
DOCKER_IMAGE_PATH="d_jar-builder" # the image name and the folder with the files

PARAM="$1"
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
cd "${PROGPATH}" || exit 5;
SOURCE_PATH="masymos-source/"
BUILDS_PATH="masymos-builds/"
MAVEN_LIBS="maven-dependencies/"

echo "### remove old jars from ${BUILDS_PATH}"
rm "${BUILDS_PATH}/*.jar"

# check parameter
if [[ "$PARAM" == "rebuild" ]]; then
    echo "### remove old docker image"
    docker image rm -f ${DOCKER_IMAGE_NAME}
fi

# check source repos
if [[ ! -d "${SOURCE_PATH}/masymos-core" ]]; then
    echo "### Source-Repository masymos-core missing → clone to ${SOURCE_PATH}"
    git clone https://github.com/MaSyMoS/masymos-core.git "${SOURCE_PATH}/masymos-core"
fi
if [[ ! -d "${SOURCE_PATH}/masymos-morre" ]]; then
    echo "### Source-Repository masymos-morre missing → clone to ${SOURCE_PATH}"
    git clone https://github.com/MaSyMoS/masymos-morre.git "${SOURCE_PATH}/masymos-morre"
fi

# build docker image only, if it's not there
if [[ "$PARAM" == "rebuild" || "$(docker images -q ${DOCKER_IMAGE_NAME} | wc -l)" -eq 0 ]]; then
    echo "### build docker image ${DOCKER_IMAGE_NAME}"
    docker build -t ${DOCKER_IMAGE_NAME}:latest ${DOCKER_IMAGE_PATH}
fi

echo "### run docker image ${DOCKER_IMAGE_NAME}"
docker run --rm \
            --name "${DOCKER_IMAGE_NAME}" \
            -v "$PWD/${MAVEN_LIBS}":"/root/.m2" \
            -v "$PWD/${SOURCE_PATH}":"/opt/source" \
            -v "$PWD/${BUILDS_PATH}":"/opt/output" \
            ${DOCKER_IMAGE_NAME}

ret=$?

if [[ $ret -ne 0 ]]; then
    echo "### docker error, retur code ${ret}"
else
    echo "### done"
fi
