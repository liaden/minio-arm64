FROM  arm64v8/golang:1.10-alpine3.7 as builder
LABEL maintainer="Minio Inc <dev@minio.io>"
ENV GOPATH /go 
ENV PATH $PATH:$GOPATH/bin 
ENV CGO_ENABLED 0 
ENV MINIO_UPDATE off 
ENV MINIO_ACCESS_KEY_FILE=access_key \ 
    MINIO_SECRET_KEY_FILE=secret_key 

WORKDIR /go/src/github.com/minio/


RUN  apk add --no-cache ca-certificates 'curl>7.61.0' && \
     apk add --no-cache --virtual .build-deps git

RUN  echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf
RUN  go get -v -d github.com/minio/minio 
RUN  cd /go/src/github.com/minio/minio && \
     go install -v -ldflags "$(go run buildscripts/gen-ldflags.go)" 

RUN  rm -rf /go/pkg /go/src /usr/local/go && apk del .build-deps



FROM arm64v8/alpine:3.7 

COPY --from=builder /go/bin/minio /usr/bin/minio
ADD https://raw.githubusercontent.com/minio/minio/master/dockerscripts/docker-entrypoint.sh https://raw.githubusercontent.com/minio/minio/master/dockerscripts/healthcheck.sh /usr/bin/

RUN chmod +x /usr/bin/minio /usr/bin/healthcheck.sh /usr/bin/docker-entrypoint.sh

EXPOSE 9000
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
VOLUME ["/data"]

HEALTHCHECK --interval=30s --timeout=5s \
    CMD /usr/bin/healthcheck.sh

CMD ["minio"]
