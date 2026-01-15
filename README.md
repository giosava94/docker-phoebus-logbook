# docker-phoebus-logbook

This repository hosts the Dockerfile used to build the Docker image published on Docker Hub and INFN Baltig's container registry:

- giosava94/logbook-server

It downloads and compiles from the [Phoebus Olog github repository](https://github.com/Olog/phoebus-olog) the **logbook-server** services.

# Pre-requisites

You must have [docker](https://docs.docker.com/) and [docker compose](https://docs.docker.com/compose/) installed on your host PC.

The logbook-server requires a [MongoDB](https://www.mongodb.com/docs/) and an [elasticsearch](https://www.elastic.co) instance. We assume a basic knowledge about mongo and elasticsearch.

> When running _elasticsearch_ outisde docker, the **vm.max_map_count** kernel setting must be set to at least 262144 for production use. To permanently change the value for the **vm.max_map_count** setting, update the value in `/etc/sysctl.conf`. Instead, to apply the settings on a live system, run: `sysctl -w vm.max_map_count=262144`

# Repository content description

The Dockerfile used to build the logbook-server docker image.

A docker-compose template as reference:
- compose.yml

# Usage

## Run temporary instance

Command to run a temporary instance of a logbook-server inside a docker container

```bash
docker run --rm giosava94/logbook-server
```

You can add other parameters if required, refers to the correct version of the [logbook-server](https://github.com/Olog/phoebus-olog) to know the possible parameters what they expect.

> Alternatively you can download the phoebus git repository, compile the service and start it locally on your host.

## Verify the logbook-server is up and running

Once the service is running, the service consists of a welcome page. This will provide information about the version of the Olog service running, along with information about the version and connection status of the elastic and mongo backends.

```bash
curl -X GET 'http://localhost:8080/Olog'
```

An example for testing the creation of a single test log entry with the demo credentials

```bash
curl --location --insecure --request PUT 'https://localhost:8181/Olog/logs' \
--header 'Content-Type: application/json' \
--header 'Authorization: Basic YWRtaW46YWRtaW5QYXNz' \
--data '{
             "owner": "test-owner",
             "source": "This is an test entry",
             "title": "Tes title",
             "level": "Info",
             "logbooks": [{"name": "operations","owner": "olog-logs"}]
         }'
```

## Phoebus clients

Set your client settings are as follows:

```md
org.phoebus.olog.es.api/olog_url=<logbook-server-url>/Olog
```

# Developers

## Build Images

The Dockerfile downloads the Olog git repository (default=v5.1.2) and compiles the service using maven (default=v3.9).

```bash
docker build -t logbook-server .
```

If you want you can build the images using the following _--build-arg_ values:
- **OLOG_VERSION**: Change the Olog service version
- **MAVEN_VERSION**: Change the maven version used to build the applications
- **JAVA_VERSION**: Change the java version used to run the applications

# Useful links

- [Phoebus Olog documentation](https://control-system-studio.readthedocs.io/en/latest/app/logbook/olog/ui/doc/index.html)
- [Phoebus Olog github repository](https://github.com/Olog/phoebus-olog)
- [Elasticsearch 8.19](https://www.elastic.co/guide/en/starting-with-the-elasticsearch-platform-and-its-solutions/8.19/index.html)
