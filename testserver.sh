#!/bin/bash

MQ_HOST=${MQ_HOST:-"rabbit"}
COURSE_NAME=${COURSE_NAME:-"testLab"}
LAB_NUMBER=${LAB_NUMBER:-1}

# Create network
docker network create ${MQ_HOST}     &> /dev/null

if ! docker images | grep -q testserver
then
    docker build -t testserver tester/
fi

docker kill testserver_${COURSE_NAME} &> /dev/null
docker rm   testserver_${COURSE_NAME} &> /dev/null

ID=$(docker run -dt \
            -e MQ_HOST=${MQ_HOST} \
            -e COURSE_NAME=${COURSE_NAME} \
            -e LAB_NUMBER=${LAB_NUMBER} \
            --network ${MQ_HOST} \
            --name "testserver_${COURSE_NAME}" \
            testserver)

cat <<EOF

ID          = ${ID:0:7}
MQ_HOST     = ${MQ_HOST}
COURSE_NAME = ${COURSE_NAME}
LAB_NUMBER  = ${LAB_NUMBER}
Can now be started and stopped with \`docker [start|stop] testserver_${COURSE_NAME}\`
EOF
