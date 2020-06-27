

Had chrome issues and need to make some changes to get Chrome to work properly when scanning:

```
wget https://raw.githubusercontent.com/jfrazelle/dotfiles/master/etc/docker/seccomp/chrome.json -O ${DOCKERDIR}/shared/chrome.json
```

docker compose:
  
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
      - /mnt/data:/mnt/data
      - ${LOCALTIME}:/etc/localtime:ro
    devices:
      - /dev/dri:/dev/dri


