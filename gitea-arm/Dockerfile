FROM node:12.16.1-alpine3.11 AS frontend
ARG GITEA_VERSION=latest
ARG SRC=https://github.com/go-gitea/gitea/archive

WORKDIR /build

RUN apk add --update --no-cache jq make

RUN if [ "$GITEA_VERSION" = "latest" ]; then GITEA_VERSION=$(wget --quiet "https://api.github.com/repos/go-gitea/gitea/releases/latest" -O - |  jq -r '.tag_name'); fi && \
	wget ${SRC}/${GITEA_VERSION}.tar.gz -O ../gitea.tar.gz

RUN tar xf ../gitea.tar.gz --strip-components=1

COPY makefile.patch makefile.patch
RUN patch < makefile.patch

RUN VERSION=${GITEA_VERSION} make js css

FROM golang:1.13-alpine3.11 AS build-env

ARG GITEA_VERSION=latest
ARG GOPROXY=https://proxy.golang.org
ARG GOARM=7

ENV GOPATH /gopath
ENV PATH $PATH:/gopath/bin
ENV GODEBUG netdns=go
ENV TAGS bindata sqlite sqlite_unlock_notify

COPY --from=frontend /build /build

WORKDIR /build

RUN apk --update --no-cache add \
	git \
	linux-pam \
	tzdata \
	gcc \
	musl-dev \
	openssl \
	openssh \
	openssh-client \
	sqlite \
	sqlite-libs ;

RUN go get -u github.com/jteeuwen/go-bindata/... && \
	go generate ./...

RUN go build -v -mod=vendor -o /gitea -tags "$TAGS" -ldflags="-s -w -X 'main.Version=$GITEA_VERSION' -X 'main.Tags=$TAGS'"

RUN mv docker /docker &&  /gitea -h

FROM alpine:3.11

EXPOSE 22 3000

RUN apk --update --no-cache add \
	su-exec \
	ca-certificates \
	sqlite \
	bash \
	git \
	linux-pam \
	gettext \
	s6 \
	curl \
	openssh \
	tzdata  && \
	addgroup -S -g 1000 git && \
	adduser -S -H -D -h /data/git -s /bin/bash -u 1000 -G git git && \
	echo "git:$(date +%s | sha256sum | base64 | head -c 32)" | chpasswd

ENV USER=git
ENV GITEA_CUSTOM=/data/gitea GITEA_WORK_DIR=/data/gitea
ENV GODEBUG=netdns=go

VOLUME ["/data"]

ENTRYPOINT ["/usr/bin/entrypoint"]
CMD ["/bin/s6-svscan", "/etc/s6"]

COPY --from=build-env /docker/root /
COPY --from=build-env /gitea /app/gitea/gitea
