#!/usr/bin/env bash

#
# set the source data directory with your database here
# make sure to point to your database, not to the neo4j database root
# your database is a named folder inside a folder called databases
#
readonly local_database_directory=""

if [[ ! -d "${local_database_directory}" ]]; then
    echo "unable to find directory ${local_database_directory}"
    exit 1
fi
if [[ ! -r "${local_database_directory}" ]]; then
    echo "unable to read directory ${local_database_directory}"
    exit 2
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

