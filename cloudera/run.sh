#!/bin/sh -e

docker build -t local/cloudera-quickstart:latest .
docker-cleanup
docker run --hostname=quickstart.cloudera --privileged=true --network=host --name=cloudera -itd local/cloudera-quickstart:latest
