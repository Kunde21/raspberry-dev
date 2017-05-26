FROM kunde21/go-arm:latest AS build-env

ENV GOPATH /gopath
ENV GODEBUG netdns=go

RUN apk update && apk upgrade && \
	apk add --no-cache git \
		gcc \
		musl-dev \ 
		openssl \
		sqlite \
		sqlite-libs \
		zip ;

RUN go get -u -t github.com/jteeuwen/go-bindata/... && \
	cd /gopath/src/github.com && mkdir drone && ls && cd drone && \
	git clone https://github.com/drone/drone && \
	cd drone && go get ./...  && \
	go generate ./store/datastore/ddl && \
	cd drone && go build -o /drone


FROM kunde21/alpine-armhf:latest

EXPOSE 80 8000 443

ENV DRONE_DATABASE_DRIVER sqlite3
ENV DRONE_DATABASE_DATASOURCE /var/lib/drone/drone.sqlite

RUN apk update && apk upgrade && \
	apk add --no-cache ca-certificates git \
		sqlite sqlite-libs openssl

COPY --from=build-env /drone /drone

VOLUME ["/var/lib/drone"]

ENTRYPOINT ["/drone"]
CMD ["server"]
