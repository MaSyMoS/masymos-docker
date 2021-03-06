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

#
# CHECKS
#
if [[ ! "$OSTYPE" ]]; then
    echo "### bash-variable OSTYPE not set - abort"
    exit 1
fi

command -v docker >/dev/null 2>&1 || { echo >&2 "Command docker is required but it's not installed. Aborting."; exit 2; }

#
# RUN
#
echo "### remove old jars from ${BUILDS_PATH}"

# rm error 1 means, the file cannot be deleted beacause it doesn't exist
__output=$(rm --verbose ${BUILDS_PATH}/*.jar 2>&1)
if [[ $? -ne 1 ]]; then
    echo "${__output}"
fi
__output=$(rm --recursive ${BUILDS_PATH}/libs 2>&1)
if [[ $? -ne 1 ]]; then
    echo "${__output}"
fi

# check parameter
if [[ "$PARAM" == "rebuild" ]]; then
    echo "### remove old docker image"
    docker image rm -f ${DOCKER_IMAGE_NAME} 2> /dev/null
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
docker volume inspect $MAVEN_VOLUME_NAME 1>/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "### create docker volume ${MAVEN_VOLUME_NAME}"
    docker volume create $MAVEN_VOLUME_NAME 1> /dev/null
fi

# build docker image only, if it does not exist
if [[ "$PARAM" == "rebuild" || "$(docker images -q ${DOCKER_IMAGE_NAME} | wc -l)" -eq 0 ]]; then
    echo "### build docker image ${DOCKER_IMAGE_NAME}"
    docker build -t ${DOCKER_IMAGE_NAME}:latest ${DOCKER_IMAGE_PATH}
fi

# docker on windows will need slightly changed path names :/
docker_source_path="$PWD/${SOURCE_PATH}"
docker_builds_path="$PWD/${BUILDS_PATH}"
# git-bash will return msys; Cygwin returs cygwin
if [[ "${OSTYPE}" == "msys" || "${OSTYPE}" == "cygwin" ]]; then
    docker_source_path=$(echo "$docker_source_path" | sed -e 's|^/\([A-Za-z]\)/|\1:/|')
    docker_builds_path=$(echo "$docker_builds_path" | sed -e 's|^/\([A-Za-z]\)/|\1:/|')
fi
echo "### OSTYPE: ${OSTYPE}"
echo "### docker_source_path: ${docker_source_path}"
echo "### docker_builds_path: ${docker_builds_path}"

echo "### run docker image ${DOCKER_IMAGE_NAME}"
docker run --rm \
            --name "${DOCKER_IMAGE_NAME}" \
            --volume "$MAVEN_VOLUME_NAME:/root/.m2" \
            --volume "${docker_source_path}:/opt/source" \
            --volume "${docker_builds_path}:/opt/output" \
            ${DOCKER_IMAGE_NAME}

ret=$?

if [[ $ret -ne 0 ]]; then
    echo "### docker error, return code ${ret}"
else
    echo "### done"
fi
