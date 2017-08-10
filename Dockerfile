FROM java:openjdk-8-jre
ENV HZ_VERSION 3.8.2
ENV HZ_HOME /opt/hazelcast/
RUN mkdir -p $HZ_HOME
WORKDIR $HZ_HOME
# Download hazelcast jars from maven repo.
ADD https://repo1.maven.org/maven2/com/hazelcast/hazelcast/$HZ_VERSION/hazelcast-$HZ_VERSION.jar $HZ_HOME

### Adding Logging redirector
ADD https://repo1.maven.org/maven2/org/slf4j/jul-to-slf4j/1.7.12/jul-to-slf4j-1.7.12.jar $HZ_HOME

### Adding JCache
ADD https://repo1.maven.org/maven2/javax/cache/cache-api/1.0.0/cache-api-1.0.0.jar $HZ_HOME

ADD server.sh /$HZ_HOME/server.sh

ADD hazelcast.xml /$HZ_HOME/hazelcast.xml

### Adding maven wrapper, downloading Hazelcast Kubernetes discovery plugin and dependencies and cleaning up
COPY mvnw $HZ_HOME/mvnw

RUN cd mvnw && \
    chmod +x mvnw && \
    ./mvnw -f dependency-copy.xml dependency:copy-dependencies && \
    cd .. && \
    rm -rf $HZ_HOME/mvnw && \
    rm -rf $HZ_HOME/.m2 && \
    chmod -R +r $HZ_HOME


RUN chmod +x /$HZ_HOME/server.sh

EXPOSE 5701

# Start hazelcast standalone server.
CMD ["./server.sh"]
