FROM maven:3-openjdk-8
VOLUME /root/.m2
VOLUME /opt/source
VOLUME /opt/output
COPY runner.sh /opt/runner.sh
CMD ["bash", "-c", "/opt/runner.sh"]