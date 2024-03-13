# syntax=docker/dockerfile:1

FROM alpine:3.19

# set version label
ARG BUILD_DATE
ARG VERSION
ARG JACKETT_RELEASE
LABEL build_version="Linuxserver.io armv7 fork version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="lggomez"

#Â environment settings
ENV XDG_DATA_HOME="/config" \
XDG_CONFIG_HOME="/config"

RUN \
  echo "**** install packages ****" && \
    apk --no-cache add \
    icu-data-full \
    icu-libs \
    curl \
    jq && \
  echo "**** install jackett ****" && \
  mkdir -p \
    /app/Jackett && \
  if [ -z ${JACKETT_RELEASE+x} ]; then \
    JACKETT_RELEASE=$(curl -sX GET "https://api.github.com/repos/Jackett/Jackett/releases/latest" \
    | jq -r .tag_name); \
  fi && \
  curl -o \
    /tmp/jacket.tar.gz -L \
    "https://github.com/Jackett/Jackett/releases/download/${JACKETT_RELEASE}/Jackett.Binaries.LinuxMuslARM32.tar.gz" && \
  tar xf \
    /tmp/jacket.tar.gz -C \
    /app/Jackett --strip-components=1 && \
  echo "**** fix for host id mapping error ****" && \
  chown -R root:root /app/Jackett && \
  echo "**** save docker image version ****" && \
  echo "${VERSION}" > /etc/docker-image && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

#Â add local files
COPY root/ /

# ports and volumes
VOLUME /config
EXPOSE 9117

ENTRYPOINT ./app/Jackett/jackett_launcher.sh && bash
