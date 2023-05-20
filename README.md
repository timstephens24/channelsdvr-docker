# Channels DVR Docker

The main difference between this docker and the official docker from fancybits is that it runs Channels DVR as a normal user that's mappable with environment variables instead of root. This gives all my media the correct permissions as owned by my user and not by root.

This supports TVE and hardware transcoding with Intel and NVIDIA. Intel support requires the `--device /dev/dri:/dev/dri` line in order to pass the video card device to the container. NVIDIA support requires the `runtime: nvidia` line and the environment variable for `NVIDIA_VISIBLE_DEVICES`.

It's also set to expose port 8089 (tcp) and 1900 (udp), so it should be able to run with just exposing those ports, but I run it in host mode. Let me know if there's any issues here.

For Unraid I also have templates in the app store. I have channels-dvr located at /mnt/user/appdata/channels-dvr and my Media folder is /mnt/user/data/Media and I have the ChannelsDVR folder in there for recordings, so you will need to modify them accordingly.

## Usage for Intel
### docker-compose (recommended)
```yaml
version: "3.8"
services:
  channels-dvr:
    network_mode: host
    restart: always
    container_name: channels-dvr
    hostname: channels
    image: timstephens24/channels-dvr:latest
    security_opt:
      - seccomp=unconfined
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
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
  --security-opt seccomp=unconfined \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/New_York \
  --volume /opt/channels:/channels-dvr \
  --volume /mnt/disk/dvr/recordings:/shares/DVR \
  --volume /etc/localtime:/etc/localtime:ro \
  --device /dev/dri:/dev/dri \
  timstephens24/channels-dvr:latest
```
## Usage for NVIDIA
### docker-compose (recommended)
```yaml
version: "3.8"
services:
  channels-dvr:
    network_mode: host
    restart: always
    container_name: channels-dvr
    hostname: channels
    image: timstephens24/channels-dvr
    runtime: nvidia
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
```
### docker cli
```
docker run \
  --detach \
  --net=host \
  --restart=always \
  --name=channels-dvr \
  --hostname=channels \
  --runtime=ndvida \
  --security-opt seccomp=unconfined \
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
## Updating to a specific pre-release version:

The Channels-DVR setup.sh is packaged with the container in the /usr/local/bin folder in the container. This allows you to roll back to whatever version you want by running this command (example version is 2023.05.20.0631):

```docker exec -it channels-dvr bash -c "DVR_VERSION=2023.05.20.0631 /usr/local/bin/setup.sh" && docker restart channels-dvr```

This works really well to downgrade to previous pre-release versions really easy. I did test rolling back stable releases, which you can do, but Channels will download the most recent stable release when it starts, and then will potentially automatically update itself. This is normal Channels behavior.

## Contact information:

| Type | Address/Details |
| :---: | --- |
| Channels | https://getchannels.com
| Forums | timstephens24
| Email | timstephens24@gmail.com
| Github | https://github.com/timstephens24/channelsdvr-docker

