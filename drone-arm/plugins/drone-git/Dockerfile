FROM golang:1.11-alpine AS build-env

ENV GOPATH /gopath
ENV GODEBUG netdns=go

RUN apk update && apk upgrade && \
	apk add --no-cache git \
		gcc \
		musl-dev ; 

RUN go get -v -tags netgo github.com/drone-plugins/drone-git 

FROM registry.kc.csk/kunde21/cluster-build:v0.0.3

MAINTAINER Chad Kunde <Kunde21@gmail.com>

LABEL org.label-schema.version=latest
LABEL org.label-schema.vcs-url="https://github.com/drone-plugins/drone-git.git"
LABEL org.label-schema.name="Drone Git for ARM"
LABEL org.label-schema.vendor="Drone.IO Community"
LABEL org.label-schema.schema-version="1.0"

RUN apk add -U --no-cache ca-certificates git openssh curl perl

COPY --from=build-env /gopath/bin/drone-git /bin/drone-git

ADD ./entry.sh /bin/entry.sh

ENTRYPOINT ["/bin/entry.sh"]
