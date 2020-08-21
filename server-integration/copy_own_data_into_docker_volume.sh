#!/usr/bin/env bash
#
# call without parameter for help

readonly local_database_directory="${1}"
readonly PROGNAME=`/usr/bin/basename $0`
cancel=1

#
#   CHECKS
#

if [[ ! -d "${local_database_directory}" ]]; then
    echo "unable to find directory ${local_database_directory}"
    cancel=0
fi
if [[ ! -r "${local_database_directory}" ]]; then
    echo "unable to read directory ${local_database_directory}"
    cancel=0
fi

if [[ ${cancel} -eq 0 ]]; then
    echo -e "\nUSAGE"
    echo "\$ ${PROGNAME} /path/to/neo4j/databases/my_database"
    echo ""
    echo "make sure to point to your database, not to the neo4j databases root folder"
    echo "your database is a named folder inside a folder called 'databases'"

    exit 1
fi

# docker on windows will need slightly changed path names :/
docker_source_path="${local_database_directory}"
if [[ ! "$OSTYPE" ]]; then
    echo "### bash-variable OSTYPE not set - abort"
    exit 1
fi
# git-bash will return msys; Cygwin returs cygwin
if [[ "${OSTYPE}" == "msys" || "${OSTYPE}" == "cygwin" ]]; then
    docker_source_path=$(echo "$docker_source_path" | sed -e 's|^/\([A-Za-z]\)/|\1:/|')
fi
echo "### OSTYPE: ${OSTYPE}"
echo "### docker_source_path: ${docker_source_path}"

#
# RUN
#

readonly NEO4J_VOLUME_NAME="masymos_neo4j_database"
# get currents user IDs
readonly __uid=$(id -u)
readonly __gid=$(id -g)
echo "### remove old volume"
docker volume rm -f ${NEO4J_VOLUME_NAME}
echo "### create new volume ${NEO4J_VOLUME_NAME}"
docker volume create ${NEO4J_VOLUME_NAME}
echo "### create databases-folder; copy data; set UID/GID"
docker run --rm --name copy_data \
    --volume "${NEO4J_VOLUME_NAME}:/opt/volume" \
    --volume "${docker_source_path}:/opt/data":ro \
    alpine sh -c "mkdir -p /opt/volume/databases; cp -R /opt/data /opt/volume/databases/morre; chown -R $__uid:$__gid /opt/volume/"
echo "### check UID/GID rights and size"
docker run --rm --name copy_data \
    --volume "${NEO4J_VOLUME_NAME}:/opt/volume" \
    alpine sh -c "ls -al /opt/volume; du -hs /opt/volume"

