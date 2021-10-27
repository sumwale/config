#!/bin/sh

docker run -d -e REGISTRY_STORAGE_DELETE_ENABLED=true -p 5000:5000 --restart=always --name registry registry:2
