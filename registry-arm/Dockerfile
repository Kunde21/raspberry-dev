FROM kunde21/go-arm:latest AS build-env

ENV DOCKER_BUILDTAGS include_oss include_gcs

WORKDIR /go/src/github.com/docker

RUN set -ex \
	&& apk add --no-cache make git && \
	git clone https://github.com/docker/distribution && cd distribution && \
	make PREFIX=/go clean binaries && \
	cp cmd/registry/config-dev.yml /config.yml


FROM kunde21/alpine-armhf:latest

ENV PATH /go/bin:$PATH

COPY --from=build-env /go/bin /go/bin
COPY --from=build-env /config.yml /etc/docker/registry/config.yml

VOLUME ["/var/lib/registry"]
EXPOSE 5000
ENTRYPOINT ["registry"]
CMD ["serve", "/etc/docker/registry/config.yml"]
