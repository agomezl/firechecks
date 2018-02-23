#!/bin/bash

MQ_HOST=${MQ_HOST:-"rabbit"}
COURSE_NAME=${COURSE_NAME:-"testLab"}

# Some setup
docker kill rabbit &> /dev/null
docker rm rabbit &> /dev/null
mkdir -p ~/.rabbit-docker/data &> /dev/null
chmod -R 777 ~/.rabbit-docker/ &> /dev/null

# Create network
docker network create ${COURSE_NAME}

# Launch the docker
echo "Building and starting the container..."
ID=$(docker run -d -p 5672:5672 \
            --hostname ${MQ_HOST} \
            --net ${COURSE_NAME} \
            --name ${MQ_HOST} \
            -v ~/.rabbit-docker/data:/var/lib/rabbitmq \
            rabbitmq:3)

echo "Container ID: $ID"
echo "Can now be started and stopped with \`docker [start|stop] rabbit\`"
