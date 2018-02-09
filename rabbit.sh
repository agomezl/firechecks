#!/bin/bash

# Some setup
docker kill rabbit &> /dev/null
docker rm rabbit &> /dev/null
mkdir -p ~/.rabbit-docker/data &> /dev/null
chmod -R 777 ~/.rabbit-docker/ &> /dev/null

# Launch the docker
echo "Building and starting the container..."

case "$OSTYPE" in
    #solaris*) echo "SOLARIS" ;;
    darwin*)
        ID=$(docker run -d --hostname rabbit --name rabbit rabbitmq:3)
        ;;
    linux*)
        ID=$(docker run -d -p 5672:5672 --hostname rabbit --name rabbit -v ~/.rabbit-docker/data:/var/lib/rabbitmq rabbitmq:3)
        ;;
    #bsd*)     echo "BSD" ;;
    #msys*)    echo "WINDOWS" ;;
    *)        echo "Unhandled OS: $OSTYPE" ;;
esac

echo "Container ID: $ID"

echo "Can now be started and stopped with \`docker [start|stop] rabbit\`"
