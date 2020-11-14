# logitechmediaserver

The [LMS Community](https://github.com/LMS-Community)'s Docker image for [Logitech Media Server](https://github.com/Logitech/slimserver/)

Run:

```
docker run -it \
      -v "<somewhere>":"/config":rw \
      -v "<somewhere>":"/music":ro \
      -v "<somewhere>":"/playlist":ro \
      -v "/etc/localtime":"/etc/localtime":ro \
      -v "/etc/timezone":"/etc/timezone":ro \
      -p 9000:9000/tcp \
      -p 9090:9090/tcp \
      -p 3483:3483/tcp \
      -p 3483:3483/udp \
      lmscommunity/logitechmediaserver
```

Docker compose:
```
version: '3'
services:
  lms:
    container_name: lms
    image: lmscommunity/logitechmediaserver
    volumes:
      - /<somewhere>:/config:rw
      - /<somewhere>:/music:ro
      - /<somewhere>:/playlist:ro
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
    ports:
      - 9000:9000/tcp
      - 9090:9090/tcp
      - 3483:3483/tcp
      - 3483:3483/udp
    restart: always
```

Alternatively you can specify the user and group id to use:
For run add:
```
  -e PUID=1000 \
  -e PGID=1000
 ```
For compose add:
```
environment:
  - PUID=1000
  - PGID=1000
 ```