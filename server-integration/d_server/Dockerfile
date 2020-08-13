# https://hub.docker.com/_/neo4j/
FROM neo4j:3.5

# copy needed libraries
COPY masymos-builds/masymos-morre-*.jar /var/lib/neo4j/plugins/masymos-morre.jar
COPY masymos-builds/libs /var/lib/neo4j/lib/ext

# Avoid unpredictable behaviour based on java-library complications
RUN cd /var/lib/neo4j/lib/ext || exit 1; \
    for f in ./../*; do rm -v "./$(basename $f)" 2>/dev/null; done || true; \
    rm -v *.pom 2>/dev/null; \
    rm -v neo4j-*.jar 2>/dev/null; \
    rm -v server-*.jar 2>/dev/null;

# adjust configurations
RUN echo "dbms.unmanaged_extension_classes=de.unirostock.morre.server.plugin=/morre" >> /var/lib/neo4j/conf/neo4j.conf \
 && sed --in-place 's|\${NEO4J_LIB}/\*:|\${NEO4J_LIB}/\*:\${NEO4J_LIB}/ext/\*:|' /var/lib/neo4j/bin/neo4j

VOLUME /data

# get an own script running on startup
COPY extra_conf.sh /extra_conf.sh
