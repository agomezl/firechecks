#!/bin/bash

MQ_HOST=${MQ_HOST:-"rabbit"}
COURSE_NAME=${COURSE_NAME:-"testLab"}
LAB_NUMBER=${LAB_NUMBER:-1}
BUILD_DIR=$(pwd)/tester
CONTAINER_NAME=${COURSE_NAME}_${LAB_NUMBER}
# Create network
docker network create ${MQ_HOST}     &> /dev/null

if ! docker images | grep -q testserver
then
    docker build -t testserver tester/src
fi

docker kill testserver_${CONTAINER_NAME} &> /dev/null
docker rm   testserver_${CONTAINER_NAME} &> /dev/null

ID=$(docker run -dt \
            -e MQ_HOST=${MQ_HOST} \
            -e COURSE_NAME=${COURSE_NAME} \
            -e LAB_NUMBER=${LAB_NUMBER} \
            -e BUILD_DIR=${BUILD_DIR} \
            -v ${BUILD_DIR}/src:/tester \
            -v /var/run/docker.sock:/var/run/docker.sock \
            --network ${MQ_HOST} \
            --name "testserver_${CONTAINER_NAME}" \
            --workdir /tester \
            testserver \
            python3 tester.py)

cat <<EOF

ID          = ${ID:0:7}
MQ_HOST     = ${MQ_HOST}
COURSE_NAME = ${COURSE_NAME}
LAB_NUMBER  = ${LAB_NUMBER}
Can now be started and stopped with \`docker [start|stop] testserver_${CONTAINER_NAME}\`
EOF
