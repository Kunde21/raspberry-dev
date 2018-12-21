FROM golang:1.11-alpine AS build-env

ARG GITEA_VERSION=v1.6.2

ENV GOPATH /gopath
ENV PATH $PATH:/gopath/bin
ENV GODEBUG netdns=go
ENV TAGS bindata sqlite 

RUN apk update && apk upgrade && \
	apk add --no-cache git \
		bash \
		linux-pam \
		curl \
		make \
		tzdata \
		gcc \
		musl-dev \ 
		openssl \
		openssh \
		openssh-client \
		sqlite \
		sqlite-libs \
		wget ;

WORKDIR /gopath/src/code.gitea.io/gitea

RUN if [ "$GITEA_VERSION" = "latest" ]; then GITEA_VERSION=$(curl --silent "https://api.github.com/repos/go-gitea/gitea/releases/latest" |  grep '"tag_name":' |  sed -E 's/.*"([^"]+)".*/\1/'); fi && \
	go get -u github.com/jteeuwen/go-bindata/... && \
	wget https://github.com/go-gitea/gitea/archive/$GITEA_VERSION.tar.gz -O ../gitea.tar.gz && \
	tar xf ../gitea.tar.gz --strip-components=1 

RUN go generate ./...

RUN go build -v -tags "$TAGS"  ./modules/...

RUN go build -v -tags "$TAGS"  ./routers/...

RUN go build -v -tags "$TAGS"  ./cmd

RUN go build -v -o /gitea -tags "$TAGS" -ldflags="-s -w -X 'main.Version=$GITEA_VERSION' -X 'main.Tags=$TAGS'"

RUN mv docker /docker &&  /gitea -h


FROM alpine:3.8

EXPOSE 22 3000

RUN apk --no-cache add \
	su-exec \
	ca-certificates \
	sqlite \
	bash \
	git \
	linux-pam \
	s6 \
	curl \
	openssh \
	tzdata  && \
	addgroup \
	-S -g 1000 \
	git && \
	adduser \
	-S -H -D \
	-h /data/git \
	-s /bin/bash \
	-u 1000 \
	-G git \
	git && \
	echo "git:$(date +%s | sha256sum | base64 | head -c 32)" | chpasswd

ENV USER git
ENV GITEA_CUSTOM /data/gitea
ENV GODEBUG=netdns=go

VOLUME ["/data"]

ENTRYPOINT ["/usr/bin/entrypoint"]
CMD ["/bin/s6-svscan", "/etc/s6"]

COPY --from=build-env /docker /
COPY --from=build-env /gitea /app/gitea/gitea
