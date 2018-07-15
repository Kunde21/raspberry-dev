FROM golang:alpine AS build-env

ENV CGO_ENABLED 0

RUN apk add --no-cache git \
    && go get -d github.com/drone-plugins/drone-docker/cmd/drone-docker \
    && go build -ldflags "-X main.build=${DRONE_BUILD_NUMBER}" -a -tags netgo -o /bin/drone-docker github.com/drone-plugins/drone-docker/cmd/drone-docker

FROM docker:18.03.1-ce-dind

COPY --from=build-env /bin/drone-docker /bin/drone-docker
ENTRYPOINT ["/usr/local/bin/dockerd-entrypoint.sh", "/bin/drone-docker"]
