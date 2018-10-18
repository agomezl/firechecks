#!/bin/bash

MQ_HOST=${MQ_HOST:-"rabbit"}

# Some setup
docker kill rabbit &> /dev/null
docker rm rabbit &> /dev/null
mkdir -p ~/.rabbit-docker/data &> /dev/null
chmod -R 777 ~/.rabbit-docker/ &> /dev/null

# Create network
docker network create ${MQ_HOST} &> /dev/null

# Launch the docker
echo "Building and starting the container..."
ID=$(docker run -d -p 5672:5672 \
            --hostname ${MQ_HOST} \
            --network ${MQ_HOST} \
            --name ${MQ_HOST} \
            -v ~/.rabbit-docker/data:/var/lib/rabbitmq \
            rabbitmq:3)
cat <<EOF
ID          = ${ID:0:7}
MQ_HOST     = ${MQ_HOST}
Can now be started and stopped with \`docker [start|stop] ${MQ_HOST}\`
EOF


echo
