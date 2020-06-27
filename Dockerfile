FROM lsiobase/ubuntu:focal
ARG BUILD_DATE
ARG VERSION
ARG CHANNELS_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="ChiefWulf"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y \
    ca-certificates \
    chromium-browser \
    curl \
    iproute2 \
    wget && \
  echo "**** install channels-dvr ****" && \
  curl -f -s https://getchannels.com/dvr/setup.sh | DOWNLOAD_ONLY=1 sh && \
  echo "**** ensure abc user's home folder is /channels-dvr ****" && \
  usermod -d /channels-dvr abc && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8089/tcp 1900/udp
VOLUME /channels-dvr
