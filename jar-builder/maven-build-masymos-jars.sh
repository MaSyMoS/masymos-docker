#!/usr/bin/env bash
# builds masymos core and masymos morre
# with the same java as used in the neo4j container
#
# paramter
#   rebuild    OPTIONAL: docker image will be created again

readonly DOCKER_IMAGE_NAME="masymos-jar-builder"     # the image name and the folder with the files
readonly DOCKER_IMAGE_PATH="d_jar-builder"           # the image name and the folder with the files
readonly MAVEN_VOLUME_NAME="masymos_maven_artifacts" # the volume name to store the maven artifacts

readonly PARAM="$1"
readonly PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
cd "${PROGPATH}" || exit 5;
readonly SOURCE_PATH="masymos-source/"
readonly BUILDS_PATH="masymos-builds/"

echo "### remove old jars from ${BUILDS_PATH}"
rm --verbose ${BUILDS_PATH}/*.jar
rm --recursive ${BUILDS_PATH}/libs

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
if [[ ! -d "${SOURCE_PATH}/masymos-cli" ]]; then
    echo "### Source-Repository masymos-cli missing → clone to ${SOURCE_PATH}"
    git clone https://github.com/MaSyMoS/masymos-cli.git "${SOURCE_PATH}/masymos-cli"
fi
if [[ ! -d "${SOURCE_PATH}/masymos-morre" ]]; then
    echo "### Source-Repository masymos-morre missing → clone to ${SOURCE_PATH}"
    git clone https://github.com/MaSyMoS/masymos-morre.git "${SOURCE_PATH}/masymos-morre"
fi

# create maven artifacts volume
docker volume inspect $MAVEN_VOLUME_NAME
if [[ $? -ne 0 ]]; then
    echo "### create docker volume ${MAVEN_VOLUME_NAME}"
    docker volume create $MAVEN_VOLUME_NAME
fi


# build docker image only, if it does not exist
if [[ "$PARAM" == "rebuild" || "$(docker images -q ${DOCKER_IMAGE_NAME} | wc -l)" -eq 0 ]]; then
    echo "### build docker image ${DOCKER_IMAGE_NAME}"
    docker build -t ${DOCKER_IMAGE_NAME}:latest ${DOCKER_IMAGE_PATH}
fi

echo "### run docker image ${DOCKER_IMAGE_NAME}"
docker run --rm \
            --name "${DOCKER_IMAGE_NAME}" \
            --volume "$MAVEN_VOLUME_NAME:/root/.m2" \
            --volume "$PWD/${SOURCE_PATH}:/opt/source" \
            --volume "$PWD/${BUILDS_PATH}:/opt/output" \
            ${DOCKER_IMAGE_NAME}

ret=$?

if [[ $ret -ne 0 ]]; then
    echo "### docker error, retur code ${ret}"
else
    echo "### done"
fi
