ARG MAVEN_VERSION=3.9
ARG JAVA_VERSION=25

# Use Maven image to execute build.
FROM maven:${MAVEN_VERSION} AS maven-build

ARG OLOG_VERSION=5.1.2
ARG INSTALL_EMAIL_NOTIFIER=false

RUN apt update \
    && apt -y install git \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

COPY ./email-notifier-module/ ./email-notifier-module/
RUN if ${INSTALL_EMAIL_NOTIFIER}; then \
        git clone -b fix-notify-with-attachment --single-branch https://github.com/giosava94/phoebus-olog.git; \
        git clone https://github.com/giosava94/phoebus-olog-email-notifier-module.git; \
        cd phoebus-olog-email-notifier-module; \
        mvn clean install -q -DskipTests=true -Dmaven.javadoc.skip=true; \
        cd ..; \
        sh email-notifier-module/add-email-notifier.sh; \
    else \
        git clone -b v${OLOG_VERSION} --single-branch https://github.com/Olog/phoebus-olog.git; \
    fi

WORKDIR /phoebus-olog
RUN mvn clean install -q \
        -DskipTests=true \
        -Dmaven.javadoc.skip=true \
        -Dmaven.source.skip=true \
        -Pdeployable-jar \
    && cp target/service-olog-${OLOG_VERSION}.jar target/service-olog.jar

# Use smaller openjdk image for running.
FROM amazoncorretto:${JAVA_VERSION}

EXPOSE 8080
EXPOSE 8181

WORKDIR /olog-target
COPY --from=maven-build /phoebus-olog/target /olog-target
CMD ["sh", "-c", "java -jar service-olog.jar"]
