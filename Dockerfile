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

RUN echo "**** install chrome ****" \
  && apt-get update \
  && apt-get install -y --no-install-recommends wget iproute2 beignet-opencl-icd jq ocl-icd-libopencl1 udev unrar wget \
  && COMP_RT_RELEASE=$(curl -sX GET "https://api.github.com/repos/intel/compute-runtime/releases/latest" | jq -r '.tag_name') \
  && COMP_RT_URLS=$(curl -sX GET "https://api.github.com/repos/intel/compute-runtime/releases/tags/${COMP_RT_RELEASE}" | jq -r '.body' | grep wget | sed 's|wget ||g') \
  && mkdir -p /opencl-intel \
  && for i in ${COMP_RT_URLS}; do \
      i=$(echo ${i} | tr -d '\r'); \
      echo "**** downloading ${i} ****"; \
      curl -o "/opencl-intel/$(basename ${i})" -L "${i}"; \
    done \
  && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends google-chrome-stable \
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
