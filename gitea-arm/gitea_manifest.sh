#!/bin/bash

docker manifest create kunde21/gitea-arm:$1 kunde21/gitea-arm:{arm64,armv6,armv7,amd64}-$2
docker manifest annotate kunde21/gitea-arm:$1 kunde21/gitea-arm:armv6-$2 --variant v6
docker manifest annotate kunde21/gitea-arm:$1 kunde21/gitea-arm:armv7-$2 --variant v7
docker manifest push -p kunde21/gitea-arm:$1
