#!/bin/bash

docker run -d \
       -e MQ_HOST=rabbit \
       -p 3000:3000 \
       --net testLab \
       -v $(pwd)/server:/server \
       fedora \
       server/.stack-work/dist/x86_64-linux-tinfo6/Cabal-1.22.5.0/build/submissionserver/submissionserver
