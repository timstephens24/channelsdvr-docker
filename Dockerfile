FROM timstephens24/ubuntu
ARG BUILD_DATE
ARG VERSION
ARG CHANNELS_RELEASE
LABEL build_version="stephens.cc version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="timstephens24"

#Add needed nvidia environment variables for https://github.com/NVIDIA/nvidia-docker
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

RUN echo "**** install chrome ****" \
  && apt update \
  && apt install -y --no-install-recommends wget iproute2 \
  && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list \
  && apt update \
  && apt install -y --no-install-recommends google-chrome-stable \
  && echo "**** install channels-dvr ****" \
  && curl -f -s https://getchannels.com/dvr/setup.sh | DOWNLOAD_ONLY=1 sh \
  && echo "**** ensure abc user's home folder is /channels-dvr ****" \
  && usermod -d /channels-dvr abc \
  && echo "**** cleanup ****" \
  && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8089/tcp 1900/udp
VOLUME /channels-dvr
