FROM timstephens24/baseimage-ubuntu:jammy
ARG BUILD_DATE
LABEL build_version="stephens.cc build-date:${BUILD_DATE}"
LABEL maintainer="tim@stephens.cc"

#Add needed nvidia environment variables for https://github.com/NVIDIA/nvidia-docker
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

RUN echo "**** add chrome repo ****" \
  && curl -sL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list \
  && echo "**** install runtimes ****" \
  && apt-get update \
  && apt-get install -y --no-install-recommends google-chrome-stable iproute2 jq mesa-va-drivers udev unrar wget \
  && echo "**** install channels-dvr ****" \
  && curl https://getchannels.com/dvr/setup.sh --output /usr/local/bin/setup.sh \
  && chmod +x /usr/local/bin/setup.sh \
  && /usr/local/bin/setup.sh DOWNLOAD_ONLY=1 \
  && echo "**** ensure abc user's home folder is /channels-dvr ****" \
  && usermod -d /channels-dvr abc \
  && chown -R abc:abc /channels-dvr \
  && find /channels-dvr -type f -name channels-dvr -exec chmod +x {} \; \
  && find /channels-dvr -type f -name "ffmpeg"* -exec chmod +x {} \; \
  && find /channels-dvr -type f -name comskip -exec chmod +x {} \; \
  && find /channels-dvr -type f -name ffprobe -exec chmod +x {} \; \
  && echo "**** cleanup ****" \
  && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8089/tcp 1900/udp
VOLUME /channels-dvr
