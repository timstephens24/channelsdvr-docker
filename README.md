# Channels DVR Docker

The main difference between this docker and the official docker from fancybits is that it runs Channels DVR as a normal user that's mappable with environment variables instead of root. This gives all my media the correct permissions as owned by my user and not by root.

This supports TVE and hardware transcoding with Intel and NVIDIA. If you don't need the Intel support remove the line the says `--device /dev/dri:/dev/dri \` (or the last two lines in the docker-compose). If you don't need NVIDIA support you can remove the environment variable for `NVIDIA_VISIBLE_DEVICES` but there's no harm in leaving it.

It's also set to expose port 8089 (tcp) and 1900 (udp), so it should be able to run with just exposing those ports, but I run it in host mode. Let me know if there's any issues here.

For Unraid I also have templates at: https://github.com/timstephens24/docker-templates. I have channels-dvr located at /mnt/user/appdata/channels-dvr and my Media folder is /mnt/user/data/Media and I have the ChannelsDVR folder in there for recordings, so you will need to modify them accordingly.

## Usage
### docker-compose (recommended)
```yaml
version: "3.8"
services:
  channels-dvr:
    network_mode: host
    restart: always
    container_name: channels-dvr
    hostname: channels
    # When using Nvidia Hardware and docker-compose version 1.29.2 add runtime
    runtime: nvidia
    image: timstephens24/channels-dvr
    security_opt:
      - seccomp=unconfined
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
      - NVIDIA_VISIBLE_DEVICES=all
    volumes:
      - /opt/channels-dvr:/channels-dvr
      - /mnt/disk/dvr/recordings:/shares/DVR # where you put the media files
      - /etc/localtime:/etc/localtime:ro
    devices:
      - /dev/dri:/dev/dri
```
### docker cli
```
docker run \
  --detach \
  --net=host \
  --restart=always \
  --name=channels-dvr \
  --hostname=channels \
  --runtime=nvidia \
  --security-opt seccomp=unconfined
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/New_York \
  -e NVIDIA_VISIBLE_DEVICES=all \
  --volume /opt/channels:/channels-dvr \
  --volume /mnt/disk/dvr/recordings:/shares/DVR \
  --volume /etc/localtime:/etc/localtime:ro \
  --device /dev/dri:/dev/dri \
  timstephens24/channels-dvr
```

## Contact information:

| Type | Address/Details |
| :---: | --- |
| Channels | https://getchannels.com
| Forums | timstephens24
| Email | timstephens24@gmail.com
| Github | https://github.com/timstephens24/channelsdvr-docker

