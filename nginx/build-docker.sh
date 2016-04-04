#!/bin/bash

docker build -t nizq/nginx-build .
docker run --rm -ti \
       -v `pwd`:/source \
       nizq/nginx-build /source/build-nginx.sh

cp Dockerfile.final final/Dockerfile
cd final
docker build -t nizq/nginx .
