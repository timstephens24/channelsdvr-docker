## Contact information:-

| Type | Address/Details |
| :---: | --- |
| Forums | [ChannelsDVR forum]timstephens24
| Email | [Gmail] timstephens24@gmail.com

Learn more about Channels at https://getchannels.com

The main difference between this docker and the official docker from fancybits is that it runs Channels DVR as a normal user that's mappable with environment variables instead of root. This gives all my media the correct permissions as owned by my user and not by root.

I also needed TVE support (Comcast only gives me DIY in SD... ew), so I needed to bake that support in as well. I based all this off the linuxserver.io group's docker containers and used their ubuntu focal base as a start so I didn't need to recreate it (and subsequently update it).

It's also set to expose port 8089 (tcp) and 1900 (udp), so it should be able to run with just exposing those ports, but I run it in host mode. Let me know if there's any issues here.

I do have some Chrome issues and needed to make some changes to get Chrome to work properly when scanning:
```
DOCKERDIR=/opt/docker
mkdir ${DOCKERDIR}/shared
wget https://raw.githubusercontent.com/jfrazelle/dotfiles/master/etc/docker/seccomp/chrome.json -O ${DOCKERDIR}/shared/chrome.json
```

Personally I prefer to run it with docker compose, and use hardware transcoding. My .env file has the DOCKERDIR, PUID, PGID, TZ, and LOCALTIME variables set, so if you don't use that make sure you change the variables below to the actual value. Also, if you want don't hardware transcoding (or it's not supported on your system) remove the last two lines:
```
version: "3.8"
services:
  channels-dvr:
    network_mode: host
    restart: always
    container_name: channels-dvr
    hostname: channels
    image: timstephens24/channels-dvr
    security_opt:
      - seccomp=${DOCKERDIR}/shared/chrome.json
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ${DOCKERDIR}/channels-dvr:/channels-dvr
      - /mnt/disk/dvr/recordings:/shares/DVR # where you put the media files
      - ${LOCALTIME}:/etc/localtime:ro
    devices:
      - /dev/dri:/dev/dri
```

A docker run command that's similar would be:
```
docker run \
  --detach \
  --net=host \
  --restart=always \
  --name=channels-dvr \
  --security-opt seccomp=/opt/docker/shared/chrome.json
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/New_York \
  --volume /mnt/disk/dvr/config:/channels-dvr \
  --volume /mnt/disk/dvr/recordings:/shares/DVR \
  --volume /etc/localtime:/etc/localtime:ro
  --device /dev/dri:/dev/dri \
  timstephens24/channels-dvr
```

I've also tested this with Unraid using NVIDIA for hardware transcoding, so this should work with the others if you add in the environmental values for NVIDIA. For Unraid I also have templates at: https://github.com/timstephens24/docker-template. The only extra thing you need to add is '--runtime=nvidia --security-opt seccomp=/mnt/user/appdata/shared/chrome.json' (you need to still download the chrome.json mentioned above and my ${DOCKERDIR} is /mnt/user/appdata) and then modify the other directories accordingly. I have channels-dvr located at /mnt/user/appdata/channels-dvr and my Media folder is /mnt/user/data/Media and I have the ChannelsDVR folder in there for recordings.
