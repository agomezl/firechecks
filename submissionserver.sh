#!/bin/bash

MQ_HOST=${MQ_HOST:-"rabbit"}
COURSE_NAME=${COURSE_NAME:-"testLab"}
LAB_NUMBER=${LAB_NUMBER:-1}

# Create network
docker network create ${COURSE_NAME}
docker network create ${MQ_HOST}

docker run -it --rm \
       -e MQ_HOST=${MQ_HOST} \
       -e COURSE_NAME=${COURSE_NAME} \
       -e LAB_NUMBER=${LAB_NUMBER} \
       -p 3000:3000 \
       --name "submissionserver_${COURSE_NAME}" \
       --net ${COURSE_NAME} \
       --net ${MQ_HOST} \
       -v $(pwd)/server:/server \
       fedora \
       server/submissionserver
