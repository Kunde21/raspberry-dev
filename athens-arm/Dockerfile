FROM golang:1.12-alpine AS build-env

ARG ATHENS_VERSION=master
ARG GOPROXY

ENV DATE="$(date -u +%Y-%m-%d-%H:%M:%S-%Z)"
ENV GO111MODULE=on
ENV CGO_ENABLED=0

WORKDIR /athens

RUN apk update && apk upgrade && \
	apk add --no-cache git \
		wget ;

RUN if [ "$ATHENS_VERSION" = "latest" ]; then GITEA_VERSION=$(curl --silent "https://api.github.com/repos/gomods/athens/releases/latest" |  grep '"tag_name":' |  sed -E 's/.*"([^"]+)".*/\1/'); fi && \
	wget https://github.com/gomods/athens/archive/$ATHENS_VERSION.tar.gz -O ../athens.tar.gz && \
	tar xf ../athens.tar.gz --strip-components=1 

RUN go build -ldflags '-X ./pkg/build.version="$ATHENS_VERSION" -X ./pkg/build.buildDate="$DATE"' -o /output/athens-proxy ./cmd/proxy && \
	mv config.dev.toml /output/config.toml && \
	mv /usr/local/go/bin/go /output/go

FROM alpine

ENV GO111MODULE=on
ENV GO_ENV=production

EXPOSE 3000

COPY --from=build-env /output /bin/

RUN apk add --update \
	bzr \
	git \
	mercurial \
	openssh-client \
	subversion \
	procps \
	fossil \
	tini \
	&& \
	mkdir -p /usr/local/go /config && \
	mv /bin/config.toml /config/config.toml && \
	[ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf


ENTRYPOINT [ "/sbin/tini", "--" ]

CMD ["athens-proxy", "-config_file=/config/config.toml"]
