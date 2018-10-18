#!/bin/bash

export COURSE_NAME=${COURSE_NAME:-"testLab"}
export LAB_NUMBER=${LAB_NUMBER:-1}
export MQ_HOST=${MQ_HOST:-"rabbit"}


if ! docker ps | grep -q ${MQ_HOST}
then
    ./rabbit.sh
    sleep 5
fi


if ! docker ps | grep -q "submissionserver_${COURSE_NAME}"
then
    ./submissionserver.sh
    sleep 5
fi

if ! docker ps | grep -q "testserver_${COURSE_NAME}"
then
    ./testserver.sh
fi
