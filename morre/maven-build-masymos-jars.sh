#!/usr/bin/env bash
# builds masymos core and masymos morre
# with the same java as used in the neo4j container
#
# paramter
#   rebuild    OPTIONAL: docker image will be created again

DOCKER_IMAGE="d_jar-builder" # the image name and the folder with the files

PARAM="$1"
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
cd "${PROGPATH}" || exit 5;
BUILDS_PATH="masymos-builds/"

echo "### remove old jars from ${BUILDS_PATH}"
rm "${BUILDS_PATH}/*.jar"

# check parameter
if [[ "$PARAM" == "rebuild" ]]; then
    echo "### remove old docker image"
    docker image rm -f ${DOCKER_IMAGE}
fi

# build docker image only, if it's not there
if [[ "$PARAM" == "rebuild" || "$(docker images -q ${DOCKER_IMAGE} | wc -l)" -eq 0 ]]; then
    echo "### build docker image ${DOCKER_IMAGE}"
    docker build -t ${DOCKER_IMAGE}:latest ${DOCKER_IMAGE}
fi

echo "### run docker image ${DOCKER_IMAGE}"
docker run --rm \
            --name "${DOCKER_IMAGE}" \
            -v "$PWD/${BUILDS_PATH}":"/opt/output" \
            ${DOCKER_IMAGE}

ret=$?

if [[ $ret -ne 0 ]]; then
    echo "### docker error, retur code ${ret}"
else
    echo "### done"
fi
