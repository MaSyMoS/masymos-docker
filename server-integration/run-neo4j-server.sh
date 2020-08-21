#!/usr/bin/env bash
# build and run masymos-enhanced neo4j in docker
#
# paramter
#   rebuild    OPTIONAL: docker image will be created again


readonly DOCKER_IMAGE_NAME="masymos_neo4j"           # the image name and the folder with the files
readonly DOCKER_IMAGE_PATH="d_server"                # the image name and the folder with the files
readonly NEO4J_VOLUME_NAME="masymos_neo4j_database"  # the volume name to store the neo4j database

readonly MASYMOS_JAR_BUILDER_SOURCE_FOLDER="../jar-builder/masymos-builds"
readonly MASYMOS_JAR_SOURCE_FOLDER="${DOCKER_IMAGE_PATH}/masymos-builds"

readonly PARAM="$1"
readonly PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
cd "${PROGPATH}" || exit 5;
__build=1

# check if running
if [[ "$( docker container inspect -f '{{.State.Running}}' "${DOCKER_IMAGE_NAME}" 2>/dev/null )" == "true" ]]; then
    echo "### Container is still running; stop with 'docker stop ${DOCKER_IMAGE_NAME}'"
    exit 10
fi

# check parameter
if [[ "$PARAM" == "rebuild" ]]; then
    echo "### remove old docker image"
    docker image rm -f ${DOCKER_IMAGE_NAME} 2> /dev/null
fi
# check, if docker image exists
if [[ "$PARAM" == "rebuild" || "$(docker images -q ${DOCKER_IMAGE_NAME} | wc -l)" -eq 0 ]]; then
    __build=0
fi

# create neo4j database volume
docker volume inspect $NEO4J_VOLUME_NAME 1>/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "### create docker volume ${NEO4J_VOLUME_NAME}"
    docker volume create $NEO4J_VOLUME_NAME 1> /dev/null
fi

# build docker image
if [[ $__build -eq 0 ]]; then
    # check masymos JARs
    if [[ -r "${MASYMOS_JAR_BUILDER_SOURCE_FOLDER}" && -d "${MASYMOS_JAR_BUILDER_SOURCE_FOLDER}" && \
          -r "${MASYMOS_JAR_BUILDER_SOURCE_FOLDER}/libs" && -d "${MASYMOS_JAR_BUILDER_SOURCE_FOLDER}/libs" && \
          $(ls "${MASYMOS_JAR_BUILDER_SOURCE_FOLDER}/"masymos-morre-*.jar | wc -l) -eq 1 && \
          $(ls "${MASYMOS_JAR_BUILDER_SOURCE_FOLDER}/libs/"masymos-core-*.jar | wc -l) -eq 1 && \
          $(ls "${MASYMOS_JAR_BUILDER_SOURCE_FOLDER}/libs/"*.jar | wc -l) -gt 123 ]]; then
        echo "### copy masymos jars and libraries from ${MASYMOS_JAR_BUILDER_SOURCE_FOLDER} to ${MASYMOS_JAR_SOURCE_FOLDER}"

        __output=$(rm --verbose ${MASYMOS_JAR_SOURCE_FOLDER}/*.jar 2>&1)
        if [[ $? -ne 1 ]]; then
            echo "${__output}"
        fi
        __output=$(rm --recursive ${MASYMOS_JAR_SOURCE_FOLDER}/libs 2>&1)
        if [[ $? -ne 1 ]]; then
            echo "${__output}"
        fi
        cp --recursive "${MASYMOS_JAR_BUILDER_SOURCE_FOLDER}/masymos-morre"*.jar "${MASYMOS_JAR_SOURCE_FOLDER}"
        cp --recursive "${MASYMOS_JAR_BUILDER_SOURCE_FOLDER}/libs" "${MASYMOS_JAR_SOURCE_FOLDER}"
    else
        echo "### cannot find masymos jars and libraries in ${MASYMOS_JAR_BUILDER_SOURCE_FOLDER} - please run the jar-builder first"
        exit 42
    fi
    # build
    echo "### build docker image ${DOCKER_IMAGE_NAME}"
    docker build -t ${DOCKER_IMAGE_NAME}:latest ${DOCKER_IMAGE_PATH}
fi

echo "### run docker image ${DOCKER_IMAGE_NAME}"
docker run --rm \
    --detach \
    --env "EXTENSION_SCRIPT=/extra_conf.sh" \
    --env "NEO4J_AUTH=none" \
    --env "NEO4J_dbms_active__database=morre" \
    --env "NEO4J_dbms_allow__upgrade=true" \
    --user "$(id -u):$(id -g)" \
    --name "${DOCKER_IMAGE_NAME}" \
    --publish 7474:7474 \
    --publish 7687:7687 \
    --volume "$NEO4J_VOLUME_NAME:/data" \
    ${DOCKER_IMAGE_NAME}

## OPTINAL PARAMETERS
## set initial password
#    --env NEO4J_AUTH=neo4j/your_password
## disable authentication
#    --env NEO4J_AUTH=none
## run neo4j with the UID7GID of the current user
#    --user "$(id -u):$(id -g)"

ret=$?

if [[ $ret -ne 0 ]]; then
    echo "### docker error, return code ${ret}"
else
    echo "### done - neo4j is running"
    echo "### see logs with 'docker logs --follow ${DOCKER_IMAGE_NAME}'"
    echo "### stop with 'docker stop ${DOCKER_IMAGE_NAME}'"
fi

