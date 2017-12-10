FROM kunde21/go-arm:latest AS build-env

ENV GOPATH /gopath
ENV PATH $PATH:/gopath/bin
ENV GODEBUG netdns=go
ENV GITEA_VERSION v1.3.1
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

RUN go get -u github.com/jteeuwen/go-bindata/... && \
	cd /gopath/src && mkdir -p code.gitea.io/gitea && cd code.gitea.io/gitea && \
	wget https://github.com/go-gitea/gitea/archive/$GITEA_VERSION.tar.gz -O ../gitea.tar.gz && \
	tar xf ../gitea.tar.gz --strip-components=1 && \
	go generate ./... && \
	go build -v -o /gitea -tags "$TAGS" -ldflags=`-s -w -X "main.Version=$GITEA_VERSION" -X "main.Tags=$TAGS"` && \
	mv docker /docker && \
	/gitea -h || echo "done"


FROM alpine:3.7

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
