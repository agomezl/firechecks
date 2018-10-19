#!/bin/bash

MQ_HOST=${MQ_HOST:-"rabbit"}
COURSE_NAME=${COURSE_NAME:-"testLab"}
LAB_NUMBER=${LAB_NUMBER:-1}
PORT=${PORT:-3000}

# Some setup
# Some setup
docker kill submissionserver_${COURSE_NAME} &> /dev/null
docker rm   submissionserver_${COURSE_NAME} &> /dev/null

# Create network
docker network create ${MQ_HOST}     &> /dev/null

ID=$(docker run -dt \
            -e MQ_HOST=${MQ_HOST} \
            -e COURSE_NAME=${COURSE_NAME} \
            -e LAB_NUMBER=${LAB_NUMBER} \
            -p ${PORT}:3000 \
            --name "submissionserver_${COURSE_NAME}" \
            --network ${MQ_HOST} \
            -v $(pwd)/server:/server \
            fedora \
            server/submissionserver)

cat <<EOF
ID          = ${ID:0:7}
MQ_HOST     = ${MQ_HOST}
COURSE_NAME = ${COURSE_NAME}
LAB_NUMBER  = ${LAB_NUMBER}
Can now be started and stopped with \`docker [start|stop] submissionserver_${COURSE_NAME}\`
EOF
