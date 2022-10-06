FROM ghcr.io/linuxserver/baseimage-ubuntu:focal
ARG BUILD_DATE
ARG VERSION
ARG CHANNELS_RELEASE
LABEL build_version="stephens.cc version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="timstephens24"

#Add needed nvidia environment variables for https://github.com/NVIDIA/nvidia-docker
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

RUN echo "**** add Intel repo ****" \
  && curl -sL https://repositories.intel.com/graphics/intel-graphics.key | apt-key add - \
  && echo 'deb [arch=amd64] https://repositories.intel.com/graphics/ubuntu focal main' > /etc/apt/sources.list.d/intel.list \
  && echo "**** install chrome repo ****" \
  && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list \
  && echo "**** install runtimes ****"
  && apt-get install -y --no-install-recommends google-chrome-stable iproute2 jq udev unrar wget \
    intel-igc-cm=1.0.128+i699.3~u20.04 intel-opencl-icd=21.49.21786+i643~u20.04 libigc1=1.0.10409+i699.3~u20.04 \
    libigdfcl1=1.0.10409+i699.3~u20.04 libigdgmm11=21.3.3+i643~u20.04 \
  && echo "**** install channels-dvr ****" \
  && curl -f -s https://getchannels.com/dvr/setup.sh | DOWNLOAD_ONLY=1 sh \
  && echo "**** ensure abc user's home folder is /channels-dvr ****" \
  && usermod -d /channels-dvr abc \
  && chown -R abc:abc /channels-dvr \
  && echo "**** cleanup ****" \
  && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8089/tcp 1900/udp
VOLUME /channels-dvr
