FROM kunde21/go-arm:latest AS build-env

ENV GOPATH /gopath
ENV GODEBUG netdns=go
ENV DRONE_VERSION v0.8.1

RUN apk update && apk upgrade && \
	apk add --no-cache git \
		gcc \
		wget \
		musl-dev \ 
		openssl \
		sqlite \
		sqlite-libs \
		zip ;

RUN go get -v github.com/drone/drone-ui/dist && go get -u -t github.com/jteeuwen/go-bindata/... && \
	cd /gopath/src/github.com && mkdir -p drone/drone && ls && cd drone && \
	wget https://github.com/drone/drone/archive/$DRONE_VERSION.tar.gz -O drone.tar.gz && \
	tar xf drone.tar.gz -C ./drone --strip-components=1 && \
	go get -v github.com/drone/drone-ui/dist && \
	go get -u golang.org/x/net/context && \
	go get -u golang.org/x/net/context/ctxhttp && \
	go get -u github.com/golang/protobuf/proto && \
	go get -u github.com/golang/protobuf/protoc-gen-go && \
	go build -o /drone-agent github.com/drone/drone/cmd/drone-agent && \
	go build -o /drone-server github.com/drone/drone/cmd/drone-server 


FROM kunde21/alpine-armhf:latest

EXPOSE 80 8000 443

ENV DRONE_DATABASE_DRIVER sqlite3
ENV DRONE_DATABASE_DATASOURCE /var/lib/drone/drone.sqlite

RUN apk update && apk upgrade && \
	apk add --no-cache ca-certificates git \
		sqlite sqlite-libs openssl

COPY --from=build-env /drone-agent /drone-agent
COPY --from=build-env /drone-server /drone-server

VOLUME ["/var/lib/drone"]

ENTRYPOINT ["/bin/sh"]
CMD ["/drone-server"]
