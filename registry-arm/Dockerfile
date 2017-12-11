FROM kunde21/go-arm:latest AS build-env

ENV DOCKER_BUILDTAGS include_oss include_gcs

RUN set -ex \
	&& apk add --no-cache make git && \
	go get github.com/docker/distribution/cmd/registry && \
	git clone https://github.com/docker/distribution-library-image && \
	mv distribution-library-image /distImg

FROM alpine:3.7

ENV PATH /go/bin:$PATH

COPY --from=build-env /go/bin/registry /go/bin/registry
COPY --from=build-env /distImg/registry/config-example.yml /etc/docker/registry/config.yml
COPY --from=build-env /distImg/docker-entrypoint.sh /entrypoint.sh

RUN sed -i -r 's/storage:/\0\n  delete:\n    enabled: true/g' /etc/docker/registry/config.yml \
    && crontab -l | { cat; echo "0	0	*/15	*	*	registry garbage-collect /etc/docker/registry/config.yml"; } | crontab -

VOLUME ["/var/lib/registry"]
EXPOSE 5000
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/etc/docker/registry/config.yml"]
