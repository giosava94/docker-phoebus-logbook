ARG MAVEN_VERSION=3.9
ARG JAVA_VERSION=25

# Use Maven image to execute build.
FROM maven:${MAVEN_VERSION} AS maven-build
ARG OLOG_VERSION=5.1.2
RUN apt update \
    && apt -y install git \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*
RUN git clone -b v${OLOG_VERSION} --single-branch https://github.com/Olog/phoebus-olog.git
WORKDIR /phoebus-olog
RUN mvn -q \
    -DskipTests=true \
    -Dmaven.javadoc.skip=true \
    -Dmaven.source.skip=true \
    -Pdeployable-jar \
    clean install

# Use smaller openjdk image for running.
FROM amazoncorretto:${JAVA_VERSION}
ARG OLOG_VERSION=5.1.2
ENV OLOG_VERSION=${OLOG_VERSION}
WORKDIR /olog-target
COPY --from=maven-build /phoebus-olog/target /olog-target
EXPOSE 8080
EXPOSE 8181
CMD ["sh", "-c", "java -jar service-olog-${OLOG_VERSION}.jar"]