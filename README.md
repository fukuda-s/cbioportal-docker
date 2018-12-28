# docker-cbioportal

A standalone Docker cantainer running the cBioPortal for Cancer Genomics (http://www.cbioportal.org/).

## Summary
The image based on mysql:8 and tomcat:9-jre11 with using docker-composer. the MySQL data is stored on Docker volume on local host so the data is not removed when the Docker container is stopped.

## Requirement

 - Docker (1.13.0+)
 - docker-compose (Compose file is described with 3.0)

## Run

    docker-compose up

## Test

URL: http://localhost:8080/cbioportal/
