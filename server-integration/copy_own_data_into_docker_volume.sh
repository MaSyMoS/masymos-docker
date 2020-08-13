#!/usr/bin/env bash
#
# call without parameter for help

readonly local_database_directory="${1}"
readonly PROGNAME=`/usr/bin/basename $0`
cancel=1

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


readonly NEO4J_VOLUME_NAME="masymos_neo4j_database"
# get currents user IDs
readonly __uid=$(id -u)
readonly __gid=$(id -g)
echo "### remove old volume"
docker volume rm -f ${NEO4J_VOLUME_NAME}
echo "### create new volume ${NEO4J_VOLUME_NAME}"
docker volume create ${NEO4J_VOLUME_NAME}
echo "### create databases-folder"
docker run --rm --name copy_data \
    --volume "${NEO4J_VOLUME_NAME}:/opt/volume" \
    alpine mkdir -p /opt/volume/databases
echo "### copy data"
docker run --rm --name copy_data \
    --volume "${NEO4J_VOLUME_NAME}:/opt/volume" \
    --volume "${local_database_directory}:/opt/data":ro \
    alpine cp -R /opt/data /opt/volume/databases/morre
echo "### set UID/GID"
docker run --rm --name copy_data \
    --volume "${NEO4J_VOLUME_NAME}:/opt/volume" \
    alpine chown -R $__uid:$__gid /opt/volume/
echo "### check UID/GID rights"
docker run --rm --name copy_data \
    --volume "${NEO4J_VOLUME_NAME}:/opt/volume" \
    alpine ls -al /opt/volume
echo "### check size"
docker run --rm --name copy_data \
    --volume "${NEO4J_VOLUME_NAME}:/opt/volume" \
    alpine du -hs /opt/volume

