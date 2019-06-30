FROM golang:1.12.6 as build

WORKDIR /src/mongodb_exporter
RUN git clone "https://github.com/percona/mongodb_exporter.git" . && make build

FROM scratch

COPY --from=build /src/mongodb_exporter/bin/mongodb_exporter /bin/mongodb_exporter

EXPOSE 9216

ENTRYPOINT [ "/bin/mongodb_exporter" ]
