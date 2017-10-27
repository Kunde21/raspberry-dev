FROM kunde21/go-arm:latest AS build-env

ENV DOCKER_BUILDTAGS include_oss include_gcs

WORKDIR /go/src/github.com/docker

RUN set -ex \
	&& apk add --no-cache make git && \
	git clone https://github.com/docker/distribution && cd distribution && \
	make PREFIX=/go clean binaries && \
	cd / && git clone https://github.com/docker/distribution-library-image && \
	mv distribution-library-image distImg
	


FROM kunde21/alpine-armhf:latest

ENV PATH /go/bin:$PATH

COPY --from=build-env /go/bin /go/bin
COPY --from=build-env /distImg/registry/config-example.yml /etc/docker/registry/config.yml
COPY --from=build-env /distImg/docker-entrypoint.sh /entrypoint.sh

VOLUME ["/var/lib/registry"]
EXPOSE 5000
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/etc/docker/registry/config.yml"]
