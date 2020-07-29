#! /bin/bash
# builds masymos core and masymos morre
# with the same java as used in the neo4j container
#
# paramter
#   rebuild    OPTIONAL: docker image will be created again

DOCKER_IMAGE="d_jar-builder"

PARAM="$1"
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`

echo "### remove old jars"
rm "${PROGPATH}/masymos-builds/*.jar"

# check parameter
if [[ "$PARAM" == "rebuild" ]]; then
    docker image rm -f ${DOCKER_IMAGE}
fi

# build docker image only, if it's not there
if [[ "$PARAM" == "rebuild" || "$(docker images -q ${DOCKER_IMAGE} | wc -l)" -eq 0 ]]; then
    echo "### build docker image ${DOCKER_IMAGE}"
    docker build -t ${DOCKER_IMAGE}:latest maven-build-masymos-jars
fi

echo "### start docker image ${DOCKER_IMAGE}"
docker run ${DOCKER_IMAGE}

ret=$?

if [[ $ret -ne 0 ]]; then
    echo "### docker error, retur code ${ret}"
else
    echo "### done"
fi