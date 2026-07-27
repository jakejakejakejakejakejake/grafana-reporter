# build
FROM golang:1.22-alpine3.20 AS build
WORKDIR /go/src/${owner:-github.com/IzakMarais}/reporter
RUN apk update && apk add make git
ADD . .
RUN make build

# create image
FROM alpine:3.20
COPY util/texlive.profile /

RUN apk add --no-cache \
    wget \
    ca-certificates \
    perl \
    gzip \
    tar \
    xz \
    && mkdir -p /root \
    && wget -qO- "https://tinytex.yihui.org/install-bin-unix.sh" | sh -s --no-path \
    && mv ~/.TinyTeX /opt/TinyTeX \
    && /opt/TinyTeX/bin/*/tlmgr path add \
    && /opt/TinyTeX/bin/*/tlmgr install epstopdf-pkg \
    && chown -R root:adm /opt/TinyTeX \
    && chmod -R g+w /opt/TinyTeX \
    && chmod -R g+wx /opt/TinyTeX/bin

ENV PATH="/opt/TinyTeX/bin/x86_64-linuxmusl:${PATH}"

COPY --from=build /go/bin/grafana-reporter /usr/local/bin
ENTRYPOINT [ "/usr/local/bin/grafana-reporter" ]
