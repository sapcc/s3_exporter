FROM golang:1.23-alpine3.21 AS build

ADD . /tmp/s3_exporter

RUN cd /tmp/s3_exporter && \
    echo "s3:*:100:s3" > group && \
    echo "s3:*:100:100::/:/s3_exporter" > passwd && \
    CGO_ENABLED=0 go build -o s3_exporter

FROM scratch
LABEL source_repository="https://github.com/sapcc/s3_exporter"

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /tmp/s3_exporter/group \
    /tmp/s3_exporter/passwd \
    /etc/
COPY --from=build /tmp/s3_exporter/s3_exporter /

USER s3:s3
EXPOSE 9340/tcp
ENTRYPOINT ["/s3_exporter"]
